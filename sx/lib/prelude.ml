module String_map = Map.Make (String)
module Char_set = Set.Make (Char)
module String_set = Set.Make (String)

let string_set_of_string_list l =
  List.fold_left (fun acc x -> String_set.add x acc) String_set.empty l

type 'a assoc = (string * 'a) list

let ( or ) opt def =
  match opt with
  | None -> def
  | Some x -> x

let ( let* ) decls gen_decl = List.concat_map gen_decl decls

let rec cartesian_map f l =
  match l with
  | [] -> []
  | [ x ] -> [ f x ]
  | x :: l' ->
    let* x' = f x in
    let* rest = cartesian_map f l' in
    [ x' :: rest ]
