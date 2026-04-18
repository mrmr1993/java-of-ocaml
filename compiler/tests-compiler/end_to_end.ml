open Util

let%expect_test "hello world via bytecode" =
  compile_and_run_bytecode {| print_endline "hello world" |};
  [%expect {| hello world |}]

let%expect_test "arithmetic via bytecode" =
  compile_and_run_bytecode {| print_int (1 + 2); print_newline () |};
  [%expect {| 3 |}]

let%expect_test "string concatenation via bytecode" =
  compile_and_run_bytecode {| print_endline ("foo" ^ "bar") |};
  [%expect {| foobar |}]

let%expect_test "list operations via bytecode" =
  compile_and_run_bytecode
    {| List.iter (fun x -> Printf.printf "%d " x) [1; 2; 3]; print_newline () |};
  [%expect {| 1 2 3 |}]

let%expect_test "hello via custom primitive compiled to JVM" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () = caml_java_print_endline "hello" |};
  [%expect {| hello |}]

let%expect_test "int literal via custom primitive" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int 42 |};
  [%expect {| 42 |}]

let%expect_test "int arithmetic via custom primitive" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int (1 + 2) |};
  [%expect {| 3 |}]

let%expect_test "mixing int and string primitives" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () = caml_java_print_endline "answer:"
       let () = caml_java_print_int (40 + 2) |};
  [%expect {|
    answer:
    42 |}]

let%expect_test "chained int arithmetic" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int (10 + 20 + 3)
       let () = caml_java_print_int (5 * 6)
       let () = caml_java_print_int (100 - 58) |};
  [%expect {|
    33
    30
    42 |}]

let%expect_test "if/else with int comparison" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         if 0 < 1 then caml_java_print_int 1
         else caml_java_print_int 2 |};
  [%expect {| 1 |}]

let%expect_test "if/else taking the else branch" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         if 5 < 3 then caml_java_print_int 100
         else caml_java_print_int 200 |};
  [%expect {| 200 |}]

let%expect_test "if/else with arithmetic in branches" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         if 2 * 3 = 6 then caml_java_print_int (10 + 1)
         else caml_java_print_int (10 - 1) |};
  [%expect {| 11 |}]

let%expect_test "if/else with string branches" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () =
         if 1 = 1 then caml_java_print_endline "yes"
         else caml_java_print_endline "no" |};
  [%expect {| yes |}]

let%expect_test "single let-binding" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 10 in
         caml_java_print_int (x + 5) |};
  [%expect {| 15 |}]

let%expect_test "nested let-bindings" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 10 in
         let y = 20 in
         caml_java_print_int (x + y) |};
  [%expect {| 30 |}]

let%expect_test "let + dynamic comparison" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 10 in
         if x < 5 then caml_java_print_int x
         else caml_java_print_int (x + 1) |};
  [%expect {| 11 |}]

let%expect_test "let + subtraction" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let a = 100 in
         let b = 58 in
         caml_java_print_int (a - b) |};
  [%expect {| 42 |}]

let%expect_test "min of two let bindings" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 5 in
         let y = 10 in
         if x < y then caml_java_print_int x
         else caml_java_print_int y |};
  [%expect {| 5 |}]
