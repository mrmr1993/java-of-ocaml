module Cp = Jvm_constant_pool
module Code = Jvm_code

type method_desc = Jvm_class_file.method_desc =
  { name : string
  ; descriptor : string
  ; access_flags : int
  ; code : Code.t
  }

type field_desc = Jvm_class_file.field_desc =
  { name : string
  ; descriptor : string
  ; access_flags : int
  }

let assemble_class = Jvm_class_file.assemble_class

let assemble_main_class = Jvm_class_file.assemble_main_class

let block_class_bytes = Jvm_runtime.block_class_bytes

let closure_class_bytes = Jvm_runtime.closure_class_bytes

let partial_closure_class_bytes = Jvm_runtime.partial_closure_class_bytes

let camlexception_class_bytes = Jvm_runtime.camlexception_class_bytes

let compare_class_bytes = Jvm_runtime.compare_class_bytes
