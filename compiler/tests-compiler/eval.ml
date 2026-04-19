(* Block-local constant folding ([Eval]): pin behaviour on small
   hand-built [Code.program]s so regressions in the folders are
   obvious diffs rather than downstream codegen surprises. *)

open Java_of_ocaml_compiler
module Code = Code

let run_and_report prog =
  let prog, { Eval.folded } = Eval.run prog in
  Format.printf "folded=%d@." folded;
  Code.Print.program Format.std_formatter prog

let%expect_test "fold add_int on two constants" =
  Code.Var.reset ();
  let a = Code.Var.fresh_n "a" in
  let b = Code.Var.fresh_n "b" in
  let s = Code.Var.fresh_n "s" in
  let blocks =
    Code.Addr.Map.singleton
      0
      { Code.params = []
      ; body =
          [ Let (a, Constant (Int 3))
          ; Let (b, Constant (Int 4))
          ; Let (s, Prim (Extern "add_int", [ Pv a; Pv b ]))
          ]
      ; branch = Return s
      }
  in
  let prog = { Code.start = 0; blocks; free_pc = 1 } in
  run_and_report prog;
  [%expect
    {|
    folded=1
    program (start = 0):
    block 0():
      let a_0 = 3
      let b_1 = 4
      let s_2 = 7
      return s_2
    |}]

let%expect_test "fold chained arithmetic in a single block" =
  Code.Var.reset ();
  let a = Code.Var.fresh_n "a" in
  let b = Code.Var.fresh_n "b" in
  let c = Code.Var.fresh_n "c" in
  let s1 = Code.Var.fresh_n "s1" in
  let s2 = Code.Var.fresh_n "s2" in
  let blocks =
    Code.Addr.Map.singleton
      0
      { Code.params = []
      ; body =
          [ Let (a, Constant (Int 10))
          ; Let (b, Constant (Int 3))
          ; Let (c, Constant (Int 2))
          ; Let (s1, Prim (Extern "mul_int", [ Pv b; Pv c ]))
          ; Let (s2, Prim (Extern "add_int", [ Pv a; Pv s1 ]))
          ]
      ; branch = Return s2
      }
  in
  let prog = { Code.start = 0; blocks; free_pc = 1 } in
  run_and_report prog;
  [%expect
    {|
    folded=2
    program (start = 0):
    block 0():
      let a_0 = 10
      let b_1 = 3
      let c_2 = 2
      let s1_3 = 6
      let s2_4 = 16
      return s2_4
    |}]

let%expect_test "don't fold when args aren't both constants" =
  Code.Var.reset ();
  let a = Code.Var.fresh_n "a" in
  let b = Code.Var.fresh_n "b" in
  let s = Code.Var.fresh_n "s" in
  let blocks =
    Code.Addr.Map.singleton
      0
      { Code.params = [ a ]
      ; body =
          [ Let (b, Constant (Int 5))
          ; Let (s, Prim (Extern "add_int", [ Pv a; Pv b ]))
          ]
      ; branch = Return s
      }
  in
  let prog = { Code.start = 0; blocks; free_pc = 1 } in
  run_and_report prog;
  [%expect
    {|
    folded=0
    program (start = 0):
    block 0(a_0):
      let b_1 = 5
      let s_2 = %add_int(a_0, b_1)
      return s_2
    |}]

let%expect_test "don't fold div_int by zero" =
  Code.Var.reset ();
  let a = Code.Var.fresh_n "a" in
  let b = Code.Var.fresh_n "b" in
  let q = Code.Var.fresh_n "q" in
  let blocks =
    Code.Addr.Map.singleton
      0
      { Code.params = []
      ; body =
          [ Let (a, Constant (Int 6))
          ; Let (b, Constant (Int 0))
          ; Let (q, Prim (Extern "div_int", [ Pv a; Pv b ]))
          ]
      ; branch = Return q
      }
  in
  let prog = { Code.start = 0; blocks; free_pc = 1 } in
  run_and_report prog;
  [%expect
    {|
    folded=0
    program (start = 0):
    block 0():
      let a_0 = 6
      let b_1 = 0
      let q_2 = %div_int(a_0, b_1)
      return q_2
    |}]

let%expect_test "comparison on ints collapses to 0/1" =
  Code.Var.reset ();
  let a = Code.Var.fresh_n "a" in
  let b = Code.Var.fresh_n "b" in
  let lt = Code.Var.fresh_n "lt" in
  let eq = Code.Var.fresh_n "eq" in
  let blocks =
    Code.Addr.Map.singleton
      0
      { Code.params = []
      ; body =
          [ Let (a, Constant (Int 2))
          ; Let (b, Constant (Int 5))
          ; Let (lt, Prim (Lt, [ Pv a; Pv b ]))
          ; Let (eq, Prim (Eq, [ Pv a; Pv b ]))
          ]
      ; branch = Return lt
      }
  in
  let prog = { Code.start = 0; blocks; free_pc = 1 } in
  run_and_report prog;
  [%expect
    {|
    folded=2
    program (start = 0):
    block 0():
      let a_0 = 2
      let b_1 = 5
      let lt_2 = 1
      let eq_3 = 0
      return lt_2
    |}]

let%expect_test "env does not cross block boundaries" =
  Code.Var.reset ();
  let a = Code.Var.fresh_n "a" in
  let ap = Code.Var.fresh_n "ap" in
  let b = Code.Var.fresh_n "b" in
  let s = Code.Var.fresh_n "s" in
  let blocks =
    Code.Addr.Map.empty
    |> Code.Addr.Map.add
         0
         { Code.params = []
         ; body = [ Let (a, Constant (Int 7)) ]
         ; branch = Branch (1, [ a ])
         }
    |> Code.Addr.Map.add
         1
         { Code.params = [ ap ]
         ; body =
             [ Let (b, Constant (Int 1))
             ; Let (s, Prim (Extern "add_int", [ Pv ap; Pv b ]))
             ]
         ; branch = Return s
         }
  in
  let prog = { Code.start = 0; blocks; free_pc = 2 } in
  run_and_report prog;
  [%expect
    {|
    folded=0
    program (start = 0):
    block 0():
      let a_0 = 7
      branch 1(a_0)
    block 1(ap_1):
      let b_2 = 1
      let s_3 = %add_int(ap_1, b_2)
      return s_3
    |}]
