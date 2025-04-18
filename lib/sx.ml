module Lex = Lex
module Gen = Gen
module Css = Css

let read_string str =
  let theme = Theme.default in
  let lexbuf = Lexing.from_string str in
  Lex.read theme lexbuf

let read_channel chan =
  let theme = Theme.default in
  let lexbuf = Lexing.from_channel chan in
  Lex.read theme lexbuf

let read_file ~file_name =
  In_channel.with_open_text file_name (Shaper.parse_channel ~file_name)

let eval = Eval.root
