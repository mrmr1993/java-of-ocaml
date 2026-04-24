(** Reader for OCaml bytecode executables. *)

type debug_loc =
  { file : string      (** Source file name as recorded in the DBUG event
                           ([ev_loc.loc_start.pos_fname]). *)
  ; line : int         (** Source line number (1-based). *)
  ; line_end : int     (** End line of the source location (1-based). *)
  ; col_start : int    (** Starting column, 0-based (pos_cnum - pos_bol). *)
  ; col_end : int      (** Ending column, 0-based. *)
  ; modname : string   (** OCaml module name from the event. *)
  ; defname : string option
        (** Enclosing-definition name from [ev_defname] ([None] if empty,
            e.g. for stripped/old bytecode). *)
  }

(** One contiguous range of the main-init bytecode that corresponds
    to a single OCaml compilation unit (i.e. one [.cmo]'s init
    code). Ranges are disjoint and ordered by [start_pc]. *)
module Unit : sig
  type t =
    { modname : string   (** OCaml module name (from DBUG or the [.cmo]'s
                             [cu_name]). May be [""] only in degraded cases. *)
    ; start_pc : int     (** Inclusive, word-pc into [code]. *)
    ; end_pc : int       (** Exclusive. *)
    }
end

type t =
  { code : int array            (** CODE section, decoded as signed int32 words *)
  ; prims : string array        (** PRIM section, null-separated primitive names *)
  ; globals : Obj.t array       (** DATA section, the marshalled globals table *)
  ; debug : (int, debug_loc) Hashtbl.t
        (** DBUG section, keyed by bytecode word-pc. Empty if the executable
            was built without [-g]. Multiple events may share a pc; last
            writer wins. *)
  ; units : Unit.t list
        (** Per-compilation-unit PC ranges covering the main-init
            region, in link order. Derived from DBUG for executables
            (one range per list, [orig] determining [start_pc]) and
            from the unit list for the linker path. Empty when no
            unit-level information is recoverable (e.g. [.bc] built
            without [-g] and not produced by our [Linker.link]). *)
  }

val read_exe : string -> t
(** Parse a bytecode executable file (produced by [ocamlc -o foo.bc]).
    Ignores any shebang line. *)

val prim_index : t -> string -> int option
(** Look up a primitive name in [prims]. *)

(** Per-unit information extracted from a [.cmo] or one member of
    a [.cma]. Matches [Cmo_format.compilation_unit] but with the
    code bytes already decoded into word-granularity ints, and
    debug events indexed by word-pc. *)

