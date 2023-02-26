import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import { generic } from "@dashkite/joy/generic"
import JSONQuery from "json-query"

pipe = ( fx ) ->
  switch fx.length
    when 1 then -> fx[0].apply null, arguments
    when 2 then -> fx[1] fx[0].apply null, arguments
    when 3 then -> fx[2] fx[1] fx[0].apply null, arguments
    when 4 then -> fx[3] fx[2] fx[1] fx[0].apply null, arguments
    when 5 then -> fx[4] fx[3] fx[2] fx[1] fx[0].apply null, arguments
    else ( args... ) ->
      for f in fx
        args = [ f.apply null, args ]       
      args[0]

skip = ( input, state ) -> state

push = ( mode ) ->
  ( state ) ->
    state.mode.push mode
    state

pop = ( state ) ->
  state.mode.pop()
  state

poke = ( mode ) ->
  ( state ) ->
    state.mode.pop()
    state.mode.push mode
    state

trim = ( state ) ->
  state.current = state.current.trim()
  state

save = ( name ) ->
  (state ) ->
    ( state.data[ name ] ?= [] ).push state.current
    state

clear = ( state ) ->
  state.current = ""
  state

append = ( c, state ) ->
  state.current += c
  state

appendText = ( text ) ->
  ( state ) ->
    state.current += text
    state

prefix = ( text, f ) ->
  ( c, state ) -> f "#{text}#{c}", state

tokens =
  escape: "\\"
  start: "$"
  open: "{"
  close: "}"

rules =

  text:
    default: append
    [ tokens.escape ]: pipe [ skip, push "escape" ]
    [ tokens.start ]: pipe [ skip, push "start" ]
    end: pipe [
      skip
      save "text"
      ( state ) ->
        { text, expressions } = state.data
        text ?= []
        expressions ?= []
        j = Math.max text.length, expressions.length
        for i in [0...j]
          [ text[ i ], expressions[ i ] ]
    ]

  escape:
    default: pipe [ append, pop ]

  expression:
    default: append
    [ tokens.escape ]: pipe [ skip, push "escape" ]
    [ tokens.close ]: pipe [
      skip
      pop
      trim
      save "expressions"
      clear
    ]

  start:

    default: pipe [
      prefix "$", append
      pop
    ]

    [ tokens.escape ]: pipe [
      skip
      appendText "$"
      push "escape"
    ]

    [ tokens.open ]: pipe [
      skip
      poke "expression"
      save "text"
      clear
    ]


getContext = ( state ) ->
  i = state.index
  state.text[( i - 5)..( i + 5 )]

getMode = ( state ) ->
  state.mode[ state.mode.length - 1 ]

getExpected = ( state ) ->
  mode = getMode state
  ( Object.keys state.rules[ mode ] ).join ", "

isFinished = ( start, state ) ->
  state.mode.length == 1 && state.mode[0] == start  

run = ( input, state ) ->
  mode = getMode state
  if ( group = rules[ mode ] )?
    if ( rule = ( group[ input ] ? group.default ) )?
      rule input, state
    else
      expected = getExpected state
      context = getContext state
      throw new Error "parse error at '#{ context }'.
        Expected one of: [ #{ expected } ], got: '#{ input }'"
  else
    throw new Error "parser in an unknown state: #{ mode }"

class LRUCache
  
  constructor: ( @cache = new Map, @max = 1e6 ) ->

  keys: -> Array.from @cache.keys()

  get: ( key ) ->
    if ( result = @cache.get key )?
      # refresh key
      @cache.delete key
      @cache.set key, result
      result
  
  set: ( key, value ) ->
    # refresh key
    if ( @cache.get key )?
      @cache.delete key
    else if @cache.size == @max
      @cache.delete @keys()[0]
    @cache.set key, value

memoize = ( f ) ->
  do ( cache = new LRUCache ) ->
    ( input ) ->
      if ( result = cache.get input )?
        result
      else
        result = f input
        cache.set input, result
        result

make = ( rules, start ) ->
  memoize ( text ) ->
    state =
      mode: [ start ]
      data: {}
      current: ""
      text: text
      rules: rules
    try
      for c, i in text
        state.index = i
        run c, state
      if isFinished start, state
        run "end", state
      else
        mode = getMode state
        throw new Error "unexpected end of input while parsing [ #{ mode } ]"
    catch error
      context = getContext state
      console.error "unexpected parse error at '#{ context }' on: [ #{ input } ]."
      throw error

parse = make rules, "text"

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

  for [ text, expression ] in parse text

    text = if text != "" then text

    value = if expression?
      query expression, context
    
    result = cat result, cat text, value

  result ? ""

export { expand, parse, query }