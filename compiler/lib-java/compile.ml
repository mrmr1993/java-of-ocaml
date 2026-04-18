(* Supported primitives. Each maps to a [println] JVM dispatch + an expected
   argument type. *)
type arg_kind = Int | String

let primitives : (string * arg_kind) list =
  [ "caml_java_print_endline", String
  ; "caml_java_print_int", Int
  ]

(* -------------------------------------------------------------------------- *)
(* Bytecode decoding into a flat instruction list. *)

type instr =
  { pc : int [@warning "-69"]
  ; opcode : int
  ; args : int array
  }

let decode_all bc =
  let n = Array.length bc.Bytecode.code in
  let rec loop pc acc =
    if pc >= n
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
(* Primitive-call discovery. *)

type supported_call =
  { call_instr_idx : int (* position in the [instrs] list *)
  ; primitive : string [@warning "-69"]
  ; kind : arg_kind
  }

let find_supported_prims bc : (int, string * arg_kind) Hashtbl.t =
  let table = Hashtbl.create 4 in
  List.iter
    (fun (name, kind) ->
      match Bytecode.prim_index bc name with
      | Some idx -> Hashtbl.add table idx (name, kind)
      | None -> ())
    primitives;
  table

let find_supported_calls ~prim_table instrs =
  let arr = Array.of_list instrs in
  let out = ref [] in
  Array.iteri
    (fun i instr ->
      if instr.opcode = Bytecode.Op.c_call1
      then
        match Hashtbl.find_opt prim_table instr.args.(0) with
        | Some (name, kind) ->
          out
          := { call_instr_idx = i; primitive = name; kind } :: !out
        | None -> ())
    arr;
  arr, List.rev !out

(* -------------------------------------------------------------------------- *)
(* Argument-expression extraction.

   Starting from a primitive-call position in the instruction array, walk
   backward collecting contiguous "arg producers" — the small set of opcodes
   that show up in the kinds of argument expressions this compiler understands.
   Anything else terminates the walk. *)

type arg_op =
  | A_int_const of int
  | A_offsetint of int
  | A_addint
  | A_subint
  | A_mulint
  | A_push
  | A_string of string (* from GETGLOBAL/PUSHGETGLOBAL of a string global *)
  | A_string_push of string (* PUSHGETGLOBAL of a string: save acc then load *)
  | A_int_push of int (* PUSHCONST0-3/PUSHCONSTINT: save acc then load int *)

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

let classify_arg_op bc instr : arg_op option =
  let op = instr.opcode in
  if op = Bytecode.Op.const0 then Some (A_int_const 0)
  else if op = Bytecode.Op.const1 then Some (A_int_const 1)
  else if op = Bytecode.Op.const2 then Some (A_int_const 2)
  else if op = Bytecode.Op.const3 then Some (A_int_const 3)
  else if op = Bytecode.Op.constint then Some (A_int_const instr.args.(0))
  else if op = Bytecode.Op.pushconst0 then Some (A_int_push 0)
  else if op = Bytecode.Op.pushconst1 then Some (A_int_push 1)
  else if op = Bytecode.Op.pushconst2 then Some (A_int_push 2)
  else if op = Bytecode.Op.pushconst3 then Some (A_int_push 3)
  else if op = Bytecode.Op.pushconstint
  then Some (A_int_push instr.args.(0))
  else if op = Bytecode.Op.offsetint then Some (A_offsetint instr.args.(0))
  else if op = Bytecode.Op.addint then Some A_addint
  else if op = Bytecode.Op.subint then Some A_subint
  else if op = Bytecode.Op.mulint then Some A_mulint
  else if op = Bytecode.Op.push then Some A_push
  else if op = Bytecode.Op.getglobal
  then
    match string_of_global bc.Bytecode.globals instr.args.(0) with
    | Some s -> Some (A_string s)
    | None -> None
  else if op = Bytecode.Op.pushgetglobal
  then
    match string_of_global bc.Bytecode.globals instr.args.(0) with
    | Some s -> Some (A_string_push s)
    | None -> None
  else None

let is_c_call op =
  op >= Bytecode.Op.c_call1 && op <= 98 (* C_CALL1..C_CALLN *)

(* Walk backward from [call_idx - 1] collecting arg-producer ops. Stops
   when the instruction at [i] fails to classify. Also stops when [i] is a
   PUSH whose predecessor is a C_CALL — that's a "save PUSH" which belongs
   to the previous statement, not to the current call's argument expression.
   Returns ops in program order. *)
