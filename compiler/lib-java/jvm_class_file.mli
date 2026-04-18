(** Assemble method layouts + a constant pool into class-file bytes. *)

type method_desc =
  { name : string
  ; descriptor : string
  ; access_flags : int
  ; code : Jvm_code.t
  }

type field_desc =
  { name : string
  ; descriptor : string
  ; access_flags : int
  }

val assemble_class :
  class_name:string
  -> super_name:string
  -> cp:Jvm_constant_pool.t
  -> fields:field_desc list
  -> methods:method_desc list
  -> access_flags:int
  -> string
(** Emit the bytes of a class file. All methods must share [cp]. *)

val assemble_main_class : (Jvm_constant_pool.t -> Jvm_code.t -> unit) -> string
(** Convenience wrapper over [assemble_class] for a single-method [Main] class
    whose public static [main(String[])V] body is produced by the callback. *)
