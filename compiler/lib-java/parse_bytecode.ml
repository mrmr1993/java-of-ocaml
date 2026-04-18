(* Lower OCaml bytecode to the Code IR.

   Mirrors js_of_ocaml/compiler/lib/parse_bytecode.ml in structure:
   compute block boundaries by scanning branches, then process each
   block with a State threading accu + stack, emitting Let/Assign/etc
   and a block terminator. *)

open Code

exception Not_supported of string

let trace_enabled =
  lazy
    (match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
     | None -> false
     | Some s ->
       List.mem "ir_trace" (List.map String.trim (String.split_on_char ',' s)))

let trace fmt =
  if Lazy.force trace_enabled
  then Format.kasprintf (fun s -> Format.eprintf "[ir_trace] %s@." s) fmt
  else Format.ikfprintf (fun _ -> ()) Format.err_formatter fmt

module IntSet = Set.Make (Int)
module IntMap = Map.Make (Int)

(* ------------------------------------------------------------------
   Block boundary discovery
   ------------------------------------------------------------------ *)

(* [block_starts] returns the sorted set of PCs that start a block
   within [start_pc..end_pc). A block starts at:
   - [start_pc] itself
   - any branch target
   - the PC immediately after a terminator
   - the PC immediately after a PUSHTRAP (the handler prelude target)
     is already covered as a branch target, and the fall-through PC
     starts a block too. *)
let block_starts instrs ~start_pc ~end_pc =
  let s = ref (IntSet.singleton start_pc) in
  let in_range pc = pc >= start_pc && pc < end_pc in
  let add pc = if in_range pc then s := IntSet.add pc !s in
  List.iter
    (fun (ins : Instr.instr) ->
      if in_range ins.pc
      then (
        List.iter add (Instr.branch_targets ins);
        if Instr.is_terminator ins.opcode
           || ins.opcode = Bytecode.Op.pushtrap
           || ins.opcode = Bytecode.Op.poptrap
        then
          (* PC after the instruction starts a new block. We need the
             next instruction's pc; find the successor from the array
             below. *)
          ()))
    instrs;
  (* Add PCs after terminators / trap ops; do it in a second pass that
     knows instruction successors. *)
  let arr = Array.of_list instrs in
  for i = 0 to Array.length arr - 1 do
    let ins = arr.(i) in
    if in_range ins.pc
       && (Instr.is_terminator ins.opcode
          || ins.opcode = Bytecode.Op.pushtrap
          || ins.opcode = Bytecode.Op.poptrap)
       && i + 1 < Array.length arr
    then add arr.(i + 1).pc
  done;
  !s

(* ------------------------------------------------------------------
   Parser state
   ------------------------------------------------------------------ *)

(* [elt] matches jsoo's: a stack slot is either a live Var or a Dummy
   placeholder (PUSH_RETADDR sentinels, PUSHTRAP trap-frame words).
   Dummies are never materialised in the IR; they only keep the stack
   depth consistent so ACC k resolves to the right slot. *)
type elt =
  | V of Var.t
  | Dummy

type state =
  { mutable accu : elt
  ; mutable stack : elt list
  ; mutable body : instr list
  ; target_params : (Addr.t, Var.t list) Hashtbl.t
  ; env : Var.t option
        (** [Some v] in a function body: [v] is the closure itself
            (read by ENVACC / OFFSETCLOSURE). [None] in main. *)
  ; mutable current_pc : int
        (** For diagnostics. *)
  ; mutable current_block_start : int
  }

let emit s i = s.body <- i :: s.body

let var_of = function
  | V v -> v
  | Dummy -> raise (Not_supported "read of Dummy stack slot")

(* Retrieve or allocate the canonical params list for a target block. *)
let params_for state addr ~accu_and_stack =
  match Hashtbl.find_opt state.target_params addr with
  | Some ps -> ps
  | None ->
    let ps = List.map (fun _ -> Var.fresh ()) accu_and_stack in
    Hashtbl.add state.target_params addr ps;
    ps

(* ------------------------------------------------------------------
   Constant conversion: OCaml [Obj.t] -> [Code.constant]
   ------------------------------------------------------------------ *)

let[@warning "-32"] rec constant_of_obj (o : Obj.t) : constant =
  if Obj.is_int o
  then Int (Obj.magic o : int)
  else
    let t = Obj.tag o in
    if t = Obj.string_tag
    then String (Obj.magic o : string)
    else if t = Obj.double_tag
    then Float (Obj.magic o : float)
    else if t < Obj.no_scan_tag
    then (
      let n = Obj.size o in
      let fields = Array.init n (fun i -> constant_of_obj (Obj.field o i)) in
      Block (t, fields))
    else raise (Not_supported (Printf.sprintf "unsupported global tag %d" t))

(* ------------------------------------------------------------------
   Accumulator / stack helpers
   ------------------------------------------------------------------ *)

let push_elt s e = s.stack <- e :: s.stack
let pop s =
  match s.stack with
  | [] -> raise (Not_supported "pop on empty stack")
  | x :: rest -> s.stack <- rest; x
let pop_var s = var_of (pop s)

let take_args s n =
  let rec loop i acc =
    if i = 0 then List.rev acc
    else loop (i - 1) (pop_var s :: acc)
  in
  loop n []

let set_accu_let s e =
  let x = Var.fresh () in
  emit s (Let (x, e));
  s.accu <- V x

