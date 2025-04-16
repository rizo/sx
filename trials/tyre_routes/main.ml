let m1_r =
  let open Tyre in
  opt (char '-') <* str "m-" <&> int

let m1_h =
 fun (minus, len) ->
  Format.printf "minus: %b, len: %d@." (Option.is_some minus) len

let m2_r =
  let open Tyre in
  opt (char '-') <* str "m-" <&> bool <&> int

let m2_h =
 fun ((minus, bool), len) ->
  Format.printf "minus: %b, bool: %b len: %d@." (Option.is_some minus) bool len

let routes =
  let open Tyre in
  route [ m1_r --> m1_h; m2_r --> m2_h ]

let () =
  while true do
    print_string "> ";
    flush stdout;
    match In_channel.input_line stdin with
    | None -> ()
    | Some line -> (
      match Tyre.exec routes line with
      | Ok () -> ()
      | Error err -> Format.eprintf "error: %a@." Tyre.pp_error err)
  done
