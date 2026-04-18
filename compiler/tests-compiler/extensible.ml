open Util

let%expect_test "extensible type with positional, tuple and inline-record constructors" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       type shape = ..
       type shape += Circle of int
       type shape += Square of int
       type shape += Rectangle of int * int
       let area = function
         | Circle r -> 3 * r * r
         | Square s -> s * s
         | Rectangle (w, h) -> w * h
         | _ -> -1
       type shape += Labelled of { name : string; size : int }
       let name_of = function
         | Circle _ -> "circle"
         | Labelled { name; _ } -> name
         | _ -> "other"
       let () =
         caml_java_print_int (area (Circle 5));
         caml_java_print_int (area (Square 4));
         caml_java_print_int (area (Rectangle (3, 7)));
         caml_java_print_int (area (Labelled { name = "x"; size = 1 }));
         caml_java_print_endline (name_of (Circle 1));
         caml_java_print_endline (name_of (Square 2));
         caml_java_print_endline (name_of (Labelled { name = "tag"; size = 99 })) |};
  [%expect {|
    75
    16
    21
    -1
    circle
    other
    tag |}]

let%expect_test "extensible type: match falls through to catch-all for a later constructor" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type op = ..
       type op += Add of int * int
       type op += Mul of int * int
       let original = function
         | Add (a, b) -> a + b
         | Mul (a, b) -> a * b
         | _ -> -1  (* catch-all — later constructors hit this *)
       type op += Neg of int
       let extended = function
         | Neg a -> 0 - a
         | other -> original other
       let () =
         caml_java_print_int (extended (Add (3, 4)));
         caml_java_print_int (extended (Mul (5, 6)));
         caml_java_print_int (extended (Neg 7)) |};
  [%expect {|
    7
    30
    -7 |}]

