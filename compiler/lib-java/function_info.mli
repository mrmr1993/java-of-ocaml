(** Per-OCaml-function metadata, collected during the pre-scan pass.

    Each OCaml function in the source bytecode becomes one JVM class that
    extends [Closure]; [function_info] records everything the emitter
    needs to generate that class and to resolve references to it from
    CLOSURE / CLOSUREREC / OFFSETCLOSURE / APPLY sites. *)

open Kind

type function_info =
  { name : string
      (** Generated JVM class name. *)
  ; closurerec_pc : int [@warning "-69"]
      (** The PC of the CLOSUREREC (or CLOSURE) that allocates this
          function's closure. *)
  ; body_pc : int
  ; body_start_idx : int
  ; body_end_idx : int
  ; nargs : int
  ; ncaps : int [@warning "-69"]
  ; return_kind : kind ref
      (** Filled by [infer_return_kind]; defaults to [K_obj]. *)
  ; arg_kinds : kind list ref
      (** Filled by [infer_arg_kinds]; element [i] is the kind of source
          argument [i]. Defaults to [K_int]. *)
  ; capture_kinds : kind list ref
      (** Populated when the closure-creation site is emitted;
          determines the capture-typed instance field descriptors. *)
  ; recursive : bool [@warning "-69"]
  ; group_idx : int [@warning "-69"]
      (** Position within a CLOSUREREC group; 0 for singleton CLOSURE. *)
  ; mutable group : function_info array
      (** All siblings in this CLOSUREREC group, indexed by
          [group_idx]. One-element array for singletons. Populated
          after all group members are registered. *)
  }

module Int_set : Set.S with type elt = int

val find_function_body_range
  :  Instr.instr array
  -> ?pc_upper_bound:int
  -> int
  -> int * int * int
(** [find_function_body_range arr body_pc] locates the function whose
    body begins at bytecode [body_pc] and returns its
    [(body_start_idx, body_end_idx, nargs)] in [arr]. The start index
    skips a leading RESTART / GRAB entry sequence; [nargs] is decoded
    from the GRAB if present, or [1] otherwise.

    [pc_upper_bound] caps the walk: an instruction at that PC or
    beyond is treated as outside this function's body. Useful when
    the next sibling function's [body_pc] is known, since OCaml's
    bytecode sometimes has forward branch targets that point past
    the natural terminator and would otherwise lead the walker to
    keep consuming sibling bodies. *)
