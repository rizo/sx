open Prelude

exception Unknown_key of string

let unknown_key x = raise_notrace (Unknown_key x)

let side x =
  match x with
  | "x" -> Either.Left [ "left"; "right" ]
  | "y" -> Either.Left [ "top"; "bottom" ]
  | "s" -> Either.Left [ "inline-start" ]
  | "e" -> Either.Left [ "inline-end" ]
  | "t" -> Either.Left [ "top" ]
  | "r" -> Either.Left [ "right" ]
  | "b" -> Either.Left [ "bottom" ]
  | "l" -> Either.Left [ "left" ]
  | _ -> invalid_arg ("invalid side: " ^ x)

let px x = Either.Left [ x ^ "px" ]

let len (spacing, unit) len_input =
  match len_input with
  | "0" -> Either.Left [ "0px" ]
  | "px" -> Either.Left [ "1px" ]
  | "auto" -> Either.Left [ "auto" ]
  | "full" -> Either.Left [ "100%" ]
  | n_str ->
    let n = float_of_string n_str in
    let m = spacing *. n in
    let m_str =
      if Float.is_integer m then string_of_int (Float.to_int m)
      else string_of_float m
    in
    Either.Left [ m_str ^ unit ]

let frac n_c m_c =
  let n = float (Char.code n_c - 48) in
  let m = float (Char.code m_c - 48) in
  let pct = n /. m *. 100. in
  let pct_str =
    if Float.is_integer pct then string_of_int (Float.to_int pct)
    else string_of_float pct
  in
  Either.Left [ pct_str ^ "%" ]

let text (theme : Theme.t) key =
  try
    let size = String_map.find key theme.text_size in
    let line_height = String_map.find key theme.text_line_height in
    Either.Left [ (size, line_height) ]
  with Not_found -> unknown_key key

let get map key : _ Either.t =
  Either.Left [ (try String_map.find key map with _ -> unknown_key key) ]

let ( or ) get_1 get_2 key : _ Either.t =
  try get_1 key with Unknown_key _ -> get_2 key

let var name map key =
  Either.Right (name, try String_map.find key map with _ -> unknown_key key)

let ( let* ) either gen_property =
  match either with
  | Either.Left values -> List.concat_map gen_property values
  | Either.Right (var_name, var_value) ->
    [ String.concat "" [ "--"; var_name; ": "; var_value; ";" ] ]
