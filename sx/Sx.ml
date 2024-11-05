open struct
  let fmt = Format.asprintf
  let str ?(sep = "") parts = String.concat sep parts
end

module type Css = sig
  type property
  type length

  val px : int -> length
  val px_0 : length
  val px_1 : length
  val unsafe_px_of_string : string -> length
  val border_width : length -> property
end

module Tw = struct
  let len_8px = [ `px0; `px1; `px2; `px4; `px8 ]
  let border_style = [ `solid; `dashed; `dotted; `double; `none ]
end

let ( let$ ) xs f = List.concat_map f xs

module Char_set = Set.Make (Char)

module Pat_tree = struct
  module Var = struct
    type 'a t = {
      name : string;
      of_string : string -> 'a option;
      value : 'a -> string list;
      values : string list;
      parser : 'a Angstrom.t;
    }

    let side =
      let parser =
        let open Angstrom in
        let* x = peek_char_fail in
        let out x = advance 1 *> return x in
        match x with
        | 'x' -> out `x
        | 'y' -> out `y
        | 's' -> out `s
        | 'e' -> out `e
        | 't' -> out `t
        | 'r' -> out `r
        | 'b' -> out `b
        | 'l' -> out `l
        | _ -> fail "side: invalid char"
      in
      let of_string str =
        match str with
        | "x" -> Some `x
        | "y" -> Some `y
        | "s" -> Some `s
        | "e" -> Some `e
        | "t" -> Some `t
        | "r" -> Some `r
        | "b" -> Some `b
        | "l" -> Some `l
        | _ -> None
      in
      let value side =
        match side with
        | `x -> [ "left"; "right" ]
        | `y -> [ "top"; "bottom" ]
        | `s -> [ "inline-start" ]
        | `e -> [ "inline-end" ]
        | `t -> [ "top" ]
        | `r -> [ "right" ]
        | `b -> [ "bottom" ]
        | `l -> [ "left" ]
      in
      let values =
        [
          "left";
          "right";
          "top";
          "bottom";
          "inline-start";
          "inline-end";
          "top";
          "right";
          "bottom";
          "left";
        ]
      in
      { name = "side"; parser; of_string; value; values }

    let len =
      let of_string str =
        match str with
        | "0" -> Some `len_0
        | "px" -> Some `len_px
        | "0.5" -> Some `len_0_5
        | "1" -> Some `len_1
        | "1.5" -> Some `len_1_5
        | "2" -> Some `len_2
        | "2.5" -> Some `len_2_5
        | "3" -> Some `len_3
        | "3.5" -> Some `len_3_5
        | "4" -> Some `len_4
        | "5" -> Some `len_5
        | "6" -> Some `len_6
        | "7" -> Some `len_7
        | "8" -> Some `len_8
        | "9" -> Some `len_9
        | "10" -> Some `len_10
        | "11" -> Some `len_11
        | "12" -> Some `len_12
        | "14" -> Some `len_14
        | "16" -> Some `len_16
        | "20" -> Some `len_20
        | "24" -> Some `len_24
        | "28" -> Some `len_28
        | "32" -> Some `len_32
        | "36" -> Some `len_36
        | "40" -> Some `len_40
        | "44" -> Some `len_44
        | "48" -> Some `len_48
        | "52" -> Some `len_52
        | "56" -> Some `len_56
        | "60" -> Some `len_60
        | "64" -> Some `len_64
        | "72" -> Some `len_72
        | "80" -> Some `len_80
        | "96" -> Some `len_96
        | _ -> None
      in
      let value side =
        match side with
        | `len_0 -> [ "0px" ]
        | `len_px -> [ "pxpx" ]
        | `len_0_5 -> [ "0.125rem" ]
        | `len_1 -> [ "0.25rem" ]
        | `len_1_5 -> [ "0.375rem" ]
        | `len_2 -> [ "0.5rem" ]
        | `len_2_5 -> [ "0.625rem" ]
        | `len_3 -> [ "0.75rem" ]
        | `len_3_5 -> [ "0.875rem" ]
        | `len_4 -> [ "1rem" ]
        | `len_5 -> [ "1.25rem" ]
        | `len_6 -> [ "1.5rem" ]
        | `len_7 -> [ "1.75rem" ]
        | `len_8 -> [ "2rem" ]
        | `len_9 -> [ "2.25rem" ]
        | `len_10 -> [ "2.5rem" ]
        | `len_11 -> [ "2.75rem" ]
        | `len_12 -> [ "3rem" ]
        | `len_14 -> [ "3.5rem" ]
        | `len_16 -> [ "4rem" ]
        | `len_20 -> [ "5rem" ]
        | `len_24 -> [ "6rem" ]
        | `len_28 -> [ "7rem" ]
        | `len_32 -> [ "8rem" ]
        | `len_36 -> [ "9rem" ]
        | `len_40 -> [ "10rem" ]
        | `len_44 -> [ "11rem" ]
        | `len_48 -> [ "12rem" ]
        | `len_52 -> [ "13rem" ]
        | `len_56 -> [ "14rem" ]
        | `len_60 -> [ "15rem" ]
        | `len_64 -> [ "16rem" ]
        | `len_72 -> [ "18rem" ]
        | `len_80 -> [ "20rem" ]
        | `len_96 -> [ "24rem" ]
      in
      let values = [] in
      let parser = Angstrom.return `len_0 in
      { name = "side"; parser; of_string; value; values }

    let color =
      let of_string str =
        match str with
        | "white" -> Some `white
        | "black" -> Some `black
        | _ -> None
      in
      let parser =
        let open Angstrom in
        let* color = string "white" <|> string "black" in
        return (Option.get (of_string color))
      in
      let value side =
        match side with
        | `white -> [ "rgb(255 255 255)" ]
        | `black -> [ "rgb(0 0 0)" ]
      in
      let values = [] in
      { name = "side"; parser; of_string; value; values }
  end

  module Gen = struct
    type t = Gen : ('a Var.t * ('a -> string)) -> t
  end

  module Key = struct
    type frag = Const of string | Var of (Gen.t * string)
    type t = frag list

    let compare k1 k2 =
      List.compare
        (fun x1 x2 ->
          match (x1, x2) with
          | Var _, Var _ -> 0
          | Const c1, Const c2 -> String.compare c1 c2
          | Const _, Var _ -> 1
          | Var _, Const _ -> -1)
        k1 k2
  end

  type 'gen pat =
    | Const : string * 'gen pat -> 'gen pat
    | Var : 'v Var.t * 'gen pat -> ('v -> 'gen) pat
    | End : (unit -> string list) pat

  type gen = Gen : ('gen pat * 'gen) -> gen

  let border =
    let pat = Const ("border", End) in
    let gen () = [ str [ "border-width: 1px;" ] ] in
    Gen (pat, gen)

  type rule = Rule : ('a Angstrom.t * ('a -> string list)) -> rule

  let border_side_rule =
    let parse =
      let open Angstrom in
      string "border-" *> Var.side.parser
    in
    let yield side =
      let$ side = Var.side.value side in
      [ str [ "border-"; side; "-width: 1px;" ] ]
    in
    Rule (parse, yield)

  let border_side_color_rule =
    let parse =
      let open Angstrom in
      let* side = string "border-" *> Var.side.parser in
      let* color = string "-" *> Var.color.parser in
      return (side, color)
    in
    let yield (side, color) =
      let$ side = Var.side.value side in
      let$ color = Var.color.value color in
      [ str [ "border-"; side; "-color: "; color; ";" ] ]
    in
    Rule (parse, yield)

  let combine r1 r2 =
    let (Rule (p1, y1)) = r1 in
    let (Rule (p2, y2)) = r2 in
    Angstrom.(map p1 ~f:y1 <|> map p2 ~f:y2 <* end_of_input)

  let border_side =
    let pat = Const ("border-", Var (Var.side, End)) in
    let gen side () =
      let$ side = Var.side.value side in
      [ str [ "border-"; side; "-width: 1px;" ] ]
    in
    Gen (pat, gen)

  let border_side_color =
    let pat =
      Const ("border-", Var (Var.side, Const ("-", Var (Var.color, End))))
    in
    let gen side color () =
      let$ side = Var.side.value side in
      let$ color = Var.color.value color in
      [ str [ "border-"; side; "-color: "; color; ";" ] ]
    in
    Gen (pat, gen)

  let m_len =
    let pat = Const ("m-", Var (Var.len, End)) in
    let gen len () =
      let$ len = Var.len.value len in
      [ str [ "margin: "; len; ";" ] ]
    in
    Gen (pat, gen)

  let m_side_len =
    let pat = Const ("m", Var (Var.side, Const ("-", Var (Var.len, End)))) in
    let gen side len () =
      let$ side = Var.side.value side in
      let$ len = Var.len.value len in
      [ str [ "margin-"; side; ": "; len; ";" ] ]
    in
    Gen (pat, gen)

  let input_1 = "border-x-white"
  let input_2 = "mb-5"
  let input_2 = "mb-auto"
  let input_3 = "m-auto"
end

module Gen = struct
  (* Spacing *)

  type side = [ `t | `r | `b | `l ]
  type axis = [ `x | `y ]
  type logical = [ `s | `e ]
  type auto = [ `auto ]

  let margin = "${minus}m${direction|axis|logical}-${sp96|auto}"

  let gen_side side =
    match side with
    | "x" -> [ "left"; "right" ]
    | "y" -> [ "top"; "bottom" ]
    | "s" -> [ "inline-start" ]
    | "e" -> [ "inline-end" ]
    | "t" -> [ "top" ]
    | "r" -> [ "right" ]
    | "b" -> [ "bottom" ]
    | "l" -> [ "left" ]
    | _ -> invalid_arg side

  module type Parser = sig
    type 'a t

    val const : string -> unit t
    val return : 'a -> 'a t

    module Syntax : sig
      val ( let* ) : 'a t -> ('a -> 'b t) -> 'bt
    end
  end

  let border parts =
    match parts with
    (* border *)
    | [ "border" ] -> [ "border-width: 1px" ]
    | [ "border"; (("0" | "2" | "4" | "8") as size) ] ->
      [ fmt "border-width: %spx" size ]
    | [ "border"; (("x" | "y" | "s" | "e" | "t" | "r" | "b" | "l") as side) ] ->
      let$ side = gen_side side in
      [ fmt "border-%s-width: 1px" side ]
    | [
     "border";
     (("x" | "y" | "s" | "e" | "t" | "r" | "b" | "l") as side);
     (("0" | "2" | "4" | "8") as size);
    ] ->
      let$ side = gen_side side in
      [ fmt "border-%s-width: %spx" side size ]
    | _ -> invalid_arg ("invalid rule: " ^ String.concat "-" parts)

  module Margin = struct
    let minus = true
    let side = [ `t; `r; `b; `l; `x; `y; `s; `e ]

    let s =
      [
        `s0;
        `spx;
        `s0_5;
        `s1;
        `s1_5;
        `s2;
        `s2_5;
        `s3;
        `s3_5;
        `s4;
        `s5;
        `s6;
        `s7;
        `s8;
        `s9;
        `s10;
        `s11;
        `s12;
        `s14;
        `s16;
        `s20;
        `s24;
        `s28;
        `s32;
        `s36;
        `s40;
        `s44;
        `s48;
        `s52;
        `s56;
        `s60;
        `s64;
        `s72;
        `s80;
        `s96;
        `auto;
      ]
  end
end

let parse p str = Angstrom.parse_string ~consume:Prefix p str
