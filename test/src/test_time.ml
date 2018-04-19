open! Core_kernel
open  Expect_test_helpers_kernel

let utc date_string ofday_string =
  Time.of_date_ofday
    (Date.of_string date_string)
    (Time.Ofday.of_string ofday_string)
    ~zone:Time.Zone.utc

let examples = [
  Time.epoch;
  utc "2001-01-01" "00:00:00";
  utc "2013-10-07" "09:30:00";
  utc "2017-07-28" "11:57:00.000123";
]

let%expect_test "Time.Stable.With_utc_sexp.V2" =
  print_and_check_stable_type [%here] (module Time.Stable.With_utc_sexp.V2)
    examples;
  [%expect {|
    (bin_shape_digest 1fd923acb2dd9c5d401ad5b08b1d40cd)
    ((sexp (1970-01-01 00:00:00.000000Z))
     (bin_io "\000\000\000\000\000\000\000\000"))
    ((sexp (2001-01-01 00:00:00.000000Z)) (bin_io "\000\000\000@\228'\205A"))
    ((sexp (2013-10-07 09:30:00.000000Z))
     (bin_io "\000\000\000\198\159\148\212A"))
    ((sexp (2017-07-28 11:57:00.000123Z)) (bin_io "\004\002\000\163\201^\214A")) |}];
;;

let span_examples =
  let units =
    [ Time.Span.nanosecond
    ; Time.Span.microsecond
    ; Time.Span.millisecond
    ; Time.Span.second
    ; Time.Span.minute
    ; Time.Span.hour
    ; Time.Span.day
    ]
  in
  let pos_and_neg_units =
    units @ List.map units ~f:Time.Span.neg
  in
  Time.Span.zero
  :: pos_and_neg_units
  @  List.map pos_and_neg_units ~f:(fun span -> Time.Span.scale span Float.pi)

let%expect_test "Time.Stable.Span.V1" =
  print_and_check_stable_type [%here] (module struct
    include Time.Stable.Span.V1

    (* [V1] does not precisely round-trip for all suffixes. So we use a comparison that
       requires accuracy up to one part in a million. *)
    let compare t1 t2 =
      let open Time.Span in
      let magnitude = max (abs t1) (abs t2) in
      let epsilon = Time.Span.( / ) magnitude 1_000_000. in
      let diff = t1 - t2 in
      if diff < neg epsilon
      then -1
      else if diff > epsilon
      then 1
      else 0
  end)
    span_examples;
  [%expect {|
    (bin_shape_digest 1fd923acb2dd9c5d401ad5b08b1d40cd)
    ((sexp   0s)
     (bin_io "\000\000\000\000\000\000\000\000"))
    ((sexp   1e-06ms)
     (bin_io "\149\214&\232\011.\017>"))
    ((sexp   0.001ms)
     (bin_io "\141\237\181\160\247\198\176>"))
    ((sexp   1ms)
     (bin_io "\252\169\241\210MbP?"))
    ((sexp   1s)
     (bin_io "\000\000\000\000\000\000\240?"))
    ((sexp   1m)
     (bin_io "\000\000\000\000\000\000N@"))
    ((sexp   1h)
     (bin_io "\000\000\000\000\000 \172@"))
    ((sexp   1d)
     (bin_io "\000\000\000\000\000\024\245@"))
    ((sexp   -1e-06ms)
     (bin_io "\149\214&\232\011.\017\190"))
    ((sexp   -0.001ms)
     (bin_io "\141\237\181\160\247\198\176\190"))
    ((sexp   -1ms)
     (bin_io "\252\169\241\210MbP\191"))
    ((sexp   -1s)
     (bin_io "\000\000\000\000\000\000\240\191"))
    ((sexp   -1m)
     (bin_io "\000\000\000\000\000\000N\192"))
    ((sexp   -1h)
     (bin_io "\000\000\000\000\000 \172\192"))
    ((sexp   -1d)
     (bin_io "\000\000\000\000\000\024\245\192"))
    ((sexp   3.14159e-06ms)
     (bin_io "\229;!po\252*>"))
    ((sexp   0.00314159ms)
     (bin_io "}t\128\211\132Z\202>"))
    ((sexp   3.14159ms)
     (bin_io "\195q\139\182e\188i?"))
    ((sexp   3.14159s)
     (bin_io "\024-DT\251!\t@"))
    ((sexp   3.14159m)
     (bin_io "F\234\255\158\219\143g@"))
    ((sexp   3.14159h)
     (bin_io "\162\235\015\229\221\022\198@"))
    ((sexp   3.14159d)
     (bin_io "\186\240\203k&\145\016A"))
    ((sexp   -3.14159e-06ms)
     (bin_io "\229;!po\252*\190"))
    ((sexp   -0.00314159ms)
     (bin_io "}t\128\211\132Z\202\190"))
    ((sexp   -3.14159ms)
     (bin_io "\195q\139\182e\188i\191"))
    ((sexp   -3.14159s)
     (bin_io "\024-DT\251!\t\192"))
    ((sexp   -3.14159m)
     (bin_io "F\234\255\158\219\143g\192"))
    ((sexp   -3.14159h)
     (bin_io "\162\235\015\229\221\022\198\192"))
    ((sexp   -3.14159d)
     (bin_io "\186\240\203k&\145\016\193")) |}];
;;

