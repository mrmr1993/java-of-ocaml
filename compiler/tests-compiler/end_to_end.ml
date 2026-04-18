open Util

let%expect_test "hello world via bytecode" =
  compile_and_run_bytecode {| print_endline "hello world" |};
  [%expect {| hello world |}]

let%expect_test "arithmetic via bytecode" =
  compile_and_run_bytecode {| print_int (1 + 2); print_newline () |};
  [%expect {| 3 |}]

let%expect_test "string concatenation via bytecode" =
  compile_and_run_bytecode {| print_endline ("foo" ^ "bar") |};
  [%expect {| foobar |}]

let%expect_test "list operations via bytecode" =
  compile_and_run_bytecode
    {| List.iter (fun x -> Printf.printf "%d " x) [1; 2; 3]; print_newline () |};
  [%expect {| 1 2 3 |}]

let%expect_test "hello via custom primitive compiled to JVM" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () = caml_java_print_endline "hello" |};
  [%expect {| hello |}]

let%expect_test "int literal via custom primitive" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int 42 |};
  [%expect {| 42 |}]

let%expect_test "int arithmetic via custom primitive" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int (1 + 2) |};
  [%expect {| 3 |}]

let%expect_test "mixing int and string primitives" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () = caml_java_print_endline "answer:"
       let () = caml_java_print_int (40 + 2) |};
  [%expect {|
    answer:
    42 |}]

let%expect_test "chained int arithmetic" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () = caml_java_print_int (10 + 20 + 3)
       let () = caml_java_print_int (5 * 6)
       let () = caml_java_print_int (100 - 58) |};
  [%expect {|
    33
    30
    42 |}]

let%expect_test "if/else with int comparison" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         if 0 < 1 then caml_java_print_int 1
         else caml_java_print_int 2 |};
  [%expect {| 1 |}]

let%expect_test "if/else taking the else branch" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         if 5 < 3 then caml_java_print_int 100
         else caml_java_print_int 200 |};
  [%expect {| 200 |}]

let%expect_test "if/else with arithmetic in branches" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         if 2 * 3 = 6 then caml_java_print_int (10 + 1)
         else caml_java_print_int (10 - 1) |};
  [%expect {| 11 |}]

let%expect_test "if/else with string branches" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () =
         if 1 = 1 then caml_java_print_endline "yes"
         else caml_java_print_endline "no" |};
  [%expect {| yes |}]

let%expect_test "single let-binding" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 10 in
         caml_java_print_int (x + 5) |};
  [%expect {| 15 |}]

let%expect_test "nested let-bindings" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 10 in
         let y = 20 in
         caml_java_print_int (x + y) |};
  [%expect {| 30 |}]

let%expect_test "let + dynamic comparison" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 10 in
         if x < 5 then caml_java_print_int x
         else caml_java_print_int (x + 1) |};
  [%expect {| 11 |}]

let%expect_test "let + subtraction" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let a = 100 in
         let b = 58 in
         caml_java_print_int (a - b) |};
  [%expect {| 42 |}]

let%expect_test "min of two let bindings" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 5 in
         let y = 10 in
         if x < y then caml_java_print_int x
         else caml_java_print_int y |};
  [%expect {| 5 |}]

let%expect_test "recursive fibonacci" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec fib n = if n < 2 then n else fib (n - 1) + fib (n - 2)
       let () = caml_java_print_int (fib 10) |};
  [%expect {| 55 |}]

let%expect_test "fib of small values" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec fib n = if n < 2 then n else fib (n - 1) + fib (n - 2)
       let () =
         caml_java_print_int (fib 0);
         caml_java_print_int (fib 1);
         caml_java_print_int (fib 5);
         caml_java_print_int (fib 15) |};
  [%expect {|
    0
    1
    5
    610 |}]

let%expect_test "non-recursive two-arg function" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let add a b = a + b
       let () = caml_java_print_int (add 3 5) |};
  [%expect {| 8 |}]

let%expect_test "non-recursive three-arg function" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let sum3 a b c = a + b + c
       let () = caml_java_print_int (sum3 10 20 30) |};
  [%expect {| 60 |}]

let%expect_test "recursive gcd" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec gcd a b = if b = 0 then a else gcd b (a - b * (a / b))
       let () = caml_java_print_int (gcd 48 18) |};
  [%expect {| 6 |}]

let%expect_test "recursive power" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec pow base n = if n = 0 then 1 else base * pow base (n - 1)
       let () = caml_java_print_int (pow 2 10) |};
  [%expect {| 1024 |}]

let%expect_test "closure with a single capture" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 42 in
         let f y = x + y in
         caml_java_print_int (f 3);
         caml_java_print_int (f 100) |};
  [%expect {|
    45
    142 |}]

let%expect_test "recursive closure with a capture" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 42 in
         let rec f n = if n = 0 then x else f (n - 1) + x in
         caml_java_print_int (f 5) |};
  [%expect {| 252 |}]

let%expect_test "closure with multiple captures" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let a = 3 in
         let b = 7 in
         let c = 11 in
         let f n = a * n + b * n + c * n in
         caml_java_print_int (f 2);
         caml_java_print_int (f 10) |};
  [%expect {|
    42
    210 |}]

