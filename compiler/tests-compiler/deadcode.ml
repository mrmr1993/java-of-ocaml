(* Deadcode pass: reachability pruning + dead-Let removal.

   Pin the pass's behaviour on small synthetic programs built
   against [Code] directly, so regressions in the drop-condition
   ([pure_expr], use counting) surface as a diff rather than as a
   whole-program correctness bug. *)

open Java_of_ocaml_compiler
module Code = Code

let run_and_report prog =
  let prog, { Deadcode.deleted_blocks; deleted_instrs } =
    Deadcode.run prog
  in
  Format.printf
    "deleted_blocks=%d deleted_instrs=%d remaining_blocks=%d@."
    deleted_blocks
    deleted_instrs
    (Code.Addr.Map.cardinal prog.blocks);
  Code.Print.program Format.std_formatter prog

(* Three blocks in a row: start -> a -> ret, plus an orphan block
   [o] with no inbound edge. Expect [o] pruned. *)
let%expect_test "prune_unreachable drops orphan blocks" =
  Code.Var.reset ();
  let x = Code.Var.fresh_n "x" in
  let y = Code.Var.fresh_n "y" in
  let blocks =
    Code.Addr.Map.empty
    |> Code.Addr.Map.add
         0
         { Code.params = []
         ; body = [ Let (x, Constant (Int 1)) ]
         ; branch = Branch (1, [ x ])
         }
    |> Code.Addr.Map.add
         1
         { Code.params = [ y ]
         ; body = []
         ; branch = Return y
         }
    |> Code.Addr.Map.add
         99
         { Code.params = []
         ; body = [ Let (Code.Var.fresh_n "zombie", Constant (Int 42)) ]
         ; branch = Stop
         }
  in
  let prog = { Code.start = 0; blocks; free_pc = 100 } in
  run_and_report prog;
  [%expect
    {|
    deleted_blocks=1 deleted_instrs=0 remaining_blocks=2
    program (start = 0):
    block 0():
      let x_0 = 1
      branch 1(x_0)
    block 1(y_1):
      return y_1
    |}]

(* One live [Let] (result used in [Return]) and one dead [Let]
   (result unused, expression pure). Expect the dead one removed. *)
let%expect_test "drop_dead_lets removes unused pure bindings" =
  Code.Var.reset ();
  let live = Code.Var.fresh_n "live" in
  let dead = Code.Var.fresh_n "dead" in
  let blocks =
    Code.Addr.Map.singleton
      0
      { Code.params = []
      ; body =
          [ Let (live, Constant (Int 7))
          ; Let (dead, Constant (Int 99))
          ]
      ; branch = Return live
      }
  in
  let prog = { Code.start = 0; blocks; free_pc = 1 } in
  run_and_report prog;
  [%expect
    {|
    deleted_blocks=0 deleted_instrs=1 remaining_blocks=1
    program (start = 0):
    block 0():
      let live_0 = 7
      return live_0
    |}]

(* A [Let] whose RHS is a [Prim (Extern _, _)] named in
   [Pure_fun]'s allow-list is dropped when the bound var is
   unused. [caml_compare] is on the list; [caml_ml_flush] is not. *)
let%expect_test "drop_dead_lets removes unused known-pure externs" =
  Code.Var.reset ();
  let unused = Code.Var.fresh_n "unused" in
  let a = Code.Var.fresh_n "a" in
  let b = Code.Var.fresh_n "b" in
  let blocks =
    Code.Addr.Map.singleton
      0
      { Code.params = [ a; b ]
      ; body =
          [ Let (unused, Prim (Extern "caml_compare", [ Pv a; Pv b ])) ]
      ; branch = Stop
      }
  in
  let prog = { Code.start = 0; blocks; free_pc = 1 } in
  run_and_report prog;
  [%expect
    {|
    deleted_blocks=0 deleted_instrs=1 remaining_blocks=1
    program (start = 0):
    block 0(a_1, b_2):
      stop
    |}]

(* A [Let] whose RHS is a [Prim (Extern _, _)] is conservatively
   kept even when the bound var is unused — we don't know if the
   primitive has a side effect. *)
let%expect_test "drop_dead_lets keeps unused externs (unknown purity)" =
  Code.Var.reset ();
  let unused = Code.Var.fresh_n "unused" in
  let v = Code.Var.fresh_n "v" in
  let blocks =
    Code.Addr.Map.singleton
      0
      { Code.params = [ v ]
      ; body =
          [ Let (unused, Prim (Extern "caml_ml_flush", [ Pv v ])) ]
      ; branch = Stop
      }
  in
  let prog = { Code.start = 0; blocks; free_pc = 1 } in
  run_and_report prog;
  [%expect
    {|
    deleted_blocks=0 deleted_instrs=0 remaining_blocks=1
    program (start = 0):
    block 0(v_1):
      let unused_0 = %caml_ml_flush(v_1)
      stop
    |}]
