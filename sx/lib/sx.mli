(** CSS types *)

type rule = { selector : string; decl_block : string list }

val pp_rule : Format.formatter -> rule -> unit

(** Theme and schema *)

type theme
type schema

val read_theme : string -> theme
val read_schema : theme:theme -> string -> schema

type schema_error

exception Schema_error of schema_error
exception Undefined_scope_var of string
exception Undefined_theme_opt of string

val pp_schema_error : Format.formatter -> schema_error -> unit
val process : string -> schema -> rule Seq.t
