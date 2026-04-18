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
  type label =
    { mutable target : int option (* byte offset inside [buf], once marked *)
    ; mutable refs : (int * int) list
      (* (branch-opcode pc, pc to encode the offset against) *)
    ; id : int
    }

  type exception_entry =
    { start_lbl : label
    ; end_lbl : label
    ; handler_lbl : label
    ; catch_cp_idx : int (* constant pool index of the catch class, or 0 for
                             "finally"-style [any] *)
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
    ; max_locals = 1 (* slot 0 for the String[] args parameter *)
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
      { start_lbl; end_lbl; handler_lbl; catch_cp_idx = idx }
      :: t.exceptions

  (* Handler entries are installed into the JVM at serialisation time; the
     verifier expects a single Throwable on the operand stack at handler
     entry. The handler code path starts with [stack = 1]. *)
  let handler_stack_prelude t =
    t.stack <- 1;
    if t.stack > t.max_stack then t.max_stack <- t.stack

  let note_local t index =
    if index + 1 > t.max_locals then t.max_locals <- index + 1

  let set_min_locals t n =
    if n > t.max_locals then t.max_locals <- n

  let fresh_label t =
    let lbl = { target = None; refs = []; id = t.next_label_id } in
    t.next_label_id <- t.next_label_id + 1;
    t.labels <- lbl :: t.labels;
    lbl

  let mark_label t lbl =
    (match lbl.target with
     | Some _ ->
       failwith
         (Printf.sprintf
            "jvm: label %d marked twice"
            lbl.id)
     | None -> ());
    lbl.target <- Some (Buffer.length t.buf)

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

  let dup2 t =
    add_u1 t.buf 0x5C;
    push t 2

  let pop_top t =
    add_u1 t.buf 0x57;
    pop t 1

  let swap t =
    add_u1 t.buf 0x5F
    (* stack depth unchanged *)

  let istore t n =
    (if n >= 0 && n <= 3
     then add_u1 t.buf (0x3B + n) (* istore_0 .. istore_3 *)
     else if n < 256
     then (
       add_u1 t.buf 0x36;
       add_u1 t.buf n)
     else
       failwith
         (Printf.sprintf "jvm: istore index %d exceeds 1-byte range" n));
    note_local t n;
    pop t 1

  let iload t n =
    (if n >= 0 && n <= 3
     then add_u1 t.buf (0x1A + n) (* iload_0 .. iload_3 *)
     else if n < 256
     then (
       add_u1 t.buf 0x15;
       add_u1 t.buf n)
     else
       failwith
         (Printf.sprintf "jvm: iload index %d exceeds 1-byte range" n));
    note_local t n;
    push t 1

  let astore t n =
    (if n >= 0 && n <= 3
     then add_u1 t.buf (0x4B + n) (* astore_0 .. astore_3 *)
     else if n < 256
     then (
       add_u1 t.buf 0x3A;
       add_u1 t.buf n)
     else
       failwith
         (Printf.sprintf "jvm: astore index %d exceeds 1-byte range" n));
    note_local t n;
    pop t 1

  let aload t n =
    (if n >= 0 && n <= 3
     then add_u1 t.buf (0x2A + n) (* aload_0 .. aload_3 *)
     else if n < 256
     then (
       add_u1 t.buf 0x19;
       add_u1 t.buf n)
     else
       failwith
         (Printf.sprintf "jvm: aload index %d exceeds 1-byte range" n));
    note_local t n;
    push t 1

  let newarray_int t =
    add_u1 t.buf 0xBC;
    add_u1 t.buf 10 (* T_INT *)
    (* stack effect: pops [count], pushes [arrayref] — net 0 *)

  let iaload t =
    add_u1 t.buf 0x2E;
    pop t 1 (* pops arrayref + index, pushes value; net -1 *)

  let iastore t =
    add_u1 t.buf 0x4F;
    pop t 3 (* pops arrayref + index + value *)

  let arraylength t =
    add_u1 t.buf 0xBE
    (* pops arrayref, pushes length — net 0 *)

  let anewarray t class_name =
    let idx = Cp.class_ t.cp class_name in
    add_u1 t.buf 0xBD;
    add_u2 t.buf idx
    (* pops [count], pushes [arrayref] — net 0 *)

  let aaload t =
    add_u1 t.buf 0x32;
    pop t 1 (* pops arrayref + index, pushes value; net -1 *)

  let aastore t =
    add_u1 t.buf 0x53;
    pop t 3 (* pops arrayref + index + value *)

  let checkcast t class_name =
    let idx = Cp.class_ t.cp class_name in
    add_u1 t.buf 0xC0;
    add_u2 t.buf idx
    (* stack effect: 0 *)

  let new_ t class_name =
    let idx = Cp.class_ t.cp class_name in
    add_u1 t.buf 0xBB;
    add_u2 t.buf idx;
    push t 1

  let invokespecial t ~class_ ~method_ ~descriptor =
    let idx = Cp.methodref t.cp ~class_ ~method_ ~descriptor in
    add_u1 t.buf 0xB7;
    add_u2 t.buf idx;
    let net =
      stack_effect_of_call_descriptor descriptor ~is_virtual:true
    in
    if net >= 0
    then pop t net
    else push t (-net)

  let getfield t ~class_ ~field ~descriptor =
    let idx = Cp.fieldref t.cp ~class_ ~field ~descriptor in
    add_u1 t.buf 0xB4;
    add_u2 t.buf idx;
    (* Pops objectref, pushes value. For single-slot values (int or ref,
       which is all we use) net effect is 0. *)
    ignore t

  let putfield t ~class_ ~field ~descriptor =
    let idx = Cp.fieldref t.cp ~class_ ~field ~descriptor in
    add_u1 t.buf 0xB5;
    add_u2 t.buf idx;
    (* Pops objectref + value. *)
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

  (* Emit a 2-byte branch instruction and record that its 2-byte offset
     field needs to be patched once [lbl] is marked. The stack delta is
     applied before the branch. *)
  let emit_branch t lbl opcode ~stack_delta =
    let branch_pc = Buffer.length t.buf in
    add_u1 t.buf opcode;
    add_u2 t.buf 0 (* placeholder offset *);
    lbl.refs <- (branch_pc, branch_pc) :: lbl.refs;
    (if stack_delta >= 0
     then push t stack_delta
     else pop t (-stack_delta))

  let if_icmpeq t lbl = emit_branch t lbl 0x9F ~stack_delta:(-2)
  let if_icmpne t lbl = emit_branch t lbl 0xA0 ~stack_delta:(-2)
  let if_icmplt t lbl = emit_branch t lbl 0xA1 ~stack_delta:(-2)
  let if_icmpge t lbl = emit_branch t lbl 0xA2 ~stack_delta:(-2)
  let if_icmpgt t lbl = emit_branch t lbl 0xA3 ~stack_delta:(-2)
  let if_icmple t lbl = emit_branch t lbl 0xA4 ~stack_delta:(-2)

  let ifeq t lbl = emit_branch t lbl 0x99 ~stack_delta:(-1)
  let ifne t lbl = emit_branch t lbl 0x9A ~stack_delta:(-1)

  let if_acmpeq t lbl = emit_branch t lbl 0xA5 ~stack_delta:(-2)
  let if_acmpne t lbl = emit_branch t lbl 0xA6 ~stack_delta:(-2)

  let goto t lbl = emit_branch t lbl 0xA7 ~stack_delta:0

  let instanceof_ t class_name =
    let idx = Cp.class_ t.cp class_name in
    add_u1 t.buf 0xC1;
    add_u2 t.buf idx
    (* pops ref, pushes int — net 0 *)

  let athrow t =
    add_u1 t.buf 0xBF;
    t.stack <- 0
    (* pops the thrown reference; control leaves the frame. *)

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

  let invokestatic t ~class_ ~method_ ~descriptor =
    let idx = Cp.methodref t.cp ~class_ ~method_ ~descriptor in
    add_u1 t.buf 0xB8;
    add_u2 t.buf idx;
    let net =
      stack_effect_of_call_descriptor descriptor ~is_virtual:false
    in
    if net >= 0
    then pop t net
    else push t (-net)

  let return_void t =
    add_u1 t.buf 0xB1 (* return *);
    t.stack <- 0

  let ireturn t =
    add_u1 t.buf 0xAC (* ireturn *);
    t.stack <- 0

  let areturn t =
    add_u1 t.buf 0xB0 (* areturn *);
    t.stack <- 0

  (* Resolve all forward references: for each label, patch the placeholder
     u2 at (branch_pc+1, branch_pc+2) with the signed 16-bit offset
     (target_pc - branch_pc). Buffers aren't mutable in place, so we convert
     to bytes, patch, and rebuild. *)
  let resolve t =
    let bytes = Bytes.of_string (Buffer.contents t.buf) in
    List.iter
      (fun lbl ->
        match lbl.target with
        | None ->
          failwith
            (Printf.sprintf
               "jvm: label %d referenced but never marked"
               lbl.id)
        | Some target ->
          List.iter
            (fun (branch_pc, _) ->
              let offset = target - branch_pc in
              if offset < -32768 || offset > 32767
              then
                failwith
                  (Printf.sprintf
                     "jvm: branch offset %d out of signed 16-bit range"
                     offset);
              let off = offset land 0xffff in
              Bytes.set_uint8 bytes (branch_pc + 1) ((off lsr 8) land 0xff);
              Bytes.set_uint8 bytes (branch_pc + 2) (off land 0xff))
            lbl.refs)
      t.labels;
    Buffer.clear t.buf;
    Buffer.add_bytes t.buf bytes

  let contents t =
    resolve t;
    Buffer.contents t.buf

  let max_stack t = t.max_stack

  let max_locals t = t.max_locals

  (* After [contents] has run (label resolution is complete), each
     exception_entry's labels have their final byte offsets. Surface
     them as 4-tuples the class-file emitter can write directly. *)
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
end

(* --- Class assembly --- *)

type method_desc =
  { name : string
  ; descriptor : string
  ; access_flags : int
  ; code : Code.t
  }

type field_desc =
  { name : string
  ; descriptor : string
  ; access_flags : int
  }

(* A method's CP indices are captured up-front so they can be interned
   BEFORE the constant pool is serialised. Code bytes are realised at the
   same time (triggering label resolution and any final CP additions). *)
type method_layout =
  { m : method_desc
  ; code_bytes : string
  ; name_idx : int
  ; desc_idx : int
  ; code_attr_idx : int
  }

let emit_method_info out (l : method_layout) =
  let code_len = String.length l.code_bytes in
  let entries = Code.exception_entries l.m.code in
  let n_entries = List.length entries in
  add_u2 out l.m.access_flags;
  add_u2 out l.name_idx;
  add_u2 out l.desc_idx;
  add_u2 out 1 (* one Code attribute *);
  add_u2 out l.code_attr_idx;
  let attr_len = 2 + 2 + 4 + code_len + 2 + (8 * n_entries) + 2 in
  add_u4 out attr_len;
  add_u2 out (Code.max_stack l.m.code);
  add_u2 out (Code.max_locals l.m.code);
  add_u4 out code_len;
  Buffer.add_string out l.code_bytes;
  add_u2 out n_entries;
  List.iter
    (fun (start_pc, end_pc, handler_pc, catch_type) ->
      add_u2 out start_pc;
      add_u2 out end_pc;
      add_u2 out handler_pc;
      add_u2 out catch_type)
    entries;
  add_u2 out 0 (* nested attributes_count *)

type field_layout =
  { f : field_desc
  ; f_name_idx : int
  ; f_desc_idx : int
  }

let emit_field_info out (l : field_layout) =
  add_u2 out l.f.access_flags;
  add_u2 out l.f_name_idx;
  add_u2 out l.f_desc_idx;
  add_u2 out 0 (* attributes_count *)

let assemble_class
    ~class_name
    ~super_name
    ~cp
    ~fields
    ~methods
    ~access_flags
  =
  (* Phase 1: realise bytes and intern all CP entries that the methods or
     class header need. Code bytes have to be computed first — [Code.contents]
     runs label resolution and may add CP entries through branch emission. *)
  let method_layouts =
    List.map
      (fun m ->
        let bytes = Code.contents m.code in
        { m
        ; code_bytes = bytes
        ; name_idx = Cp.utf8 cp m.name
        ; desc_idx = Cp.utf8 cp m.descriptor
        ; code_attr_idx = Cp.utf8 cp "Code"
        })
      methods
  in
  let field_layouts =
    List.map
      (fun f ->
        { f
        ; f_name_idx = Cp.utf8 cp f.name
        ; f_desc_idx = Cp.utf8 cp f.descriptor
        })
      fields
  in
  let this_class = Cp.class_ cp class_name in
  let super_class = Cp.class_ cp super_name in
  (* Phase 2: serialise. The CP is now stable. *)
  let out = Buffer.create 512 in
  add_u4 out 0xCAFEBABE;
  add_u2 out 0 (* minor_version *);
  add_u2 out 49 (* major_version = Java 5.
                   Modern JVMs apply type-inference verification to
                   major_version <= 49 class files; 50 is borderline and
                   can fall back but newer JDKs are strict. Using 49 is
                   the reliable way to avoid emitting StackMapTable
                   attributes for now. *);
  add_u2 out (Cp.count cp + 1);
  Buffer.add_string out (Cp.contents cp);
  add_u2 out access_flags;
  add_u2 out this_class;
  add_u2 out super_class;
  add_u2 out 0 (* interfaces_count *);
  add_u2 out (List.length fields);
  List.iter (emit_field_info out) field_layouts;
  add_u2 out (List.length methods);
  List.iter (emit_method_info out) method_layouts;
  add_u2 out 0 (* class attributes_count *);
  Buffer.contents out

let assemble_main_class build =
  let cp = Cp.create () in
  let main_code = Code.create cp in
  build cp main_code;
  assemble_class
    ~class_name:"Main"
    ~super_name:"java/lang/Object"
    ~cp
    ~fields:[]
    ~methods:
      [ { name = "main"
        ; descriptor = "([Ljava/lang/String;)V"
        ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
        ; code = main_code
        }
      ]
    ~access_flags:0x0021 (* ACC_PUBLIC | ACC_SUPER *)

(* -------------------------------------------------------------------------- *)
(* Block class

     public final class Block {
         public final int tag;
         public final Object[] fields;
         public Block(int tag, Object[] fields) {
             this.tag = tag;
             this.fields = fields;
         }
     }

   Generated at class-writing time so it can ship alongside Main.class. *)

(* -------------------------------------------------------------------------- *)
(* Closure base class

     public class Closure {
         public Closure() { super(); }
         public Object apply1(Object a1) { throw new RuntimeException(...); }
         public Object apply2(Object a1, Object a2) { throw ...; }
         public Object apply3(Object a1, Object a2, Object a3) { throw ...; }
     }

   OCaml functions are compiled to subclasses that override the apply
   method matching their arity. *)

let closure_class_bytes () =
  let cp = Cp.create () in
  (* <init>() — just calls Object.<init>. *)
  let ctor = Code.create cp in
  Code.set_min_locals ctor 1;
  Code.aload ctor 0;
  Code.invokespecial
    ctor
    ~class_:"java/lang/Object"
    ~method_:"<init>"
    ~descriptor:"()V";
  Code.return_void ctor;
  (* Throwing-body helper: builds a method that does
       new RuntimeException("arity mismatch");
       athrow
     with enough locals for the declared args. *)
  let throw_body ~nargs =
    let body = Code.create cp in
    Code.set_min_locals body (1 + nargs);
    (* Push throw-message + throw. We use String constant via ldc. *)
    Code.new_ body "java/lang/RuntimeException";
    Code.dup body;
    Code.ldc_string body "closure arity mismatch";
    Code.invokespecial
      body
      ~class_:"java/lang/RuntimeException"
      ~method_:"<init>"
      ~descriptor:"(Ljava/lang/String;)V";
    (* Stack: [..., exception]. athrow (0xBF). *)
    add_u1 body.buf 0xBF;
    body
  in
  let make_apply n =
    let desc =
      let buf = Buffer.create 16 in
      Buffer.add_char buf '(';
      for _ = 1 to n do
        Buffer.add_string buf "Ljava/lang/Object;"
      done;
      Buffer.add_string buf ")Ljava/lang/Object;";
      Buffer.contents buf
    in
    { name = Printf.sprintf "apply%d" n
    ; descriptor = desc
    ; access_flags = 0x0001 (* ACC_PUBLIC *)
    ; code = throw_body ~nargs:n
    }
  in
  assemble_class
    ~class_name:"Closure"
    ~super_name:"java/lang/Object"
    ~cp
    ~fields:[]
    ~methods:
      [ { name = "<init>"
        ; descriptor = "()V"
        ; access_flags = 0x0001
        ; code = ctor
        }
      ; make_apply 1
      ; make_apply 2
      ; make_apply 3
      ]
    ~access_flags:0x0021 (* ACC_PUBLIC | ACC_SUPER *)

let block_class_bytes () =
  let cp = Cp.create () in
  let code = Code.create cp in
  Code.set_min_locals code 3;
  (* aload_0 ; invokespecial Object.<init>()V *)
  Code.aload code 0;
  Code.invokespecial
    code
    ~class_:"java/lang/Object"
    ~method_:"<init>"
    ~descriptor:"()V";
  (* aload_0 ; iload_1 ; putfield Block.tag I *)
  Code.aload code 0;
  Code.iload code 1;
  Code.putfield code ~class_:"Block" ~field:"tag" ~descriptor:"I";
  (* aload_0 ; aload_2 ; putfield Block.fields [Ljava/lang/Object; *)
  Code.aload code 0;
  Code.aload code 2;
  Code.putfield
    code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  Code.return_void code;
  assemble_class
    ~class_name:"Block"
    ~super_name:"java/lang/Object"
    ~cp
    ~fields:
      [ { name = "tag"
        ; descriptor = "I"
        ; access_flags = 0x0011 (* ACC_PUBLIC | ACC_FINAL *)
        }
      ; { name = "fields"
        ; descriptor = "[Ljava/lang/Object;"
        ; access_flags = 0x0011
        }
      ]
    ~methods:
      [ { name = "<init>"
        ; descriptor = "(I[Ljava/lang/Object;)V"
        ; access_flags = 0x0001 (* ACC_PUBLIC *)
        ; code
        }
      ]
    ~access_flags:0x0031 (* ACC_PUBLIC | ACC_SUPER | ACC_FINAL *)

(* Wrapper [RuntimeException] whose single public field [value] carries
   the OCaml exception value. Raised by OCaml's [raise] instruction and
   caught by the JVM exception handler installed at each [PUSHTRAP]. *)
let camlexception_class_bytes () =
  let cp = Cp.create () in
  let code = Code.create cp in
  Code.set_min_locals code 2;
  (* super-ctor: aload_0; invokespecial RuntimeException.<init>()V *)
  Code.aload code 0;
  Code.invokespecial
    code
    ~class_:"java/lang/RuntimeException"
    ~method_:"<init>"
    ~descriptor:"()V";
  (* this.value = arg1 *)
  Code.aload code 0;
  Code.aload code 1;
  Code.putfield
    code
    ~class_:"CamlException"
    ~field:"value"
    ~descriptor:"Ljava/lang/Object;";
  Code.return_void code;
  assemble_class
    ~class_name:"CamlException"
    ~super_name:"java/lang/RuntimeException"
    ~cp
    ~fields:
      [ { name = "value"
        ; descriptor = "Ljava/lang/Object;"
        ; access_flags = 0x0011 (* ACC_PUBLIC | ACC_FINAL *)
        }
      ]
    ~methods:
      [ { name = "<init>"
        ; descriptor = "(Ljava/lang/Object;)V"
        ; access_flags = 0x0001
        ; code
        }
      ]
    ~access_flags:0x0031 (* ACC_PUBLIC | ACC_SUPER | ACC_FINAL *)
