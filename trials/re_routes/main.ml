let print ?(break : unit Fmt.t = Format.pp_print_newline) fmt =
  Format.kfprintf (fun f -> break f ()) Format.std_formatter fmt

module String_map = Map.Make (String)

module Theme = struct
  (* option -> var -> value list *)
  type t = string list String_map.t String_map.t

  let dump f t =
    String_map.iter
      (fun option vars ->
        Fmt.pf f "%S:@." option;
        String_map.iter (fun var values -> Fmt.pf f "  - %S@." var) vars)
      t

  let read_option_vars json =
    match json with
    | `Assoc assoc ->
      List.fold_left
        (fun acc (var, var_value_json) ->
          let var_values =
            match var_value_json with
            | `String value -> [ value ]
            | `List values_json ->
              List.map Yojson.Basic.Util.to_string values_json
            | _ ->
              Fmt.epr "INPUT:@.%a@." Yojson.Basic.pp var_value_json;
              invalid_arg "theme values must be string or list of string"
          in
          String_map.add var var_values acc)
        String_map.empty assoc
    | `List id_vars ->
      List.fold_left
        (fun acc id_var_json ->
          let id_var = Yojson.Basic.Util.to_string id_var_json in
          String_map.add id_var [ id_var ] acc)
        String_map.empty id_vars
    | _ ->
      Fmt.epr "INPUT:@.%a@." Yojson.Basic.pp json;
      invalid_arg "vars must be an object or a list"

  let read path =
    let options_json = Yojson.Basic.from_file path in
    let options_assoc = Yojson.Basic.Util.to_assoc options_json in
    List.fold_left
      (fun acc (option, vars_json) ->
        let vars = read_option_vars vars_json in
        String_map.add option vars acc)
      String_map.empty options_assoc

  let var_names_for_option option t =
    try
      let vars = String_map.find option t in
      String_map.to_seq vars |> Seq.map fst
    with Not_found -> Fmt.failwith "theme: option not found: %S" option

  let lookup_var ~option var_name t =
    let vars = String_map.find option t in
    try String_map.find var_name vars
    with Not_found -> Fmt.invalid_arg "theme: var_name not found: %S" var_name
end

module Css_gen = struct
  let prop name value = String.concat ": " [ name; value ]
  let block items = String.concat ";\n" items
end

module Re_utils = struct
  let delim = Re.set " \t\n\"'|"

  let delimited expr =
    let open Re in
    seq [ alt [ bos; delim ]; expr ]
end

