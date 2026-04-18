open Kind
open State

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
  (* OCaml's C_CALL1 leaves acc live with the result — for a
     unit-returning call that's Val_long(0). We mirror that so match
     arms like [| [] -> ()] (which leave acc_live = true holding 0)
     merge cleanly with arms ending in a C_CALL — otherwise the JVM
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
  | [] -> K_int
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
  | K_obj ->
    Jvm.Code.checkcast state.code "Block";
    Jvm.Code.getfield
      state.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.iload state.code idx_slot;
    Jvm.Code.aaload state.code;
    consume_top state;
    state.acc_live <- true;
    state.acc_kind <- K_obj
  | _ -> failwith "java_of_ocaml: dynamic field/array read on non-block"

(* caml_obj_tag: return the runtime tag of a value. OCaml reserves
   tag 1000 for immediates (ints); blocks return [Block.tag]; strings
   return 252; closures return 247. *)
let emit_obj_tag state =
  match state.acc_kind with
  | K_int ->
    if state.acc_live then Jvm.Code.pop_top state.code;
    Jvm.Code.ldc_int state.code 1000;
    state.acc_live <- true;
    state.acc_kind <- K_int
  | K_string ->
    if state.acc_live then Jvm.Code.pop_top state.code;
    Jvm.Code.ldc_int state.code 252;
    state.acc_live <- true;
    state.acc_kind <- K_int
  | K_float ->
    drop_live_acc state;
    Jvm.Code.ldc_int state.code 253;
    state.acc_live <- true;
    state.acc_kind <- K_int
  | K_closure _ ->
    if state.acc_live then Jvm.Code.pop_top state.code;
    Jvm.Code.ldc_int state.code 247;
    state.acc_live <- true;
    state.acc_kind <- K_int
  | K_block _ ->
    Jvm.Code.getfield state.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
    state.acc_kind <- K_int
  | K_obj ->
    let l_block = Jvm.Code.fresh_label state.code in
    let l_end = Jvm.Code.fresh_label state.code in
    Jvm.Code.dup state.code;
    Jvm.Code.instanceof_ state.code "Block";
    Jvm.Code.ifne state.code l_block;
    Jvm.Code.pop_top state.code;
    Jvm.Code.ldc_int state.code 1000;
    Jvm.Code.goto state.code l_end;
    Jvm.Code.mark_label state.code l_block;
    Jvm.Code.checkcast state.code "Block";
    Jvm.Code.getfield state.code ~class_:"Block" ~field:"tag" ~descriptor:"I";
    Jvm.Code.mark_label state.code l_end;
    state.acc_kind <- K_int

(* caml_obj_block(tag, size): allocate Block(tag, Object[size]) with
   fields pre-filled to Val_unit (Integer(0)) to match OCaml's
   behavior for scannable tags. *)
let emit_obj_block state =
  ensure_kind state K_int;
  let tag_local = allocate_local state in
  Jvm.Code.istore state.code tag_local;
  Jvm.Code.new_ state.code "Block";
  Jvm.Code.dup state.code;
  Jvm.Code.iload state.code tag_local;
  let size_slot = List.hd state.slots in
  emit_load_for_kind state.code size_slot.local size_slot.kind;
  (match size_slot.kind with
   | K_int -> ()
   | K_obj -> emit_unbox_to_kind state.code K_int
   | _ -> failwith "java_of_ocaml: caml_obj_block: size must be int");
  Jvm.Code.anewarray state.code "java/lang/Object";
  Jvm.Code.dup state.code;
  Jvm.Code.ldc_int state.code 0;
  emit_box_int state.code;
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/util/Arrays"
    ~method_:"fill"
    ~descriptor:"([Ljava/lang/Object;Ljava/lang/Object;)V";
  Jvm.Code.invokespecial
    state.code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V";
  pop_slots state 1;
  state.acc_live <- true;
  state.acc_kind <- K_obj

(* caml_obj_with_tag(tag, src): like obj_dup but with an explicit new
   tag. *)
let emit_obj_with_tag state =
  ensure_kind state K_int;
  let tag_local = allocate_local state in
  Jvm.Code.istore state.code tag_local;
  let src_slot = List.hd state.slots in
  emit_load_for_kind state.code src_slot.local src_slot.kind;
  (match src_slot.kind with
   | K_block _ -> ()
   | K_obj -> Jvm.Code.checkcast state.code "Block"
   | _ -> failwith "java_of_ocaml: caml_obj_with_tag: source must be a block");
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
  let arr_local = allocate_local state in
  Jvm.Code.astore state.code arr_local;
  Jvm.Code.new_ state.code "Block";
  Jvm.Code.dup state.code;
  Jvm.Code.iload state.code tag_local;
  Jvm.Code.aload state.code arr_local;
  Jvm.Code.invokespecial
    state.code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V";
  pop_slots state 1;
  state.acc_live <- true;
  state.acc_kind <- K_obj

(* caml_obj_dup: allocate new Block(src.tag, Arrays.copyOf(src.fields,
   src.length)). *)
let emit_obj_dup state =
  (match state.acc_kind with
   | K_block _ -> ()
   | _ -> failwith "java_of_ocaml: caml_obj_dup on non-block");
  let src_local = allocate_local state in
  Jvm.Code.astore state.code src_local;
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

(* caml_alloc_dummy n: allocate Block(0, new Object[n]) — a placeholder
   whose fields will be backfilled by a matching caml_update_dummy.
   OCaml uses this pair to build recursive values like
   [let rec a = A (b, b) and b = [|a; a; a|]]. *)
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

(* caml_update_dummy dst src: copy src's fields into dst's fields.
   OCaml's runtime also overwrites dst's tag, but our Block.tag is
   final — in practice both dst and src share tag = 0 for the
   recursive-value patterns the bytecode compiler emits (records,
   arrays), so skipping tag overwriting is fine. *)
let emit_update_dummy state =
  let src_slot = List.hd state.slots in
  Jvm.Code.checkcast state.code "Block";
  Jvm.Code.getfield
    state.code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  let dst_fields_local = allocate_local state in
  Jvm.Code.astore state.code dst_fields_local;
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

(* caml_fresh_oo_id: returns a fresh int. OCaml's runtime increments a
   process-global counter; we inline a compile-time counter, which is
   stable enough because module init — the only site that calls this —
   runs exactly once at Main.main entry. *)
let emit_fresh_oo_id state =
  let n = !(state.fresh_oo_id_counter) in
  state.fresh_oo_id_counter := n + 1;
  if state.acc_live then Jvm.Code.pop_top state.code;
  Jvm.Code.ldc_int state.code n;
  state.acc_live <- true;
  state.acc_kind <- K_int

(* Load the top OCaml-stack slot as a JVM [double], unboxing from
   [java.lang.Double] if the slot currently holds an opaque object. *)
let emit_dload_top_as_double state =
  let si = List.hd state.slots in
  emit_load_for_kind state.code si.local si.kind;
  match si.kind with
  | K_float -> ()
  | K_obj ->
    Jvm.Code.checkcast state.code "java/lang/Double";
    Jvm.Code.invokevirtual
      state.code
      ~class_:"java/lang/Double"
      ~method_:"doubleValue"
      ~descriptor:"()D"
  | _ ->
    failwith
      (Printf.sprintf
         "java_of_ocaml: float primitive on a non-float slot (%s)"
         (jvm_type_of_kind si.kind))

let emit_float_binop state op =
  ensure_kind state K_float;
  emit_dload_top_as_double state;
  op state.code;
  consume_top state;
  state.acc_live <- true;
  state.acc_kind <- K_float

let emit_float_neg state =
  ensure_kind state K_float;
  Jvm.Code.dneg state.code;
  state.acc_kind <- K_float

let emit_float_abs state =
  ensure_kind state K_float;
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/lang/Math"
    ~method_:"abs"
    ~descriptor:"(D)D";
  state.acc_kind <- K_float

(* OCaml's float comparisons return [false] on NaN for all six
   operators — so picking [dcmpg] for strict-less/less-eq and
   [dcmpl] for strict-greater/greater-eq keeps NaN from sneaking
   through as a positive answer. *)
let emit_float_cmp state ~cmp =
  ensure_kind state K_float;
  emit_dload_top_as_double state;
  let use_dcmpg =
    match cmp with
    | Lt | Le -> true
    | Gt | Ge | Eq | Ne -> false
  in
  if use_dcmpg
  then Jvm.Code.dcmpg state.code
  else Jvm.Code.dcmpl state.code;
  let lbl_true = Jvm.Code.fresh_label state.code in
  let lbl_end = Jvm.Code.fresh_label state.code in
  (match cmp with
   | Eq -> Jvm.Code.ifeq state.code lbl_true
   | Ne -> Jvm.Code.ifne state.code lbl_true
   | Lt -> Jvm.Code.iflt state.code lbl_true
   | Le -> Jvm.Code.ifle state.code lbl_true
   | Gt -> Jvm.Code.ifgt state.code lbl_true
   | Ge -> Jvm.Code.ifge state.code lbl_true);
  Jvm.Code.ldc_int state.code 0;
  Jvm.Code.goto state.code lbl_end;
  Jvm.Code.mark_label state.code lbl_true;
  Jvm.Code.ldc_int state.code 1;
  Jvm.Code.mark_label state.code lbl_end;
  consume_top state;
  state.acc_live <- true;
  state.acc_kind <- K_int

let emit_int_of_float state =
  ensure_kind state K_float;
  Jvm.Code.d2i state.code;
  state.acc_kind <- K_int

let emit_float_of_int state =
  ensure_kind state K_int;
  Jvm.Code.i2d state.code;
  state.acc_kind <- K_float

(* [caml_int_of_string s]: like [Integer.parseInt] with prefix-aware
   base detection (0x/0o/0b). Raises [Failure "int_of_string"] on
   bad input — same name as OCaml. *)
let emit_int_of_string state =
  ensure_kind state K_string;
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/lang/Integer"
    ~method_:"parseInt"
    ~descriptor:"(Ljava/lang/String;)I";
  state.acc_kind <- K_int

(* [caml_format_int fmt n]: the bytecode primitive that backs
   [string_of_int] / [Printf "%d"]. We support just the trivial
   ["%d"] case by ignoring the format string and calling
   [Integer.toString]; a general printf-format implementation would
   live here (%x, %o, padding, etc.). *)
let emit_format_int state =
  (* acc is the format string; stack[0] is the int. *)
  let n_slot = List.hd state.slots in
  (* Drop the format string — we ignore it for now. *)
  drop_live_acc state;
  emit_load_for_kind state.code n_slot.local n_slot.kind;
  (match n_slot.kind with
   | K_int -> ()
   | K_obj -> emit_unbox_to_kind state.code K_int
   | _ -> failwith "java_of_ocaml: caml_format_int: arg must be an int");
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/lang/Integer"
    ~method_:"toString"
    ~descriptor:"(I)Ljava/lang/String;";
  consume_top state;
  state.acc_live <- true;
  state.acc_kind <- K_string

let emit_float_print state =
  ensure_kind state K_float;
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/lang/Double"
    ~method_:"toString"
    ~descriptor:"(D)Ljava/lang/String;";
  Jvm.Code.getstatic
    state.code
    ~class_:"java/lang/System"
    ~field:"out"
    ~descriptor:"Ljava/io/PrintStream;";
  Jvm.Code.swap state.code;
  Jvm.Code.invokevirtual
    state.code
    ~class_:"java/io/PrintStream"
    ~method_:"println"
    ~descriptor:"(Ljava/lang/String;)V";
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_int

(* [caml_array_make(size, init)]: allocate [Block(0, Object[size])]
   and fill every slot with [init]. The result kind is [K_obj] —
   callers use it through the array primitives, which already handle
   the opaque-block shape; we intentionally don't synthesise a
   single-kind [K_block [init_kind]] because [Block]'s field-kind
   list is sized to match fixed-layout blocks, not dynamic arrays. *)
let emit_array_make state =
  ensure_kind state K_int;
  let size_local = allocate_local state in
  Jvm.Code.istore state.code size_local;
  Jvm.Code.iload state.code size_local;
  Jvm.Code.anewarray state.code "java/lang/Object";
  let fields_local = allocate_local state in
  Jvm.Code.astore state.code fields_local;
  let init_slot = List.hd state.slots in
  emit_load_for_kind state.code init_slot.local init_slot.kind;
  box_if_int state.code init_slot.kind;
  Jvm.Code.aload state.code fields_local;
  Jvm.Code.swap state.code;
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/util/Arrays"
    ~method_:"fill"
    ~descriptor:"([Ljava/lang/Object;Ljava/lang/Object;)V";
  Jvm.Code.new_ state.code "Block";
  Jvm.Code.dup state.code;
  Jvm.Code.ldc_int state.code 0;
  Jvm.Code.aload state.code fields_local;
  Jvm.Code.invokespecial
    state.code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V";
  pop_slots state 1;
  state.acc_live <- true;
  state.acc_kind <- K_obj

(* [caml_array_sub(src, ofs, len)]: new [Block(0, copyOfRange)]. *)
let emit_array_sub state =
  (match state.acc_kind with
   | K_block _ -> ()
   | K_obj -> Jvm.Code.checkcast state.code "Block"
   | _ ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: caml_array_sub on non-block (%s)"
          (jvm_type_of_kind state.acc_kind)));
  Jvm.Code.getfield
    state.code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  let ofs_slot = List.nth state.slots 0 in
  let len_slot = List.nth state.slots 1 in
  emit_load_for_kind state.code ofs_slot.local ofs_slot.kind;
  (match ofs_slot.kind with
   | K_int -> ()
   | K_obj -> emit_unbox_to_kind state.code K_int
   | _ -> failwith "java_of_ocaml: caml_array_sub: ofs must be int");
  Jvm.Code.dup state.code;
  emit_load_for_kind state.code len_slot.local len_slot.kind;
  (match len_slot.kind with
   | K_int -> ()
   | K_obj -> emit_unbox_to_kind state.code K_int
   | _ -> failwith "java_of_ocaml: caml_array_sub: len must be int");
  Jvm.Code.iadd state.code;
  (* stack: [..., fields, ofs, ofs+len] *)
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/util/Arrays"
    ~method_:"copyOfRange"
    ~descriptor:"([Ljava/lang/Object;II)[Ljava/lang/Object;";
  let copy_local = allocate_local state in
  Jvm.Code.astore state.code copy_local;
  Jvm.Code.new_ state.code "Block";
  Jvm.Code.dup state.code;
  Jvm.Code.ldc_int state.code 0;
  Jvm.Code.aload state.code copy_local;
  Jvm.Code.invokespecial
    state.code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V";
  pop_slots state 2;
  state.acc_live <- true;
  state.acc_kind <- K_obj

