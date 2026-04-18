open Util

let%expect_test "higher-order: mkadder" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let mkadder x = (fun y -> x + y)
       let () =
         let add10 = mkadder 10 in
         caml_java_print_int (add10 5);
         caml_java_print_int (add10 25) |};
  [%expect {|
    15
    35 |}]

let%expect_test "higher-order: composition" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let mkmul k = (fun x -> k * x)
       let mkadd d = (fun x -> x + d)
       let () =
         let double = mkmul 2 in
         let plus3 = mkadd 3 in
         caml_java_print_int (double 7);
         caml_java_print_int (plus3 7);
         caml_java_print_int (double (plus3 5)) |};
  [%expect {|
    14
    10
    16 |}]

let%expect_test "string field in tuple" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () =
         let p = ("answer is", 42) in
         let (s, n) = p in
         caml_java_print_endline s;
         caml_java_print_int n |};
  [%expect {|
    answer is
    42 |}]

let%expect_test "record with string and int fields" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       type labeled = { name : string; value : int }
       let () =
         let r = { name = "pi"; value = 314 } in
         caml_java_print_endline r.name;
         caml_java_print_int r.value |};
  [%expect {|
    pi
    314 |}]

let%expect_test "closure taking a string arg" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () =
         let greet name = caml_java_print_endline name in
         greet "world";
         greet "ocaml" |};
  [%expect {|
    world
    ocaml |}]

let%expect_test "closure capturing a string" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let mkgreeter name = (fun () -> caml_java_print_endline name)
       let () =
         let hi = mkgreeter "hello world" in
         hi (); hi () |};
  [%expect {|
    hello world
    hello world |}]

let%expect_test "array of strings" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () =
         let a = [| "one"; "two"; "three" |] in
         for i = 0 to Array.length a - 1 do
           caml_java_print_endline a.(i)
         done |};
  [%expect {|
    one
    two
    three |}]
