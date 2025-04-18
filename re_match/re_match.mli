type 'a t
(** The compiled state of the regular expression matcher.

    The type variable ['a] is the type of the matching cases. This is similar to
    the [match] expression in OCaml in the sense that all cases must have the
    same type. *)

val compile : (Re.t * (Re.Group.t -> 'a)) list -> 'a t
(** [compile cases] produces a match state from pairs [(re, action)] in [cases].

    The resulting state marks each [re] so that when it is matched, [action] is
    called with the matched group.

    @raise Invalid_argument when [cases] is empty. *)

val exec : 'a t -> string -> 'a option
(** [exec rematch input] attempts to match [input] with cases in [rematch],
    producing the result of calling the action associated to matched regular
    expression. *)

val all : 'a t -> string -> 'a Seq.t
(** [exec rematch input] attempts to match [input] with cases in [rematch],
    producing the result of calling the action associated to matched regular
    expression. *)

val re : 'a t -> Re.re
(** The underlying compiled regular expression. *)
