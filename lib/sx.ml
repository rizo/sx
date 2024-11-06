module Lex = Lex
module Gen = Gen
module Css = Css

let read_string str =
  let lexbuf = Lexing.from_string str in
  Lex.read lexbuf

let read_channel chan =
  let lexbuf = Lexing.from_channel chan in
  Lex.read lexbuf
