open Global_view

type kind =
  | K_int
  | K_string
  | K_float
  | K_block of kind list
  | K_closure of closure_ref
  | K_obj

and closure_ref =
  { name : string
  ; captures : (int * kind) list [@warning "-69"]
  }

let rec kind_of_global_field = function
  | Gv_int _ -> K_int
  | Gv_string _ -> K_string
  | Gv_float _ -> K_float
  | Gv_int64 _ -> K_obj
  | Gv_block (_, fields) -> K_block (List.map kind_of_global_field fields)
  | Gv_null -> K_obj

let jvm_type_of_kind = function
  | K_int -> "J"
  | K_string -> "Ljava/lang/String;"
  | K_float -> "D"
  | K_block _ -> "LBlock;"
  | K_closure { name; _ } -> Printf.sprintf "L%s;" name
  | K_obj -> "Ljava/lang/Object;"

let rec string_of_kind = function
  | K_int -> "int"
  | K_string -> "string"
  | K_float -> "float"
  | K_block ks ->
    Printf.sprintf "block[%s]" (String.concat "," (List.map string_of_kind ks))
  | K_closure { name; _ } -> Printf.sprintf "closure<%s>" name
  | K_obj -> "obj"

(* [K_float] and [K_int] values occupy 2 JVM local slots (locals N
   and N+1) and 2 operand-stack slots. Callers storing them to a
   local must reserve the second slot too — see
   [State.allocate_local_for_kind]. OCaml ints back as JVM [long]
   for 63-bit range. *)
let local_slots_for_kind = function
  | K_float | K_int -> 2
  | K_string | K_block _ | K_closure _ | K_obj -> 1

let emit_store_for_kind code local kind =
  match kind with
  | K_int -> Jvm.Code.lstore code local
  | K_float -> Jvm.Code.dstore code local
  | K_string | K_block _ | K_closure _ | K_obj ->
    Jvm.Code.astore code local

let emit_load_for_kind code local kind =
  match kind with
  | K_int -> Jvm.Code.lload code local
  | K_float -> Jvm.Code.dload code local
  | K_string | K_block _ | K_closure _ | K_obj ->
    Jvm.Code.aload code local

(* OCaml [int] boxes as [java.lang.Long] now that its backing JVM
   type is [long]. This helper takes a JVM [int] on the stack (the
   historical contract — many callers push an [int] result from an
   [invokestatic] / [arraylength] / arithmetic opcode), widens it
   to [long], and boxes. Use [emit_box_long] if the top-of-stack is
   already a [long]. *)
let emit_box_int code =
  Jvm.Code.i2l code;
  Jvm.Code.invokestatic
    code
    ~class_:"java/lang/Long"
    ~method_:"valueOf"
    ~descriptor:"(J)Ljava/lang/Long;"

let emit_box_float code =
  Jvm.Code.invokestatic
    code
    ~class_:"java/lang/Double"
    ~method_:"valueOf"
    ~descriptor:"(D)Ljava/lang/Double;"

(* JVM [long] → [java.lang.Long]. Used for [Int64.t] values, which
   cross OCaml-boundary as boxed [Long]s. *)
let emit_box_long code =
  Jvm.Code.invokestatic
    code
    ~class_:"java/lang/Long"
    ~method_:"valueOf"
    ~descriptor:"(J)Ljava/lang/Long;"

(* Unbox a boxed number to a primitive [long]. Accepts both
   [java.lang.Long] (the usual Int64 representation) and
   [java.lang.Integer] (the materialisation used for custom-tag
   globals from Int32 / Nativeint / small-Int64 module-level
   constants — all three marshalled identically by the OCaml
   bytecoder). Routes through [Block.asLong] which dispatches on
   [instanceof]. *)
let emit_unbox_long code =
  Jvm.Code.invokestatic
    code
    ~class_:"Block"
    ~method_:"asLong"
    ~descriptor:"(Ljava/lang/Object;)J"

let emit_unbox_to_kind code kind =
  match kind with
  | K_int ->
    (* OCaml int unboxes as JVM long. [Block.asLong] dispatches
       across Integer / Long / other numerics; it handles both
       freshly-boxed Longs and legacy Integer constants from
       module-level globals. *)
    emit_unbox_long code
  | K_float ->
    Jvm.Code.checkcast code "java/lang/Double";
    Jvm.Code.invokevirtual
      code
      ~class_:"java/lang/Double"
      ~method_:"doubleValue"
      ~descriptor:"()D"
  | K_string -> Jvm.Code.checkcast code "java/lang/String"
  | K_block _ -> Jvm.Code.checkcast code "Block"
  | K_closure { name; _ } -> Jvm.Code.checkcast code name
  | K_obj -> ()

let box_if_int code kind =
  match kind with
  | K_int -> emit_box_int code
  | K_float -> emit_box_float code
  | _ -> ()
