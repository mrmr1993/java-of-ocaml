(** A builder for a JVM class-file constant pool.

    Entries are 1-indexed and interned — repeated requests for the same
    logical key return the same index. *)

type t

val create : unit -> t

val intern : t -> string -> (Buffer.t -> unit) -> int
(** Intern a pool entry under [key]. If no entry has that key yet, call [emit]
    with the pool's internal buffer to serialise the entry bytes, allocate a
    fresh 1-based index, and return it. Otherwise return the cached index.

    [key] is a logical identifier — it need not match the on-wire bytes.
    Callers prefix the key with a tag (e.g. ["U:" ^ s]) to keep different
    entry kinds separate. *)

val utf8 : t -> string -> int

val class_ : t -> string -> int
(** Internal JVM name, e.g. ["java/lang/System"]. *)

val string : t -> string -> int

val name_and_type : t -> name:string -> descriptor:string -> int

val fieldref : t -> class_:string -> field:string -> descriptor:string -> int

val methodref : t -> class_:string -> method_:string -> descriptor:string -> int

val double : t -> float -> int
(** Intern a [CONSTANT_Double_info] entry. Per the JVM spec, a double
    occupies two constant-pool slots (the second is unusable); the
    returned index is the first of the pair. *)

val count : t -> int
(** Number of interned entries. The constant-pool-count in the class file
    header is [count t + 1] (the pool itself is 1-based). *)

val contents : t -> string
(** Raw serialised bytes of all entries in allocation order. *)
