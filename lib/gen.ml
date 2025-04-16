open Prelude

let float_to_css_string n =
  if Float.is_integer n then string_of_int (Float.to_int n)
  else
    let s = Printf.sprintf "%.6g" n in
    if String.starts_with ~prefix:"0." s then
      String.sub s 1 (String.length s - 1)
    else s

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

let dir x =
  match x with
  | "x" -> Either.Left [ "column" ]
  | "y" -> Either.Left [ "row" ]
  | _ -> invalid_arg ("invalid dir: " ^ x)

let px x = Either.Left [ (if String.equal x "0" then "0" else x ^ "px") ]

let len (spacing, unit) key =
  match key with
  | "0" -> Either.Left [ "0" ]
  | "px" -> Either.Left [ "1px" ]
  | "auto" -> Either.Left [ "auto" ]
  | "full" -> Either.Left [ "100%" ]
  | n_str ->
    let n = try float_of_string n_str with _ -> unknown_key key in
    let m = spacing *. n in
    let m_str = float_to_css_string m in
    Either.Left [ m_str ^ unit ]

let width key =
  match key with
  | "screen" -> Either.Left [ "100vw" ]
  | "svw" -> Either.Left [ "100svw" ]
  | "lvw" -> Either.Left [ "100lvw" ]
  | "dvw" -> Either.Left [ "100dvw" ]
  | "min" -> Either.Left [ "min-content" ]
  | "max" -> Either.Left [ "max-content" ]
  | "fit" -> Either.Left [ "fit-content" ]
  | _ -> unknown_key key

let height key =
  match key with
  | "screen" -> Either.Left [ "100vh" ]
  | "svh" -> Either.Left [ "100svh" ]
  | "lvh" -> Either.Left [ "100lvh" ]
  | "dvh" -> Either.Left [ "100dvh" ]
  | "min" -> Either.Left [ "min-content" ]
  | "max" -> Either.Left [ "max-content" ]
  | "fit" -> Either.Left [ "fit-content" ]
  | _ -> unknown_key key

let pct key =
  let n = int_of_string key in
  let pct = float n /. 100.0 in
  let pct_str = float_to_css_string pct in
  Either.Left [ pct_str ]

let content key =
  match key with
  | "auto" -> Either.Left [ "auto" ]
  | "normal" -> Either.Left [ "normal" ]
  | "start" -> Either.Left [ "flex-start" ]
  | "end" -> Either.Left [ "flex-end" ]
  | "center" -> Either.Left [ "center" ]
  | "between" -> Either.Left [ "space-between" ]
  | "around" -> Either.Left [ "space-around" ]
  | "evenly" -> Either.Left [ "space-evenly" ]
  | "stretch" -> Either.Left [ "stretch" ]
  | "baseline" -> Either.Left [ "baseline" ]
  | _ -> unknown_key key

let frac n_c m_c =
  let n = float (int_of_string n_c) in
  let m = float (int_of_string m_c) in
  let pct = n /. m *. 100. in
  let pct_str = float_to_css_string pct in
  Either.Left [ pct_str ^ "%" ]

let text (theme : Theme.t) key =
  try
    let size = String_map.find key theme.text_size in
    let line_height = String_map.find key theme.text_line_height in
    Either.Left [ (size, line_height) ]
  with Not_found -> unknown_key key

let get map key : _ Either.t =
  Either.Left [ (try String_map.find key map with _ -> unknown_key key) ]

let lookup map key = try String_map.find key map with _ -> unknown_key key

let ( or ) get_1 get_2 key : _ Either.t =
  try get_1 key with Unknown_key _ -> get_2 key

let get_var name map key =
  Either.Right (name, try String_map.find key map with _ -> unknown_key key)

let var name value = String.concat "" [ "--"; name; ": "; value; ";" ]
let decl prop value = String.concat "" [ prop; ":"; value ]

let ( let* ) either gen_property =
  match either with
  | Either.Left props -> List.concat_map gen_property props
  | Either.Right (var_name, var_value) ->
    [ String.concat "" [ "--"; var_name; ": "; var_value; ";" ] ]
