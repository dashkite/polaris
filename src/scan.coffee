import {
  pipe
  push
  pop
  poke
  skip
  prefix
  append
  appendText
  save
  clear
  make
  trim
} from "@dashkite/scan"

finish = ( state ) ->
  { text, expressions } = state.data
  text ?= []
  expressions ?= []
  j = Math.max text.length, expressions.length
  for i in [0...j]
    [ text[ i ], expressions[ i ] ]

$ =
  escape: "\\"
  start: "$"
  open: "{"
  close: "}"

rules =

  text:
    default: append
    [ $.escape ]: pipe [ skip, push "escape" ]
    [ $.start ]: pipe [ skip, push "start" ]
    end: pipe [
      skip
      save "text"
      finish
    ]

  escape:
    default: pipe [ append, pop ]

  expression:
    default: append
    [ $.escape ]: pipe [ skip, push "escape" ]
    [ $.close ]: pipe [
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

    [ $.escape ]: pipe [
      skip
      appendText "$"
      push "escape"
    ]

    [ $.open ]: pipe [
      skip
      poke "expression"
      save "text"
      clear
    ]

scan = make rules, "text"

export { scan }