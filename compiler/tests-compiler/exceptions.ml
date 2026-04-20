open Util

let%expect_test "try/with catch-all" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       exception Oops
       let safe x =
         try if x = 0 then raise Oops else 100 / x with _ -> -1
       let () =
         caml_java_print_int (safe 10);
         caml_java_print_int (safe 0);
         caml_java_print_int (safe 4) |};
  [%expect {|
    10
    -1
    25 |}]

let%expect_test "try/with matching specific exceptions" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       exception A
       exception B
       let classify x =
         try
           if x = 1 then raise A
           else if x = 2 then raise B
           else x * 10
         with
         | A -> 111
         | B -> 222
       let () =
         caml_java_print_int (classify 5);
         caml_java_print_int (classify 1);
         caml_java_print_int (classify 2) |};
  [%expect {|
    50
    111
    222 |}]

let%expect_test "exception propagates through one frame into try" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       exception E
       let f x = if x < 0 then raise E else x * 2
       let g x = try f x with _ -> 999
       let () =
         caml_java_print_int (g 5);
         caml_java_print_int (g (-1));
         caml_java_print_int (g 0) |};
  [%expect {|
    10
    999
    0 |}]

(* Nested [try]/[with] where the inner handler itself raises. At
   runtime the inner trap is popped by the raise that enters the
   inner handler, so the outer trap is the active catcher while the
   handler runs — the raise there must route to the outer handler.

   This exercises the JVM exception-table coverage question: the
   outer's table must include every block reachable under the outer
   trap, including the inner handler's blocks. *)
let%expect_test "raise inside inner handler routes to outer" =
  compile_and_run
    {| exception A
       exception B of string
       let () =
         try
           (try raise A with A -> raise (B "from inner"))
         with B m -> print_endline m |};
  [%expect {| from inner |}]

(* Code that sits between an inner [Poptrap] (normal exit from inner
   try) and the outer's [Poptrap] is still under the outer trap —
   a raise there must be caught by the outer handler, not escape.

   The inner [try () with _ -> ()] completes normally and flows into
   the [failwith] below it; that failwith is protected by the outer. *)
let%expect_test "raise after inner poptrap still caught by outer" =
  compile_and_run
    {| let () =
         try
           (try () with _ -> ());
           failwith "after-inner"
         with Failure m -> print_endline m |};
  [%expect {| after-inner |}]
