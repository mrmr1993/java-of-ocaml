(** Emitters for the C-primitive handlers + [ISINT].

    Each primitive listed in [Prim] maps to one of these entry points.
    The [Prim.prim_handler] tag picks the right emitter in
    [Emit_instr]'s C_CALL arm. *)

val emit_println : State.state -> int_arg:bool -> unit
(** [caml_java_print_int] / [caml_java_print_endline]. *)

val emit_array_get : State.state -> unit
(** [caml_array_get_addr], [caml_array_get], [caml_array_unsafe_get],
    and [GETVECTITEM] (dynamic block-field read used by [Obj.field] /
    [%obj_field]). Bounds-checking is not yet distinct from the
    unsafe variant. *)

val emit_array_set : State.state -> unit
(** [caml_array_set_addr], [caml_array_set], [caml_array_unsafe_set],
    and [SETVECTITEM]. Bounds-checking is not yet distinct from the
    unsafe variant. *)

val emit_array_make : State.state -> unit
val emit_array_sub : State.state -> unit
val emit_array_blit : State.state -> unit
val emit_array_fill : State.state -> unit
val emit_array_append : State.state -> unit

val emit_int_of_string : State.state -> unit
(** [caml_int_of_string]: parse a string as an int via
    [Integer.parseInt]. Does not yet support OCaml's "0x" / "0o" /
    "0b" base prefixes or trailing [l]/[L]/[n] suffixes — the bare
    decimal case only. *)

val emit_format_int : State.state -> unit
(** [caml_format_int]: format an int as a string. Ignores the format
    string argument and always does [Integer.toString]. Sufficient
    for ["%d"] but not ["%x"] / ["%5d"] / etc. *)

val emit_float_of_string : State.state -> unit
(** [caml_float_of_string]: parse a string as a double via
    [Double.parseDouble]. *)

val emit_format_float : State.state -> unit
(** [caml_format_float]: same simplification as [emit_format_int] —
    ignores the format string and always does [Double.toString]. *)

val emit_string_length : State.state -> unit
val emit_string_equal : State.state -> invert:bool -> unit
val emit_string_compare : State.state -> unit

val emit_noop : State.state -> nargs:int -> unit
(** Stub a C primitive as a unit-returning no-op: drops [nargs - 1]
    stack slots (plus the acc), leaves [Val_unit = 0] in acc. Used
    for Stdlib-init primitives that manage JVM-irrelevant state
    (GC, signal handlers, backtrace control). *)

val emit_noop_null : State.state -> nargs:int -> unit
(** Like [emit_noop] but returns a JVM [null] as a [K_obj] instead
    of [Val_unit] as a [K_int]. Use for stubs whose callers
    checkcast the result to a reference type (channel, block,
    closure) — a null cast succeeds, whereas a boxed [0] would
    raise [ClassCastException]. *)

val emit_atomic_load : State.state -> unit
val emit_atomic_cas : State.state -> unit
val emit_atomic_exchange : State.state -> unit
val emit_atomic_fetch_add : State.state -> unit
(** OCaml's [Atomic] refs are just [Block(0, [| value |])] at the
    runtime level. On the JVM we're single-threaded, so the
    primitives reduce to [getfield fields; aaload / aastore]. *)

val emit_int_compare : State.state -> unit
(** [caml_int_compare a b]: [Integer.compare(a, b)]. *)

val emit_poly_cmp : State.state -> method_name:string -> unit
(** Dispatch a polymorphic comparison primitive (caml_compare,
    caml_equal, ..., caml_greaterequal) to a static method on the
    [Compare] runtime class. [method_name] is the Java method:
    ["compare"], ["equal"], ["notequal"], ["lessthan"],
    ["lessequal"], ["greaterthan"], ["greaterequal"]. *)

val emit_noop_float1 : State.state -> unit
(** Stub returning [0.0] as a K_float. Used for primitives that take
    an Int32 / Int64 we can't materialise and return a double. *)

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

val emit_open_descriptor_out : State.state -> unit
(** [caml_ml_open_descriptor_out fd]: [Channel.forDescriptor(fd)]. *)

val emit_ml_output : State.state -> unit
(** [caml_ml_output(chan, buf, ofs, len)]: [chan.output(buf, ofs, len)]. *)

val emit_ml_output_char : State.state -> unit
(** [caml_ml_output_char(chan, c)]: [chan.outputChar(c)]. *)

val emit_ml_flush : State.state -> unit
(** [caml_ml_flush(chan)]: [chan.flush()]. *)

val emit_create_bytes : State.state -> unit
val emit_bytes_length : State.state -> unit
val emit_bytes_get : State.state -> unit
val emit_bytes_set : State.state -> unit
val emit_fill_bytes : State.state -> unit
val emit_blit_string_to_bytes : State.state -> unit
val emit_blit_bytes_to_bytes : State.state -> unit
val emit_bytes_of_string : State.state -> unit
val emit_string_of_bytes : State.state -> unit
val emit_bytes_equal : State.state -> invert:bool -> unit
val emit_bytes_compare : State.state -> unit
(** [Bytes] primitives: storage-class for OCaml's mutable byte
    sequence. See [Bytes.java] in [runtime-java/]. *)
