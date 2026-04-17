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