let%expect_test "Time.Stable.Span.V2" =
  print_and_check_stable_type [%here] (module Time.Stable.Span.V2)
    ~cr:Comment
    span_examples;
  [%expect {|
    (bin_shape_digest 1fd923acb2dd9c5d401ad5b08b1d40cd)
    ((sexp   0s)
     (bin_io "\000\000\000\000\000\000\000\000"))
    ((sexp   1ns)
     (bin_io "\149\214&\232\011.\017>"))
    ((sexp   1us)
     (bin_io "\141\237\181\160\247\198\176>"))
    ((sexp   1ms)
     (bin_io "\252\169\241\210MbP?"))
    ((sexp   1s)
     (bin_io "\000\000\000\000\000\000\240?"))
    ((sexp   1m)
     (bin_io "\000\000\000\000\000\000N@"))
    ((sexp   1h)
     (bin_io "\000\000\000\000\000 \172@"))
    ((sexp   1d)
     (bin_io "\000\000\000\000\000\024\245@"))
    ((sexp   -1ns)
     (bin_io "\149\214&\232\011.\017\190"))
    ((sexp   -1us)
     (bin_io "\141\237\181\160\247\198\176\190"))
    ((sexp   -1ms)
     (bin_io "\252\169\241\210MbP\191"))
    ((sexp   -1s)
     (bin_io "\000\000\000\000\000\000\240\191"))
    ((sexp   -1m)
     (bin_io "\000\000\000\000\000\000N\192"))
    ((sexp   -1h)
     (bin_io "\000\000\000\000\000 \172\192"))
    ((sexp   -1d)
     (bin_io "\000\000\000\000\000\024\245\192"))
    ((sexp   3.1415926535897931ns)
     (bin_io "\229;!po\252*>"))
    ((sexp   3.1415926535897931us)
     (bin_io "}t\128\211\132Z\202>"))
    (* require-failed: lib/core_kernel/test/src/test_time.ml:LINE:COL. *)
    ("sexp serialization failed to round-trip"
      (original       3.1415926535897931us)
      (sexp           3.1415926535897931us)
      (sexp_roundtrip 3.1415926535897931us))
    ((sexp   3.1415926535897931ms)
     (bin_io "\195q\139\182e\188i?"))
    ((sexp   3.1415926535897931s)
     (bin_io "\024-DT\251!\t@"))
    ((sexp   3.1415926535897927m)
     (bin_io "F\234\255\158\219\143g@"))
    ((sexp   3.1415926535897931h)
     (bin_io "\162\235\015\229\221\022\198@"))
    ((sexp   3.1415926535897936d)
     (bin_io "\186\240\203k&\145\016A"))
    ((sexp   -3.1415926535897931ns)
     (bin_io "\229;!po\252*\190"))
    ((sexp   -3.1415926535897931us)
     (bin_io "}t\128\211\132Z\202\190"))
    (* require-failed: lib/core_kernel/test/src/test_time.ml:LINE:COL. *)
    ("sexp serialization failed to round-trip"
      (original       -3.1415926535897931us)
      (sexp           -3.1415926535897931us)
      (sexp_roundtrip -3.1415926535897931us))
    ((sexp   -3.1415926535897931ms)
     (bin_io "\195q\139\182e\188i\191"))
    ((sexp   -3.1415926535897931s)
     (bin_io "\024-DT\251!\t\192"))
    ((sexp   -3.1415926535897927m)
     (bin_io "F\234\255\158\219\143g\192"))
    ((sexp   -3.1415926535897931h)
     (bin_io "\162\235\015\229\221\022\198\192"))
    ((sexp   -3.1415926535897936d)
     (bin_io "\186\240\203k&\145\016\193")) |}];
;;

let span_gen = Quickcheck.Generator.map Float.gen_finite ~f:Time.Span.of_sec

