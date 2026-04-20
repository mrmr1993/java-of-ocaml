(* Structural cut analysis for 64 KB method splitting. We synthesise
   tiny [Code.program] graphs and assert the [Method_split.find_cut]
   decision matches expectations — covering the happy paths, the
   rejection of back-edges (loops and diamonds with internal merges),
   and the rejection of cuts that would split a Pushtrap region. *)

open Java_of_ocaml_compiler
module C = Code
module Split = Method_split

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

let pp_set fmt s =
  let xs = C.Addr.Set.elements s |> List.map string_of_int in
  Format.fprintf fmt "{%s}" (String.concat "," xs)

let print_cut = function
  | None -> print_endline "no cut"
  | Some { Split.cut_addr; head; tail } ->
    Format.printf "cut=%d head=%a tail=%a@." cut_addr pp_set head pp_set tail

let%expect_test "linear chain: cut is in the middle" =
  let v = fresh_var () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Branch (1, []))
      ; 1, block (C.Branch (2, []))
      ; 2, block (C.Branch (3, []))
      ; 3, block (C.Branch (4, []))
      ; 4, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v)
      ]
  in
  print_cut (Split.find_cut prog);
  [%expect {| cut=3 head={0,1,2} tail={3,4} |}]

let%expect_test "loop: no valid cut (back-edge from tail into head)" =
  let v = fresh_var () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Branch (1, []))
      ; 1, block (C.Cond (v, (0, []), (2, [])))
      ; 2, block (C.Return v)
      ]
  in
  print_cut (Split.find_cut prog);
  [%expect {| cut=2 head={0,1} tail={2} |}]

let%expect_test "diamond merging before a cut candidate: invalidates inner cuts" =
  let v = fresh_var () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Cond (v, (1, []), (2, [])))
      ; 1, block (C.Branch (3, []))
      ; 2, block (C.Branch (3, []))
      ; 3, block (C.Return v)
      ]
  in
  (* Cut at 1 fails (2 reaches 3 without going through 1, intersection);
     cut at 2 fails symmetrically; cut at 3 is valid. *)
  print_cut (Split.find_cut prog);
  [%expect {| cut=3 head={0,1,2} tail={3} |}]

let%expect_test "Pushtrap region fully contained in head is splittable past it" =
  let exn_v = fresh_var () in
  let v = fresh_var () in
  (* Block 0: Pushtrap body=1 handler=3
     Block 1: Branch 2 (inside try)
     Block 2: Poptrap 4 (exits try)
     Block 3: handler — Branch 4
     Block 4: Return
     Trap region = {1, 2}. Every cut inside or at the region boundary
     (1, 2, or 3) is rejected: either the region straddles head/tail
     or the handler ends up on the opposite side of the Pushtrap block.
     Cut at 4 works: head = {0,1,2,3}, tail = {4}, pushtrap/region/
     handler all in head. *)
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Pushtrap ((1, []), exn_v, (3, [])))
      ; 1, block (C.Branch (2, []))
      ; 2, block (C.Poptrap (4, []))
      ; 3, block (C.Branch (4, []))
      ; 4, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v)
      ]
  in
  print_cut (Split.find_cut prog);
  [%expect {| cut=4 head={0,1,2,3} tail={4} |}]

let%expect_test "Pushtrap with no Poptrap is unsplittable when handler sits past every Return" =
  let exn_v = fresh_var () in
  let v = fresh_var () in
  (* Block 0: Pushtrap body=1 handler=3; Block 1: Branch 2; Block 2:
     Return; Block 3: Return. Region = {1,2}, handler = 3.
     Every candidate cut either straddles the region or puts the
     handler on the opposite side of the Pushtrap block. *)
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Pushtrap ((1, []), exn_v, (3, [])))
      ; 1, block (C.Branch (2, []))
      ; 2, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v)
      ; 3, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v)
      ]
  in
  print_cut (Split.find_cut prog);
  [%expect {| no cut |}]

let%expect_test "single-block program: no cut" =
  let v = fresh_var () in
  let prog =
    build_program
      ~start:0
      [ 0, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v) ]
  in
  print_cut (Split.find_cut prog);
  [%expect {| no cut |}]

let%expect_test "head and tail programs shape" =
  let v = fresh_var () in
  let prog =
    build_program
      ~start:0
      [ 0, block (C.Branch (1, []))
      ; 1, block (C.Branch (2, []))
      ; 2, block ~body:[| C.Let (v, C.Constant (C.Int 0)) |] (C.Return v)
      ]
  in
  let r =
    Split.split
      ~limit:1
      ~class_name:"Foo"
      ~is_static:false
      ~return_kind:Split.Return_object
      prog
  in
  let count_helpers = List.length r.helpers in
  Format.printf
    "head.start=%d helpers=%d first.params=%d@."
    r.head.start
    count_helpers
    (match r.helpers with
     | h :: _ -> List.length h.params
     | [] -> -1);
  [%expect {| head.start=0 helpers=2 first.params=0 |}]
