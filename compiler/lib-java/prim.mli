(** The C primitives the compiler knows how to emit.

    Each entry is a [caml_*] symbol that the bytecode [C_CALL*] dispatch
    targets. The emitter's primitive-handling code matches on
    [prim_handler] to generate the right JVM sequence. *)

type prim_handler =
  | P_println_int
  | P_println_string
  | P_array_get
  | P_array_set
  | P_obj_dup
  | P_fresh_oo_id
  | P_alloc_dummy
  | P_update_dummy

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
