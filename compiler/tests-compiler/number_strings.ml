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
     external format_int : string -> int -> string = "caml_format_int"
     external float_of_string : string -> float = "caml_float_of_string"
     external format_float : string -> float -> string = "caml_format_float" |}

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
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Failure "non-zero exit code")
  Raised at Stdlib__Buffer.add_channel in file "buffer.ml", line 213, characters 18-35
  Called from Java_of_ocaml_expect_tests_helper__Util.channel_to_string.loop in file "compiler/tests-compiler/util/util.ml", line 122, characters 4-52
  Called from Java_of_ocaml_expect_tests_helper__Util.channel_to_string in file "compiler/tests-compiler/util/util.ml", line 125, characters 7-14

  Trailing output
  ---------------
  /bin/sh: 1: /home/mathew/source_code/java-of-ocaml/_build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe: not found

  process exited with error code 127
   /home/mathew/source_code/java-of-ocaml/_build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe  test.bc -o .
  |}]

let%expect_test "float_of_string / format_float round-trip" =
  compile_and_run
    (preamble
     ^ {| let () =
            caml_java_print_endline (format_float "%f" 3.14);
            caml_java_print_endline (format_float "%f" (float_of_string "42.5"));
            caml_java_print_endline (format_float "%f" (-. 1.0)) |});
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Failure "non-zero exit code")
  Raised at Stdlib__Buffer.add_channel in file "buffer.ml", line 213, characters 18-35
  Called from Java_of_ocaml_expect_tests_helper__Util.channel_to_string.loop in file "compiler/tests-compiler/util/util.ml", line 122, characters 4-52
  Called from Java_of_ocaml_expect_tests_helper__Util.channel_to_string in file "compiler/tests-compiler/util/util.ml", line 125, characters 7-14

  Trailing output
  ---------------
  /bin/sh: 1: /home/mathew/source_code/java-of-ocaml/_build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe: Permission denied

  process exited with error code 126
   /home/mathew/source_code/java-of-ocaml/_build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe  test.bc -o .
  |}]

let%expect_test "caml_ml_string_length / caml_string_equal / caml_string_compare" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external length : string -> int = "caml_ml_string_length"
       external equal : string -> string -> bool = "caml_string_equal"
       external notequal : string -> string -> bool = "caml_string_notequal"
       external compare : string -> string -> int = "caml_string_compare"
       let to_int b = if b then 1 else 0
       let sign n = if n < 0 then -1 else if n > 0 then 1 else 0
       let () =
         caml_java_print_int (length "hello");
         caml_java_print_int (length "");
         caml_java_print_int (to_int (equal "abc" "abc"));
         caml_java_print_int (to_int (equal "abc" "abd"));
         caml_java_print_int (to_int (notequal "abc" "abc"));
         caml_java_print_int (to_int (notequal "abc" "abd"));
         caml_java_print_int (sign (compare "abc" "abc"));
         caml_java_print_int (sign (compare "abc" "abd"));
         caml_java_print_int (sign (compare "abd" "abc")) |};
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  (* CR expect_test_collector: This test expectation appears to contain a backtrace.
     This is strongly discouraged as backtraces are fragile.
     Please change this test to not include a backtrace. *)
  (Failure "non-zero exit code")
  Raised at Stdlib__Buffer.add_channel in file "buffer.ml", line 213, characters 18-35
  Called from Java_of_ocaml_expect_tests_helper__Util.channel_to_string.loop in file "compiler/tests-compiler/util/util.ml", line 122, characters 4-52
  Called from Java_of_ocaml_expect_tests_helper__Util.channel_to_string in file "compiler/tests-compiler/util/util.ml", line 125, characters 7-14

  Trailing output
  ---------------
  /bin/sh: 1: /home/mathew/source_code/java-of-ocaml/_build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe: Permission denied

  process exited with error code 126
   /home/mathew/source_code/java-of-ocaml/_build/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe  test.bc -o .
  |}]
