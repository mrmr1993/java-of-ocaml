(* Binary-writing helpers. The JVM class file format is big-endian throughout. *)

let add_u1 buf n = Buffer.add_char buf (Char.chr (n land 0xff))

let add_u2 buf n =
  Buffer.add_char buf (Char.chr ((n lsr 8) land 0xff));
  Buffer.add_char buf (Char.chr (n land 0xff))

let add_u4 buf n =
  Buffer.add_char buf (Char.chr ((n lsr 24) land 0xff));
  Buffer.add_char buf (Char.chr ((n lsr 16) land 0xff));
  Buffer.add_char buf (Char.chr ((n lsr 8) land 0xff));
  Buffer.add_char buf (Char.chr (n land 0xff))

(* --- Constant pool ---

   Entries are 1-indexed. We keep raw serialised bytes alongside a table from
   logical key to the 1-based index, so repeated requests for the same entry
   (e.g. the same UTF-8 string) return the same index. *)

module Cp = struct
  type t =
    { mutable count : int
    ; buf : Buffer.t
    ; table : (string, int) Hashtbl.t
    }

  let create () =
    { count = 1 (* entries are 1-based; [count] is the next index to assign *)
    ; buf = Buffer.create 256
    ; table = Hashtbl.create 32
    }

  let intern t key emit =
    match Hashtbl.find_opt t.table key with
    | Some idx -> idx
    | None ->
      let idx = t.count in
      t.count <- t.count + 1;
      emit t.buf;
      Hashtbl.add t.table key idx;
      idx

  let utf8 t s =
    intern t ("U:" ^ s) (fun buf ->
      add_u1 buf 1;
      add_u2 buf (String.length s);
      Buffer.add_string buf s)

  let class_ t name =
    let utf_idx = utf8 t name in
    intern t ("C:" ^ name) (fun buf ->
      add_u1 buf 7;
      add_u2 buf utf_idx)

  let string t s =
    let utf_idx = utf8 t s in
    intern t ("S:" ^ s) (fun buf ->
      add_u1 buf 8;
      add_u2 buf utf_idx)

  let name_and_type t ~name ~descriptor =
    let n_idx = utf8 t name in
    let d_idx = utf8 t descriptor in
    intern t ("NT:" ^ name ^ ":" ^ descriptor) (fun buf ->
      add_u1 buf 12;
      add_u2 buf n_idx;
      add_u2 buf d_idx)

  let class_ref = class_

  let fieldref t ~class_ ~field ~descriptor =
    let cls_idx = class_ref t class_ in
    let nt_idx = name_and_type t ~name:field ~descriptor in
    intern t ("F:" ^ class_ ^ ":" ^ field ^ ":" ^ descriptor) (fun buf ->
      add_u1 buf 9;
      add_u2 buf cls_idx;
      add_u2 buf nt_idx)

  let methodref t ~class_ ~method_ ~descriptor =
    let cls_idx = class_ref t class_ in
    let nt_idx = name_and_type t ~name:method_ ~descriptor in
    intern t ("M:" ^ class_ ^ ":" ^ method_ ^ ":" ^ descriptor) (fun buf ->
      add_u1 buf 10;
      add_u2 buf cls_idx;
      add_u2 buf nt_idx)

  let count t = t.count - 1

  let contents t = Buffer.contents t.buf
end

(* --- Method-body builder ---

   Tracks operand-stack depth so we can set [max_stack] correctly.
   Straight-line code only: no branches, no exception handlers. *)

let stack_effect_of_call_descriptor descriptor ~is_virtual =
  (* Net stack effect of invokevirtual / invokestatic on a method with the
     given descriptor. Counts args in "(...)R" between parens; virtual calls
     consume one extra slot (the receiver). *)
  let lp = String.index descriptor '(' in
  let rp = String.index descriptor ')' in
  let args = String.sub descriptor (lp + 1) (rp - lp - 1) in
  let rec count_args i acc =
    if i >= String.length args
    then acc
    else
      match args.[i] with
      | 'L' ->
        let semi = String.index_from args i ';' in
        count_args (semi + 1) (acc + 1)
      | '[' -> count_args (i + 1) acc
      | _ -> count_args (i + 1) (acc + 1)
  in
  let n_args = count_args 0 0 in
  let ret = String.sub descriptor (rp + 1) 1 in
  let push_ret = if ret = "V" then 0 else 1 in
  let pops = n_args + if is_virtual then 1 else 0 in
  pops - push_ret

