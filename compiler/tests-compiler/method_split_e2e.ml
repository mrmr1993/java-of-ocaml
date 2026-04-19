(* End-to-end test of 64 KB method splitting. OCaml doesn't normally
   produce methods over the JVM's 65535-byte [Code] cap, but the
   compiler exposes [JAVA_OF_OCAML_SPLIT_THRESHOLD] to force splitting
   on smaller bodies. We set it low, compile a function with enough
   distinct IR blocks (via a chain of if-expressions) that the
   emitter produces a body exceeding the threshold, and verify the
   resulting class still runs correctly — so the splitter's head +
   helper decomposition preserves semantics. *)

open Util

let with_env name value ~f =
  let prev = try Some (Sys.getenv name) with Not_found -> None in
  Unix.putenv name value;
  let finally () =
    match prev with
    | None -> Unix.putenv name ""  (* best-effort unset *)
    | Some v -> Unix.putenv name v
  in
  match f () with
  | x ->
    finally ();
    x
  | exception e ->
    finally ();
    raise e

let%expect_test "function with many blocks runs correctly under a tight split threshold" =
  with_env "JAVA_OF_OCAML_SPLIT_THRESHOLD" "400" ~f:(fun () ->
    compile_and_run
      {|
        external caml_java_print_int : int -> unit = "caml_java_print_int"
        let f x =
          let a = if x > 0 then 10 else 20 in
          let b = if x > 1 then 30 else 40 in
          let c = if x > 2 then 50 else 60 in
          let d = if x > 3 then 70 else 80 in
          let e = if x > 4 then 90 else 100 in
          let g = if x > 5 then 110 else 120 in
          let h = if x > 6 then 130 else 140 in
          a + b + c + d + e + g + h
        let () =
          caml_java_print_int (f 0);
          caml_java_print_int (f 3);
          caml_java_print_int (f 10)
      |});
  [%expect {|
    560
    530
    490
    |}]
