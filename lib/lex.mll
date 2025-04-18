{
  let ( let* ) = Gen.( let* )
  let (or) = Gen.(or)
  let concat = String.concat ""

  exception Non_utility

  type state = {
    scope : [ `sm | `md | `lg | `xl | `xl2] option;
    variants : string list;
  }

  let init = {
    scope = None;
    variants = [];
  }

  open Theme.Prelude
}

let pseudo_class_variant =
    "hover"
  | "focus"
  | "active"
  | "focus-within"
  | "focus-visible"
  | "motion-safe"
  | "disabled"
  | "visited"
  | "checked"
  | "first"
  | "last"
  | "odd"
  | "even"

let side = ['x' 'y' 's' 'e' 't' 'r' 'b' 'l']

let num = ['1'-'9']['0'-'9']*

let pct = "0" | "5" | "100" | (['1'-'9'] ("0" | "5"))

let len_int =
    ['0'-'9']
  | "10"
  | "11"
  | "12"
  | "14"
  | "16"
  | "20"
  | "24"
  | "28"
  | "32"
  | "36"
  | "40"
  | "44"
  | "48"
  | "52"
  | "56"
  | "60"
  | "64"
  | "72"
  | "80"
  | "96"

let len =
  len_int
  | "px"
  | (['0'-'3'] ".5")

let size = 
    "3xs"
  | "2xs"
  | "xs"
  | "sm"
  | "md"
  | "lg"
  | "xl"
  | "2xl"
  | "3xl"
  | "4xl"
  | "5xl"
  | "6xl"
  | "7xl"

let text_size = 
    "xs"
  | "sm"
  | "base"
  | "lg"
  | "xl"
  | "2xl"
  | "3xl"
  | "4xl"
  | "5xl"
  | "6xl"
  | "7xl"
  | "8xl"
  | "9xl"

let auto = "auto"
let full = "full"

let suffix = (['a'-'z'] | ['0'-'9'] | '-' | '_' )+

let break_inside_value =
    "auto"
  | "avoid"
  | "avoid-page"
  | "avoid-column"

let break_value =
    "auto"
  | "avoid"
  | "all"
  | "avoid-page"
  | "page"
  | "left"
  | "right"
  | "column"

let border_style =
    "solid"
  | "dashed"
  | "dotted"
  | "double"
  | "hidden"
  | "none"

let width =
    len
  | auto
  | full
  | "screen"
  | "svw"
  | "lvw"
  | "dvw"
  | "min"
  | "max"
  | "fit"

let height =
    len
  | auto
  | full
  | "screen"
  | "svh"
  | "lvh"
  | "dvh"
  | "min"
  | "max"
  | "fit"

let content =
    "normal"
  | "start"
  | "end"
  | "center"
  | "between"
  | "around"
  | "evenly"
  | "stretch"

(* Chars that delimit utility names.
  If a utility name is not delimited by one of these, it will NOT be treated as
  a valid utility. EOF is treated as a delimiter in the lexer.
  
  The '|' char is not supported by the official tailwindcss CLI, but we add it to
  allow matching utilities in OCaml `{|...|}` strings. *)
let delim = ' ' | '\n' | '\t' | '\"' | '\'' | '|'

rule read_utility state theme = parse
  (* aspect-ratio *)
  | "aspect-auto" {
    [Gen.decl "aspect-ratio" "auto"]
  }
  | "aspect-square" {
    [Gen.decl "aspect-ratio" "1/1"]
  }
  | "aspect-video" {
    [Gen.decl "aspect-ratio" "16/9"]
  }

  | "columns-" (['0'-'9'] | ('1' ('0' | '1' | '2') | auto) as v) {
    [Gen.decl "columns" v]
  }

  | "columns-" (size as size) {
    let* size = Gen.get theme.size size in
    [Gen.decl "columns" size]
  }

  (* break *)
  | "break-after-" (break_value as v) {
    [Gen.decl "break-after" v]
  }
  | "break-before-" (break_value as v) {
    [Gen.decl "break-before" v]
  }
  | "break-inside-" (break_inside_value as v) {
    [Gen.decl "break-before" v]
  }

  (* box-decoration *)
  | "box-decoration-" ("clone" | "slice" as v) {
    [Gen.decl "box-decoration-break" v]
  }

  (* box-sizing *)
  | "box-" ("border" | "content" as v) {
    [Gen.decl "box-sizing" (v ^ "-box")]
  }

  (* display *)
  | "block" as v {
    [Gen.decl "display" v]
  }
  | "inline-block" as v {
    [Gen.decl "display" v]
  }
  | "inline" as v {
    [Gen.decl "display" v]
  }
  | "flex" as v {
    [Gen.decl "display" v]
  }
  | "inline-flex" as v {
    [Gen.decl "display" v]
  }
  | "table" as v {
    [Gen.decl "display" v]
  }
  | "inline-table" as v {
    [Gen.decl "display" v]
  }
  | "table-caption" as v {
    [Gen.decl "display" v]
  }
  | "table-cell" as v {
    [Gen.decl "display" v]
  }
  | "table-column" as v {
    [Gen.decl "display" v]
  }
  | "table-column-group" as v {
    [Gen.decl "display" v]
  }
  | "table-footer-group" as v {
    [Gen.decl "display" v]
  }
  | "table-header-group" as v {
    [Gen.decl "display" v]
  }
  | "table-row-group" as v {
    [Gen.decl "display" v]
  }
  | "table-row" as v {
    [Gen.decl "display" v]
  }
  | "flow-root" as v {
    [Gen.decl "display" v]
  }
  | "grid" as v {
    [Gen.decl "display" v]
  }
  | "inline-grid" as v {
    [Gen.decl "display" v]
  }
  | "contents" as v {
    [Gen.decl "display" v]
  }
  | "list-item" as v {
    [Gen.decl "display" v ]
  }
  | "hidden" {
    [Gen.decl "display" "none"]
  }

  (* flex-basis *)
  | "basis-auto" {
    [Gen.decl "flex-basis" "auto"]
  }
  | "basis-" (len as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "flex-basis" len]
  }

  (* float *)
  | "float-start" {
    [Gen.decl "float" "inline-start"]
  }
  | "float-end" {
    [Gen.decl "float" "inline-end"]
  }
  | "float-" ("left" | "right" | "none" as v) {
    [Gen.decl "float" v]
  }

  (* clear *)
  | "clear-start" {
    [Gen.decl "clear" "inline-start"]
  }
  | "clear-end" {
    [Gen.decl "clear" "inline-end"]
  }
  | "clear-" ("left" | "right" | "none" as v) {
    [Gen.decl "clear" v]
  }

  (* isolate *)
  | "isolate" {
    [Gen.decl "isolation" "isolate"]
  }
  | "isolation-auto" {
    [Gen.decl "isolation" "auto"]
  }

  (* object-fit *)
  | "object-" ("contain" | "cover" | "fill" | "none" | "scale-down" as v) {
    [Gen.decl "object-fit" v]
  }

  (* position *)
  | "static" | "fixed" | "absolute" | "relative" | "sticky" as v {
    [Gen.decl "position" v]
  }

  (* top-right-bottom-left frac *)
  | "left-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    [Gen.decl "left" len]
  }
  | "right-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    [Gen.decl "right" len]
  }
  | "bottom-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    [Gen.decl "bottom" len]
  }
  | "top-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    [Gen.decl "top" len]
  }
  | "inset-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    [Gen.decl "inset" len]
  }
  | "inset-" (side as side) "-" (num as n) "/" (num as m) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.frac n m in
    [Gen.decl side len]
  }
  | "start-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    [Gen.decl "inset-inline-start" len]
  }
  | "end-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    [Gen.decl "inset-inline-end" len]
  }

  (* top-right-bottom-left len *)
  | "left-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "left" len]
  }
  | "right-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "right" len]
  }
  | "bottom-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "bottom" len]
  }
  | "top-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "top" len]
  }
  | "inset-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "inset" len]
  }
  | "inset-" (side as side) "-" ((len | auto | full) as len) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    [Gen.decl side len]
  }
  | "start-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "inset-inline-start" len]
  }
  | "end-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "inset-inline-end" len]
  }

  (* gap *)
  | "gap-" (len as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "gap" len]
  }

  (* gap *)
  | "gap-" (side as side) "-" (len as len) {
    let* dir = Gen.dir (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    [Gen.decl (dir ^ "-gap") len]
  }

  (* width *)
  | "w-[" ([^ '[' ']' '{' '}' '@']+ as v) "]" {
    [Gen.decl "width" v]
  }
  | "w-" (num as n) "/" (num as m) {
    let* pct = Gen.frac n m in
    [Gen.decl "width" pct]
  }
  | "w-" (width as key) {
    let* len = (Gen.len theme.spacing or Gen.width) key in
    [Gen.decl "width" len]
  }

  (* height *)
  | "h-[" ([^ '[' ']' '{' '}' '@']+ as v) "]" {
    [Gen.decl "height" v]
  }
  | "h-" (num as n) "/" (num as m) {
    let* pct = Gen.frac n m in
    [Gen.decl "height" pct]
  }
  | "h-" (height as key) {
    let* len = (Gen.len theme.spacing or Gen.height) key in
    [Gen.decl "height" len]
  }

  (* margin *)
  | ("-"? as minus) "m-" ((len | auto) as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "margin" (minus ^ len)]
  }
  | ("-"? as minus) "m" (side as side) "-" ((len | auto) as len) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    [Gen.decl ("margin-" ^ side) (minus ^ len)]
  }

  (* z *)
  | "z-" ("0" | "10" | "20" | "30" | "40" | "50" | auto as key) {
    [Gen.decl "z-index" key]
  }

  (* basis *)
  | "basis-" (num as n) "/" (num as m) {
    let* pct = Gen.frac n m in
    [Gen.decl "flex-basis" pct]
  }
  | "basis-full" {
    [Gen.decl "flex-basis" "100%"]
  }

  (* opacity *)
  | "opacity-" (pct as key) {
    let* pct = Gen.pct key in
    [Gen.decl "opacity" pct]
  }

  (* backdrop-opacity *)
  | "backdrop-opacity-" (pct as key) {
    let* pct = Gen.pct key in
    ["backdrop-filter: opacity("; pct;");"]
  }

  (* justify-content *)
  | "justify-" (content as k) {
    let* v = Gen.content k in
    [Gen.decl "justify-content" v]
  }

  (* justify-items *)
  | "justify-items-" (("start" | "end" | "center" | "stretch") as v) {
    [Gen.decl "justify-items" v]
  }

  (* justify-self *)
  | "justify-self-" ((auto | "start" | "end" | "center" | "stretch") as v) {
    [Gen.decl "justify-self" v]
  }

  (* align-content *)
  | "content-" ((content | "baseline") as k) {
    let* v = Gen.content k in
    [Gen.decl "align-content" v]
  }

  (* align-items *)
  | "items-" (("start" | "end" | "center" | "baseline" | "stretch") as k) {
    let* v = Gen.content k in
    [Gen.decl "align-items" v]
  }

  (* align-self *)
  | "self-" ((auto | "start" | "end" | "center" | "baseline" | "stretch") as k) {
    let* v = Gen.content k in
    [Gen.decl "align-self" v]
  }

  (* place-content *)
  | "place-content-" (("start" | "end" | "center" | "between" 
                      | "arount" | "evenly" | "baseline" | "stretch") as k) {
    let* v = Gen.content k in
    [Gen.decl "place-content" v]
  }

  (* place-items *)
  | "place-items-" (("start" | "end" | "center" | "baseline" | "stretch") as k) {
    let* v = Gen.content k in
    [Gen.decl "place-items" v]
  }

  (* place-self *)
  | "place-self-" ((auto | "start" | "end" | "center"  | "stretch") as k) {
    let* v = Gen.content k in
    [Gen.decl "place-self" v]
  }

  (* padding *)
  | "p-" (len as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "padding" len]
  }
  | "p" (side as side) "-" (len as len) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    [Gen.decl ("padding-" ^ side) len]
  }

  (* text *)
  | "text-" (text_size as text_size) {
    let* size, line_height = Gen.text theme text_size in
    [Gen.decl "font-size" size; Gen.decl "line-height" line_height]
  }
  | "text-" (suffix as color) {
    let* color = Gen.get theme.color color in
    [Gen.decl "color" color]
  }

  (* indent *)
  | "indent-" (len as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "text-indent" len]
  }

  (* decoration *)
  | "decoration-" (suffix as color) {
    let* color = Gen.get theme.color color in
    [Gen.decl "text-decoration-color" color]
  }

  (* bg *)
  | "bg-origin-" ("border" | "padding" | "content" as v) {
    [Gen.decl "background-origin" (v ^ "-box")]
  }
  | "bg-" ("bottom" | "left" | "left-bottom" | "left-top" | "right" | "right-bottom" | "right-top" | "top" as v) {
    let v = String.map (function '-' -> ' ' | x -> x) v in
    [Gen.decl "background-position" v]
  }
  | "bg-repeat" {
    [Gen.decl "background-repeat" "repeat"]
  }
  | "bg-no-repeat" {
    [Gen.decl "background-repeat" "no-repeat"]
  }
  | "bg-repeat-" ( "x" | "y" | "round" | "space" as v) {
    [Gen.decl "background-repeat" ("repeat-" ^ v)]
  }
  | "bg-" ("auto" | "cover" | "contain" as v) {
    [Gen.decl "background-size" v]
  }
  | "bg-none" {
    [Gen.decl "background-image" "none"]
  }
  | "bg-" (suffix as color) {
    let* color = Gen.get theme.color color in
    [Gen.decl "background-color" color]
  }

  (* border *)
  | "border" {
    [Gen.decl "border-width" "1px"]
  }
  | "border-" (border_style as v) {
    [Gen.decl "border-style" v]
  }
  (* TODO: use var? *)
  | "border-" (side as side) {
    let* side = Gen.side (String.make 1 side) in
    [Gen.decl (concat ["border-"; side; "-width"]) "1px"]
  }
  | "border-" ('0' | '2' | '4' | '8' as px) {
    let* px = Gen.px (String.make 1 px) in
    [Gen.decl "border-width" px]
  }
  | "border-" (side as side) "-" ('0' | '2' | '4' | '8' as px) {
    let* side = Gen.side (String.make 1 side) in
    let* px = Gen.px (String.make 1 px) in
    [Gen.decl (concat ["border-"; side; "-width"]) px]
  }
  | "border-" (side as side) "-" (suffix as color) {
    let* side = Gen.side (String.make 1 side) in
    let* color = Gen.get theme.color color in
    [Gen.decl ("border-" ^ side) color]
  }
  | "border-" (suffix as color) {
    let* color = Gen.get theme.color color in
    [Gen.decl "border-color" color]
  }

  (* divide color *)
  | "divide-" (suffix as color) {
    let* color = Gen.get theme.color color in
    [Gen.decl "border-color" color]
  }

  (* outline *)
  | "outline-" (suffix as color) {
    let* color = Gen.get theme.color color in
    [Gen.decl "outline-color" color]
  }

  (* ring *)
  (* FIXME: use var API *)
  | "ring-" (suffix as color) {
    let v = Gen.lookup theme.color color in
    [Gen.var "sx-ring-color" v]
  }

  (* shadow *)

  | "shadow-" (suffix as key) {
    try
      let* v = Gen.get theme.shadow key in
      [Gen.decl "box-shadow" v]
    with Gen.Unknown_key _ ->
      let v = Gen.lookup theme.color key in
      [Gen.var "sx-shadow-color" v]
  }

  (*| "shadow-" (suffix as suffix) {*)
  (*  let* v = Gen.(get theme.shadow or get_var "sx-shadow-color" theme.color) suffix in*)
  (*  [Gen.decl "box-shadow" v]*)
  (*}*)
  | "shadow" {
    let* box_shadow = Gen.get theme.shadow "" in
    [Gen.decl "box-shadow" box_shadow]
  }

  (* accent *)
  | "accent-auto" { ["accent-color:auto;"] }
  | "accent-" (suffix as color) {
    let* color = Gen.get theme.color color in
    [Gen.decl "accent-color" color]
  }

  (* caret *)
  | "caret-" (suffix as color) {
    let* color = Gen.get theme.color color in
    [Gen.decl "caret-color" color]
  }

  (* scroll-margin *)
  | "scroll-m-" (len as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "scroll-margin" len]
  }
  | "scroll-m" (side as side) "-" (len as len) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    [Gen.decl ("scroll-margin-" ^ side)  len]
  }

  (* scroll-padding *)
  | "scroll-p-" (len as len) {
    let* len = Gen.len theme.spacing len in
    [Gen.decl "scroll-padding" len]
  }
  | "scroll-p" (side as side) "-" (len as len) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    [Gen.decl ("scroll-padding-" ^ side) len]
  }

  (* fill *)
  | "fill-" (suffix as color) {
    let* color = Gen.get theme.color color in
    [Gen.decl "fill" color]
  }

  (* stroke *)
  | "stroke-" ("0" | "1" | "2" as v) {
    [Gen.decl "stroke-width" (String.make 1 v)]
  }
  | "stroke-" (suffix as color) {
    let* color = Gen.get theme.color color in
    [Gen.decl "stroke" color]
  }

  (* custom *)
  (*| '[' ([^ '[' ']']+ as v) ']' {
    [v; ";"]
  }*)

  | _ { raise Non_utility }

and has_delim = parse
  | delim | eof { true }
  | _ { false }

and skip_non_utility state = parse
  | delim { () }
  | _ { skip_non_utility state lexbuf }


and read state theme out = parse
  (* responsive *)
  | "sm:"  { read { state with scope = Some `sm } theme out lexbuf }
  | "md:"  { read { state with scope = Some `md } theme out lexbuf }
  | "lg:"  { read { state with scope = Some `lg } theme out lexbuf }
  | "xl:"  { read { state with scope = Some `xl } theme out lexbuf }
  | "2xl:" { read { state with scope = Some `xl2 } theme out lexbuf }

  (* variants *)
  | (pseudo_class_variant as v) ":" {
    read { state with variants = v :: state.variants } theme out lexbuf
  }

  | delim+ {
    read init theme out lexbuf
  }

  | eof { out }
  | "" {
    try
      let properties = String.concat ";" (read_utility state theme lexbuf) in
      let utility = Lexing.lexeme lexbuf in
      if has_delim lexbuf then
        let selector = Css.make_selector_name ~scope:state.scope ~variants:state.variants ~utility in
        let out' = Css.add ~scope:state.scope ~selector ~properties out in
        read init theme out' lexbuf
      else
        read init theme out lexbuf
    with
    | Non_utility | Gen.Unknown_key _ ->
      skip_non_utility state lexbuf;
      read init theme out lexbuf
  }

{
  let read theme lexbuf =
    read init theme Css.empty lexbuf
}
