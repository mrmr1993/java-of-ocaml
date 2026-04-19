open Util

(* [Array.{sub,blit,fill,append}] live on top of
   [Stdlib.invalid_arg], which we can't materialise yet; the test
   re-declares them as externals bound directly to the underlying C
   primitives so the inlined externals reach our C_CALL handlers. *)
let array_primitives_preamble =
  {| external caml_java_print_int : int -> unit = "caml_java_print_int"
     external array_sub : 'a array -> int -> int -> 'a array = "caml_array_sub"
     external array_blit :
       'a array -> int -> 'a array -> int -> int -> unit = "caml_array_blit"
     external array_fill :
       'a array -> int -> int -> 'a -> unit = "caml_array_fill"
     external array_append :
       'a array -> 'a array -> 'a array = "caml_array_append" |}

let%expect_test "Array.make / length / get / set" =
  compile_and_run
    (array_primitives_preamble
     ^ {| let () =
            let a = Array.make 5 7 in
            caml_java_print_int (Array.length a);
            caml_java_print_int a.(0);
            caml_java_print_int a.(4);
            a.(2) <- 42;
            caml_java_print_int a.(2);
            a.(4) <- -1;
            caml_java_print_int a.(4) |});
  [%expect {|
    5
    7
    7
    42
    -1 |}]

let%expect_test "Array.sub is a fresh copy" =
  compile_and_run
    (array_primitives_preamble
     ^ {| let () =
            let a = Array.make 5 0 in
            a.(0) <- 10; a.(1) <- 20; a.(2) <- 30;
            a.(3) <- 40; a.(4) <- 50;
            let b = array_sub a 1 3 in
            caml_java_print_int (Array.length b);
            caml_java_print_int b.(0);
            caml_java_print_int b.(1);
            caml_java_print_int b.(2);
            (* mutating [b] must not touch [a]. *)
            b.(0) <- 999;
            caml_java_print_int a.(1);
            caml_java_print_int b.(0) |});
  [%expect {|
    3
    20
    30
    40
    20
    999
    |}]

let%expect_test "Array.blit copies between distinct arrays" =
  compile_and_run
    (array_primitives_preamble
     ^ {| let () =
            let a = Array.make 5 0 in
            a.(0) <- 10; a.(1) <- 20; a.(2) <- 30;
            a.(3) <- 40; a.(4) <- 50;
            let d = Array.make 3 0 in
            array_blit a 1 d 0 3;
            caml_java_print_int d.(0);
            caml_java_print_int d.(1);
            caml_java_print_int d.(2) |});
  [%expect {|
    20
    30
    40
    |}]

let%expect_test "Array.fill with a constant" =
  compile_and_run
    (array_primitives_preamble
     ^ {| let () =
            let a = Array.make 6 1 in
            array_fill a 2 3 99;
            caml_java_print_int a.(0);
            caml_java_print_int a.(1);
            caml_java_print_int a.(2);
            caml_java_print_int a.(3);
            caml_java_print_int a.(4);
            caml_java_print_int a.(5) |});
  [%expect {|
    1
    1
    99
    99
    99
    1
    |}]

let%expect_test "Array.append concatenates two arrays" =
  compile_and_run
    (array_primitives_preamble
     ^ {| let () =
            let a = Array.make 3 0 in
            a.(0) <- 1; a.(1) <- 2; a.(2) <- 3;
            let b = Array.make 2 0 in
            b.(0) <- 40; b.(1) <- 50;
            let c = array_append a b in
            caml_java_print_int (Array.length c);
            caml_java_print_int c.(0);
            caml_java_print_int c.(1);
            caml_java_print_int c.(2);
            caml_java_print_int c.(3);
            caml_java_print_int c.(4) |});
  [%expect {|
    5
    1
    2
    3
    40
    50
    |}]

let%expect_test "array of closures" =
  compile_and_run
    (array_primitives_preamble
     ^ {| let () =
            let a = Array.make 3 (fun x -> x) in
            a.(0) <- (fun x -> x + 1);
            a.(1) <- (fun x -> x * 2);
            a.(2) <- (fun x -> x - 3);
            caml_java_print_int (a.(0) 10);
            caml_java_print_int (a.(1) 10);
            caml_java_print_int (a.(2) 10) |});
  [%expect {|
    11
    20
    7 |}]
