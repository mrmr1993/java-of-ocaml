open Global_view
open Instr
open Kind
open Function_info
open Prim

(* [ensure_kind] is defined below, after the [state] record type is
   available — it needs to read [state.acc_kind] and emit into
   [state.code]. *)

(* -------------------------------------------------------------------------- *)
(* Forward emitter. *)

type cmp_op = Eq | Ne | Lt | Le | Gt | Ge

(* Snapshot of the emitter's OCaml-side state at a branch target. We capture
   it at each branch emission and restore it when we mark a caller
   label, so that the linear instruction walk doesn't carry state from the
   [RETURN] / fall-through path into a caller's emission. *)
type slot_info = { kind : kind; local : int }

type branch_snapshot =
  { s_oc_stack_depth : int
  ; s_slots : slot_info list
  }

type state =
  { code : Jvm.Code.t
  ; globals : Obj.t array
  ; supported_prims : (int, string * prim_handler * bool) Hashtbl.t
      (* Prim-table value: (name, handler, is_seed) — the seed flag is
         ignored at emission time but consulted by the user-range
         detector to reject stdlib-internal primitives as range seeds. *)
  ; functions : (int, function_info) Hashtbl.t
      (* closure{,rec}_pc -> function_info *)
  ; fn_by_name : (string, function_info) Hashtbl.t
      (* function class name -> function_info (for APPLY return-kind
         lookup). *)
  ; pc_to_label : (int, Jvm.Code.label) Hashtbl.t
  ; branch_target_state : (int, branch_snapshot) Hashtbl.t
      (* Target PC -> state to restore when we mark that target's label. *)
  ; mutable acc_live : bool
  ; mutable acc_kind : kind
  ; mutable slots : slot_info list
      (* most-recently-pushed first; head of list is the top of the OCaml
         stack. Length always equals [oc_stack_depth]. Each element records
         both the value's kind and the JVM local holding it. *)
  ; mutable oc_stack_depth : int
  ; mutable next_local : int
      (* Monotonically-increasing counter of allocated JVM locals for
         OCaml-stack values. Never decremented — once a local has held a
         pushed value, we don't reuse it (closure captures rely on locals
         surviving past slot-pop events). *)
  ; mutable pending_cmp : cmp_op option
  ; nargs : int
      (* Number of OCaml arguments for this method. 0 for [main]. N for a
         function with N args. *)
  ; ncaps : int
      (* Number of captures in this method. Captures occupy JVM locals
         0..ncaps-1; args then occupy ncaps..ncaps+nargs-1. *)
  ; capture_kinds : kind list [@warning "-69"]
      (* Kinds of the captures, in closure-field order (index 0 = first
         ENVACC-visible capture). Used to emit the right load opcode for
         ENVACC and to propagate to self-closures via OFFSETCLOSURE0. *)
  ; enclosing_function_name : string option
      (* [None] when emitting [main]; [Some name] inside a function body.
         OFFSETCLOSURE0 uses this to tag acc as the self-closure. *)
  ; pending_handlers : (int, Jvm.Code.label) Hashtbl.t
      (* Bytecode PC of a try/with handler -> JVM label where the JVM-level
         prelude (unwrap the caught [CamlException]) should be emitted
         just before the OCaml handler's own label. *)
  ; mutable open_traps :
      (Jvm.Code.label * Jvm.Code.label) list
      (* Stack of (try-region-start label, JVM prelude label for the
         handler). A [PUSHTRAP] pushes an entry; the matching [POPTRAP]
         pops it and registers the exception-table entry spanning the
         region between them. *)
  ; fresh_oo_id_counter : int ref
  ; mutable pending_retaddrs : int
      (* Count of [PUSH_RETADDR]s whose matching [APPLY] we haven't yet
         seen. OCaml's interpreter pushes 3 retaddr words at
         PUSH_RETADDR; the callee's [RETURN] pops them alongside its
         own locals. At the JVM level we pop them in the caller after
         [emit_apply_invoke] returns. *)
      (* Monotonically-increasing counter for [caml_fresh_oo_id] —
         OCaml's runtime gives each exception / object type a unique
         int at module init. Module init runs once per program start,
         so a compile-time counter is stable enough for our purposes. *)
  }

(* Slot lookups go through [state.slots], which records per-slot the kind
   and the JVM local that was assigned at push time. *)

(* If acc is [K_obj] (opaque Object from an apply-method arg), unbox/cast
   it to [target]. If it's already a compatible specific kind, do nothing.
   If it's an incompatible specific kind, fail loudly — that indicates a
   kind-tracking bug in the compiler itself. *)
let ensure_kind state target =
  let compatible a b =
    match a, b with
    | K_int, K_int -> true
    | K_string, K_string -> true
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

let record_branch_target state target_pc =
  if not (Hashtbl.mem state.branch_target_state target_pc)
  then
    Hashtbl.add
      state.branch_target_state
      target_pc
      { s_oc_stack_depth = state.oc_stack_depth
      ; s_slots = state.slots
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

let kind_of_slot_from_top ~state k =
  (List.nth state.slots k).kind

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

let label_at state pc =
  Hashtbl.find state.pc_to_label pc

(* Replace acc (pop any live value, push new). *)
let overwrite_acc state kind emit =
  if state.acc_live then Jvm.Code.pop_top state.code;
  emit ();
  state.acc_live <- true;
  state.acc_kind <- kind

let emit_int_const state n =
  overwrite_acc state K_int (fun () -> Jvm.Code.ldc_int state.code n)

let emit_string_const state s =
  overwrite_acc
    state
    K_string
    (fun () -> Jvm.Code.ldc_string state.code s)

(* Materialise a block constant (from the DATA section) as a Block instance
   on top of the op stack. Each field that's an int gets boxed as Integer;
   string fields are loaded via [ldc] and stored as-is. Does not modify
   [state.acc_live] / [state.acc_kind]; callers handle those. *)
let rec emit_materialise_value state = function
  | Gv_int n ->
    Jvm.Code.ldc_int state.code n;
    emit_box_int state.code
  | Gv_string s -> Jvm.Code.ldc_string state.code s
  | Gv_block (tag, fields) -> emit_materialise_block_constant state tag fields

and emit_materialise_block_constant state tag fields =
  let fields_local = allocate_local state in
  let size = List.length fields in
  Jvm.Code.ldc_int state.code size;
  Jvm.Code.anewarray state.code "java/lang/Object";
  Jvm.Code.astore state.code fields_local;
  List.iteri
    (fun i fv ->
      Jvm.Code.aload state.code fields_local;
      Jvm.Code.ldc_int state.code i;
      emit_materialise_value state fv;
      Jvm.Code.aastore state.code)
    fields;
  Jvm.Code.new_ state.code "Block";
  Jvm.Code.dup state.code;
  Jvm.Code.ldc_int state.code tag;
  Jvm.Code.aload state.code fields_local;
  Jvm.Code.invokespecial
    state.code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V"

(* OCaml PUSH: stack := stack++[acc]; acc unchanged. On JVM, dup acc so the
   operand stack still has acc on top; the dup'd copy becomes a named local
   for later ACC access. *)
let emit_push state =
  if not state.acc_live
  then
    (* A PUSH immediately after a C_CALL is a save-PUSH for its return value.
       Our compile stops before anything would read it back, so skip. *)
    ()
  else (
    let local = allocate_local state in
    Jvm.Code.dup state.code;
    emit_store_for_kind state.code local state.acc_kind;
    push_slot state state.acc_kind local)

let emit_acc state k =
  if k >= state.oc_stack_depth
  then
    (* ACC past the end of our tracked OCaml stack — the compiler emits such
       an access in the module-init trailer to fetch the top-level binding
       for MAKEBLOCK. Our emission stops before MAKEBLOCK, so this access
       is dead; skip it. *)
    ()
  else (
    let slot = stack_slot_local ~state k in
    let new_kind = kind_of_slot_from_top ~state k in
    if state.acc_live then Jvm.Code.pop_top state.code;
    emit_load_for_kind state.code slot new_kind;
    state.acc_live <- true;
    state.acc_kind <- new_kind)

let emit_pushacc state k =
  if not state.acc_live
  then
    (* A PUSHACC at a "dead" point — the most common example is right after
       a C_CALL returning unit, used by the module-init trailer to stash
       the return value and then load a binding for MAKEBLOCK. We don't
       emit MAKEBLOCK, so skipping this is correct. *)
    ()
  else (
    emit_push state;
    emit_acc state k)

let emit_int_push state n =
  let was_live = state.acc_live in
  emit_push state;
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_int state.code n;
  state.acc_live <- true;
  state.acc_kind <- K_int

let emit_string_push state s =
  let was_live = state.acc_live in
  emit_push state;
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_string state.code s;
  state.acc_live <- true;
  state.acc_kind <- K_string

let self_closure_ref state =
  match state.enclosing_function_name with
  | None ->
    failwith
      "java_of_ocaml: OFFSETCLOSURE0/PUSHOFFSETCLOSURE0 outside a function"
  | Some fname ->
    (* Self-closure: the captures aren't in separate locals anymore — they
       live as instance fields on [this]. We don't need to re-list them;
       what we need is a [closure_ref] whose [name] matches this method's
       class so APPLY emits the right [invokevirtual]. The [captures]
       list is left empty because the runtime representation of "self" is
       just [this] (no extra locals to load). *)
    { name = fname; captures = [] }

let emit_offsetclosure0 state =
  let cref = self_closure_ref state in
  (* Emit [this] onto the op stack. *)
  if state.acc_live then Jvm.Code.pop_top state.code;
  Jvm.Code.aload state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_closure cref

let emit_pushoffsetclosure0 state =
  let cref = self_closure_ref state in
  let was_live = state.acc_live in
  emit_push state;
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.aload state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_closure cref

(* Resolve [OFFSETCLOSURE N] to the sibling within the enclosing
   function's CLOSUREREC group. OCaml lays out each function's code
   pointer 3 words apart in the shared closure block, so offset N
   corresponds to moving [N/3] sibling positions. *)
let resolve_sibling state offset =
  let self_fi =
    match state.enclosing_function_name with
    | None -> failwith "java_of_ocaml: OFFSETCLOSURE outside a function"
    | Some name ->
      (match Hashtbl.find_opt state.fn_by_name name with
       | Some fi -> fi
       | None ->
         failwith
           (Printf.sprintf
              "java_of_ocaml: enclosing function %s not registered"
              name))
  in
  let target_idx = self_fi.group_idx + (offset / 3) in
  if target_idx < 0 || target_idx >= Array.length self_fi.group
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: OFFSETCLOSURE %d out of range for group of %d"
         offset
         (Array.length self_fi.group));
  self_fi, self_fi.group.(target_idx), target_idx

let emit_offsetclosure state offset =
  if offset = 0 then emit_offsetclosure0 state
  else (
    let self_fi, target_fi, target_idx = resolve_sibling state offset in
    if state.acc_live then Jvm.Code.pop_top state.code;
    Jvm.Code.aload state.code 0;
    Jvm.Code.getfield
      state.code
      ~class_:self_fi.name
      ~field:(Printf.sprintf "sibling_%d" target_idx)
      ~descriptor:"LClosure;";
    state.acc_live <- true;
    state.acc_kind <- K_closure { name = target_fi.name; captures = [] })

let emit_pushoffsetclosure state offset =
  if offset = 0 then emit_pushoffsetclosure0 state
  else (
    let self_fi, target_fi, target_idx = resolve_sibling state offset in
    let was_live = state.acc_live in
    emit_push state;
    if was_live then Jvm.Code.pop_top state.code;
    Jvm.Code.aload state.code 0;
    Jvm.Code.getfield
      state.code
      ~class_:self_fi.name
      ~field:(Printf.sprintf "sibling_%d" target_idx)
      ~descriptor:"LClosure;";
    state.acc_live <- true;
    state.acc_kind <- K_closure { name = target_fi.name; captures = [] })

(* ENVACC k accesses the k-th field of the closure's environment. OCaml 5.x
   closure layout: field 0 = code, field 1 = closinfo, fields 2..ncaps+1 =
   captures in order. ENVACC k for k >= 2 = capture (k-2), at JVM local
   (k-2); its kind comes from [state.capture_kinds]. *)
let capture_kind_at state cap_index =
  try List.nth state.capture_kinds cap_index with
  | _ ->
    failwith
      (Printf.sprintf
         "java_of_ocaml: ENVACC capture index %d out of range (ncaps=%d)"
         cap_index
         state.ncaps)

(* ENVACC k reads field [k] of the closure environment. In our representation,
   captures live as instance fields on the closure object named [capN]
   (where N = k - 2). We load [this], then read the field. *)

let emit_envacc state k =
  if k < 2
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: ENVACC %d (field <2) not supported — closure \
          info fields aren't modelled"
         k);
  let cap_index = k - 2 in
  let kind = capture_kind_at state cap_index in
  let fname = Printf.sprintf "cap%d" cap_index in
  let desc = jvm_type_of_kind kind in
  let class_ =
    match state.enclosing_function_name with
    | Some n -> n
    | None -> failwith "java_of_ocaml: ENVACC outside a function"
  in
  if state.acc_live then Jvm.Code.pop_top state.code;
  Jvm.Code.aload state.code 0 (* this *);
  Jvm.Code.getfield state.code ~class_ ~field:fname ~descriptor:desc;
  state.acc_live <- true;
  state.acc_kind <- kind

let emit_pushenvacc state k =
  let was_live = state.acc_live in
  emit_push state;
  if k < 2
  then
    failwith
      (Printf.sprintf "java_of_ocaml: PUSHENVACC %d (field <2) not supported" k);
  let cap_index = k - 2 in
  let kind = capture_kind_at state cap_index in
  let fname = Printf.sprintf "cap%d" cap_index in
  let desc = jvm_type_of_kind kind in
  let class_ =
    match state.enclosing_function_name with
    | Some n -> n
    | None -> failwith "java_of_ocaml: PUSHENVACC outside a function"
  in
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.aload state.code 0;
  Jvm.Code.getfield state.code ~class_ ~field:fname ~descriptor:desc;
  state.acc_live <- true;
  state.acc_kind <- kind

(* Build a JVM constructor descriptor for a closure class given the kinds
   of its captures in field order. *)
let ctor_descriptor_for_captures cap_kinds =
  let buf = Buffer.create 16 in
  Buffer.add_char buf '(';
  List.iter (fun k -> Buffer.add_string buf (jvm_type_of_kind k)) cap_kinds;
  Buffer.add_string buf ")V";
  Buffer.contents buf

(* CLOSURE / CLOSUREREC: allocate a fresh [Closure_<name>] instance whose
   constructor takes the captures. The result flows as a JVM reference (the
   new instance is on the op stack).

   OCaml semantics for nvars > 0: [field(closure, 2..) = sp[0..nvars-1]]
   with the implicit [sp.push(acc)] at the start. The first capture is
   therefore acc at closure-creation time; the rest come from the top N-1
   OCaml-stack slots in top-first order. *)
let emit_closure_creation state (fn_info : function_info) ~nvars ~is_rec =
  let captures =
    if nvars = 0
    then []
    else (
      if not state.acc_live
      then
        failwith
          "java_of_ocaml: CLOSURE/CLOSUREREC with nvars>0 requires a \
           live acc";
      emit_push state;
      let rec loop k acc =
        if k >= nvars
        then List.rev acc
        else (
          let slot = List.nth state.slots k in
          loop (k + 1) ((slot.local, slot.kind) :: acc))
      in
      let caps = loop 0 [] in
      pop_slots state nvars;
      caps)
  in
  let collected_kinds = List.map snd captures in
  (match !(fn_info.capture_kinds) with
   | [] -> fn_info.capture_kinds := collected_kinds
   | existing when List.length existing = List.length collected_kinds
     && List.for_all2
          (fun a b ->
            match a, b with
            | K_int, K_int -> true
            | K_string, K_string -> true
            | K_block _, K_block _ -> true
            | K_closure _, K_closure _ -> true
            | _ -> false)
          existing
          collected_kinds ->
     ()
   | _ ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: inconsistent capture kinds for function %s"
          fn_info.name));
  let cref = { name = fn_info.name; captures } in
  (* Pop any stale acc, allocate instance, invoke constructor with capture
     values in field order. *)
  if state.acc_live then Jvm.Code.pop_top state.code;
  Jvm.Code.new_ state.code fn_info.name;
  Jvm.Code.dup state.code;
  List.iter
    (fun (local, kind) -> emit_load_for_kind state.code local kind)
    captures;
  Jvm.Code.invokespecial
    state.code
    ~class_:fn_info.name
    ~method_:"<init>"
    ~descriptor:(ctor_descriptor_for_captures collected_kinds);
  state.acc_live <- true;
  state.acc_kind <- K_closure cref;
  if is_rec
  then (
    let local = allocate_local state in
    Jvm.Code.dup state.code;
    Jvm.Code.astore state.code local;
    push_slot state state.acc_kind local)

let emit_closure state (ins : instr) =
  let fn_info =
    try Hashtbl.find state.functions ins.pc with
    | Not_found ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: CLOSURE at pc %d not registered"
           ins.pc)
  in
  let nvars = ins.args.(0) in
  emit_closure_creation state fn_info ~nvars ~is_rec:false

