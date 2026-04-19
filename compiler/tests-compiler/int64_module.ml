(* [Int64] arithmetic + conversions. Int64 values flow as boxed
   [java.lang.Long]; primitives unbox to JVM [long], operate, and
   re-box.

   The correctness value: without this, stdlib's [infinity] / [nan]
   / [max_float] / [min_float] initialise to 0.0 (Gv_int64 was
   truncated to 32 bits), and any [Int64.shift_left] past 32 bits
   silently wrapped. *)

open Util

let%expect_test "Int64 literals preserve full 64-bit value" =
  compile_and_run
    {| let () = Printf.printf "%Ld\n" 1L
       let () = Printf.printf "%Ld\n" (Int64.shift_left 1L 40)
       let () = Printf.printf "%Ld\n" Int64.max_int
       let () = Printf.printf "%Ld\n" Int64.min_int |};
  [%expect {|
    1
    1099511627776
    9223372036854775807
    -9223372036854775808 |}]

let%expect_test "Int64 arithmetic" =
  compile_and_run
    {| let () = Printf.printf "%Ld\n" (Int64.add 42L 1L)
       let () = Printf.printf "%Ld\n" (Int64.sub 100L 7L)
       let () = Printf.printf "%Ld\n" (Int64.mul 1_000_000L 1_000_000L)
       let () = Printf.printf "%Ld\n" (Int64.div 100L 7L)
       let () = Printf.printf "%Ld\n" (Int64.rem 100L 7L)
       let () = Printf.printf "%Ld\n" (Int64.neg 42L) |};
  [%expect {|
    43
    93
    1000000000000
    14
    2
    -42 |}]

let%expect_test "Int64 bitwise ops" =
  compile_and_run
    {| let () = Printf.printf "%Ld\n" (Int64.logand 0xFF00FFL 0x00FFFFL)
       let () = Printf.printf "%Ld\n" (Int64.logor 0xFF00L 0x00FFL)
       let () = Printf.printf "%Ld\n" (Int64.logxor 0xFFFFL 0x00FFL)
       let () = Printf.printf "%Ld\n" (Int64.shift_left 1L 40)
       let () = Printf.printf "%Ld\n" (Int64.shift_right (-1L) 1)
       let () = Printf.printf "%Ld\n" (Int64.shift_right_logical (-1L) 1) |};
  [%expect {|
    255
    65535
    65280
    1099511627776
    -1
    9223372036854775807 |}]

let%expect_test "Int64 conversions int/float round-trip" =
  compile_and_run
    {| let () = Printf.printf "%d\n" (Int64.to_int 42L)
       let () = Printf.printf "%Ld\n" (Int64.of_int 42)
       let () = Printf.printf "%f\n" (Int64.to_float 1L)
       let () = Printf.printf "%Ld\n" (Int64.of_float 42.9) |};
  [%expect {|
    42
    42
    1.000000
    42 |}]

let%expect_test "Stdlib float constants from Int64 bit patterns" =
  compile_and_run
    {| let () = Printf.printf "inf=%f\n" infinity
       let () = Printf.printf "neg_inf=%f\n" neg_infinity
       let () = Printf.printf "max_float=%e\n" max_float |};
  [%expect {|
    inf=Infinity
    neg_inf=-Infinity
    max_float=1.797693e+308 |}]
