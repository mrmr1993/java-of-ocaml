open Util

let%expect_test "option match: Some vs None" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let describe = function
         | None -> 0
         | Some n -> n
       let () =
         caml_java_print_int (describe (Some 42));
         caml_java_print_int (describe None) |};
  [%expect {|
    42
    0 |}]

let%expect_test "enum variant: Red / Green / Blue" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type color = Red | Green | Blue
       let rank = function
         | Red -> 1
         | Green -> 2
         | Blue -> 3
       let () =
         caml_java_print_int (rank Red);
         caml_java_print_int (rank Green);
         caml_java_print_int (rank Blue) |};
  [%expect {|
    1
    2
    3 |}]

let%expect_test "variant with payload in closure capture" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let unwrap_or default = function
         | None -> default
         | Some n -> n
       let () =
         caml_java_print_int (unwrap_or 99 (Some 7));
         caml_java_print_int (unwrap_or 99 None) |};
  [%expect {|
    7
    99 |}]

let%expect_test "variant with mixed immediate and data constructors" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type tree = Leaf | Node of int
       let value_of = function
         | Leaf -> -1
         | Node n -> n
       let () =
         caml_java_print_int (value_of Leaf);
         caml_java_print_int (value_of (Node 17));
         caml_java_print_int (value_of (Node 42)) |};
  [%expect {|
    -1
    17
    42 |}]
let%expect_test "variant: multiple data constructors with different tags" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type shape = Circle of int | Square of int | Rectangle of int * int
       let area = function
         | Circle r -> 3 * r * r
         | Square s -> s * s
         | Rectangle (w, h) -> w * h
       let () =
         caml_java_print_int (area (Circle 5));
         caml_java_print_int (area (Square 4));
         caml_java_print_int (area (Rectangle (3, 7))) |};
  [%expect {|
    75
    16
    21 |}]

let%expect_test "recursive variant: binary tree sum" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type tree = Leaf | Node of tree * int * tree
       let rec sum = function
         | Leaf -> 0
         | Node (l, v, r) -> sum l + v + sum r
       let t =
         Node (Node (Leaf, 1, Node (Leaf, 2, Leaf)), 3, Node (Leaf, 4, Leaf))
       let () = caml_java_print_int (sum t) |};
  [%expect {| 10 |}]

let%expect_test "recursive variant: arithmetic expression evaluator" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type expr =
         | Num of int
         | Add of expr * expr
         | Mul of expr * expr
       let rec eval = function
         | Num n -> n
         | Add (a, b) -> eval a + eval b
         | Mul (a, b) -> eval a * eval b
       let () =
         caml_java_print_int (eval (Mul (Add (Num 2, Num 3), Num 4))) |};
  [%expect {| 20 |}]

let%expect_test "polymorphic variant with zero-arg and data cases" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let describe = function
         | `Red -> 1
         | `Green -> 2
         | `Blue -> 3
         | `Rgb (r, _, _) -> r
       let () =
         caml_java_print_int (describe `Red);
         caml_java_print_int (describe `Blue);
         caml_java_print_int (describe (`Rgb (42, 0, 0))) |};
  [%expect {|
    1
    3
    42 |}]

