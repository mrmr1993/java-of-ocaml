(** Link one or more [Bytecode.unit_info]s into a self-contained
    [Bytecode.t], i.e. the same shape [Bytecode.read_exe] produces
    for a full bytecode executable.

    The linker performs the job that [ocamlc -o foo.bc] does at the
    tail of its pipeline: assign slots in a shared globals table,
    intern structured-constant literals, place predefined exception
    descriptors at canonical indices, patch relocatable code words,
    and merge per-unit primitive tables into a flat [prims] array.

    Downstream (parse_bytecode, codegen) consumes the result without
    caring whether it came from [.bc] or from [.cmo]/[.cma] link. *)

val link : Bytecode.unit_info list -> Bytecode.t
(** Link the given units in declaration order. Returns a [Bytecode.t]
    whose [code] is the concatenation of each unit's patched code,
    whose [globals] holds the predefined-exception descriptors
    followed by one slot per linked compunit and one slot per
    intern'd literal, and whose [prims] is the merged primitive
    table (deduplicated). Debug events are merged with pc shifted
    to the unit's position in the combined code.

    [Reloc_getcompunit] / [Reloc_setcompunit] references to units
    not in the input list reserve a fresh "external" globals slot
    per referenced name — a partial-link model. The resulting
    [Bytecode.t] is not runnable on its own in that case (the slot
    holds [0], not a real module record); a later link step, or
    the runtime loader against pre-linked Stdlib classes, must fill
    it in.

    Raises [Failure] on an unknown [Reloc_getpredef] name (those
    are a closed set defined by [Runtimedef.builtin_exceptions]). *)
