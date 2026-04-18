(* -------------------------------------------------------------------------- *)
(* Supported primitives. *)

type arg_kind = Int | String

let primitives : (string * arg_kind) list =
  [ "caml_java_print_endline", String
  ; "caml_java_print_int", Int
  ]

(* -------------------------------------------------------------------------- *)
(* Bytecode decoding into a flat instruction list. *)

type instr =
  { pc : int
  ; opcode : int
  ; args : int array
  }

let decode_all bc =
  let n = Array.length bc.Bytecode.code in
  let rec loop pc acc =
    if pc = n
    then List.rev acc
    else if pc > n
    then
      failwith
        (Printf.sprintf
           "java_of_ocaml: walked past end of code section at pc %d (len %d)"
           pc
           n)
    else
      let size = Bytecode.instr_size bc pc in
      let args =
        Array.init (max 0 (size - 1)) (fun i ->
          bc.Bytecode.code.(pc + 1 + i))
      in
      let instr = { pc; opcode = bc.Bytecode.code.(pc); args } in
      loop (pc + size) (instr :: acc)
  in
  loop 0 []

(* -------------------------------------------------------------------------- *)
(* "User-code" range detection.

   The compiled bytecode contains a large preamble (Stdlib init) that we
   don't translate. We identify the user module by walking outward from the
   first supported primitive call, including only op-classes that appear in
   our user code (value producers, comparisons, branches, C_CALLs) and
   stopping at anything else (SETGLOBAL, STOP, MAKEBLOCK, APPLY, CLOSURE,
   etc.). This is a heuristic, but it's robust for the straight-line +
   if/else programs we currently handle. *)

let is_cmp_jump op =
  op = 131 (* BEQ *) || op = 132 (* BNEQ *) || op = 133 (* BLTINT *)
  || op = 134 (* BLEINT *) || op = 135 (* BGTINT *) || op = 136 (* BGEINT *)

let is_c_call op = op >= 93 && op <= 98

let is_user_op (ins : instr) =
  let op = ins.opcode in
  op = Bytecode.Op.push
  || op = Bytecode.Op.const0
  || op = Bytecode.Op.const1
  || op = Bytecode.Op.const2
  || op = Bytecode.Op.const3
  || op = Bytecode.Op.constint
  || op = Bytecode.Op.pushconst0
  || op = Bytecode.Op.pushconst1
  || op = Bytecode.Op.pushconst2
  || op = Bytecode.Op.pushconst3
  || op = Bytecode.Op.pushconstint
  || op = Bytecode.Op.offsetint
  || op = Bytecode.Op.addint
  || op = Bytecode.Op.subint
  || op = Bytecode.Op.mulint
  || op = Bytecode.Op.getglobal
  || op = Bytecode.Op.pushgetglobal
  || op = 84 (* BRANCH *)
  || op = 85 (* BRANCHIF *)
  || op = 86 (* BRANCHIFNOT *)
  || is_cmp_jump op
  || is_c_call op

(* -------------------------------------------------------------------------- *)
(* Globals. *)

let string_of_global (globals : Obj.t array) n =
  if n < 0 || n >= Array.length globals
  then
    failwith
      (Printf.sprintf "java_of_ocaml: global index %d out of bounds" n);
  let v = globals.(n) in
  if not (Obj.is_block v)
  then None
  else if Obj.tag v <> Obj.string_tag
  then None
  else Some (Obj.magic v : string)

(* -------------------------------------------------------------------------- *)
(* Branch target arithmetic.

   OCaml bytecode branch offsets are relative to the instruction position,
   plus a fixed constant depending on the opcode kind (number of arg slots
   past the opcode). See js_of_ocaml's parse_bytecode.ml:
     KJump / KCond_jump: target = pc + offset + 1
     KCmp_jump          : target = pc + offset + 2
*)

let branch_target (ins : instr) =
  let op = ins.opcode in
  if op = 84 || op = 85 || op = 86
  then Some (ins.pc + ins.args.(0) + 1)
  else if is_cmp_jump op
  then Some (ins.pc + ins.args.(1) + 2)
  else None

(* -------------------------------------------------------------------------- *)
(* Forward emitter. *)

type state =
  { code : Jvm.Code.t
  ; globals : Obj.t array
  ; supported_prims : (int, string * arg_kind) Hashtbl.t
  ; pc_to_label : (int, Jvm.Code.label) Hashtbl.t
      (* OCaml PC -> JVM label, populated ahead of time for every branch
         target that lies within the user range. *)
  ; mutable acc_live : bool
      (* Does the top of the JVM operand stack currently represent OCaml's
         accumulator? Toggled by ops that produce/consume values. *)
  }

let find_supported_prims bc =
  let table = Hashtbl.create 4 in
  List.iter
    (fun (name, kind) ->
      match Bytecode.prim_index bc name with
      | Some idx -> Hashtbl.add table idx (name, kind)
      | None -> ())
    primitives;
  table

