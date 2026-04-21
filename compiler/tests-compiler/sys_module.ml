(* [Sys] module — filesystem + time primitives backed by [java.io.File]
   and [System.nanoTime]. [caml_sys_random_seed] returns a 1-element
   [int array] seeded from [nanoTime]; stdlib's [Random.State] takes
   it from there. *)

open Util

let%expect_test "Sys.getcwd returns a non-empty string" =
  compile_and_run
    {| let () = Printf.printf "%B\n" (String.length (Sys.getcwd ()) > 0) |};
  [%expect {| true |}]

let%expect_test "Sys.is_directory / is_regular_file via java.io.File" =
  compile_and_run
    {| let () =
         Printf.printf "is_dir(/tmp)=%B\n" (Sys.is_directory "/tmp");
         Printf.printf "is_reg(/etc/hostname)=%B\n"
           (Sys.is_regular_file "/etc/hostname") |};
  [%expect {|
    is_dir(/tmp)=true
    is_reg(/etc/hostname)=true
    |}]

let%expect_test "Sys.time returns a non-negative float" =
  compile_and_run
    {| let () = Printf.printf "%B\n" (Sys.time () >= 0.0) |};
  [%expect {| true |}]
