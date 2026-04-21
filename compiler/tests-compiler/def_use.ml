(* [Def_use] unit tests. Pin the def/use-site shape so regressions
   in [of_program] or fv-helper drift show up as expect-test drift. *)

open Java_of_ocaml_compiler
module C = Code

let fresh () = C.Var.fresh ()

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

let pp_def = function
  | Def_use.Block_param (a, i) -> Printf.sprintf "Block_param(%d,%d)" a i
  | Let_instr (a, i) -> Printf.sprintf "Let_instr(%d,%d)" a i
  | Exn_var a -> Printf.sprintf "Exn_var(%d)" a

let pp_use = function
  | Def_use.In_body (a, i) -> Printf.sprintf "In_body(%d,%d)" a i
  | In_branch a -> Printf.sprintf "In_branch(%d)" a
  | In_branch_arg (a, i) -> Printf.sprintf "In_branch_arg(%d,%d)" a i

let pp_uses us =
  let strs = List.map pp_use us |> List.sort compare in
  String.concat "," strs

let%expect_test "Let binding: def + single in-body use" =
  let v = fresh () in
  let w = fresh () in
  let prog =
    build_program
      ~start:0
      [ ( 0
        , block
            ~body:
              [| C.Let (v, C.Constant (C.Int 42))
               ; C.Let (w, C.Field (v, 0))
              |]
            (C.Return w) )
      ]
  in
  let du = Def_use.of_program prog in
  Printf.printf "v def=%s uses=[%s]\n"
    (Option.fold ~none:"<none>" ~some:pp_def (Def_use.def_of du v))
    (pp_uses (Def_use.uses_of du v));
  Printf.printf "w def=%s uses=[%s]\n"
    (Option.fold ~none:"<none>" ~some:pp_def (Def_use.def_of du w))
    (pp_uses (Def_use.uses_of du w));
  [%expect {|
    v def=Let_instr(0,0) uses=[In_body(0,1)]
    w def=Let_instr(0,1) uses=[In_branch(0)]
    |}]

let%expect_test "block param threaded through Branch arg" =
  let v = fresh () in
  let w = fresh () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Branch (1, [ v ]))
      ; 1, block ~params:[ w ] (C.Return w)
      ]
  in
  let du = Def_use.of_program prog in
  Printf.printf "v def=%s uses=[%s]\n"
    (Option.fold ~none:"<none>" ~some:pp_def (Def_use.def_of du v))
    (pp_uses (Def_use.uses_of du v));
  Printf.printf "w def=%s uses=[%s]\n"
    (Option.fold ~none:"<none>" ~some:pp_def (Def_use.def_of du w))
    (pp_uses (Def_use.uses_of du w));
  [%expect {|
    v def=<none> uses=[In_branch_arg(0,0)]
    w def=Block_param(1,0) uses=[In_branch(1)]
    |}]

let%expect_test "Pushtrap: exn_var is a def" =
  let exn_v = fresh () in
  let v = fresh () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Pushtrap ((1, []), exn_v, (2, [])))
      ; 1, block (C.Poptrap (3, []))
      ; 2, block ~params:[ v ] (C.Return v)
      ; 3, block ~params:[] (C.Stop)
      ]
  in
  let du = Def_use.of_program prog in
  Printf.printf "exn_v def=%s uses=[%s]\n"
    (Option.fold ~none:"<none>" ~some:pp_def (Def_use.def_of du exn_v))
    (pp_uses (Def_use.uses_of du exn_v));
  [%expect {| exn_v def=Exn_var(0) uses=[] |}]

let%expect_test "Cond scrutinee: In_branch + In_branch_arg" =
  let v = fresh () in
  let w = fresh () in
  let prog =
    build_program
      ~start:0
      [ 0, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |]
            (C.Cond (v, (1, [ v ]), (2, [])))
      ; 1, block ~params:[ w ] (C.Return w)
      ; 2, block (C.Return v)
      ]
  in
  let du = Def_use.of_program prog in
  Printf.printf "v def=%s uses=[%s]\n"
    (Option.fold ~none:"<none>" ~some:pp_def (Def_use.def_of du v))
    (pp_uses (Def_use.uses_of du v));
  [%expect
    {| v def=Let_instr(0,0) uses=[In_branch(0),In_branch(2),In_branch_arg(0,0)] |}]
