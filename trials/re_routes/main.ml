module Common = struct
  open Re

  (** [0-9]+ *)
  let pos_int = rep1 digit

  (** -?[0-9]+ *)
  let int = seq [ opt (char '-'); pos_int ]

  (** -?[0-9]+\.[0-9]* *)
  let float = seq [ opt (char '-'); rep1 digit; seq [ char '.'; rep digit ] ]

  (** true|false *)
  let bool = alt [ str "true"; str "false" ]
end

module Rematch : sig
  type 'a t

  val compile : (Re.t * (Re.Group.t -> 'a)) list -> 'a t
  (** [compile cases] produces a rematch state from pairs [(re, action)] in
      [cases].

      The resulting state marks each [re] so that when it is matched, [action]
      is called with the matched group.

      @raise Invalid_argument when [cases] is empty. *)

  val exec : 'a t -> string -> 'a option
  (** [exec rematch input] attempts to match [input] with cases in [rematch],
      producing the result of calling the action associated to matched regular
      expression. *)
end = struct
  module Mark_map = Map.Make (Re.Mark)

  type 'a t = (Re.Group.t -> 'a) Mark_map.t * Re.re

  let compile cases0 =
    match cases0 with
    | (re0, k0) :: cases' ->
      let m0, re0' = Re.mark re0 in
      let ctx0 = Mark_map.singleton m0 k0 in
      let ctx, re =
        List.fold_left
          (fun (ctx, acc) (re, k) ->
            let m, re' = Re.mark re in
            let ctx' = Mark_map.add m k ctx in
            let acc' = Re.alt [ acc; re' ] in
            (ctx', acc'))
          (ctx0, re0') cases'
      in
      (ctx, Re.compile re)
    | [] -> invalid_arg "empty cases"

  let exec (ctx, re) input =
    match Re.exec_opt re input with
    | None -> None
    | Some g ->
      let marks = Re.Mark.all g in
      assert (Re.Mark.Set.cardinal marks = 1);
      let m = Re.Mark.Set.min_elt marks in
      let k = Mark_map.find m ctx in
      Some (k g)
end

open Printf

let r1 =
  Rematch.compile
    [
      (Common.float, fun g -> sprintf "FLOATING: %S\n" (Re.Group.get g 0));
      (Common.pos_int, fun g -> sprintf "POSITIVE: %S\n" (Re.Group.get g 0));
      (Common.int, fun g -> sprintf "INTEGER: %S\n" (Re.Group.get g 0));
      (Common.bool, fun g -> sprintf "BOOLEAN: %S\n" (Re.Group.get g 0));
    ]

(* FIXME: abc123 should not match int *)

let () =
  while true do
    printf "> %!";
    match In_channel.input_line stdin with
    | None -> ()
    | Some line -> (
      match Rematch.exec r1 line with
      | Some value -> printf "%s\n%!" value
      | None -> printf "no match!\n%!")
  done