let%test_module "Time.Stable.Span.V3" =
  (module struct

    let span_examples =
      let factors =
        [ Float.min_positive_subnormal_value
        ; Float.min_positive_normal_value
        ; 1e-100
        ; 1e19
        ; 1e100
        ]
      in
      let magnitudes =
        List.concat_map factors ~f:(fun factor ->
          [factor; Float.pi *. factor])
        @ [ Float.max_finite_value
          ; Float.infinity
          ]
      in
      let pos_and_neg_magnitudes =
        List.concat_map magnitudes ~f:(fun magnitude ->
          [magnitude; Float.neg magnitude])
      in
      let magnitude_examples =
        List.map pos_and_neg_magnitudes ~f:Time.Span.of_sec
      in
      span_examples @ magnitude_examples

    let%expect_test "serialization tests" =
      print_and_check_stable_type [%here] (module Time.Stable.Span.V3)
        span_examples;
      [%expect {|
        (bin_shape_digest 1fd923acb2dd9c5d401ad5b08b1d40cd)
        ((sexp   0s)
         (bin_io "\000\000\000\000\000\000\000\000"))
        ((sexp   1ns)
         (bin_io "\149\214&\232\011.\017>"))
        ((sexp   1us)
         (bin_io "\141\237\181\160\247\198\176>"))
        ((sexp   1ms)
         (bin_io "\252\169\241\210MbP?"))
        ((sexp   1s)
         (bin_io "\000\000\000\000\000\000\240?"))
        ((sexp   1m)
         (bin_io "\000\000\000\000\000\000N@"))
        ((sexp   1h)
         (bin_io "\000\000\000\000\000 \172@"))
        ((sexp   1d)
         (bin_io "\000\000\000\000\000\024\245@"))
        ((sexp   -1ns)
         (bin_io "\149\214&\232\011.\017\190"))
        ((sexp   -1us)
         (bin_io "\141\237\181\160\247\198\176\190"))
        ((sexp   -1ms)
         (bin_io "\252\169\241\210MbP\191"))
        ((sexp   -1s)
         (bin_io "\000\000\000\000\000\000\240\191"))
        ((sexp   -1m)
         (bin_io "\000\000\000\000\000\000N\192"))
        ((sexp   -1h)
         (bin_io "\000\000\000\000\000 \172\192"))
        ((sexp   -1d)
         (bin_io "\000\000\000\000\000\024\245\192"))
        ((sexp   3.1415926535897931ns)
         (bin_io "\229;!po\252*>"))
        ((sexp   3.1415926535897927us4e-13ns)
         (bin_io "}t\128\211\132Z\202>"))
        ((sexp   3.1415926535897931ms)
         (bin_io "\195q\139\182e\188i?"))
        ((sexp   3.1415926535897931s)
         (bin_io "\024-DT\251!\t@"))
        ((sexp   3m8.49555921538757s)
         (bin_io "F\234\255\158\219\143g@"))
        ((sexp   3h8m29.733552923255s)
         (bin_io "\162\235\015\229\221\022\198@"))
        ((sexp   3d3h23m53.60527015815s)
         (bin_io "\186\240\203k&\145\016A"))
        ((sexp   -3.1415926535897931ns)
         (bin_io "\229;!po\252*\190"))
        ((sexp   -3.1415926535897927us4e-13ns)
         (bin_io "}t\128\211\132Z\202\190"))
        ((sexp   -3.1415926535897931ms)
         (bin_io "\195q\139\182e\188i\191"))
        ((sexp   -3.1415926535897931s)
         (bin_io "\024-DT\251!\t\192"))
        ((sexp   -3m8.49555921538757s)
         (bin_io "F\234\255\158\219\143g\192"))
        ((sexp   -3h8m29.733552923255s)
         (bin_io "\162\235\015\229\221\022\198\192"))
        ((sexp   -3d3h23m53.60527015815s)
         (bin_io "\186\240\203k&\145\016\193"))
        ((sexp   4.94065645841247e-315ns)
         (bin_io "\001\000\000\000\000\000\000\000"))
        ((sexp   -4.94065645841247e-315ns)
         (bin_io "\001\000\000\000\000\000\000\128"))
        ((sexp   1.48219693752374e-314ns)
         (bin_io "\003\000\000\000\000\000\000\000"))
        ((sexp   -1.48219693752374e-314ns)
         (bin_io "\003\000\000\000\000\000\000\128"))
        ((sexp   2.2250738585072014e-299ns)
         (bin_io "\000\000\000\000\000\000\016\000"))
        ((sexp   -2.2250738585072014e-299ns)
         (bin_io "\000\000\000\000\000\000\016\128"))
        ((sexp   6.9902756875809189e-299ns)
         (bin_io "\024-DT\251!)\000"))
        ((sexp   -6.9902756875809189e-299ns)
         (bin_io "\024-DT\251!)\128"))
        ((sexp   1e-91ns)
         (bin_io "0\005\142\228.\255++"))
        ((sexp   -1e-91ns)
         (bin_io "0\005\142\228.\255+\171"))
        ((sexp   3.1415926535897929e-91ns)
         (bin_io "\012\248;\174\023\253E+"))
        ((sexp   -3.1415926535897929e-91ns)
         (bin_io "\012\248;\174\023\253E\171"))
        ((sexp   115740740740740d17h34m)
         (bin_io "\000=\145`\228X\225C"))
        ((sexp   -115740740740740d17h34m)
         (bin_io "\000=\145`\228X\225\195"))
        ((sexp   363610260832152d)
         (bin_io "n_\197\171\188?\251C"))
        ((sexp   -363610260832152d)
         (bin_io "n_\197\171\188?\251\195"))
        ((sexp   1.1574074074074074e+95d)
         (bin_io "}\195\148%\173I\178T"))
        ((sexp   -1.1574074074074074e+95d)
         (bin_io "}\195\148%\173I\178\212"))
        ((sexp   3.63610260832152e+95d)
         (bin_io "\132\235\242\195\245\185\204T"))
        ((sexp   -3.63610260832152e+95d)
         (bin_io "\132\235\242\195\245\185\204\212"))
        ((sexp   2.0806633505350874e+303d2e+287d)
         (bin_io "\255\255\255\255\255\255\239\127"))
        ((sexp   -2.0806633505350874e+303d2e+287d)
         (bin_io "\255\255\255\255\255\255\239\255"))
        ((sexp   INFs)
         (bin_io "\000\000\000\000\000\000\240\127"))
        ((sexp   -INFs)
         (bin_io "\000\000\000\000\000\000\240\255")) |}]
    ;;

    let%expect_test "serialization tests for NaNs" [@tags "64-bits-only"] =
      print_and_check_stable_type [%here] (module Time.Stable.Span.V3)
        [Time.Span.of_sec Float.nan; Time.Span.of_sec Float.nan |> Time.Span.neg];
      [%expect {|
        (bin_shape_digest 1fd923acb2dd9c5d401ad5b08b1d40cd)
        ((sexp   NANs)
         (bin_io "\001\000\000\000\000\000\240\127"))
        ((sexp   NANs)
         (bin_io "\001\000\000\000\000\000\240\255")) |}]
    ;;

    let%expect_test "V3 accepts V1 and V2 sexp outputs" =
      let test version (module Vn : Sexpable with type t = Time.Span.t) span =
        let module V3 = Time.Stable.Span.V3 in
        let vn_sexp = Vn.sexp_of_t span in
        let vn = Vn.t_of_sexp vn_sexp in
        let v3 = V3.t_of_sexp vn_sexp in
        let vn_error = Time.Span.abs (Time.Span.( - ) vn span) in
        let v3_error = Time.Span.abs (Time.Span.( - ) v3 span) in
        require [%here] (Time.Span.( <= ) v3_error vn_error)
          ~if_false_then_print_s:
            (lazy [%message
              "V3 did not read prior version sexp at least as precisely as prior version"
                (version  : string)
                (span     : Time.Span.t)
                (vn_sexp  : Sexp.t)
                (vn       : Time.Span.t)
                (v3       : Time.Span.t)
                (vn_error : Time.Span.t)
                (v3_error : Time.Span.t)])
      in
      quickcheck [%here] span_gen ~sexp_of:Time.Span.sexp_of_t ~f:(fun span ->
        test "V1" (module Time.Stable.Span.V1) span;
        test "V2" (module Time.Stable.Span.V2) span);
      [%expect {| |}];
    ;;
  end)

