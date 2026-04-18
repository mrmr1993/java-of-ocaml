(** Reader for OCaml bytecode executables. *)

type t =
  { code : int array            (** CODE section, decoded as signed int32 words *)
  ; prims : string array        (** PRIM section, null-separated primitive names *)
  ; globals : Obj.t array       (** DATA section, the marshalled globals table *)
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
  val addint : int
  val subint : int
  val mulint : int
  val divint : int
  val modint : int
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
  val offsetclosure0 : int
  val pushoffsetclosure0 : int
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