let emit_closurerec state (ins : instr) =
  let nfuncs = ins.args.(0) in
  let nvars = ins.args.(1) in
  let head_fi =
    try Hashtbl.find state.functions ins.pc with
    | Not_found ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: CLOSUREREC at pc %d not registered"
           ins.pc)
  in
  if nfuncs = 1
  then emit_closure_creation state head_fi ~nvars ~is_rec:true
  else (
    (* Multi-function group: allocate all N closures up-front (each
       constructed with its captures), then patch the [sibling_K]
       cross-reference fields on every instance. The captures are
       consumed once, not once per function. *)
    let group = head_fi.group in
    let n = Array.length group in
    (* Snapshot capture locals + kinds before we pop them — every
       function in the group shares this set. *)
    let captures =
      if nvars = 0
      then []
      else (
        if not state.acc_live
        then
          failwith
            "java_of_ocaml: CLOSUREREC with nvars>0 requires a live acc";
        emit_push state;
        let rec loop k acc =
          if k >= nvars
          then List.rev acc
          else (
            let slot = List.nth state.slots k in
            loop (k + 1) ((slot.local, slot.kind) :: acc))
        in
        let caps = loop 0 [] in
        pop_slots state nvars;
        caps)
    in
    let cap_kinds = List.map snd captures in
    Array.iter
      (fun (fi : function_info) ->
        (match !(fi.capture_kinds) with
         | [] -> fi.capture_kinds := cap_kinds
         | existing
           when List.length existing = List.length cap_kinds
                && List.for_all2
                     (fun a b ->
                       match a, b with
                       | K_int, K_int -> true
                       | K_string, K_string -> true
                       | K_block _, K_block _ -> true
                       | K_closure _, K_closure _ -> true
                       | _ -> false)
                     existing
                     cap_kinds ->
           ()
         | _ ->
           failwith
             (Printf.sprintf
                "java_of_ocaml: inconsistent capture kinds for function %s"
                fi.name)))
      group;
    if state.acc_live then Jvm.Code.pop_top state.code;
    (* Allocate each closure into its own JVM local. *)
    let instance_locals = Array.make n 0 in
    for k = 0 to n - 1 do
      let fi = group.(k) in
      Jvm.Code.new_ state.code fi.name;
      Jvm.Code.dup state.code;
      List.iter
        (fun (local, kind) -> emit_load_for_kind state.code local kind)
        captures;
      Jvm.Code.invokespecial
        state.code
        ~class_:fi.name
        ~method_:"<init>"
        ~descriptor:(ctor_descriptor_for_captures cap_kinds);
      let l = allocate_local state in
      Jvm.Code.astore state.code l;
      instance_locals.(k) <- l
    done;
    (* Patch cross-references: for each instance i, set sibling_j = inst_j. *)
    for i = 0 to n - 1 do
      for j = 0 to n - 1 do
        Jvm.Code.aload state.code instance_locals.(i);
        Jvm.Code.aload state.code instance_locals.(j);
        Jvm.Code.putfield
          state.code
          ~class_:group.(i).name
          ~field:(Printf.sprintf "sibling_%d" j)
          ~descriptor:"LClosure;"
      done
    done;
    (* OCaml's CLOSUREREC leaves its N functions on the OCaml stack
       with the LAST-defined function at the top: stack layout from
       top = [f_{n-1}; f_{n-2}; ...; f_0]. acc also holds f_{n-1}. *)
    let last = n - 1 in
    Jvm.Code.aload state.code instance_locals.(last);
    state.acc_live <- true;
    state.acc_kind <- K_closure { name = group.(last).name; captures = [] };
    for k = 0 to n - 1 do
      let local = instance_locals.(k) in
      push_slot state
        (K_closure { name = group.(k).name; captures = [] })
        local
    done;
    ignore ins)

let consume_top state =
  pop_slots state 1

(* Load the top OCaml-stack slot as an [int], unboxing from Integer if the
   slot currently holds an opaque Object. *)
