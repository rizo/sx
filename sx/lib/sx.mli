(** Theme and schema *)

type config
type schema

val read_config : string -> config
val read_schema : config:config -> string -> schema

type schema_error

exception Schema_error of schema_error
exception Undefined_scope_var of string
exception Undefined_config_opt of string

val pp_schema_error : Format.formatter -> schema_error -> unit
val process : string -> schema -> unit
