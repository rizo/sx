open struct
  type cset = Sedlex_ppx.Sedlex_cset.t
end

let digit = Sedlex_ppx.Xml.digit

let digit_2 =
  Sedlex_ppx.Sedlex.seq
    (Sedlex_ppx.Sedlex.chars digit)
    (Sedlex_ppx.Sedlex.chars digit)

(*
   [|
     ([|(cs1, 1); (cs2, 2); ...|], [|true; false; false; ...|]);
     ...
   |]
 *)
let auto : ((cset * int) array * bool array) array =
  Sedlex_ppx.Sedlex.compile [| digit_2 |]
