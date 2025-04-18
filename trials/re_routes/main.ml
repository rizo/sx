let print ?(break : unit Fmt.t = Format.pp_print_newline) fmt =
  Format.kfprintf (fun f -> break f ()) Format.std_formatter fmt

module Theme = struct
  open Re

  let len = rep1 digit
  let size = alt [ str "xs"; str "sm"; str "md"; str "lg"; str "xl" ]
  let side = alt [ str "t"; str "b"; str "l"; str "r"; str "x"; str "y" ]
end

module Rules = struct
  open Re

  let w_full = seq [ str "w-full" ]
  let w_len = seq [ str "w-"; group Theme.len ]
  let w_frac = seq [ str "w-"; group Theme.len; str "/"; group Theme.len ]

  let m_side_len =
    seq
      [
        group (opt (str "-"));
        str "m";
        group Theme.side;
        str "-";
        group Theme.len;
      ]

  let m_len = seq [ group (opt (str "-")); str "m-"; group Theme.len ]
  let text_size = seq [ str "text-"; group Theme.size ]
end

let debug_action name =
 fun g ->
  print "%s(%d): %s" name (Re.Group.nb_groups g)
    (Re.Group.all g |> Array.to_list |> String.concat ", ")

let delim = Re.set " \t\n\"'|"

let delimited expr =
  let open Re in
  seq [ alt [ bos; delim ]; expr ]

let case rule act = (delimited rule, act)

let cases =
  [
    case Rules.w_full (debug_action "w_full");
    case Rules.w_len (debug_action "w_len");
    case Rules.w_frac (debug_action "w_frac");
    case Rules.m_side_len (debug_action "m_side_len");
    case Rules.m_len (debug_action "m_len");
    case Rules.text_size (debug_action "text_size");
  ]
  |> Re_match.compile

let () =
  print "%a" Re.pp_re (Re_match.re cases);
  while true do
    print ~break:Fmt.flush "> ";
    match In_channel.input_line stdin with
    | None ->
      print_newline ();
      exit 0
    | Some line -> Seq.iter ignore (Re_match.all cases line)
  done
