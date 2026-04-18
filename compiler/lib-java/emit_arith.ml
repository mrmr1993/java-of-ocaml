open Kind
open State

(* Load the top OCaml-stack slot as a JVM [int], unboxing from Integer if
   the slot currently holds an opaque Object. *)
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

let emit_binop state op =
  ensure_kind state K_int;
  emit_iload_top_as_int state;
  op state.code;
  consume_top state

let emit_addint state = emit_binop state Jvm.Code.iadd
let emit_subint state = emit_binop state Jvm.Code.isub
let emit_mulint state = emit_binop state Jvm.Code.imul
let emit_divint state = emit_binop state Jvm.Code.idiv
let emit_modint state = emit_binop state Jvm.Code.irem
let emit_andint state = emit_binop state Jvm.Code.iand
let emit_orint state = emit_binop state Jvm.Code.ior
let emit_xorint state = emit_binop state Jvm.Code.ixor
let emit_lslint state = emit_binop state Jvm.Code.ishl
let emit_lsrint state = emit_binop state Jvm.Code.iushr
let emit_asrint state = emit_binop state Jvm.Code.ishr

let emit_negint state =
  ensure_kind state K_int;
  Jvm.Code.ineg state.code

let emit_offsetint state n =
  ensure_kind state K_int;
  Jvm.Code.ldc_int state.code n;
  Jvm.Code.iadd state.code
