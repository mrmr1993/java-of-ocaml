open Jvm_bin
module Cp = Jvm_constant_pool

(* Sum the JVM operand-stack slot widths of [args] (the descriptor's
   argument string, i.e. the content between '(' and ')'). Doubles
   and longs occupy 2 slots; everything else 1. *)
let stack_effect_of_call_descriptor descriptor ~is_virtual =
  let lp = String.index descriptor '(' in
  let rp = String.index descriptor ')' in
  let args = String.sub descriptor (lp + 1) (rp - lp - 1) in
  let rec count_args i slots =
    if i >= String.length args
    then slots
    else
      match args.[i] with
      | 'L' ->
        let semi = String.index_from args i ';' in
        count_args (semi + 1) (slots + 1)
      | '[' -> count_args (i + 1) slots
      | 'D' | 'J' -> count_args (i + 1) (slots + 2)
      | _ -> count_args (i + 1) (slots + 1)
  in
  let arg_slots = count_args 0 0 in
  let ret =
    if rp + 1 >= String.length descriptor
    then "V"
    else String.sub descriptor (rp + 1) 1
  in
  let push_ret =
    match ret with
    | "V" -> 0
    | "D" | "J" -> 2
    | _ -> 1
  in
  let pops = arg_slots + if is_virtual then 1 else 0 in
  pops - push_ret

