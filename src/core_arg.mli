(** INRIA's original command-line parsing library.

    The [Command] module is generally recommended over direct use of this library.. *)

include module type of Caml.Arg

type t = key * spec * doc

(** Like [align], except that the specification list is also sorted by key *)
val sort_and_align : (key * spec * doc) list -> (key * spec * doc) list
