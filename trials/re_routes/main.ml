module Common = struct
  open Re

  (** [0-9]+ *)
  let pos_int = rep1 digit

  (** -?[0-9]+ *)
  let int = seq [ opt (char '-'); pos_int ]

  (** -?[0-9]+( .[0-9]* )? *)
  let float =
    seq [ opt (char '-'); rep1 digit; opt (seq [ char '.'; rep digit ]) ]

  (** true|false *)
  let bool = alt [ str "true"; str "false" ]
end

module Rematch = struct
  module Mark_map = Map.Make (Re.Mark)

  let cases xs =
    match xs with
    | (re0, k0) :: res ->
      let m0, re0' = Re.mark re0 in
      let ctx0 = Mark_map.singleton m0 k0 in
      let ctx, re =
        List.fold_left
          (fun (ctx, acc) (re, k) ->
            let m, re' = Re.mark re in
            let ctx' = Mark_map.add m k ctx in
            let acc' = Re.alt [ acc; re' ] in
            (ctx', acc'))
          (ctx0, re0') res
      in
      (ctx, Re.compile re)
    | _ -> failwith "insufficient routes"

  let exec (ctx, re) input =
    match Re.exec_opt re input with
    | None -> failwith "no match"
    | Some g ->
      let ml = Re.Mark.all g in
      Re.Mark.Set.iter
        (fun m ->
          let k = Mark_map.find m ctx in
          Printf.printf "k = %S\n" k)
        ml
end

let r1 =
  Rematch.cases
    [
      (Common.pos_int, "POSITIVE");
      (Common.int, "INTEGER");
      (Common.float, "FLOATING");
      (Common.bool, "BOOLEAN");
    ]

let () =
  while true do
    print_string "> ";
    flush stdout;
    match In_channel.input_line stdin with
    | None -> ()
    | Some line -> begin Rematch.exec r1 line end
  done
