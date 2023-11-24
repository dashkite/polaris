import { JSONPath as _query } from "jsonpath-plus"

unwrap = ( value ) ->
  if Array.isArray value
    if value.length == 1
      value[ 0 ]
    else if value.length == 0
      undefined
    else value
  else value

query = ( expression, data ) ->
  # ( JSONQuery expression, { data } )?.value
  # unwrap JSONPath.query data, expression
  # JSONata expression
  #   .evaluate data
  unwrap _query expression, data

export { query }

cat = ( a, b ) ->
  if a? && b?
    "#{ a }#{ b }"
  else if a?
    a
  else b

export { cat }