(** Emitters for the APPLY / APPTERM / RETURN / PUSH_RETADDR family. *)

val apply_descriptor_for_nargs : int -> string
(** [(Ljava/lang/Object;)...(Ljava/lang/Object;)Ljava/lang/Object;] for
    [nargs] arg slots. Used by both [emit_apply_invoke] and the
    per-function closure-class emitter in the compile driver. *)

val emit_apply_invoke : State.state -> nargs:int -> unit
(** Low-level: emit the [invokevirtual Closure.apply<nargs>] plus all
    the arg loading / boxing. Leaves the result on the JVM op stack as
    an [Object]; does not apply any [ensure_kind] to the result. *)

val emit_apply : State.state -> nargs:int -> unit
(** Full [APPLY n]: invoke, then pick the result's kind from the
    callee's inferred [return_kind] (or [K_obj] if unknown / if the
    call is under-supplied) and emit the matching unbox. *)

val emit_apply1 : State.state -> unit
(** [APPLY 1]. *)

val emit_push_retaddr : State.state -> unit

val emit_appterm : State.state -> nargs:int -> unit

val emit_return : State.state -> unit
