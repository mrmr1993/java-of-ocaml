(** JVM class-file emission.

    Phase 0 only supports what we need to produce a [Main] class whose static
    [main] method runs a straight-line sequence of [System.out.println(String)]
    calls. The API is intentionally narrow; extend as new tests demand. *)

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

  val getstatic :
    t -> class_:string -> field:string -> descriptor:string -> unit

  val ldc_string : t -> string -> unit

  val invokevirtual :
    t -> class_:string -> method_:string -> descriptor:string -> unit

  val return_void : t -> unit
end

val emit_main_class : messages:string list -> string
(** Return the bytes of a [.class] file defining class [Main] with a
    [public static void main(String[])] method that calls
    [System.out.println(m)] for each [m] in [messages], then returns. *)
