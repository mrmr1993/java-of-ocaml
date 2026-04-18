open Util

let%expect_test "module: basic structure with values, let-bindings, and functions" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       module M = struct
         let x = 42
         let y = "hello"
         let add a b = a + b
       end
       let () =
         caml_java_print_int M.x;
         caml_java_print_endline M.y;
         caml_java_print_int (M.add 3 4) |};
  [%expect {|
    42
    hello
    7 |}]

let%expect_test "module: signature hiding a helper function" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module M : sig
         val public : int -> int
       end = struct
         let bump x = x + 1
         let helper x = bump (bump x)
         let public x = helper x * 10
       end
       let () = caml_java_print_int (M.public 3) |};
  [%expect {| 50 |}]

let%expect_test "module: nested modules, accessed with dotted paths" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       module Outer = struct
         let name = "outer"
         module Inner = struct
           let x = 100
           let label () = name
         end
         module Deeper = struct
           module Deepest = struct
             let answer = 42
           end
         end
       end
       let () =
         caml_java_print_int Outer.Inner.x;
         caml_java_print_endline (Outer.Inner.label ());
         caml_java_print_int Outer.Deeper.Deepest.answer |};
  [%expect {|
    100
    outer
    42 |}]

let%expect_test "module: aliases and [open]" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module M = struct let x = 10 end
       module Alias = M
       module Util = struct
         let double n = n * 2
         let triple n = n * 3
       end
       open Util
       let () =
         caml_java_print_int Alias.x;
         caml_java_print_int (double 7);
         caml_java_print_int (triple 7) |};
  [%expect {|
    10
    14
    21 |}]

let%expect_test "module: local opens — [let open … in] and [M.(…)]" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module M = struct
         let x = 5
         let f n = n + 100
       end
       let a = let open M in f x
       let b = M.(f x)
       let compute () =
         let open M in
         let y = f x in f y
       let () =
         caml_java_print_int a;
         caml_java_print_int b;
         caml_java_print_int (compute ()) |};
  [%expect {|
    105
    105
    205 |}]

let%expect_test "module: exporting a variant type and its constructors" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       external caml_java_print_endline : string -> unit = "caml_java_print_endline"
       module Shape = struct
         type t = Circle of int | Rect of int * int
         let area = function
           | Circle r -> 3 * r * r
           | Rect (w, h) -> w * h
         let describe = function
           | Circle _ -> "circle"
           | Rect _ -> "rectangle"
       end
       open Shape
       let () =
         let c = Circle 5 in
         let r = Rect (3, 4) in
         caml_java_print_int (area c);
         caml_java_print_int (area r);
         caml_java_print_endline (describe c);
         caml_java_print_endline (describe r) |};
  [%expect {|
    75
    12
    circle
    rectangle |}]

let%expect_test "module: exporting an exception, raised and caught across module boundary" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module Err = struct
         exception Boom of int
         let may_fail n = if n < 0 then raise (Boom n) else n * 2
       end
       let safe n =
         try Err.may_fail n with
         | Err.Boom k -> k - 1000
       let () =
         caml_java_print_int (safe 10);
         caml_java_print_int (safe (-5)) |};
  [%expect {|
    20
    -1005 |}]

let%expect_test "module: opaque abstract type (Counter with mutable state)" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module Counter : sig
         type t
         val make : unit -> t
         val bump : t -> int -> unit
         val peek : t -> int
       end = struct
         type t = { mutable count : int }
         let make () = { count = 0 }
         let bump c n = c.count <- c.count + n
         let peek c = c.count
       end
       let () =
         let c = Counter.make () in
         Counter.bump c 5;
         Counter.bump c 3;
         caml_java_print_int (Counter.peek c) |};
  [%expect {| 8 |}]

let%expect_test "module: [include] re-exports bindings" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module Base = struct
         let a = 10
         let b = 20
       end
       module Extended = struct
         include Base
         let c = 30
         let sum () = a + b + c
       end
       let () =
         caml_java_print_int Extended.a;
         caml_java_print_int Extended.b;
         caml_java_print_int Extended.c;
         caml_java_print_int (Extended.sum ()) |};
  [%expect {|
    10
    20
    30
    60 |}]

let%expect_test "functor: single-argument fold over a monoid" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module type Monoid = sig
         type t
         val zero : t
         val combine : t -> t -> t
       end
       module IntAdd : Monoid with type t = int = struct
         type t = int
         let zero = 0
         let combine a b = a + b
       end
       module Fold (M : Monoid) = struct
         let rec fold_list = function
           | [] -> M.zero
           | h :: t -> M.combine h (fold_list t)
       end
       module IntFold = Fold (IntAdd)
       let () = caml_java_print_int (IntFold.fold_list [1; 2; 3; 4; 5]) |};
  [%expect {| 15 |}]

