module String_map = Map.Make (String)
module Char_set = Set.Make (Char)

let fmt = Fmt.str
let str ?(sep = "") parts = String.concat sep parts
let ( == ) = `Deprecated
let ( = ) : int -> int -> bool = ( = )
let ( >= ) : int -> int -> bool = ( >= )
let ( < ) : int -> int -> bool = ( < )
let ( <= ) : int -> int -> bool = ( <= )

module String_ext = struct
  let iter_while p f s =
    let len = String.length s in
    let rec loop i =
      if i >= len then ()
      else
        let c = String.unsafe_get s i in
        if p c then begin
          f c;
          loop (i + 1)
        end
    in
    loop 0

  let find_index f s =
    let len = String.length s in
    let rec loop i =
      if i >= len then raise Not_found
      else
        let c = String.unsafe_get s i in
        if f c then i else loop (i + 1)
    in
    loop 0
end

let ( let* ) = Result.bind
