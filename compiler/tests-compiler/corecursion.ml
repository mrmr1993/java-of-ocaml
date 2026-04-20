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

let%expect_test "module rec with a single function component" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module rec M : sig val f : int -> int end = struct
         let f n = if n = 0 then 0 else M.f (n - 1) + 1
       end
       let () =
         caml_java_print_int (M.f 0);
         caml_java_print_int (M.f 5);
         caml_java_print_int (M.f 10) |};
  [%expect {|
    0
    5
    10 |}]

let%expect_test "module rec with two mutually recursive modules" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module rec Even : sig val test : int -> bool end = struct
         let test n = if n = 0 then true else Odd.test (n - 1)
       end
       and Odd : sig val test : int -> bool end = struct
         let test n = if n = 0 then false else Even.test (n - 1)
       end
       let () =
         caml_java_print_int (if Even.test 4 then 1 else 0);
         caml_java_print_int (if Even.test 7 then 1 else 0);
         caml_java_print_int (if Odd.test 5 then 1 else 0);
         caml_java_print_int (if Odd.test 6 then 1 else 0) |};
  [%expect {|
    1
    0
    1
    0 |}]

let%expect_test "module rec with a lazy component" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module rec M : sig val n : int Lazy.t val f : int -> int end = struct
         let n = lazy (M.f 3)
         and f x = x * 14
       end
       let () = caml_java_print_int (Lazy.force M.n) |};
  [%expect {| 42 |}]

let%expect_test "module rec with nested mutually recursive functions" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module rec A : sig val f : int -> int val g : int -> int end = struct
         let f n = if n <= 0 then 0 else B.g (n - 1) + 1
         let g n = if n <= 0 then 100 else A.f (n - 1) + 1
       end
       and B : sig val f : int -> int val g : int -> int end = struct
         let f n = A.f (2 * n)
         let g n = A.g (n + 1)
       end
       let () =
         caml_java_print_int (A.f 3);
         caml_java_print_int (A.g 3);
         caml_java_print_int (B.f 4);
         caml_java_print_int (B.g 0) |};
  [%expect {|
    6
    5
    16
    1 |}]
