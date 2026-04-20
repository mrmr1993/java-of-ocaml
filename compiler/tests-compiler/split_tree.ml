(* Structural-tree construction for [Split_tree]. Pins the round-trip
   identity + the recognised-pattern counts so regressions in
   [of_program] / [to_program] show up as expect-test drift. *)

open Java_of_ocaml_compiler
module C = Code

let fresh_var () = C.Var.fresh ()

let block ?(params = []) ?(body = [||]) branch =
  { C.params; body; branch }

let build_program ~start blocks =
  let map =
    List.fold_left
      (fun acc (addr, b) -> C.Addr.Map.add addr b acc)
      C.Addr.Map.empty
      blocks
  in
  let max_addr =
    List.fold_left (fun acc (a, _) -> max acc a) 0 blocks
  in
  { C.start; blocks = map; free_pc = max_addr + 1 }

let program_eq (a : C.program) (b : C.program) =
  a.start = b.start
  && a.free_pc = b.free_pc
  && C.Addr.Map.cardinal a.blocks = C.Addr.Map.cardinal b.blocks
  && C.Addr.Map.for_all
       (fun addr blk_a ->
         match C.Addr.Map.find_opt addr b.blocks with
         | None -> false
         | Some blk_b ->
           blk_a.C.params = blk_b.C.params
           && blk_a.C.body = blk_b.C.body
           && blk_a.C.branch = blk_b.C.branch)
       a.blocks

let print_summary prog =
  let tree = Split_tree.of_program prog in
  let s = Split_tree.summarise tree in
  let rt_ok = program_eq (Split_tree.to_program tree) prog in
  Printf.printf
    "round-trip=%b leaves=%d flats=%d seqs=%d ifs=%d switches=%d loops=%d trys=%d stragglers=%d\n"
    rt_ok
    s.leaves
    s.flats
    s.seqs
    s.ifs
    s.switches
    s.loops
    s.trys
    s.stragglers

let%expect_test "linear chain: Seq recognition" =
  let v = fresh_var () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Branch (1, []))
      ; 1, block (C.Branch (2, []))
      ; 2, block (C.Branch (3, []))
      ; 3, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v)
      ]
  in
  print_summary prog;
  [%expect
    {| round-trip=true leaves=4 flats=0 seqs=3 ifs=0 switches=0 loops=0 trys=0 stragglers=0 |}]

let%expect_test "if-diamond: If recognition" =
  let v = fresh_var () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Cond (v, (1, []), (2, [])))
      ; 1, block (C.Branch (3, []))
      ; 2, block (C.Branch (3, []))
      ; 3, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v)
      ]
  in
  print_summary prog;
  [%expect
    {| round-trip=true leaves=4 flats=0 seqs=0 ifs=1 switches=0 loops=0 trys=0 stragglers=0 |}]

let%expect_test "nested ifs: both levels recognised" =
  let v = fresh_var () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Cond (v, (1, []), (4, [])))
      ; 1, block (C.Cond (v, (2, []), (3, [])))
      ; 2, block (C.Branch (7, []))
      ; 3, block (C.Branch (7, []))
      ; 4, block (C.Cond (v, (5, []), (6, [])))
      ; 5, block (C.Branch (7, []))
      ; 6, block (C.Branch (7, []))
      ; 7, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v)
      ]
  in
  print_summary prog;
  [%expect
    {| round-trip=true leaves=8 flats=1 seqs=0 ifs=3 switches=0 loops=0 trys=0 stragglers=1 |}]

let%expect_test "try/with: Try_region recognition" =
  let exn_v = fresh_var () in
  let v = fresh_var () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Pushtrap ((1, []), exn_v, (3, [])))
      ; 1, block (C.Poptrap (2, []))
      ; 2, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v)
      ; 3, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v)
      ]
  in
  print_summary prog;
  [%expect
    {| round-trip=true leaves=4 flats=1 seqs=0 ifs=0 switches=0 loops=0 trys=1 stragglers=2 |}]

let%expect_test "single block: trivial round-trip" =
  let v = fresh_var () in
  let prog =
    build_program
      ~start:0
      [ 0, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v) ]
  in
  print_summary prog;
  [%expect
    {| round-trip=true leaves=1 flats=0 seqs=0 ifs=0 switches=0 loops=0 trys=0 stragglers=0 |}]

let%expect_test "loop: round-trip preserves program despite no Loop node yet" =
  let v = fresh_var () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Branch (1, []))
      ; 1, block (C.Cond (v, (0, []), (2, [])))
      ; 2, block (C.Return v)
      ]
  in
  print_summary prog;
  [%expect
    {| round-trip=true leaves=3 flats=1 seqs=1 ifs=1 switches=0 loops=0 trys=0 stragglers=0 |}]
