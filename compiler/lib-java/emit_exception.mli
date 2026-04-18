(** Emission of OCaml exception machinery.

    [raise] / [try ... with] / [reraise] / [raise_notrace] all sit on top
    of the same JVM primitives: wrap the OCaml exception value in a
    [CamlException] (subclass of [RuntimeException]), [athrow] it, and
    at [PUSHTRAP] install an exception-table entry whose handler unwraps
    the caught carrier back into an OCaml-level value. *)

val emit_raise : State.state -> unit

val emit_pushtrap : State.state -> Instr.instr -> unit
(** Open a try region whose handler lives at the PC encoded in [ins].
    Records a pending handler-prelude label that [emit_instr] will
    mark + unwrap once the handler PC is reached. *)

val emit_poptrap : State.state -> unit
(** Close the innermost open trap. Installs the JVM exception-table
    entry spanning [start_lbl .. end_lbl] → handler prelude. *)