(* [caml_array_blit(src, sofs, dst, dofs, len)]: System.arraycopy on
   the underlying Object[]s. *)
let emit_array_blit state =
  (match state.acc_kind with
   | K_block _ -> ()
   | K_obj -> Jvm.Code.checkcast state.code "Block"
   | _ ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: caml_array_blit on non-block src (%s)"
          (jvm_type_of_kind state.acc_kind)));
  Jvm.Code.getfield
    state.code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  let sofs = List.nth state.slots 0 in
  let dst = List.nth state.slots 1 in
  let dofs = List.nth state.slots 2 in
  let len = List.nth state.slots 3 in
  emit_load_for_kind state.code sofs.local sofs.kind;
  (match sofs.kind with
   | K_int -> ()
   | K_obj -> emit_unbox_to_kind state.code K_int
   | _ -> failwith "java_of_ocaml: caml_array_blit: sofs must be int");
  emit_load_for_kind state.code dst.local dst.kind;
  (match dst.kind with
   | K_block _ -> ()
   | K_obj -> Jvm.Code.checkcast state.code "Block"
   | _ -> failwith "java_of_ocaml: caml_array_blit: dst must be a block");
  Jvm.Code.getfield
    state.code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  emit_load_for_kind state.code dofs.local dofs.kind;
  (match dofs.kind with
   | K_int -> ()
   | K_obj -> emit_unbox_to_kind state.code K_int
   | _ -> failwith "java_of_ocaml: caml_array_blit: dofs must be int");
  emit_load_for_kind state.code len.local len.kind;
  (match len.kind with
   | K_int -> ()
   | K_obj -> emit_unbox_to_kind state.code K_int
   | _ -> failwith "java_of_ocaml: caml_array_blit: len must be int");
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/lang/System"
    ~method_:"arraycopy"
    ~descriptor:"(Ljava/lang/Object;ILjava/lang/Object;II)V";
  pop_slots state 4;
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_int