let label_at state pc =
  Hashtbl.find state.pc_to_label pc

let emit_overwrite_value state emit =
  if state.acc_live then Jvm.Code.pop_top state.code;
  emit ();
  state.acc_live <- true

let emit_int_const state n =
  emit_overwrite_value state (fun () -> Jvm.Code.ldc_int state.code n)

let emit_string_const state s =
  emit_overwrite_value state (fun () -> Jvm.Code.ldc_string state.code s)

let emit_int_push state n =
  (* OCaml PUSHCONST-style fused op: with acc already live, loading the new
     value just pushes on top while the old acc slides down to become a
     saved OCaml-stack entry. *)
  Jvm.Code.ldc_int state.code n;
  state.acc_live <- true

let emit_string_push state s =
  Jvm.Code.ldc_string state.code s;
  state.acc_live <- true

let emit_c_call state ~kind =
  (* Stack enters with [..., arg] (acc on top). Push System.out above,
     swap so it becomes the receiver below the arg, invoke. Stack exits
     with [...] (void return). *)
  Jvm.Code.getstatic
    state.code
    ~class_:"java/lang/System"
    ~field:"out"
    ~descriptor:"Ljava/io/PrintStream;";
  Jvm.Code.swap state.code;
  let desc =
    match kind with
    | Int -> "(I)V"
    | String -> "(Ljava/lang/String;)V"
  in
  Jvm.Code.invokevirtual
    state.code
    ~class_:"java/io/PrintStream"
    ~method_:"println"
    ~descriptor:desc;
  state.acc_live <- false

(* Emit a fused Cmp_jump + target: the OCaml [Bxxx imm offset] opcodes pop
   the pushed value from the OCaml stack and compare it with the immediate
   inline. In JVM terms, we already have the compared value on the operand
   stack as [..., stack_val, acc]; we push the immediate and use if_icmp
   with the corresponding predicate. *)
let emit_cmp_jump state (ins : instr) =
  let imm = ins.args.(0) in
  let target_pc = ins.pc + ins.args.(1) + 2 in
  let lbl = label_at state target_pc in
  Jvm.Code.ldc_int state.code imm;
  (* Now stack top is imm, below is acc. JVM's if_icmp<cond> compares
     value1 (below = acc) <cond> value2 (top = imm). *)
  (match ins.opcode with
   | 131 (* BEQ    imm==acc -> acc==imm *)         -> Jvm.Code.if_icmpeq state.code lbl
   | 132 (* BNEQ   imm!=acc -> acc!=imm *)         -> Jvm.Code.if_icmpne state.code lbl
   | 133 (* BLTINT imm<acc  -> acc>imm *)          -> Jvm.Code.if_icmpgt state.code lbl
   | 134 (* BLEINT imm<=acc -> acc>=imm *)         -> Jvm.Code.if_icmpge state.code lbl
   | 135 (* BGTINT imm>acc  -> acc<imm *)          -> Jvm.Code.if_icmplt state.code lbl
   | 136 (* BGEINT imm>=acc -> acc<=imm *)         -> Jvm.Code.if_icmple state.code lbl
   | other ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: unexpected cmp_jump opcode %d"
          other));
  state.acc_live <- false

