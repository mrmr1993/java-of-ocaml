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
  }

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

let resolve t =
  let bytes = Bytes.of_string (Buffer.contents t.buf) in
  List.iter
    (fun lbl ->
      match lbl.target with
      | None ->
        failwith
          (Printf.sprintf "jvm: label %d referenced but never marked" lbl.id)
      | Some target ->
        List.iter
          (fun { opcode_pc = _; offset_pc; width; offset_base } ->
            let offset = target - offset_base in
            match width with
            | 2 ->
              if offset < -32768 || offset > 32767
              then
                failwith
                  (Printf.sprintf
                     "jvm: branch offset %d out of signed 16-bit range"
                     offset);
              let off = offset land 0xffff in
              Bytes.set_uint8 bytes offset_pc ((off lsr 8) land 0xff);
              Bytes.set_uint8 bytes (offset_pc + 1) (off land 0xff)
            | 4 ->
              let off = offset land 0xffffffff in
              Bytes.set_uint8 bytes offset_pc ((off lsr 24) land 0xff);
              Bytes.set_uint8 bytes (offset_pc + 1) ((off lsr 16) land 0xff);
              Bytes.set_uint8 bytes (offset_pc + 2) ((off lsr 8) land 0xff);
              Bytes.set_uint8 bytes (offset_pc + 3) (off land 0xff)
            | _ -> assert false)
          lbl.refs)
    t.labels;
  Buffer.clear t.buf;
  Buffer.add_bytes t.buf bytes

let contents t =
  resolve t;
  Buffer.contents t.buf

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
