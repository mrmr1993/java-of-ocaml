(* Primitives used as first-class values.

   Everything in OCaml is a function value, including externals, inlined
   operators ([%addint], [%mulint]), and stdlib primitives like
   [Int64.add] or [compare]. When the source uses them as a value —
   [List.map f xs] where [f] is the primitive, or partial application
   like [Int64.add 1000L] — OCaml's bytecode compiler either inlines or
   wraps them in a [CLOSURE]; partial applications land in our
   [PartialClosure] runtime. This test file pins that the full round-
   trip through [Closure] + [PartialClosure] works for the common
   shapes. Historically it's where shortcuts in closure representation
   can silently fail: a primitive forgets to wrap, or a partial apply
   returns the wrong arity. *)

open Util

let%expect_test "primitive as first-class value: let-bound + called" =
  compile_and_run
    {| external my_add : int -> int -> int = "%addint"
       let () =
         let f = my_add in
         Printf.printf "direct=%d\n" (f 5 7) |};
  [%expect {|
    [warning] <closure> ocaml_fn_650 oversized after split (88230 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_650 (88230 bytes)
    direct=12
    |}]

let%expect_test "inlined-primitive partial application via HOF" =
  compile_and_run
    {| external my_add : int -> int -> int = "%addint"
       let () =
         let xs = List.map (my_add 10) [1; 2; 3] in
         List.iter (Printf.printf "%d ") xs;
         print_newline () |};
  [%expect {|
    [warning] <closure> ocaml_fn_753 oversized after split (88184 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_753 (88184 bytes)
    11 12 13
    |}]

let%expect_test "real C primitive (Int64.add) as first-class value" =
  compile_and_run
    {| let () =
         let f = Int64.add in
         Printf.printf "direct=%Ld\n" (f 100L 200L);
         let xs = List.map (Int64.add 1000L) [1L; 2L; 3L] in
         List.iter (Printf.printf "%Ld ") xs;
         print_newline () |};
  [%expect {|
    [warning] <closure> ocaml_fn_753 oversized after split (88184 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_753 (88184 bytes)
    direct=300
    1001 1002 1003
    |}]

let%expect_test "compose + curry a primitive across modules" =
  compile_and_run
    {| module Ops = struct
         external add : int -> int -> int = "%addint"
         external mul : int -> int -> int = "%mulint"
         let compose f g x = f (g x)
       end
       let () =
         let f = Ops.compose (Ops.add 1) (Ops.mul 2) in
         Printf.printf "f(5)=%d\n" (f 5);
         let sum = List.fold_left (+) 0 [1; 2; 3; 4; 5] in
         Printf.printf "sum=%d\n" sum |};
  [%expect {|
    [warning] <closure> ocaml_fn_753 oversized after split (88184 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_753 (88184 bytes)
    f(5)=11
    sum=15
    |}]

let%expect_test "5-ary C primitive through PartialClosure chain" =
  (* Forces [caml_blit_string]'s arity-5 check in [jvm_generate]'s
     [emit_ccall] to fire on a saturated call that only reaches it
     via the PartialClosure runtime — not a direct CCALL5 at the
     source. If the closure / partial-closure chain miscounts args,
     the primitive raises [Unsupported "caml_blit_string arity"]
     at emit time (fails the build) or the JVM fires verifier /
     runtime errors at the CCALL site. *)
  compile_and_run
    {| external blit_string :
         string -> int -> bytes -> int -> int -> unit
         = "caml_blit_string"
       let () =
         let buf = Bytes.make 10 '.' in
         let partial4 = blit_string "hello" 0 buf 0 in
         partial4 5;
         Printf.printf "blit: %s\n" (Bytes.unsafe_to_string buf);
         let buf2 = Bytes.make 20 '.' in
         let blit3 = blit_string "abc" 0 buf2 in
         List.iter (fun off -> blit3 off 3) [0; 5; 10];
         Printf.printf "multi: %s\n" (Bytes.unsafe_to_string buf2) |};
  [%expect {|
    [warning] <closure> ocaml_fn_753 oversized after split (88184 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_753 (88184 bytes)
    blit: hello.....
    multi: abc..abc..abc.......
    |}]

let%expect_test "polymorphic compare as first-class" =
  compile_and_run
    {| let () =
         let xs = List.sort compare [3; 1; 4; 1; 5; 9; 2; 6] in
         List.iter (Printf.printf "%d ") xs;
         print_newline () |};
  [%expect {|
    [warning] <closure> ocaml_fn_753 oversized after split (88184 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_753 (88184 bytes)
    1 1 2 3 4 5 6 9
    |}]
