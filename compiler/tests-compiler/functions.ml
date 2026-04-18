open Util

let%expect_test "recursive fibonacci" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec fib n = if n < 2 then n else fib (n - 1) + fib (n - 2)
       let () = caml_java_print_int (fib 10) |};
  [%expect {| 55 |}]

let%expect_test "fib of small values" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec fib n = if n < 2 then n else fib (n - 1) + fib (n - 2)
       let () =
         caml_java_print_int (fib 0);
         caml_java_print_int (fib 1);
         caml_java_print_int (fib 5);
         caml_java_print_int (fib 15) |};
  [%expect {|
    0
    1
    5
    610 |}]

let%expect_test "non-recursive two-arg function" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let add a b = a + b
       let () = caml_java_print_int (add 3 5) |};
  [%expect {| 8 |}]

let%expect_test "non-recursive three-arg function" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let sum3 a b c = a + b + c
       let () = caml_java_print_int (sum3 10 20 30) |};
  [%expect {| 60 |}]

let%expect_test "recursive gcd" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec gcd a b = if b = 0 then a else gcd b (a - b * (a / b))
       let () = caml_java_print_int (gcd 48 18) |};
  [%expect {| 6 |}]

let%expect_test "recursive power" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec pow base n = if n = 0 then 1 else base * pow base (n - 1)
       let () = caml_java_print_int (pow 2 10) |};
  [%expect {| 1024 |}]

let%expect_test "closure with a single capture" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 42 in
         let f y = x + y in
         caml_java_print_int (f 3);
         caml_java_print_int (f 100) |};
  [%expect {|
    45
    142 |}]

let%expect_test "recursive closure with a capture" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 42 in
         let rec f n = if n = 0 then x else f (n - 1) + x in
         caml_java_print_int (f 5) |};
  [%expect {| 252 |}]

let%expect_test "closure with multiple captures" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let a = 3 in
         let b = 7 in
         let c = 11 in
         let f n = a * n + b * n + c * n in
         caml_java_print_int (f 2);
         caml_java_print_int (f 10) |};
  [%expect {|
    42
    210 |}]

