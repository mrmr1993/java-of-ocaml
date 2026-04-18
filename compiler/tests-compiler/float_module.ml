open Util

let%expect_test "float arithmetic + literals" =
  compile_and_run
    {| external caml_java_print_float : float -> unit = "caml_java_print_float"
       let () =
         caml_java_print_float (1.5 +. 2.25);
         caml_java_print_float (5.0 -. 1.5);
         caml_java_print_float (2.0 *. 3.0);
         caml_java_print_float (10.0 /. 4.0);
         caml_java_print_float (-. 3.14);
         caml_java_print_float (Float.abs (-2.5)) |};
  [%expect {|
    3.75
    3.5
    6.0
    2.5
    -3.14
    2.5 |}]

let%expect_test "float comparisons via type-annotated less" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let less (a : float) (b : float) = a < b
       let leq (a : float) (b : float) = a <= b
       let equal (a : float) (b : float) = a = b
       let () =
         caml_java_print_int (if less 1.0 2.0 then 1 else 0);
         caml_java_print_int (if less 2.0 1.0 then 1 else 0);
         caml_java_print_int (if less 2.0 2.0 then 1 else 0);
         caml_java_print_int (if leq 2.0 2.0 then 1 else 0);
         caml_java_print_int (if equal 2.0 2.0 then 1 else 0) |};
  [%expect {|
    1
    0
    0
    1
    1 |}]

let%expect_test "NaN-safe float comparisons" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let less (a : float) (b : float) = a < b
       let leq (a : float) (b : float) = a <= b
       let equal (a : float) (b : float) = a = b
       let neq (a : float) (b : float) = a <> b
       (* [Stdlib.nan] lives in the Stdlib module record, which we can't
          materialise yet — construct a NaN inline instead. *)
       let nan = 0.0 /. 0.0
       let () =
         caml_java_print_int (if less nan 1.0 then 1 else 0);
         caml_java_print_int (if less 1.0 nan then 1 else 0);
         caml_java_print_int (if leq nan 1.0 then 1 else 0);
         caml_java_print_int (if equal nan nan then 1 else 0);
         caml_java_print_int (if neq nan nan then 1 else 0) |};
  [%expect {|
    0
    0
    0
    0
    1 |}]

let%expect_test "int-float conversions" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_float : float -> unit = "caml_java_print_float"
       let () =
         caml_java_print_int (int_of_float 3.7);
         caml_java_print_int (int_of_float (-. 3.7));
         caml_java_print_float (float_of_int 42);
         caml_java_print_float (float_of_int (-7)) |};
  [%expect {|
    3
    -3
    42.0
    -7.0 |}]

let%expect_test "float flows through a closure" =
  compile_and_run
    {| external caml_java_print_float : float -> unit = "caml_java_print_float"
       let mk_adder (n : float) = fun (x : float) -> x +. n
       let () =
         let add10 = mk_adder 10.0 in
         caml_java_print_float (add10 3.5);
         caml_java_print_float (add10 (-. 2.0)) |};
  [%expect {|
    13.5
    8.0 |}]
