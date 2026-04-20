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
    [warning] <closure> ocaml_fn_667 oversized after split (88231 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_667 (88231 bytes)
    1
    1099511627776
    9223372036854775807
    -9223372036854775808
    |}]

let%expect_test "Int64 arithmetic" =
  compile_and_run
    {| let () = Printf.printf "%Ld\n" (Int64.add 42L 1L)
       let () = Printf.printf "%Ld\n" (Int64.sub 100L 7L)
       let () = Printf.printf "%Ld\n" (Int64.mul 1_000_000L 1_000_000L)
       let () = Printf.printf "%Ld\n" (Int64.div 100L 7L)
       let () = Printf.printf "%Ld\n" (Int64.rem 100L 7L)
       let () = Printf.printf "%Ld\n" (Int64.neg 42L) |};
  [%expect {|
    [warning] <closure> ocaml_fn_650 oversized after split (88230 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_650 (88230 bytes)
    43
    93
    1000000000000
    14
    2
    -42
    |}]

let%expect_test "Int64 bitwise ops" =
  compile_and_run
    {| let () = Printf.printf "%Ld\n" (Int64.logand 0xFF00FFL 0x00FFFFL)
       let () = Printf.printf "%Ld\n" (Int64.logor 0xFF00L 0x00FFL)
       let () = Printf.printf "%Ld\n" (Int64.logxor 0xFFFFL 0x00FFL)
       let () = Printf.printf "%Ld\n" (Int64.shift_left 1L 40)
       let () = Printf.printf "%Ld\n" (Int64.shift_right (-1L) 1)
       let () = Printf.printf "%Ld\n" (Int64.shift_right_logical (-1L) 1) |};
  [%expect {|
    [warning] <closure> ocaml_fn_650 oversized after split (88230 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_650 (88230 bytes)
    255
    65535
    65280
    1099511627776
    -1
    9223372036854775807
    |}]

let%expect_test "Int64 conversions int/float round-trip" =
  compile_and_run
    {| let () = Printf.printf "%d\n" (Int64.to_int 42L)
       let () = Printf.printf "%Ld\n" (Int64.of_int 42)
       let () = Printf.printf "%f\n" (Int64.to_float 1L)
       let () = Printf.printf "%Ld\n" (Int64.of_float 42.9) |};
  [%expect {|
    [warning] <closure> ocaml_fn_667 oversized after split (88231 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_667 (88231 bytes)
    42
    42
    1.000000
    42
    |}]

let%expect_test "Stdlib float constants from Int64 bit patterns" =
  compile_and_run
    {| let () = Printf.printf "inf=%f\n" infinity
       let () = Printf.printf "neg_inf=%f\n" neg_infinity
       let () = Printf.printf "max_float=%e\n" max_float |};
  [%expect {|
    [warning] <closure> ocaml_fn_650 oversized after split (88230 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_650 (88230 bytes)
    inf=Infinity
    neg_inf=-Infinity
    max_float=1.797693e+308
    |}]

let%expect_test "Int64.equal on equal values compares by content" =
  (* Regression: [Compare.equal] didn't dispatch [Long], so boxed
     [Int64] values — including [Int64.bits_of_float] output — used
     the [return 0] fallthrough and always compared unequal. Base's
     float0.ml's [is_x_minus_one_exact] depended on it and tripped
     an assert during Stdlib init, blocking large-program bytecode tests. *)
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let a = Int64.bits_of_float 123.456 in
         let b = Int64.bits_of_float 123.456 in
         caml_java_print_int (if Int64.equal a b then 1 else 0);
         let c = Int64.bits_of_float (-. (2. ** 62.)) in
         let d = Int64.bits_of_float ((-. (2. ** 62.)) -. 1.) in
         caml_java_print_int (if Int64.equal c d then 1 else 0);
         let e = 4000000000L in
         let f = 4000000000L in
         caml_java_print_int (if Int64.equal e f then 1 else 0);
         caml_java_print_int (if Int64.compare e f = 0 then 1 else 0) |};
  [%expect {|
    1
    1
    1
    1 |}]
