import {
  pipe
  push
  pop
  poke
  skip
  prefix
  append
  tag
  save
  clear
  make
  trim
} from "@dashkite/scan"

finish = ( state ) ->
  { tokens } = state.data
  tokens

# tokens
$ =
  escape: "\\"
  start: "$"
  open: "{"
  close: "}"

scan = make "text",

  text:
  
    default: append
  
    end: pipe [
      skip
      pop
      tag "text"
      save "tokens"
      finish
    ]

    [ $.escape ]: pipe [ skip, push "escape" ]
  
    [ $.start ]: pipe [ skip, push "start" ]
  
  escape:
  
    default: pipe [ append, pop ]

  expression:

    default: append
  
    [ $.escape ]: pipe [ skip, push "escape" ]
  
    [ $.close ]: pipe [
      skip
      pop
      trim
      tag "expression"
      save "tokens"
      clear
    ]

  start:

    default: pipe [
      prefix "$", append
      pop
    ]

    [ $.escape ]: pipe [
      skip
      append "$"
      push "escape"
    ]

    [ $.open ]: pipe [
      skip
      poke "expression"
      tag "text"
      save "tokens"
      clear
    ]

export { scan }