open Util

let%expect_test "constant tuple destructured" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let t = (10, 20, 30) in
         let (a, b, c) = t in
         caml_java_print_int (a + b + c) |};
  [%expect {| 60 |}]

let%expect_test "dynamic tuple from let bindings" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 10 in
         let t = (x, x + 5, x * 2) in
         let (a, b, c) = t in
         caml_java_print_int (a + b + c) |};
  [%expect {| 45 |}]

let%expect_test "record with multiple fields" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type point = { x : int; y : int }
       let () =
         let p = { x = 3; y = 4 } in
         caml_java_print_int (p.x + p.y) |};
  [%expect {| 7 |}]

let%expect_test "mutable record field" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type counter = { mutable n : int }
       let () =
         let c = { n = 0 } in
         c.n <- 10;
         c.n <- c.n + 5;
         caml_java_print_int c.n |};
  [%expect {| 15 |}]

let%expect_test "array read/write/length" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let a = [| 10; 20; 30; 40 |] in
         a.(1) <- 99;
         caml_java_print_int a.(0);
         caml_java_print_int a.(1);
         caml_java_print_int a.(3);
         caml_java_print_int (Array.length a) |};
  [%expect {|
    10
    99
    40
    4 |}]

let%expect_test "sum an array" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let a = [| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 |] in
         let total = ref 0 in
         for i = 0 to Array.length a - 1 do
           total := !total + a.(i)
         done;
         caml_java_print_int !total |};
  [%expect {| 55 |}]

let%expect_test "tuple of int and ref" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let r = ref 5 in
         let p = (42, r) in
         let (n, r2) = p in
         r2 := !r2 + 100;
         caml_java_print_int (n + !r) |};
  [%expect {| 147 |}]

let%expect_test "record with int and ref fields" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type thing = { k : int; v : int ref }
       let () =
         let t = { k = 7; v = ref 11 } in
         t.v := !(t.v) * t.k;
         caml_java_print_int !(t.v) |};
  [%expect {| 77 |}]

let%expect_test "array of refs" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let arr = [| ref 1; ref 2; ref 3 |] in
         for i = 0 to Array.length arr - 1 do
           incr arr.(i)
         done;
         caml_java_print_int !(arr.(0));
         caml_java_print_int !(arr.(1));
         caml_java_print_int !(arr.(2)) |};
  [%expect {|
    2
    3
    4 |}]

let%expect_test "nested tuples" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let inner = (3, 4) in
         let outer = (inner, 5) in
         let ((a, b), c) = outer in
         caml_java_print_int (a + b + c) |};
  [%expect {| 12 |}]

