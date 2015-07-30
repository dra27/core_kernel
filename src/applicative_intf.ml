(** Applicatives model computations in which values computed by subcomputations cannot
    affect what subsequent computations will take place.  Relative to monads, this
    restriction takes power away from the user of the interface and gives it to the
    implementation.  In particular, because the structure of the entire computation is
    known, one can augment its definition with some description of that structure.

    For more information, see:

    {v
      Applicative Programming with Effects.
      Conor McBride and Ross Paterson.
      Journal of Functional Programming 18:1 (2008), pages 1-13.
      http://staff.city.ac.uk/~ross/papers/Applicative.pdf
    v}
*)

module type Basic = sig
  type 'a t
  val return : 'a -> 'a t
  val apply : ('a -> 'b) t -> 'a t -> 'b t
  (** The following identities ought to hold for every Applicative (for some value of =):

      - [return Fn.id <*> t = t]
      - [return Fn.compose <*> tf <*> tg <*> tx = tf <*> (tg <*> tx)]
      - [return f <*> return x = return (f x)]
      - [tf <*> return x = return (fun f -> f x) <*> tf]

      Note: <*> is the infix notation for apply.
  *)

  (** The [map] argument to [Applicative.Make] says how to implement the applicative's
      [map] function.  [`Define_using_apply] means to define [map t ~f = return f <*> t].
      [`Custom] overrides the default implementation, presumably with something more
      efficient.

      Some other functions returned by [Applicative.Make] are defined in terms of [map],
      so passing in a more efficient [map] will improve their efficiency as well. *)
  val map : [`Define_using_apply | `Custom of ('a t -> f:('a -> 'b) -> 'b t)]
end

module type S = sig

  type 'a t

  val return : 'a -> 'a t

  val apply : ('a -> 'b) t -> 'a t -> 'b t

  val map : 'a t -> f:('a -> 'b) -> 'b t

  val map2 : 'a t -> 'b t -> f:('a -> 'b -> 'c) -> 'c t

  val map3 : 'a t -> 'b t -> 'c t -> f:('a -> 'b -> 'c -> 'd) -> 'd t

  val all : 'a t list -> 'a list t

  val both : 'a t -> 'b t -> ('a * 'b) t

  module Applicative_infix : sig
    val ( <*> ) : ('a -> 'b) t -> 'a t -> 'b t (** same as [apply] *)
    val ( <*  ) : 'a t -> unit t -> 'a t
    val (  *> ) : unit t -> 'a t -> 'a t
  end

  include module type of Applicative_infix

end

(** argument lists and associated N-ary map and apply functions *)
module type Args = sig

  type 'a arg (** the underlying applicative *)

  (** ['f] is the type of a function that consumes the list of arguments and returns an
      ['r]. *)
  type ('f, 'r) t

  (** the empty argument list **)
  val nil : ('r, 'r) t

  (** prepend an argument *)
  val cons : 'a arg -> ('f, 'r) t -> ('a -> 'f, 'r) t

  (** infix operator for [cons] *)
  val (@>) : 'a arg -> ('f, 'r) t -> ('a -> 'f, 'r) t

  (** Transform argument values in some way.  For example, one can label a function
      argument like so:

      {[
        step ~f:(fun f ~foo:x -> f x) : ('a -> 'r1, 'r2) t -> (foo:'a -> 'r1, 'r2) t
      ]}
  *)
  val step : ('f1, 'r) t -> f:('f2 -> 'f1) -> ('f2, 'r) t

  (** The preferred way to factor out an [Args] sub-sequence:

      {[
        let args =
          Foo.Args.(
            bar "A"
            (* TODO: factor out the common baz qux sub-sequence *)
            @> baz "B"
            @> qux "C"
            @> zap "D"
            @> nil
          )
      ]}

      is to write a function that prepends the sub-sequence:

      {[
        let baz_qux remaining_args =
          Foo.Args.(
            baz "B"
            @> qux "C"
            @> remaining_args
          )
      ]}

      and splice it back into the original sequence using [@@] so that things line up
      nicely:

      {[
        let args =
          Foo.Args.(
            bar "A"
            @> baz_qux
            @@ zap "D"
            @> nil
          )
      ]}
  *)

  val mapN : f:'f -> ('f, 'r) t -> 'r arg

  val applyN : 'f arg -> ('f, 'r) t -> 'r arg

end

module type Basic2 = sig
  type ('a, 'e) t
  val return : 'a -> ('a, _) t
  val apply : ('a -> 'b, 'e) t -> ('a, 'e) t -> ('b, 'e) t
  val map : [`Define_using_apply | `Custom of (('a, 'e) t -> f:('a -> 'b) -> ('b, 'e) t)]
end

module type S2 = sig
  type ('a, 'e) t

  val return : 'a -> ('a, _) t

  val apply : ('a -> 'b, 'e) t -> ('a, 'e) t -> ('b, 'e) t

  val map : ('a, 'e) t -> f:('a -> 'b) -> ('b, 'e) t

  val map2 : ('a, 'e) t -> ('b, 'e) t -> f:('a -> 'b -> 'c) -> ('c, 'e) t

  val map3
    :  ('a, 'e) t
    -> ('b, 'e) t
    -> ('c, 'e) t
    -> f:('a -> 'b -> 'c -> 'd)
    -> ('d, 'e) t

  val all : ('a, 'e) t list -> ('a list, 'e) t

  val both : ('a, 'e) t -> ('b, 'e) t -> ('a * 'b, 'e) t

  module Applicative_infix : sig
    val ( <*> ) : ('a -> 'b, 'e) t -> ('a, 'e) t -> ('b, 'e) t
    val ( <*  ) : ('a, 'e) t -> (unit, 'e) t -> ('a, 'e) t
    val (  *> ) : (unit, 'e) t -> ('a, 'e) t -> ('a, 'e) t
  end

  include module type of Applicative_infix
end

(** This module serves mostly as a partial check that [S2] and [S] are in sync, but
    actually calling it is occasionally useful. *)
module S_to_S2 (X : S) : (S2 with type ('a, 'e) t = 'a X.t) = struct
  type ('a, 'e) t = 'a X.t
  include (X : S with type 'a t := 'a X.t)
end

module S2_to_S (X : S2) : (S with type 'a t = ('a, unit) X.t) = struct
  type 'a t = ('a, unit) X.t
  include (X : S2 with type ('a, 'e) t := ('a, 'e) X.t)
end

module type Args2 = sig
  type ('a, 'e) arg

  type ('f, 'r, 'e) t

  val nil : ('r, 'r, _) t

  val cons : ('a, 'e) arg -> ('f, 'r, 'e) t -> ('a -> 'f, 'r, 'e) t
  val (@>) : ('a, 'e) arg -> ('f, 'r, 'e) t -> ('a -> 'f, 'r, 'e) t

  val step : ('f1, 'r, 'e) t -> f:('f2 -> 'f1) -> ('f2, 'r, 'e) t

  val mapN : f:'f -> ('f, 'r, 'e) t -> ('r, 'e) arg
  val applyN : ('f, 'e) arg -> ('f, 'r, 'e) t -> ('r, 'e) arg
end

module Args_to_Args2 (X : Args) : (
  Args2 with type ('a, 'e) arg = 'a X.arg
        with type ('f, 'r, 'e) t = ('f, 'r) X.t
) = struct
  type ('a, 'e) arg = 'a X.arg
  type ('f, 'r, 'e) t = ('f, 'r) X.t
  include (X : Args with type 'a arg := 'a X.arg and type ('f, 'r) t := ('f, 'r) X.t)
end
