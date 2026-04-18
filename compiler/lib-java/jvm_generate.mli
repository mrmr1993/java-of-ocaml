(** Emit JVM bytecode from a [Code.program].

    This is the IR-driven counterpart to the forward-walk emitters
    under [Emit_*]. Phase 2 scope: constants, arithmetic / comparison
    primitives, branches (Branch / Cond / Return / Stop), and Assign.
    Richer features (Closure / Apply / Block allocation / Field /
    Set_field / Pushtrap / Switch / C_CALL externs) will raise
    [Unsupported] — callers can catch and fall back to the legacy
    emitter during the transition. *)

exception Unsupported of string

(** [emit_program ~code ~typing prog] emits bytecode for [prog] into
    the given [Jvm.Code.t]. *)
val emit_program :
  code:Jvm.Code.t -> typing:Jvm_typing.t -> Code.program -> unit