let%expect_test "local ref with := and !" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let r = ref 5 in
         caml_java_print_int !r;
         r := 10;
         caml_java_print_int !r;
         r := !r + 7;
         caml_java_print_int !r |};
  [%expect {|
    5
    10
    17 |}]

let%expect_test "ref captured in a closure (counter)" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let counter = ref 0 in
         let bump () = counter := !counter + 1 in
         bump (); bump (); bump (); bump ();
         caml_java_print_int !counter |};
  [%expect {| 4 |}]

let%expect_test "incr/decr on a captured ref" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let r = ref 100 in
         let inc () = incr r in
         let dec () = decr r in
         inc (); inc (); inc (); dec ();
         caml_java_print_int !r |};
  [%expect {| 102 |}]

let%expect_test "constant tuple destructured" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let t = (10, 20, 30) in
         let (a, b, c) = t in
         caml_java_print_int (a + b + c) |};
  [%expect {| 60 |}]

let%expect_test "dynamic tuple from let bindings" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let x = 10 in
         let t = (x, x + 5, x * 2) in
         let (a, b, c) = t in
         caml_java_print_int (a + b + c) |};
  [%expect {| 45 |}]

let%expect_test "record with multiple fields" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type point = { x : int; y : int }
       let () =
         let p = { x = 3; y = 4 } in
         caml_java_print_int (p.x + p.y) |};
  [%expect {| 7 |}]

let%expect_test "mutable record field" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type counter = { mutable n : int }
       let () =
         let c = { n = 0 } in
         c.n <- 10;
         c.n <- c.n + 5;
         caml_java_print_int c.n |};
  [%expect {| 15 |}]

let%expect_test "array read/write/length" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let a = [| 10; 20; 30; 40 |] in
         a.(1) <- 99;
         caml_java_print_int a.(0);
         caml_java_print_int a.(1);
         caml_java_print_int a.(3);
         caml_java_print_int (Array.length a) |};
  [%expect {|
    10
    99
    40
    4 |}]

let%expect_test "sum an array" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let a = [| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 |] in
         let total = ref 0 in
         for i = 0 to Array.length a - 1 do
           total := !total + a.(i)
         done;
         caml_java_print_int !total |};
  [%expect {| 55 |}]

let%expect_test "tuple of int and ref" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let r = ref 5 in
         let p = (42, r) in
         let (n, r2) = p in
         r2 := !r2 + 100;
         caml_java_print_int (n + !r) |};
  [%expect {| 147 |}]

let%expect_test "record with int and ref fields" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type thing = { k : int; v : int ref }
       let () =
         let t = { k = 7; v = ref 11 } in
         t.v := !(t.v) * t.k;
         caml_java_print_int !(t.v) |};
  [%expect {| 77 |}]

let%expect_test "array of refs" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let arr = [| ref 1; ref 2; ref 3 |] in
         for i = 0 to Array.length arr - 1 do
           incr arr.(i)
         done;
         caml_java_print_int !(arr.(0));
         caml_java_print_int !(arr.(1));
         caml_java_print_int !(arr.(2)) |};
  [%expect {|
    2
    3
    4 |}]

let%expect_test "nested tuples" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let () =
         let inner = (3, 4) in
         let outer = (inner, 5) in
         let ((a, b), c) = outer in
         caml_java_print_int (a + b + c) |};
  [%expect {| 12 |}]

let%expect_test "higher-order: mkadder" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let mkadder x = (fun y -> x + y)
       let () =
         let add10 = mkadder 10 in
         caml_java_print_int (add10 5);
         caml_java_print_int (add10 25) |};
  [%expect {|
    15
    35 |}]

let%expect_test "higher-order: composition" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let mkmul k = (fun x -> k * x)
       let mkadd d = (fun x -> x + d)
       let () =
         let double = mkmul 2 in
         let plus3 = mkadd 3 in
         caml_java_print_int (double 7);
         caml_java_print_int (plus3 7);
         caml_java_print_int (double (plus3 5)) |};
  [%expect {|
    14
    10
    16 |}]

let%expect_test "string field in tuple" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () =
         let p = ("answer is", 42) in
         let (s, n) = p in
         caml_java_print_endline s;
         caml_java_print_int n |};
  [%expect {|
    answer is
    42 |}]

let%expect_test "record with string and int fields" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       type labeled = { name : string; value : int }
       let () =
         let r = { name = "pi"; value = 314 } in
         caml_java_print_endline r.name;
         caml_java_print_int r.value |};
  [%expect {|
    pi
    314 |}]

let%expect_test "closure taking a string arg" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () =
         let greet name = caml_java_print_endline name in
         greet "world";
         greet "ocaml" |};
  [%expect {|
    world
    ocaml |}]

let%expect_test "closure capturing a string" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let mkgreeter name = (fun () -> caml_java_print_endline name)
       let () =
         let hi = mkgreeter "hello world" in
         hi (); hi () |};
  [%expect {|
    hello world
    hello world |}]

let%expect_test "array of strings" =
  compile_and_run
    {| external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       let () =
         let a = [| "one"; "two"; "three" |] in
         for i = 0 to Array.length a - 1 do
           caml_java_print_endline a.(i)
         done |};
  [%expect {|
    one
    two
    three |}]
