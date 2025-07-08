open Prelude

type t = {
  global : string String_map.t;
  sm : string String_map.t;
  md : string String_map.t;
  lg : string String_map.t;
  xl : string String_map.t;
  xl2 : string String_map.t;
}

let empty =
  {
    global = String_map.empty;
    sm = String_map.empty;
    md = String_map.empty;
    lg = String_map.empty;
    xl = String_map.empty;
    xl2 = String_map.empty;
  }

let is_empty self =
  String_map.is_empty self.global
  && String_map.is_empty self.sm
  && String_map.is_empty self.md
  && String_map.is_empty self.lg
  && String_map.is_empty self.xl
  && String_map.is_empty self.xl2

let add ~scope ~selector ~properties self =
  let add = String_map.add selector properties in
  match scope with
  | None -> { self with global = add self.global }
  | Some `sm -> { self with sm = add self.sm }
  | Some `md -> { self with md = add self.md }
  | Some `lg -> { self with lg = add self.lg }
  | Some `xl -> { self with xl = add self.xl }
  | Some `xl2 -> { self with xl2 = add self.xl2 }

let pp_scope formatter =
  let pp_binding formatter (key, rules) =
    Format.fprintf formatter ".%s{%a}" key Format.pp_print_string rules
  in
  Fmt.pf formatter "%a" (Fmt.iter_bindings String_map.iter pp_binding)

let pp formatter self =
  let pp_media size =
    Format.fprintf formatter "@media (width>=%dpx){%a}@." size pp_scope
  in
  if not (String_map.is_empty self.global) then
    Format.fprintf formatter "%a@." pp_scope self.global;
  if not (String_map.is_empty self.sm) then pp_media 640 self.sm;
  if not (String_map.is_empty self.md) then pp_media 768 self.md;
  if not (String_map.is_empty self.lg) then pp_media 1024 self.lg;
  if not (String_map.is_empty self.xl) then pp_media 1280 self.xl;
  if not (String_map.is_empty self.xl2) then pp_media 1536 self.xl2

let union self other =
  let combine _selector self_properties _other_properties =
    Some self_properties
  in
  {
    global = String_map.union combine self.global other.global;
    sm = String_map.union combine self.sm other.sm;
    md = String_map.union combine self.md other.md;
    lg = String_map.union combine self.lg other.lg;
    xl = String_map.union combine self.xl other.xl;
    xl2 = String_map.union combine self.xl2 other.xl2;
  }
