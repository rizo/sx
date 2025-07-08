type flx = Flx__Expr.t

open Prelude

type schema_error = { ctx : string; expected : string; actual : flx }

let pp_schema_error f err =
  Fmt.pf f "%s: expected %s;@,actual=%a" err.ctx err.expected Flx.pp err.actual

exception Schema_error of schema_error

module Re_utils = struct
  (* TODO: Move into config *)
  let pseudo_class_variant =
    let open Re in
    alt
      [
        str "hover";
        str "focus";
        str "active";
        str "focus-within";
        str "focus-visible";
        str "motion-safe";
        str "disabled";
        str "visited";
        str "checked";
        str "first";
        str "last";
        str "odd";
        str "even";
      ]

  let delim_str = " \t\n\"'`|"
  let delim = Re.set delim_str

  let delimited ~breakpoint expr =
    let open Re in
    seq
      [
        alt [ delim; start ];
        group @@ opt (seq [ breakpoint; char ':' ]);
        group @@ rep (seq [ pseudo_class_variant; char ':' ]);
        group expr;
        alt [ delim; stop ];
      ]
end

type breakpoint = { name : string; size : string }

type rule = {
  breakpoint : breakpoint option;
  selector : string;
  decl_block : string list;
}

module Css_gen = struct
  (* { media => (media size, { sel => decl list }) } *)
  module Media_map = Map.Make (struct
    type t = breakpoint option

    let compare t1 t2 =
      Option.compare String.compare
        (Option.map (fun b -> b.name) t1)
        (Option.map (fun b -> b.name) t2)
  end)

  type css = string list String_map.t Media_map.t

  let is_empty = Media_map.is_empty

  let pp_rule f (sel, rules) =
    Fmt.pf f "@[<v2>.%s {@,%a;@]@,}" sel
      (Fmt.list ~sep:Fmt.semi Fmt.string)
      rules

  let pp_media f (breakpoint_opt, rule) =
    match breakpoint_opt with
    | None ->
      Fmt.pf f "@[<v>%a@]" (Fmt.iter_bindings String_map.iter pp_rule) rule
    | Some breakpoint ->
      Fmt.pf f "@[<v2>@media (%s) {@,%a@]@.}" breakpoint.size
        (Fmt.iter_bindings String_map.iter pp_rule)
        rule

  let pp_css f (css : css) =
    Format.fprintf f "%a" (Fmt.iter_bindings Media_map.iter pp_media) css

  let css_of_rule_seq seq : css =
    Seq.fold_left
      (fun acc (rule : rule) ->
        Media_map.update rule.breakpoint
          (function
            | None -> Some (String_map.singleton rule.selector rule.decl_block)
            | Some old -> Some (String_map.add rule.selector rule.decl_block old)
            )
          acc
      )
      Media_map.empty seq

  let chars_that_need_escaping =
    Char_set.of_list [ ':'; '['; ']'; '('; ')'; '&'; '.'; '/' ]

  let make_selector_name ~breakpoint ~variants ~utility =
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
    match (breakpoint, variants) with
    | None, [] -> utility
    | Some { name; _ }, [] -> name ^ "\\:" ^ utility
    | _ ->
      let selector_prefix =
        match breakpoint with
        | None -> variants
        | Some { name; _ } -> name :: variants
      in
      let buf = Buffer.create 16 in
      List.iter
        (fun p ->
          if String.length p > 0 then (
            Buffer.add_string buf p;
            Buffer.add_string buf "\\:"
          )
        )
        selector_prefix;
      Buffer.add_string buf utility;
      List.iter
        (fun p ->
          if String.length p > 0 then (
            Buffer.add_string buf ":";
            Buffer.add_string buf p
          )
        )
        variants;
      Buffer.contents buf
end

