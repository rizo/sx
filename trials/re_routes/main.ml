let print ?(break : unit Fmt.t = Format.pp_print_newline) fmt =
  Format.kfprintf (fun f -> break f ()) Format.std_formatter fmt

module Rematch : sig
  type 'a t
  (** The compiled state of the regular expression matcher.

      The type variable ['a] is the type of the matching cases. This is similar
      to the [match] expression in OCaml in the sense that all cases must have
      the same type. *)

  val compile : (Re.t * (Re.Group.t -> 'a)) list -> 'a t
  (** [compile cases] produces a match state from pairs [(re, action)] in
      [cases].

      The resulting state marks each [re] so that when it is matched, [action]
      is called with the matched group.

      @raise Invalid_argument when [cases] is empty. *)

  val exec : 'a t -> string -> 'a option
  (** [exec rematch input] attempts to match [input] with cases in [rematch],
      producing the result of calling the action associated to matched regular
      expression. *)

  val re : 'a t -> Re.re
  (** The underlying compiled regular expression. *)
end = struct
  type 'a t = { marks : (Re.Mark.t, Re.Group.t -> 'a) Hashtbl.t; re : Re.re }

  let compile case_list =
    let case_count = ref 0 in
    let case_list_rev =
      List.fold_left
        (fun acc case ->
          incr case_count;
          case :: acc)
        [] case_list
    in
    let marks = Hashtbl.create !case_count in
    (* Reverses to the original order since leftmost cases are preferred. *)
    let expr_list =
      List.fold_left
        (fun acc (case_expr, case_action) ->
          let mark, case_expr' = Re.mark case_expr in
          Hashtbl.add marks mark case_action;
          case_expr' :: acc)
        [] case_list_rev
    in
    { marks; re = Re.compile (Re.longest (Re.alt expr_list)) }

  let exec rematch input =
    match Re.exec_opt rematch.re input with
    | None -> None
    | Some g ->
      let marks = Re.Mark.all g in
      (* NOTE: Having more marks in the matching g indicates a conflict? *)
      (* NOTE: We may want to simply ignore unknown marks. *)
      assert (Re.Mark.Set.cardinal marks = 1);
      let mark = Re.Mark.Set.min_elt marks in
      print "Mark: %d" (Obj.magic mark);
      let action = Hashtbl.find rematch.marks mark in
      Some (action g)

  let re t = t.re
end

module Theme = struct
  open Re

  let num = rep1 digit
  let size = alt [ str "xs"; str "sm"; str "md"; str "lg"; str "xl" ]
  let side = alt [ str "t"; str "b"; str "l"; str "r"; str "x"; str "y" ]
end

module Rules = struct
  open Re

  let w_full = seq [ str "w-full" ]
  let w_num = seq [ str "w-"; group Theme.num ]
  let w_frac = seq [ str "w-"; group Theme.num; str "/"; group Theme.num ]

  let m_side =
    seq
      [
        group (opt (str "-"));
        str "m";
        group Theme.side;
        str "-";
        group Theme.num;
      ]

  let text_size = seq [ str "text-"; group Theme.size ]
end

module Actions = struct
  let debug_g name =
   fun g ->
    print "%s: %a@.CAP(%d): %s" name Re.Group.pp g (Re.Group.nb_groups g)
      (Re.Group.all g |> Array.to_list |> String.concat ", ")

  let debug name =
   fun g ->
    print "%s: %a@.CAP(%d): %s" name Re.Group.pp g (Re.Group.nb_groups g)
      (Re.Group.all g |> Array.to_list |> String.concat ", ")
end

let r1 =
  [
    (Rules.w_full, Actions.debug "w_full");
    (Rules.w_num, Actions.debug "w_num");
    (Rules.w_frac, Actions.debug "w_frac");
    (Rules.m_side, Actions.debug "m_side");
    (Rules.text_size, Actions.debug "text_size");
  ]
  |> Rematch.compile

(* FIXME: abc123 should not match int *)

let () =
  print "%a" Re.pp_re (Rematch.re r1);
  while true do
    print ~break:Fmt.flush "> ";
    match In_channel.input_line stdin with
    | None ->
      print_newline ();
      exit 0
    | Some line -> (
      match Rematch.exec r1 line with
      | Some () -> ()
      | None -> print "no match!")
  done
