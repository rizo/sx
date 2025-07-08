let () =
  Printexc.record_backtrace true;
  let config = Sx.read_config "./sx.json" in
  let schema =
    try Sx.read_schema ~config "./schema.flx" with
    | Sx.Schema_error err ->
      Fmt.epr "schema error: %a@." Sx.pp_schema_error err;
      exit 1
    | Sx.Undefined_scope_var var_name ->
      Fmt.epr "error: undefined scope variable: %S@." var_name;
      exit 1
    | Sx.Undefined_config_opt opt_name ->
      Fmt.epr "error: undefined theme option: %S@." opt_name;
      exit 1
  in
  while true do
    match In_channel.input_line stdin with
    | None ->
      print_newline ();
      exit 0
    | Some line -> Sx.process line schema
  done
