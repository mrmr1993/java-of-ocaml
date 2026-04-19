(** Emit JVM bytecode from a [Code.program].

    This is the IR-driven counterpart to the forward-walk emitters
    under [Emit_*]. Phase 2 scope: constants, arithmetic / comparison
    primitives, branches (Branch / Cond / Return / Stop), and Assign.
    Richer features (Closure / Apply / Block allocation / Field /
    Set_field / Pushtrap / Switch / C_CALL externs) will raise
    [Unsupported] — callers can catch and fall back to the legacy
    emitter during the transition. *)

exception Unsupported of string

(** [emit_program ~code ~typing ~name_of_body prog] emits bytecode
    for [prog] into the given [Jvm.Code.t].

    [name_of_body pc] resolves a bytecode PC (the body entry of a
    CLOSURE / CLOSUREREC) to the generated JVM class name for that
    closure body, so [Let (x, Closure ...)] can emit [new
    <name>(captures)]. If unknown, raise Not_found and the emitter
    will raise [Unsupported]. *)
val emit_program :
     code:Jvm.Code.t
  -> typing:Jvm_typing.t
  -> name_of_body:(int -> string)
  -> fn_info_of_body:(int -> Function_info.function_info option)
      (* Look up the enclosing-fn metadata for a CLOSURE / CLOSUREREC
         body pc so [Let (_, Closure {...})] can emit a ctor call
         whose descriptor matches the callee's actual capture-kind
         layout. *)
  -> prim_name:(int -> string)
  -> ?arg_vars:Code.Var.t list
  -> ?enclosing:Function_info.function_info * Code.Var.t
  -> Code.program
  -> unit
