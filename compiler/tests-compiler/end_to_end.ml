open Util

let%expect_test "hello world via bytecode" =
  compile_and_run_bytecode {| print_endline "hello world" |};
  [%expect {| hello world |}]

let%expect_test "arithmetic via bytecode" =
  compile_and_run_bytecode {| print_int (1 + 2); print_newline () |};
  [%expect {| 3 |}]

let%expect_test "string concatenation via bytecode" =
  compile_and_run_bytecode {| print_endline ("foo" ^ "bar") |};
  [%expect {| foobar |}]

let%expect_test "list operations via bytecode" =
  compile_and_run_bytecode
    {| List.iter (fun x -> Printf.printf "%d " x) [1; 2; 3]; print_newline () |};
  [%expect {| 1 2 3 |}]

let%expect_test "hello via custom primitive compiled to JVM" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () = caml_java_print_endline "hello" |};
  [%expect {| hello |}]

let%expect_test "int literal via custom primitive" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int 42 |};
  [%expect {| 42 |}]

let%expect_test "int arithmetic via custom primitive" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int (1 + 2) |};
  [%expect {| 3 |}]

let%expect_test "mixing int and string primitives" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () = caml_java_print_endline "answer:"
       let () = caml_java_print_int (40 + 2) |};
  [%expect {|
    answer:
    42 |}]

let%expect_test "chained int arithmetic" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int (10 + 20 + 3)
       let () = caml_java_print_int (5 * 6)
       let () = caml_java_print_int (100 - 58) |};
  [%expect {|
    33
    30
    42 |}]

let%expect_test "if/else with int comparison" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         if 0 < 1 then caml_java_print_int 1
         else caml_java_print_int 2 |};
  [%expect {| 1 |}]

let%expect_test "if/else taking the else branch" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         if 5 < 3 then caml_java_print_int 100
         else caml_java_print_int 200 |};
  [%expect {| 200 |}]

let%expect_test "if/else with arithmetic in branches" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         if 2 * 3 = 6 then caml_java_print_int (10 + 1)
         else caml_java_print_int (10 - 1) |};
  [%expect {| 11 |}]

let%expect_test "if/else with string branches" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () =
         if 1 = 1 then caml_java_print_endline "yes"
         else caml_java_print_endline "no" |};
  [%expect {| yes |}]

let%expect_test "single let-binding" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 10 in
         caml_java_print_int (x + 5) |};
  [%expect {| 15 |}]

let%expect_test "nested let-bindings" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 10 in
         let y = 20 in
         caml_java_print_int (x + y) |};
  [%expect {| 30 |}]

let%expect_test "let + dynamic comparison" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 10 in
         if x < 5 then caml_java_print_int x
         else caml_java_print_int (x + 1) |};
  [%expect {| 11 |}]

let%expect_test "let + subtraction" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let a = 100 in
         let b = 58 in
         caml_java_print_int (a - b) |};
  [%expect {| 42 |}]

let%expect_test "min of two let bindings" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 5 in
         let y = 10 in
         if x < y then caml_java_print_int x
         else caml_java_print_int y |};
  [%expect {| 5 |}]

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

let%expect_test "local ref with := and !" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let r = ref 5 in
         caml_java_print_int !r;
         r := 10;
         caml_java_print_int !r;
         r := !r + 7;
         caml_java_print_int !r |};
  [%expect {|
    5
    10
    17 |}]

let%expect_test "ref captured in a closure (counter)" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let counter = ref 0 in
         let bump () = counter := !counter + 1 in
         bump (); bump (); bump (); bump ();
         caml_java_print_int !counter |};
  [%expect {| 4 |}]

let%expect_test "incr/decr on a captured ref" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let r = ref 100 in
         let inc () = incr r in
         let dec () = decr r in
         inc (); inc (); inc (); dec ();
         caml_java_print_int !r |};
  [%expect {| 102 |}]
