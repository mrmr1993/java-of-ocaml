open Util

let%expect_test "4-arg function (PUSH_RETADDR + apply4)" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let f a b c d = a + b + c + d
       let () = caml_java_print_int (f 1 2 3 4) |};
  [%expect {| 10 |}]

let%expect_test "5-, 6-, and 7-arg functions" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let f5 a b c d e = a + b + c + d + e
       let f6 a b c d e f = a + b + c + d + e + f
       let f7 a b c d e f g = a + b + c + d + e + f + g
       let () =
         caml_java_print_int (f5 1 2 3 4 5);
         caml_java_print_int (f6 1 2 3 4 5 6);
         caml_java_print_int (f7 1 2 3 4 5 6 7) |};
  [%expect {|
    15
    21
    28 |}]

let%expect_test "partial application: 3-arg function called with 2 args then 1" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let add3 a b c = a + b + c
       let inc = add3 1 2
       let () =
         caml_java_print_int (add3 10 20 30);
         caml_java_print_int (inc 100);
         caml_java_print_int (inc 5) |};
  [%expect {|
    60
    103
    8 |}]

let%expect_test "instantiation currying: each call to [f ()] yields its own mutable state" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let f () =
         let counter = ref 0 in
         fun x ->
           counter := !counter + x;
           !counter
       let () =
         let acc = f () in
         caml_java_print_int (acc 1);
         caml_java_print_int (acc 10);
         caml_java_print_int (acc 100);
         let acc2 = f () in
         caml_java_print_int (acc2 5);
         caml_java_print_int (acc 0);
         caml_java_print_int (acc2 5) |};
  [%expect {|
    1
    11
    111
    5
    111
    10 |}]

let%expect_test "instantiation currying: sibling closures share one mutable cell" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let make_pair () =
         let counter = ref 0 in
         let bump x = counter := !counter + x; !counter in
         let peek () = !counter in
         (bump, peek)
       let () =
         let (bump, peek) = make_pair () in
         caml_java_print_int (bump 3);
         caml_java_print_int (bump 7);
         caml_java_print_int (peek ());
         let (bump2, peek2) = make_pair () in
         caml_java_print_int (bump2 100);
         caml_java_print_int (peek ());
         caml_java_print_int (peek2 ()) |};
  [%expect {|
    3
    10
    10
    100
    10
    100 |}]

let%expect_test "instantiation currying: nested closures with shared-outer, fresh-inner refs" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let f () =
         let outer = ref 0 in
         fun seed ->
           outer := !outer + seed;
           let inner = ref !outer in
           fun bump ->
             inner := !inner + bump;
             (!outer, !inner)
       let () =
         let g = f () in
         let h1 = g 10 in
         let h2 = g 1 in
         let (o, i) = h1 100 in
         caml_java_print_int o; caml_java_print_int i;
         let (o, i) = h2 200 in
         caml_java_print_int o; caml_java_print_int i;
         let (o, i) = h1 0 in
         caml_java_print_int o; caml_java_print_int i |};
  [%expect {|
    11
    110
    11
    211
    11
    110 |}]

let%expect_test "partial application: 4-arg function applied in several stages" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let f a b c d = a * 1000 + b * 100 + c * 10 + d
       let () =
         caml_java_print_int (f 1 2 3 4);
         let g = f 1 in
         caml_java_print_int (g 2 3 4);
         let h = g 2 in
         caml_java_print_int (h 3 4);
         let k = h 3 in
         caml_java_print_int (k 4) |};
  [%expect {|
    1234
    1234
    1234
    1234 |}]

