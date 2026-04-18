open Util

(* These exercise [caml_int_of_string] / [caml_format_int], the two C
   primitives that back [int_of_string] and [Printf %d]. The wrappers
   in [Stdlib] (via [CamlinternalFormat]) can't yet be called
   directly — tests here bind the primitives as externals until
   whole-bytecode compilation lands. *)

let preamble =
  {| external caml_java_print_int : int -> unit = "caml_java_print_int"
     external caml_java_print_endline : string -> unit =
       "caml_java_print_endline"
     external int_of_string : string -> int = "caml_int_of_string"
     external format_int : string -> int -> string = "caml_format_int" |}

let%expect_test "int_of_string: positive / negative decimal" =
  compile_and_run
    (preamble
     ^ {| let () =
            caml_java_print_int (int_of_string "42");
            caml_java_print_int (int_of_string "-7");
            caml_java_print_int (int_of_string "0");
            caml_java_print_int (int_of_string "2147483647") |});
  [%expect {|
    42
    -7
    0
    2147483647 |}]

let%expect_test "format_int: %d on a range of ints" =
  compile_and_run
    (preamble
     ^ {| let () =
            caml_java_print_endline (format_int "%d" 0);
            caml_java_print_endline (format_int "%d" 123);
            caml_java_print_endline (format_int "%d" (-456));
            caml_java_print_endline (format_int "%d" 1000000) |});
  [%expect {|
    0
    123
    -456
    1000000 |}]

let%expect_test "int_of_string . format_int is identity on ints" =
  compile_and_run
    (preamble
     ^ {| let () =
            let roundtrip n =
              caml_java_print_int (int_of_string (format_int "%d" n))
            in
            roundtrip 42;
            roundtrip (-1);
            roundtrip 0 |});
  [%expect {|
    42
    -1
    0 |}]
