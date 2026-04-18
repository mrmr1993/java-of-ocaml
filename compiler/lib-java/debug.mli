(** Toggleable debug flags.

    Each named flag starts disabled. A flag is enabled by setting the
    [JAVA_OF_OCAML_DEBUG] environment variable to a comma-separated list of
    names (e.g. [JAVA_OF_OCAML_DEBUG=times,kinds]); reading a flag with
    [find] the first time registers it so it can be listed via [available].

    Modeled on [js_of_ocaml/compiler/lib/debug.ml]. *)

val find : string -> unit -> bool
(** [find name] returns a thunk that, when called, reports whether the flag
    [name] is currently enabled. Call this at module load time and keep the
    thunk around — the lookup happens once. *)

val enable : string -> unit

val disable : string -> unit

val available : unit -> string list
(** Names of every flag that has been registered (via [find]) so far. *)
