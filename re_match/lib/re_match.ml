type 'a case = Re.re Lazy.t * (Re.Group.t -> 'a)
type 'a t = { marks : (Re.Mark.t, 'a case) Hashtbl.t; re : Re.re }

let re t = t.re

let compile case_list =
  let case_count = ref 0 in
  let case_list_rev =
    List.fold_left
      (fun acc case ->
        incr case_count;
        case :: acc
      )
      [] case_list
  in
  let marks = Hashtbl.create !case_count in
  (* Reverses to the original order since leftmost cases are preferred. *)
  let expr_list =
    List.fold_left
      (fun acc (case_expr, case_action) ->
        let mark, case_expr' = Re.mark case_expr in
        Hashtbl.add marks mark (lazy (Re.compile case_expr), case_action);
        Re.no_group case_expr' :: acc
      )
      [] case_list_rev
  in
  { marks; re = Re.compile (Re.longest (Re.alt expr_list)) }

let dispatch_group t input g =
  let pos, pos' = Re.Group.offset g 0 in
  let len = pos' - pos in
  let marks = Re.Mark.all g in
  (* NOTE: Having more marks in the matching g indicates a conflict? *)
  (* NOTE: We may want to simply ignore unknown marks. *)
  assert (Re.Mark.Set.cardinal marks = 1);
  let mark = Re.Mark.Set.min_elt marks in
  let case_re_z, case_action = Hashtbl.find t.marks mark in
  let case_g = Re.exec ~pos ~len (Lazy.force case_re_z) input in
  case_action case_g

let exec t input =
  match Re.exec_opt t.re input with
  | None -> None
  | Some g -> Some (dispatch_group t input g)

let all t input =
  let groups = Re.Seq.all t.re input in
  Seq.map (dispatch_group t input) groups
