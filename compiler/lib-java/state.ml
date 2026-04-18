open Kind
open Function_info

type cmp_op = Eq | Ne | Lt | Le | Gt | Ge

type slot_info = { kind : kind; local : int }

type branch_snapshot =
  { s_oc_stack_depth : int
  ; s_slots : slot_info list
  ; s_acc_live : bool
  ; s_acc_kind : kind
  }

(* Block parameters for a JOIN block (one with >1 incoming edges).
   Each OCaml-stack slot at block entry has a reserved Object-typed
   JVM local; the acc (if any incoming path has it live) has its
   own reserved Object local too. Every branch edge to this block
   stores the outgoing state into these locals; the block prologue
   loads from them. Shape-based merging — no type-lattice fixpoint
   needed — adapted from jsoo's block [params]. *)
type block_params =
  { p_slot_locals : int array
        (** Local index for each OCaml-stack slot at block entry,
            indexed 0 = top of stack. *)
  ; p_acc_local : int option
        (** Local index for the incoming acc. [None] means the
            first branch that recorded saw [acc_live=false]. *)
  }

type state =
  { code : Jvm.Code.t
  ; globals : Obj.t array
  ; prims : string array
  ; supported_prims : Prim.table
  ; functions : (int, function_info) Hashtbl.t
  ; fn_by_name : (string, function_info) Hashtbl.t
  ; pc_to_label : (int, Jvm.Code.label) Hashtbl.t
  ; branch_target_state : (int, branch_snapshot) Hashtbl.t
  ; cfg : Cfg.t option
        (** Per-function control-flow graph. When present, join
            blocks get block-parameter locals and every edge into
            them materialises state into those locals, making
            cross-block type merging structural instead of
            inference-based. [None] for [main] (we haven't needed
            the machinery there yet). *)
  ; block_params : (int, block_params) Hashtbl.t
        (** Block id → reserved param locals. Allocated lazily on
            first branch to a join block. *)
  ; mutable acc_live : bool
  ; mutable acc_kind : kind
  ; mutable slots : slot_info list
  ; mutable oc_stack_depth : int
  ; mutable next_local : int
  ; mutable pending_cmp : cmp_op option
  ; nargs : int
  ; ncaps : int
  ; capture_kinds : kind list [@warning "-69"]
  ; enclosing_function_name : string option
  ; pending_handlers : (int, Jvm.Code.label) Hashtbl.t
  ; mutable open_traps :
      (Jvm.Code.label * Jvm.Code.label * Jvm.Code.label) list
        (** Each open try region carries [(start_lbl, end_lbl, prelude_lbl)].
            The JVM exception-table entry is installed eagerly at PUSHTRAP
            using all three labels; POPTRAP (or the handler-label prelude
            if POPTRAP was elided) marks [end_lbl] at its position. Mirrors
            jsoo's structural Pushtrap-IR approach: the region's existence
            doesn't depend on seeing POPTRAP in the instruction stream. *)
  ; fresh_oo_id_counter : int ref
  ; mutable pending_retaddrs : int
  ; mutable last_was_terminator : bool
        (** True immediately after emitting a terminator opcode
            (BRANCH, RETURN, RAISE, STOP, APPTERM/1/2/3). Used by the
            label prologue to tell fall-through entries (spill
            in-flight state first) from jump-only entries (spills
            already happened at the branch sites). Initialised to
            [true] at function entry — no fall-through into the
            first instruction. *)
  ; slot_obj_locals : (int, int) Hashtbl.t
        (** Fixed OCaml-stack-depth → JVM local mapping. Depth is
            measured from the bottom of the stack (0 = oldest frame),
            and each depth is assigned a single [Object]-typed JVM
            local once, stable across every control-flow path in the
            function. Primitive-kind slot values get boxed into the
            Object local on write and unboxed on read. Removes the
            class of "Register N contains wrong type" verifier errors
            where different paths backed the "same" OCaml slot with
            different JVM locals and a merge tried to read one that
            the other path never stored to. *)
  }

(* Look up (and lazily allocate) the single [Object]-typed JVM local
   reserved for the OCaml-stack slot at [depth_from_bottom]. Stable
   across the whole function: every control-flow path that writes or
   reads the slot at this depth uses the same JVM local, eliminating
   the class of cross-path local-aliasing bugs that untyped OCaml
   slots meeting typed JVM locals produce. *)
let slot_obj_local state depth_from_bottom =
  match Hashtbl.find_opt state.slot_obj_locals depth_from_bottom with
  | Some l -> l
  | None ->
    let l = state.next_local in
    state.next_local <- l + 1;
    Jvm.Code.set_min_locals state.code state.next_local;
    Hashtbl.add state.slot_obj_locals depth_from_bottom l;
    l

(* Convert an [Object]-typed JVM-stack value to the [kind] the caller
   wants — unbox if primitive, no-op for reference kinds. Assumes the
   top of the operand stack is an [Object] reference at entry. *)
let emit_unbox_on_top code = function
  | K_int ->
    Jvm.Code.checkcast code "java/lang/Integer";
    Jvm.Code.invokevirtual
      code
      ~class_:"java/lang/Integer"
      ~method_:"intValue"
      ~descriptor:"()I"
  | K_float ->
    Jvm.Code.checkcast code "java/lang/Double";
    Jvm.Code.invokevirtual
      code
      ~class_:"java/lang/Double"
      ~method_:"doubleValue"
      ~descriptor:"()D"
  | K_string | K_block _ | K_closure _ | K_obj -> ()

(* [aload slot.local] + unbox if the slot has a primitive kind. Slot
   locals are always [Object]-typed per the fixed-depth mapping. Use
   this instead of [emit_load_for_kind] at every slot-read site; the
   latter is now reserved for dynamic primitive temporaries. *)
let emit_slot_load state (slot : slot_info) =
  Jvm.Code.aload state.code slot.local;
  emit_unbox_on_top state.code slot.kind

(* Box acc to Object (if primitive), astore into the slot's Object
   local. Slot kind is updated to reflect what was written so reads
   can unbox correctly. *)
let emit_slot_store state k new_kind =
  (* Caller has acc on stack as [state.acc_kind]; box first if needed. *)
  (match state.acc_kind with
   | K_int -> emit_box_int state.code
   | K_float -> emit_box_float state.code
   | K_string | K_block _ | K_closure _ | K_obj -> ());
  let slot = List.nth state.slots k in
  Jvm.Code.astore state.code slot.local;
  state.slots <-
    List.mapi
      (fun i s -> if i = k then { kind = new_kind; local = slot.local } else s)
      state.slots

let ensure_kind state target =
  let compatible a b =
    match a, b with
    | K_int, K_int -> true
    | K_string, K_string -> true
    | K_float, K_float -> true
    | K_block _, K_block _ -> true
    | K_closure _, K_closure _ -> true
    | K_obj, K_obj -> true
    | _ -> false
  in
  if compatible state.acc_kind target
  then ()
  else
    match state.acc_kind with
    | K_obj ->
      emit_unbox_to_kind state.code target;
      state.acc_kind <- target
    | _ ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: kind mismatch — have %s, need %s"
           (jvm_type_of_kind state.acc_kind)
           (jvm_type_of_kind target))

(* Reserve param locals for a join block. Called lazily on the
   first edge into the block: the first caller's state determines
   the shape (depth + acc-live). OCaml's bytecode guarantees all
   edges into the same join agree on shape, so subsequent callers
   don't re-check — but we do keep a single entry keyed by block
   id, so any later disagreement becomes visible as a misuse at
   spill time. *)
let reserve_block_params state block_id ~at_depth ~acc_live =
  match Hashtbl.find_opt state.block_params block_id with
  | Some p -> p
  | None ->
    (* Use the fixed depth→Object-local mapping for the slot params
       too, so spill and post-reload pushes all share the same
       underlying JVM locals. Without this, block-params and
       [slot_obj_local] would hand out different locals for the
       "same" OCaml slot, and a later non-join push or ASSIGN
       would write to a different local than the block-params
       reload set up — leading to "Register N contains wrong type"
       at the next use. *)
    let p_slot_locals =
      Array.init at_depth (fun i ->
        (* slot[0] is top = depth_from_bottom (at_depth - 1). *)
        slot_obj_local state (at_depth - 1 - i))
    in
    let p_acc_local =
      if acc_live
      then (
        let l = state.next_local in
        state.next_local <- l + 1;
        Jvm.Code.set_min_locals state.code state.next_local;
        Some l)
      else None
    in
    let p = { p_slot_locals; p_acc_local } in
    Hashtbl.add state.block_params block_id p;
    p

(* Non-consuming spill: copy each slot's value and acc (if live)
   into a caller block's param locals, leaving the JVM operand
   stack unchanged. Acc on stack: duplicated (dup / dup2 for
   K_float), boxed, astore'd. Slots: read from their current local,
   written to a caller's param local — no operand-stack touch.

   Safe to call multiple times per edge (e.g. to both the
   branch target and the fall-through target of a conditional
   branch), and safe before a consuming comparison — after the
   comparison consumes acc, each outgoing edge's target block
   prologue reloads acc from its own param local. *)
let spill_to_block_params state block_id =
  let p =
    reserve_block_params
      state
      block_id
      ~at_depth:state.oc_stack_depth
      ~acc_live:state.acc_live
  in
  List.iteri
    (fun i (slot : slot_info) ->
      if i < Array.length p.p_slot_locals
      then (
        (* Slot locals are always [Object]-typed under the
           fixed-depth scheme, so [aload] then [astore] into the
           target's param local — no unbox/rebox needed. *)
        Jvm.Code.aload state.code slot.local;
        Jvm.Code.astore state.code p.p_slot_locals.(i)))
    state.slots;
  match p.p_acc_local, state.acc_live with
  | Some acc_local, true ->
    (match state.acc_kind with
     | K_int ->
       Jvm.Code.dup state.code;
       emit_box_int state.code;
       Jvm.Code.astore state.code acc_local
     | K_float ->
       Jvm.Code.dup2 state.code;
       emit_box_float state.code;
       Jvm.Code.astore state.code acc_local
     | K_string | K_block _ | K_closure _ | K_obj ->
       Jvm.Code.dup state.code;
       Jvm.Code.astore state.code acc_local)
  | None, _ | _, false -> ()

(* Design B reload. Acc is already on the JVM operand stack
   (boxed to [Object] by every incoming edge's
   [normalize_acc_for_branch] + non-consuming spill). The reload
   only updates the tracker: replace [state.slots] with fresh
   slot_infos that refer to the block's reserved param locals,
   and set [acc_live] / [acc_kind] according to whether the
   block has an acc param. The operand stack is untouched. *)
let reload_from_block_params state block_id =
  match Hashtbl.find_opt state.block_params block_id with
  | None -> ()
  | Some p ->
    state.oc_stack_depth <- Array.length p.p_slot_locals;
    state.slots <-
      (let rec loop i =
         if i >= Array.length p.p_slot_locals
         then []
         else { kind = K_obj; local = p.p_slot_locals.(i) } :: loop (i + 1)
       in
       loop 0);
    (match p.p_acc_local with
     | Some _ ->
       state.acc_live <- true;
       state.acc_kind <- K_obj
     | None ->
       state.acc_live <- false;
       state.acc_kind <- K_int)

(* Box a live primitive acc to its reference form, leaving
   [acc_kind = K_obj]. Dead accs are untouched. Used at branch
   sites so every incoming edge to a label leaves acc in the same
   JVM type (Object) — resolving the class of bugs where one path
   leaves an [int] on the operand stack and another leaves an
   [Object], tripping the JVM verifier's "Mismatched stack types".
   Downstream ops pay the [ensure_kind] unbox cost on first use,
   which is negligible. *)
let normalize_acc_for_branch state =
  if state.acc_live
  then
    match state.acc_kind with
    | K_int ->
      emit_box_int state.code;
      state.acc_kind <- K_obj
    | K_float ->
      emit_box_float state.code;
      state.acc_kind <- K_obj
    | K_string | K_block _ | K_closure _ | K_obj -> ()

(* Edge discipline: before a jump into a join block, normalise the
   acc and copy the current state into a caller's param locals
   so a caller's prologue's [reload_from_block_params] sees a
   consistent shape across every incoming edge. The spill is non-
   consuming (dup+astore for acc, local-to-local copies for slots),
   so the caller's subsequent comparison or branch sequence can keep
   using the operand stack as before. No-op when a caller is not
   a join, or when there is no CFG. *)
let emit_edge_spill state target_pc =
  match
    match state.cfg with
    | None -> None
    | Some cfg ->
      (match Hashtbl.find_opt cfg.by_start_pc target_pc with
       | Some bid when Cfg.is_join cfg bid -> Some bid
       | _ -> None)
  with
  | None -> ()
  | Some block_id ->
    normalize_acc_for_branch state;
    spill_to_block_params state block_id

(* Return whether [target_pc] is the start of a join block in the
   current function's CFG. If no CFG is set (e.g. for [main]),
   every edge falls back to the snapshot mechanism. *)
let target_block_if_join state target_pc =
  match state.cfg with
  | None -> None
  | Some cfg ->
    (match Hashtbl.find_opt cfg.by_start_pc target_pc with
     | Some block_id when Cfg.is_join cfg block_id -> Some block_id
     | _ -> None)

(* First-write-wins: subsequent branches to the same label must agree
   with the snapshot we've already recorded. Capturing [acc_live] /
   [acc_kind] alongside the OCaml-stack state means the label
   prologue can restore the full emitter context, not just the stack
   half — necessary for code that reaches a label with a live acc
   (e.g. [CLOSURE] with nvars>0 uses acc as its first capture). *)
let record_branch_target state target_pc =
  if not (Hashtbl.mem state.branch_target_state target_pc)
  then
    Hashtbl.add
      state.branch_target_state
      target_pc
      { s_oc_stack_depth = state.oc_stack_depth
      ; s_slots = state.slots
      ; s_acc_live = state.acc_live
      ; s_acc_kind = state.acc_kind
      }

let stack_slot_local ~state k =
  if k < 0 || k >= state.oc_stack_depth
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: stack slot %d out of range (depth %d, nargs %d, \
          ncaps %d, in_fn=%s)"
         k
         state.oc_stack_depth
         state.nargs
         state.ncaps
         (match state.enclosing_function_name with
          | Some n -> n
          | None -> "<main>"));
  (List.nth state.slots k).local

let top_slot_local ~state = stack_slot_local ~state 0

let allocate_local state =
  let l = state.next_local in
  state.next_local <- l + 1;
  l

(* For [K_float] a JVM local takes 2 adjacent slots (N and N+1).
   Callers that know the value's kind should use this instead of
   [allocate_local] to avoid clobbering the second half. *)
let allocate_local_for_kind state kind =
  let l = state.next_local in
  state.next_local <- l + Kind.local_slots_for_kind kind;
  l

let kind_of_slot_from_top ~state k = (List.nth state.slots k).kind

let push_slot state kind local =
  state.slots <- { kind; local } :: state.slots;
  state.oc_stack_depth <- state.oc_stack_depth + 1

let pop_slots state n =
  let rec drop lst n =
    if n <= 0 then lst
    else
      match lst with
      | _ :: rest -> drop rest (n - 1)
      | [] ->
        failwith "java_of_ocaml: tried to pop beyond the OCaml stack bottom"
  in
  state.slots <- drop state.slots n;
  state.oc_stack_depth <- state.oc_stack_depth - n

let consume_top state = pop_slots state 1

let label_at state pc = Hashtbl.find state.pc_to_label pc

(* Discard the current live acc from the JVM stack — one [pop] for
   most kinds, [pop2] for [K_float] (which occupies 2 operand-stack
   slots). *)
let drop_live_acc state =
  if state.acc_live
  then
    match state.acc_kind with
    | K_float -> Jvm.Code.pop2 state.code
    | _ -> Jvm.Code.pop_top state.code

let overwrite_acc state kind emit =
  drop_live_acc state;
  emit ();
  state.acc_live <- true;
  state.acc_kind <- kind

let box_acc_to_object state =
  match state.acc_kind with
  | K_int -> emit_box_int state.code
  | K_float -> emit_box_float state.code
  | K_string | K_block _ | K_closure _ | K_obj -> ()

(* Emit [throw new java.lang.UnsupportedOperationException(msg)].
   Used as a placeholder for opcodes we haven't implemented yet; the
   JVM verifier still accepts unreachable code after [athrow], so
   surrounding emission can continue as if nothing happened beyond
   invalidating acc. Callers that take a branch target or otherwise
   fall through must update [state.acc_*] appropriately afterwards. *)
let emit_throw_unsupported state msg =
  Jvm.Code.new_ state.code "java/lang/UnsupportedOperationException";
  Jvm.Code.dup state.code;
  Jvm.Code.ldc_string state.code msg;
  Jvm.Code.invokespecial
    state.code
    ~class_:"java/lang/UnsupportedOperationException"
    ~method_:"<init>"
    ~descriptor:"(Ljava/lang/String;)V";
  Jvm.Code.athrow state.code;
  state.acc_live <- false;
  state.acc_kind <- K_int
