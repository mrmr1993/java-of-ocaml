(* Tests for:
   - [Bytecode.t.units] population (slice 1 — [Linker.link] + [read_exe])
   - [Main_init_split.plan] on synthetic programs (slice 2) *)

open Java_of_ocaml_expect_tests_helper

module Bytecode = Java_of_ocaml_compiler.Bytecode
module Code = Java_of_ocaml_compiler.Code
module Linker = Java_of_ocaml_compiler.Linker
module Mis = Java_of_ocaml_compiler.Main_init_split

(* -- slice 1 -------------------------------------------------------- *)

let%expect_test "Linker.link populates unit ranges" =
  Util.with_temp_dir ~f:(fun () ->
      let mk name content =
        let path = name ^ ".ml" in
        let oc = open_out path in
        output_string oc content;
        close_out oc;
        Util.Filetype.ocaml_file_of_path path
        |> Util.compile_ocaml_to_cmo
        |> Util.Filetype.path_of_cmo_file
      in
      let a = mk "a" "let () = print_endline \"a\"\n" in
      let b = mk "b" "let () = print_endline \"b\"\n" in
      let u_a = Bytecode.read_cmo a in
      let u_b = Bytecode.read_cmo b in
      let linked = Linker.link [ u_a; u_b ] in
      List.iter
        (fun (u : Bytecode.Unit.t) ->
          Printf.printf "unit %s: [%d, %d)\n" u.modname u.start_pc u.end_pc)
        linked.units;
      (* Sanity: the unit PC ranges must be disjoint, in-order, and
         fit within [code]. The linker appends one word for a trailing
         STOP, so the last range ends exactly at [code_len - 1]. *)
      let code_len = Array.length linked.code in
      let sorted =
        List.for_all
          (fun (u : Bytecode.Unit.t) -> u.start_pc < u.end_pc)
          linked.units
        && List.fold_left
             (fun prev_end (u : Bytecode.Unit.t) ->
               assert (u.start_pc >= prev_end);
               u.end_pc)
             0
             linked.units
           = code_len - 1
      in
      Printf.printf "disjoint_in_order_tight=%b code_len=%d\n" sorted code_len);
  [%expect
    {|
    unit A: [0, 12)
    unit B: [12, 24)
    disjoint_in_order_tight=true code_len=25
    |}]

(* -- slice 2 -------------------------------------------------------- *)

(* Build a tiny synthetic [Code.program] with two straight-line
   blocks, one per unit. This bypasses [Parse_bytecode] so we can
   exercise [Main_init_split.plan]'s structural checks independently
   of real bytecode shapes. *)
let make_block ~src_pc : Code.block =
  { params = []
  ; body = [| Code.Source_pc src_pc |]
  ; branch = Code.Stop
  }

let make_block_branching ~src_pc ~target : Code.block =
  { params = []
  ; body = [| Code.Source_pc src_pc |]
  ; branch = Code.Branch (target, [])
  }

