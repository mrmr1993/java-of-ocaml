open Global_view

type kind =
  | K_int
  | K_string
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
  | Gv_block (_, fields) -> K_block (List.map kind_of_global_field fields)

let jvm_type_of_kind = function
  | K_int -> "I"
  | K_string -> "Ljava/lang/String;"
  | K_block _ -> "LBlock;"
  | K_closure { name; _ } -> Printf.sprintf "L%s;" name
  | K_obj -> "Ljava/lang/Object;"

let emit_store_for_kind code local kind =
  match kind with
  | K_int -> Jvm.Code.istore code local
  | K_string | K_block _ | K_closure _ | K_obj ->
    Jvm.Code.astore code local

let emit_load_for_kind code local kind =
  match kind with
  | K_int -> Jvm.Code.iload code local
  | K_string | K_block _ | K_closure _ | K_obj ->
    Jvm.Code.aload code local

let emit_box_int code =
  Jvm.Code.invokestatic
    code
    ~class_:"java/lang/Integer"
    ~method_:"valueOf"
    ~descriptor:"(I)Ljava/lang/Integer;"

let emit_unbox_to_kind code kind =
  match kind with
  | K_int ->
    Jvm.Code.checkcast code "java/lang/Integer";
    Jvm.Code.invokevirtual
      code
      ~class_:"java/lang/Integer"
      ~method_:"intValue"
      ~descriptor:"()I"
  | K_string -> Jvm.Code.checkcast code "java/lang/String"
  | K_block _ -> Jvm.Code.checkcast code "Block"
  | K_closure { name; _ } -> Jvm.Code.checkcast code name
  | K_obj -> ()

let box_if_int code kind =
  match kind with
  | K_int -> emit_box_int code
  | _ -> ()
