open Std_internal

type ('key, 'a, 'cmp) t = ('key, 'a, 'cmp) Map.t

let to_map x = x

let key_not_in_enumeration t key =
  failwiths
    "Key was not provided in the enumeration given to [Total_map.Make]"
    key (Map.comparator t).sexp_of_t

let change t k f =
  Map.change t k (function
    | Some x -> Some (f x)
    | None -> key_not_in_enumeration t k)

let find t k =
  match Map.find t k with
  | Some x -> x
  | None -> key_not_in_enumeration t k

let pair t1 t2 key = function
  | `Left  _ -> key_not_in_enumeration t2 key
  | `Right _ -> key_not_in_enumeration t1 key
  | `Both (v1, v2) -> (v1, v2)

let iter2 t1 t2 ~f =
  Map.iter2 t1 t2 ~f:(fun ~key ~data ->
    let (v1, v2) = pair t1 t2 key data in
    f ~key v1 v2)

let map2 t1 t2 ~f =
  Map.merge t1 t2 ~f:(fun ~key v ->
    let (v1, v2) = pair t1 t2 key v in
    Some (f v1 v2))

let set t key data = Map.add t ~key ~data

include struct
  open Map
  let map      = map
  let mapi     = mapi
  let to_alist = to_alist
  let iter     = iter
end

module type Key = sig
  type t with sexp, bin_io, compare, enumerate
end

module type S = sig
  module Key : Key

  type comparator_witness

  type nonrec 'a t = (Key.t, 'a, comparator_witness) t with sexp, bin_io, compare

  include Applicative with type 'a t := 'a t

  val create : (Key.t -> 'a) -> 'a t
end

module Make (Key : Key) = struct

  module Key = struct
    include Key
    include Comparable.Make_binable (Key)
  end

  type comparator_witness = Key.comparator_witness

  type 'a t = 'a Key.Map.t with sexp, compare

  let all_set = Key.Set.of_list Key.all

  let validate_map_from_serialization map =
    let keys = Set.of_map_keys map in
    let keys_minus_all = Set.diff keys all_set in
    let all_minus_keys = Set.diff all_set keys in
    Validate.maybe_raise (
      Validate.of_list [
        if Set.is_empty keys_minus_all then
          Validate.pass
        else
          Validate.fails "map from serialization has keys not provided in the enumeration"
            keys_minus_all <:sexp_of<Key.Set.t>>;
        if Set.is_empty all_minus_keys then
          Validate.pass
        else
          Validate.fails "map from serialization doesn't have keys it should have"
            all_minus_keys <:sexp_of<Key.Set.t>>;
      ]
    )

  let t_of_sexp a_of_sexp sexp =
    let t = t_of_sexp a_of_sexp sexp in
    validate_map_from_serialization t;
    t

  include Bin_prot.Utils.Make_binable1 (struct
    type nonrec 'a t = 'a t
    module Binable = Key.Map
    let to_binable x = x
    let of_binable x = validate_map_from_serialization x; x
  end)

  let create f =
    List.fold Key.all ~init:Key.Map.empty ~f:(fun t key ->
      Map.add t ~key ~data:(f key))

  include Applicative.Make (struct
      type nonrec 'a t = 'a t
      let return x = create (fun _ -> x)
      let apply t1 t2 = map2 t1 t2 ~f:(fun f x -> f x)
      let map = `Custom map
    end)
end
