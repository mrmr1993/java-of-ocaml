(* [lazy] / [Lazy.force] — end-to-end through [CamlinternalLazy].

   Forcing a lazy value flips its [Block] tag from [lazy_tag=246] to
   [forcing_tag=244] via [caml_lazy_update_to_forcing], evaluates the
   stored thunk, writes the result back to field 0, then flips the
   tag to [forward_tag=250] via [caml_lazy_update_to_forward]. On
   exception the tag is reset via [caml_lazy_reset_to_lazy]. *)

open Util

let%expect_test "Lazy.force computes once and caches the result" =
  compile_and_run
    {| let x = lazy (print_endline "computed"; 42)
       let () = Printf.printf "%d\n" (Lazy.force x)
       let () = Printf.printf "%d\n" (Lazy.force x) |};
  [%expect {|
    computed
    42
    42
    |}]

let%expect_test "Lazy.force propagates exceptions" =
  compile_and_run
    {| exception E
       let x = lazy (raise E)
       let () =
         (try let _ = Lazy.force x in print_endline "no exn"
          with E -> print_endline "first: E");
         (try let _ = Lazy.force x in print_endline "no exn"
          with E -> print_endline "second: E") |};
  [%expect {|
    first: E
    second: E |}]

let%expect_test "lazy cascading / chained forces" =
  compile_and_run
    {| let a = lazy 10
       let b = lazy (Lazy.force a + 5)
       let c = lazy (Lazy.force b * 2)
       let () = Printf.printf "%d\n" (Lazy.force c) |};
  [%expect {| 30 |}]