(* [caml_array_fill(arr, ofs, len, v)]: Arrays.fill(arr.fields, ofs,
   ofs+len, boxed_v). *)
let emit_array_fill state =
  (match state.acc_kind with
   | K_block _ -> ()
   | K_obj -> Jvm.Code.checkcast state.code "Block"
   | _ ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: caml_array_fill on non-block (%s)"
          (jvm_type_of_kind state.acc_kind)));
  Jvm.Code.getfield
    state.code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  let ofs = List.nth state.slots 0 in
  let len = List.nth state.slots 1 in
  let v = List.nth state.slots 2 in
  emit_load_for_kind state.code ofs.local ofs.kind;
  (match ofs.kind with
   | K_int -> ()
   | K_obj -> emit_unbox_to_kind state.code K_int
   | _ -> failwith "java_of_ocaml: caml_array_fill: ofs must be int");
  Jvm.Code.dup state.code;
  emit_load_for_kind state.code len.local len.kind;
  (match len.kind with
   | K_int -> ()
   | K_obj -> emit_unbox_to_kind state.code K_int
   | _ -> failwith "java_of_ocaml: caml_array_fill: len must be int");
  Jvm.Code.iadd state.code;
  emit_load_for_kind state.code v.local v.kind;
  box_if_int state.code v.kind;
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/util/Arrays"
    ~method_:"fill"
    ~descriptor:"([Ljava/lang/Object;IILjava/lang/Object;)V";
  pop_slots state 3;
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_int

