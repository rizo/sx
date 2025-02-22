module Lex = Lex
module Gen = Gen
module Css = Css

let read_string str =
  let theme = Theme.default in
  let lexbuf = Lexing.from_string str in
  Lex.read theme lexbuf

(* let read_string_list strl =
   if List.is_empty strl then invalid_arg "read_string_list: empty input";
   let str = ref (List.hd strl) in
   let lexbuf = Lexing.from_function (fun buf n ->
     n
   ) in
   Lex.read lexbuf *)

let read_channel chan =
  let theme = Theme.default in
  let lexbuf = Lexing.from_channel chan in
  Lex.read theme lexbuf
