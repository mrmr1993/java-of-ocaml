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

(** Opcode numbers. Only the handful we currently inspect. *)
module Op : sig
  val getglobal : int
  val pushgetglobal : int
  val c_call1 : int
  val stop : int
end
