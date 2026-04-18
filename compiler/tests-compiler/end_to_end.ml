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