module Schema_eval = struct
  open struct
    type syn = Shaper.Shape.t
  end

  type scope_var =
    | Theme_var of { slot : int; option : string }
    | Inline_var of { slot : int; re : Re.t }

  type scope = {
    mutable vars : scope_var String_map.t;
    mutable var_count : int;
  }

  let ( let* ) props gen_prop = List.concat_map gen_prop props

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
  let get_scope_var ~name scope = String_map.find name scope.vars

  let expected name msg syn =
    Fmt.pr "INPUT: %a@." Shaper.Shape.pp_sexp syn;
    Fmt.failwith "%s: expected `%s`" name msg

  let theme_var_names_to_re var_names =
    Seq.map Re.str var_names |> List.of_seq |> Re.alt

  let get_matched_var_value ~slot g =
    try Re.Group.get g slot
    with Not_found ->
      Fmt.invalid_arg
        "get_matched_var_value: slot %d not found in %S, nb_groups=%d" slot
        (Re.Group.get g 0) (Re.Group.nb_groups g)

  let rec resolve_prop_seg ~theme ~scope ~g (syn : syn) =
    match syn with
    | `str str_val -> [ str_val ]
    | `id scope_var_name -> (
      let scope_var = get_scope_var ~name:scope_var_name scope in
      match scope_var with
      | Theme_var v ->
        let matched_var_value = get_matched_var_value ~slot:v.slot g in
        Theme.lookup_var ~option:v.option matched_var_value theme
      | Inline_var v ->
        let matched_var_value = Re.Group.get g v.slot in
        [ matched_var_value ])
    | _ -> expected "property value" "string or id" syn

  let resolve_prop_full ~theme ~scope ~g prop_name_seq prop_value_seq =
    let parts = prop_name_seq @ (`str ": " :: prop_value_seq) in
    let parts = cartesian_map (resolve_prop_seg ~theme ~scope ~g) parts in
    List.map (String.concat "") parts

  (* Eval CSS properties/declarations by expanding all variable combinations. *)
  let rec eval_prop ~theme ~scope ~g (syn : syn) =
    match syn with
    | `infix (":", `seq prop_name_seq, `seq prop_value_seq) ->
      resolve_prop_full ~theme ~scope ~g prop_name_seq prop_value_seq
    | `infix (":", `seq prop_name_seq, prop_value_syn) ->
      resolve_prop_full ~theme ~scope ~g prop_name_seq [ prop_value_syn ]
    | `infix (":", prop_name_syn, `seq prop_value_seq) ->
      resolve_prop_full ~theme ~scope ~g [ prop_name_syn ] prop_value_seq
    | `infix (":", prop_name_syn, prop_value_syn) ->
      resolve_prop_full ~theme ~scope ~g [ prop_name_syn ] [ prop_value_syn ]
    | _ -> expected "decl" "_ : _" syn

  let rec eval_pat_var_value ~theme (syn : syn) =
    match syn with
    | `str str -> Re.str str
    | `char c -> Re.char c
    | `brackets (`infix ("-", `char c1, `char c2)) -> Re.rg c1 c2
    | `id theme_option ->
      let var_names = Theme.var_names_for_option theme_option theme in
      theme_var_names_to_re var_names
    | `postfix ("?", syn') -> Re.opt (eval_pat_var_value ~theme syn')
    | `infix ("|", left_syn, right_syn) ->
      let left = eval_pat_var_value ~theme left_syn in
      let right = eval_pat_var_value ~theme right_syn in
      Re.alt [ left; right ]
    | `parens syn' -> eval_pat_var_value ~theme syn'
    | `seq seq -> Re.seq (List.map (eval_pat_var_value ~theme) seq)
    | _ ->
      Fmt.pr "INPUT:@.%a@." Shaper.Shape.pp_sexp syn;
      failwith "eval_pat_var_value: expected `\"...\"` or `_ | _`"

  let eval_pat_seg ~theme scope (syn : syn) =
    match syn with
    | `str str -> Re.str str
    | `parens (`infix ("=", `id var_name, var_value_syn)) ->
      let var_value_re = eval_pat_var_value ~theme var_value_syn in
      let scope_var =
        match var_value_syn with
        | `id option -> Theme_var { option; slot = scope.var_count + 1 }
        | _ -> Inline_var { slot = scope.var_count + 1; re = var_value_re }
      in
      add_scope_var ~name:var_name scope_var scope;
      Re.group ~name:var_name var_value_re
    | _ ->
      Fmt.pr "INPUT:@.%a@." Shaper.Shape.pp syn;
      failwith "eval_pat_seg: expected `\"...\"` or `_ | _`"

  let eval_pat ~theme scope (syn : syn) =
    match syn with
    | `seq segs -> Re.seq (List.map (eval_pat_seg ~theme scope) segs)
    | seg -> Re.seq [ eval_pat_seg ~theme scope seg ]

  let eval_case ~theme (syn : syn) =
    let scope = new_scope () in
    match syn with
    | `infix ("=>", pat, `braces (`comma decl_block_syn)) ->
      let case_re = Re_utils.delimited (eval_pat ~theme scope pat) in
      let resolve_block g =
        let prop_list = List.map (eval_prop ~theme ~scope ~g) decl_block_syn in
        Css_gen.block (List.concat prop_list)
      in
      (case_re, resolve_block)
    | `infix ("=>", pat, `braces decl_syn) ->
      let case_re = Re_utils.delimited (eval_pat ~theme scope pat) in
      let resolve_block g =
        let prop_list = eval_prop ~theme ~scope ~g decl_syn in
        Css_gen.block prop_list
      in
      (case_re, resolve_block)
    | _ -> failwith "expected `_ => { _ }` or _ => { _, _ }"

  let eval_group ~theme (syn : syn) =
    match syn with
    | `infix ("=", `id _group_name, `braces (`comma cases)) ->
      List.map (eval_case ~theme) cases
    | `infix ("=", `id _group_name, `braces case) -> [ eval_case ~theme case ]
    | _ ->
      Fmt.pr "INPUT:@.%a@." Shaper.Shape.pp syn;
      failwith "expected `group_name = { _, _ }`"

  let eval ~theme (syn : syn) =
    match syn with
    | `semi groups ->
      let groups = List.concat_map (eval_group ~theme) groups in
      groups
    | _ -> failwith "expected `_; _`"
end

module Theme' = struct
  open Re

  let len = rep1 digit
  let size = alt [ str "xs"; str "sm"; str "md"; str "lg"; str "xl" ]
  let side = alt [ str "t"; str "b"; str "l"; str "r"; str "x"; str "y" ]
end

module Rules = struct
  open Re

  let w_full_pat = seq [ str "w-full" ]
  let w_full_css g = ()
  let w_len = seq [ str "w-"; group Theme'.len ]
  let w_frac = seq [ str "w-"; group Theme'.len; str "/"; group Theme'.len ]

  let m_side_len =
    seq
      [
        group (opt (str "-"));
        str "m";
        group Theme'.side;
        str "-";
        group Theme'.len;
      ]

  let m_len = seq [ group (opt (str "-")); str "m-"; group Theme'.len ]
  let text_size = seq [ str "text-"; group Theme'.size ]
end

let debug_action name =
 fun g ->
  Fmt.str "%s(%d): %s" name (Re.Group.nb_groups g)
    (Re.Group.all g |> Array.to_list |> String.concat ", ")

let cases =
  let case rule act = (Re_utils.delimited rule, act) in
  [
    case Rules.w_full_pat (debug_action "w_full");
    case Rules.w_len (debug_action "w_len");
    case Rules.w_frac (debug_action "w_frac");
    case Rules.m_side_len (debug_action "m_side_len");
    case Rules.m_len (debug_action "m_len");
    case Rules.text_size (debug_action "text_size");
  ]
  |> Re_match.compile

let read_schema ~theme path =
  let syn = In_channel.with_open_text path Shaper.parse_channel in
  let cases = Schema_eval.eval ~theme syn in
  Re_match.compile cases

let () =
  Printexc.record_backtrace true;
  print_newline ();
  let theme = Theme.read "./theme.json" in
  Fmt.pr "THEME:@.a%a@." Theme.dump theme;
  let schema_match = read_schema ~theme "./schema.shape" in
  (* print "%a" Re.pp_re (Re_match.re cases); *)
  while true do
    print ~break:Fmt.flush "> ";
    match In_channel.input_line stdin with
    | None ->
      print_newline ();
      exit 0
    | Some line -> Seq.iter print_endline (Re_match.all schema_match line)
  done
