open Instr

type block =
  { id : int
  ; start_idx : int
  ; end_idx : int
  ; start_pc : int
  ; mutable incoming : int list
  ; mutable outgoing : int list
  }

type t =
  { blocks : block array
  ; by_start_pc : (int, int) Hashtbl.t
  }

(* Unconditional terminators: control does not fall through to the
   next instruction. RESTART / GRAB are prologue markers that show
   up at a function body's entry but don't terminate control flow. *)
let is_unconditional_terminator op =
  op = Bytecode.Op.branch
  || op = return_op
  || op = appterm_op
  || op = appterm1_op
  || op = appterm2_op
  || op = appterm3_op
  || op = Bytecode.Op.raise_
  || op = Bytecode.Op.reraise
  || op = Bytecode.Op.raise_notrace
  || op = Bytecode.Op.stop

(* Does this instruction name a branch target (in addition to
   possibly falling through)? BRANCH / BRANCHIF* / PUSHTRAP / cmp
   jumps / SWITCH all do. [Instr.branch_targets] returns the list. *)
let branch_target_pcs ins = branch_targets ins

(* Build the set of pcs that are block boundaries: every branch
   target, plus every pc that immediately follows an unconditional
   terminator, plus the body's first pc. Collected as a set keyed
   by pc. *)
let collect_block_start_pcs arr ~body_start ~body_end =
  let set = Hashtbl.create 16 in
  Hashtbl.replace set arr.(body_start).pc ();
  for i = body_start to body_end do
    let ins = arr.(i) in
    List.iter
      (fun target_pc -> Hashtbl.replace set target_pc ())
      (branch_target_pcs ins);
    if is_unconditional_terminator ins.opcode && i + 1 <= body_end
    then Hashtbl.replace set arr.(i + 1).pc ()
  done;
  set

let build arr ~body_start ~body_end =
  let start_pcs = collect_block_start_pcs arr ~body_start ~body_end in
  (* Walk the instruction range and carve out blocks. An index is a
     block start iff its pc is in [start_pcs]; a block runs until
     (inclusive) the last instruction before the next block start
     (or body_end). *)
  let blocks = ref [] in
  let by_start_pc = Hashtbl.create 16 in
  let next_id = ref 0 in
  let i = ref body_start in
  while !i <= body_end do
    let block_start_idx = !i in
    let block_start_pc = arr.(block_start_idx).pc in
    assert (Hashtbl.mem start_pcs block_start_pc);
    (* Walk forward until we hit either an unconditional terminator
       (the terminator belongs to this block) or an instruction
       whose pc is another block's start (it belongs to the next
       block). *)
    let last_idx = ref block_start_idx in
    let keep_going = ref true in
    while !keep_going do
      if is_unconditional_terminator arr.(!last_idx).opcode
      then keep_going := false
      else if
        !last_idx + 1 > body_end
        || Hashtbl.mem start_pcs arr.(!last_idx + 1).pc
      then keep_going := false
      else incr last_idx
    done;
    let block =
      { id = !next_id
      ; start_idx = block_start_idx
      ; end_idx = !last_idx
      ; start_pc = block_start_pc
      ; incoming = []
      ; outgoing = []
      }
    in
    Hashtbl.add by_start_pc block_start_pc !next_id;
    blocks := block :: !blocks;
    incr next_id;
    i := !last_idx + 1
  done;
  let blocks = Array.of_list (List.rev !blocks) in
  (* Wire up outgoing/incoming edges. *)
  Array.iter
    (fun b ->
      let terminator = arr.(b.end_idx) in
      let targets = branch_target_pcs terminator in
      let outgoing = ref [] in
      List.iter
        (fun target_pc ->
          match Hashtbl.find_opt by_start_pc target_pc with
          | Some target_id -> outgoing := target_id :: !outgoing
          | None -> ())
        targets;
      (* Fall-through edge: if the terminator isn't unconditional
         and there's a next block, add it. *)
      (if not (is_unconditional_terminator terminator.opcode)
       then
         if b.end_idx + 1 < Array.length arr
         then
           match Hashtbl.find_opt by_start_pc arr.(b.end_idx + 1).pc with
           | Some next_id -> outgoing := next_id :: !outgoing
           | None -> ());
      b.outgoing <- List.rev !outgoing)
    blocks;
  Array.iter
    (fun b ->
      List.iter
        (fun target_id -> blocks.(target_id).incoming <-
          b.id :: blocks.(target_id).incoming)
        b.outgoing)
    blocks;
  { blocks; by_start_pc }

let entry_block_id _t = 0

let is_join t id =
  match t.blocks.(id).incoming with
  | [] | [ _ ] -> false
  | _ -> true
