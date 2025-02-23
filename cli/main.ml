let () =
  Printexc.record_backtrace true;
  let chan =
    match Sys.argv with
    | [| _; "-" |] | [| _ |] -> stdin
    | [| _; path |] -> open_in path
    | _ -> invalid_arg "too many arguments"
  in
  let out = Sx.read_channel chan in
  Fmt.pr "%a" Sx.Css.pp out