(* ------------------------------------------------------------------
   Per-opcode lowering
   ------------------------------------------------------------------ *)

(* Given a prim + N args popped/consumed from accu + stack, bind the
   result to a fresh Var and leave it in accu. *)
let binop s p =
  let a = var_of s.accu in
  let b = pop_var s in
  set_accu_let s (Prim (p, [ Pv a; Pv b ]))

let unop s p =
  let a = var_of s.accu in
  set_accu_let s (Prim (p, [ Pv a ]))

let const_int s n =
  set_accu_let s (Constant (Int n))


(* For slot-read/write (ACC / ASSIGN): OCaml stack is 0-indexed from
   the top; stack[0] = top. *)
let nth_stack s k =
  try List.nth s.stack k
  with _ ->
    raise
      (Not_supported
         (Printf.sprintf
            "stack index %d out of range (depth=%d at pc=%d, block_start=%d)"
            k
            (List.length s.stack)
            s.current_pc
            s.current_block_start))

let acc s k = s.accu <- nth_stack s k

(* ------------------------------------------------------------------
   Block processing
   ------------------------------------------------------------------ *)

(* Convert every stack slot (including Dummies) to a Var for passing
   across a block edge. Dummy slots become fresh Vars bound to [Null]
   — the value never matters (PUSH_RETADDR/PUSHTRAP trap-frame words
   are opaque to the OCaml interpreter), but assigning a Var keeps the
   IR's shape consistent at joins. *)
let s_to_list state =
  let of_elt = function
    | V v -> v
    | Dummy ->
      let v = Var.fresh () in
      state.body <- Let (v, Constant Null) :: state.body;
      v
  in
  of_elt state.accu :: List.map of_elt state.stack

(* Produce a cont = (target_pc, args) by materialising accu + stack as
   the args for a caller block's params. *)
let make_cont state target_pc =
  let accu_and_stack = s_to_list state in
  let _params = params_for state target_pc ~accu_and_stack in
  (target_pc, accu_and_stack)

(* Advance the state by one instruction. Returns [Some last] if the
   instruction was a terminator, [None] otherwise. *)
let step (state : state) (ins : Instr.instr) : last option =
  let op = ins.opcode in
  let args = ins.args in
  let nullary p = unop state p in
  let _ = nullary in
  (* ACC k *)
  if Instr.is_acc op
  then (
    let k = if op = Bytecode.Op.acc then args.(0) else op - Bytecode.Op.acc0 in
    acc state k;
    None)
  else if Instr.is_pushacc op
  then (
    let k =
      if op = Bytecode.Op.pushacc then args.(0) else op - Bytecode.Op.pushacc0
    in
    push_elt state state.accu;
    acc state k;
    None)
  else if op = Bytecode.Op.push
  then (
    push_elt state state.accu;
    None)
  else if op = Bytecode.Op.pop
  then (
    for _ = 1 to args.(0) do
      ignore (pop state)
    done;
    None)
  else if op = Bytecode.Op.push_retaddr
  then (
    push_elt state Dummy;
    push_elt state Dummy;
    push_elt state Dummy;
    None)
  else if op = Bytecode.Op.const0
  then (const_int state 0; None)
  else if op = Bytecode.Op.const1
  then (const_int state 1; None)
  else if op = Bytecode.Op.const2
  then (const_int state 2; None)
  else if op = Bytecode.Op.const3
  then (const_int state 3; None)
  else if op = Bytecode.Op.constint
  then (const_int state args.(0); None)
  else if op = Bytecode.Op.pushconst0
  then (push_elt state state.accu; const_int state 0; None)
  else if op = Bytecode.Op.pushconst1
  then (push_elt state state.accu; const_int state 1; None)
  else if op = Bytecode.Op.pushconst2
  then (push_elt state state.accu; const_int state 2; None)
  else if op = Bytecode.Op.pushconst3
  then (push_elt state state.accu; const_int state 3; None)
  else if op = Bytecode.Op.pushconstint
  then (push_elt state state.accu; const_int state args.(0); None)
  else if op = Bytecode.Op.negint
  then (unop state (Extern "neg_int"); None)
  else if op = Bytecode.Op.addint
  then (binop state (Extern "add_int"); None)
  else if op = Bytecode.Op.subint
  then (binop state (Extern "sub_int"); None)
  else if op = Bytecode.Op.mulint
  then (binop state (Extern "mul_int"); None)
  else if op = Bytecode.Op.divint
  then (binop state (Extern "div_int"); None)
  else if op = Bytecode.Op.modint
  then (binop state (Extern "mod_int"); None)
  else if op = Bytecode.Op.andint
  then (binop state (Extern "and_int"); None)
  else if op = Bytecode.Op.orint
  then (binop state (Extern "or_int"); None)
  else if op = Bytecode.Op.xorint
  then (binop state (Extern "xor_int"); None)
  else if op = Bytecode.Op.lslint
  then (binop state (Extern "lsl_int"); None)
  else if op = Bytecode.Op.lsrint
  then (binop state (Extern "lsr_int"); None)
  else if op = Bytecode.Op.asrint
  then (binop state (Extern "asr_int"); None)
  else if op = Bytecode.Op.offsetint
  then (
    let a = var_of state.accu in
    let c = Var.fresh () in
    emit state (Let (c, Constant (Int args.(0))));
    let r = Var.fresh () in
    emit state (Let (r, Prim (Extern "add_int", [ Pv a; Pv c ])));
    state.accu <- V r;
    None)
  else if op = Bytecode.Op.offsetref
  then (
    let a = var_of state.accu in
    emit state (Offset_ref (a, args.(0)));
    None)
  else if op = Bytecode.Op.boolnot
  then (unop state Not; None)
  else if op = Bytecode.Op.isint
  then (unop state IsInt; None)
  else if op = Bytecode.Op.eq
  then (binop state Eq; None)
  else if op = Bytecode.Op.neq
  then (binop state Neq; None)
  else if op = Bytecode.Op.ltint
  then (binop state Lt; None)
  else if op = Bytecode.Op.leint
  then (binop state Le; None)
  else if op = Bytecode.Op.gtint
  then (binop state Gt; None)
  else if op = Bytecode.Op.geint
  then (binop state Ge; None)
  else if op = Bytecode.Op.ultint
  then (binop state Ult; None)
  else if op = Bytecode.Op.ugeint
  then (binop state Uge; None)
  (* ENVACC family — read a field of the current closure. *)
  else if op = Bytecode.Op.envacc1
       || op = Bytecode.Op.envacc2
       || op = Bytecode.Op.envacc3
       || op = Bytecode.Op.envacc4
       || op = Bytecode.Op.envacc
  then (
    let k =
      if op = Bytecode.Op.envacc then args.(0)
      else op - Bytecode.Op.envacc1 + 1
    in
    match state.env with
    | None -> raise (Not_supported "ENVACC outside a function")
    | Some env ->
      set_accu_let state (Field (env, k));
      None)
  else if op = Bytecode.Op.pushenvacc1
       || op = Bytecode.Op.pushenvacc2
       || op = Bytecode.Op.pushenvacc3
       || op = Bytecode.Op.pushenvacc4
       || op = Bytecode.Op.pushenvacc
  then (
    let k =
      if op = Bytecode.Op.pushenvacc then args.(0)
      else op - Bytecode.Op.pushenvacc1 + 1
    in
    push_elt state state.accu;
    match state.env with
    | None -> raise (Not_supported "PUSHENVACC outside a function")
    | Some env ->
      set_accu_let state (Field (env, k));
      None)
  (* OFFSETCLOSURE — sibling lookup in a CLOSUREREC group. The integer
     arg is the infix offset (0, 3, -3, or N). Modelled as an opaque
     prim; the JVM generator will translate it using the enclosing
     function's group layout. *)
  else if op = Bytecode.Op.offsetclosure0
  then (
    match state.env with
    | None -> raise (Not_supported "OFFSETCLOSURE outside a function")
    | Some env ->
      set_accu_let
        state
        (Prim (Extern "offsetclosure", [ Pv env; Pc (Int 0) ]));
      None)
  else if op = Bytecode.Op.offsetclosure3
  then (
    match state.env with
    | None -> raise (Not_supported "OFFSETCLOSURE outside a function")
    | Some env ->
      set_accu_let
        state
        (Prim (Extern "offsetclosure", [ Pv env; Pc (Int 3) ]));
      None)
  else if op = Bytecode.Op.offsetclosurem3
  then (
    match state.env with
    | None -> raise (Not_supported "OFFSETCLOSURE outside a function")
    | Some env ->
      set_accu_let
        state
        (Prim (Extern "offsetclosure", [ Pv env; Pc (Int (-3)) ]));
      None)
  else if op = Bytecode.Op.offsetclosure
  then (
    match state.env with
    | None -> raise (Not_supported "OFFSETCLOSURE outside a function")
    | Some env ->
      set_accu_let
        state
        (Prim (Extern "offsetclosure", [ Pv env; Pc (Int args.(0)) ]));
      None)
  else if op = Bytecode.Op.pushoffsetclosure0
  then (
    push_elt state state.accu;
    match state.env with
    | None -> raise (Not_supported "PUSHOFFSETCLOSURE outside a function")
    | Some env ->
      set_accu_let
        state
        (Prim (Extern "offsetclosure", [ Pv env; Pc (Int 0) ]));
      None)
  else if op = Bytecode.Op.pushoffsetclosure3
  then (
    push_elt state state.accu;
    match state.env with
    | None -> raise (Not_supported "PUSHOFFSETCLOSURE outside a function")
    | Some env ->
      set_accu_let
        state
        (Prim (Extern "offsetclosure", [ Pv env; Pc (Int 3) ]));
      None)
  else if op = Bytecode.Op.pushoffsetclosurem3
  then (
    push_elt state state.accu;
    match state.env with
    | None -> raise (Not_supported "PUSHOFFSETCLOSURE outside a function")
    | Some env ->
      set_accu_let
        state
        (Prim (Extern "offsetclosure", [ Pv env; Pc (Int (-3)) ]));
      None)
  else if op = Bytecode.Op.pushoffsetclosure
  then (
    push_elt state state.accu;
    match state.env with
    | None -> raise (Not_supported "PUSHOFFSETCLOSURE outside a function")
    | Some env ->
      set_accu_let
        state
        (Prim (Extern "offsetclosure", [ Pv env; Pc (Int args.(0)) ]));
      None)
  (* CLOSURE(nvars, ofs) — allocate a non-recursive closure. If
     [nvars > 0], accu is pushed first and then the top [nvars] stack
     slots are the env captures. Body entry is at [pc + ofs + 2]. *)
  else if op = Bytecode.Op.closure
  then (
    let nvars = args.(0) in
    let body_pc = ins.pc + args.(1) + 2 in
    if nvars > 0 then push_elt state state.accu;
    let captures =
      let rec pop_n n acc =
        if n = 0 then List.rev acc
        else pop_n (n - 1) (pop_var state :: acc)
      in
      pop_n nvars []
    in
    (* Body block sees an empty initial stack and the env Var is
       implicit in its own params. We don't recursively parse here —
       the top-level driver (in compile.ml) walks CLOSUREREC/CLOSURE
       instructions separately and parses each body as its own
       [parse_function]. The closure expression just records the entry
       pc and captures. *)
    set_accu_let
      state
      (Closure { captures; body = (body_pc, []) });
    None)
  (* CLOSUREREC(nfuncs, nvars, ofs_0, ofs_1, ..., ofs_{nfuncs-1}) —
     allocate a group of mutually recursive closures. The group is one
     shared block containing [nfuncs] (code, closinfo, infix) triples
     followed by [nvars] captures.

     Stack effect: if [nvars > 0], accu is pushed first, then the top
     [nvars] stack slots are consumed as captures. After allocation,
     each of the [nfuncs] sibling closures is PUSHed onto the stack,
     top-first; accu holds the first (group_idx=0) sibling.

     We lower this to [nfuncs] distinct [Closure] Lets (one per
     sibling), each with the same captures list. The siblings end up
     distributed across accu + pushed stack just like the interpreter.
     Sibling navigation at runtime (OFFSETCLOSURE_N) reads a field of
     the env rather than a stored sibling pointer; we keep the
     [Extern "offsetclosure"] prim for that. *)
  else if op = Bytecode.Op.closurerec
  then (
    let nfuncs = args.(0) in
    let nvars = args.(1) in
    if nvars > 0 then push_elt state state.accu;
    let captures =
      let rec pop_n n acc =
        if n = 0 then List.rev acc
        else pop_n (n - 1) (pop_var state :: acc)
      in
      pop_n nvars []
    in
    (* Stack discipline per OCaml interp:
       - emit Let for every sibling;
       - set accu = sibling_0;
       - PUSH sibling_0 (so it ends up on the stack as well as in accu);
       - PUSH sibling_i for i = 1 .. nfuncs-1.
       The resulting stack, top-to-bottom, is sibling_{n-1}, ...,
       sibling_1, sibling_0, then whatever was below. *)
    let sibling_vars = Array.init nfuncs (fun _ -> Var.fresh ()) in
    for i = 0 to nfuncs - 1 do
      let body_pc = ins.pc + 3 + args.(2 + i) in
      emit
        state
        (Let
           ( sibling_vars.(i)
           , Closure { captures; body = (body_pc, []) } ))
    done;
    state.accu <- V sibling_vars.(0);
    push_elt state (V sibling_vars.(0));
    for i = 1 to nfuncs - 1 do
      push_elt state (V sibling_vars.(i))
    done;
    None)
  (* C_CALL family — external primitives indexed by prim table. In the
     IR they're Extern prims. *)
  else if Instr.is_c_call op
  then (
    let nargs_ccall = op - 92 (* C_CALL1=93 → 1 arg *) in
    let prim_idx = args.(0) in
    let prim_name = "ccall_" ^ string_of_int prim_idx in
    let a = var_of state.accu in
    let rest = take_args state (nargs_ccall - 1) in
    let all_args = List.map (fun v -> Pv v) (a :: rest) in
    set_accu_let state (Prim (Extern prim_name, all_args));
    None)
  else if op = Bytecode.Op.c_calln
  then (
    let nargs_ccall = args.(0) in
    let prim_idx = args.(1) in
    let prim_name = "ccall_" ^ string_of_int prim_idx in
    let a = var_of state.accu in
    let rest = take_args state (nargs_ccall - 1) in
    let all_args = List.map (fun v -> Pv v) (a :: rest) in
    set_accu_let state (Prim (Extern prim_name, all_args));
    None)
  (* BULTINT / BUGEINT — unsigned fused compare-and-branch. *)
  else if op = Bytecode.Op.bultint || op = Bytecode.Op.bugeint
  then (
    let a = var_of state.accu in
    let cmp = if op = Bytecode.Op.bultint then Ult else Uge in
    let c = Var.fresh () in
    emit state (Let (c, Constant (Int args.(0))));
    let r = Var.fresh () in
    emit state (Let (r, Prim (cmp, [ Pv a; Pv c ])));
    let then_pc = ins.pc + args.(1) + 2 in
    let else_pc = ins.pc + 3 in
    Some (Cond (r, make_cont state then_pc, make_cont state else_pc)))
  (* SWITCH(sizes, offsets...) — OCaml's switch splits immediates from
     blocks. args.(0) packs num_ints in low 16 bits, num_tags in high.
     Cases 0..num_ints-1 match on the int value; cases 0..num_tags-1
     match on the block tag — but we collapse to a single-dimensional
     switch on accu at IR level and let the generator split. *)
  else if op = Bytecode.Op.switch
  then (
    let a = var_of state.accu in
    let sizes = args.(0) in
    let num_ints = sizes land 0xffff in
    let num_tags = (sizes lsr 16) land 0xffff in
    let total = num_ints + num_tags in
    let cases =
      Array.init total (fun i ->
        let target_pc = ins.pc + 2 + args.(1 + i) in
        make_cont state target_pc)
    in
    Some (Switch (a, cases)))
  (* PUSHTRAP L — open a try/with region. The OCaml interp pushes four
     trap-frame words onto the stack (Dummies in our IR) and registers
     L as the handler. We lower to Pushtrap (body, exn_var, handler);
     the body block starts at PC+2 (after the 2-word PUSHTRAP), the
     handler at [pc + arg + 1]. *)
  else if op = Bytecode.Op.pushtrap
  then (
    (* Capture the handler-entry state *before* the 4 trap-frame
       dummies are pushed. When the exception fires, the runtime
       pops the dummies and jumps to the handler with accu = exn and
       the stack exactly as it was here. *)
    let handler_pc = ins.pc + args.(0) + 1 in
    let body_pc = ins.pc + 2 in
    let exn_var = Var.fresh () in
    let handler_stack_vars =
      List.map
        (function
          | V v -> v
          | Dummy ->
            let v = Var.fresh () in
            state.body <- Let (v, Constant Null) :: state.body;
            v)
        state.stack
    in
    let handler_cont = (handler_pc, exn_var :: handler_stack_vars) in
    let _ = params_for state handler_pc ~accu_and_stack:(snd handler_cont) in
    (* Now push 4 Dummies for the protected body and record the
       body_cont. *)
    push_elt state Dummy;
    push_elt state Dummy;
    push_elt state Dummy;
    push_elt state Dummy;
    Some (Pushtrap (make_cont state body_pc, exn_var, handler_cont)))
  (* POPTRAP — pop the 4 trap-frame dummies and resume in the next
     block. *)
  else if op = Bytecode.Op.poptrap
  then (
    (* The 4 trap-frame slots may be Dummies (if this block starts
       straight after PUSHTRAP) or Vars (if a prior block edge
       materialised them via [s_to_list]). Drop either. *)
    for _ = 1 to 4 do
      ignore (pop state)
    done;
    (* Successor PC: next instruction. We don't have it here directly,
       so we terminate with Poptrap of a Branch cont to the next
       instruction's PC. The [walk] function handles this by not
       falling through — but Poptrap isn't actually a terminator in
       the same sense as Return/Branch. For now, treat it as a branch
       to the fall-through PC. *)
    let next_pc = ins.pc + 1 in
    Some (Poptrap (make_cont state next_pc)))
  (* String / bytes / float-block ops. *)
  else if op = Bytecode.Op.getstringchar || op = Bytecode.Op.getbyteschar
  then (binop state (Extern "get_byte"); None)
  else if op = Bytecode.Op.setbyteschar
  then (
    let s = var_of state.accu in
    let i = pop_var state in
    let v = pop_var state in
    let r = Var.fresh () in
    emit
      state
      (Let (r, Prim (Extern "set_byte", [ Pv s; Pv i; Pv v ])));
    state.accu <- V r;
    None)
  else if op = Bytecode.Op.makefloatblock
  then (
    let n = args.(0) in
    let fields = Array.make n (Var.fresh ()) in
    fields.(0) <- var_of state.accu;
    for i = 1 to n - 1 do
      fields.(i) <- pop_var state
    done;
    set_accu_let state (Block (Obj.double_array_tag, fields));
    None)
  else if op = Bytecode.Op.getfloatfield
  then (
    let a = var_of state.accu in
    set_accu_let state (Field (a, args.(0)));
    None)
  else if op = Bytecode.Op.setfloatfield
  then (
    let a = var_of state.accu in
    let v = pop_var state in
    emit state (Set_field (a, args.(0), v));
    None)
  else if op = Bytecode.Op.atom0
  then (set_accu_let state (Constant (Block (0, [||]))); None)
  else if op = Bytecode.Op.atom
  then (set_accu_let state (Constant (Block (args.(0), [||]))); None)
  else if op = Bytecode.Op.pushatom0
  then (
    push_elt state state.accu;
    set_accu_let state (Constant (Block (0, [||])));
    None)
  else if op = Bytecode.Op.pushatom
  then (
    push_elt state state.accu;
    set_accu_let state (Constant (Block (args.(0), [||])));
    None)
  (* ASSIGN k — copy accu into slot k. In the IR, this is an
     Assign that updates the slot's Var so any active exception
     handler sees the new value. *)
  else if op = Bytecode.Op.assign
  then (
    let k = args.(0) in
    let slot = nth_stack state k in
    let dst = var_of slot in
    let src = var_of state.accu in
    emit state (Assign (dst, src));
    (* accu becomes unit (OCaml interp sets it to Val_unit). *)
    const_int state 0;
    None)
  (* GETMETHOD / GETPUBMET / GETDYNMET — OO method dispatch. Modelled
     as opaque externs; JVM generator resolves method-table reads
     later. *)
  else if op = Bytecode.Op.getmethod
  then (
    (* OCaml interp: accu = Lookup(sp[0], accu); stack unchanged. *)
    let a = var_of state.accu in
    let obj = var_of (nth_stack state 0) in
    set_accu_let state (Prim (Extern "getmethod", [ Pv a; Pv obj ]));
    None)
  else if op = Bytecode.Op.getpubmet
  then (
    (* GETPUBMET tag cache — pushes accu, then looks up method. *)
    push_elt state state.accu;
    let a = var_of state.accu in
    set_accu_let
      state
      (Prim (Extern "getpubmet", [ Pv a; Pc (Int args.(0)) ]));
    None)
  else if op = Bytecode.Op.getdynmet
  then (
    let a = var_of state.accu in
    let obj = nth_stack state 0 in
    let obj_v = var_of obj in
    set_accu_let state (Prim (Extern "getdynmet", [ Pv a; Pv obj_v ]));
    None)
  (* GRAB / RESTART / CHECK_SIGNALS / EVENT / BREAK — no-ops at the
     IR level. GRAB is used for curried closure partial-application
     runtime check; we handle partial application via Apply's exact
     flag and the runtime PartialClosure class. RESTART is the entry
     back-edge for that; also a no-op for us. *)
  else if op = Bytecode.Op.grab
       || op = Bytecode.Op.restart
       || op = 92 (* CHECK_SIGNALS *)
       || op = Bytecode.Op.event
       || op = Bytecode.Op.break
  then None
  else if op = Bytecode.Op.vectlength
  then (unop state Vectlength; None)
  else if op = Bytecode.Op.getvectitem
  then (binop state Array_get; None)
  else if op = Bytecode.Op.setvectitem
  then (
    let a = var_of state.accu in
    let i = pop_var state in
    let v = pop_var state in
    emit state (Array_set (a, i, v));
    state.accu <- V a;
    None)
  (* GETFIELD *)
  else if op = Bytecode.Op.getfield0
  then (let a = var_of state.accu in set_accu_let state (Field (a, 0)); None)
  else if op = Bytecode.Op.getfield1
  then (let a = var_of state.accu in set_accu_let state (Field (a, 1)); None)
  else if op = Bytecode.Op.getfield2
  then (let a = var_of state.accu in set_accu_let state (Field (a, 2)); None)
  else if op = Bytecode.Op.getfield3
  then (let a = var_of state.accu in set_accu_let state (Field (a, 3)); None)
  else if op = Bytecode.Op.getfield
  then (
    let a = var_of state.accu in
    set_accu_let state (Field (a, args.(0)));
    None)
  else if op = Bytecode.Op.setfield0
  then (
    let a = var_of state.accu in
    let v = pop_var state in
    emit state (Set_field (a, 0, v));
    None)
  else if op = Bytecode.Op.setfield1
  then (
    let a = var_of state.accu in
    let v = pop_var state in
    emit state (Set_field (a, 1, v));
    None)
  else if op = Bytecode.Op.setfield2
  then (
    let a = var_of state.accu in
    let v = pop_var state in
    emit state (Set_field (a, 2, v));
    None)
  else if op = Bytecode.Op.setfield3
  then (
    let a = var_of state.accu in
    let v = pop_var state in
    emit state (Set_field (a, 3, v));
    None)
  else if op = Bytecode.Op.setfield
  then (
    let a = var_of state.accu in
    let v = pop_var state in
    emit state (Set_field (a, args.(0), v));
    None)
  else if op = Bytecode.Op.makeblock1
  then (
    let f0 = var_of state.accu in
    set_accu_let state (Block (args.(0), [| f0 |]));
    None)
  else if op = Bytecode.Op.makeblock2
  then (
    let f0 = var_of state.accu in
    let f1 = pop_var state in
    set_accu_let state (Block (args.(0), [| f0; f1 |]));
    None)
  else if op = Bytecode.Op.makeblock3
  then (
    let f0 = var_of state.accu in
    let f1 = pop_var state in
    let f2 = pop_var state in
    set_accu_let state (Block (args.(0), [| f0; f1; f2 |]));
    None)
  else if op = Bytecode.Op.makeblock
  then (
    let n = args.(0) in
    let tag = args.(1) in
    let fields = Array.make n (Var.fresh ()) in
    fields.(0) <- var_of state.accu;
    for i = 1 to n - 1 do
      fields.(i) <- pop_var state
    done;
    set_accu_let state (Block (tag, fields));
    None)
  (* GETGLOBAL / GETGLOBALFIELD — treated as opaque externs that take a
     numeric argument. The JVM generator resolves these via the globals
     table. *)
  else if op = Bytecode.Op.getglobal
  then (
    set_accu_let
      state
      (Prim (Extern "get_global", [ Pc (Int args.(0)) ]));
    None)
  else if op = Bytecode.Op.pushgetglobal
  then (
    push_elt state state.accu;
    set_accu_let
      state
      (Prim (Extern "get_global", [ Pc (Int args.(0)) ]));
    None)
  else if op = Bytecode.Op.getglobalfield
  then (
    set_accu_let
      state
      (Prim
         ( Extern "get_global_field"
         , [ Pc (Int args.(0)); Pc (Int args.(1)) ] ));
    None)
  else if op = Bytecode.Op.pushgetglobalfield
  then (
    push_elt state state.accu;
    set_accu_let
      state
      (Prim
         ( Extern "get_global_field"
         , [ Pc (Int args.(0)); Pc (Int args.(1)) ] ));
    None)
  else if op = Bytecode.Op.setglobal
  then (
    let a = var_of state.accu in
    emit
      state
      (Let
         ( Var.fresh ()
         , Prim (Extern "set_global", [ Pc (Int args.(0)); Pv a ]) ));
    (* acc becomes unit (Int 0) after SETGLOBAL *)
    const_int state 0;
    None)
  (* APPLY family *)
  else if op = Bytecode.Op.apply1
  then (
    let f = var_of state.accu in
    let a = pop_var state in
    set_accu_let state (Apply { f; args = [ a ]; exact = false });
    None)
  else if op = Bytecode.Op.apply2
  then (
    let f = var_of state.accu in
    let a0 = pop_var state in
    let a1 = pop_var state in
    set_accu_let state (Apply { f; args = [ a0; a1 ]; exact = false });
    None)
  else if op = Bytecode.Op.apply3
  then (
    let f = var_of state.accu in
    let a0 = pop_var state in
    let a1 = pop_var state in
    let a2 = pop_var state in
    set_accu_let state (Apply { f; args = [ a0; a1; a2 ]; exact = false });
    None)
  else if op = Bytecode.Op.apply
  then (
    let f = var_of state.accu in
    let n = args.(0) in
    let call_args = take_args state n in
    set_accu_let state (Apply { f; args = call_args; exact = false });
    (* Pop the 3 PUSH_RETADDR dummies. *)
    for _ = 1 to 3 do
      match pop state with
      | Dummy -> ()
      | V _ ->
        raise (Not_supported "APPLY: expected Dummy retaddr slots")
    done;
    None)
  (* Terminators *)
  else if op = Bytecode.Op.return
  then Some (Return (var_of state.accu))
  else if op = Bytecode.Op.stop
  then Some Stop
  else if op = Bytecode.Op.raise_
          || op = Bytecode.Op.reraise
          || op = Bytecode.Op.raise_notrace
  then Some (Raise (var_of state.accu))
  else if op = Bytecode.Op.branch
  then Some (Branch (make_cont state (ins.pc + args.(0) + 1)))
  else if op = Bytecode.Op.branchif
  then (
    let v = var_of state.accu in
    let then_pc = ins.pc + args.(0) + 1 in
    let else_pc = ins.pc + 2 in
    Some (Cond (v, make_cont state then_pc, make_cont state else_pc)))
  else if op = Bytecode.Op.branchifnot
  then (
    let v = var_of state.accu in
    let else_pc = ins.pc + args.(0) + 1 in
    let then_pc = ins.pc + 2 in
    Some (Cond (v, make_cont state then_pc, make_cont state else_pc)))
  else if Instr.is_cmp_jump op
  then (
    let a = var_of state.accu in
    let cmp =
      if op = 131 then Eq
      else if op = 132 then Neq
      else if op = 133 then Lt
      else if op = 134 then Le
      else if op = 135 then Gt
      else Ge
    in
    let c = Var.fresh () in
    emit state (Let (c, Constant (Int args.(0))));
    let r = Var.fresh () in
    emit state (Let (r, Prim (cmp, [ Pv a; Pv c ])));
    let then_pc = ins.pc + args.(1) + 2 in
    let else_pc = ins.pc + 3 in
    Some (Cond (r, make_cont state then_pc, make_cont state else_pc)))
  (* APPTERM / APPTERM1..3 — tail calls collapse to Apply + Return. *)
  else if op = Bytecode.Op.appterm1
  then (
    let f = var_of state.accu in
    let a = pop_var state in
    let r = Var.fresh () in
    emit state (Let (r, Apply { f; args = [ a ]; exact = false }));
    Some (Return r))
  else if op = Bytecode.Op.appterm2
  then (
    let f = var_of state.accu in
    let a0 = pop_var state in
    let a1 = pop_var state in
    let r = Var.fresh () in
    emit state (Let (r, Apply { f; args = [ a0; a1 ]; exact = false }));
    Some (Return r))
  else if op = Bytecode.Op.appterm3
  then (
    let f = var_of state.accu in
    let a0 = pop_var state in
    let a1 = pop_var state in
    let a2 = pop_var state in
    let r = Var.fresh () in
    emit state (Let (r, Apply { f; args = [ a0; a1; a2 ]; exact = false }));
    Some (Return r))
  else if op = Bytecode.Op.appterm
  then (
    let n = args.(0) in
    let f = var_of state.accu in
    let call_args = take_args state n in
    let r = Var.fresh () in
    emit state (Let (r, Apply { f; args = call_args; exact = false }));
    Some (Return r))
  (* Remaining opcodes not yet supported by the IR path. Raising lets
     the forward-walk fallback pick up the slack; callers should catch
     and skip to the legacy emitter. *)
  else
    raise
      (Not_supported
         (Printf.sprintf
            "opcode %d (%s)"
            op
            (Bytecode.opcode_name op)))

(* ------------------------------------------------------------------
   Top-level drivers
   ------------------------------------------------------------------ *)

let build_addr_map instrs =
  let m = ref IntMap.empty in
  List.iter (fun (ins : Instr.instr) -> m := IntMap.add ins.pc ins !m) instrs;
  !m

(* Process one block: consume instructions until we hit the next block
   boundary or a terminator. Returns the constructed [block].

   If any predecessor has already registered canonical params for
   [start_pc] via [make_cont], we inherit them. Otherwise (entry block
   or one reached purely by fall-through that we haven't observed
   yet), use the state's current accu+stack length to allocate a
   fresh param list. *)
let process_block state start_pc next_starts addr_map =
  let params =
    match Hashtbl.find_opt state.target_params start_pc with
    | Some ps -> ps
    | None ->
      let accu_v = Var.fresh () in
      let stack_vs = List.map (fun _ -> Var.fresh ()) state.stack in
      let ps = accu_v :: stack_vs in
      Hashtbl.add state.target_params start_pc ps;
      ps
  in
  let accu_v, stack_vs =
    match params with
    | a :: s -> a, s
    | [] -> raise (Not_supported "block has no params")
  in
  state.accu <- V accu_v;
  state.stack <- List.map (fun v -> V v) stack_vs;
  state.body <- [];
  state.current_block_start <- start_pc;
  trace "block pc=%d params=%d" start_pc (List.length params);
  let rec walk pc =
    state.current_pc <- pc;
    if IntSet.mem pc next_starts && pc <> start_pc
    then (
      let cont = make_cont state pc in
      Branch cont)
    else
      match IntMap.find_opt pc addr_map with
      | None ->
        raise
          (Not_supported (Printf.sprintf "PC %d has no decoded instr" pc))
      | Some ins ->
        trace
          "  pc=%d op=%s args=[%s] depth_before=%d"
          pc
          (Bytecode.opcode_name ins.Instr.opcode)
          (String.concat ";"
             (Array.to_list (Array.map string_of_int ins.Instr.args)))
          (List.length state.stack);
        (match step state ins with
         | Some last -> last
         | None ->
           (* Find next PC (pc of the next instruction in the array). *)
           let next_pc =
             (* Use addr_map ordered keys. *)
             let rec find p =
               let p' = p + 1 in
               if IntMap.mem p' addr_map
               then p'
               else if p' > pc + 256
               then raise (Not_supported "can't find successor pc")
               else find p'
             in
             find ins.pc
           in
           walk next_pc)
  in
  let br = walk start_pc in
  { params; body = List.rev state.body; branch = br }

let parse_generic_with_stack instrs ~start_pc ~end_pc ~initial_stack ~env =
  let starts = block_starts instrs ~start_pc ~end_pc in
  let addr_map = build_addr_map instrs in
  let start_accu = Var.fresh () in
  let state =
    { accu = V start_accu
    ; stack = List.map (fun v -> V v) initial_stack
    ; body = []
    ; target_params = Hashtbl.create 32
    ; env
    ; current_pc = start_pc
    ; current_block_start = start_pc
    }
  in
  (* Pre-register the entry block's params so [process_block] reuses
     the caller-provided [initial_stack] Vars instead of minting
     fresh ones that nobody's bound to JVM locals 1..N. *)
  Hashtbl.add
    state.target_params
    start_pc
    (start_accu :: initial_stack);
  (* DFS from [start_pc] so every block's canonical params are
     registered by a predecessor's [make_cont] before we process the
     block itself. Blocks unreachable from [start_pc] (usually none,
     but handler blocks from PUSHTRAP land here too — Pushtrap is the
     terminator, so [make_cont] covers them) are still processed via
     the outer fallback loop afterwards. *)
  let blocks = ref Addr.Map.empty in
  let visited = Hashtbl.create 32 in
  (* [starts_ref] is mutable so DFS can dynamically promote any cont
     target it reaches that wasn't in the initial [block_starts] scan
     to a proper block boundary. This papers over edge cases where
     the static scan missed a target (e.g., a branch to an address
     that happens to equal end_pc, a POPTRAP next-pc that doesn't
     line up with [i+1 < len], etc.). *)
  let starts_ref = ref starts in
  let rec visit pc =
    if Hashtbl.mem visited pc
    then ()
    else if not (IntSet.mem pc !starts_ref)
    then (
      if IntMap.mem pc addr_map
      then (
        starts_ref := IntSet.add pc !starts_ref;
        visit pc))
    else (
      Hashtbl.add visited pc ();
      let blk = process_block state pc !starts_ref addr_map in
      blocks := Addr.Map.add pc blk !blocks;
      let step_cont (addr, _args) = visit addr in
      match blk.branch with
      | Return _ | Raise _ | Stop -> ()
      | Branch c | Poptrap c -> step_cont c
      | Cond (_, c1, c2) -> step_cont c1; step_cont c2
      | Switch (_, arr) -> Array.iter step_cont arr
      | Pushtrap (b, _, h) -> step_cont b; step_cont h)
  in
  visit start_pc;
  let starts = !starts_ref in
  (* Any blocks not reached by DFS — unlikely in well-formed bytecode
     but guard against orphans. *)
  IntSet.iter
    (fun pc ->
      if not (Hashtbl.mem visited pc)
      then (
        Hashtbl.add visited pc ();
        try
          let blk = process_block state pc starts addr_map in
          blocks := Addr.Map.add pc blk !blocks
        with Not_supported _ -> ()))
    starts;
  { start = start_pc; blocks = !blocks; free_pc = end_pc }

let parse_function instrs ~start_pc ~end_pc ~nargs ~ncaps =
  Var.reset ();
  let arg_vars = List.init nargs (fun _ -> Var.fresh ()) in
  let cap_vars = List.init ncaps (fun _ -> Var.fresh ()) in
  let params = arg_vars @ cap_vars in
  (* OCaml enters a function body with args on the stack: arg[0] at
     top (stack[0] = arg[0] → ACC0 reads arg[0]), arg[nargs-1] at
     bottom. [arg_vars] is in declaration order ([v0; v1; ...]);
     [state.stack]'s head is the top of the stack, so feed arg_vars
     through as-is — no reverse. *)
  let env_var = Var.fresh () in
  let _ = cap_vars in
  let prog =
    let initial_stack = arg_vars in
    parse_generic_with_stack
      instrs
      ~start_pc
      ~end_pc
      ~initial_stack
      ~env:(Some env_var)
  in
  (prog, params, env_var)

let parse_main instrs ~start_pc ~end_pc =
  Var.reset ();
  parse_generic_with_stack
    instrs
    ~start_pc
    ~end_pc
    ~initial_stack:[]
    ~env:None
