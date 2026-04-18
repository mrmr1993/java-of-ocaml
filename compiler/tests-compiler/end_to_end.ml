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

let%expect_test "option match: Some vs None" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let describe = function
         | None -> 0
         | Some n -> n
       let () =
         caml_java_print_int (describe (Some 42));
         caml_java_print_int (describe None) |};
  [%expect {|
    42
    0 |}]

let%expect_test "enum variant: Red / Green / Blue" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type color = Red | Green | Blue
       let rank = function
         | Red -> 1
         | Green -> 2
         | Blue -> 3
       let () =
         caml_java_print_int (rank Red);
         caml_java_print_int (rank Green);
         caml_java_print_int (rank Blue) |};
  [%expect {|
    1
    2
    3 |}]

let%expect_test "variant with payload in closure capture" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let unwrap_or default = function
         | None -> default
         | Some n -> n
       let () =
         caml_java_print_int (unwrap_or 99 (Some 7));
         caml_java_print_int (unwrap_or 99 None) |};
  [%expect {|
    7
    99 |}]

let%expect_test "variant with mixed immediate and data constructors" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type tree = Leaf | Node of int
       let value_of = function
         | Leaf -> -1
         | Node n -> n
       let () =
         caml_java_print_int (value_of Leaf);
         caml_java_print_int (value_of (Node 17));
         caml_java_print_int (value_of (Node 42)) |};
  [%expect {|
    -1
    17
    42 |}]

let%expect_test "list sum and length" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec sum = function
         | [] -> 0
         | h :: t -> h + sum t
       let rec length = function
         | [] -> 0
         | _ :: t -> 1 + length t
       let () =
         caml_java_print_int (sum [1; 2; 3; 4; 5]);
         caml_java_print_int (length [10; 20; 30]);
         caml_java_print_int (sum []) |};
  [%expect {|
    15
    3
    0 |}]

let%expect_test "list iter with external primitive" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec iter f = function
         | [] -> ()
         | h :: t -> f h; iter f t
       let () = iter caml_java_print_int [1; 2; 3] |};
  [%expect {|
    1
    2
    3 |}]

let%expect_test "list map returning a new list" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec map f = function
         | [] -> []
         | h :: t -> f h :: map f t
       let rec iter f = function
         | [] -> ()
         | h :: t -> f h; iter f t
       let () =
         let doubled = map (fun x -> x * 2) [1; 2; 3; 4] in
         iter caml_java_print_int doubled |};
  [%expect {|
    2
    4
    6
    8 |}]

let%expect_test "list nth with sentinel fallback" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let rec nth xs i = match xs with
         | [] -> -1
         | h :: t -> if i = 0 then h else nth t (i - 1)
       let () =
         caml_java_print_int (nth [100; 200; 300; 400] 2);
         caml_java_print_int (nth [100; 200; 300; 400] 0);
         caml_java_print_int (nth [] 5) |};
  [%expect {|
    300
    100
    -1 |}]

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

let%expect_test "variant: multiple data constructors with different tags" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type shape = Circle of int | Square of int | Rectangle of int * int
       let area = function
         | Circle r -> 3 * r * r
         | Square s -> s * s
         | Rectangle (w, h) -> w * h
       let () =
         caml_java_print_int (area (Circle 5));
         caml_java_print_int (area (Square 4));
         caml_java_print_int (area (Rectangle (3, 7))) |};
  [%expect {|
    75
    16
    21 |}]

let%expect_test "recursive variant: binary tree sum" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type tree = Leaf | Node of tree * int * tree
       let rec sum = function
         | Leaf -> 0
         | Node (l, v, r) -> sum l + v + sum r
       let t =
         Node (Node (Leaf, 1, Node (Leaf, 2, Leaf)), 3, Node (Leaf, 4, Leaf))
       let () = caml_java_print_int (sum t) |};
  [%expect {| 10 |}]

let%expect_test "recursive variant: arithmetic expression evaluator" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type expr =
         | Num of int
         | Add of expr * expr
         | Mul of expr * expr
       let rec eval = function
         | Num n -> n
         | Add (a, b) -> eval a + eval b
         | Mul (a, b) -> eval a * eval b
       let () =
         caml_java_print_int (eval (Mul (Add (Num 2, Num 3), Num 4))) |};
  [%expect {| 20 |}]

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

let%expect_test "GADT: type-refined evaluator over int and pair expressions" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type _ expr =
         | Lit : int -> int expr
         | Pair : int expr * int expr -> (int * int) expr
         | Fst : (int * int) expr -> int expr
         | Snd : (int * int) expr -> int expr
         | Add : int expr * int expr -> int expr
       let rec eval : type a. a expr -> a = function
         | Lit n -> n
         | Pair (a, b) -> (eval a, eval b)
         | Fst e -> let (a, _) = eval e in a
         | Snd e -> let (_, b) = eval e in b
         | Add (a, b) -> eval a + eval b
       let () =
         caml_java_print_int (eval (Add (Lit 10, Lit 32)));
         caml_java_print_int (eval (Fst (Pair (Lit 7, Lit 99))));
         caml_java_print_int (eval (Snd (Pair (Lit 7, Lit 99)))) |};
  [%expect {|
    42
    7
    99 |}]

