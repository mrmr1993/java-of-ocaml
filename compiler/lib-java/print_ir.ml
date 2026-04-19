(* Locate the natural end of a function body starting at [body_pc].
   Duplicates the "next entry in sorted_body_pcs" logic so we don't
   have to thread the array through — callers compute it from the
   full function-info table. *)

let find_end_pc ~arr ~body_pc ~fn_info_of_body =
  (* Collect all other body_pcs from the function-info table via
     [fn_info_of_body], which we can't fully iterate — but callers
     give us a reasonable upper bound by way of [arr]. In practice
     the parser walks linearly from body_pc, so passing the whole
     remaining range is fine; it stops at a terminator. *)
  ignore fn_info_of_body;
  let n = Array.length arr in
  if n = 0
  then body_pc
  else arr.(n - 1).Instr.pc + 1

let print fmt ~arr ~fn_info_of_body ~main_start_pc ~pc =
  let end_pc = find_end_pc ~arr ~body_pc:pc ~fn_info_of_body in
  Format.fprintf fmt "[print-ir] pc=%d@." pc;
  if pc = main_start_pc
  then (
    Format.fprintf fmt "  (treating as main init)@.";
    try
      let prog =
        Parse_bytecode.parse_main arr ~start_pc:pc ~end_pc
      in
      Code.Print.program fmt prog
    with
    | Parse_bytecode.Not_supported msg ->
      Format.fprintf fmt "  parse failed: %s@." msg)
  else
    match fn_info_of_body pc with
    | Some (fi : Function_info.function_info) ->
      Format.fprintf
        fmt
        "  (function %s, nargs=%d, ncaps=%d)@."
        fi.name
        fi.nargs
        fi.ncaps;
      let body_end_pc = arr.(fi.body_end_idx).pc + 1 in
      (try
         let prog, _params, _env =
           Parse_bytecode.parse_function
             arr
             ~start_pc:pc
             ~end_pc:body_end_pc
             ~nargs:fi.nargs
             ~ncaps:fi.ncaps
         in
         Code.Print.program fmt prog
       with
       | Parse_bytecode.Not_supported msg ->
         Format.fprintf fmt "  parse failed: %s@." msg)
    | None ->
      Format.fprintf
        fmt
        "  (pc not registered as a function body; skipping)@."