let emit_iload_top_as_int state =
  let si = List.hd state.slots in
  emit_load_for_kind state.code si.local si.kind;
  match si.kind with
  | K_int -> ()
  | K_obj ->
    Jvm.Code.checkcast state.code "java/lang/Integer";
    Jvm.Code.invokevirtual
      state.code
      ~class_:"java/lang/Integer"
      ~method_:"intValue"
      ~descriptor:"()I"
  | _ ->
    failwith
      (Printf.sprintf
         "java_of_ocaml: arithmetic on non-int slot (%s)"
         (jvm_type_of_kind si.kind))

let emit_addint state =
  ensure_kind state K_int;
  emit_iload_top_as_int state;
  Jvm.Code.iadd state.code;
  consume_top state

let emit_subint state =
  ensure_kind state K_int;
  emit_iload_top_as_int state;
  Jvm.Code.isub state.code;
  consume_top state

let emit_mulint state =
  ensure_kind state K_int;
  emit_iload_top_as_int state;
  Jvm.Code.imul state.code;
  consume_top state

let emit_divint state =
  ensure_kind state K_int;
  emit_iload_top_as_int state;
  Jvm.Code.idiv state.code;
  consume_top state

let emit_modint state =
  ensure_kind state K_int;
  emit_iload_top_as_int state;
  Jvm.Code.irem state.code;
  consume_top state

let emit_offsetint state n =
  ensure_kind state K_int;
  Jvm.Code.ldc_int state.code n;
  Jvm.Code.iadd state.code

let emit_println state ~int_arg =
  if int_arg
  then ensure_kind state K_int
  else ensure_kind state K_string;
  Jvm.Code.getstatic
    state.code
    ~class_:"java/lang/System"
    ~field:"out"
    ~descriptor:"Ljava/io/PrintStream;";
  Jvm.Code.swap state.code;
  let desc = if int_arg then "(I)V" else "(Ljava/lang/String;)V" in
  Jvm.Code.invokevirtual
    state.code
    ~class_:"java/io/PrintStream"
    ~method_:"println"
    ~descriptor:desc;
  (* OCaml's [C_CALL1] leaves [acc] live with the result — for a
     unit-returning call that's [Val_long(0)]. We mirror that so match
     arms like [| [] -> ()] (which leave [acc_live = true] holding 0)
     merge cleanly with arms ending in a [C_CALL] — otherwise the JVM
     stack depth disagrees at the common label. *)
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_int

(* For an array-like block accessed with a dynamic index (Array.get /
   Array.set), all fields should share a kind if the OCaml program is
   well-typed. Take the first field's kind as the element kind and check
   the rest match. *)
let element_kind_of_block field_kinds =
  match field_kinds with
  | [] -> K_int (* degenerate — shouldn't happen for a live array *)
  | k :: rest ->
    let compatible a b =
      match a, b with
      | K_int, K_int -> true
      | K_string, K_string -> true
      | K_block _, K_block _ -> true
      | K_closure _, K_closure _ -> true
      | _ -> false
    in
    if List.for_all (compatible k) rest
    then k
    else
      failwith
        "java_of_ocaml: dynamic array indexing on a heterogeneous block — \
         element kinds disagree across fields"

(* caml_array_get_addr: C_CALL2 — args acc=block, stack[0]=index, result=
   block.fields[index] (with cast + unbox to the element kind). *)
let emit_array_get state =
  let idx_slot = top_slot_local ~state in
  match state.acc_kind with
  | K_block field_kinds ->
    let ek = element_kind_of_block field_kinds in
    Jvm.Code.getfield
      state.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.iload state.code idx_slot;
    Jvm.Code.aaload state.code;
    emit_unbox_to_kind state.code ek;
    consume_top state;
    state.acc_live <- true;
    state.acc_kind <- ek
  | _ -> failwith "java_of_ocaml: caml_array_get_addr on non-block"

(* caml_obj_dup: C_CALL1, acc=block, result=shallow copy of block.
   Allocate a new Block(src.tag, Arrays.copyOf(src.fields, src.length)). *)
let emit_obj_dup state =
  (match state.acc_kind with
   | K_block _ -> ()
   | _ -> failwith "java_of_ocaml: caml_obj_dup on non-block");
  let src_local = allocate_local state in
  Jvm.Code.astore state.code src_local;
  (* Allocate new Block with (src.tag, Arrays.copyOf(src.fields, src.fields.length)). *)
  Jvm.Code.new_ state.code "Block";
  Jvm.Code.dup state.code;
  Jvm.Code.aload state.code src_local;
  Jvm.Code.getfield state.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
  Jvm.Code.aload state.code src_local;
  Jvm.Code.getfield
    state.code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  Jvm.Code.dup state.code;
  Jvm.Code.arraylength state.code;
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/util/Arrays"
    ~method_:"copyOf"
    ~descriptor:"([Ljava/lang/Object;I)[Ljava/lang/Object;";
  Jvm.Code.invokespecial
    state.code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V"
  (* acc_kind unchanged *)

(* [caml_alloc_dummy n]: allocate a [Block(0, new Object[n])] — a
   placeholder whose fields will be backfilled by a matching
   [caml_update_dummy]. OCaml uses this pair to build recursive
   values like [let rec a = A (b, b) and b = [|a; a; a|]]: allocate
   dummies first, build the real shapes referencing the dummies, then
   overwrite the dummies' contents. *)
let emit_alloc_dummy state =
  ensure_kind state K_int;
  Jvm.Code.anewarray state.code "java/lang/Object";
  let arr_local = allocate_local state in
  Jvm.Code.astore state.code arr_local;
  Jvm.Code.new_ state.code "Block";
  Jvm.Code.dup state.code;
  Jvm.Code.ldc_int state.code 0;
  Jvm.Code.aload state.code arr_local;
  Jvm.Code.invokespecial
    state.code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V";
  state.acc_live <- true;
  state.acc_kind <- K_obj

(* [caml_update_dummy dst src]: copy [src]'s fields into [dst]'s
   fields. OCaml's runtime also overwrites [dst]'s tag, but our
   [Block.tag] is [final] — in practice both [dst] and [src] share
   [tag = 0] for the recursive-value patterns the bytecode compiler
   emits (records, arrays), so skipping tag overwriting is fine. *)
let emit_update_dummy state =
  let src_slot = List.hd state.slots in
  (* Stack: [dst]. First get dst.fields into a local. *)
  Jvm.Code.checkcast state.code "Block";
  Jvm.Code.getfield
    state.code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  let dst_fields_local = allocate_local state in
  Jvm.Code.astore state.code dst_fields_local;
  (* System.arraycopy(src.fields, 0, dst.fields, 0, dst.fields.length) *)
  emit_load_for_kind state.code src_slot.local src_slot.kind;
  Jvm.Code.checkcast state.code "Block";
  Jvm.Code.getfield
    state.code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  Jvm.Code.ldc_int state.code 0;
  Jvm.Code.aload state.code dst_fields_local;
  Jvm.Code.ldc_int state.code 0;
  Jvm.Code.aload state.code dst_fields_local;
  Jvm.Code.arraylength state.code;
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/lang/System"
    ~method_:"arraycopy"
    ~descriptor:"(Ljava/lang/Object;ILjava/lang/Object;II)V";
  pop_slots state 1;
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_int

(* [caml_fresh_oo_id]: returns a fresh int. OCaml's runtime increments a
   process-global counter; we inline a compile-time counter, which is
   stable enough because module init — the only site that calls this —
   runs exactly once at [Main.main] entry. Acc (the passed-in dummy arg)
   is discarded, replaced with the freshly-assigned int. *)
let emit_fresh_oo_id state =
  let n = !(state.fresh_oo_id_counter) in
  state.fresh_oo_id_counter := n + 1;
  if state.acc_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_int state.code n;
  state.acc_live <- true;
  state.acc_kind <- K_int

(* OCaml [ISINT]: [acc := Val_bool(Is_long(acc))]. Used by polymorphic-
   variant match bytecode to dispatch between zero-arg cases (stored as
   tagged ints whose value is the hash of the variant name) and
   data-carrying cases (stored as blocks).

   If acc's kind is known statically (K_int ⇒ always immediate,
   K_block / K_closure / K_string ⇒ never immediate), fold the result
   to a constant. Otherwise (K_obj) emit a runtime [instanceof
   java/lang/Integer] test. *)
let emit_isint state =
  (match state.acc_kind with
   | K_int ->
     if state.acc_live then Jvm.Code.pop_top state.code;
     Jvm.Code.ldc_int state.code 1
   | K_block _ | K_closure _ | K_string ->
     if state.acc_live then Jvm.Code.pop_top state.code;
     Jvm.Code.ldc_int state.code 0
   | K_obj ->
     (* Pops objectref, pushes int (0 or 1). acc now represents the
        boolean as a JVM int. *)
     Jvm.Code.instanceof_ state.code "java/lang/Integer");
  state.acc_live <- true;
  state.acc_kind <- K_int

(* caml_array_set_addr: C_CALL3 — args acc=block, stack[0]=index,
   stack[1]=value, result=unit. *)
let emit_array_set state =
  let idx_slot = stack_slot_local ~state 0 in
  let val_slot_info = List.nth state.slots 1 in
  (match state.acc_kind with
   | K_block _ ->
     Jvm.Code.getfield
       state.code
       ~class_:"Block"
       ~field:"fields"
       ~descriptor:"[Ljava/lang/Object;";
     Jvm.Code.iload state.code idx_slot;
     emit_load_for_kind state.code val_slot_info.local val_slot_info.kind;
     box_if_int state.code val_slot_info.kind;
     Jvm.Code.aastore state.code
   | _ -> failwith "java_of_ocaml: caml_array_set_addr on non-block");
  pop_slots state 2;
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_int

(* APPLY{1,2,3,N}: OCaml-stack slots [0..n-1] from top are the args in
   source order (stack[0 from top] = first source-order arg). The closure
   sentinel sits on top of the JVM operand stack in acc. Captures (if any)
   are loaded from the JVM locals the closure recorded when it was created,
   each using its kind's corresponding load opcode. We emit captures first,
   then args, then invokestatic. *)
(* APPLY: acc holds a [Closure] subclass instance. We need to call
   [acc.applyN(arg0, arg1, ...)] where each arg is boxed to [Object].
   Small arities (1/2/3) use the [applyN] overloads on [Closure]. *)

let apply_descriptor_for_nargs nargs =
  let buf = Buffer.create 16 in
  Buffer.add_char buf '(';
  for _ = 1 to nargs do
    Buffer.add_string buf "Ljava/lang/Object;"
  done;
  Buffer.add_string buf ")Ljava/lang/Object;";
  Buffer.contents buf

(* Emit the invokevirtual for an APPLY. Leaves the callee's result as an
   [Object] reference on the JVM op stack, consumes the arg slots, and
   updates state accordingly. Does not touch the result's boxedness. *)
let emit_apply_invoke state ~nargs =
  (* Ensure acc is a Closure reference. K_obj → checkcast Closure;
     K_closure is already typed. *)
  (match state.acc_kind with
   | K_closure _ -> ()
   | K_obj ->
     Jvm.Code.checkcast state.code "Closure";
     state.acc_kind <- K_closure { name = "Closure"; captures = [] }
   | K_int | K_string | K_block _ ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: APPLY%d called on a non-closure value (%s). \
           Closure analysis lost the tag?"
          nargs
          (jvm_type_of_kind state.acc_kind)));
  for k = 0 to nargs - 1 do
    let slot = stack_slot_local ~state k in
    let sk = (List.nth state.slots k).kind in
    emit_load_for_kind state.code slot sk;
    box_if_int state.code sk
  done;
  if nargs > 7
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: APPLY%d — the base Closure class only \
          declares apply1..apply7 right now"
         nargs);
  Jvm.Code.invokevirtual
    state.code
    ~class_:"Closure"
    ~method_:(Printf.sprintf "apply%d" nargs)
    ~descriptor:(apply_descriptor_for_nargs nargs);
  pop_slots state nargs;
  (* If this APPLY is the tail of a [PUSH_RETADDR; …; APPLY] frame,
     discard the three retaddr sentinels too. OCaml's callee consumed
     them in its RETURN; at our level we just drop them from the
     tracked OCaml-stack depth. *)
  if state.pending_retaddrs > 0
  then (
    state.pending_retaddrs <- state.pending_retaddrs - 1;
    pop_slots state 3);
  state.acc_live <- true

