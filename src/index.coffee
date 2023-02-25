import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import { generic } from "@dashkite/joy/generic"
import JSONQuery from "json-query"

parseText = ( state, c ) ->
  switch c
    when "\\"
      state._mode = "text"
      state.mode = "escape"
    when "$"
      state.mode = "start"
    else
      state.current += c

parseEscape = ( state, c ) ->
  state.current += c
  state.mode = state._mode
  state._mode = undefined

parseExpression = ( state, c ) ->
  switch c
    when "\\"
      state._mode = "expression"
      state.mode = "escape"
    when "}"
      state.mode = "text"
      state.expressions.push state.current.trim()
      state.current = ""
    else
      state.current += c

parseStart = ( state, c ) ->
  switch c
    when "\\"
      state._mode = "text"
      state.mode = "escape"
      state.current += "$"
    when "{"
      state.mode = "expression"
      state.blocks.push state.current
      state.current = ""
    else
      state.mode = "text"
      state.current += "$#{c}"

parse = ( text ) ->

  # initalize parser state
  state =
    mode: "text"
    blocks: []
    expressions: []
    current: ""

  # parse each character
  for c in text
    switch state.mode
      when "text"
        parseText state, c
      when "escape"
        parseEscape state, c
      when "expression"
        parseExpression state, c
      when "start"
        parseStart state, c

  # return result
  if state.mode == "text"
    # push the final block unless it's empty
    if state.current != ""
      state.blocks.push state.current
    for block, i in state.blocks
      if ( expression = state.expressions[ i ] )?
        [ block, state.expressions[ i ] ]
      # there's no corresponding expression 
      # so this is just the closing block
      else [ block ]
  # there was a parse error so we just assume this wasn't
  # an polaris template - maybe we should throw?
  else [ text ]
    
query = ( expression, data ) ->
  ( JSONQuery expression, { data } )?.value

collate = ( context ) ->
  ( result, [ key, value ]) ->
    result[ key ] = expand value, context
    result

cat = ( a, b ) ->
  if a? && b?
    "#{ a }#{ b }"
  else if a?
    a
  else b

expand = generic 
  name: "expand"
  default: Fn.identity

generic expand, Type.isObject, Type.isObject, ( object, context ) ->
  Object.entries object
    .reduce ( collate context ), {}

generic expand, Type.isArray, Type.isObject, ( array, context ) ->
  expand value, context for value in array

generic expand, Type.isString, Type.isObject, ( text, context ) -> 
  
  result = undefined
  
  for [ block, expression ] in parse text

    block = if block != "" then block

    value = if expression?
      query expression, context
    
    result = cat result, cat block, value

  result ? ""

export { expand, parse, query }