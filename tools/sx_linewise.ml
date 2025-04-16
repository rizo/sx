let () =
  Printexc.record_backtrace true;
  In_channel.fold_lines
    (fun () line ->
      try
        let out = Sx.read_string line in
        Fmt.pr "%a" Sx.Css.pp out
      with exn -> Fmt.pr "error: input=%S: %a@." line Fmt.exn exn)
    () stdin
