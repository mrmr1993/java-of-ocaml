(* Bytecode_compat for OCaml 5.x. Selected by dune when
   [%{ocaml_version}] is 5.x. Direct passthrough — 5.x's
   [Cmo_format.reloc_info] already uses the [Reloc_getcompunit] /
   [Reloc_getpredef] / [Reloc_setcompunit] variants we normalise to. *)

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

let compunit_name : Cmo_format.compunit -> string = function
  | Compunit s -> s

let predef_name : Cmo_format.predef -> string = function
  | Predef_exn s -> s

let reloc_of_cmo : Cmo_format.reloc_info -> reloc = function
  | Reloc_literal obj -> Reloc_literal obj
  | Reloc_getcompunit c -> Reloc_getcompunit (compunit_name c)
  | Reloc_getpredef p -> Reloc_getpredef (predef_name p)
  | Reloc_setcompunit c -> Reloc_setcompunit (compunit_name c)
  | Reloc_primitive s -> Reloc_primitive s

let normalize_cu (cu : Cmo_format.compilation_unit) : cu_header =
  { cu_name = compunit_name cu.cu_name
  ; cu_pos = cu.cu_pos
  ; cu_codesize = cu.cu_codesize
  ; cu_reloc = List.map (fun (info, off) -> reloc_of_cmo info, off) cu.cu_reloc
  ; cu_imports = cu.cu_imports
  ; cu_required = List.map compunit_name cu.cu_required_compunits
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
