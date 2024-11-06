module String_map = Map.Make (String)
module Char_set = Set.Make (Char)

let fmt = Fmt.str
let str ?(sep = "") parts = String.concat sep parts