(* [width] is the byte-width of the offset slot following the opcode.
   [opcode_pc] is where the branch opcode itself was written. [offset_base]
   is the pc the offset is relative to (for tableswitch the base is the
   opcode pc; for the ordinary branches it's also the opcode pc). *)
type ref_info =
  { opcode_pc : int
  ; offset_pc : int
  ; width : int (* 2 or 4 *)
  ; offset_base : int
  }

type label =
  { mutable target : int option
  ; mutable refs : ref_info list
  ; id : int
  }

type exception_entry =
  { start_lbl : label
  ; end_lbl : label
  ; handler_lbl : label
  ; catch_cp_idx : int
  }

type t =
  { cp : Cp.t
  ; buf : Buffer.t
  ; mutable stack : int
  ; mutable max_stack : int
  ; mutable max_locals : int
  ; mutable next_label_id : int
  ; mutable labels : label list
  ; mutable exceptions : exception_entry list
  ; mutable line_entries : (int * int) list
        (* (jvm_pc, source_line), pushed in reverse chronological
           order. See [mark_line] / [line_entries]. *)
  }

let create cp =
  { cp
  ; buf = Buffer.create 64
  ; stack = 0
  ; max_stack = 0
  ; max_locals = 1
  ; next_label_id = 0
  ; labels = []
  ; exceptions = []
  ; line_entries = []
  }

(* Record that the JVM bytecode starting at the current buffer position
   originates from [line] in the source file. Collapses redundant
   entries:
   - if the previous entry sits at the same JVM pc, overwrite it
     (the later call is more specific);
   - otherwise if it reports the same [line] already in effect, skip
     (no change to the running line).  *)
let mark_line t line =
  if line > 0 && line <= 0xffff
  then
    let pc = Buffer.length t.buf in
    match t.line_entries with
    | (prev_pc, _) :: rest when prev_pc = pc ->
      t.line_entries <- (pc, line) :: rest
    | (_, prev_line) :: _ when prev_line = line -> ()
    | _ -> t.line_entries <- (pc, line) :: t.line_entries

let line_entries t = List.rev t.line_entries

let add_exception_handler t ~start_lbl ~end_lbl ~handler_lbl ~catch_class =
  let idx =
    match catch_class with
    | None -> 0
    | Some name -> Cp.class_ t.cp name
  in
  t.exceptions <-
    { start_lbl; end_lbl; handler_lbl; catch_cp_idx = idx } :: t.exceptions

let handler_stack_prelude t =
  t.stack <- 1;
  if t.stack > t.max_stack then t.max_stack <- t.stack

let note_local t index =
  if index + 1 > t.max_locals then t.max_locals <- index + 1

let set_min_locals t n = if n > t.max_locals then t.max_locals <- n

let label_id lbl = lbl.id

let fresh_label t =
  let lbl = { target = None; refs = []; id = t.next_label_id } in
  t.next_label_id <- t.next_label_id + 1;
  t.labels <- lbl :: t.labels;
  lbl

let mark_label _t lbl =
  (match lbl.target with
   | Some _ ->
     failwith (Printf.sprintf "jvm: label %d marked twice" lbl.id)
   | None -> ());
  lbl.target <- Some (Buffer.length _t.buf)

let push t n =
  t.stack <- t.stack + n;
  if t.stack > t.max_stack then t.max_stack <- t.stack

(* For compound opcodes whose stack-effect encoding is [pop t net]
   with [net = pops - push_ret], the intermediate (pre-push) stack
   depth is [t.stack + pops] — which is strictly larger than
   [t.stack] when [net < pops]. We mostly ignore this since the
   preceding pushes already recorded the call-site high-water
   mark, but [invoke_stack_effect] below re-asserts it explicitly
   for the invoke family where the args are often [Object]s that
   [push] registered one-at-a-time anyway. *)
let pop t n = t.stack <- t.stack - n

let ldc_string t s =
  let idx = Cp.string t.cp s in
  if idx <= 0xff
  then (
    add_u1 t.buf 0x12;
    add_u1 t.buf idx)
  else (
    add_u1 t.buf 0x13;
    add_u2 t.buf idx);
  push t 1

let ldc_int t n =
  (if n >= -1 && n <= 5
   then
     let op =
       match n with
       | -1 -> 0x02
       | 0 -> 0x03
       | 1 -> 0x04
       | 2 -> 0x05
       | 3 -> 0x06
       | 4 -> 0x07
       | 5 -> 0x08
       | _ -> assert false
     in
     add_u1 t.buf op
   else if n >= -128 && n <= 127
   then (
     add_u1 t.buf 0x10;
     add_u1 t.buf (n land 0xff))
   else if n >= -32768 && n <= 32767
   then (
     add_u1 t.buf 0x11;
     add_u2 t.buf (n land 0xffff))
   else
     let idx =
       Cp.intern t.cp (Printf.sprintf "I:%d" n) (fun buf ->
         add_u1 buf 3;
         add_u4 buf n)
     in
     if idx <= 0xff
     then (
       add_u1 t.buf 0x12;
       add_u1 t.buf idx)
     else (
       add_u1 t.buf 0x13;
       add_u2 t.buf idx));
  push t 1

let dup t =
  add_u1 t.buf 0x59;
  push t 1

let dup2 t =
  add_u1 t.buf 0x5C;
  push t 2

let pop_top t =
  add_u1 t.buf 0x57;
  pop t 1

let aconst_null t =
  add_u1 t.buf 0x01;
  push t 1

let swap t = add_u1 t.buf 0x5F

(* Locals past index 3 use the 1-byte-index form (up to 255); past 255
   use the [wide] prefix (0xC4) + 2-byte index. *)
let emit_local_op t ~short_opcode ~indexed_opcode n =
  if n >= 0 && n <= 3
  then add_u1 t.buf (short_opcode + n)
  else if n < 256
  then (
    add_u1 t.buf indexed_opcode;
    add_u1 t.buf n)
  else if n < 0x10000
  then (
    add_u1 t.buf 0xC4;
    add_u1 t.buf indexed_opcode;
    add_u2 t.buf n)
  else failwith (Printf.sprintf "jvm: local index %d exceeds 2-byte range" n)

let istore t n =
  emit_local_op t ~short_opcode:0x3B ~indexed_opcode:0x36 n;
  note_local t n;
  pop t 1

let iload t n =
  emit_local_op t ~short_opcode:0x1A ~indexed_opcode:0x15 n;
  note_local t n;
  push t 1

let astore t n =
  emit_local_op t ~short_opcode:0x4B ~indexed_opcode:0x3A n;
  note_local t n;
  pop t 1

let aload t n =
  emit_local_op t ~short_opcode:0x2A ~indexed_opcode:0x19 n;
  note_local t n;
  push t 1

(* Doubles occupy 2 JVM local slots (N and N+1) and 2 operand-stack
   slots. All the [d*] helpers reflect that in their push/pop
   accounting and reserve the second local slot via [note_local]. *)
let dstore t n =
  emit_local_op t ~short_opcode:0x47 ~indexed_opcode:0x39 n;
  note_local t (n + 1);
  pop t 2

let dload t n =
  emit_local_op t ~short_opcode:0x26 ~indexed_opcode:0x18 n;
  note_local t (n + 1);
  push t 2

let ldc_double t d =
  let idx = Cp.double t.cp d in
  add_u1 t.buf 0x14;
  add_u2 t.buf idx;
  push t 2

let ldc_long t n =
  let idx = Cp.long t.cp n in
  add_u1 t.buf 0x14;
  add_u2 t.buf idx;
  push t 2

let pop2 t =
  add_u1 t.buf 0x58;
  pop t 2

let newarray_int t =
  add_u1 t.buf 0xBC;
  add_u1 t.buf 10

let iaload t =
  add_u1 t.buf 0x2E;
  pop t 1

let iastore t =
  add_u1 t.buf 0x4F;
  pop t 3

let arraylength t = add_u1 t.buf 0xBE

let anewarray t class_name =
  let idx = Cp.class_ t.cp class_name in
  add_u1 t.buf 0xBD;
  add_u2 t.buf idx

let aaload t =
  add_u1 t.buf 0x32;
  pop t 1

let aastore t =
  add_u1 t.buf 0x53;
  pop t 3

let checkcast t class_name =
  let idx = Cp.class_ t.cp class_name in
  add_u1 t.buf 0xC0;
  add_u2 t.buf idx

let new_ t class_name =
  let idx = Cp.class_ t.cp class_name in
  add_u1 t.buf 0xBB;
  add_u2 t.buf idx;
  push t 1

let invokespecial t ~class_ ~method_ ~descriptor =
  let idx = Cp.methodref t.cp ~class_ ~method_ ~descriptor in
  add_u1 t.buf 0xB7;
  add_u2 t.buf idx;
  let net = stack_effect_of_call_descriptor descriptor ~is_virtual:true in
  if net >= 0 then pop t net else push t (-net)

let getfield t ~class_ ~field ~descriptor =
  let idx = Cp.fieldref t.cp ~class_ ~field ~descriptor in
  add_u1 t.buf 0xB4;
  add_u2 t.buf idx;
  ignore t

let putfield t ~class_ ~field ~descriptor =
  let idx = Cp.fieldref t.cp ~class_ ~field ~descriptor in
  add_u1 t.buf 0xB5;
  add_u2 t.buf idx;
  pop t 2

let iadd t =
  add_u1 t.buf 0x60;
  pop t 1

let isub t =
  add_u1 t.buf 0x64;
  pop t 1

let imul t =
  add_u1 t.buf 0x68;
  pop t 1

let idiv t =
  add_u1 t.buf 0x6C;
  pop t 1

let irem t =
  add_u1 t.buf 0x70;
  pop t 1

let ineg t = add_u1 t.buf 0x74

let ishl t =
  add_u1 t.buf 0x78;
  pop t 1

let ishr t =
  add_u1 t.buf 0x7A;
  pop t 1

let iushr t =
  add_u1 t.buf 0x7C;
  pop t 1

let iand t =
  add_u1 t.buf 0x7E;
  pop t 1

let ior t =
  add_u1 t.buf 0x80;
  pop t 1

let ixor t =
  add_u1 t.buf 0x82;
  pop t 1

(* Double arithmetic. Each [d*] binary op pops two doubles (4 slots)
   and pushes one (2 slots), net -2. Unary [dneg] is stack-neutral. *)
let dadd t =
  add_u1 t.buf 0x63;
  pop t 2

let dsub t =
  add_u1 t.buf 0x67;
  pop t 2

let dmul t =
  add_u1 t.buf 0x6B;
  pop t 2

let ddiv t =
  add_u1 t.buf 0x6F;
  pop t 2

let dneg t = add_u1 t.buf 0x77

let dcmpl t =
  add_u1 t.buf 0x97;
  pop t 3

let dcmpg t =
  add_u1 t.buf 0x98;
  pop t 3

let d2i t =
  add_u1 t.buf 0x8E;
  pop t 1

let i2d t =
  add_u1 t.buf 0x87;
  push t 1

(* [f2d] widens a single-precision [float] (1 slot) to [double]
   (2 slots) — value-preserving. Used by [Int32.float_of_bits]. *)
let f2d t =
  add_u1 t.buf 0x8D;
  push t 1

(* [d2f] narrows [double] (2 slots) to [float] (1 slot). Used by
   [Int32.bits_of_float]. *)
let d2f t =
  add_u1 t.buf 0x90;
  pop t 1

(* [long]-manipulation opcodes. A [long] occupies 2 JVM stack slots.
   Binary arithmetic pops 4 (two [long]s) and pushes 2 (one [long]),
   net -2. Shifts take [long] + [int] (3 slots) → [long] (2 slots).
   Unary ops are stack-neutral. Conversion ops adjust by ±1. *)
let ladd t = add_u1 t.buf 0x61; pop t 2
let lsub t = add_u1 t.buf 0x65; pop t 2
let lmul t = add_u1 t.buf 0x69; pop t 2
let ldiv t = add_u1 t.buf 0x6D; pop t 2
let lrem t = add_u1 t.buf 0x71; pop t 2
let lneg t = add_u1 t.buf 0x75
let lshl t = add_u1 t.buf 0x79; pop t 1
let lshr t = add_u1 t.buf 0x7B; pop t 1
let lushr t = add_u1 t.buf 0x7D; pop t 1
let land_ t = add_u1 t.buf 0x7F; pop t 2
let lor_ t = add_u1 t.buf 0x81; pop t 2
let lxor_ t = add_u1 t.buf 0x83; pop t 2
let lcmp t = add_u1 t.buf 0x94; pop t 3

let i2l t = add_u1 t.buf 0x85; push t 1
let l2i t = add_u1 t.buf 0x88; pop t 1
let l2d t = add_u1 t.buf 0x8A  (* 2→2, stack-neutral *)
let d2l t = add_u1 t.buf 0x8F  (* 2→2, stack-neutral *)
let lstore t n =
  if n <= 3
  then add_u1 t.buf (0x3F + n)
  else (add_u1 t.buf 0x37; add_u1 t.buf n);
  pop t 2
let lload t n =
  if n <= 3
  then add_u1 t.buf (0x1E + n)
  else (add_u1 t.buf 0x16; add_u1 t.buf n);
  push t 2

let emit_branch t lbl opcode ~stack_delta =
  let opcode_pc = Buffer.length t.buf in
  add_u1 t.buf opcode;
  let offset_pc = Buffer.length t.buf in
  add_u2 t.buf 0;
  lbl.refs <-
    { opcode_pc; offset_pc; width = 2; offset_base = opcode_pc } :: lbl.refs;
  if stack_delta >= 0 then push t stack_delta else pop t (-stack_delta)

let if_icmpeq t lbl = emit_branch t lbl 0x9F ~stack_delta:(-2)
let if_icmpne t lbl = emit_branch t lbl 0xA0 ~stack_delta:(-2)
let if_icmplt t lbl = emit_branch t lbl 0xA1 ~stack_delta:(-2)
let if_icmpge t lbl = emit_branch t lbl 0xA2 ~stack_delta:(-2)
let if_icmpgt t lbl = emit_branch t lbl 0xA3 ~stack_delta:(-2)
let if_icmple t lbl = emit_branch t lbl 0xA4 ~stack_delta:(-2)

let ifeq t lbl = emit_branch t lbl 0x99 ~stack_delta:(-1)
let ifne t lbl = emit_branch t lbl 0x9A ~stack_delta:(-1)
let iflt t lbl = emit_branch t lbl 0x9B ~stack_delta:(-1)
let ifge t lbl = emit_branch t lbl 0x9C ~stack_delta:(-1)
let ifgt t lbl = emit_branch t lbl 0x9D ~stack_delta:(-1)
let ifle t lbl = emit_branch t lbl 0x9E ~stack_delta:(-1)

let if_acmpeq t lbl = emit_branch t lbl 0xA5 ~stack_delta:(-2)
let if_acmpne t lbl = emit_branch t lbl 0xA6 ~stack_delta:(-2)

let ifnull t lbl = emit_branch t lbl 0xC6 ~stack_delta:(-1)
let ifnonnull t lbl = emit_branch t lbl 0xC7 ~stack_delta:(-1)

let goto t lbl = emit_branch t lbl 0xA7 ~stack_delta:0

(* [goto_w] — 4-byte branch-offset variant of [goto]. Required for
   branch distances beyond the signed 16-bit range. *)
let goto_w t lbl =
  let opcode_pc = Buffer.length t.buf in
  add_u1 t.buf 0xC8;
  let offset_pc = Buffer.length t.buf in
  add_u4 t.buf 0;
  lbl.refs <-
    { opcode_pc; offset_pc; width = 4; offset_base = opcode_pc } :: lbl.refs

(* [tableswitch v default low high targets] — dense jump table for an
   int selector. Opcode 0xAA followed by 0..3 bytes of alignment padding
   so the default offset starts at a 4-byte boundary, then 4-byte
   default, 4-byte low, 4-byte high, and (high-low+1) 4-byte target
   offsets. Pops the selector (1 slot). *)
let tableswitch t ~default ~low ~high targets =
  let opcode_pc = Buffer.length t.buf in
  add_u1 t.buf 0xAA;
  let pad = (4 - ((opcode_pc + 1) mod 4)) mod 4 in
  for _ = 1 to pad do
    add_u1 t.buf 0
  done;
  let default_pc = Buffer.length t.buf in
  add_u4 t.buf 0;
  default.refs <-
    { opcode_pc
    ; offset_pc = default_pc
    ; width = 4
    ; offset_base = opcode_pc
    }
    :: default.refs;
  add_u4 t.buf low;
  add_u4 t.buf high;
  Array.iter
    (fun (lbl : label) ->
      let offset_pc = Buffer.length t.buf in
      add_u4 t.buf 0;
      lbl.refs <-
        { opcode_pc
        ; offset_pc
        ; width = 4
        ; offset_base = opcode_pc
        }
        :: lbl.refs)
    targets;
  pop t 1

let instanceof_ t class_name =
  let idx = Cp.class_ t.cp class_name in
  add_u1 t.buf 0xC1;
  add_u2 t.buf idx

let athrow t =
  add_u1 t.buf 0xBF;
  t.stack <- 0

let getstatic t ~class_ ~field ~descriptor =
  let idx = Cp.fieldref t.cp ~class_ ~field ~descriptor in
  add_u1 t.buf 0xB2;
  add_u2 t.buf idx;
  push t 1

let putstatic t ~class_ ~field ~descriptor =
  let idx = Cp.fieldref t.cp ~class_ ~field ~descriptor in
  add_u1 t.buf 0xB3;
  add_u2 t.buf idx;
  let slots =
    match String.sub descriptor 0 1 with
    | "D" | "J" -> 2
    | _ -> 1
  in
  pop t slots

let invokevirtual t ~class_ ~method_ ~descriptor =
  let idx = Cp.methodref t.cp ~class_ ~method_ ~descriptor in
  add_u1 t.buf 0xB6;
  add_u2 t.buf idx;
  let net = stack_effect_of_call_descriptor descriptor ~is_virtual:true in
  if net >= 0 then pop t net else push t (-net)

let invokestatic t ~class_ ~method_ ~descriptor =
  let idx = Cp.methodref t.cp ~class_ ~method_ ~descriptor in
  add_u1 t.buf 0xB8;
  add_u2 t.buf idx;
  let net = stack_effect_of_call_descriptor descriptor ~is_virtual:false in
  if net >= 0 then pop t net else push t (-net)

let return_void t =
  add_u1 t.buf 0xB1;
  t.stack <- 0

let ireturn t =
  add_u1 t.buf 0xAC;
  t.stack <- 0

let areturn t =
  add_u1 t.buf 0xB0;
  t.stack <- 0

(* Invert a conditional-branch opcode. Used by branch relaxation when
   a short [if_cond L] needs to become [if_!cond +8; goto_w L]. *)
let invert_conditional_branch = function
  | 0x99 -> 0x9A | 0x9A -> 0x99 (* ifeq / ifne *)
  | 0x9B -> 0x9C | 0x9C -> 0x9B (* iflt / ifge *)
  | 0x9D -> 0x9E | 0x9E -> 0x9D (* ifgt / ifle *)
  | 0x9F -> 0xA0 | 0xA0 -> 0x9F (* if_icmpeq / if_icmpne *)
  | 0xA1 -> 0xA2 | 0xA2 -> 0xA1 (* if_icmplt / if_icmpge *)
  | 0xA3 -> 0xA4 | 0xA4 -> 0xA3 (* if_icmpgt / if_icmple *)
  | 0xA5 -> 0xA6 | 0xA6 -> 0xA5 (* if_acmpeq / if_acmpne *)
  | 0xC6 -> 0xC7 | 0xC7 -> 0xC6 (* ifnull / ifnonnull *)
  | op -> failwith (Printf.sprintf "jvm: not a conditional branch: 0x%02x" op)

(* [resolve] — patch branch offsets into the buffer, widening any
   short (3-byte) branch whose target is farther than the signed
   16-bit range. Widening a short branch can push other targets out
   of range, so iterate the decision until stable, then rebuild the
   buffer with the widened forms.

   Widening:
   - [goto L] (3 bytes) -> [goto_w L] (5 bytes), +2 bytes.
   - [if_cond L] (3 bytes) -> [if_!cond +8; goto_w L] (8 bytes), +5
     bytes. The fall-through of the inverted branch lands past the
     [goto_w], preserving [if_cond L] semantics while giving us a
     4-byte offset for the actual jump.

   Labels and line-number entries have positions in original-buffer
   coordinates; we remap them to new coordinates after the rebuild
   so [exception_entries] and [line_entries] stay consistent. *)
let resolve t =
  let bytes = Bytes.of_string (Buffer.contents t.buf) in
  let label_target lbl =
    match lbl.target with
    | Some p -> p
    | None ->
      failwith
        (Printf.sprintf "jvm: label %d referenced but never marked" lbl.id)
  in
  (* Gather every branch ref along with its enclosing label's target
     in original coordinates. Widening state is tracked per ref. *)
  let all_refs =
    List.concat_map
      (fun lbl ->
        let tgt = label_target lbl in
        List.map (fun r -> lbl, tgt, r) lbl.refs)
      t.labels
  in
  let widened = Hashtbl.create 16 in
  let is_short r = r.width = 2 in
  (* Original end of the instruction an opcode_pc belongs to. For
     width=2 this is opcode_pc + 3 (opcode + u2). For width=4 we
     conservatively use the maximum [offset_pc + 4] across refs at
     that opcode — captures goto_w (1 ref) and tableswitch (N refs
     ending at the last case's offset). *)
  let instr_end_by_opcode = Hashtbl.create 16 in
  List.iter
    (fun (_, _, r) ->
      let prev = try Hashtbl.find instr_end_by_opcode r.opcode_pc with Not_found -> 0 in
      let this_end =
        if r.width = 2 then r.opcode_pc + 3 else r.offset_pc + r.width
      in
      if this_end > prev then Hashtbl.replace instr_end_by_opcode r.opcode_pc this_end)
    all_refs;
  let widening_delta r =
    if not (Hashtbl.mem widened (r.opcode_pc, r.offset_pc))
    then 0
    else
      let op = Bytes.get_uint8 bytes r.opcode_pc in
      if op = 0xA7 then 2 else 5
  in
  (* Cumulative shift at an original byte position: the sum of deltas
     for all widened branches whose original instruction ended at or
     before [pos]. O(n_widenings) per query, but n_widenings is tiny
     compared to the buffer. *)
  let shift_at pos =
    List.fold_left
      (fun acc (_, _, r) ->
        if is_short r
           && Hashtbl.mem widened (r.opcode_pc, r.offset_pc)
           && Hashtbl.find instr_end_by_opcode r.opcode_pc <= pos
        then acc + widening_delta r
        else acc)
      0
      all_refs
  in
  let short_fits_in_16 offset = offset >= -32768 && offset <= 32767 in
  let changed = ref true in
  while !changed do
    changed := false;
    List.iter
      (fun (_, tgt, r) ->
        if is_short r && not (Hashtbl.mem widened (r.opcode_pc, r.offset_pc))
        then (
          let new_target = tgt + shift_at tgt in
          let new_base = r.offset_base + shift_at r.offset_base in
          let offset = new_target - new_base in
          if not (short_fits_in_16 offset)
          then (
            Hashtbl.add widened (r.opcode_pc, r.offset_pc) ();
            changed := true)))
      all_refs
  done;
  (* If no widenings were needed, patch offsets in place and we're done. *)
  if Hashtbl.length widened = 0
  then (
    List.iter
      (fun (_, tgt, r) ->
        let offset = tgt - r.offset_base in
        match r.width with
        | 2 ->
          let off = offset land 0xffff in
          Bytes.set_uint8 bytes r.offset_pc ((off lsr 8) land 0xff);
          Bytes.set_uint8 bytes (r.offset_pc + 1) (off land 0xff)
        | 4 ->
          let off = offset land 0xffffffff in
          Bytes.set_uint8 bytes r.offset_pc ((off lsr 24) land 0xff);
          Bytes.set_uint8 bytes (r.offset_pc + 1) ((off lsr 16) land 0xff);
          Bytes.set_uint8 bytes (r.offset_pc + 2) ((off lsr 8) land 0xff);
          Bytes.set_uint8 bytes (r.offset_pc + 3) (off land 0xff)
        | _ -> assert false)
      all_refs;
    Buffer.clear t.buf;
    Buffer.add_bytes t.buf bytes)
  else (
    (* Rebuild the buffer with widened instructions spliced in.
       Walk original byte positions in order, grouping refs by
       opcode_pc so tableswitch's many refs are processed together. *)
    let new_buf = Buffer.create (Bytes.length bytes + 16) in
    let opcode_pcs =
      List.sort_uniq compare (List.map (fun (_, _, r) -> r.opcode_pc) all_refs)
    in
    (* For each ref, remember its new (opcode_pc, offset_pc, width)
       so we can patch the offset once target shifts are known. *)
    let new_refs = Hashtbl.create 16 in
    let cursor = ref 0 in
    List.iter
      (fun opc ->
        (* Copy bytes from cursor up to this opcode. *)
        if opc > !cursor
        then Buffer.add_subbytes new_buf bytes !cursor (opc - !cursor);
        cursor := opc;
        let refs_here =
          List.filter (fun (_, _, r) -> r.opcode_pc = opc) all_refs
        in
        let orig_end = Hashtbl.find instr_end_by_opcode opc in
        let any_widened_here =
          List.exists
            (fun (_, _, r) -> Hashtbl.mem widened (r.opcode_pc, r.offset_pc))
            refs_here
        in
        if any_widened_here
        then (
          (* Exactly one ref per opcode for short branches. *)
          let lbl, _, r =
            match refs_here with
            | [ x ] -> x
            | _ -> assert false
          in
          let op = Bytes.get_uint8 bytes opc in
          if op = 0xA7
          then (
            (* goto -> goto_w *)
            let new_opc = Buffer.length new_buf in
            Buffer.add_char new_buf (Char.chr 0xC8);
            let new_off = Buffer.length new_buf in
            for _ = 1 to 4 do
              Buffer.add_char new_buf '\x00'
            done;
            Hashtbl.add
              new_refs
              (r.opcode_pc, r.offset_pc)
              (lbl, { opcode_pc = new_opc; offset_pc = new_off; width = 4; offset_base = new_opc }))
          else (
            (* if_cond L -> if_!cond +8; goto_w L *)
            let new_opc = Buffer.length new_buf in
            Buffer.add_char new_buf (Char.chr (invert_conditional_branch op));
            Buffer.add_char new_buf '\x00';
            Buffer.add_char new_buf (Char.chr 8);
            Buffer.add_char new_buf (Char.chr 0xC8);
            let new_off = Buffer.length new_buf in
            for _ = 1 to 4 do
              Buffer.add_char new_buf '\x00'
            done;
            Hashtbl.add
              new_refs
              (r.opcode_pc, r.offset_pc)
              (lbl, { opcode_pc = new_opc; offset_pc = new_off; width = 4; offset_base = new_opc + 3 })))
        else (
          (* Not widened — copy the instruction's bytes through and
             remap each ref's offset_pc to its new position. Keeping
             width / offset_base semantics from the original. *)
          let orig_start = opc in
          let new_start = Buffer.length new_buf in
          Buffer.add_subbytes new_buf bytes orig_start (orig_end - orig_start);
          List.iter
            (fun (lbl, _, r) ->
              let new_offset_pc = new_start + (r.offset_pc - orig_start) in
              let new_offset_base = new_start + (r.offset_base - orig_start) in
              Hashtbl.add
                new_refs
                (r.opcode_pc, r.offset_pc)
                (lbl
                , { opcode_pc = new_start
                  ; offset_pc = new_offset_pc
                  ; width = r.width
                  ; offset_base = new_offset_base
                  }))
            refs_here);
        cursor := orig_end)
      opcode_pcs;
    (* Trailing bytes after the last branch. *)
    if !cursor < Bytes.length bytes
    then
      Buffer.add_subbytes
        new_buf
        bytes
        !cursor
        (Bytes.length bytes - !cursor);
    let new_bytes = Bytes.of_string (Buffer.contents new_buf) in
    (* Remap label targets, then patch offsets. *)
    List.iter
      (fun lbl ->
        match lbl.target with
        | Some p -> lbl.target <- Some (p + shift_at p)
        | None -> ())
      t.labels;
    (* Replace each label's [refs] with the post-rebuild version. *)
    List.iter
      (fun lbl ->
        lbl.refs <-
          List.map
            (fun r ->
              let _, r' = Hashtbl.find new_refs (r.opcode_pc, r.offset_pc) in
              r')
            lbl.refs)
      t.labels;
    List.iter
      (fun lbl ->
        let tgt =
          match lbl.target with
          | Some p -> p
          | None -> assert false
        in
        List.iter
          (fun r ->
            let offset = tgt - r.offset_base in
            match r.width with
            | 2 ->
              if offset < -32768 || offset > 32767
              then
                failwith
                  (Printf.sprintf
                     "jvm: short branch still overflows after relaxation \
                      (offset %d)"
                     offset);
              let off = offset land 0xffff in
              Bytes.set_uint8
                new_bytes
                r.offset_pc
                ((off lsr 8) land 0xff);
              Bytes.set_uint8 new_bytes (r.offset_pc + 1) (off land 0xff)
            | 4 ->
              let off = offset land 0xffffffff in
              Bytes.set_uint8
                new_bytes
                r.offset_pc
                ((off lsr 24) land 0xff);
              Bytes.set_uint8
                new_bytes
                (r.offset_pc + 1)
                ((off lsr 16) land 0xff);
              Bytes.set_uint8
                new_bytes
                (r.offset_pc + 2)
                ((off lsr 8) land 0xff);
              Bytes.set_uint8 new_bytes (r.offset_pc + 3) (off land 0xff)
            | _ -> assert false)
          lbl.refs)
      t.labels;
    (* Remap line entries to new coordinates. *)
    t.line_entries <-
      List.map (fun (pc, line) -> pc + shift_at pc, line) t.line_entries;
    Buffer.clear t.buf;
    Buffer.add_bytes t.buf new_bytes)

let contents t =
  resolve t;
  Buffer.contents t.buf

let resolved_size t =
  resolve t;
  Buffer.length t.buf

let max_stack t = t.max_stack

let max_locals t = t.max_locals

let exception_entries t =
  List.rev_map
    (fun e ->
      let target lbl =
        match lbl.target with
        | Some off -> off
        | None ->
          failwith "jvm: exception_entry references an unmarked label"
      in
      target e.start_lbl, target e.end_lbl, target e.handler_lbl, e.catch_cp_idx)
    t.exceptions
