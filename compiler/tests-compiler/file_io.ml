(* File I/O — open_in / input_char / input_line / open_out / close.

   [caml_sys_open] allocates an FD in [Channel.FDS] and hands back
   the int; [caml_ml_open_descriptor_in] unwraps that FD into a
   [Channel] with a 64 KB byte-level input buffer;
   [caml_ml_input_scan_line] implements the buffered newline-search
   protocol [input_line] is built on; EOF raises OCaml's
   [End_of_file] via a [CamlException] wrapping [GLOBALS[4]]
   (seeded by main-init). *)

open Util

let%expect_test "write then read-line a file" =
  compile_and_run
    {| let () =
         let path = "/tmp/jvm-test-file-io.txt" in
         let oc = open_out path in
         output_string oc "alpha\nbeta\ngamma\n";
         close_out oc;
         let ic = open_in path in
         (try while true do print_endline (input_line ic) done
          with End_of_file -> ());
         close_in ic;
         Sys.remove path |};
  [%expect {|
    alpha
    beta
    gamma |}]

let%expect_test "input_char reads one byte at a time to EOF" =
  compile_and_run
    {| let () =
         let path = "/tmp/jvm-test-file-io.txt" in
         let oc = open_out path in
         output_string oc "abc";
         close_out oc;
         let ic = open_in path in
         (try while true do print_char (input_char ic) done
          with End_of_file -> ());
         print_newline ();
         close_in ic;
         Sys.remove path |};
  [%expect {| abc |}]

let%expect_test "input reads up to N bytes into a buffer" =
  compile_and_run
    {| let () =
         let path = "/tmp/jvm-test-file-io.txt" in
         let oc = open_out path in
         output_string oc "0123456789";
         close_out oc;
         let ic = open_in path in
         let buf = Bytes.create 4 in
         let n1 = input ic buf 0 4 in
         Printf.printf "read %d: %s\n" n1 (Bytes.sub_string buf 0 n1);
         let n2 = input ic buf 0 4 in
         Printf.printf "read %d: %s\n" n2 (Bytes.sub_string buf 0 n2);
         close_in ic;
         Sys.remove path |};
  [%expect {|
    [warning] <closure> ocaml_fn_650 oversized after split (88230 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_650 (88230 bytes)
    read 4: 0123
    read 4: 4567
    |}]
