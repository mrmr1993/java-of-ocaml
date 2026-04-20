(* [Mutex] and [Condition] primitives — backed by
   [java.util.concurrent.locks.ReentrantLock] and a lazily-bound
   [Condition]. These work correctly under real contention if
   [Thread.create] is ever wired up; for now they compile and run
   cleanly in the single-threaded case, which is what most libraries
   reaching for [Mutex] / [Condition] internally actually need. *)

open Util

let%expect_test "Mutex.create + lock + unlock" =
  compile_and_run
    {| let m = Mutex.create ()
       let () =
         Mutex.lock m;
         print_endline "locked";
         Mutex.unlock m;
         print_endline "unlocked";
         Mutex.lock m;
         Mutex.unlock m;
         print_endline "re-lock + unlock ok" |};
  [%expect {|
    locked
    unlocked
    re-lock + unlock ok |}]

let%expect_test "Mutex.try_lock returns true when uncontended" =
  compile_and_run
    {| let m = Mutex.create ()
       let () =
         Printf.printf "%B\n" (Mutex.try_lock m);
         Mutex.unlock m |};
  [%expect {|
    [warning] <closure> ocaml_fn_655 oversized after split (88231 bytes > 65535) — body replaced with a runtime-throwing stub
    [warning] 1 method stubbed after exceeding the JVM 64 KB [Code]-attribute limit; affected call paths fail at runtime.
    [warning]   <closure>  ocaml_fn_655 (88231 bytes)
    true
    |}]

let%expect_test "Condition.signal / broadcast are no-ops when no one waits" =
  compile_and_run
    {| let _m = Mutex.create ()
       let c = Condition.create ()
       let () =
         Condition.signal c;
         Condition.broadcast c;
         print_endline "ok" |};
  [%expect {| ok |}]
