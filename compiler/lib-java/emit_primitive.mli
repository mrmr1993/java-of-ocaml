(** Emitters for the C-primitive handlers + [ISINT].

    Each primitive listed in [Prim] maps to one of these entry points.
    The [Prim.prim_handler] tag picks the right emitter in
    [Emit_instr]'s C_CALL arm. *)

val emit_println : State.state -> int_arg:bool -> unit
(** [caml_java_print_int] / [caml_java_print_endline]. *)

val emit_array_get : State.state -> unit
(** [caml_array_get_addr], and [GETVECTITEM] (dynamic block-field read
    used by [Obj.field] / [%obj_field]). *)

val emit_array_set : State.state -> unit
(** [caml_array_set_addr], and [SETVECTITEM] (dynamic block-field
    write used by [Obj.set_field] / [%obj_set_field]). *)

val emit_obj_dup : State.state -> unit
val emit_obj_tag : State.state -> unit
val emit_obj_block : State.state -> unit
val emit_obj_with_tag : State.state -> unit
val emit_alloc_dummy : State.state -> unit
val emit_update_dummy : State.state -> unit
val emit_fresh_oo_id : State.state -> unit

val emit_isint : State.state -> unit
(** Not a C primitive but the sibling [ISINT] bytecode; shares the
    Integer-vs-Block dispatch idiom used by the array / obj
    primitives. *)

val emit_float_binop : State.state -> (Jvm.Code.t -> unit) -> unit
(** Binary float op: [acc := acc <op> stack[0]]. The JVM callback
    should be one of [dadd] / [dsub] / [dmul] / [ddiv]. *)

val emit_float_neg : State.state -> unit
val emit_float_abs : State.state -> unit

val emit_float_cmp : State.state -> cmp:State.cmp_op -> unit
(** Float comparison, NaN-safe per OCaml semantics (NaN → false). *)

val emit_int_of_float : State.state -> unit
val emit_float_of_int : State.state -> unit

val emit_float_print : State.state -> unit
(** Test-only [caml_java_print_float] — prints the double via
    [Double.toString] + [System.out.println]. *)
