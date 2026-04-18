(** Compile-time kinds: what JVM runtime shape each OCaml value has.

    Tracked per OCaml-stack slot and per accumulator. When a value of
    unknown kind ([K_obj]) is used in a context demanding a specific
    kind, the emitter inserts a [checkcast] and any required
    [Integer.intValue()] unboxing via [ensure_kind] (defined on [state]
    in the main driver). *)

type kind =
  | K_int
  | K_string
  | K_block of kind list
  | K_closure of closure_ref
  | K_obj

and closure_ref =
  { name : string
      (** Generated JVM class name of the closure (e.g. ["ocaml_fn_0"]). *)
  ; captures : (int * kind) list
      (** Legacy field. Each capture's (JVM local at closure-creation
          site, kind). Captures now flow through instance fields on
          [this], so this list is normally empty — retained for back-
          compatibility with earlier code paths. *)
  }

val kind_of_global_field : Global_view.global_field_value -> kind

val jvm_type_of_kind : kind -> string
(** JVM descriptor (["I"], ["Ljava/lang/String;"], ...) for each kind. *)

val string_of_kind : kind -> string
(** Short, human-readable tag: ["int"] / ["string"] / ["block[…]"] /
    ["closure<name>"] / ["obj"]. For diagnostic tracing; not stable
    enough to switch on. *)

val emit_store_for_kind : Jvm.Code.t -> int -> kind -> unit

val emit_load_for_kind : Jvm.Code.t -> int -> kind -> unit

val emit_box_int : Jvm.Code.t -> unit
(** [Integer.valueOf(int) : Integer]. *)

val emit_unbox_to_kind : Jvm.Code.t -> kind -> unit
(** If the top-of-stack is an [Object], unbox / checkcast it in place to
    the concrete [kind]. *)

val box_if_int : Jvm.Code.t -> kind -> unit
(** [emit_box_int] when [kind = K_int]; a no-op otherwise. *)