(* [caml_array_append(a, b)]: allocate a new Object[] of length
   a.length + b.length, arraycopy both halves, wrap in Block(0, _). *)
let emit_array_append state =
  (match state.acc_kind with
   | K_block _ -> ()
   | K_obj -> Jvm.Code.checkcast state.code "Block"
   | _ ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: caml_array_append left arg must be an array"));
  Jvm.Code.getfield
    state.code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  let a_local = allocate_local state in
  Jvm.Code.astore state.code a_local;
  let b = List.hd state.slots in
  emit_load_for_kind state.code b.local b.kind;
  (match b.kind with
   | K_block _ -> ()
   | K_obj -> Jvm.Code.checkcast state.code "Block"
   | _ ->
     failwith "java_of_ocaml: caml_array_append right arg must be an array");
  Jvm.Code.getfield
    state.code
    ~class_:"Block"
    ~field:"fields"
    ~descriptor:"[Ljava/lang/Object;";
  let b_local = allocate_local state in
  Jvm.Code.astore state.code b_local;
  Jvm.Code.aload state.code a_local;
  Jvm.Code.arraylength state.code;
  Jvm.Code.aload state.code b_local;
  Jvm.Code.arraylength state.code;
  Jvm.Code.iadd state.code;
  Jvm.Code.anewarray state.code "java/lang/Object";
  let out_local = allocate_local state in
  Jvm.Code.astore state.code out_local;
  (* System.arraycopy(a, 0, out, 0, a.length) *)
  Jvm.Code.aload state.code a_local;
  Jvm.Code.ldc_int state.code 0;
  Jvm.Code.aload state.code out_local;
  Jvm.Code.ldc_int state.code 0;
  Jvm.Code.aload state.code a_local;
  Jvm.Code.arraylength state.code;
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/lang/System"
    ~method_:"arraycopy"
    ~descriptor:"(Ljava/lang/Object;ILjava/lang/Object;II)V";
  (* System.arraycopy(b, 0, out, a.length, b.length) *)
  Jvm.Code.aload state.code b_local;
  Jvm.Code.ldc_int state.code 0;
  Jvm.Code.aload state.code out_local;
  Jvm.Code.aload state.code a_local;
  Jvm.Code.arraylength state.code;
  Jvm.Code.aload state.code b_local;
  Jvm.Code.arraylength state.code;
  Jvm.Code.invokestatic
    state.code
    ~class_:"java/lang/System"
    ~method_:"arraycopy"
    ~descriptor:"(Ljava/lang/Object;ILjava/lang/Object;II)V";
  Jvm.Code.new_ state.code "Block";
  Jvm.Code.dup state.code;
  Jvm.Code.ldc_int state.code 0;
  Jvm.Code.aload state.code out_local;
  Jvm.Code.invokespecial
    state.code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V";
  pop_slots state 1;
  state.acc_live <- true;
  state.acc_kind <- K_obj

(* ISINT: [acc := Val_bool(Is_long(acc))]. Used by polymorphic-variant
   match bytecode to dispatch between zero-arg cases (tagged ints) and
   data-carrying cases (blocks). *)
let emit_isint state =
  (match state.acc_kind with
   | K_int ->
     if state.acc_live then Jvm.Code.pop_top state.code;
     Jvm.Code.ldc_int state.code 1
   | K_block _ | K_closure _ | K_string ->
     if state.acc_live then Jvm.Code.pop_top state.code;
     Jvm.Code.ldc_int state.code 0
   | K_float ->
     drop_live_acc state;
     Jvm.Code.ldc_int state.code 0
   | K_obj -> Jvm.Code.instanceof_ state.code "java/lang/Integer");
  state.acc_live <- true;
  state.acc_kind <- K_int

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
   | K_obj ->
     Jvm.Code.checkcast state.code "Block";
     Jvm.Code.getfield
       state.code
       ~class_:"Block"
       ~field:"fields"
       ~descriptor:"[Ljava/lang/Object;";
     Jvm.Code.iload state.code idx_slot;
     emit_load_for_kind state.code val_slot_info.local val_slot_info.kind;
     box_if_int state.code val_slot_info.kind;
     Jvm.Code.aastore state.code
   | _ -> failwith "java_of_ocaml: dynamic field/array write on non-block");
  pop_slots state 2;
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_int