let emit_instr state (ins : instr) =
  (* Mark any label pinned to this PC first. Subsequent bytes are the
     target of whatever branched here. *)
  (match Hashtbl.find_opt state.pc_to_label ins.pc with
   | Some lbl -> Jvm.Code.mark_label state.code lbl
   | None -> ());
  let op = ins.opcode in
  if op = Bytecode.Op.const0 then emit_int_const state 0
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
  else if op = Bytecode.Op.offsetint
  then (
    Jvm.Code.ldc_int state.code ins.args.(0);
    Jvm.Code.iadd state.code)
  else if op = Bytecode.Op.addint then Jvm.Code.iadd state.code
  else if op = Bytecode.Op.subint then Jvm.Code.isub state.code
  else if op = Bytecode.Op.mulint then Jvm.Code.imul state.code
  else if op = Bytecode.Op.push then
    if state.acc_live
    then Jvm.Code.dup state.code
    else
      (* PUSH with no live acc is a "save PUSH" immediately after a C_CALL
         at a statement boundary. Skip it; subsequent ops will set up a
         fresh acc on top. *)
      ()
  else if op = Bytecode.Op.getglobal
  then
    match string_of_global state.globals ins.args.(0) with
    | Some s -> emit_string_const state s
    | None ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: GETGLOBAL %d at pc %d — only string globals are \
            currently supported"
           ins.args.(0)
           ins.pc)
  else if op = Bytecode.Op.pushgetglobal
  then
    match string_of_global state.globals ins.args.(0) with
    | Some s -> emit_string_push state s
    | None ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: PUSHGETGLOBAL %d at pc %d — only string globals \
            are currently supported"
           ins.args.(0)
           ins.pc)
  else if op = 84 (* BRANCH *)
  then
    let target = ins.pc + ins.args.(0) + 1 in
    Jvm.Code.goto state.code (label_at state target)
  else if op = 85 (* BRANCHIF *)
  then (
    (* Branch if acc is non-zero. Consume acc; assume the OCaml bytecode
       won't expect a live acc on either side of the branch. *)
    let target = ins.pc + ins.args.(0) + 1 in
    Jvm.Code.ldc_int state.code 0;
    Jvm.Code.if_icmpne state.code (label_at state target);
    state.acc_live <- false)
  else if op = 86 (* BRANCHIFNOT *)
  then (
    let target = ins.pc + ins.args.(0) + 1 in
    Jvm.Code.ldc_int state.code 0;
    Jvm.Code.if_icmpeq state.code (label_at state target);
    state.acc_live <- false)
  else if is_cmp_jump op then emit_cmp_jump state ins
  else if is_c_call op
  then (
    match Hashtbl.find_opt state.supported_prims ins.args.(0) with
    | Some (_name, kind) -> emit_c_call state ~kind
    | None ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: unsupported primitive call %s at pc %d"
           (if ins.args.(0) < 0 then "<?>" else "<#" ^ string_of_int ins.args.(0) ^ ">")
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

(* Find the first and last indices in [arr] of supported-primitive C_CALLs. *)
let supported_call_indices arr ~prim_table =
  let n = Array.length arr in
  let rec find_first i =
    if i >= n
    then None
    else
      let ins = arr.(i) in
      if is_c_call ins.opcode
         && Hashtbl.mem prim_table ins.args.(0)
      then Some i
      else find_first (i + 1)
  in
  let rec find_last i =
    if i < 0
    then None
    else
      let ins = arr.(i) in
      if is_c_call ins.opcode
         && Hashtbl.mem prim_table ins.args.(0)
      then Some i
      else find_last (i - 1)
  in
  match find_first 0, find_last (n - 1) with
  | Some f, Some l -> Some (f, l)
  | _ -> None

let walk_back_user_start arr start_idx =
  (* Walk backward while instructions classify as user-ops. Stop index is the
     first instruction (lowest index) still in the run. *)
  let rec loop i =
    if i < 0 then 0
    else if is_user_op arr.(i)
    then loop (i - 1)
    else i + 1
  in
  loop (start_idx - 1)

let walk_forward_user_end arr end_idx =
  let n = Array.length arr in
  let rec loop i =
    if i >= n then n - 1
    else if is_user_op arr.(i)
    then loop (i + 1)
    else i - 1
  in
  loop (end_idx + 1)

(* -------------------------------------------------------------------------- *)
(* Driver. *)

let compile ~bc ~out_dir =
  let parsed = Bytecode.read_exe bc in
  let prim_table = find_supported_prims parsed in
  if Hashtbl.length prim_table = 0
  then
    failwith
      "java_of_ocaml: bytecode references none of the supported primitives \
       (caml_java_print_endline, caml_java_print_int).";
  let instrs = decode_all parsed in
  let arr = Array.of_list instrs in
  let first_idx, last_idx =
    match supported_call_indices arr ~prim_table with
    | Some p -> p
    | None ->
      failwith "java_of_ocaml: no supported primitive calls found"
  in
  let start_idx = walk_back_user_start arr first_idx in
  let end_idx = walk_forward_user_end arr last_idx in
  let class_bytes =
    Jvm.assemble_main_class (fun _cp code ->
      (* Pre-create labels for every branch target that lands inside the
         user range (or immediately past its end, which is common for the
         merge point of an if/else). *)
      let pc_to_label = Hashtbl.create 4 in
      let post_end_pc =
        if end_idx + 1 < Array.length arr
        then arr.(end_idx + 1).pc
        else max_int
      in
      for i = start_idx to end_idx do
        match branch_target arr.(i) with
        | None -> ()
        | Some target_pc ->
          let in_range =
            target_pc >= arr.(start_idx).pc
            && target_pc <= post_end_pc
          in
          if in_range && not (Hashtbl.mem pc_to_label target_pc)
          then
            Hashtbl.add pc_to_label target_pc (Jvm.Code.fresh_label code)
      done;
      let state =
        { code
        ; globals = parsed.globals
        ; supported_prims = prim_table
        ; pc_to_label
        ; acc_live = false
        }
      in
      for i = start_idx to end_idx do
        emit_instr state arr.(i)
      done;
      (* Any label whose OCaml target sits beyond the last emitted
         instruction (typically the merge-point at the PUSH that starts the
         module's cleanup) gets pinned to the current JVM position. *)
      let pinned_here_pc = post_end_pc in
      (match Hashtbl.find_opt pc_to_label pinned_here_pc with
       | Some lbl -> Jvm.Code.mark_label code lbl
       | None -> ());
      Jvm.Code.return_void code)
  in
  let out_path = Filename.concat out_dir "Main.class" in
  let oc = open_out_bin out_path in
  output_string oc class_bytes;
  close_out oc
