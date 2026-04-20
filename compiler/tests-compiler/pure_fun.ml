(* Pure_fun: closure-purity analysis. Feeds [Deadcode] so that
   [Apply { exact = true; f; _ }] with [f] in the pure-set, and
   unused calls to allow-listed C primitives, can be removed. *)

open Java_of_ocaml_compiler
module Code = Code

let report prog =
  let set = Pure_fun.f prog in
  let vars = Code.Var.Set.elements set in
  Format.printf
    "pure funs: [%s]@."
    (String.concat "; "
       (List.map
          (fun v ->
            Format.asprintf "%a" Code.Var.print v)
          vars))

(* [Closure f] whose body just returns a constant — observably pure. *)
let%expect_test "closure returning a constant is pure" =
  Code.Var.reset ();
  let f = Code.Var.fresh_n "f" in
  let x = Code.Var.fresh_n "x" in
  let k = Code.Var.fresh_n "k" in
  let blocks =
    Code.Addr.Map.empty
    |> Code.Addr.Map.add
         10
         { Code.params = [ x ]
         ; body = [| Let (k, Constant (Int 0)) |]
         ; branch = Return k
         }
    |> Code.Addr.Map.add
         0
         { Code.params = []
         ; body = [| Let (f, Closure { captures = []; body = 10, [] }) |]
         ; branch = Stop
         }
  in
  report { Code.start = 0; blocks; free_pc = 11 };
  [%expect {| pure funs: [f_0] |}]

(* [Closure f] whose body [Raise]s — impure. *)
let%expect_test "closure that raises is impure" =
  Code.Var.reset ();
  let f = Code.Var.fresh_n "f" in
  let x = Code.Var.fresh_n "x" in
  let blocks =
    Code.Addr.Map.empty
    |> Code.Addr.Map.add
         10
         { Code.params = [ x ]; body = [||]; branch = Raise x }
    |> Code.Addr.Map.add
         0
         { Code.params = []
         ; body = [| Let (f, Closure { captures = []; body = 10, [] }) |]
         ; branch = Stop
         }
  in
  report { Code.start = 0; blocks; free_pc = 11 };
  [%expect {| pure funs: [] |}]

(* Closure body that calls an impure C primitive — impure. *)
let%expect_test "closure calling an impure extern is impure" =
  Code.Var.reset ();
  let f = Code.Var.fresh_n "f" in
  let x = Code.Var.fresh_n "x" in
  let y = Code.Var.fresh_n "y" in
  let blocks =
    Code.Addr.Map.empty
    |> Code.Addr.Map.add
         10
         { Code.params = [ x ]
         ; body = [| Let (y, Prim (Extern "caml_ml_flush", [ Pv x ])) |]
         ; branch = Return y
         }
    |> Code.Addr.Map.add
         0
         { Code.params = []
         ; body = [| Let (f, Closure { captures = []; body = 10, [] }) |]
         ; branch = Stop
         }
  in
  report { Code.start = 0; blocks; free_pc = 11 };
  [%expect {| pure funs: [] |}]

(* Closure body that calls an allow-listed pure extern — pure. *)
let%expect_test "closure calling caml_compare is pure" =
  Code.Var.reset ();
  let f = Code.Var.fresh_n "f" in
  let x = Code.Var.fresh_n "x" in
  let y = Code.Var.fresh_n "y" in
  let blocks =
    Code.Addr.Map.empty
    |> Code.Addr.Map.add
         10
         { Code.params = [ x ]
         ; body = [| Let (y, Prim (Extern "caml_compare", [ Pv x; Pv x ])) |]
         ; branch = Return y
         }
    |> Code.Addr.Map.add
         0
         { Code.params = []
         ; body = [| Let (f, Closure { captures = []; body = 10, [] }) |]
         ; branch = Stop
         }
  in
  report { Code.start = 0; blocks; free_pc = 11 };
  [%expect {| pure funs: [f_0] |}]
