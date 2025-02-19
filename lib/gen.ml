exception Unknown_var of string

let unknown_var x = raise (Unknown_var x)

let side x =
  match x with
  | "x" -> [ "left"; "right" ]
  | "y" -> [ "top"; "bottom" ]
  | "s" -> [ "inline-start" ]
  | "e" -> [ "inline-end" ]
  | "t" -> [ "top" ]
  | "r" -> [ "right" ]
  | "b" -> [ "bottom" ]
  | "l" -> [ "left" ]
  | _ -> invalid_arg ("invalid side: " ^ x)

let size x =
  match x with
  | "3xs" -> [ "16rem" ]
  | "2xs" -> [ "18rem" ]
  | "xs" -> [ "20rem" ]
  | "sm" -> [ "24rem" ]
  | "md" -> [ "28rem" ]
  | "lg" -> [ "32rem" ]
  | "xl" -> [ "36rem" ]
  | "2xl" -> [ "42rem" ]
  | "3xl" -> [ "48rem" ]
  | "4xl" -> [ "56rem" ]
  | "5xl" -> [ "64rem" ]
  | "6xl" -> [ "72rem" ]
  | "7xl" -> [ "80rem" ]
  | _ -> invalid_arg ("invalid size: " ^ x)

let px x = [ x ^ "px" ]

let len x =
  match x with
  | "0" -> [ "0px" ]
  | "px" -> [ "1px" ]
  | "0.5" -> [ "0.125rem" ]
  | "1" -> [ "0.25rem" ]
  | "1.5" -> [ "0.375rem" ]
  | "2" -> [ "0.5rem" ]
  | "2.5" -> [ "0.625rem" ]
  | "3" -> [ "0.75rem" ]
  | "3.5" -> [ "0.875rem" ]
  | "4" -> [ "1rem" ]
  | "5" -> [ "1.25rem" ]
  | "6" -> [ "1.5rem" ]
  | "7" -> [ "1.75rem" ]
  | "8" -> [ "2rem" ]
  | "9" -> [ "2.25rem" ]
  | "10" -> [ "2.5rem" ]
  | "11" -> [ "2.75rem" ]
  | "12" -> [ "3rem" ]
  | "14" -> [ "3.5rem" ]
  | "16" -> [ "4rem" ]
  | "20" -> [ "5rem" ]
  | "24" -> [ "6rem" ]
  | "28" -> [ "7rem" ]
  | "32" -> [ "8rem" ]
  | "36" -> [ "9rem" ]
  | "40" -> [ "10rem" ]
  | "44" -> [ "11rem" ]
  | "48" -> [ "12rem" ]
  | "52" -> [ "13rem" ]
  | "56" -> [ "14rem" ]
  | "60" -> [ "15rem" ]
  | "64" -> [ "16rem" ]
  | "72" -> [ "18rem" ]
  | "80" -> [ "20rem" ]
  | "96" -> [ "24rem" ]
  | "auto" -> [ "auto" ]
  | _ -> invalid_arg ("invalid len: " ^ x)

open Prelude

type t = {
  color : string -> string list;
  shadow : string -> (string list, string * string) Either.t;
  side : string -> string list;
  size : string -> string list;
  len : string -> string list;
}

let get map k = try String_map.find k map with _ -> unknown_var k

let make (theme : Theme.t) =
  let color var = [ get theme.color var ] in
  let shadow var =
    try Either.Left [ get theme.shadow var ]
    with Unknown_var _ -> Either.Right ("sx-shadow-color", get theme.color var)
  in
  { color; shadow; side; size; len }

let color t = t.color
let shadow t = t.shadow
let side t = t.side
let size t = t.size
let len t = t.len
let ( let* ) xs f = List.concat_map f xs

let ( let** ) either gen_property =
  match either with
  | Either.Left values -> List.concat_map gen_property values
  | Either.Right (var_name, var_value) ->
    [ String.concat "" [ "--"; var_name; ": "; var_value; ";" ] ]
