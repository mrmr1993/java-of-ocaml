open Util

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
