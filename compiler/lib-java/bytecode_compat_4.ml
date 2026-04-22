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

(* Translate a [Lambda.structured_constant] into the live OCaml value
   it denotes. Mirrors [Symtable.transl_const] from the OCaml
   compiler; the 4.x [Reloc_literal] is a [structured_constant] AST,
   not an already-computed [Obj.t], so we have to evaluate it to get
   the object the runtime would see. Without this an [Int64] literal
   (say [0x7FF0...L]) is stored as the AST [Const_base(Const_int64 n)]
   — a regular [Block(0, [Block(5, [Int64])])] — instead of as the
   custom-tag block that [caml_int64_float_of_bits] expects, and
   [Block.asLong] throws at runtime. *)
let rec transl_const : Lambda.structured_constant -> Obj.t = function
  | Const_base (Const_int i) -> Obj.repr i
  | Const_base (Const_char c) -> Obj.repr c
  | Const_base (Const_string (s, _, _)) -> Obj.repr s
  | Const_base (Const_float f) -> Obj.repr (float_of_string f)
  | Const_base (Const_int32 i) -> Obj.repr i
  | Const_base (Const_int64 i) -> Obj.repr i
  | Const_base (Const_nativeint i) -> Obj.repr i
  | Const_immstring s -> Obj.repr s
  | Const_block (tag, fields) ->
    let n = List.length fields in
    let blk = Obj.new_block tag n in
    List.iteri (fun i c -> Obj.set_field blk i (transl_const c)) fields;
    blk
  | Const_float_array fields ->
    let res = Array.Floatarray.create (List.length fields) in
    List.iteri (fun i f -> Array.Floatarray.set res i (float_of_string f)) fields;
    Obj.repr res

let reloc_of_cmo : Cmo_format.reloc_info -> reloc = function
  | Reloc_literal sc -> Reloc_literal (transl_const sc)
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
