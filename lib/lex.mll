{
  let ( let* ) = Gen.( let* )
  let (or) = Gen.(or)

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

(* Chars that delimit utility names.
  If a utility name is not delimited by one of these, it will NOT be treated as
  a valid utility. EOF is treated as a delimiter in the lexer.
  
  The '|' char is not supported by the official tailwindcss CLI, but we add it to
  allow matching utilities in OCaml `{|...|}` strings. *)
let delim = ' ' | '\n' | '\t' | '\"' | '\'' | '|'

rule read_utility state theme = parse
  (* aspect-ratio *)
  | "aspect-auto" { ["aspect-ratio:auto;"] }
  | "aspect-square" { ["aspect-ratio:1 / 1;"] }
  | "aspect-video" { ["aspect-ratio:16 / 9;"] }

  (* columns *)
  | "columns-" (['0'-'9'] | ('1' ('0' | '1' | '2') | auto) as v) {
    ["columns: "; v; ";" ]
  }
  | "columns-" (size as size) {
    let* size = Gen.get theme.size size in
    ["columns: "; size; ";"]
  }

  (* break *)
  | "break-after-" (break_value as v) { ["break-after: "; v; ";"] }
  | "break-before-" (break_value as v) { ["break-before: "; v; ";"] }
  | "break-inside-" (break_inside_value as v) { ["break-before: "; v; ";"] }

  (* box-decoration *)
  | "box-decoration-" ("clone" | "slice" as v) { ["box-decoration-break: "; v; ";"] }

  (* box-sizing *)
  | "box-" ("border" | "content" as v) { ["box-sizing: "; v; "-box;"] }

  (* display *)
  | "block" as v { ["display: "; v; ";"] }
  | "inline-block" as v { ["display: "; v;  ";"] }
  | "inline" as v { ["display: "; v; ";"] }
  | "flex" as v { ["display: "; v; ";"] }
  | "inline-flex" as v { ["display: "; v; ";"] }
  | "table" as v { ["display: "; v; ";"] }
  | "inline-table" as v { ["display: "; v; ";"] }
  | "table-caption" as v { ["display: "; v; ";"] }
  | "table-cell" as v { ["display: "; v; ";"] }
  | "table-column" as v { ["display: "; v; ";"] }
  | "table-column-group" as v { ["display: "; v; ";"] }
  | "table-footer-group" as v { ["display: "; v; ";"] }
  | "table-header-group" as v { ["display: "; v; ";"] }
  | "table-row-group" as v { ["display: "; v; ";"] }
  | "table-row" as v { ["display: "; v; ";"] }
  | "flow-root" as v { ["display: "; v; ";"] }
  | "grid" as v { ["display: "; v; ";"] }
  | "inline-grid" as v { ["display: "; v; ";"] }
  | "contents" as v { ["display: "; v; ";"] }
  | "list-item" as v { ["display: "; v ; ";"] }
  | "hidden" { ["display:none;"] }

  (* flex-basis *)
  | "basis-auto" { ["flex-basis:auto;"] }
  | "basis-" (len as len) {
    let* len = Gen.len theme.spacing len in
    ["flex-basis: "; len; ";"]
  }

  (* float *)
  | "float-start" { ["float:inline-start;"] }
  | "float-end" { ["float:inline-end;"] }
  | "float-" ("left" | "right" | "none" as v) { ["float: "; v; ";"] }

  (* clear *)
  | "clear-start" { ["clear:inline-start;"] }
  | "clear-end" { ["clear:inline-end;"] }
  | "clear-" ("left" | "right" | "none" as v) { ["clear: "; v; ";"] }

  (* isolate *)
  | "isolate" { ["isolation:isolate;"] }
  | "isolation-auto" { ["isolation:auto;"] }

  (* object-fit *)
  | "object-" ("contain" | "cover" | "fill" | "none" | "scale-down" as v) {
    ["object-fit: "; v; ";"]
  }

  (* position *)
  | "static" | "fixed" | "absolute" | "relative" | "sticky" as v {
    ["position: "; v; ";"]
  }

  (* top-right-bottom-left frac *)
  | "left-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    ["left: "; len; ";"]
  }
  | "right-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    ["right: "; len; ";"]
  }
  | "bottom-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    ["bottom: "; len; ";"]
  }
  | "top-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    ["top: "; len; ";"]
  }
  | "inset-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    ["inset: "; len; ";"]
  }
  | "inset-" (side as side) "-" (num as n) "/" (num as m) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.frac n m in
    [side; ": "; len; ";"]
  }
  | "start-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    ["inset-inline-start: "; len; ";"]
  }
  | "end-" (num as n) "/" (num as m) {
    let* len = Gen.frac n m in
    ["inset-inline-end: "; len; ";"]
  }

  (* top-right-bottom-left len *)
  | "left-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    ["left: "; len; ";"]
  }
  | "right-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    ["right: "; len; ";"]
  }
  | "bottom-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    ["bottom: "; len; ";"]
  }
  | "top-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    ["top: "; len; ";"]
  }
  | "inset-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    ["inset: "; len; ";"]
  }
  | "inset-" (side as side) "-" ((len | auto | full) as len) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    [side; ": "; len; ";"]
  }
  | "start-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    ["inset-inline-start: "; len; ";"]
  }
  | "end-" ((len | auto | full) as len) {
    let* len = Gen.len theme.spacing len in
    ["inset-inline-end: "; len; ";"]
  }

  (* gap *)
  | "gap-" (len as len) {
    let* len = Gen.len theme.spacing len in
    ["gap: "; len; ";"]
  }

  (* gap *)
  | "gap-" (side as side) "-" (len as len) {
    let* dir = Gen.dir (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    [dir; "-gap: "; len; ";"]
  }

  (* width frac *)
  | "w-" (num as n) "/" (num as m) {
    let* pct = Gen.frac n m in
    ["width: "; pct; ";"]
  }

  (* width *)
  | "w-" (width as key) {
    let* len = (Gen.len theme.spacing or Gen.width) key in
    ["width: "; len; ";"]
  }

  (* height frac *)
  | "h-" (num as n) "/" (num as m) {
    let* pct = Gen.frac n m in
    ["height: "; pct; ";"]
  }

  (* height *)
  | "h-" (height as key) {
    let* len = (Gen.len theme.spacing or Gen.height) key in
    ["height: "; len; ";"]
  }

  (* margin *)
  | ("-"? as minus) "m-" ((len | auto) as len) {
    let* len = Gen.len theme.spacing len in
    ["margin: "; minus; len; ";"]
  }
  | ("-"? as minus) "m" (side as side) "-" ((len | auto) as len) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    ["margin-"; side; ": "; minus; len; ";"]
  }

  (* z *)
  | "z-" ("0" | "10" | "20" | "30" | "40" | "50" | auto as key) {
    ["z-index: "; key; ";"]
  }

  (* basis *)
  | "basis-" (num as n) "/" (num as m) {
    let* pct = Gen.frac n m in
    ["flex-basis: "; pct; ";"]
  }
  | "basis-full" { ["flex-basis: 100%;"] }

  (* opacity *)
  | "opacity-" (pct as key) {
    let* pct = Gen.pct key in
    ["opacity: "; pct; ";"]
  }

  (* backdrop-opacity *)
  | "backdrop-opacity-" (pct as key) {
    let* pct = Gen.pct key in
    ["backdrop-filter: opacity("; pct;");"]
  }

  (* padding *)
  | "p-" (len as len) {
    let* len = Gen.len theme.spacing len in
    ["padding: "; len; ";" ]
  }
  | "p" (side as side) "-" (len as len) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    ["padding-"; side; ": "; len; ";"]
  }

  (* text *)
  | "text-" (text_size as text_size) {
    let* size, line_height = Gen.text theme text_size in
    ["font-size: "; size; "; line-height: "; line_height; ";"]
  }
  | "text-" (suffix as color) {
    let* color = Gen.get theme.color color in
    ["color: "; color; ";"]
  }

  (* indent *)
  | "indent-" (len as len) {
    let* len = Gen.len theme.spacing len in
    ["text-indent: "; len; ";"]
  }

  (* decoration *)
  | "decoration-" (suffix as color) {
    let* color = Gen.get theme.color color in
    ["text-decoration-color: "; color; ";"]
  }

  (* bg *)
  | "bg-origin-" ("border" | "padding" | "content" as v) { ["background-origin: "; v; "-box;"] }
  | "bg-" ("bottom" | "left" | "left-bottom" | "left-top" | "right" | "right-bottom" | "right-top" | "top" as v) {
    let v = String.map (function '-' -> ' ' | x -> x) v in
    ["background-position: "; v;";"]
  }
  | "bg-repeat" {["background-repeat:repeat;"]}
  | "bg-no-repeat" {["background-repeat:no-repeat;"]}
  | "bg-repeat-" ( "x" | "y" | "round" | "space" as v) { ["background-repeat:repeat-"; v; ";"] }
  | "bg-" ("auto" | "cover" | "contain" as v) { ["background-size: "; v;";"] }
  | "bg-none" { ["background-image:none;"] }
  | "bg-" (suffix as color) {
    let* color = Gen.get theme.color color in
    ["background-color: "; color; ";"]
  }

  (* border *)
  | "border" { ["border-width: 1px;"] }
  | "border-" (border_style as v) { ["border-style: "; v; ";"] }
  | "border-" (side as side) {
    let* side = Gen.side (String.make 1 side) in
    ["border-"; side; "-width: 1px;"]
  }
  | "border-" ('0' | '2' | '4' | '8' as px) {
    let* px = Gen.px (String.make 1 px) in
    ["border-width: "; px; ";"]
  }
  | "border-" (side as side) "-" ('0' | '2' | '4' | '8' as px) {
    let* side = Gen.side (String.make 1 side) in
    let* px = Gen.px (String.make 1 px) in
    ["border-"; side; "-width: "; px; ";"]
  }
  | "border-" (side as side) "-" (suffix as color) {
    let* side = Gen.side (String.make 1 side) in
    let* color = Gen.get theme.color color in
    ["border-"; side; ": "; color; ";"]
  }
  | "border-" (suffix as color) {
    let* color = Gen.get theme.color color in
    ["border-color: "; color; ";"]
  }

  (* divide *)
  | "divide-" (suffix as color) {
    let* color = Gen.get theme.color color in
    ["border-color: "; color; ";"]
  }

  (* outline *)
  | "outline-" (suffix as color) {
    let* color = Gen.get theme.color color in
    ["outline-color: "; color; ";"]
  }

  (* ring *)
  | "ring-" (suffix as color) {
    let* color = Gen.get theme.color color in
    ["--sx-ring-color: "; color; ";"]
  }

  (* shadow *)
  | "shadow-" (suffix as suffix) {
    let* box_shadow = Gen.(get theme.shadow or var "sx-shadow-color" theme.color) suffix in
    ["box-shadow: "; box_shadow; ";"]
  }
  | "shadow" {
    let* box_shadow = Gen.get theme.shadow "" in
    ["box-shadow: "; box_shadow; ";"]
  }

  (* accent *)
  | "accent-auto" { ["accent-color:auto;"] }
  | "accent-" (suffix as color) {
    let* color = Gen.get theme.color color in
    ["accent-color: "; color; ";"]
  }

  (* caret *)
  | "caret-" (suffix as color) {
    let* color = Gen.get theme.color color in
    ["caret-color: "; color; ";"]
  }

  (* scroll-margin *)
  | "scroll-m-" (len as len) {
    let* len = Gen.len theme.spacing len in
    ["scroll-margin: "; len; ";" ]
  }
  | "scroll-m" (side as side) "-" (len as len) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    ["scroll-margin-"; side; ": "; len; ";"]
  }

  (* scroll-padding *)
  | "scroll-p-" (len as len) {
    let* len = Gen.len theme.spacing len in
    ["scroll-padding: "; len; ";" ]
  }
  | "scroll-p" (side as side) "-" (len as len) {
    let* side = Gen.side (String.make 1 side) in
    let* len = Gen.len theme.spacing len in
    ["scroll-padding-"; side; ": "; len; ";"]
  }

  (* fill *)
  | "fill-" (suffix as color) {
    let* color = Gen.get theme.color color in
    ["fill: "; color; ";"]
  }

  (* stroke *)
  | "stroke-" ("0" | "1" | "2" as v) {
    ["stroke-width: "; String.make 1 v; ";"]
  }
  | "stroke-" (suffix as color) {
    let* color = Gen.get theme.color color in
    ["stroke: "; color; ";"]
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
      let properties = String.concat "" (read_utility state theme lexbuf) in
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
