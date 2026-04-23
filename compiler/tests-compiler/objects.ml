open Util

(* OCaml OO surface. These tests exercise the [MAKEBLOCK tag=248]
   object layout built by [CamlinternalOO], the
   [caml_set_oo_id] / [caml_fresh_oo_id] primitives, and the
   three method-dispatch opcodes [GETMETHOD] / [GETPUBMET] /
   [GETDYNMET]. the test binary's init path invokes object methods
   transitively through ppxlib visitors; these smaller
   reproductions keep the behaviour covered without pulling in
   the whole stdlib. *)

let%expect_test "bare class: instantiate and invoke one public method" =
  compile_and_run
    {| class c = object method m = 42 end
       let () = print_int (new c)#m |};
  [%expect {| 42 |}]

let%expect_test "class with instance variable + arg-taking method" =
  compile_and_run
    {| class counter init = object
         val mutable n = init
         method bump x = n <- n + x; n
         method peek = n
       end
       let () =
         let c = new counter 10 in
         let _ = c#bump 5 in
         let _ = c#bump 7 in
         print_int c#peek;
         print_newline () |};
  [%expect {| 22 |}]

let%expect_test "two objects share the same method table but have distinct state" =
  compile_and_run
    {| class box (init : int) = object
         val mutable v = init
         method get = v
         method set x = v <- x
       end
       let () =
         let a = new box 1 in
         let b = new box 2 in
         b#set 99;
         Printf.printf "%d %d\n" a#get b#get |};
  [%expect {| 1 99 |}]

let%expect_test "inheritance + overridden method dispatches via self" =
  compile_and_run
    {| class base = object (self)
         method label = "base"
         method greet = "hello from " ^ self#label
       end
       class child = object
         inherit base
         method! label = "child"
       end
       let () =
         Printf.printf "%s\n" (new base)#greet;
         Printf.printf "%s\n" (new child)#greet |};
  [%expect {|
    hello from base
    hello from child |}]

let%expect_test "visitor-shaped class (ppxlib-style)" =
  compile_and_run
    {| class visitor = object (_self)
         method visit_int x = x + 1
         method visit_list : 'a 'b. ('a -> 'b) -> 'a list -> 'b list =
           fun f xs -> List.map f xs
       end
       let () =
         let v = new visitor in
         let r = v#visit_list v#visit_int [1; 2; 3] in
         List.iter (Printf.printf "%d ") r;
         print_newline () |};
  [%expect {| 2 3 4 |}]