let%expect_test "functor: multi-argument (curried)" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module type T = sig val x : int end
       module F (A : T) (B : T) = struct
         let sum = A.x + B.x
         let product = A.x * B.x
       end
       module Three = struct let x = 3 end
       module Five = struct let x = 5 end
       module R = F (Three) (Five)
       let () =
         caml_java_print_int R.sum;
         caml_java_print_int R.product |};
  [%expect {|
    8
    15 |}]

let%expect_test "functor: generative [()] argument produces fresh state per application" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module type Fresh = sig type t val make : int -> t val get : t -> int end
       module MakeCell () : Fresh = struct
         type t = { mutable v : int }
         let make n = { v = n }
         let get c = c.v
       end
       module A = MakeCell ()
       module B = MakeCell ()
       let () =
         let a = A.make 10 in
         let b = B.make 20 in
         caml_java_print_int (A.get a);
         caml_java_print_int (B.get b) |};
  [%expect {|
    10
    20 |}]

let%expect_test "functor: result includes the argument module and adds new bindings" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module type HasX = sig val x : int end
       module MakeWithBump (M : HasX) = struct
         include M
         let bumped = M.x + 1
       end
       module Three = struct let x = 3 end
       module BumpedThree = MakeWithBump (Three)
       let () =
         caml_java_print_int BumpedThree.x;
         caml_java_print_int BumpedThree.bumped |};
  [%expect {|
    3
    4 |}]

let%expect_test "module type: [with type t = …] and [with type t := …] \
                 (destructive substitution)" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module type Container = sig
         type t
         val empty : t
         val add : int -> t -> t
         val total : t -> int
       end
       module ListContainer : Container with type t = int list = struct
         type t = int list
         let empty = []
         let add x xs = x :: xs
         let rec total = function [] -> 0 | h :: t -> h + total t
       end
       module type Base = sig
         type t
         val make : int -> t
         val val_of : t -> int
       end
       module type IntBase = Base with type t := int
       module M : IntBase = struct
         let make x = x * 2
         let val_of x = x
       end
       let () =
         let c = ListContainer.(add 1 (add 2 (add 3 empty))) in
         caml_java_print_int (ListContainer.total c);
         caml_java_print_int (M.val_of (M.make 21)) |};
  [%expect {|
    6
    42 |}]

let%expect_test "module type of: signature derived from an existing module" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module Original = struct
         let x = 10
         let f n = n * 2
       end
       module type OriginalSig = module type of Original
       module Shadow : OriginalSig = struct
         let x = 100
         let f n = n * 3
       end
       let () =
         caml_java_print_int Original.x;
         caml_java_print_int (Original.f 5);
         caml_java_print_int Shadow.x;
         caml_java_print_int (Shadow.f 5) |};
  [%expect {|
    10
    10
    100
    15 |}]

let%expect_test "first-class module: packed and unpacked via a [(module S)] pattern" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module type Show = sig
         type t
         val value : t
         val show : t -> int
       end
       module I : Show with type t = int = struct
         type t = int
         let value = 42
         let show x = x
       end
       module Doubled : Show with type t = int = struct
         type t = int
         let value = 21
         let show x = x * 2
       end
       let print_show (type a) (module S : Show with type t = a) =
         caml_java_print_int (S.show S.value)
       let () =
         print_show (module I);
         print_show (module Doubled) |};
  [%expect {|
    42
    42 |}]

let%expect_test "first-class module: stored in a list and pattern-matched in [unpack ::]" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module type Num = sig val v : int end
       let pack_and_sum (list : (module Num) list) =
         let rec go acc = function
           | [] -> acc
           | (module N : Num) :: t -> go (acc + N.v) t
         in go 0 list
       module A = struct let v = 1 end
       module B = struct let v = 10 end
       module C = struct let v = 100 end
       let () =
         caml_java_print_int
           (pack_and_sum [(module A); (module B); (module C)]) |};
  [%expect {| 111 |}]

let%expect_test "nested functor application: [F (A).Inner (B)]" =
  compile_and_run
    {| external caml_java_print_int : int -> unit = "caml_java_print_int"
       module type Num = sig val v : int end
       module Add (A : Num) = struct
         module Inner (B : Num) = struct
           let sum = A.v + B.v
         end
       end
       module Seven = struct let v = 7 end
       module Three = struct let v = 3 end
       module Result = Add (Seven)
       module Final = Result.Inner (Three)
       let () = caml_java_print_int Final.sum |};
  [%expect {| 10 |}]