let collect_arg_ops bc instrs call_idx =
  let rec loop i acc =
    if i < 0
    then acc
    else
      let instr = instrs.(i) in
      if instr.opcode = Bytecode.Op.push
         && i >= 1
         && is_c_call instrs.(i - 1).opcode
      then acc
      else
        match classify_arg_op bc instr with
        | Some op -> loop (i - 1) (op :: acc)
        | None -> acc
  in
  loop (call_idx - 1) []

(* -------------------------------------------------------------------------- *)
(* JVM emission for arg expressions.

   Invariant during arg-expr emission: the OCaml "accumulator" sits at the
   top of the JVM operand stack, with any OCaml-stack values beneath it
   (matching the OCaml bytecode state exactly) and below all of those, the
   [System.out] receiver we pre-pushed. We track whether the top-of-stack
   currently represents a live OCaml accumulator so that overwriting ops
   like CONST know whether to pop the previous value first. *)

type emit_state = { mutable acc_live : bool }

let emit_arg_op state code (op : arg_op) =
  match op with
  | A_int_const n ->
    (* CONSTi / CONSTINT overwrites acc. Pop previous acc first if present. *)
    if state.acc_live then Jvm.Code.pop_top code;
    Jvm.Code.ldc_int code n;
    state.acc_live <- true
  | A_int_push n ->
    (* PUSH acc then load int. OCaml effect: stack := stack++[acc]; acc := n.
       At JVM level, with acc already on top, we want to end with [stack,
       acc, n]. That's just [ldc n] — the existing acc becomes a saved
       stack entry and n is the new top/acc. [acc_live] stays true. *)
    Jvm.Code.ldc_int code n;
    state.acc_live <- true
  | A_offsetint n ->
    Jvm.Code.ldc_int code n;
    Jvm.Code.iadd code
  | A_addint -> Jvm.Code.iadd code
  | A_subint -> Jvm.Code.isub code
  | A_mulint -> Jvm.Code.imul code
  | A_push ->
    (* OCaml PUSH saves acc on its stack; acc itself remains. On JVM, dup
       the top: the duplicate represents the saved stack entry beneath the
       live acc. *)
    Jvm.Code.dup code
  | A_string s ->
    if state.acc_live then Jvm.Code.pop_top code;
    Jvm.Code.ldc_string code s;
    state.acc_live <- true
  | A_string_push s ->
    Jvm.Code.ldc_string code s;
    state.acc_live <- true

let descriptor_for_kind = function
  | Int -> "(I)V"
  | String -> "(Ljava/lang/String;)V"

let emit_call code ~arg_ops ~kind =
  (* Push System.out first, then the argument expression on top. That's
     exactly the operand-stack layout [..., receiver, arg] that
     invokevirtual expects. *)
  Jvm.Code.getstatic
    code
    ~class_:"java/lang/System"
    ~field:"out"
    ~descriptor:"Ljava/io/PrintStream;";
  let state = { acc_live = false } in
  List.iter (emit_arg_op state code) arg_ops;
  Jvm.Code.invokevirtual
    code
    ~class_:"java/io/PrintStream"
    ~method_:"println"
    ~descriptor:(descriptor_for_kind kind)

(* -------------------------------------------------------------------------- *)
(* Driver. *)

let compile ~bc ~out_dir =
  let parsed = Bytecode.read_exe bc in
  let prim_table = find_supported_prims parsed in
  if Hashtbl.length prim_table = 0
  then
    failwith
      "java_of_ocaml: bytecode references none of the supported primitives \
       (caml_java_print_endline, caml_java_print_int). Phase 1 only knows \
       how to compile programs built around these primitives.";
  let instrs = decode_all parsed in
  let arr, calls = find_supported_calls ~prim_table instrs in
  if calls = []
  then
    failwith
      "java_of_ocaml: no supported primitive calls found in the bytecode";
  let class_bytes =
    Jvm.assemble_main_class (fun _cp code ->
      List.iter
        (fun call ->
          let arg_ops = collect_arg_ops parsed arr call.call_instr_idx in
          emit_call code ~arg_ops ~kind:call.kind)
        calls;
      Jvm.Code.return_void code)
  in
  let out_path = Filename.concat out_dir "Main.class" in
  let oc = open_out_bin out_path in
  output_string oc class_bytes;
  close_out oc
