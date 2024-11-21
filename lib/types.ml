module type S = sig
  type prop

  val mt : int -> prop
  val py : int -> prop
  val hover : prop list -> prop
  val focus : prop list -> prop
  val blur : prop list -> prop
  val md : prop list -> prop
  val xl : prop list -> prop
  val sm : prop list -> prop

  (* Border *)
  type b = { xl : int; m : int }

  val b : prop
  val bt : b
  val br : prop
  val bb : prop
  val bl : prop
end

module type Css = sig
  type rule
  type display = [ `flex | `grid | `block ]
  type flex_direction = [ `row | `row_reverse | `column | `column_reverse ]
  type safe_position = [ `center | `start | `end_ ]
  type align_items = [ `normal | `stretch | safe_position ]
  type font_size = [ `px of int | `pt of int ]
  type width = [ `px of int | `pt of int ]
  type pct = [ `pct of float ]

  type len =
    [ `ch of float
    | `em of float
    | `ex of float
    | `rem of float
    | `vh of float
    | `vw of float
    | `vmin of float
    | `vmax of float
    | `px of int
    | `pxFloat of float
    | `cm of float
    | `mm of float
    | `inch of float
    | `pc of float
    | `pt of int
    | `zero
    | `percent of float ]

  type pct_len_calc =
    [ pct
    | len
    | `min of pct_len_calc * pct_len_calc
    | `max of pct_len_calc * pct_len_calc
    | `add of pct_len_calc * pct_len_calc
    | `subtract of pct_len_calc * pct_len_calc
    | `mul of pct_len_calc * float
    | `div of pct_len_calc * float ]

  type color =
    [ `white
    | `black
    | `blue
    | `red
    | `darkblue
    | `lightblue
    | `rgb of int * int * int
    | `rgba of int * int * int * int ]

  type position_alignment =
    [ `center
    | `start
    | `end_
    | `flexStart
    | `flexEnd
    | `selfStart
    | `selfEnd
    | `left
    | `right ]

  val display : display -> rule
  val flex_direction : flex_direction -> rule
  val align_items : align_items -> rule
  val background_color : color -> rule
  val color : color -> rule
  val unsafe : string -> string -> rule
  val padding : int -> rule
  val hover : rule list -> rule
  val active : rule list -> rule
  val font_size : font_size -> rule
  val line_height : float -> rule
  val width : pct_len_calc -> rule
  val height : pct_len_calc -> rule
  val justify_content : position_alignment -> rule
end