(* Regular APPLY: invoke then cast / unbox based on the callee's return
   kind. [fn_by_name] is a side-table supplied in the state for this. *)
let emit_apply state ~nargs =
  let callee_info =
    match state.acc_kind with
    | K_closure { name; _ } -> Hashtbl.find_opt state.fn_by_name name
    | _ -> None
  in
  emit_apply_invoke state ~nargs;
  let return_kind =
    match callee_info with
    | Some fi when nargs < fi.nargs ->
      (* Undersupplied call — the JVM [Closure.apply<nargs>] stub built a
         [PartialClosure] from the passed args. The result is a closure,
         not the function's final return. *)
      K_obj
    | Some fi -> !(fi.return_kind)
    | None ->
      (* Calling through an opaque closure (e.g. a function arg, or a
         capture whose kind we lost). We can't know the callee's return
         kind without more analysis, so stay on the lazy K_obj path and
         let the next op unbox via [ensure_kind] at point of use. *)
      K_obj
  in
  emit_unbox_to_kind state.code return_kind;
  state.acc_kind <- return_kind

let emit_apply1 state = emit_apply state ~nargs:1

(* OCaml [PUSH_RETADDR L]: push three retaddr words onto the OCaml stack
   (return PC, env, extra_args). The callee's [RETURN] pops them along
   with its own locals. At the JVM level we don't need any of this
   information (Java's native return takes care of it); we only need to
   track that the OCaml stack got 3 slots deeper so later [ACC k]
   resolves to the right slot. After the matching [APPLY] those slots
   are "popped" by the callee's RETURN — since nothing in our JVM-level
   emission pushed them, we reconcile by popping 3 slots post-apply. *)
let emit_push_retaddr state =
  for _ = 1 to 3 do
    let local = allocate_local state in
    push_slot state K_obj local
  done;
  state.pending_retaddrs <- state.pending_retaddrs + 1

(* Box acc's value into an Object on the JVM op stack, so it can be used
   as the [Object] return from an [apply] method or as a capture /
   exception payload. *)
let box_acc_to_object state =
  match state.acc_kind with
  | K_int -> emit_box_int state.code
  | K_string | K_block _ | K_closure _ | K_obj ->
    () (* already a reference *)

(* OCaml [RAISE]: box acc into a [CamlException] and [athrow].

   Leaves the OCaml-level state dead: after the throw, control exits the
   method, so anything the linear walker emits after this point is
   unreachable from normal flow (only the JVM exception handler at a
   pushtrap can jump back in). *)
let emit_raise state =
  box_acc_to_object state;
  let exc_val_local = allocate_local state in
  Jvm.Code.astore state.code exc_val_local;
  Jvm.Code.new_ state.code "CamlException";
  Jvm.Code.dup state.code;
  Jvm.Code.aload state.code exc_val_local;
  Jvm.Code.invokespecial
    state.code
    ~class_:"CamlException"
    ~method_:"<init>"
    ~descriptor:"(Ljava/lang/Object;)V";
  Jvm.Code.athrow state.code;
  state.acc_live <- false;
  state.acc_kind <- K_int;
  state.oc_stack_depth <- 0;
  state.slots <- []

(* OCaml [PUSHTRAP L]: opens a try region whose handler lives at bytecode
   PC [L].

   - Snapshot the current OCaml-side state so when we later materialise
     the handler label we can restore [slots] / [oc_stack_depth] to their
     pre-pushtrap values (OCaml's [RAISE] unwinds the trap frame and
     resumes at the handler with the stack it had before PUSHTRAP).
   - Inflate [oc_stack_depth] by 4 with dummy slots so any following
     [acc K] / [push] in the protected body resolves to the right index
     (OCaml's interpreter pushes 4 trap-frame words at PUSHTRAP).
   - Mark a fresh JVM label at the current byte offset: this is the
     [start_pc] of the JVM exception-table entry the matching POPTRAP
     will install.
   - Allocate a fresh JVM label [prelude_lbl] and record it in
     [pending_handlers] keyed by the bytecode PC [L]. When [emit_instr]
     reaches that PC it will emit the JVM-side prelude (unwrap the
     caught [CamlException]) at [prelude_lbl] before continuing into the
     OCaml handler's own bytecode. *)
let emit_pushtrap state (ins : instr) =
  let handler_pc = ins.pc + ins.args.(0) + 1 in
  record_branch_target state handler_pc;
  let prelude_lbl =
    match Hashtbl.find_opt state.pending_handlers handler_pc with
    | Some lbl -> lbl
    | None ->
      let lbl = Jvm.Code.fresh_label state.code in
      Hashtbl.add state.pending_handlers handler_pc lbl;
      lbl
  in
  let start_lbl = Jvm.Code.fresh_label state.code in
  Jvm.Code.mark_label state.code start_lbl;
  for _ = 1 to 4 do
    let local = allocate_local state in
    push_slot state K_obj local
  done;
  state.open_traps <- (start_lbl, prelude_lbl) :: state.open_traps

(* OCaml [POPTRAP]: closes the innermost try region and installs the JVM
   exception-table entry. Pops the 4 dummy trap slots we inflated at the
   matching [PUSHTRAP]. Emits no JVM bytes — the [end_lbl] marks the
   current byte offset as the exclusive end of the protected range. *)
let emit_poptrap state =
  match state.open_traps with
  | [] ->
    failwith
      "java_of_ocaml: POPTRAP without a matching PUSHTRAP — \
       exception-scope tracking is broken"
  | (start_lbl, prelude_lbl) :: rest ->
    state.open_traps <- rest;
    let end_lbl = Jvm.Code.fresh_label state.code in
    Jvm.Code.mark_label state.code end_lbl;
    Jvm.Code.add_exception_handler
      state.code
      ~start_lbl
      ~end_lbl
      ~handler_lbl:prelude_lbl
      ~catch_class:(Some "CamlException");
    pop_slots state 4

(* APPTERM_N: tail call — same as APPLY followed by return. Because the
   callee's result and our method's return type are both [Object], we
   don't unbox; we pass the Object straight to areturn. *)
let emit_appterm state ~nargs =
  emit_apply_invoke state ~nargs;
  Jvm.Code.areturn state.code;
  state.acc_live <- false;
  state.acc_kind <- K_int;
  state.oc_stack_depth <- 0;
  state.slots <- []

let emit_return state =
  (* We're returning from a JVM [apply] method whose signature returns
     [Object]. If acc is already on the stack, box (if int) and areturn;
     otherwise materialise a unit and return that. *)
  if state.acc_live
  then box_acc_to_object state
  else (
    Jvm.Code.ldc_int state.code 0;
    emit_box_int state.code);
  Jvm.Code.areturn state.code;
  state.acc_live <- false;
  state.acc_kind <- K_int;
  state.oc_stack_depth <- 0;
  state.slots <- []

let emit_cmp_jump state (ins : instr) =
  let imm = ins.args.(0) in
  let target_pc = ins.pc + ins.args.(1) + 2 in
  let lbl = label_at state target_pc in
  ensure_kind state K_int;
  Jvm.Code.ldc_int state.code imm;
  (match ins.opcode with
   | 131 -> Jvm.Code.if_icmpeq state.code lbl
   | 132 -> Jvm.Code.if_icmpne state.code lbl
   | 133 -> Jvm.Code.if_icmpgt state.code lbl
   | 134 -> Jvm.Code.if_icmpge state.code lbl
   | 135 -> Jvm.Code.if_icmplt state.code lbl
   | 136 -> Jvm.Code.if_icmple state.code lbl
   | other ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: unexpected cmp_jump opcode %d"
          other));
  (* Cmp_jump reads acc (= accu of [acc TST imm]) but doesn't touch the
     OCaml stack; a caller sees the same stack as the branch point. *)
  record_branch_target state target_pc;
  state.acc_live <- false;
  state.acc_kind <- K_int

let cmp_of_opcode op =
  if op = Bytecode.Op.eq then Eq
  else if op = Bytecode.Op.neq then Ne
  else if op = Bytecode.Op.ltint then Lt
  else if op = Bytecode.Op.leint then Le
  else if op = Bytecode.Op.gtint then Gt
  else if op = Bytecode.Op.geint then Ge
  else
    failwith
      (Printf.sprintf
         "java_of_ocaml: cmp_of_opcode on non-comparison %d"
         op)

(* BRANCHIFNOT / BRANCHIF on a K_obj acc (i.e. a variant value that may be
   either a boxed Integer — for immediate constructors like [None] or enum
   tags — or a [Block] — for data constructors like [Some x]). OCaml's
   branchifnot branches if the value equals [Val_long(0)]; in our
   representation that means the value is an [Integer] whose [intValue] is
   zero. A [Block] always counts as "truthy". Emits the dual-dispatch that
   handles both shapes at runtime. Assumes acc is already on the JVM
   operand stack. *)
let emit_branch_on_val_int_zero state ~target_pc ~branch_if_zero =
  (* Stash acc to a local so every JVM path leaves the op stack empty —
     the [Jvm.Code] max-stack tracker is linear-only and a dangling
     [pop_top] on an unreachable path would silently desync it. *)
  let v_local = allocate_local state in
  let l_not_int = Jvm.Code.fresh_label state.code in
  let l_end = Jvm.Code.fresh_label state.code in
  let target_lbl = label_at state target_pc in
  Jvm.Code.astore state.code v_local;
  Jvm.Code.aload state.code v_local;
  Jvm.Code.instanceof_ state.code "java/lang/Integer";
  Jvm.Code.ifeq state.code l_not_int;
  Jvm.Code.aload state.code v_local;
  Jvm.Code.checkcast state.code "java/lang/Integer";
  Jvm.Code.invokevirtual
    state.code
    ~class_:"java/lang/Integer"
    ~method_:"intValue"
    ~descriptor:"()I";
  (if branch_if_zero
   then Jvm.Code.ifeq state.code target_lbl
   else Jvm.Code.ifne state.code target_lbl);
  Jvm.Code.goto state.code l_end;
  Jvm.Code.mark_label state.code l_not_int;
  if not branch_if_zero then Jvm.Code.goto state.code target_lbl;
  Jvm.Code.mark_label state.code l_end

(* Compile a [(case_value, target_pc)] table to a dispatch chain. Each
   target is reached with the JVM operand stack empty (the scrutinee has
   been consumed). Fall-through after the chain also leaves the stack
   empty. The scrutinee must be on the op stack as a raw int at entry.

   Implementation: stash the scrutinee into a JVM local, then for each case
   iload + ldc + if_icmpeq. This keeps the JVM stack balanced across the
   dispatch and, critically, never leaves a dangling [pop] on an
   unreachable linear path — the [Jvm.Code] max-stack tracker only
   observes straight-line code, so every dangling [pop] after a [goto]
   silently decrements its view of the stack and causes it to
   under-declare [max_stack] downstream. *)
let emit_int_case_chain state ~cases ~to_target_pc =
  let v_local = allocate_local state in
  Jvm.Code.istore state.code v_local;
  List.iter
    (fun case_index ->
      let target_pc = to_target_pc case_index in
      Jvm.Code.iload state.code v_local;
      Jvm.Code.ldc_int state.code case_index;
      Jvm.Code.if_icmpeq state.code (label_at state target_pc);
      record_branch_target state target_pc)
    cases

let emit_switch state (ins : instr) =
  let sizes = ins.args.(0) in
  let num_ints = sizes land 0xffff in
  let num_tags = (sizes lsr 16) land 0xffff in
  let int_target i = ins.pc + 2 + ins.args.(1 + i) in
  let tag_target j = ins.pc + 2 + ins.args.(1 + num_ints + j) in
  let int_cases = List.init num_ints (fun i -> i) in
  let tag_cases = List.init num_tags (fun j -> j) in
  (match state.acc_kind with
   | K_int ->
     (* All values are immediates; tag cases are unreachable. *)
     emit_int_case_chain state ~cases:int_cases ~to_target_pc:int_target
   | K_obj ->
     if num_tags = 0
     then (
       Jvm.Code.checkcast state.code "java/lang/Integer";
       Jvm.Code.invokevirtual
         state.code
         ~class_:"java/lang/Integer"
         ~method_:"intValue"
         ~descriptor:"()I";
       emit_int_case_chain state ~cases:int_cases ~to_target_pc:int_target)
     else if num_ints = 0
     then (
       Jvm.Code.checkcast state.code "Block";
       Jvm.Code.getfield state.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
       emit_int_case_chain state ~cases:tag_cases ~to_target_pc:tag_target)
     else (
       (* Stash acc so the JVM op stack is empty at both label targets. *)
       let v_local = allocate_local state in
       let l_is_block = Jvm.Code.fresh_label state.code in
       let l_end = Jvm.Code.fresh_label state.code in
       Jvm.Code.astore state.code v_local;
       Jvm.Code.aload state.code v_local;
       Jvm.Code.instanceof_ state.code "Block";
       Jvm.Code.ifne state.code l_is_block;
       Jvm.Code.aload state.code v_local;
       Jvm.Code.checkcast state.code "java/lang/Integer";
       Jvm.Code.invokevirtual
         state.code
         ~class_:"java/lang/Integer"
         ~method_:"intValue"
         ~descriptor:"()I";
       emit_int_case_chain state ~cases:int_cases ~to_target_pc:int_target;
       Jvm.Code.goto state.code l_end;
       Jvm.Code.mark_label state.code l_is_block;
       Jvm.Code.aload state.code v_local;
       Jvm.Code.checkcast state.code "Block";
       Jvm.Code.getfield state.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
       emit_int_case_chain state ~cases:tag_cases ~to_target_pc:tag_target;
       Jvm.Code.mark_label state.code l_end)
   | K_block _ ->
     Jvm.Code.getfield state.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
     emit_int_case_chain state ~cases:tag_cases ~to_target_pc:tag_target
   | other ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: SWITCH on unsupported kind %s"
          (jvm_type_of_kind other)));
  state.acc_live <- false;
  state.acc_kind <- K_int

let emit_fused_branch state ~cmp ~target_pc ~branch_if_true =
  (* acc (value1) is on the JVM op stack; the OCaml-stack top is value2.
     Dispatch on kinds: two [K_int]s (or [K_obj]s that unbox cleanly)
     compare as ints; two references compare as identities. OCaml's
     [eqint] / [neqint] are reference-equality when applied to block-
     tagged values (e.g. exception descriptors), so we need both
     paths. *)
  let slot_kind = kind_of_slot_from_top ~state 0 in
  let slot = top_slot_local ~state in
  let is_ref_kind = function
    | K_int | K_obj -> false
    | K_string | K_block _ | K_closure _ -> true
  in
  let lbl = label_at state target_pc in
  let branch_cond =
    if branch_if_true
    then cmp
    else
      match cmp with
      | Eq -> Ne
      | Ne -> Eq
      | Lt -> Ge
      | Le -> Gt
      | Gt -> Le
      | Ge -> Lt
  in
  (* Reference-equality path. Only [Eq] / [Ne] are meaningful on refs;
     ordering compares on references would be nonsensical. *)
  if is_ref_kind state.acc_kind || is_ref_kind slot_kind
  then (
    emit_load_for_kind state.code slot slot_kind;
    (match branch_cond with
     | Eq -> Jvm.Code.if_acmpeq state.code lbl
     | Ne -> Jvm.Code.if_acmpne state.code lbl
     | _ ->
       failwith
         (Printf.sprintf
            "java_of_ocaml: ordering comparison on reference kinds \
             (%s vs %s) at pc %d"
            (jvm_type_of_kind state.acc_kind)
            (jvm_type_of_kind slot_kind)
            target_pc)))
  else (
    ensure_kind state K_int;
    emit_load_for_kind state.code slot slot_kind;
    (match slot_kind with
     | K_int -> ()
     | K_obj -> emit_unbox_to_kind state.code K_int
     | other ->
       failwith
         (Printf.sprintf
            "java_of_ocaml: fused branch on non-int slot kind %s"
            (jvm_type_of_kind other)));
    match branch_cond with
    | Eq -> Jvm.Code.if_icmpeq state.code lbl
    | Ne -> Jvm.Code.if_icmpne state.code lbl
    | Lt -> Jvm.Code.if_icmplt state.code lbl
    | Le -> Jvm.Code.if_icmple state.code lbl
    | Gt -> Jvm.Code.if_icmpgt state.code lbl
    | Ge -> Jvm.Code.if_icmpge state.code lbl);
  consume_top state;
  record_branch_target state target_pc;
  state.acc_live <- false;
  state.acc_kind <- K_int

let emit_instr state (ins : instr) =
  (match Hashtbl.find_opt state.pc_to_label ins.pc with
   | Some lbl ->
     (* If this PC is a try/with handler target, emit the JVM-level
        prelude first (unwrap the caught [CamlException] into its
        [value]). The JVM exception handler's handler_pc points at the
        prelude label, not at the OCaml handler label directly — the
        prelude converts the handler-entry state (one [Throwable] on
        the op stack) into our acc-live convention. *)
     (match Hashtbl.find_opt state.pending_handlers ins.pc with
      | Some prelude_lbl ->
        Jvm.Code.mark_label state.code prelude_lbl;
        Jvm.Code.handler_stack_prelude state.code;
        Jvm.Code.checkcast state.code "CamlException";
        Jvm.Code.getfield
          state.code
          ~class_:"CamlException"
          ~field:"value"
          ~descriptor:"Ljava/lang/Object;"
      | None -> ());
     Jvm.Code.mark_label state.code lbl;
     (* Reset state to the snapshot taken at the first branch into this
        target. Any linear-walk mutations between here and the preceding
        [RETURN] / fall-through are effectively dead code from the JVM's
        point of view; we just need consistent state going forward. *)
     (match Hashtbl.find_opt state.branch_target_state ins.pc with
      | Some snap ->
        state.oc_stack_depth <- snap.s_oc_stack_depth;
        state.slots <- snap.s_slots
      | None -> ());
     (* A handler target arrives with acc live (the caught value on the
        JVM op stack) — don't clobber it. For normal branch targets acc
        is always consumed before the branch, so it's dead on entry. *)
     if Hashtbl.mem state.pending_handlers ins.pc
     then (
       state.acc_live <- true;
       state.acc_kind <- K_obj)
     else (
       state.acc_live <- false;
       state.acc_kind <- K_int);
     state.pending_cmp <- None
   | None -> ());
  let op = ins.opcode in
  if is_cmp_nullary op
  then state.pending_cmp <- Some (cmp_of_opcode op)
  else if op = Bytecode.Op.branchifnot
  then (
    match state.pending_cmp with
    | Some cmp ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      emit_fused_branch state ~cmp ~target_pc ~branch_if_true:false;
      state.pending_cmp <- None
    | None ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      (match state.acc_kind with
       | K_int ->
         Jvm.Code.ldc_int state.code 0;
         Jvm.Code.if_icmpeq state.code (label_at state target_pc)
       | K_obj ->
         emit_branch_on_val_int_zero
           state
           ~target_pc
           ~branch_if_zero:true
       | K_block _ | K_closure _ | K_string ->
         (* A statically-known reference kind is never [Val_int(0)];
            the branchifnot can't fire. Discard acc. *)
         Jvm.Code.pop_top state.code
       );
      record_branch_target state target_pc;
      state.acc_live <- false;
      state.acc_kind <- K_int)
  else if op = Bytecode.Op.branchif
  then (
    match state.pending_cmp with
    | Some cmp ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      emit_fused_branch state ~cmp ~target_pc ~branch_if_true:true;
      state.pending_cmp <- None
    | None ->
      let target_pc = ins.pc + ins.args.(0) + 1 in
      (match state.acc_kind with
       | K_int ->
         Jvm.Code.ldc_int state.code 0;
         Jvm.Code.if_icmpne state.code (label_at state target_pc)
       | K_obj ->
         emit_branch_on_val_int_zero
           state
           ~target_pc
           ~branch_if_zero:false
       | K_block _ | K_closure _ | K_string ->
         (* Statically-known reference — always "truthy"; the branch
            always fires. Drop acc and goto. *)
         Jvm.Code.pop_top state.code;
         Jvm.Code.goto state.code (label_at state target_pc)
       );
      record_branch_target state target_pc;
      state.acc_live <- false;
      state.acc_kind <- K_int)
  else if op = Bytecode.Op.switch
  then emit_switch state ins
  else if op = Bytecode.Op.pushtrap
  then emit_pushtrap state ins
  else if op = Bytecode.Op.poptrap
  then emit_poptrap state
  else if op = Bytecode.Op.raise_
       || op = Bytecode.Op.reraise
       || op = Bytecode.Op.raise_notrace
  then emit_raise state
  else if op = Bytecode.Op.isint
  then emit_isint state
  else if op = Bytecode.Op.push_retaddr
  then emit_push_retaddr state
  else if op = Bytecode.Op.boolnot
  then (
    (* OCaml bool is Val_int(0) / Val_int(1). Flip via XOR with 1. *)
    ensure_kind state K_int;
    Jvm.Code.ldc_int state.code 1;
    (* XOR opcode not exposed; synthesise via [(1 - x)] with iconst_1;
       swap; isub — but [Code.swap] + [isub] is what we have.
       Actually simpler: [ixor] is opcode 0x82, not yet in [Jvm.Code].
       Use subtraction instead. *)
    Jvm.Code.swap state.code;
    Jvm.Code.isub state.code;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.const0 then emit_int_const state 0
  else if op = Bytecode.Op.const1 then emit_int_const state 1
  else if op = Bytecode.Op.const2 then emit_int_const state 2
  else if op = Bytecode.Op.const3 then emit_int_const state 3
  else if op = Bytecode.Op.constint then emit_int_const state ins.args.(0)
  else if op = Bytecode.Op.pushconst0 then emit_int_push state 0
  else if op = Bytecode.Op.pushconst1 then emit_int_push state 1
  else if op = Bytecode.Op.pushconst2 then emit_int_push state 2
  else if op = Bytecode.Op.pushconst3 then emit_int_push state 3
  else if op = Bytecode.Op.pushconstint
  then emit_int_push state ins.args.(0)
  else if op = Bytecode.Op.offsetint then emit_offsetint state ins.args.(0)
  else if op = Bytecode.Op.makeblock
       || op = Bytecode.Op.makeblock1
       || op = Bytecode.Op.makeblock2
       || op = Bytecode.Op.makeblock3
  then (
    (* MAKEBLOCK size tag / MAKEBLOCKi tag: allocate a Block whose
       field 0 = acc and fields 1..size-1 = the top (size-1) OCaml-stack
       entries (most-recently-pushed at the lowest non-zero index). Int
       fields are boxed as Integer; reference fields flow into the
       Object[] as-is.

       The module-init trailer also emits MAKEBLOCK to wrap the
       compilation unit, but by then acc is dead — ignore those. *)
    if not state.acc_live
    then ()
    else (
      let size, tag =
        if op = Bytecode.Op.makeblock1
        then 1, ins.args.(0)
        else if op = Bytecode.Op.makeblock2
        then 2, ins.args.(0)
        else if op = Bytecode.Op.makeblock3
        then 3, ins.args.(0)
        else ins.args.(0), ins.args.(1)
      in
      if size < 1 then failwith "java_of_ocaml: MAKEBLOCK with size < 1";
      let field_kinds =
        let k0 = state.acc_kind in
        let rec gather i acc =
          if i >= size
          then List.rev acc
          else
            let slot_kind = (List.nth state.slots (i - 1)).kind in
            gather (i + 1) (slot_kind :: acc)
        in
        gather 1 [ k0 ]
      in
      (* Stash acc to a local so we can freely build the fields array. *)
      let acc_local = allocate_local state in
      emit_store_for_kind state.code acc_local state.acc_kind;
      (* Build the Object[] of fields, pre-boxing ints. *)
      let fields_local = allocate_local state in
      Jvm.Code.ldc_int state.code size;
      Jvm.Code.anewarray state.code "java/lang/Object";
      Jvm.Code.astore state.code fields_local;
      Jvm.Code.aload state.code fields_local;
      Jvm.Code.ldc_int state.code 0;
      emit_load_for_kind state.code acc_local state.acc_kind;
      box_if_int state.code state.acc_kind;
      Jvm.Code.aastore state.code;
      for i = 1 to size - 1 do
        let slot = List.nth state.slots (i - 1) in
        Jvm.Code.aload state.code fields_local;
        Jvm.Code.ldc_int state.code i;
        emit_load_for_kind state.code slot.local slot.kind;
        box_if_int state.code slot.kind;
        Jvm.Code.aastore state.code
      done;
      (* Allocate the Block. *)
      Jvm.Code.new_ state.code "Block";
      Jvm.Code.dup state.code;
      Jvm.Code.ldc_int state.code tag;
      Jvm.Code.aload state.code fields_local;
      Jvm.Code.invokespecial
        state.code
        ~class_:"Block"
        ~method_:"<init>"
        ~descriptor:"(I[Ljava/lang/Object;)V";
      pop_slots state (size - 1);
      state.acc_kind <- K_block field_kinds))
  else if op = Bytecode.Op.getfield0
       || op = Bytecode.Op.getfield1
       || op = Bytecode.Op.getfield2
       || op = Bytecode.Op.getfield3
       || op = Bytecode.Op.getfield
  then (
    let field =
      if op = Bytecode.Op.getfield0
      then 0
      else if op = Bytecode.Op.getfield1
      then 1
      else if op = Bytecode.Op.getfield2
      then 2
      else if op = Bytecode.Op.getfield3
      then 3
      else ins.args.(0)
    in
    match state.acc_kind with
    | K_block field_kinds ->
      let fk =
        try List.nth field_kinds field with
        | _ ->
          failwith
            (Printf.sprintf
               "java_of_ocaml: GETFIELD %d out of range at pc %d"
               field
               ins.pc)
      in
      Jvm.Code.getfield
        state.code
        ~class_:"Block"
        ~field:"fields"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int state.code field;
      Jvm.Code.aaload state.code;
      emit_unbox_to_kind state.code fk;
      state.acc_kind <- fk
    | K_obj ->
      (* Variant value whose shape is only knowable at runtime. We already
         dispatched past the immediate-constructor case via BRANCHIFNOT, so
         the value must be a [Block]. Cast it, pluck the field, and leave
         the result as K_obj (its kind is inferred lazily by the next op). *)
      Jvm.Code.checkcast state.code "Block";
      Jvm.Code.getfield
        state.code
        ~class_:"Block"
        ~field:"fields"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int state.code field;
      Jvm.Code.aaload state.code;
      state.acc_kind <- K_obj
    | _ ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: GETFIELD on non-block at pc %d"
           ins.pc))
  else if op = Bytecode.Op.setfield0
       || op = Bytecode.Op.setfield1
       || op = Bytecode.Op.setfield2
       || op = Bytecode.Op.setfield3
       || op = Bytecode.Op.setfield
  then (
    let field =
      if op = Bytecode.Op.setfield0
      then 0
      else if op = Bytecode.Op.setfield1
      then 1
      else if op = Bytecode.Op.setfield2
      then 2
      else if op = Bytecode.Op.setfield3
      then 3
      else ins.args.(0)
    in
    let top = List.hd state.slots in
    (match state.acc_kind with
     | K_block _ ->
       Jvm.Code.getfield
         state.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.ldc_int state.code field;
       emit_load_for_kind state.code top.local top.kind;
       box_if_int state.code top.kind;
       Jvm.Code.aastore state.code
     | K_obj ->
       (* Record / mutable block arrived as an opaque Object (e.g. a
          function arg). Cast and proceed. *)
       Jvm.Code.checkcast state.code "Block";
       Jvm.Code.getfield
         state.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.ldc_int state.code field;
       emit_load_for_kind state.code top.local top.kind;
       box_if_int state.code top.kind;
       Jvm.Code.aastore state.code
     | _ ->
       failwith
         (Printf.sprintf
            "java_of_ocaml: SETFIELD on non-block at pc %d"
            ins.pc));
    consume_top state;
    Jvm.Code.ldc_int state.code 0;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.vectlength
  then (
    (match state.acc_kind with
     | K_block _ -> ()
     | K_obj -> Jvm.Code.checkcast state.code "Block"
     | _ ->
       failwith
         (Printf.sprintf "java_of_ocaml: VECTLENGTH on non-block at pc %d" ins.pc));
    Jvm.Code.getfield
      state.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.arraylength state.code;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.offsetref
  then (
    (* Field(acc, 0) += n; acc := unit. Load the Integer, unbox, add n,
       rebox, store back. *)
    let n = ins.args.(0) in
    (match state.acc_kind with
     | K_block _ -> ()
     | K_obj -> Jvm.Code.checkcast state.code "Block"
     | _ ->
       failwith
         (Printf.sprintf "java_of_ocaml: OFFSETREF on non-ref at pc %d" ins.pc));
    Jvm.Code.getfield
      state.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    (* Stack: [fields] *)
    Jvm.Code.dup state.code;
    Jvm.Code.ldc_int state.code 0;
    (* Stack: [fields, fields, 0] *)
    Jvm.Code.dup2 state.code;
    (* Stack: [fields, fields, 0, fields, 0] *)
    Jvm.Code.aaload state.code;
    emit_unbox_to_kind state.code K_int;
    Jvm.Code.ldc_int state.code n;
    Jvm.Code.iadd state.code;
    emit_box_int state.code;
    (* Stack: [fields, fields, 0, new_integer] *)
    Jvm.Code.aastore state.code;
    (* Stack: [fields] *)
    Jvm.Code.pop_top state.code;
    Jvm.Code.ldc_int state.code 0;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.addint then emit_addint state
  else if op = Bytecode.Op.subint then emit_subint state
  else if op = Bytecode.Op.mulint then emit_mulint state
  else if op = Bytecode.Op.divint then emit_divint state
  else if op = Bytecode.Op.modint then emit_modint state
  else if op = Bytecode.Op.push then emit_push state
  else if op = Bytecode.Op.acc0 then emit_acc state 0
  else if op = Bytecode.Op.acc1 then emit_acc state 1
  else if op = Bytecode.Op.acc2 then emit_acc state 2
  else if op = Bytecode.Op.acc3 then emit_acc state 3
  else if op = Bytecode.Op.acc4 then emit_acc state 4
  else if op = Bytecode.Op.acc5 then emit_acc state 5
  else if op = Bytecode.Op.acc6 then emit_acc state 6
  else if op = Bytecode.Op.acc7 then emit_acc state 7
  else if op = Bytecode.Op.acc then emit_acc state ins.args.(0)
  else if op = Bytecode.Op.pushacc0 then emit_pushacc state 0
  else if op = Bytecode.Op.pushacc1 then emit_pushacc state 1
  else if op = Bytecode.Op.pushacc2 then emit_pushacc state 2
  else if op = Bytecode.Op.pushacc3 then emit_pushacc state 3
  else if op = Bytecode.Op.pushacc4 then emit_pushacc state 4
  else if op = Bytecode.Op.pushacc5 then emit_pushacc state 5
  else if op = Bytecode.Op.pushacc6 then emit_pushacc state 6
  else if op = Bytecode.Op.pushacc7 then emit_pushacc state 7
  else if op = Bytecode.Op.pushacc then emit_pushacc state ins.args.(0)
  else if op = Bytecode.Op.pop
  then (
    (* The module-init trailer emits POP 2 / POP N where N may exceed what
       we've tracked (we ignore MAKEBLOCK1 and other trailer ops). Clamp
       the pop to the available depth to stay robust. *)
    let n = min ins.args.(0) state.oc_stack_depth in
    pop_slots state n)
  else if op = Bytecode.Op.assign
  then (
    (* OCaml semantics: stack[k] := acc ; acc := unit. We store acc into
       the JVM local of a caller slot, then overwrite acc with 0 (our
       unit sentinel). *)
    let k = ins.args.(0) in
    if k < 0 || k >= state.oc_stack_depth
    then
      failwith
        (Printf.sprintf
           "java_of_ocaml: ASSIGN %d out of range (depth %d) at pc %d"
           k
           state.oc_stack_depth
           ins.pc);
    if not state.acc_live
    then
      failwith
        (Printf.sprintf "java_of_ocaml: ASSIGN with dead acc at pc %d" ins.pc);
    let target = (List.nth state.slots k).local in
    Jvm.Code.istore state.code target;
    Jvm.Code.ldc_int state.code 0;
    state.acc_live <- true;
    state.acc_kind <- K_int)
  else if op = Bytecode.Op.getglobal
  then (
    match inspect_global state.globals ins.args.(0) with
    | G_string s -> emit_string_const state s
    | G_block (tag, fields) ->
      if state.acc_live then Jvm.Code.pop_top state.code;
      emit_materialise_block_constant state tag fields;
      state.acc_live <- true;
      state.acc_kind <- K_block (List.map kind_of_global_field fields)
    | G_unsupported ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: GETGLOBAL %d at pc %d — global has an \
            unsupported shape (nested blocks / abstract values aren't \
            materialised yet)"
           ins.args.(0)
           ins.pc))
  else if op = Bytecode.Op.pushgetglobal
  then (
    match inspect_global state.globals ins.args.(0) with
    | G_string s -> emit_string_push state s
    | G_block (tag, fields) ->
      let was_live = state.acc_live in
      emit_push state;
      if was_live then Jvm.Code.pop_top state.code;
      emit_materialise_block_constant state tag fields;
      state.acc_live <- true;
      state.acc_kind <- K_block (List.map kind_of_global_field fields)
    | G_unsupported ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: PUSHGETGLOBAL %d at pc %d — global has an \
            unsupported shape"
           ins.args.(0)
           ins.pc))
  else if op = Bytecode.Op.branch
  then (
    let target = ins.pc + ins.args.(0) + 1 in
    Jvm.Code.goto state.code (label_at state target);
    record_branch_target state target)
  else if is_cmp_jump op then emit_cmp_jump state ins
  else if op = closurerec_op then emit_closurerec state ins
  else if op = closure_op then emit_closure state ins
  else if op = Bytecode.Op.envacc1 then emit_envacc state 1
  else if op = Bytecode.Op.envacc2 then emit_envacc state 2
  else if op = Bytecode.Op.envacc3 then emit_envacc state 3
  else if op = Bytecode.Op.envacc4 then emit_envacc state 4
  else if op = Bytecode.Op.envacc then emit_envacc state ins.args.(0)
  else if op = Bytecode.Op.pushenvacc1 then emit_pushenvacc state 1
  else if op = Bytecode.Op.pushenvacc2 then emit_pushenvacc state 2
  else if op = Bytecode.Op.pushenvacc3 then emit_pushenvacc state 3
  else if op = Bytecode.Op.pushenvacc4 then emit_pushenvacc state 4
  else if op = Bytecode.Op.pushenvacc then emit_pushenvacc state ins.args.(0)
  else if op = offsetclosure0_op then emit_offsetclosure0 state
  else if op = pushoffsetclosure0_op then emit_pushoffsetclosure0 state
  else if op = offsetclosurem3_op then emit_offsetclosure state (-3)
  else if op = offsetclosure3_op then emit_offsetclosure state 3
  else if op = offsetclosure_op then emit_offsetclosure state ins.args.(0)
  else if op = pushoffsetclosurem3_op then emit_pushoffsetclosure state (-3)
  else if op = pushoffsetclosure3_op then emit_pushoffsetclosure state 3
  else if op = pushoffsetclosure_op
  then emit_pushoffsetclosure state ins.args.(0)
  else if op = apply1_op then emit_apply1 state
  else if op = apply2_op then emit_apply state ~nargs:2
  else if op = apply3_op then emit_apply state ~nargs:3
  else if op = apply_op then emit_apply state ~nargs:ins.args.(0)
  else if op = appterm1_op then emit_appterm state ~nargs:1
  else if op = appterm2_op then emit_appterm state ~nargs:2
  else if op = appterm3_op then emit_appterm state ~nargs:3
  else if op = appterm_op then emit_appterm state ~nargs:ins.args.(0)
  else if op = return_op then emit_return state
  else if op = restart_op || op = grab_op then
    (* Function-entry prologue. We already extracted [nargs] up-front and
       the JVM convention puts args in locals 0..nargs-1; nothing to emit. *)
    ()
  else if op = event_op || op = break_op then
    (* Debug markers from [ocamlc -g]. Nothing to emit; they're there for
       the OCaml debugger only. *)
    ()
  else if op = 92 then
    (* CHECK_SIGNALS — OCaml bytecode polls for signals at loop headers.
       We don't model OCaml's signal machinery, so this is a no-op. *)
    ()
  else if is_c_call op
  then (
    match Hashtbl.find_opt state.supported_prims ins.args.(0) with
    | Some (_name, handler, _seed) ->
      (match handler with
       | P_println_int -> emit_println state ~int_arg:true
       | P_println_string -> emit_println state ~int_arg:false
       | P_array_get -> emit_array_get state
       | P_array_set -> emit_array_set state
       | P_obj_dup -> emit_obj_dup state
       | P_fresh_oo_id -> emit_fresh_oo_id state
       | P_alloc_dummy -> emit_alloc_dummy state
       | P_update_dummy -> emit_update_dummy state)
    | None ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: unsupported primitive call #%d at pc %d"
           ins.args.(0)
           ins.pc))
  else
    failwith
      (Printf.sprintf
         "java_of_ocaml: unsupported opcode %s (%d) at pc %d"
         (Bytecode.opcode_name op)
         op
         ins.pc)

(* -------------------------------------------------------------------------- *)
(* Range selection. *)

(* -------------------------------------------------------------------------- *)
(* Compile-wide driver. *)

let collect_pc_to_label
    code
    ~arr
    ~scan_range:(scan_lo, scan_hi)
    ~target_range:(tgt_lo_pc, tgt_hi_pc)
    ~skip_pcs
  =
  let tbl = Hashtbl.create 4 in
  for i = scan_lo to scan_hi do
    if not (Hashtbl.mem skip_pcs arr.(i).pc)
    then
      List.iter
        (fun target_pc ->
          if target_pc >= tgt_lo_pc
             && target_pc <= tgt_hi_pc
             && not (Hashtbl.mem tbl target_pc)
          then Hashtbl.add tbl target_pc (Jvm.Code.fresh_label code))
        (branch_targets arr.(i))
  done;
  tbl

let emit_range state arr (lo, hi) ~skip_pcs =
  for i = lo to hi do
    if not (Hashtbl.mem skip_pcs arr.(i).pc)
    then emit_instr state arr.(i)
  done

let compile ~bc ~out_dir =
  let parsed = Bytecode.read_exe bc in
  let prim_table = Prim.find_supported_prims parsed in
  if Hashtbl.length prim_table = 0
  then
    failwith
      "java_of_ocaml: bytecode references none of the supported primitives \
       (caml_java_print_endline, caml_java_print_int).";
  let instrs = decode_all parsed in
  let arr = Array.of_list instrs in
  let first_idx, last_idx =
    match Inference.supported_call_indices arr ~prim_table with
    | Some p -> p
    | None ->
      failwith "java_of_ocaml: no supported primitive calls found"
  in
  let start_idx = Inference.walk_back_user_start arr first_idx in
  let end_idx = Inference.walk_forward_user_end arr last_idx in
  (* Pre-scan for CLOSUREREC within the user range. *)
  let functions = Hashtbl.create 2 in
  let func_list = ref [] in
  let fn_body_pcs = Hashtbl.create 4 in
  let fn_count = ref 0 in
  for i = start_idx to end_idx do
    let ins = arr.(i) in
    if ins.opcode = closurerec_op || ins.opcode = closure_op
    then (
      let recursive = ins.opcode = closurerec_op in
      let nfuncs, nvars, body_pc_of =
        if recursive
        then (
          let nf = ins.args.(0) in
          let nv = ins.args.(1) in
          nf, nv, fun k -> ins.pc + 3 + ins.args.(2 + k))
        else (
          let nv = ins.args.(0) in
          1, nv, fun _ -> ins.pc + ins.args.(1) + 2)
      in
      let group = Array.make nfuncs (Obj.magic () : function_info) in
      for k = 0 to nfuncs - 1 do
        let body_pc = body_pc_of k in
        let body_start_idx, body_end_idx, nargs =
          find_function_body_range arr body_pc
        in
        let name = Printf.sprintf "ocaml_fn_%d" !fn_count in
        incr fn_count;
        let info =
          { name
          ; closurerec_pc = ins.pc
          ; body_pc
          ; body_start_idx
          ; body_end_idx
          ; nargs
          ; ncaps = nvars
          ; return_kind = ref K_int
          ; arg_kinds = ref (List.init nargs (fun _ -> K_int))
          ; capture_kinds = ref []
          ; recursive
          ; group_idx = k
          ; group = [||] (* filled in below *)
          }
        in
        group.(k) <- info;
        (* Main dispatch uses [functions] keyed by closurerec pc to look
           up the group's first function; nested [OFFSETCLOSURE] uses the
           [group] field to navigate to siblings. *)
        if k = 0 then Hashtbl.add functions ins.pc info;
        func_list := info :: !func_list;
        let pre_start =
          let rec find i =
            if i >= Array.length arr then i
            else if arr.(i).pc = body_pc then i
            else find (i + 1)
          in
          find 0
        in
        for j = pre_start to body_end_idx do
          Hashtbl.replace fn_body_pcs arr.(j).pc ()
        done
      done;
      Array.iter (fun info -> info.group <- group) group)
  done;
  (* Build a name -> function_info index for APPLY return-kind lookup, and
     run a quick pre-pass to seed each function's return_kind from the
     instruction preceding its RETURN / APPTERM. *)
  let fn_by_name = Hashtbl.create 4 in
  List.iter
    (fun (fi : function_info) -> Hashtbl.add fn_by_name fi.name fi)
    !func_list;
  List.iter
    (fun (fi : function_info) ->
      fi.return_kind := Inference.infer_return_kind arr !func_list fi;
      fi.arg_kinds := Inference.infer_arg_kinds arr prim_table fi)
    !func_list;
  let cp = Jvm.Cp.create () in
  (* Emit main first so that CLOSURE/CLOSUREREC sites can fill in each
     function's [capture_kinds] from the kinds of values captured at the
     call site. Function bodies are then emitted with that information. *)
  let main_code = Jvm.Code.create cp in
  let fresh_oo_id_counter = ref 0 in
  let post_end_pc =
    if end_idx + 1 < Array.length arr then arr.(end_idx + 1).pc else max_int
  in
  let pc_to_label =
    collect_pc_to_label
      main_code
      ~arr
      ~scan_range:(start_idx, end_idx)
      ~target_range:(arr.(start_idx).pc, post_end_pc)
      ~skip_pcs:fn_body_pcs
  in
  let state =
    { code = main_code
    ; globals = parsed.globals
    ; supported_prims = prim_table
    ; functions
    ; fn_by_name
    ; pc_to_label
    ; branch_target_state = Hashtbl.create 4
    ; acc_live = false
    ; acc_kind = K_int
    ; slots = []
    ; oc_stack_depth = 0
    ; next_local = 1 (* local 0 reserved for [String[] args] *)
    ; pending_cmp = None
    ; nargs = 0
    ; ncaps = 0
    ; capture_kinds = []
    ; enclosing_function_name = None
    ; pending_handlers = Hashtbl.create 2
    ; open_traps = []
    ; fresh_oo_id_counter
    ; pending_retaddrs = 0
    }
  in
  emit_range state arr (start_idx, end_idx) ~skip_pcs:fn_body_pcs;
  (match Hashtbl.find_opt pc_to_label post_end_pc with
   | Some lbl -> Jvm.Code.mark_label main_code lbl
   | None -> ());
  Jvm.Code.return_void main_code;
  let main_method =
    { Jvm.name = "main"
    ; descriptor = "([Ljava/lang/String;)V"
    ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
    ; code = main_code
    }
  in
  let main_class_bytes =
    Jvm.assemble_class
      ~class_name:"Main"
      ~super_name:"java/lang/Object"
      ~cp
      ~fields:[]
      ~methods:[ main_method ]
      ~access_flags:0x0021 (* ACC_PUBLIC | ACC_SUPER *)
  in
  (* Now emit each function as its own concrete [Closure] subclass. Each
     closure class has:
       - one instance field per capture, named [capN] (field order).
       - a constructor taking the captures as args, assigning them to the
         fields after calling [Closure.<init>()].
       - an [applyN] method whose body is the OCaml function's bytecode,
         with a prologue that unboxes [K_int] args from their [Object]
         parameters, and RETURN/APPTERM that box the result before
         [areturn]. *)
  let closure_class_files =
    List.map
      (fun (fn_info : function_info) ->
        let cap_kinds = !(fn_info.capture_kinds) in
        let ncaps = List.length cap_kinds in
        let fn_cp = Jvm.Cp.create () in
        (* --- Constructor --- *)
        let ctor_code = Jvm.Code.create fn_cp in
        Jvm.Code.set_min_locals ctor_code (1 + ncaps);
        Jvm.Code.aload ctor_code 0;
        Jvm.Code.invokespecial
          ctor_code
          ~class_:"Closure"
          ~method_:"<init>"
          ~descriptor:"()V";
        List.iteri
          (fun i k ->
            Jvm.Code.aload ctor_code 0;
            emit_load_for_kind ctor_code (i + 1) k;
            Jvm.Code.putfield
              ctor_code
              ~class_:fn_info.name
              ~field:(Printf.sprintf "cap%d" i)
              ~descriptor:(jvm_type_of_kind k))
          cap_kinds;
        Jvm.Code.return_void ctor_code;
        (* --- apply method body --- *)
        let apply_code = Jvm.Code.create fn_cp in
        (* Reserve max_locals: [this] + N args. *)
        Jvm.Code.set_min_locals apply_code (1 + fn_info.nargs);
        (* No prologue: apply method args arrive as [Object], and we keep
           them that way in their locals. Each op that needs a specific
           kind (arithmetic → int; println(string) → String; etc.) casts
           or unboxes on first use via [ensure_kind]. This avoids static
           arg-kind inference and handles transitive cases like
           mkgreeter, where the arg's kind is only determined by where
           it ends up (in this case, a closure capture). *)
        let initial_slots =
          let rec make k =
            if k >= fn_info.nargs
            then []
            else { kind = K_obj; local = k + 1 } :: make (k + 1)
          in
          make 0
        in
        let pc_to_label =
          collect_pc_to_label
            apply_code
            ~arr
            ~scan_range:(fn_info.body_start_idx, fn_info.body_end_idx)
            ~target_range:
              (arr.(fn_info.body_start_idx).pc, arr.(fn_info.body_end_idx).pc)
            ~skip_pcs:(Hashtbl.create 0)
        in
        let state =
          { code = apply_code
          ; globals = parsed.globals
          ; supported_prims = prim_table
          ; functions
          ; fn_by_name
          ; pc_to_label
          ; branch_target_state = Hashtbl.create 4
          ; acc_live = false
          ; acc_kind = K_int
          ; slots = initial_slots
          ; oc_stack_depth = fn_info.nargs
          ; next_local = 1 + fn_info.nargs
          ; pending_cmp = None
          ; nargs = fn_info.nargs
          ; ncaps
          ; capture_kinds = cap_kinds
          ; enclosing_function_name = Some fn_info.name
          ; pending_handlers = Hashtbl.create 2
          ; open_traps = []
          ; fresh_oo_id_counter
          ; pending_retaddrs = 0
          }
        in
        emit_range
          state
          arr
          (fn_info.body_start_idx, fn_info.body_end_idx)
          ~skip_pcs:(Hashtbl.create 0);
        let cap_fields =
          List.mapi
            (fun i k ->
              { Jvm.name = Printf.sprintf "cap%d" i
              ; descriptor = jvm_type_of_kind k
              ; access_flags = 0x0011 (* ACC_PUBLIC | ACC_FINAL *)
              })
            cap_kinds
        in
        (* Sibling fields for CLOSUREREC groups > 1 function. Each
           function in the group holds [Closure]-typed refs to the
           others so [OFFSETCLOSURE N] can resolve statically to a
           [getfield sibling_K]. Mutable so the [CLOSUREREC] emission
           can allocate all group members and then patch cross-refs. *)
        let sibling_fields =
          let n = Array.length fn_info.group in
          if n <= 1
          then []
          else
            List.init n (fun i ->
              { Jvm.name = Printf.sprintf "sibling_%d" i
              ; descriptor = "LClosure;"
              ; access_flags = 0x0001 (* ACC_PUBLIC, mutable *)
              })
        in
        let fields = cap_fields @ sibling_fields in
        let ctor =
          { Jvm.name = "<init>"
          ; descriptor = ctor_descriptor_for_captures cap_kinds
          ; access_flags = 0x0001 (* ACC_PUBLIC *)
          ; code = ctor_code
          }
        in
        let apply_method =
          { Jvm.name = Printf.sprintf "apply%d" fn_info.nargs
          ; descriptor = apply_descriptor_for_nargs fn_info.nargs
          ; access_flags = 0x0001 (* ACC_PUBLIC *)
          ; code = apply_code
          }
        in
        (* [arity()] override so the base [Closure]'s dispatch (and
           [PartialClosure]'s saturation check) sees this subclass's
           actual arity. *)
        let arity_code = Jvm.Code.create fn_cp in
        Jvm.Code.set_min_locals arity_code 1;
        Jvm.Code.ldc_int arity_code fn_info.nargs;
        Jvm.Code.ireturn arity_code;
        let arity_method =
          { Jvm.name = "arity"
          ; descriptor = "()I"
          ; access_flags = 0x0001
          ; code = arity_code
          }
        in
        let bytes =
          Jvm.assemble_class
            ~class_name:fn_info.name
            ~super_name:"Closure"
            ~cp:fn_cp
            ~fields
            ~methods:[ ctor; arity_method; apply_method ]
            ~access_flags:0x0031 (* ACC_PUBLIC | ACC_SUPER | ACC_FINAL *)
        in
        fn_info.name, bytes)
      !func_list
  in
  let write_class name bytes =
    let path = Filename.concat out_dir (name ^ ".class") in
    let oc = open_out_bin path in
    output_string oc bytes;
    close_out oc
  in
  write_class "Main" main_class_bytes;
  write_class "Block" (Jvm.block_class_bytes ());
  write_class "Closure" (Jvm.closure_class_bytes ());
  write_class "CamlException" (Jvm.camlexception_class_bytes ());
  write_class "PartialClosure" (Jvm.partial_closure_class_bytes ());
  List.iter (fun (name, bytes) -> write_class name bytes) closure_class_files
