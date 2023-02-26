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

generic expand, Type.isObject, Type.isObject, ( object, context ) ->
  result = {}
  for key, value of object
    result[ key ] = expand value, context
  result

generic expand, Type.isArray, Type.isObject, ( array, context ) ->
  expand value, context for value in array

generic expand, Type.isString, Type.isObject, ( text, context ) -> 
  result = undefined
  for { text, expression } in scan text
    if text? && text != ""
      result = cat result, text
    else if expression?
      result = cat result, query expression, context
  result ? ""

export { expand, scan, query }