module Code = struct
  type t =
    { cp : Cp.t
    ; buf : Buffer.t
    ; mutable stack : int
    ; mutable max_stack : int
    }

  let create cp = { cp; buf = Buffer.create 64; stack = 0; max_stack = 0 }

  let push t n =
    t.stack <- t.stack + n;
    if t.stack > t.max_stack then t.max_stack <- t.stack

  let pop t n = t.stack <- t.stack - n

  let ldc_string t s =
    let idx = Cp.string t.cp s in
    if idx <= 0xff
    then (
      add_u1 t.buf 0x12 (* ldc *);
      add_u1 t.buf idx)
    else (
      add_u1 t.buf 0x13 (* ldc_w *);
      add_u2 t.buf idx);
    push t 1

  let ldc_int t n =
    (* Pick the tightest encoding. iconst_m1..iconst_5 are one byte; bipush
       handles -128..127 in two bytes; sipush handles -32768..32767 in three;
       anything else needs a CONSTANT_Integer constant-pool entry. *)
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
       add_u1 t.buf 0x10 (* bipush *);
       add_u1 t.buf (n land 0xff))
     else if n >= -32768 && n <= 32767
     then (
       add_u1 t.buf 0x11 (* sipush *);
       add_u2 t.buf (n land 0xffff))
     else
       let idx =
         Cp.intern
           t.cp
           (Printf.sprintf "I:%d" n)
           (fun buf ->
             add_u1 buf 3 (* CONSTANT_Integer *);
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

  let pop_top t =
    add_u1 t.buf 0x57;
    pop t 1

  let swap t =
    add_u1 t.buf 0x5F
    (* stack depth unchanged *)

  let iadd t =
    add_u1 t.buf 0x60;
    pop t 1

  let isub t =
    add_u1 t.buf 0x64;
    pop t 1

  let imul t =
    add_u1 t.buf 0x68;
    pop t 1

  let getstatic t ~class_ ~field ~descriptor =
    let idx = Cp.fieldref t.cp ~class_ ~field ~descriptor in
    add_u1 t.buf 0xB2;
    add_u2 t.buf idx;
    push t 1

  let invokevirtual t ~class_ ~method_ ~descriptor =
    let idx = Cp.methodref t.cp ~class_ ~method_ ~descriptor in
    add_u1 t.buf 0xB6;
    add_u2 t.buf idx;
    let net = stack_effect_of_call_descriptor descriptor ~is_virtual:true in
    if net >= 0
    then pop t net
    else push t (-net)

  let return_void t =
    add_u1 t.buf 0xB1 (* return *);
    t.stack <- 0

  let contents t = Buffer.contents t.buf

  let max_stack t = t.max_stack
end

(* --- Class assembly --- *)

let assemble_main_class build =
  let cp = Cp.create () in
  let code = Code.create cp in
  build cp code;
  let code_bytes = Code.contents code in
  let code_len = String.length code_bytes in
  (* Pre-register structural constants so the CP serialisation order is
     stable even though emitting instructions may have already appended. *)
  let this_class = Cp.class_ cp "Main" in
  let super_class = Cp.class_ cp "java/lang/Object" in
  let main_name = Cp.utf8 cp "main" in
  let main_desc = Cp.utf8 cp "([Ljava/lang/String;)V" in
  let code_attr_name = Cp.utf8 cp "Code" in
  let out = Buffer.create 512 in
  add_u4 out 0xCAFEBABE;
  add_u2 out 0 (* minor_version *);
  add_u2 out 52 (* major_version = Java 8 *);
  add_u2 out (Cp.count cp + 1);
  Buffer.add_string out (Cp.contents cp);
  add_u2 out 0x0021 (* access_flags: ACC_PUBLIC | ACC_SUPER *);
  add_u2 out this_class;
  add_u2 out super_class;
  add_u2 out 0 (* interfaces_count *);
  add_u2 out 0 (* fields_count *);
  add_u2 out 1 (* methods_count *);
  add_u2 out 0x0009 (* ACC_PUBLIC | ACC_STATIC *);
  add_u2 out main_name;
  add_u2 out main_desc;
  add_u2 out 1 (* one Code attribute on the method *);
  add_u2 out code_attr_name;
  let attr_len =
    2 (* max_stack *) + 2 (* max_locals *) + 4 (* code_length *) + code_len
    + 2 (* exception_table_length *) + 2 (* Code attributes_count *)
  in
  add_u4 out attr_len;
  add_u2 out (Code.max_stack code);
  add_u2 out 1 (* max_locals: just the String[] args slot *);
  add_u4 out code_len;
  Buffer.add_string out code_bytes;
  add_u2 out 0 (* exception_table_length *);
  add_u2 out 0 (* nested attributes_count *);
  add_u2 out 0 (* class attributes_count *);
  Buffer.contents out
