{
  let ( let* ) xs f = List.concat_map f xs

  let string_of_scope scope =
    match scope with
    | `sm -> "sm"
    | `md -> "md"
    | `lg -> "lg"
    | `xl -> "xl"
    | `xl2 -> "2xl"

  let make_selector_name ~scope ~variants ~utility =
    match (scope, variants) with
    | None, [] -> utility
    | Some scope, [] -> string_of_scope scope ^ "\\:" ^ utility
    | _ ->
      let selector_prefix =
        Option.fold scope ~none:variants ~some:(fun scope ->
            string_of_scope scope :: variants)
      in
      let name = String.concat "\\:" selector_prefix ^ "\\:" ^ utility in
      name ^ ":" ^ String.concat ":" variants
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

let auto = "auto"

let color_base = 
    "amber"
  | "blue"
  | "cyan"
  | "emerald"
  | "fuchsia"
  | "gray"
  | "green"
  | "indigo"
  | "lime"
  | "neutral"
  | "orange"
  | "pink"
  | "purple"
  | "red"
  | "rose"
  | "sky"
  | "slate"
  | "stone"
  | "teal"
  | "violet"
  | "white"
  | "yellow"
  | "zinc"

let color_final = 
    "inherit"
  | "current"
  | "transparent"
  | "black"
  | "white"

let color_num = "50" | "950" | (['1'-'9'] "00")

let color = (color_final | (color_base "-" color_num)) 

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

rule read_utility = parse
  (* aspect-ratio *)
  | "aspect-auto" { ["aspect-ratio:auto;"] }
  | "aspect-square" { ["aspect-ratio:1 / 1;"] }
  | "aspect-video" { ["aspect-ratio:16 / 9;"] }

  (* columns *)
  | "columns-" (['0'-'9'] | ('1' ('0' | '1' | '2') | auto) as v) {
    ["columns:"; v; ";" ]
  }
  | "columns-" (size as size) {
    let* size = Gen.size size in
    ["columns:"; size; ";"]
  }

  (* break *)
  | "break-after-" (break_value as v) { ["break-after:"; v; ";"] }
  | "break-before-" (break_value as v) { ["break-before:"; v; ";"] }
  | "break-inside-" (break_inside_value as v) { ["break-before:"; v; ";"] }

  (* box-decoration *)
  | "box-decoration-" ("clone" | "slice" as v) { ["box-decoration-break:"; v; ";"] }

  (* box-sizing *)
  | "box-" ("border" | "content" as v) { ["box-sizing:"; v; "-box;"] }

  (* display *)
  | "block" as v { ["display:"; v; ";"] }
  | "inline-block" as v { ["display:"; v;  ";"] }
  | "inline" as v { ["display:"; v; ";"] }
  | "flex" as v { ["display:"; v; ";"] }
  | "inline-flex" as v { ["display:"; v; ";"] }
  | "table" as v { ["display:"; v; ";"] }
  | "inline-table" as v { ["display:"; v; ";"] }
  | "table-caption" as v { ["display:"; v; ";"] }
  | "table-cell" as v { ["display:"; v; ";"] }
  | "table-column" as v { ["display:"; v; ";"] }
  | "table-column-group" as v { ["display:"; v; ";"] }
  | "table-footer-group" as v { ["display:"; v; ";"] }
  | "table-header-group" as v { ["display:"; v; ";"] }
  | "table-row-group" as v { ["display:"; v; ";"] }
  | "table-row" as v { ["display:"; v; ";"] }
  | "flow-root" as v { ["display:"; v; ";"] }
  | "grid" as v { ["display:"; v; ";"] }
  | "inline-grid" as v { ["display:"; v; ";"] }
  | "contents" as v { ["display:"; v; ";"] }
  | "list-item" as v { ["display:"; v ; ";"] }
  | "hidden" { ["display:none;"] }

  (* flex-basis *)
  | "basis-auto" { ["flex-basis:auto;"] }
  | "basis-" (len as len) {
    let* len = Gen.len len in
    ["flex-basis:"; len; ";"]
  }

  (* float *)
  | "float-start" { ["float:inline-start;"] }
  | "float-end" { ["float:inline-end;"] }
  | "float-" ("left" | "right" | "none" as v) { ["float:"; v; ";"] }

  (* clear *)
  | "clear-start" { ["clear:inline-start;"] }
  | "clear-end" { ["clear:inline-end;"] }
  | "clear-" ("left" | "right" | "none" as v) { ["clear:"; v; ";"] }

  (* isolate *)
  | "isolate" { ["isolation:isolate;"] }
  | "isolation-auto" { ["isolation:auto;"] }

  (* object-fit *)
  | "object-" ("contain" | "cover" | "fill" | "none" | "scale-down" as v) {
    ["object-fit:"; v; ";"]
  }

  (* position *)
  | "static" as v { ["position:"; v; ";"] }
  | "fixed" as v { ["position:"; v;  ";"] }
  | "absolute" as v { ["position:"; v; ";"] }
  | "relative" as v { ["position:"; v; ";"] }
  | "sticky" as v { ["position:"; v; ";"] }

  (* margin *)
  | ("-"? as minus) "m-" ((len | auto) as len) {
    let* len = Gen.len len in
    ["margin: "; minus; len; ";"]
  }
  | ("-"? as minus) "m" (side as side) "-" ((len | auto) as len) {
    let* side = Gen.side side in
    let* len = Gen.len len in
    ["margin-"; side; ": "; minus; len; ";"]
  }

  (* padding *)
  | "p-" (len as len) {
    let* len = Gen.len len in
    ["padding: "; len; ";" ]
  }
  | "p" (side as side) "-" (len as len) {
    let* side = Gen.side side in
    let* len = Gen.len len in
    ["padding-"; side; ": "; len; ";"]
  }

  (* text *)
  | "text-" (color as color) {
    let* color = Gen.color color in
    ["color:"; color; ";"]
  }

  (* text *)
  | "decoration-" (color as color) {
    let* color = Gen.color color in
    ["text-decoration-color:"; color; ";"]
  }

  (* bg *)
  | "bg-" (color as color) {
    let* color = Gen.color color in
    ["background-color:"; color; ";"]
  }
  | "bg-origin-" ("border" | "padding" | "content" as v) { ["background-origin:"; v; "-box;"] }
  | "bg-" ("bottom" | "left" | "left-bottom" | "left-top" | "right" | "right-bottom" | "right-top" | "top" as v) {
    let v = String.map (function '-' -> ' ' | x -> x) v in
    ["background-position:"; v;";"]
  }
  | "bg-repeat" {["background-repeat:repeat;"]}
  | "bg-no-repeat" {["background-repeat:no-repeat;"]}
  | "bg-repeat-" ( "x" | "y" | "round" | "space" as v) { ["background-repeat:repeat-"; v; ";"] }
  | "bg-" ("auto" | "cover" | "contain" as v) { ["background-size:"; v;";"] }
  | "bg-none" { ["background-image:none;"] }

  (* border *)
  | "border" { ["border-width: 1px;"] }
  | "border-" (border_style as v) { ["border-style:"; v; ";"] }
  | "border-" (side as side) {
    let* side = Gen.side side in
    ["border-"; side; "-width: 1px;"]
  }
  | "border-" (color as color) {
    let* color = Gen.color color in
    ["border-color:"; color; ";"]
  }
  | "border-" ('0' | '2' | '4' | '8' as px) {
    let* px = Gen.px (String.make 1 px) in
    ["border-width: "; px; ";"]
  }
  | "border-" (side as side) "-" ('0' | '2' | '4' | '8' as px) {
    let* side = Gen.side side in
    let* px = Gen.px (String.make 1 px) in
    ["border-"; side; "-width:"; px; ";"]
  }
  | "border-" (side as side) "-" (color as color) {
    let* side = Gen.side side in
    let* color = Gen.color color in
    ["border-"; side; ":"; color; ";"]
  }

  (* divide *)
  | "divide-" (color as color) {
    let* color = Gen.color color in
    ["border-color:"; color; ";"]
  }

  (* outline *)
  | "outline-" (color as color) {
    let* color = Gen.color color in
    ["outline-color:"; color; ";"]
  }

  (* ring *)
  | "ring-" (color as color) {
    let* color = Gen.color color in
    ["--tw-ring-color:"; color; ";"]
  }

  (* shadow *)
  | "shadow-" (color as color) {
    let* color = Gen.color color in
    ["--tw-shadow-color:"; color; ";"]
  }

  (* accent *)
  | "accent-auto" { ["accent-color:auto;"] }
  | "accent-" (color as color) {
    let* color = Gen.color color in
    ["accent-color:"; color; ";"]
  }

  (* caret *)
  | "caret-" (color as color) {
    let* color = Gen.color color in
    ["caret-color:"; color; ";"]
  }

  (* scroll-margin *)
  | "scroll-m-" (len as len) {
    let* len = Gen.len len in
    ["scroll-margin: "; len; ";" ]
  }
  | "scroll-m" (side as side) "-" (len as len) {
    let* side = Gen.side side in
    let* len = Gen.len len in
    ["scroll-margin-"; side; ":"; len; ";"]
  }

  (* scroll-padding *)
  | "scroll-p-" (len as len) {
    let* len = Gen.len len in
    ["scroll-padding: "; len; ";" ]
  }
  | "scroll-p" (side as side) "-" (len as len) {
    let* side = Gen.side side in
    let* len = Gen.len len in
    ["scroll-padding-"; side; ":"; len; ";"]
  }

  (* fill *)
  | "fill-" (color as color) {
    let* color = Gen.color color in
    ["fill:"; color; ";"]
  }

  (* stroke *)
  | "stroke-" (color as color) {
    let* color = Gen.color color in
    ["stroke:"; color; ";"]
  }
  | "stroke-" ("0" | "1" | "2" as v) {
    ["stroke-width:"; String.make 1 v; ";"]
  }

  | _ as unexpected { invalid_arg (String.make 1 unexpected) }


and read out scope variants = parse
  (* responsive *)
  | "sm:" { read out (Some `sm) variants lexbuf }
  | "md:" { read out (Some `md) variants lexbuf }
  | "lg:" { read out (Some `lg) variants lexbuf }
  | "xl:" { read out (Some `xl) variants lexbuf }
  | "2xl:" { read out (Some `xl2) variants lexbuf }

  (* variants *)
  | (pseudo_class_variant as v) ":" {
    read out scope (v :: variants) lexbuf
  }

  | ' ' { read out None [] lexbuf }

  | eof { out }
  | "" {
    let i = lexbuf.lex_curr_pos in
    let properties = String.concat "" (read_utility lexbuf) in
    let j = lexbuf.lex_curr_pos in
    let utility = Bytes.to_string (Bytes.sub lexbuf.lex_buffer i (j - i)) in
    (* Fmt.pr "LEX: i=%d j=%d %s %S@." i j (Bytes.to_string lexbuf.lex_buffer) utility; *)
    let selector = make_selector_name ~scope ~variants ~utility in
    let out' = Css_output.add ~scope ~selector ~properties out in
    read out' scope variants lexbuf
  }

{
  let read lexbuf =
   let out = read Css_output.empty None [] lexbuf in
   out
}
