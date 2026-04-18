(* The runtime classes (Block / Closure / PartialClosure / CamlException)
   are now authored as real Java source under [runtime-java/] and
   compiled with [javac] at build time. The class bytes are embedded
   into an OCaml string literal in [Java_of_ocaml_runtime_bytes], which
   this module re-exports under the legacy names. *)

module R = Java_of_ocaml_runtime_bytes.Runtime_bytes

let block_class_bytes () = R.block
let closure_class_bytes () = R.closure
let partial_closure_class_bytes () = R.partial_closure
let camlexception_class_bytes () = R.caml_exception
let compare_class_bytes () = R.compare
