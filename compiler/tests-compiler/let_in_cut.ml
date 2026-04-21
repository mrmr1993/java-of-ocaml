(* [Let_in_cut.enumerate] snapshots. Pin the candidate-identification
   behaviour so we notice if the dominance filter or the
   single-entry-single-exit check starts mis-firing. *)

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

let pp_set s =
  C.Addr.Set.elements s
  |> List.map string_of_int
  |> String.concat ","

let print cs =
  List.iter
    (fun (c : Let_in_cut.candidate) ->
      Printf.printf
        "candidate: join=%d entry=%d caller=%d body={%s} cost=%d\n"
        c.join_block
        c.body_entry
        c.caller
        (pp_set c.body_blocks)
        c.cost)
    (List.sort
       (fun (a : Let_in_cut.candidate) b -> compare a.join_block b.join_block)
       cs)

let%expect_test "simple if-diamond: one candidate at the join" =
  let x = fresh () in
  let y1 = fresh () in
  let y2 = fresh () in
  let w = fresh () in
  let prog =
    build_program
      ~start:0
      [ (* 0 = caller; branch into diamond *)
        0, block ~body:[| C.Let (x, C.Constant (C.Int 0)) |]
             (C.Branch (1, [ x ]))
        (* 1 = diamond entry (body_entry); Cond on x *)
      ; 1, block ~params:[ x ] (C.Cond (x, (2, []), (3, [])))
        (* 2, 3 = arms *)
      ; 2, block ~body:[| C.Let (y1, C.Constant (C.Int 1)) |]
             (C.Branch (4, [ y1 ]))
      ; 3, block ~body:[| C.Let (y2, C.Constant (C.Int 2)) |]
             (C.Branch (4, [ y2 ]))
        (* 4 = join block, receives result *)
      ; 4, block ~params:[ w ] (C.Return w)
      ]
  in
  print (Let_in_cut.enumerate prog);
  [%expect
    {| candidate: join=4 entry=1 caller=0 body={1,2,3} cost=70 |}]

let%expect_test "single-predecessor join: rejected (not a match shape)" =
  let x = fresh () in
  let w = fresh () in
  let prog =
    build_program
      ~start:0
      [ 0, block ~body:[| C.Let (x, C.Constant (C.Int 0)) |]
             (C.Branch (1, [ x ]))
      ; 1, block ~params:[ w ] (C.Return w)
      ]
  in
  print (Let_in_cut.enumerate prog);
  [%expect {||}]

let%expect_test "prog.start as body_entry: rejected (can't extract the whole program)" =
  let v = fresh () in
  let w = fresh () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Cond (v, (1, []), (2, [])))
      ; 1, block ~body:[| C.Let (v, C.Constant (C.Int 1)) |]
             (C.Branch (3, [ v ]))
      ; 2, block ~body:[| C.Let (v, C.Constant (C.Int 2)) |]
             (C.Branch (3, [ v ]))
      ; 3, block ~params:[ w ] (C.Return w)
      ]
  in
  print (Let_in_cut.enumerate prog);
  [%expect {||}]
