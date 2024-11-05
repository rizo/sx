open Printf

let digit = [%sedlex.regexp? '0' .. '9']
let number = [%sedlex.regexp? Plus digit]

(* let side = [%sedlex.regexp? 'x' | 'y' | 's' | 'e' | 't' | 'r' | 'b' | 'l'] *)
let side = [%sedlex.regexp? Chars "xysetrbl"]

let parse_side buf =
  let out x = x in
  match%sedlex buf with
  | 'x' -> out `x
  | 'y' -> out `y
  | 's' -> out `s
  | 'e' -> out `e
  | 't' -> out `t
  | 'r' -> out `r
  | 'b' -> out `b
  | 'l' -> out `l
  | _ -> failwith "invalid margin"

let parse_border buf =
  match%sedlex buf with
  | eof -> printf "BORDER\n"
  | Chars "xysetrbl" ->
    let x = Sedlexing.Latin1.lexeme buf in
    printf "%s\n" x
  | _ -> failwith "invalid border"

let parse buf =
  match%sedlex buf with
  | "border" -> parse_border buf
  | _ -> failwith "invalid"

let read_margin buf =
  match%sedlex buf with
  | "m-" -> ()
  | _ -> failwith "invalid margin"

let rec token buf =
  let letter = [%sedlex.regexp? 'a' .. 'z' | 'A' .. 'Z'] in
  match%sedlex buf with
  | number ->
    Printf.printf "Number %s\n" (Sedlexing.Latin1.lexeme buf);
    token buf
  | letter, Star ('A' .. 'Z' | 'a' .. 'z' | digit) ->
    Printf.printf "Ident %s\n" (Sedlexing.Latin1.lexeme buf);
    token buf
  | Plus xml_blank -> token buf
  | Plus (Chars "+*-/") ->
    Printf.printf "Op %s\n" (Sedlexing.Latin1.lexeme buf);
    token buf
  | 128 .. 255 -> print_endline "Non ASCII"
  | eof -> print_endline "EOF"
  | _ -> failwith "Unexpected character"

let () =
  let lexbuf = Sedlexing.Latin1.from_string "foobar A123Bfoo  ++123Xbar/foo" in
  token lexbuf
