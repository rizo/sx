open Dune_action_plugin.V1

let log =
  let out = open_out_gen [ Open_append; Open_wronly ] 0o777 "/tmp/y" in
  fun x -> output_string out (x ^ "\n")

let action () =
  (* read_directory_with_glob ~path:(Path.of_string ".")
     ~glob:(Dune_glob.V1.of_string "input_d.ml") *)
  read_file ~path:(Path.of_string "input_d.ml")
  |> map ~f:(fun x -> [ x ])
  |> stage ~f:(fun src_list ->
         let data = String.concat "++" src_list in
         write_file ~path:(Path.of_string "output.css") ~data)

(* let () = run action *)

let () =
  let files = Sys.argv |> Array.to_list |> String.concat ", " in
  let out = open_out "output.css" in
  output_string out (files ^ "\n")
