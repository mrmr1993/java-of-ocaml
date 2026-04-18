open Util

let%expect_test "record passed through a function argument" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       type person = { name : string; age : int; score : int }
       let older_of a b = if a.age > b.age then a else b
       let bump p = { p with age = p.age + 1 }
       let () =
         let alice = { name = "Alice"; age = 30; score = 100 } in
         let bob = { name = "Bob"; age = 25; score = 90 } in
         let senior = older_of alice bob in
         caml_java_print_endline senior.name;
         let alice_next = bump alice in
         caml_java_print_int alice_next.age |};
  [%expect {|
    Alice
    31 |}]

let%expect_test "mutable record fields through function calls" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type counter = { mutable count : int; step : int }
       let make_counter step = { count = 0; step }
       let tick c = c.count <- c.count + c.step
       let get c = c.count
       let describe { count; step } = count * step
       let () =
         let c = make_counter 5 in
         tick c; tick c; tick c;
         caml_java_print_int (get c);
         caml_java_print_int (describe c) |};
  [%expect {|
    15
    75 |}]

let%expect_test "inline record in variant, with mutable field" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       type event =
         | Login of { user : string; time : int }
         | Payment of { amount : int; mutable confirmed : bool }
         | Noop
       let describe = function
         | Login { user; time } ->
             caml_java_print_endline user;
             caml_java_print_int time
         | Payment { amount; confirmed } ->
             caml_java_print_int amount;
             caml_java_print_int (if confirmed then 1 else 0)
         | Noop -> caml_java_print_int (-1)
       let confirm = function
         | Payment r -> r.confirmed <- true
         | _ -> ()
       let () =
         describe (Login { user = "alice"; time = 42 });
         let p = Payment { amount = 100; confirmed = false } in
         describe p;
         confirm p;
         describe p;
         describe Noop |};
  [%expect {|
    alice
    42
    100
    0
    100
    1
    -1 |}]

let%expect_test "polymorphic inline record in variant, with mutation and boolnot" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       type 'a node =
         | Item of { a : 'a; b : int; mutable c : bool }
         | Empty
       let read = function
         | Item r ->
             caml_java_print_int r.b;
             caml_java_print_int (if r.c then 1 else 0);
             r.c <- not r.c
         | Empty -> ()
       let () =
         let n = Item { a = "payload"; b = 7; c = false } in
         read n; read n;
         match n with
         | Item r -> caml_java_print_endline r.a
         | Empty -> () |};
  [%expect {|
    7
    0
    7
    1
    payload |}]

