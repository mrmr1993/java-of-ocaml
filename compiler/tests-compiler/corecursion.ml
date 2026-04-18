open Util

let%expect_test "mutually recursive functions (nfuncs=2)" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec even n = if n = 0 then 1 else odd (n - 1)
       and odd n = if n = 0 then 0 else even (n - 1)
       let () =
         caml_java_print_int (even 10);
         caml_java_print_int (odd 7);
         caml_java_print_int (even 3) |};
  [%expect {|
    1
    1
    0 |}]

let%expect_test "three-way mutual recursion (nfuncs=3)" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec mod3_0 n = if n = 0 then 0 else mod3_1 (n - 1)
       and mod3_1 n = if n = 0 then 1 else mod3_2 (n - 1)
       and mod3_2 n = if n = 0 then 2 else mod3_0 (n - 1)
       let () =
         caml_java_print_int (mod3_0 7);
         caml_java_print_int (mod3_1 7);
         caml_java_print_int (mod3_2 7);
         caml_java_print_int (mod3_0 15) |};
  [%expect {|
    1
    2
    0
    0 |}]

let%expect_test "recursive values via alloc_dummy / update_dummy" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type t = A of t array * t array
       let rec a = A (b, b) and b = [|a; a; a|]
       let () =
         caml_java_print_int (Array.length b);
         match a with A (arr, _) -> caml_java_print_int (Array.length arr) |};
  [%expect {|
    3
    3 |}]

let%expect_test "recursive cyclic list" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec ones = 1 :: ones
       let rec ab = 1 :: bb and bb = 2 :: ab
       let () =
         (match ones with
          | h :: t ->
            caml_java_print_int h;
            (match t with h :: _ -> caml_java_print_int h | [] -> ())
          | [] -> ());
         (match ab with
          | h :: t ->
            caml_java_print_int h;
            (match t with
             | h :: t ->
               caml_java_print_int h;
               (match t with h :: _ -> caml_java_print_int h | [] -> ())
             | [] -> ())
          | [] -> ()) |};
  [%expect {|
    1
    1
    1
    2
    1 |}]
