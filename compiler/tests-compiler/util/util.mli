module Filetype : Filetype_intf.S

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