type reloc =
  | Reloc_literal of Obj.t       (** Structured constant referenced from code;
                                     the linker interns it into the globals
                                     table and patches the code word with its
                                     global index. *)
  | Reloc_getcompunit of string  (** Read the named unit's global. *)
  | Reloc_getpredef of string    (** Read a predefined exception descriptor. *)
  | Reloc_setcompunit of string  (** Write this unit's global (once). *)
  | Reloc_primitive of string    (** C primitive reference; patched to the
                                     linker-assigned index in the merged
                                     [prims] table. *)

type unit_info =
  { cu_name : string
  ; cu_code : int array
        (** Word-decoded code. Relocation placeholders are still in
            place; the linker must patch them before the code is
            runnable. *)
  ; cu_prims : string array
        (** Primitives the unit declares and references. *)
  ; cu_reloc : (reloc * int) list
        (** Offsets are in words (i.e. into [cu_code]). The original
            [Cmo_format.compilation_unit.cu_reloc] offsets are in
            bytes; [read_cmo]/[read_cma] divide them by 4. *)
  ; cu_imports : (string * Digest.t option) list
        (** Interface CRCs the unit was compiled against. Used for
            link-time consistency checks. *)
  ; cu_required : string list
        (** Other units whose side-effecting initialisation must run
            before this one's. *)
  ; cu_force_link : bool
  ; cu_debug : (int, debug_loc) Hashtbl.t
        (** Debug events keyed by word-pc within this unit. *)
  }

val read_cmo : string -> unit_info
(** Parse a [.cmo] file (produced by [ocamlc -c]). *)

val read_cma : string -> unit_info list
(** Parse a [.cma] library. Returns the units in link order. *)

type channel_contents =
  | Exe of t
  | Cmo of unit_info
  | Cma of unit_info list

val read_file : string -> channel_contents
(** Magic-number-dispatched reader. Accepts an executable, [.cmo],
    or [.cma]. *)

(** Opcode numbers. Extend as new tests demand. *)
module Op : sig
  val acc0 : int
  val acc1 : int
  val acc2 : int
  val acc3 : int
  val acc4 : int
  val acc5 : int
  val acc6 : int
  val acc7 : int
  val acc : int
  val push : int
  val push_retaddr : int
  val assign : int
  val pushacc0 : int
  val pushacc1 : int
  val pushacc2 : int
  val pushacc3 : int
  val pushacc4 : int
  val pushacc5 : int
  val pushacc6 : int
  val pushacc7 : int
  val pushacc : int
  val pop : int
  val getglobal : int
  val pushgetglobal : int
  val getglobalfield : int
  val pushgetglobalfield : int
  val c_call1 : int
  val const0 : int
  val const1 : int
  val const2 : int
  val const3 : int
  val constint : int
  val pushconst0 : int
  val pushconst1 : int
  val pushconst2 : int
  val pushconst3 : int
  val pushconstint : int
  val negint : int
  val addint : int
  val subint : int
  val mulint : int
  val divint : int
  val modint : int
  val andint : int
  val orint : int
  val xorint : int
  val lslint : int
  val lsrint : int
  val asrint : int
  val eq : int
  val neq : int
  val ltint : int
  val leint : int
  val gtint : int
  val geint : int
  val offsetint : int
  val offsetref : int
  val makeblock : int
  val makeblock1 : int
  val makeblock2 : int
  val makeblock3 : int
  val getfield0 : int
  val getfield1 : int
  val getfield2 : int
  val getfield3 : int
  val getfield : int
  val setfield0 : int
  val setfield1 : int
  val setfield2 : int
  val setfield3 : int
  val setfield : int
  val vectlength : int
  val getvectitem : int
  val setvectitem : int
  val getbyteschar : int
  val setbyteschar : int
  val getstringchar : int
  val makefloatblock : int
  val getfloatfield : int
  val setfloatfield : int
  val setglobal : int
  val atom0 : int
  val atom : int
  val pushatom0 : int
  val pushatom : int
  val ultint : int
  val ugeint : int
  val bultint : int
  val bugeint : int
  val c_calln : int
  val getmethod : int
  val getpubmet : int
  val getdynmet : int
  val perform : int
  val resume : int
  val resumeterm : int
  val reperformterm : int
  val branch : int
  val branchif : int
  val branchifnot : int
  val switch : int
  val boolnot : int
  val pushtrap : int
  val poptrap : int
  val raise_ : int
  val isint : int
  val reraise : int
  val raise_notrace : int
  val stop : int
  val apply : int
  val apply1 : int
  val apply2 : int
  val apply3 : int
  val appterm : int
  val appterm1 : int
  val appterm2 : int
  val appterm3 : int
  val return : int
  val restart : int
  val grab : int
  val closure : int
  val closurerec : int
  val offsetclosurem3 : int
  val offsetclosure0 : int
  val offsetclosure3 : int
  val offsetclosure : int
  val pushoffsetclosurem3 : int
  val pushoffsetclosure0 : int
  val pushoffsetclosure3 : int
  val pushoffsetclosure : int
  val envacc1 : int
  val envacc2 : int
  val envacc3 : int
  val envacc4 : int
  val envacc : int
  val pushenvacc1 : int
  val pushenvacc2 : int
  val pushenvacc3 : int
  val pushenvacc4 : int
  val pushenvacc : int
  val event : int
  val break : int
end

val instr_size : t -> int -> int
(** Given a pc inside [t.code], return the number of words this instruction
    occupies (including the opcode). Raises [Failure] on unsupported
    variable-length opcodes (SWITCH, CLOSUREREC). *)

val opcode_name : int -> string
(** Human-readable name for an opcode; useful for error messages. *)
