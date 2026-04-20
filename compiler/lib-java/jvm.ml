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

let dummy_closure_class_bytes = Jvm_runtime.dummy_closure_class_bytes

let camlexception_class_bytes = Jvm_runtime.camlexception_class_bytes

let compare_class_bytes = Jvm_runtime.compare_class_bytes

let channel_class_bytes = Jvm_runtime.channel_class_bytes

let bytes_class_bytes = Jvm_runtime.bytes_class_bytes

let format_class_bytes = Jvm_runtime.format_class_bytes

let ephemeron_class_bytes = Jvm_runtime.ephemeron_class_bytes

let java_ffi_class_bytes = Jvm_runtime.java_ffi_class_bytes

let mutex_class_bytes = Jvm_runtime.mutex_class_bytes

let cond_var_class_bytes = Jvm_runtime.cond_var_class_bytes

let big_array_class_bytes = Jvm_runtime.big_array_class_bytes

let thread_prim_class_bytes = Jvm_runtime.thread_prim_class_bytes
