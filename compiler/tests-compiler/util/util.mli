val measure_extern_cost :
     ?prefix_extras:Java_of_ocaml_compiler.Code.prim_arg list
  -> ?extras:Java_of_ocaml_compiler.Code.prim_arg list
  -> nargs:int
  -> string
  -> (int * int, string) result
(** [measure_extern_cost ~nargs name] builds a minimal
    [Code.program] that invokes the extern [name] with [nargs]
    [Pv] args (plus any [Pc] [prefix_extras] before and [extras]
    after), emits it via [Jvm_generate], and returns [Ok (ideal,
    actual)] where [ideal] is what [Code_cost.program] would
    produce if the table were applied end-to-end and [actual] is
    the emitted byte count. [Error msg] if the emitter bails. *)

module Filetype : Filetype_intf.S

(** Absolute path to the repo's [_build/default] root — used by tests
    to locate sibling build artefacts (e.g. the [ppx_java] executable
    for FFI-sugar tests). *)
val java_of_ocaml_root : string

val with_temp_dir : f:(unit -> 'a) -> 'a

val compile_ocaml_to_cmo : ?debug:bool -> Filetype.ocaml_file -> Filetype.cmo_file

val compile_ocaml_to_bc :
     ?debug:bool
  -> ?unix:bool
  -> ?ocaml_flags:string list
  -> Filetype.ocaml_file
  -> Filetype.bc_file

val compile_lib : Filetype.cmo_file list -> string -> Filetype.cmo_file

val compile_bc_to_class :
  ?flags:string list -> Filetype.bc_file -> Filetype.class_file

val compile_cmo_to_class :
  ?flags:string list -> Filetype.cmo_file -> Filetype.class_file

val run_java : ?classpath:string list -> Filetype.class_file -> string

val run_bytecode : Filetype.bc_file -> string

val compile_and_run :
     ?flags:string list
  -> ?ocaml_flags:string list
  -> ?debug:bool
  -> ?unix:bool
  -> string
  -> unit

val compile_and_run_bytecode : ?unix:bool -> string -> unit

val normalize_path : string -> string

val compile_and_javap :
     ?flags:string list
  -> ?ocaml_flags:string list
  -> ?debug:bool
  -> ?unix:bool
  -> string
  -> unit
(** Compile [s] through to [Main.class], then [javap -c] the result and
    print the listing. Designed for ppx_expect snapshot tests that pin
    the emitted JVM bytecode of a representative program, so that
    emission regressions show up as a diff even when the program's
    stdout is unchanged. *)

val compile_and_javap_lines :
     ?flags:string list
  -> ?ocaml_flags:string list
  -> ?debug:bool
  -> ?unix:bool
  -> string
  -> unit
(** Compile [s] through to [Main.class], then [javap -l] the result
    and print the listing (includes [SourceFile] and per-method
    [LineNumberTable] info). Used for source-map snapshots. *)