let%expect_test "plan splits two disjoint units" =
  (* Each block's first [Source_pc] must match its unit's [start_pc]
     — [entry_of] looks for a block whose [block_pc_range]'s [lo]
     equals the unit's entry pc. *)
  let blocks =
    Code.Addr.Map.empty
    |> Code.Addr.Map.add 0 (make_block ~src_pc:10)   (* unit A *)
    |> Code.Addr.Map.add 1 (make_block ~src_pc:100)  (* unit B *)
  in
  let prog = { Code.start = 0; blocks; free_pc = 2 } in
  let units =
    [ { Bytecode.Unit.modname = "A"; start_pc = 10; end_pc = 100 }
    ; { Bytecode.Unit.modname = "B"; start_pc = 100; end_pc = 200 }
    ]
  in
  (match Mis.plan prog ~units with
   | Mis.Rejected why -> Printf.printf "rejected: %s\n" why
   | Mis.Split plan ->
     Printf.printf "n_units=%d driver_entry=%d\n"
       (List.length plan.units)
       plan.driver_entry_addr;
     List.iter
       (fun (s : Mis.unit_slice) ->
         Printf.printf
           "  %s -> %s (blocks=%d start=%d)\n"
           s.modname
           s.method_name
           (Code.Addr.Map.cardinal s.prog.blocks)
           s.prog.start)
       plan.units);
  [%expect
    {|
    n_units=2 driver_entry=0
      A -> init_A (blocks=1 start=0)
      B -> init_B (blocks=1 start=1)
    |}]

(* The planner ALLOWS cross-unit [Branch] edges (they're the
   fall-through pattern between consecutive unit inits) but rewrites
   the source's terminator to [Stop] in the slice. Test the
   terminator rewrite by making block 0's Branch target live in
   unit B and verifying the slice's block 0 ends in [Stop]. *)
let%expect_test "plan rewrites cross-unit Branch to Stop in slice" =
  let blocks =
    Code.Addr.Map.empty
    |> Code.Addr.Map.add 0 (make_block_branching ~src_pc:10 ~target:1)
    |> Code.Addr.Map.add 1 (make_block ~src_pc:100)
  in
  let prog = { Code.start = 0; blocks; free_pc = 2 } in
  let units =
    [ { Bytecode.Unit.modname = "A"; start_pc = 10; end_pc = 100 }
    ; { Bytecode.Unit.modname = "B"; start_pc = 100; end_pc = 200 }
    ]
  in
  (match Mis.plan prog ~units with
   | Mis.Rejected why -> Printf.printf "rejected: %s\n" why
   | Mis.Split plan ->
     List.iter
       (fun (s : Mis.unit_slice) ->
         Code.Addr.Map.iter
           (fun addr (b : Code.block) ->
             let last =
               match b.branch with
               | Code.Stop -> "Stop"
               | Code.Branch _ -> "Branch"
               | _ -> "other"
             in
             Printf.printf "%s addr=%d last=%s\n" s.modname addr last)
           s.prog.blocks)
       plan.units);
  [%expect
    {|
    A addr=0 last=Stop
    B addr=1 last=Stop
    |}]

(* Non-[Branch] cross-unit terminators (e.g. [Cond] with one arm in
   a different unit) are rejected — we can't sequentially dispatch
   a conditional to the next unit. *)
let%expect_test "plan rejects cross-unit Cond terminator" =
  let blocks =
    Code.Addr.Map.empty
    |> Code.Addr.Map.add
         0
         { Code.params = [ Code.Var.fresh () ]
         ; body = [| Code.Source_pc 10 |]
         ; branch =
             Code.Cond
               ( Code.Var.fresh ()
               , (1, [])
               , (2, []) )
         }
    |> Code.Addr.Map.add 1 (make_block ~src_pc:20)
    |> Code.Addr.Map.add 2 (make_block ~src_pc:100)
  in
  let prog = { Code.start = 0; blocks; free_pc = 3 } in
  let units =
    [ { Bytecode.Unit.modname = "A"; start_pc = 10; end_pc = 100 }
    ; { Bytecode.Unit.modname = "B"; start_pc = 100; end_pc = 200 }
    ]
  in
  (match Mis.plan prog ~units with
   | Mis.Rejected why -> Printf.printf "rejected: %s\n" why
   | Mis.Split _ -> Printf.printf "unexpected split\n");
  [%expect
    {| rejected: block 0 in unit A has non-Branch cross-unit terminator |}]

let%expect_test "plan rejects straddling block" =
  let blocks =
    Code.Addr.Map.empty
    |> Code.Addr.Map.add
         0
         { Code.params = []
         ; body = [| Code.Source_pc 10; Code.Source_pc 110 |]
         ; branch = Code.Stop
         }
  in
  let prog = { Code.start = 0; blocks; free_pc = 1 } in
  let units =
    [ { Bytecode.Unit.modname = "A"; start_pc = 10; end_pc = 100 }
    ; { Bytecode.Unit.modname = "B"; start_pc = 100; end_pc = 200 }
    ]
  in
  (match Mis.plan prog ~units with
   | Mis.Rejected why -> Printf.printf "rejected: %s\n" why
   | Mis.Split _ -> Printf.printf "unexpected split\n");
  [%expect {| rejected: block 0 straddles units A..B (pcs 10..110) |}]

let%expect_test "plan falls back when unit list is empty" =
  let prog =
    { Code.start = 0
    ; blocks = Code.Addr.Map.singleton 0 (make_block ~src_pc:10)
    ; free_pc = 1
    }
  in
  (match Mis.plan prog ~units:[] with
   | Mis.Rejected why -> Printf.printf "rejected: %s\n" why
   | Mis.Split _ -> Printf.printf "unexpected split\n");
  [%expect {| rejected: no unit ranges |}]

let%expect_test "extra_block_starts lists unit entry pcs" =
  let units =
    [ { Bytecode.Unit.modname = "A"; start_pc = 10; end_pc = 100 }
    ; { Bytecode.Unit.modname = "B"; start_pc = 100; end_pc = 200 }
    ; { Bytecode.Unit.modname = "C"; start_pc = 200; end_pc = 300 }
    ]
  in
  List.iter (Printf.printf "%d ") (Mis.extra_block_starts units);
  print_newline ();
  [%expect {| 10 100 200 |}]
