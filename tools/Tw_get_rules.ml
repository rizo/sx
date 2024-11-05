open Soup.Infix

let base_url = "https://tailwindcss.com/docs/"
let sep = "\t"

let get_immediate_text node =
  node
  |> Soup.children
  |> Soup.filter Soup.is_text
  |> Soup.fold
       (fun acc node ->
         let t = String.trim (Soup.R.leaf_text node) in
         if String.equal t " " then acc else t :: acc)
       []
  |> List.rev
  |> String.concat ""

let get_tr_data tr =
  let key_td = tr |> Soup.children |> Soup.R.nth 1 in
  let value_td = tr |> Soup.children |> Soup.R.nth 2 in
  let key = get_immediate_text key_td in
  let value = get_immediate_text value_td in
  (key, value)

let get_page_info url =
  prerr_endline ("processing " ^ url);
  let curl_chan = Unix.open_process_in ("curl -s " ^ url) in
  let data = In_channel.input_all curl_chan in
  let soup = Soup.parse data in
  let rows = soup $ "tbody" |> Soup.children |> Soup.elements in
  Soup.fold (fun acc node -> get_tr_data node :: acc) [] rows |> List.rev

let make_slug name =
  String.map
    (function
      | ' ' -> '-'
      | c -> Char.lowercase_ascii c)
    name

let () =
  Printexc.record_backtrace true;
  let input_path = Sys.argv.(1) in
  let output_path = Sys.argv.(2) in
  let lines = In_channel.with_open_text input_path In_channel.input_lines in
  let lines = List.tl lines (* skip header *) in
  let oc = open_out output_path in
  let process_line line =
    match String.split_on_char ',' line with
    | [ category; group; slug ] ->
      let slug = if String.equal slug "" then make_slug group else slug in
      let url = base_url ^ slug in
      let properties = get_page_info url in
      List.iter
        (fun (key, value) ->
          let row = String.concat sep [ category; group; slug; key; value ] in
          Out_channel.output_string oc (row ^ "\n"))
        properties
    | _ -> invalid_arg ("invalid row: " ^ line)
  in
  List.iter process_line lines;
  close_out oc
