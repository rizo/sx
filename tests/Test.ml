open Printf

let _1 () =
  print_newline ();
  let p =
    let open Sx.Pat_tree in
    combine border_side_color_rule border_side_rule
  in
  match Sx.parse p "border-t-white" with
  | Ok x -> printf "parsed: %s\n" (String.concat "," x)
  | Error msg -> printf "sx: error%s\n" msg

let print input =
  let lexbuf = Lexing.from_string input in
  try
    let out = Twlexer.Lex.read lexbuf in
    Fmt.pr "%a@." Twlexer.Css_output.pp out;
    (* printf "%S => %S\n" input actual *)
    ()
  with exn -> printf "error: %S: %s\n" input (Printexc.to_string exn)

let cases =
  [
    "m-0";
    "m-px";
    "m-1";
    "m-20";
    "my-0";
    "mx-px";
    "me-1";
    "mb-20";
    "my-0";
    "mx-px";
    "-m-4";
    "-mx-1";
    "mt-auto";
    "p-0";
    "ps-2";
    "py-80";
    "aspect-square";
    "columns-5";
    "columns-10";
    "columns-auto";
    "columns-xs";
    "columns-3xs";
    (* "columns-13"; *)
    "break-before-all";
    "break-inside-avoid";
    "flex";
    "basis-32";
    "basis-px";
    "basis-1.5";
    "hidden";
    "fixed";
    "absolute";
    "float-end";
    "clear-none";
    "object-cover";
    "border";
    "border-0";
    "border-2";
    "border-t";
    "border-x";
    "border-y-4";
    "border-black";
    "border-red-400";
    "border-x-red-400";
    "border-e-current";
    "border-slate-50";
    "border-y-sky-400";
    "border-none";
    "divide-fuchsia-950";
    "outline-slate-800";
    "ring-neutral-100";
    "shadow-neutral-900";
    "text-stone-300";
    "text-transparent";
    "decoration-pink-500";
    "bg-inherit";
    "bg-violet-900";
    "bg-origin-padding";
    "bg-right-bottom";
    "bg-no-repeat";
    "bg-repeat-x";
    "bg-none";
    "bg-auto";
    "accent-zinc-400";
    "accent-auto";
    "caret-white";
    "scroll-m-11";
    "scroll-mr-72";
    "scroll-p-0";
    "scroll-px-96";
    "fill-sky-50";
    "stroke-gray-600";
    "stroke-2";
    "md:border-t";
    "hover:bg-red-100";
    "mt-0 pb-2";
  ]

let () =
  print_newline ();
  List.iter print cases