let%expect_test "GADT: length-indexed vector sum and length" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type z = Z
       type 'n s = S of 'n
       type (_, _) vec =
         | Nil  : (z, 'a) vec
         | Cons : 'a * ('n, 'a) vec -> ('n s, 'a) vec
       let rec sum : type n. (n, int) vec -> int = function
         | Nil -> 0
         | Cons (h, t) -> h + sum t
       let rec length : type n a. (n, a) vec -> int = function
         | Nil -> 0
         | Cons (_, t) -> 1 + length t
       let () =
         let v = Cons (10, Cons (20, Cons (30, Nil))) in
         caml_java_print_int (sum v);
         caml_java_print_int (length v) |};
  [%expect {|
    60
    3 |}]

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

let%expect_test "extensible type with positional, tuple and inline-record constructors" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       type shape = ..
       type shape += Circle of int
       type shape += Square of int
       type shape += Rectangle of int * int
       let area = function
         | Circle r -> 3 * r * r
         | Square s -> s * s
         | Rectangle (w, h) -> w * h
         | _ -> -1
       type shape += Labelled of { name : string; size : int }
       let name_of = function
         | Circle _ -> "circle"
         | Labelled { name; _ } -> name
         | _ -> "other"
       let () =
         caml_java_print_int (area (Circle 5));
         caml_java_print_int (area (Square 4));
         caml_java_print_int (area (Rectangle (3, 7)));
         caml_java_print_int (area (Labelled { name = "x"; size = 1 }));
         caml_java_print_endline (name_of (Circle 1));
         caml_java_print_endline (name_of (Square 2));
         caml_java_print_endline (name_of (Labelled { name = "tag"; size = 99 })) |};
  [%expect {|
    75
    16
    21
    -1
    circle
    other
    tag |}]

let%expect_test "4-arg function (PUSH_RETADDR + apply4)" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let f a b c d = a + b + c + d
       let () = caml_java_print_int (f 1 2 3 4) |};
  [%expect {| 10 |}]

let%expect_test "5-, 6-, and 7-arg functions" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let f5 a b c d e = a + b + c + d + e
       let f6 a b c d e f = a + b + c + d + e + f
       let f7 a b c d e f g = a + b + c + d + e + f + g
       let () =
         caml_java_print_int (f5 1 2 3 4 5);
         caml_java_print_int (f6 1 2 3 4 5 6);
         caml_java_print_int (f7 1 2 3 4 5 6 7) |};
  [%expect {|
    15
    21
    28 |}]

let%expect_test "partial application: 3-arg function called with 2 args then 1" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let add3 a b c = a + b + c
       let inc = add3 1 2
       let () =
         caml_java_print_int (add3 10 20 30);
         caml_java_print_int (inc 100);
         caml_java_print_int (inc 5) |};
  [%expect {|
    60
    103
    8 |}]

let%expect_test "partial application: 4-arg function applied in several stages" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let f a b c d = a * 1000 + b * 100 + c * 10 + d
       let () =
         caml_java_print_int (f 1 2 3 4);
         let g = f 1 in
         caml_java_print_int (g 2 3 4);
         let h = g 2 in
         caml_java_print_int (h 3 4);
         let k = h 3 in
         caml_java_print_int (k 4) |};
  [%expect {|
    1234
    1234
    1234
    1234 |}]

let%expect_test "extensible type: match falls through to catch-all for a later constructor" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       type op = ..
       type op += Add of int * int
       type op += Mul of int * int
       let original = function
         | Add (a, b) -> a + b
         | Mul (a, b) -> a * b
         | _ -> -1  (* catch-all — later constructors hit this *)
       type op += Neg of int
       let extended = function
         | Neg a -> 0 - a
         | other -> original other
       let () =
         caml_java_print_int (extended (Add (3, 4)));
         caml_java_print_int (extended (Mul (5, 6)));
         caml_java_print_int (extended (Neg 7)) |};
  [%expect {|
    7
    30
    -7 |}]

let%expect_test "polymorphic variant with zero-arg and data cases" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       let describe = function
         | `Red -> 1
         | `Green -> 2
         | `Blue -> 3
         | `Rgb (r, _, _) -> r
       let () =
         caml_java_print_int (describe `Red);
         caml_java_print_int (describe `Blue);
         caml_java_print_int (describe (`Rgb (42, 0, 0))) |};
  [%expect {|
    1
    3
    42 |}]

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
