open Util

let%expect_test "try/with catch-all" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       exception Oops
       let safe x =
         try if x = 0 then raise Oops else 100 / x with _ -> -1
       let () =
         caml_java_print_int (safe 10);
         caml_java_print_int (safe 0);
         caml_java_print_int (safe 4) |};
  [%expect {|
    10
    -1
    25 |}]

let%expect_test "try/with matching specific exceptions" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       exception A
       exception B
       let classify x =
         try
           if x = 1 then raise A
           else if x = 2 then raise B
           else x * 10
         with
         | A -> 111
         | B -> 222
       let () =
         caml_java_print_int (classify 5);
         caml_java_print_int (classify 1);
         caml_java_print_int (classify 2) |};
  [%expect {|
    50
    111
    222 |}]

let%expect_test "exception propagates through one frame into try" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       exception E
       let f x = if x < 0 then raise E else x * 2
       let g x = try f x with _ -> 999
       let () =
         caml_java_print_int (g 5);
         caml_java_print_int (g (-1));
         caml_java_print_int (g 0) |};
  [%expect {|
    10
    999
    0 |}]
