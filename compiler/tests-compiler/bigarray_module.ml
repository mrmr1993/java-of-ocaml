(* Minimal [Bigarray] backing — [BigArray] runtime class is an
   [Object[]]-per-cell box matrix with kind / layout / dims
   recorded. Enough for [Random.State]'s 512-int64 buffer pulled
   in transitively by [Filename.temp_file]. *)

open Util

let%expect_test "Bigarray.Array1 Int64 round-trip" =
  compile_and_run
    {| let () =
         let ba = Bigarray.Array1.create Bigarray.int64 Bigarray.c_layout 5 in
         for i = 0 to 4 do Bigarray.Array1.set ba i (Int64.of_int (i * i)) done;
         for i = 0 to 4 do Printf.printf "%Ld " (Bigarray.Array1.get ba i) done;
         print_newline ();
         Printf.printf "dim=%d\n" (Bigarray.Array1.dim ba) |};
  [%expect {|
    0 1 4 9 16
    dim=5 |}]

let%expect_test "Filename.temp_file reaches Random.State + Digest + LXM" =
  (* End-to-end path that was blocked until Bigarray / MD5 / LXM /
     bytes-wide primitives landed: temp_file pulls in Random.State
     which needs a 512-int64 bigarray, a [caml_md5_string] seed
     mix, and [caml_lxm_next] to advance the generator. *)
  compile_and_run
    {| let () =
         let p = Filename.temp_file "jvm-test" ".txt" in
         let oc = open_out p in
         output_string oc "hi\n";
         close_out oc;
         let ic = open_in p in
         print_endline (input_line ic);
         close_in ic;
         Sys.remove p |};
  [%expect {| hi |}]
