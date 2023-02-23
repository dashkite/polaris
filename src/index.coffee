import * as Parse from "@dashkite/parse"
import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import { generic } from "@dashkite/joy/generic"
import JSONQuery from "json-query"

start = Parse.text "${"
end = Parse.text "}"
escape = Parse.text "\\"
symbol = Parse.re /^./

escaped = Parse.all [
  Parse.skip escape
  symbol
]

textSymbol = Parse.any [
  escaped
  Parse.negate start
]

expressionSymbol = Parse.any [
  escaped
  Parse.negate end
]

text = Parse.pipe [
  Parse.many textSymbol
  Parse.cat
  Parse.tag "text"
]

expression = Parse.pipe [
  Parse.between [ start, end ], Parse.many expressionSymbol
  Parse.cat
  Parse.trim
  Parse.tag "expression"
]

parse = Parse.parser Parse.pipe [
  Parse.many Parse.any [
    expression
    text
  ]
]

query = ( expression, data ) ->
  ( JSONQuery expression, { data } )?.value

concatenate = ( result, value ) ->
  if result?
    "#{result}#{value}"
  else
    # don't convert to string
    # unless we are concatenating
    value

collate = ( context ) ->
  ( result, [ key, value ]) ->
    result[ key ] = expand value, context
    result

Cache = do ( cache = new Map ) ->

  get: ({ value, context }) ->
    if cache.has value
      subcache = cache.get value
      if subcache.has context
        subcache.get context

  put: ({ value, context, result }) ->
    subcache = undefined
    if cache.has value
      subcache = cache.get value
    else
      subcache = new Map
      cache.set value, subcache
    subcache.set context, result
    result

cache = ( f ) ->
  ( value, context ) ->
    if ( result = Cache.get { value, context } )?
      result
    else
      Cache.put { value, context, result: f value, context }

expand = generic 
  name: "expand"
  default: Fn.identity

generic expand, Type.isObject, Type.isObject, cache ( object, context ) ->
  Object.entries object
    .reduce ( collate context ), {}

generic expand, Type.isArray, Type.isObject, cache ( array, context ) ->
  expand value, context for value in array

generic expand, Type.isString, Type.isObject, cache ( text, context ) -> 
  if text? && text != ""
    result = null
    parse text
    .map ( block ) ->
      if block.text?
        block.text
      else
        query block.expression, context
    .reduce concatenate, null
  else
    ""

export { expand, parse, query }