let%test_module "Span.to_string/of_string" =
  (module struct
    let%expect_test "of_string unit tests" =
      let strings =
        [ "1d1ns"
        ; "-1ns1d"
        ; "1e4d1e-4ms"
        ; "3e-5ms1e4d3e-5ms"
        ; "2_400h1.000_001s"
        ]
      in
      List.iter strings ~f:(fun string ->
        print_endline (Float.to_string (Time.Span.to_sec (Time.Span.of_string string))));
      [%expect {|
        86400.000000001
        -86400.000000001
        864000000.00000012
        864000000.
        8640001.000001 |}]
    ;;

    let near_powers_of_10 =
      let powers_of_10 =
        List.map (List.range ~start:`inclusive ~-20 ~stop:`exclusive 30) ~f:(fun expt ->
          10. ** Float.of_int expt)
      in
      let powers_of_10_in_various_units =
        List.concat_map powers_of_10 ~f:(fun power_of_10 ->
          List.map Unit_of_time.all ~f:(fun unit_of_time ->
            Time.Span.scale (Time.Span.of_unit_of_time unit_of_time) power_of_10))
      in
      List.concat_map powers_of_10_in_various_units ~f:(fun power -> [
          power |> Time.Span.prev |> Time.Span.prev |> Time.Span.prev;
          power |> Time.Span.prev |> Time.Span.prev;
          power |> Time.Span.prev;
          power;
          power |> Time.Span.next;
          power |> Time.Span.next |> Time.Span.next;
          power |> Time.Span.next |> Time.Span.next |> Time.Span.next;
        ])

    let%expect_test "string round-trip is precise" =
      quickcheck [%here] span_gen
        ~sexp_of:Time.Span.sexp_of_t
        ~examples:near_powers_of_10
        ~f:(fun span ->
          let string     = Time.Span.to_string span in
          let round_trip = Time.Span.of_string string in
          require [%here]
            (Time.Span.equal round_trip span)
            ~if_false_then_print_s:
              (lazy [%message
                "string round-trip is not precise"
                  (span       : Time.Span.t)
                  (string     : string)
                  (round_trip : Time.Span.t)]));
      [%expect {| |}];
    ;;

    let%expect_test "of_string accepts underscores in between digits" =
      let open Quickcheck.Let_syntax in
      let rec with_underscores_gen = function
        | []     -> return []
        | [char] -> return [char]
        | a :: b :: rest when Char.is_digit a && Char.is_digit b ->
          let%bind tail = with_underscores_gen (b :: rest) in
          if%bind Bool.gen
          then return (a :: '_' :: tail)
          else return (a ::        tail)
        | char :: rest ->
          let%bind tail = with_underscores_gen rest in
          return (char :: tail)
      in
      let string_with_underscores_gen =
        let%bind span = span_gen in
        let string = Time.Span.to_string span in
        let%bind list_with_underscores = with_underscores_gen (String.to_list string) in
        return (String.of_char_list list_with_underscores)
      in
      quickcheck [%here] string_with_underscores_gen
        ~sexp_of:String.sexp_of_t
        ~f:(fun string_with_underscores ->
          require_does_not_raise [%here] (fun () ->
            let span = Time.Span.of_string string_with_underscores in
            let string_without_underscores = Time.Span.to_string span in
            let round_trip = Time.Span.of_string string_without_underscores in
            require_equal [%here] (module Time.Span) span round_trip
              ~if_false_then_print_s:(lazy [%message string_without_underscores]);
            let string_with_underscores_removed =
              String.filter string_with_underscores ~f:(function '_' -> false | _ -> true)
            in
            require_equal [%here] (module String)
              string_without_underscores string_with_underscores_removed
              ~if_false_then_print_s:(lazy [%sexp (span : Time.Span.t)])));
      [%expect {| |}];
    ;;

    let is_float_char = function
      | '0' .. '9' | '.' | 'e' | '+' | '-' -> true
      | _ -> false

    let min_mantissa = Float.ieee_mantissa Float.min_positive_normal_value
    let max_mantissa = Float.ieee_mantissa Float.max_finite_value
    let%expect_test "mantissa bounds" =
      printf !"%{Int63.Hex#hum} %{Int63.Hex#hum}\n" min_mantissa max_mantissa;
      (* 13x4 = 52 explicitly-represented bits of mantissa in a 64-bit float *)
      [%expect {| 0x0 0xf_ffff_ffff_ffff |}];
    ;;
    let float_gen_uniform_exponent ~min_exponent ~max_exponent =
      let open Quickcheck.Generator.Let_syntax in
      [%map_open
        let mantissa = Int63.gen_incl min_mantissa max_mantissa
        (* [Int] is big enough even on 32-bit platforms. *)
        and exponent = Int.gen_incl   min_exponent max_exponent
        and negative = Bool.gen
        in
        Float.create_ieee_exn ~negative ~exponent ~mantissa
      ]

    let bounded_span_gen ~magnitude_low ~magnitude_high =
      let min_exponent = Float.ieee_exponent (Time.Span.to_sec magnitude_low) in
      let max_exponent = Float.ieee_exponent (Time.Span.to_sec magnitude_high) in
      float_gen_uniform_exponent ~min_exponent ~max_exponent
      |> Quickcheck.Generator.map ~f:Time.Span.of_sec
      |> Quickcheck.Generator.filter ~f:(fun span ->
        let magnitude = Time.Span.abs span in
        Time.Span.(>) magnitude magnitude_low &&
        Time.Span.(<) magnitude magnitude_high)

    let test_part_magnitudes ~magnitude_low ~magnitude_high ~allow_abnormal_frac =
      let unit_of_suffix string : Unit_of_time.t =
        match string with
        | "d"  -> Day
        | "h"  -> Hour
        | "m"  -> Minute
        | "s"  -> Second
        | "ms" -> Millisecond
        | "us" -> Microsecond
        | "ns" -> Nanosecond
        | _    -> assert false
      in
      let rec parts_of_list = function
        | [] -> []
        | magnitude :: suffix :: rest ->
          (Float.of_string magnitude, unit_of_suffix suffix) :: parts_of_list rest
        | _ -> assert false
      in
      let parts_of_string string =
        let string =
          match String.chop_prefix string ~prefix:"-" with
          | Some prefix -> prefix
          | None        -> string
        in
        let magnitudes_and_units =
          String.to_list string
          |> List.group ~break:(fun a b ->
            Bool.( <> ) (is_float_char a) (is_float_char b))
          |> List.map ~f:String.of_char_list
        in
        parts_of_list magnitudes_and_units
      in
      let upper_bound unit_of_time =
        match (unit_of_time : Unit_of_time.t) with
        | Day         -> None
        | Hour        -> Some 24.
        | Minute      -> Some 60.
        | Second      -> Some 60.
        | Millisecond -> Some 1000.
        | Microsecond -> Some 1000.
        | Nanosecond  -> Some 1000.
      in
      let gen = bounded_span_gen ~magnitude_low ~magnitude_high in
      let test_count     = ref 0 in
      let abnormal_count = ref 0 in
      quickcheck [%here] gen ~sexp_of:Time.Span.sexp_of_t
        ~f:(fun span ->
          let seconds = Time.Span.to_sec span in
          let ulp = Float.one_ulp `Up seconds -. seconds in
          let string = Time.Span.to_string span in
          require [%here] (Time.Span.of_string string = span)
            ~if_false_then_print_s:
              (lazy [%message
                "span failed to round-trip string conversion"
                  (string  : string)
                  (seconds : float)]);
          let parts = parts_of_string string in
          let is_abnormal =
            (* Spans with a ULP over half a minute start to have abnormal parts like
               "60s".  This is an artifact of our [to_string] algorithm and how it uses
               smaller units of time to correct for rounding error in the larger ones;
               once the rounding error is over half the size of the previous unit, the
               results are no longer what we expect as humans.

               Since the output is still numerically correct and spans this large are
               rarely used, we tolerate the abnormality, but only in the very last
               part. Additionally, we very occasionally have remainders that are >900us,
               but we print 1 decimal place and end up printing 1000us instead of 1ms *)
            List.fold parts ~init:false ~f:(fun has_abnormal (magnitude, unit_of_time) ->
              let open Float.O in
              require [%here] (not has_abnormal)
                ~if_false_then_print_s:
                  (lazy [%message
                    "abnormal span part not last"
                      (string : string)]);
              require [%here] (magnitude > 0.)
                ~if_false_then_print_s:
                  (lazy [%message
                    "magnitude is negative"
                      (string       : string)
                      (magnitude    : float)
                      (unit_of_time : Unit_of_time.t)]);
              Option.value_map ~default:false (upper_bound unit_of_time)
                ~f:(fun upper_bound ->
                  (* we tolerate one abnormality where the very last part is exactly at
                     the upper bound *)
                  if magnitude = upper_bound
                  then true
                  else begin
                    require [%here] (magnitude < upper_bound)
                      ~if_false_then_print_s:
                        (lazy [%message
                          "magnitude out of bounds"
                            (string       : string)
                            (seconds      : float)
                            (ulp          : float)
                            (magnitude    : float)
                            (upper_bound  : float)
                            (unit_of_time : Unit_of_time.t)]);
                    false
                  end))
          in
          incr test_count;
          if is_abnormal then incr abnormal_count;
        );
      let abnormal_frac = Float.of_int !abnormal_count /. Float.of_int !test_count in
      if Float.(abnormal_frac > allow_abnormal_frac)
      then begin
        raise_s [%message
          "fraction of inputs with abnormal parts beyond tolerance"
            (magnitude_low       : Time.Span.t)
            (magnitude_high      : Time.Span.t)
            (test_count          : int ref)
            (abnormal_count      : int ref)
            (abnormal_frac       : float)
            (allow_abnormal_frac : float)]
      end

    let%expect_test "span magnitudes are within expected range" =

      (* construct and verify constants with desired ULP values *)
      let check_ulps x =
        printf "span    : %s\n" Time.Span.(to_string x);
        printf "ulp up  : %s\n" Time.Span.(to_string (next x - x));
        printf "ulp down: %s\n" Time.Span.(to_string (x - prev x))
      in
      let tenth_ms_ulp = Time.Span.of_sec (Float.ldexp 1. (53 - 14)) in
      check_ulps tenth_ms_ulp;
      [%expect {|
        span    : 6362914d12h18m8s
        ulp up  : 122.0703125us
        ulp down: 61.03515625us |}];
      let ms_ulp = Time.Span.of_sec (Float.ldexp 1. (53 - 10)) in
      check_ulps ms_ulp;
      [%expect {|
        span    : 101806632d4h50m8s
        ulp up  : 1.953125ms
        ulp down: 976.5625us |}];
      let half_min_ulp = Time.Span.of_sec (Float.ldexp 1. (53 + 4)) in
      check_ulps half_min_ulp;
      [%expect {|
        span    : 1667999861989d1h44m32s
        ulp up  : 32s
        ulp down: 16s |}];
      let two_min_ulp = Time.Span.of_sec (Float.ldexp 1. (53 + 6)) in
      check_ulps two_min_ulp;
      [%expect {|
        span    : 6671999447956d6h58m
        ulp up  : 2m8s
        ulp down: 1m4s |}];
      let quarter_hr_ulp = Time.Span.of_sec (Float.ldexp 1. (53 + 9)) in
      check_ulps quarter_hr_ulp;
      [%expect {|
        span    : 53375995583650d7h42m
        ulp up  : 17m4s
        ulp down: 8m32s |}];
      let two_hr_ulp = Time.Span.of_sec (Float.ldexp 1. (53 + 12)) in
      check_ulps two_hr_ulp;
      [%expect {|
        span    : 427007964669202d14h
        ulp up  : 2h16m32s
        ulp down: 1h8m16s |}];
      let infinity = Time.Span.of_sec Float.infinity in

      (* Test magnitudes of span parts, allowing abnormal magnitudes (like 24h or 60s) in
         the ranges where we expect them. The allowed fractions of values with abnormal
         magnitudes are set generously, so if they break in the future we've seen a
         significant change in behavior, and not just a different random seed. *)
      test_part_magnitudes
        ~magnitude_low:Time.Span.zero
        ~magnitude_high:tenth_ms_ulp
        ~allow_abnormal_frac:0.;
      test_part_magnitudes
        ~magnitude_low:tenth_ms_ulp
        ~magnitude_high:ms_ulp
        ~allow_abnormal_frac:0.00002;
      test_part_magnitudes
        ~magnitude_low:ms_ulp
        ~magnitude_high:half_min_ulp
        ~allow_abnormal_frac:0.;
      test_part_magnitudes
        ~magnitude_low:half_min_ulp
        ~magnitude_high:two_min_ulp
        ~allow_abnormal_frac:0.006;
      test_part_magnitudes
        ~magnitude_low:two_min_ulp
        ~magnitude_high:quarter_hr_ulp
        ~allow_abnormal_frac:0.;
      test_part_magnitudes
        ~magnitude_low:quarter_hr_ulp
        ~magnitude_high:two_hr_ulp
        ~allow_abnormal_frac:0.02;
      test_part_magnitudes
        ~magnitude_low:two_hr_ulp
        ~magnitude_high:infinity
        ~allow_abnormal_frac:0.;

      (* A few explicit examples of abnormal parts *)
      printf "%s\n" (Time.Span.to_string (Time.Span.of_sec 3004250081760.001));
      printf "%s\n" (Time.Span.to_string (Time.Span.of_sec 4.5514503734113075E+17));
      printf "%s\n" (Time.Span.to_string (Time.Span.of_sec 1.8863400560491495E+19));
      [%expect {|
        34771412d23h36m1e+03us
        5267882376633d10h60m
        218326395376058d24h |}];
    ;;

    let%expect_test "unit appearing twice" =
      let split string =
        String.to_list string
        |> List.group ~break:(fun a b ->
          Bool.( <> ) (is_float_char a) (is_float_char b))
        |> List.map ~f:String.of_char_list
      in
      let test ?cr suffix =
        quickcheck [%here] ?cr span_gen ~sexp_of:Time.Span.sexp_of_t ~f:(fun span ->
          let string = Time.Span.to_string span in
          let strings = split string in
          require [%here] ?cr (List.count strings ~f:(String.equal suffix) <= 1))
      in
      (* For very large values (ULP >> 1s), we can see days appear twice, once very large
         and once smaller by several orders of magnitude. Note that the specific example
         produced here is nondeterministic and may change. *)
      test ~cr:Comment "d";
      [%expect {|
        (* require-failed: lib/core_kernel/test/src/test_time.ml:LINE:COL. *)
        (* require-failed: lib/core_kernel/test/src/test_time.ml:LINE:COL. *)
        ("random input"
          (value -2.1695734240829744e+44d3e+28d)
          (error "printed 1 CRs for Quickcheck-generated input")) |}];
      test "h";
      [%expect {| |}];
      test "m";
      [%expect {| |}];
      test "s";
      [%expect {| |}];
      test "ms";
      [%expect {| |}];
      test "us";
      [%expect {| |}];
      (* For some times measured in ns, we can see ns appear twice, with the second one
         smaller than the first by several orders of magnitude. The specific example
         produced here is nondeterministic and may change. *)
      test ~cr:Comment "ns";
      [%expect {|
        (* require-failed: lib/core_kernel/test/src/test_time.ml:LINE:COL. *)
        (* require-failed: lib/core_kernel/test/src/test_time.ml:LINE:COL. *)
        ("random input"
          (value -3.70807784925899e-59ns4e-75ns)
          (error "printed 1 CRs for Quickcheck-generated input")) |}];
    ;;
  end)

let%expect_test "Span.to_parts + Span.create" =
  List.iter span_examples ~f:(fun span ->
    let parts = Time.Span.to_parts span in
    Core_kernel.print_s [%sexp ((span, parts) : Time.Span.t * Time.Span.Parts.t)];
    let { sign; hr; min; sec; ms; us; ns } : Time.Span.Parts.t = parts in
    let round_trip = Time.Span.create ~sign ~hr ~min ~sec ~ms ~us ~ns () in
    let abs_diff = Time.Span.abs (Time.Span.( - ) span round_trip) in
    require [%here] (Time.Span.( < ) abs_diff Time.Span.nanosecond)
      ~if_false_then_print_s:
        (lazy [%message
          "round-trip failed"
            (span       : Time.Span.t)
            (parts      : Time.Span.Parts.t)
            (round_trip : Time.Span.t)
            (abs_diff   : Time.Span.t)]));
  [%expect {|
    (0s ((sign Zero) (hr 0) (min 0) (sec 0) (ms 0) (us 0) (ns 0)))
    (1ns ((sign Pos) (hr 0) (min 0) (sec 0) (ms 0) (us 0) (ns 1)))
    (1us ((sign Pos) (hr 0) (min 0) (sec 0) (ms 0) (us 1) (ns 0)))
    (1ms ((sign Pos) (hr 0) (min 0) (sec 0) (ms 1) (us 0) (ns 0)))
    (1s ((sign Pos) (hr 0) (min 0) (sec 1) (ms 0) (us 0) (ns 0)))
    (1m ((sign Pos) (hr 0) (min 1) (sec 0) (ms 0) (us 0) (ns 0)))
    (1h ((sign Pos) (hr 1) (min 0) (sec 0) (ms 0) (us 0) (ns 0)))
    (1d ((sign Pos) (hr 24) (min 0) (sec 0) (ms 0) (us 0) (ns 0)))
    (-1ns ((sign Neg) (hr 0) (min 0) (sec 0) (ms 0) (us 0) (ns 1)))
    (-1us ((sign Neg) (hr 0) (min 0) (sec 0) (ms 0) (us 1) (ns 0)))
    (-1ms ((sign Neg) (hr 0) (min 0) (sec 0) (ms 1) (us 0) (ns 0)))
    (-1s ((sign Neg) (hr 0) (min 0) (sec 1) (ms 0) (us 0) (ns 0)))
    (-1m ((sign Neg) (hr 0) (min 1) (sec 0) (ms 0) (us 0) (ns 0)))
    (-1h ((sign Neg) (hr 1) (min 0) (sec 0) (ms 0) (us 0) (ns 0)))
    (-1d ((sign Neg) (hr 24) (min 0) (sec 0) (ms 0) (us 0) (ns 0)))
    (3.1415926535897931ns
     ((sign Pos) (hr 0) (min 0) (sec 0) (ms 0) (us 0) (ns 3)))
    (3.1415926535897927us4e-13ns
     ((sign Pos) (hr 0) (min 0) (sec 0) (ms 0) (us 3) (ns 142)))
    (3.1415926535897931ms
     ((sign Pos) (hr 0) (min 0) (sec 0) (ms 3) (us 141) (ns 593)))
    (3.1415926535897931s
     ((sign Pos) (hr 0) (min 0) (sec 3) (ms 141) (us 592) (ns 654)))
    (3m8.49555921538757s
     ((sign Pos) (hr 0) (min 3) (sec 8) (ms 495) (us 559) (ns 215)))
    (3h8m29.733552923255s
     ((sign Pos) (hr 3) (min 8) (sec 29) (ms 733) (us 552) (ns 923)))
    (3d3h23m53.60527015815s
     ((sign Pos) (hr 75) (min 23) (sec 53) (ms 605) (us 270) (ns 158)))
    (-3.1415926535897931ns
     ((sign Neg) (hr 0) (min 0) (sec 0) (ms 0) (us 0) (ns 3)))
    (-3.1415926535897927us4e-13ns
     ((sign Neg) (hr 0) (min 0) (sec 0) (ms 0) (us 3) (ns 142)))
    (-3.1415926535897931ms
     ((sign Neg) (hr 0) (min 0) (sec 0) (ms 3) (us 141) (ns 593)))
    (-3.1415926535897931s
     ((sign Neg) (hr 0) (min 0) (sec 3) (ms 141) (us 592) (ns 654)))
    (-3m8.49555921538757s
     ((sign Neg) (hr 0) (min 3) (sec 8) (ms 495) (us 559) (ns 215)))
    (-3h8m29.733552923255s
     ((sign Neg) (hr 3) (min 8) (sec 29) (ms 733) (us 552) (ns 923)))
    (-3d3h23m53.60527015815s
     ((sign Neg) (hr 75) (min 23) (sec 53) (ms 605) (us 270) (ns 158))) |}];
;;

let ofday_examples =
  List.filter_map span_examples ~f:(fun span ->
    if Time.Span.( >= ) span Time.Span.zero
    && Time.Span.( <  ) span Time.Span.day
    then Some (Time.Ofday.of_span_since_start_of_day_exn span)
    else None)

let%expect_test "Ofday.to_parts + Ofday.create" =
  List.iter ofday_examples ~f:(fun ofday ->
    let parts = Time.Ofday.to_parts ofday in
    Core_kernel.print_s [%sexp ((ofday, parts) : Time.Ofday.t * Time.Span.Parts.t)];
    let { sign = _; hr; min; sec; ms; us; ns } : Time.Span.Parts.t = parts in
    let round_trip = Time.Ofday.create ~hr ~min ~sec ~ms ~us ~ns () in
    let abs_diff = Time.Span.abs (Time.Ofday.diff ofday round_trip) in
    require [%here] (Time.Span.( < ) abs_diff Time.Span.nanosecond)
      ~if_false_then_print_s:
        (lazy [%message
          "round-trip failed"
            (ofday      : Time.Ofday.t)
            (parts      : Time.Span.Parts.t)
            (round_trip : Time.Ofday.t)
            (abs_diff   : Time.Span.t)]));
  [%expect {|
    (00:00:00.000000 ((sign Zero) (hr 0) (min 0) (sec 0) (ms 0) (us 0) (ns 0)))
    (00:00:00.000000 ((sign Pos) (hr 0) (min 0) (sec 0) (ms 0) (us 0) (ns 1)))
    (00:00:00.000001 ((sign Pos) (hr 0) (min 0) (sec 0) (ms 0) (us 1) (ns 0)))
    (00:00:00.001000 ((sign Pos) (hr 0) (min 0) (sec 0) (ms 1) (us 0) (ns 0)))
    (00:00:01.000000 ((sign Pos) (hr 0) (min 0) (sec 1) (ms 0) (us 0) (ns 0)))
    (00:01:00.000000 ((sign Pos) (hr 0) (min 1) (sec 0) (ms 0) (us 0) (ns 0)))
    (01:00:00.000000 ((sign Pos) (hr 1) (min 0) (sec 0) (ms 0) (us 0) (ns 0)))
    (00:00:00.000000 ((sign Pos) (hr 0) (min 0) (sec 0) (ms 0) (us 0) (ns 3)))
    (00:00:00.000003 ((sign Pos) (hr 0) (min 0) (sec 0) (ms 0) (us 3) (ns 142)))
    (00:00:00.003142
     ((sign Pos) (hr 0) (min 0) (sec 0) (ms 3) (us 141) (ns 593)))
    (00:00:03.141593
     ((sign Pos) (hr 0) (min 0) (sec 3) (ms 141) (us 592) (ns 654)))
    (00:03:08.495559
     ((sign Pos) (hr 0) (min 3) (sec 8) (ms 495) (us 559) (ns 215)))
    (03:08:29.733553
     ((sign Pos) (hr 3) (min 8) (sec 29) (ms 733) (us 552) (ns 923))) |}];
;;

let%expect_test "time zone offset parsing" =
  let test string =
    print_endline (Time.to_string (Time.of_string string));
  in
  test "2000-01-01 12:34:56.789012-00:00";
  test "2000-01-01 12:34:56.789012-0:00";
  test "2000-01-01 12:34:56.789012-00";
  test "2000-01-01 12:34:56.789012-0";
  [%expect {|
    2000-01-01 12:34:56.789012Z
    2000-01-01 12:34:56.789012Z
    2000-01-01 12:34:56.789012Z
    2000-01-01 12:34:56.789012Z |}];
  test "2000-01-01 12:34:56.789012-05:00";
  test "2000-01-01 12:34:56.789012-5:00";
  test "2000-01-01 12:34:56.789012-05";
  test "2000-01-01 12:34:56.789012-5";
  [%expect {|
    2000-01-01 17:34:56.789012Z
    2000-01-01 17:34:56.789012Z
    2000-01-01 17:34:56.789012Z
    2000-01-01 17:34:56.789012Z |}];
  test "2000-01-01 12:34:56.789012-23:00";
  test "2000-01-01 12:34:56.789012-23";
  [%expect {|
    2000-01-02 11:34:56.789012Z
    2000-01-02 11:34:56.789012Z |}];
  test "2000-01-01 12:34:56.789012-24:00";
  test "2000-01-01 12:34:56.789012-24";
  [%expect {|
    2000-01-02 12:34:56.789012Z
    2000-01-02 12:34:56.789012Z |}];
;;

let%expect_test "time zone invalid offset parsing" =
  let test here string =
    require_does_raise here (fun () ->
      Time.of_string string)
  in
  test [%here] "2000-01-01 12:34:56.789012-0:";
  test [%here] "2000-01-01 12:34:56.789012-00:";
  test [%here] "2000-01-01 12:34:56.789012-0:0";
  test [%here] "2000-01-01 12:34:56.789012-00:0";
  test [%here] "2000-01-01 12:34:56.789012-:";
  test [%here] "2000-01-01 12:34:56.789012-:00";
  test [%here] "2000-01-01 12:34:56.789012-";
  [%expect {|
    (time.ml.Make.Time_of_string
     "2000-01-01 12:34:56.789012-0:"
     ("Time.Ofday: invalid string"
      0:
      "expected colon or am/pm suffix with optional space after minutes"))
    (time.ml.Make.Time_of_string
     "2000-01-01 12:34:56.789012-00:"
     ("Time.Ofday: invalid string"
      00:
      "expected colon or am/pm suffix with optional space after minutes"))
    (time.ml.Make.Time_of_string
     "2000-01-01 12:34:56.789012-0:0"
     ("Time.Ofday: invalid string"
      0:0
      "expected colon or am/pm suffix with optional space after minutes"))
    (time.ml.Make.Time_of_string
     "2000-01-01 12:34:56.789012-00:0"
     ("Time.Ofday: invalid string"
      00:0
      "expected colon or am/pm suffix with optional space after minutes"))
    (time.ml.Make.Time_of_string
     "2000-01-01 12:34:56.789012-:"
     (Invalid_argument "index out of bounds"))
    (time.ml.Make.Time_of_string
     "2000-01-01 12:34:56.789012-:00"
     (Failure "Char.get_digit_exn ':': not a digit"))
    (time.ml.Make.Time_of_string
     "2000-01-01 12:34:56.789012-"
     (Invalid_argument "index out of bounds")) |}];
  test [%here] "2000-01-01 12:34:56.789012-25:00";
  test [%here] "2000-01-01 12:34:56.789012-25";
  [%expect {|
    (time.ml.Make.Time_of_string
     "2000-01-01 12:34:56.789012-25:00"
     ("Time.Ofday: invalid string" 25:00 "hours out of bounds"))
    (time.ml.Make.Time_of_string
     "2000-01-01 12:34:56.789012-25"
     ("Time.Ofday: invalid string" 25:00 "hours out of bounds")) |}];
  test [%here] "2000-01-01 12:34:56.789012--1:00";
  test [%here] "2000-01-01 12:34:56.789012--1";
  [%expect {|
    (time.ml.Make.Time_of_string
     "2000-01-01 12:34:56.789012--1:00"
     (Failure "Char.get_digit_exn '-': not a digit"))
    (time.ml.Make.Time_of_string
     "2000-01-01 12:34:56.789012--1"
     (Invalid_argument "index out of bounds")) |}];
;;

let%expect_test "of_string_iso8601_extended" =
  let success string =
    require_does_not_raise [%here] (fun () ->
      printf "%s <-- %s\n"
        (Time.Ofday.to_string (Time.Ofday.of_string_iso8601_extended string))
        string)
  in
  List.iter ~f:success [
    (* normal times *)
    "12";
    "12:34";
    "12:34:56";
    "12:34:56.789";
    "12:34:56.789123";
    "12:34:56.789123456";
    (* lower boundary case *)
    "00";
    "00:00";
    "00:00:00";
    "00:00:00.000";
    "00:00:00.000000";
    "00:00:00.000000000";
    (* upper boundary case *)
    "23";
    "23:59";
    "23:59:59";
    "23:59:59.999";
    "23:59:59.999999";
    "23:59:59.999999999";
    (* midnight tomorrow *)
    "24";
    "24:00";
    "24:00:00";
    "24:00:00.000";
    "24:00:00.000000";
    "24:00:00.000000000";
    (* leap second *)
    "12:59:60";
    "12:59:60.789";
    "12:59:60.789123";
    "12:59:60.789123456";
  ];
  [%expect {|
    12:00:00.000000 <-- 12
    12:34:00.000000 <-- 12:34
    12:34:56.000000 <-- 12:34:56
    12:34:56.789000 <-- 12:34:56.789
    12:34:56.789123 <-- 12:34:56.789123
    12:34:56.789123 <-- 12:34:56.789123456
    00:00:00.000000 <-- 00
    00:00:00.000000 <-- 00:00
    00:00:00.000000 <-- 00:00:00
    00:00:00.000000 <-- 00:00:00.000
    00:00:00.000000 <-- 00:00:00.000000
    00:00:00.000000 <-- 00:00:00.000000000
    23:00:00.000000 <-- 23
    23:59:00.000000 <-- 23:59
    23:59:59.000000 <-- 23:59:59
    23:59:59.999000 <-- 23:59:59.999
    23:59:59.999999 <-- 23:59:59.999999
    24:00:00.000000 <-- 23:59:59.999999999
    24:00:00.000000 <-- 24
    24:00:00.000000 <-- 24:00
    24:00:00.000000 <-- 24:00:00
    24:00:00.000000 <-- 24:00:00.000
    24:00:00.000000 <-- 24:00:00.000000
    24:00:00.000000 <-- 24:00:00.000000000
    13:00:00.000000 <-- 12:59:60
    13:00:00.000000 <-- 12:59:60.789
    13:00:00.000000 <-- 12:59:60.789123
    13:00:00.000000 <-- 12:59:60.789123456 |}];
  let failure string =
    match Time.Ofday.of_string_iso8601_extended string with
    | exception (Invalid_argument message) -> print_endline message
    | exception exn ->
      (* This is not necessarily an error, we may just need to update this test. *)
      print_cr [%here] [%message "unexpected exception" (exn : exn)]
    | ofday ->
      print_cr [%here] [%message "did not raise" (string : string) (ofday : Time.Ofday.t)]
  in
  List.iter ~f:failure [
    (* bad syntax *)
    "";
    "1";
    "123";
    ":";
    "12:";
    "1:23";
    "12:3";
    "12:345";
    "12:34:";
    "12:34:5";
    (* numerical bounds *)
    "25:00";
    "00:60";
    "00:59:61";
  ];
  [%expect {|
    Ofday.of_string_iso8601_extended(): (Failure "len < 2")
    Ofday.of_string_iso8601_extended(1): (Failure "len < 2")
    Ofday.of_string_iso8601_extended(123): (Failure "2 < len < 5")
    Ofday.of_string_iso8601_extended(:): (Failure "len < 2")
    Ofday.of_string_iso8601_extended(12:): (Failure "2 < len < 5")
    Ofday.of_string_iso8601_extended(1:23): (Failure "Char.get_digit_exn ':': not a digit")
    Ofday.of_string_iso8601_extended(12:3): (Failure "2 < len < 5")
    Ofday.of_string_iso8601_extended(12:345): (Failure "5 < len < 8")
    Ofday.of_string_iso8601_extended(12:34:): (Failure "5 < len < 8")
    Ofday.of_string_iso8601_extended(12:34:5): (Failure "5 < len < 8")
    Ofday.of_string_iso8601_extended(25:00): (Failure "hour > 24")
    Ofday.of_string_iso8601_extended(00:60): (Failure "minute > 60")
    Ofday.of_string_iso8601_extended(00:59:61): (Failure "invalid second: 61") |}];
;;
