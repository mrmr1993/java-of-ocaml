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

(** A builder for a method body (the bytes of a [Code] attribute). *)
module Code : sig
  type t

  val create : Cp.t -> t

  (** {2 Loads / stack manipulation} *)

  val ldc_string : t -> string -> unit

  val ldc_int : t -> int -> unit
  (** Push an [int]. Chooses the tightest of iconst_* / bipush / sipush / ldc
      depending on the value. *)

  val dup : t -> unit

  val pop_top : t -> unit
  (** Discard the top stack slot (JVM [pop], 0x57). *)

  val swap : t -> unit

  (** {2 Arithmetic (int)} *)

  val iadd : t -> unit

  val isub : t -> unit

  val imul : t -> unit

  (** {2 Static/virtual dispatch} *)

  val getstatic :
    t -> class_:string -> field:string -> descriptor:string -> unit

  val invokevirtual :
    t -> class_:string -> method_:string -> descriptor:string -> unit

  val return_void : t -> unit
end

val assemble_main_class : (Cp.t -> Code.t -> unit) -> string
(** Build a class file with a public static [main(String[])] method. The
    supplied callback receives a fresh constant pool and code builder; it
    should emit the method body (including the terminating [return_void]).
    The returned bytes are ready to write to [Main.class]. *)
