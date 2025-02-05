let () =
  print_endline
    (String.concat ","
       [
         "[INFO] test_use_ppx:"; Input_a.x1; Input_b.x1; Input_b.x2; Input_c.x1;
       ])
