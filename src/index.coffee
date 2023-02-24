import Crypto from "node:crypto"

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

hash = ( value ) ->
  Crypto
    .createHash "md5"
    .update JSON.stringify value
    .digest "hex"

Cache = do ( cache = new Map, max = 100000 ) ->

  get: ( key ) ->
    if ( result = cache.get key )?
      # refresh key
      cache.delete key
      cache.set key
  
  set: ( key, value ) ->
    # refresh key
    if ( cache.get key )?
      cache.delete key
    else if cache.size == max
      cache.delete cache.keys().next().value
    cache.set key, value

cache = ( f ) ->
  ( value, context ) ->
    key = hash { value, context }
    if ( result = Cache.get key)?
      result
    else
      result = f value, context
      Cache.set key, result
      result

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