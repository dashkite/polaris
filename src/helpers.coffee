import JSONQuery from "json-query"

query = ( expression, data ) ->
  ( JSONQuery expression, { data } )?.value

export { query }

cat = ( a, b ) ->
  if a? && b?
    "#{ a }#{ b }"
  else if a?
    a
  else b

export { cat }