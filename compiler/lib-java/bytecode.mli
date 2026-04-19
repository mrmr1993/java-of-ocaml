(** Reader for OCaml bytecode executables. *)

type debug_loc =
  { file : string      (** Source file name as recorded in the DBUG event
                           ([ev_loc.loc_start.pos_fname]). *)
  ; line : int         (** Source line number (1-based). *)
  ; modname : string   (** OCaml module name from the event. *)
  }

type t =
  { code : int array            (** CODE section, decoded as signed int32 words *)
  ; prims : string array        (** PRIM section, null-separated primitive names *)
  ; globals : Obj.t array       (** DATA section, the marshalled globals table *)
  ; debug : (int, debug_loc) Hashtbl.t
        (** DBUG section, keyed by bytecode word-pc. Empty if the executable
            was built without [-g]. Multiple events may share a pc; last
            writer wins. *)
  }

val read_exe : string -> t
(** Parse a bytecode executable file (produced by [ocamlc -o foo.bc]).
    Ignores any shebang line. *)

val prim_index : t -> string -> int option
(** Look up a primitive name in [prims]. *)

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
