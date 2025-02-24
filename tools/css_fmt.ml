let () =
  let data = In_channel.input_all stdin in
  let css = Css.parse_css data in
  Css.pp_string_css Format.std_formatter css
