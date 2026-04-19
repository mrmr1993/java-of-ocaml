(** Version-agnostic view over [compiler-libs]'s [Cmo_format]. 4.14 and
    5.x changed the relocation variants ([Reloc_getglobal]/[_setglobal]
    of [Ident.t] vs [Reloc_getcompunit]/[_getpredef]/[_setcompunit] of
    string) and the [cu_required_*] field name. This shim flattens both
    into the single shape the rest of the compiler consumes. One file
    is selected at build time by [dune] based on [%{ocaml_version}]. *)

type reloc =
  | Reloc_literal of Obj.t
  | Reloc_getcompunit of string
  | Reloc_getpredef of string
  | Reloc_setcompunit of string
  | Reloc_primitive of string

type cu_header =
  { cu_name : string
  ; cu_pos : int
  ; cu_codesize : int
  ; cu_reloc : (reloc * int) list
        (** Byte offset within the compilation unit's code. The caller
            divides by 4 for word indexing. *)
  ; cu_imports : (string * Digest.t option) list
  ; cu_required : string list
  ; cu_primitives : string list
  ; cu_force_link : bool
  ; cu_debug : int
  ; cu_debugsize : int
  }

val read_compunit : in_channel -> cu_header
(** Read one compilation unit header ([input_value] on the channel, at
    the current position). Normalises the version-coupled fields. *)

val read_library : in_channel -> cu_header list
(** Read a library header ([input_value] of the [.cma] TOC) and map
    its [lib_units] to the normalised view. *)
