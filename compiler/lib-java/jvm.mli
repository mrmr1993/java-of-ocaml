(** JVM class-file emission.

    The API is intentionally narrow: extend it as new tests demand. Method
    bodies are built by calling the [Code] ops in program order, and the
    builder tracks [max_stack] from the cumulative effects. Straight-line
    code only — no branches or exception handlers yet. *)

(** A builder for the class-file constant pool. *)
module Cp : sig
  type t

  val create : unit -> t

  val utf8 : t -> string -> int

  val class_ : t -> string -> int
  (** Internal JVM name, e.g. ["java/lang/System"]. *)

  val string : t -> string -> int

  val fieldref :
    t -> class_:string -> field:string -> descriptor:string -> int

  val methodref :
    t -> class_:string -> method_:string -> descriptor:string -> int
end

(** A builder for a method body (the bytes of a [Code] attribute).

    {b Branching note:} classes are emitted with Java major version 50
    (Java 6), which permits type-inference verification. That lets us emit
    branching code without generating [StackMapTable] attributes. When we
    move on to ranges/switches heavy enough to want the type-checker's
    guarantees, we'll bump the major version and add frame emission. *)
module Code : sig
  type t

  (** Opaque forward-reference labels. Create with [fresh_label]; emit
      references to them with any of the branch ops; pin to the current
      position with [mark_label]. *)
  type label

  val create : Cp.t -> t

  val fresh_label : t -> label

  val mark_label : t -> label -> unit

  val set_min_locals : t -> int -> unit
  (** Ensure [max_locals] is at least [n]. Used to reserve slots for
      method parameters that the body may not touch directly. *)

  (** {2 Loads / stack manipulation} *)

  val ldc_string : t -> string -> unit

  val ldc_int : t -> int -> unit
  (** Push an [int]. Chooses the tightest of iconst_* / bipush / sipush / ldc
      depending on the value. *)

  val dup : t -> unit

  val dup2 : t -> unit

  val pop_top : t -> unit
  (** Discard the top stack slot (JVM [pop], 0x57). *)

  val swap : t -> unit

  (** {2 Integer locals}

      [istore]/[iload] operate on a JVM local variable slot by index. The
      builder automatically tracks [max_locals] so the enclosing class file
      declares enough space. *)

  val istore : t -> int -> unit

  val iload : t -> int -> unit

  val astore : t -> int -> unit

  val aload : t -> int -> unit

  val newarray_int : t -> unit

  val iaload : t -> unit

  val iastore : t -> unit

  val arraylength : t -> unit

  (** {2 Arithmetic (int)} *)

  val iadd : t -> unit

  val isub : t -> unit

  val imul : t -> unit

  val idiv : t -> unit

  val irem : t -> unit

  (** {2 Branches}

      All variants of [if_icmp<cond>] compare two ints. The semantics follow
      the JVM spec: the comparison is [value1 <cond> value2], where
      [value1] was pushed first (sits below) and [value2] is the current
      top. Branch if the comparison is true. *)

  val if_icmpeq : t -> label -> unit
  val if_icmpne : t -> label -> unit
  val if_icmplt : t -> label -> unit
  val if_icmple : t -> label -> unit
  val if_icmpgt : t -> label -> unit
  val if_icmpge : t -> label -> unit

  val goto : t -> label -> unit

  (** {2 Static/virtual dispatch} *)

  val getstatic :
    t -> class_:string -> field:string -> descriptor:string -> unit

  val invokevirtual :
    t -> class_:string -> method_:string -> descriptor:string -> unit

  val invokestatic :
    t -> class_:string -> method_:string -> descriptor:string -> unit

  val return_void : t -> unit

  val ireturn : t -> unit
end

(** A method definition: its name, JVM descriptor, access flags, and body. *)
type method_desc =
  { name : string
  ; descriptor : string
  ; access_flags : int
  ; code : Code.t
  }

val assemble_class :
  class_name:string -> cp:Cp.t -> methods:method_desc list -> string
(** Build a class file containing the given methods. All methods share the
    supplied constant pool. The returned bytes are ready to write to
    [<class_name>.class]. *)

val assemble_main_class : (Cp.t -> Code.t -> unit) -> string
(** Convenience wrapper over {!assemble_class} for a single-method [Main]
    class whose public static [main(String[])V] body is produced by the
    callback. *)
