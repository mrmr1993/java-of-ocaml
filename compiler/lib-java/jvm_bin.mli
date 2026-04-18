(** Big-endian integer writers for the JVM class-file format. *)

val add_u1 : Buffer.t -> int -> unit

val add_u2 : Buffer.t -> int -> unit

val add_u4 : Buffer.t -> int -> unit
