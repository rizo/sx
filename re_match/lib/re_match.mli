(** {1 Regular-expression case matching}

    This module allows matching an input string based on a regular expression.
    The provided functionality is similar to OCaml's [match] expression:

    {[
      let cases =
        let re = Re.Posix.re in
        [
          (* Match a number *)
          (re "[0-9]+", fun g -> "a number: " ^ Re.Group.get g 0);
          (* Match something fixed *)
          (re "fixed", fun g -> "just a fixed string");
          (* Match an email *)
          (re "[a-z0-9_.]+@[a-z0-9_-]+(.[a-z]+)*", fun g -> Re.Group.get g 0);
        ]
        |> Re_match.compile

      let () =
        match Re_match.exec cases "user@example.com" with
        | None -> print_endline "No match"
        | Some matched -> print_endline ("Match: " ^ matched)
    ]} *)

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
