open struct
  module String_map = Map.Make (String)

  type 'a assoc = (string * 'a) list
end

open Prelude

module Utils = struct
  let float_to_css_string n =
    if Float.is_integer n then string_of_int (Float.to_int n)
    else
      let s = Printf.sprintf "%.6g" n in
      if String.starts_with ~prefix:"0." s then
        String.sub s 1 (String.length s - 1)
      else s
end

open struct
  type syn = Flx__Expr.t
end

type schema_error = { ctx : string; expected : string; actual : syn }

let pp_schema_error f err =
  Fmt.pf f "%s: expected %s;@,actual=%a" err.ctx err.expected Flx.pp err.actual

exception Schema_error of schema_error

let pp_schema_error f err =
  Fmt.pf f "%s: expected %s;@,actual=%a" err.ctx err.expected Flx.pp err.actual

exception Undefined_scope_var of string
exception Undefined_theme_opt of string

module Theme = struct
  type var_value = [ `flat of string list | `nested of string list assoc ]

  (* option -> var -> (flat: value list | nested: sub_var -> value list *)
  type t = [ `static of var_value String_map.t | `regex of Re.t ] String_map.t

  let is_regex_var ~var_name t =
    match String_map.find var_name t with
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
                           "theme: var=%S: sub var value must be a string or a \
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
                  "var=%S: theme value must be a string or a list of string" var
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
    let options_json = Yojson.Basic.from_file path in
    let options_assoc = Yojson.Basic.Util.to_assoc options_json in
    List.fold_left
      (fun acc (option, vars_json) ->
        let vars = read_option_vars vars_json in
        String_map.add option vars acc
      )
      String_map.empty options_assoc

  let regex_for_option option (t : t) =
    match String_map.find option t with
    | exception Not_found -> raise (Undefined_theme_opt option)
    | `regex regex -> regex
    | `static vars ->
      let var_names = String_map.to_seq vars |> Seq.map fst in
      Seq.map Re.str var_names |> List.of_seq |> Re.alt

  let lookup_flat_var ~option ~var_name (t : t) =
    let vars =
      match String_map.find option t with
      | exception Not_found -> raise (Undefined_theme_opt option)
      | `static vars -> vars
      | `regex _ ->
        Fmt.failwith
          "theme: var_name=%S: found regex when static var was expected"
          var_name
    in
    try
      let values = String_map.find var_name vars in
      match values with
      | `flat flat -> flat
      | `nested _ ->
        Fmt.invalid_arg
          "theme: lookup_flat_var: option=%S: var=%S: var is not flat" option
          var_name
    with Not_found -> Fmt.invalid_arg "theme: var_name not found: %S" var_name

  let lookup_nested_var ~option ~var_name ~sub_var_name (t : t) =
    let vars =
      match String_map.find option t with
      | exception Not_found -> Fmt.failwith "theme: option not found"
      | `static vars -> vars
      | `regex _ ->
        Fmt.failwith
          "theme: var_name=%S: found regex when static var was expected"
          var_name
    in
    try
      let values = String_map.find var_name vars in
      match values with
      | `nested nested -> (
        match List.assoc_opt sub_var_name nested with
        | Some sub_val -> sub_val
        | None ->
          Fmt.invalid_arg
            "theme: lookup_nested_var: option=%S: var=%S: sub_var=%S: sub var \
             is not defined"
            option var_name sub_var_name
      )
      | `flat _ ->
        Fmt.invalid_arg
          "theme: lookup_nested_var: option=%S: var=%S: var is not nested"
          option var_name
    with Not_found -> Fmt.invalid_arg "theme: var_name not found: %S" var_name
end

module Re_utils = struct
  let delim_str = " \t\n\"'|`"
  let delim = Re.set delim_str

  (* FIXME: matches with juxt trailing non-match: "columns-123" matches "columns-12" *)
  let delimited expr =
    let open Re in
    seq [ alt [ delim; start ]; expr; alt [ delim; stop ] ]
end

module Css_gen = struct
  let chars_that_need_escaping =
    Char_set.of_list [ ':'; '['; ']'; '('; ')'; '&'; '.'; '/' ]

  let string_of_scope scope =
    match scope with
    | `sm -> "sm"
    | `md -> "md"
    | `lg -> "lg"
    | `xl -> "xl"
    | `xl2 -> "2xl"

  let make_selector_name ~scope ~variants ~utility =
    let utility =
      let buf = Buffer.create (String.length utility + 4) in
      String.iter
        (fun x ->
          let is_delim = String.contains Re_utils.delim_str x in
          if not is_delim then (
            if Char_set.mem x chars_that_need_escaping then
              Buffer.add_char buf '\\';
            Buffer.add_char buf x
          )
        )
        utility;
      Buffer.contents buf
    in
    match (scope, variants) with
    | None, [] -> utility
    | Some scope, [] -> string_of_scope scope ^ "\\:" ^ utility
    | _ ->
      let selector_prefix =
        Option.fold scope ~none:variants ~some:(fun scope ->
            string_of_scope scope :: variants
        )
      in
      let name = String.concat "\\:" selector_prefix ^ "\\:" ^ utility in
      name ^ ":" ^ String.concat ":" variants
end

type rule = { selector : string; decl_block : string list }

let pp_rule f rule =
  Fmt.pf f "@[<v2>%s {@,%a@]@,}" rule.selector
    (Fmt.list ~sep:Fmt.semi Fmt.string)
    rule.decl_block

module Schema_eval = struct
  let expected ctx expected actual =
    raise (Schema_error { ctx; expected; actual })

  type scope_var =
    | Theme_var of { slot : int; option : string }
    | Inline_var of { slot : int; re : Re.t }

  let pp_scope_var f = function
    | Theme_var x -> Fmt.pf f "(theme_var %d %s)" x.slot x.option
    | Inline_var x -> Fmt.pf f "(theme_var %d %a)" x.slot Re.pp x.re

  type scope = {
    mutable vars : scope_var String_map.t;
    mutable var_count : int;
  }

  let ( let* ) decls gen_decl = List.concat_map gen_decl decls

  let rec cartesian_map f l =
    match l with
    | [] -> []
    | [ x ] -> [ f x ]
    | x :: l' ->
      let* x' = f x in
      let* rest = cartesian_map f l' in
      [ x' :: rest ]

  let add_scope_var ~name var scope =
    scope.vars <- String_map.add name var scope.vars;
    scope.var_count <- scope.var_count + 1

  let new_scope () = { vars = String_map.empty; var_count = 0 }

  let get_scope_var ~name scope =
    try String_map.find name scope.vars
    with Not_found -> raise (Undefined_scope_var name)

  let get_matched_var_value ~slot g =
    try Re.Group.get g slot
    with Not_found ->
      Fmt.invalid_arg
        "get_matched_var_value: slot %d not found in %S, nb_groups=%d" slot
        (Re.Group.get g 0) (Re.Group.nb_groups g)

  let resolve_decl_seg ~theme ~scope (syn : syn) =
    match syn with
    | `str str_val -> fun ~g:_ -> [ str_val ]
    | `id scope_var_name -> (
      let scope_var = get_scope_var ~name:scope_var_name scope in
      fun ~g ->
        match scope_var with
        | Theme_var v ->
          let matched_var_value = get_matched_var_value ~slot:v.slot g in
          Theme.lookup_flat_var ~option:v.option ~var_name:matched_var_value
            theme
        | Inline_var v ->
          let matched_var_value = Re.Group.get g v.slot in
          [ matched_var_value ]
    )
    | `dot [ `id scope_var_name; `id scope_sub_var_name ] -> (
      let scope_var = get_scope_var ~name:scope_var_name scope in
      fun ~g ->
        match scope_var with
        | Theme_var v ->
          let matched_var_value = get_matched_var_value ~slot:v.slot g in
          Theme.lookup_nested_var ~option:v.option ~var_name:matched_var_value
            ~sub_var_name:scope_sub_var_name theme
        | Inline_var v ->
          let matched_var_value = Re.Group.get g v.slot in
          [ matched_var_value ]
    )
    | _ -> expected "decl_seg" "string, id or variable" syn

  let resolve_decl_tpl ~theme ~scope decl_name_seq decl_value_seq =
    let parts = decl_name_seq @ (`str ": " :: decl_value_seq) in
    let decl_seg_delayed = List.map (resolve_decl_seg ~theme ~scope) parts in
    fun ~g ->
      decl_seg_delayed
      |> cartesian_map (fun delayed -> delayed ~g)
      |> List.map (String.concat "")

  (* Eval CSS declarations by expanding all variable combinations. *)
  let eval_decl ~theme ~scope (syn : syn) =
    match syn with
    | `infix (":", `template decl_name_seq, `template decl_value_seq) ->
      resolve_decl_tpl ~theme ~scope decl_name_seq decl_value_seq
    | `infix (":", `template decl_name_seq, decl_value_syn) ->
      resolve_decl_tpl ~theme ~scope decl_name_seq [ decl_value_syn ]
    | `infix (":", decl_name_syn, `template decl_value_seq) ->
      resolve_decl_tpl ~theme ~scope [ decl_name_syn ] decl_value_seq
    | `infix (":", decl_name_syn, decl_value_syn) ->
      resolve_decl_tpl ~theme ~scope [ decl_name_syn ] [ decl_value_syn ]
    | _ -> expected "decl" "_ : _" syn

  let rec eval_pat_var_value ~theme (syn : syn) =
    match syn with
    | `str str -> Re.str str
    | `char c -> Re.char c
    | `brackets (`infix ("-", `char c1, `char c2)) -> Re.rg c1 c2
    | `id theme_option -> Theme.regex_for_option theme_option theme
    | `postfix ("?", syn') -> Re.opt (eval_pat_var_value ~theme syn')
    | `pipe items ->
      let items_re = List.map (eval_pat_var_value ~theme) items in
      Re.longest (Re.alt items_re)
    | `parens syn' -> eval_pat_var_value ~theme syn'
    | `seq seq -> Re.seq (List.map (eval_pat_var_value ~theme) seq)
    | _ ->
      Fmt.pr "INPUT:@.%a@." Flx.pp syn;
      failwith "eval_pat_var_value: expected `\"...\"` or `_ | _`"

  let eval_pat_seg ~theme scope (syn : syn) =
    match syn with
    | `str str -> Re.str str
    | `char c -> Re.char c
    | `parens (`infix ("=", `id var_name, var_value_syn)) ->
      let var_value_re = eval_pat_var_value ~theme var_value_syn in
      (* WIP: Handle regex var, currently is saved as theme var and fails on lookup. *)
      let scope_var =
        match var_value_syn with
        | `id option when Theme.is_regex_var ~var_name:option theme ->
          Inline_var { slot = scope.var_count + 1; re = var_value_re }
        | `id option -> Theme_var { option; slot = scope.var_count + 1 }
        | _ -> Inline_var { slot = scope.var_count + 1; re = var_value_re }
      in
      add_scope_var ~name:var_name scope_var scope;
      Re.group ~name:var_name var_value_re
    | _ ->
      Fmt.pr "INPUT:@.%a@." Flx.pp syn;
      failwith "eval_pat_seg: expected `\"...\"` or `_ | _`"

  let eval_pat ~theme scope (syn : syn) =
    match syn with
    | `seq segs -> Re.seq (List.map (eval_pat_seg ~theme scope) segs)
    | seg -> Re.seq [ eval_pat_seg ~theme scope seg ]

  let eval_case ~theme (syn : syn) =
    let scope = new_scope () in
    let pat, decl_syn_list =
      match syn with
      | `infix ("=>", pat, `braces (`comma decl_syn_list)) ->
        (pat, decl_syn_list)
      | `infix ("=>", pat, `braces decl_syn) -> (pat, [ decl_syn ])
      | _ -> failwith "expected `_ => { _ }` or `_ => { _, _ }"
    in
    let case_re = Re_utils.delimited (eval_pat ~theme scope pat) in
    let decl_list_delayed = List.map (eval_decl ~theme ~scope) decl_syn_list in
    let resolve_block g =
      let selector =
        Css_gen.make_selector_name ~scope:None ~variants:[]
          ~utility:(Re.Group.get g 0)
      in
      let decl_block = List.concat_map (fun run -> run ~g) decl_list_delayed in
      { selector; decl_block }
    in
    (case_re, resolve_block)

  let eval_group ~theme (syn : syn) =
    match syn with
    | `infix ("=", `id _group_name, `braces (`comma cases)) ->
      List.map (eval_case ~theme) cases
    | `infix ("=", `id _group_name, `braces case) -> [ eval_case ~theme case ]
    | _ ->
      Fmt.pr "INPUT:@.%a@." Flx.pp syn;
      failwith "expected `group_name = { _, _ }`"

  let eval ~theme (syn : syn) =
    match syn with
    | `semi groups -> List.concat_map (eval_group ~theme) groups
    | _ -> eval_group ~theme syn
end

let read_theme path = Theme.read path

let read_schema ~theme path =
  let syn =
    In_channel.with_open_text path (fun chan ->
        Flx.parse (Flx.Lex.read_channel chan)
    )
  in
  let cases = Schema_eval.eval ~theme syn in
  Re_match.compile cases

type theme = Theme.t
type schema = rule Re_match.t

let process input schema = Re_match.all schema input
