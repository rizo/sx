open Prelude

exception Undefined_scope_var of string
exception Undefined_config_opt of string

type var_value = [ `flat of string list | `nested of string list assoc ]

type t = {
  (* option -> var -> (flat: value list | nested: sub_var -> value list) *)
  options : [ `static of var_value String_map.t | `regex of Re.t ] String_map.t;
  media : string String_map.t;
  spacing : string;
}

let is_regex_var ~var_name t =
  match String_map.find var_name t.options with
  | `regex _ -> true
  | `static _ -> false
  | exception Not_found -> false

let dump f t =
  String_map.iter
    (fun option vars ->
      match vars with
      | `regex regex -> Fmt.pf f "%S: %a@." option Re.pp regex
      | `static vars ->
        Fmt.pf f "%S:@." option;
        String_map.iter (fun var _values -> Fmt.pf f "  - %S@." var) vars
    )
    t

let read_option_vars json =
  match json with
  | `Assoc assoc ->
    let vars =
      List.fold_left
        (fun acc (var, var_value_json) ->
          let var_values =
            match var_value_json with
            | `String value -> `flat [ value ]
            | `Assoc sub_vars ->
              `nested
                (List.map
                   (function
                     | sub_var, `String value -> (sub_var, [ value ])
                     | sub_var, `List values_json ->
                       ( sub_var,
                         List.map Yojson.Basic.Util.to_string values_json
                       )
                     | _ ->
                       Fmt.epr "INPUT:@.%a@." Yojson.Basic.pp var_value_json;
                       Fmt.invalid_arg
                         "config: var=%S: sub var value must be a string or a \
                          list of string"
                         var
                     )
                   sub_vars
                )
            | `List values_json ->
              `flat (List.map Yojson.Basic.Util.to_string values_json)
            | _ ->
              Fmt.epr "INPUT:@.%a@." Yojson.Basic.pp var_value_json;
              Fmt.invalid_arg
                "var=%S: config value must be a string or a list of string" var
          in
          String_map.add var var_values acc
        )
        String_map.empty assoc
    in
    `static vars
  | `List id_vars ->
    let vars =
      List.fold_left
        (fun acc id_var_json ->
          let id_var = Yojson.Basic.Util.to_string id_var_json in
          String_map.add id_var (`flat [ id_var ]) acc
        )
        String_map.empty id_vars
    in
    `static vars
  | `String regex -> `regex (Re.Posix.re ~opts:[] regex)
  | _ ->
    Fmt.epr "INPUT:@.%a@." Yojson.Basic.pp json;
    invalid_arg "option value must be an object, a list or a regex string"

let read path =
  let json = Yojson.Basic.from_file path in
  let options_json = Yojson.Basic.Util.member "options" json in
  let options_assoc = Yojson.Basic.Util.to_assoc options_json in
  let options =
    List.fold_left
      (fun acc (option, vars_json) ->
        let vars = read_option_vars vars_json in
        String_map.add option vars acc
      )
      String_map.empty options_assoc
  in
  let media_json = Yojson.Basic.Util.member "media" json in
  let media_assoc = Yojson.Basic.Util.to_assoc media_json in
  let media =
    List.fold_left
      (fun acc (id, value_json) ->
        let value = Yojson.Basic.Util.to_string value_json in
        String_map.add id value acc
      )
      String_map.empty media_assoc
  in
  let spacing_json = Yojson.Basic.Util.member "spacing" json in
  let spacing = Yojson.Basic.Util.to_string spacing_json in
  { options; media; spacing }

let regex_for_option option (t : t) =
  match String_map.find option t.options with
  | exception Not_found -> raise (Undefined_config_opt option)
  | `regex regex -> regex
  | `static vars ->
    let var_names = String_map.to_seq vars |> Seq.map fst in
    Seq.map Re.str var_names |> List.of_seq |> Re.alt

let regex_for_media t =
  let ids = String_map.to_seq t.media |> Seq.map fst in
  Seq.map Re.str ids |> List.of_seq |> Re.alt

let lookup_media t id =
  try String_map.find id t.media
  with Not_found -> Fmt.invalid_arg "config: no such media id: %S" id

let lookup_flat_var ~option ~var_name (t : t) =
  let vars =
    match String_map.find option t.options with
    | exception Not_found -> raise (Undefined_config_opt option)
    | `static vars -> vars
    | `regex _ ->
      Fmt.failwith
        "config: var_name=%S: found regex when static var was expected" var_name
  in
  try
    let values = String_map.find var_name vars in
    match values with
    | `flat flat -> flat
    | `nested _ ->
      Fmt.invalid_arg
        "config: lookup_flat_var: option=%S: var=%S: var is not flat" option
        var_name
  with Not_found -> Fmt.invalid_arg "config: var_name not found: %S" var_name

let lookup_nested_var ~option ~var_name ~sub_var_name (t : t) =
  let vars =
    match String_map.find option t.options with
    | exception Not_found -> Fmt.failwith "config: option not found"
    | `static vars -> vars
    | `regex _ ->
      Fmt.failwith
        "config: var_name=%S: found regex when static var was expected" var_name
  in
  try
    let values = String_map.find var_name vars in
    match values with
    | `nested nested -> (
      match List.assoc_opt sub_var_name nested with
      | Some sub_val -> sub_val
      | None ->
        Fmt.invalid_arg
          "config: lookup_nested_var: option=%S: var=%S: sub_var=%S: sub var \
           is not defined"
          option var_name sub_var_name
    )
    | `flat _ ->
      Fmt.invalid_arg
        "config: lookup_nested_var: option=%S: var=%S: var is not nested" option
        var_name
  with Not_found -> Fmt.invalid_arg "config: var_name not found: %S" var_name
