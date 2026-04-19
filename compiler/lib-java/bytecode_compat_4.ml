(* Bytecode_compat for OCaml 4.14. Selected by dune when
   [%{ocaml_version}] is in the 4.x range.

   Differences from 5.x that this shim smooths over:
   - [Cmo_format.reloc_info] uses [Reloc_getglobal of Ident.t] and
     [Reloc_setglobal of Ident.t] where 5.x splits predefined
     exceptions out into a dedicated [Reloc_getpredef of compunit].
     We classify via [Ident.is_predef].
   - [Cmo_format.compilation_unit] stores dependencies as
     [cu_required_globals : Ident.t list] instead of 5.x's
     [cu_required_compunits : compunit_name list].
   - [cu_name] is a raw [string] here, not a [compunit] wrapper. *)

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
  ; cu_imports : (string * Digest.t option) list
  ; cu_required : string list
  ; cu_primitives : string list
  ; cu_force_link : bool
  ; cu_debug : int
  ; cu_debugsize : int
  }

let reloc_of_cmo : Cmo_format.reloc_info -> reloc = function
  | Reloc_literal obj -> Reloc_literal (Obj.repr obj)
  | Reloc_getglobal id ->
    let name = Ident.name id in
    if Ident.is_predef id then Reloc_getpredef name else Reloc_getcompunit name
  | Reloc_setglobal id ->
    (* Predefined exceptions never get [setglobal] — only user
       modules produce this at the end of their init code. *)
    Reloc_setcompunit (Ident.name id)
  | Reloc_primitive s -> Reloc_primitive s

let normalize_cu (cu : Cmo_format.compilation_unit) : cu_header =
  { cu_name = cu.cu_name
  ; cu_pos = cu.cu_pos
  ; cu_codesize = cu.cu_codesize
  ; cu_reloc = List.map (fun (info, off) -> reloc_of_cmo info, off) cu.cu_reloc
  ; cu_imports = cu.cu_imports
  ; cu_required = List.map Ident.name cu.cu_required_globals
  ; cu_primitives = cu.cu_primitives
  ; cu_force_link = cu.cu_force_link
  ; cu_debug = cu.cu_debug
  ; cu_debugsize = cu.cu_debugsize
  }

let read_compunit ic : cu_header =
  let cu : Cmo_format.compilation_unit = input_value ic in
  normalize_cu cu

let read_library ic : cu_header list =
  let lib : Cmo_format.library = input_value ic in
  List.map normalize_cu lib.lib_units
