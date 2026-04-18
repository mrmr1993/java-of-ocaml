(** The C primitives the compiler knows how to emit.

    Each entry is a [caml_*] symbol that the bytecode [C_CALL*] dispatch
    targets. The emitter's primitive-handling code matches on
    [prim_handler] to generate the right JVM sequence. *)

type prim_handler =
  | P_println_int
  | P_println_string
  | P_println_float
  | P_array_get
  | P_array_set
  | P_obj_dup
  | P_obj_tag
  | P_obj_block
  | P_obj_with_tag
  | P_fresh_oo_id
  | P_alloc_dummy
  | P_update_dummy
  | P_float_add
  | P_float_sub
  | P_float_mul
  | P_float_div
  | P_float_neg
  | P_float_abs
  | P_float_eq
  | P_float_neq
  | P_float_lt
  | P_float_le
  | P_float_gt
  | P_float_ge
  | P_int_of_float
  | P_float_of_int
  | P_array_make
  | P_array_sub
  | P_array_blit
  | P_array_fill
  | P_array_append
  | P_int_of_string
  | P_format_int
  | P_float_of_string
  | P_format_float
  | P_string_length
  | P_string_equal
  | P_string_notequal
  | P_string_compare
  | P_noop1
  | P_noop2
  | P_noop_float1
  | P_noop_null1
  | P_noop_null2
  | P_atomic_load
  | P_atomic_cas
  | P_atomic_exchange
  | P_atomic_fetch_add
  | P_int_compare
  | P_poly_compare
  | P_poly_equal
  | P_poly_notequal
  | P_poly_lessthan
  | P_poly_lessequal
  | P_poly_greaterthan
  | P_poly_greaterequal
  | P_ml_open_descriptor_out
  | P_ml_output
  | P_ml_output_char
  | P_ml_flush

type prim_entry =
  { name : string
  ; handler : prim_handler
  ; seed : bool
      (** True if this primitive is suitable as an anchor for the
          user-code range walker: it must appear only in user source,
          not in Stdlib init. [caml_fresh_oo_id] is a bad seed (every
          module with an exception calls it); the print-* / array /
          [caml_obj_dup] / [caml_{alloc,update}_dummy] primitives are
          all fine. *)
  }

val primitives : prim_entry list

type table = (int, string * prim_handler * bool) Hashtbl.t
(** Maps each primitive's [PRIM] index to [(name, handler, seed)]. *)

val find_supported_prims : Bytecode.t -> table
(** Build [table] by intersecting the bytecode's [PRIM] section with
    [primitives]. Primitives we don't know about are simply omitted. *)