module Schema_eval = struct
  let expected ctx expected actual =
    raise (Schema_error { ctx; expected; actual })

  type scope_var =
    | Config_var of { slot : int; option : string }
    | Inline_var of { slot : int; re : Re.t }

  type scope = {
    mutable vars : scope_var String_map.t;
    mutable var_count : int;
  }

  let add_scope_var ~name var scope =
    scope.vars <- String_map.add name var scope.vars;
    scope.var_count <- scope.var_count + 1

  (* We start [var_count] with 3 because: 0=responsive 1=pseudo_variant 2=utility. *)
  let new_scope () = { vars = String_map.empty; var_count = 3 }

  let get_scope_var ~name scope =
    try String_map.find name scope.vars
    with Not_found -> raise (Config.Undefined_scope_var name)

  let get_matched_var_value ~slot g =
    try Re.Group.get g slot
    with Not_found ->
      Fmt.invalid_arg
        "get_matched_var_value: slot %d not found in %S, nb_groups=%d" slot
        (Re.Group.get g 0) (Re.Group.nb_groups g)

  let resolve_decl_seg ~config ~scope (syn : flx) =
    match syn with
    | `str str_val -> fun ~g:_ -> [ str_val ]
    | `id scope_var_name -> (
      let scope_var = get_scope_var ~name:scope_var_name scope in
      fun ~g ->
        match scope_var with
        | Config_var v ->
          let matched_var_value = get_matched_var_value ~slot:v.slot g in
          Config.lookup_flat_var ~option:v.option ~var_name:matched_var_value
            config
        | Inline_var v ->
          let matched_var_value = Re.Group.get g v.slot in
          [ matched_var_value ]
    )
    | `dot [ `id scope_var_name; `id scope_sub_var_name ] -> (
      let scope_var = get_scope_var ~name:scope_var_name scope in
      fun ~g ->
        match scope_var with
        | Config_var v ->
          let matched_var_value = get_matched_var_value ~slot:v.slot g in
          Config.lookup_nested_var ~option:v.option ~var_name:matched_var_value
            ~sub_var_name:scope_sub_var_name config
        | Inline_var v ->
          let matched_var_value = Re.Group.get g v.slot in
          [ matched_var_value ]
    )
    | _ -> expected "decl_seg" "string, id or variable" syn

  let resolve_decl_tpl ~config ~scope decl_name_seq decl_value_seq =
    let parts = decl_name_seq @ (`str ": " :: decl_value_seq) in
    let decl_seg_delayed = List.map (resolve_decl_seg ~config ~scope) parts in
    fun ~g ->
      decl_seg_delayed
      |> cartesian_map (fun delayed -> delayed ~g)
      |> List.map (String.concat "")

  (* Eval CSS declarations by expanding all variable combinations. *)
  let eval_decl ~config ~scope (syn : flx) =
    match syn with
    | `infix (":", `template decl_name_seq, `template decl_value_seq) ->
      resolve_decl_tpl ~config ~scope decl_name_seq decl_value_seq
    | `infix (":", `template decl_name_seq, decl_value_syn) ->
      resolve_decl_tpl ~config ~scope decl_name_seq [ decl_value_syn ]
    | `infix (":", decl_name_syn, `template decl_value_seq) ->
      resolve_decl_tpl ~config ~scope [ decl_name_syn ] decl_value_seq
    | `infix (":", decl_name_syn, decl_value_syn) ->
      resolve_decl_tpl ~config ~scope [ decl_name_syn ] [ decl_value_syn ]
    | _ -> expected "decl" "_ : _" syn

  let rec eval_pat_var_value ~config (syn : flx) =
    match syn with
    | `str str -> Re.str str
    | `char c -> Re.char c
    | `brackets (`infix ("-", `char c1, `char c2)) -> Re.rg c1 c2
    | `id config_option -> Config.regex_for_option config_option config
    | `postfix ("?", syn') -> Re.opt (eval_pat_var_value ~config syn')
    | `pipe items ->
      let items_re = List.map (eval_pat_var_value ~config) items in
      Re.longest (Re.alt items_re)
    | `parens syn' -> eval_pat_var_value ~config syn'
    | `seq seq -> Re.seq (List.map (eval_pat_var_value ~config) seq)
    | _ ->
      expected "pattern" "string, char, id, [char - char], `_?` or `_ | _`" syn

  let eval_pat_seg ~config scope (syn : flx) =
    match syn with
    | `str str -> Re.str str
    | `char c -> Re.char c
    | `parens (`infix ("=", `id var_name, var_value_syn))
    | `infix ("=", `id var_name, var_value_syn) ->
      let var_value_re = eval_pat_var_value ~config var_value_syn in
      (* WIP: Handle regex var, currently is saved as config var and fails on lookup. *)
      let scope_var =
        match var_value_syn with
        | `id option when Config.is_regex_var ~var_name:option config ->
          Inline_var { slot = scope.var_count + 1; re = var_value_re }
        | `id option -> Config_var { option; slot = scope.var_count + 1 }
        | _ -> Inline_var { slot = scope.var_count + 1; re = var_value_re }
      in
      add_scope_var ~name:var_name scope_var scope;
      Re.group ~name:var_name var_value_re
    | _ -> expected "utility pattern" "`\"...\"` or `_ | _`" syn

  let eval_pat ~config scope (syn : flx) =
    match syn with
    | `template segs -> Re.seq (List.map (eval_pat_seg ~config scope) segs)
    | seg -> Re.seq [ eval_pat_seg ~config scope seg ]

  let eval_case ~config (syn : flx) =
    let scope = new_scope () in
    let pat, decl_syn_list =
      match syn with
      | `infix ("=>", pat, `braces (`comma decl_syn_list)) ->
        (pat, decl_syn_list)
      | `infix ("=>", pat, `braces decl_syn) -> (pat, [ decl_syn ])
      | _ -> expected "match case" "_ => { _ } or _ => { _, _ }" syn
    in
    let case_re =
      Re_utils.delimited
        ~breakpoint:(Config.regex_for_media config)
        (eval_pat ~config scope pat)
    in
    let decl_list_delayed = List.map (eval_decl ~config ~scope) decl_syn_list in
    let resolve_block g =
      let decl_block = List.concat_map (fun run -> run ~g) decl_list_delayed in
      let breakpoint =
        let name_match = Re.Group.get g 1 in
        if String.equal name_match "" then None
        else
          (* Drop trailing ':'. *)
          let name = String.sub name_match 0 (String.length name_match - 1) in
          let size = Config.lookup_media config name in
          Some { name; size }
      in
      let variants_match = Re.Group.get g 2 in
      let utility = Re.Group.get g 3 in
      let variants = String.split_on_char ':' variants_match in
      let selector =
        Css_gen.make_selector_name ~breakpoint ~variants ~utility
      in
      { breakpoint; selector; decl_block }
    in
    (case_re, resolve_block)

  let eval_group ~config (syn : flx) =
    match syn with
    | `infix ("=", `id _group_name, `braces (`comma cases)) ->
      List.map (eval_case ~config) cases
    | `infix ("=", `id _group_name, `braces case) -> [ eval_case ~config case ]
    | _ -> expected "utility" "{ _ , _ }" syn

  let eval ~config (syn : flx) =
    match syn with
    | `semi groups -> List.concat_map (eval_group ~config) groups
    | _ -> eval_group ~config syn
end

let read_config path = Config.read path

let read_schema ~config path =
  let syn =
    In_channel.with_open_text path (fun chan ->
        Flx.parse (Flx.Lex.read_channel chan)
    )
  in
  let cases = Schema_eval.eval ~config syn in
  Re_match.compile cases

type config = Config.t
type schema = rule Re_match.t

let process input schema =
  let seq = Re_match.all schema input in
  let css = Css_gen.css_of_rule_seq seq in
  if not (Css_gen.is_empty css) then Fmt.pr "%a@." Css_gen.pp_css css

exception Undefined_scope_var = Config.Undefined_scope_var
exception Undefined_config_opt = Config.Undefined_config_opt
