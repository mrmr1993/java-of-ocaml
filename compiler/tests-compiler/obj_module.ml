open Util

let%expect_test "Obj.is_int (inlined to ISINT)" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let b x = if x then 1 else 0
       let () =
         caml_java_print_int (b (Obj.is_int (Obj.repr 42)));
         caml_java_print_int (b (Obj.is_int (Obj.repr (1, 2)))) |};
  [%expect {|
    1
    0 |}]

let%expect_test "Obj.tag on ints, tuples, variants" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type t = A | B of int * int | C of string
       let () =
         caml_java_print_int (Obj.tag (Obj.repr 7));
         caml_java_print_int (Obj.tag (Obj.repr (1, 2, 3)));
         caml_java_print_int (Obj.tag (Obj.repr (B (10, 20))));
         caml_java_print_int (Obj.tag (Obj.repr (C "x"))) |};
  [%expect {|
    1000
    0
    0
    1 |}]

let%expect_test "Obj.size and Obj.field" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let t = Obj.repr (10, 20, 30) in
         caml_java_print_int (Obj.size t);
         caml_java_print_int (Obj.obj (Obj.field t 0));
         caml_java_print_int (Obj.obj (Obj.field t 1));
         caml_java_print_int (Obj.obj (Obj.field t 2)) |};
  [%expect {|
    3
    10
    20
    30 |}]

let%expect_test "Obj.set_field on a mutable record" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type r = { mutable a : int; mutable b : int }
       let () =
         let r = { a = 0; b = 0 } in
         Obj.set_field (Obj.repr r) 0 (Obj.repr 11);
         Obj.set_field (Obj.repr r) 1 (Obj.repr 22);
         caml_java_print_int r.a;
         caml_java_print_int r.b |};
  [%expect {|
    11
    22 |}]

let%expect_test "Obj.new_block + set_field builds a readable block" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let b = Obj.new_block 0 3 in
         Obj.set_field b 0 (Obj.repr 100);
         Obj.set_field b 1 (Obj.repr 200);
         Obj.set_field b 2 (Obj.repr 300);
         caml_java_print_int (Obj.size b);
         caml_java_print_int (Obj.tag b);
         caml_java_print_int (Obj.obj (Obj.field b 0));
         caml_java_print_int (Obj.obj (Obj.field b 1));
         caml_java_print_int (Obj.obj (Obj.field b 2)) |};
  [%expect {|
    3
    0
    100
    200
    300 |}]

let%expect_test "Obj.dup is a shallow copy, Obj.with_tag changes the tag" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let t = Obj.repr (1, 2, 3) in
         let d = Obj.dup t in
         caml_java_print_int (Obj.size d);
         caml_java_print_int (Obj.obj (Obj.field d 0));
         caml_java_print_int (Obj.obj (Obj.field d 1));
         caml_java_print_int (Obj.obj (Obj.field d 2));
         let w = Obj.with_tag 5 t in
         caml_java_print_int (Obj.tag w);
         caml_java_print_int (Obj.size w);
         caml_java_print_int (Obj.obj (Obj.field w 0)) |};
  [%expect {|
    3
    1
    2
    3
    5
    3
    1 |}]

let%expect_test "Obj.magic roundtrip preserves int payload" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let n : int = Obj.magic (Obj.magic 42 : string) in
         caml_java_print_int n |};
  [%expect {| 42 |}]
