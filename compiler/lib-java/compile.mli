val compile : bc:string -> out_dir:string -> unit
(** Phase 0 pipeline: read the OCaml bytecode at [bc], extract arguments to
    every [caml_java_print_endline] call, and emit [out_dir/Main.class] which
    prints each argument via [System.out.println]. *)
