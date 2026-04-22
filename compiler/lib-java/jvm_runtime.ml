(* The runtime classes (Block / Closure / PartialClosure / CamlException)
   are now authored as real Java source under [runtime-java/] and
   compiled with [javac] at build time. The class bytes are embedded
   into an OCaml string literal in [Java_of_ocaml_runtime_bytes], which
   this module re-exports under the legacy names. *)

module R = Java_of_ocaml_runtime_bytes.Runtime_bytes

let block_class_bytes () = R.block
let closure_class_bytes () = R.closure
let partial_closure_class_bytes () = R.partial_closure
let dummy_closure_class_bytes () = R.dummy_closure
let camlexception_class_bytes () = R.caml_exception
let compare_class_bytes () = R.compare
let channel_class_bytes () = R.channel
let bytes_class_bytes () = R.bytes
let format_class_bytes () = R.format
let ephemeron_class_bytes () = R.ephemeron
let java_ffi_class_bytes () = R.java_f_f_i
let mutex_class_bytes () = R.mutex
let cond_var_class_bytes () = R.cond_var
let big_array_class_bytes () = R.big_array
let thread_prim_class_bytes () = R.thread_prim
let ocaml_class_bytes () = R.ocaml

let builtin_stub_classes () =
  [ "CoreUnixStubs", R.core_unix_stubs
  ; "ConstantStubs", R.constant_stubs
  ; "IntegersStubs", R.integers_stubs
  ]

let builtin_stubs_json () = R.stubs_json
