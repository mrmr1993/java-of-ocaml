(** Classification of values read out of the bytecode's globals table.

    GETGLOBAL references go through [inspect_global] to decide whether to
    emit a constant int, a string literal, or a materialised [Block]. *)

type global_field_value =
  | Gv_int of int
  | Gv_string of string
  | Gv_float of float
  | Gv_block of int * global_field_value list

type global_view =
  | G_int of int
  | G_string of string
  | G_float of float
  | G_block of int * global_field_value list
  | G_unsupported

val inspect_global : Obj.t array -> int -> global_view
(** [inspect_global globals n] classifies [globals.(n)]. Out-of-bounds
    indices raise [Failure]. *)
