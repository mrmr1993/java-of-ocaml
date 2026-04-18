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
  | _ -> failwith "java_of_ocaml: caml_array_get_addr on non-block"

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
   | _ -> failwith "java_of_ocaml: caml_array_set_addr on non-block");
  pop_slots state 2;
  Jvm.Code.ldc_int state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_int
