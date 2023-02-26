import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import { generic } from "@dashkite/joy/generic"

import { scan } from "./scan"

import {
  query
  cat
} from "./helpers"

expand = generic 
  name: "expand"
  default: Fn.identity

collate = ( context ) ->
  ( result, [ key, value ]) ->
    result[ key ] = expand value, context
    result

generic expand, Type.isObject, Type.isObject, ( object, context ) ->
  Object.entries object
    .reduce ( collate context ), {}

generic expand, Type.isArray, Type.isObject, ( array, context ) ->
  expand value, context for value in array

generic expand, Type.isString, Type.isObject, ( text, context ) -> 
  
  result = undefined

  for [ text, expression ] in scan text

    text = if text != "" then text

    value = if expression?
      query expression, context
    
    result = cat result, cat text, value

  result ? ""

export { expand, scan, query }