(** Emission of user-facing Java facade classes for OCaml modules.

    Step 3 of [docs/JAVA_FACADE.md §8]: produces thin static-method
    wrappers that dispatch to [Main.GLOBALS] + [Closure.applyN]
    behind a one-shot init guard. Bindings with unsupported type
    shapes are currently skipped with a warning; subsequent steps
    widen coverage. *)

type export =
  { outer : string       (** Outer OCaml module name, matches a
                             [Bytecode.Unit.t].modname. *)
  ; sub_path : string list
        (** Dotted submodule path from [outer] to the target. Empty
            list means [outer] itself is the target. *)
  ; fqcn : string        (** Target fully-qualified Java class
                             name, either dotted or slash form. *)
  }

type facade_class =
  { jvm_name : string    (** Internal JVM name, e.g.
                             [com/example/Int64Utils]. *)
  ; bytes : string
  }

val emit :
     parsed:Bytecode.t
  -> cmi_paths:string list
  -> exports:export list
  -> facade_class list
(** [emit ~parsed ~cmi_paths ~exports] resolves each OCaml module's
    global-array index from the linked bytecode, reads its
    corresponding [.cmi] off the search path, and assembles one
    facade class per export. Unsupported bindings emit a warning
    to stderr and are skipped. Raises [Failure] if a module's
    [.cmi] is missing or if its global-array index cannot be
    recovered from the bytecode. *)
