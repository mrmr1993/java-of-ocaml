let print fmt ~arr ~fn_info_of_body ~main_start_pc ~pc =
  let n = Array.length arr in
  let end_pc = if n = 0 then pc else arr.(n - 1).Instr.pc + 1 in
  Format.fprintf fmt "[print-tree] pc=%d@." pc;
  if pc = main_start_pc
  then (
    Format.fprintf fmt "  (treating as main init)@.";
    try
      let prog =
        Parse_bytecode.parse_main arr ~start_pc:pc ~end_pc
      in
      let tree = Split_tree.of_program prog in
      let s = Split_tree.summarise tree in
      Format.fprintf
        fmt
        "  blocks=%d leaves=%d flats=%d seqs=%d ifs=%d switches=%d \
         loops=%d trys=%d stragglers=%d@."
        (Code.Addr.Map.cardinal prog.blocks)
        s.leaves
        s.flats
        s.seqs
        s.ifs
        s.switches
        s.loops
        s.trys
        s.stragglers;
      Split_tree.print fmt tree
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
         let tree = Split_tree.of_program prog in
         let s = Split_tree.summarise tree in
         Format.fprintf
           fmt
           "  blocks=%d leaves=%d flats=%d seqs=%d ifs=%d switches=%d \
            loops=%d trys=%d stragglers=%d@."
           (Code.Addr.Map.cardinal prog.blocks)
           s.leaves
           s.flats
           s.seqs
           s.ifs
           s.switches
           s.loops
           s.trys
           s.stragglers;
         Split_tree.print fmt tree
       with
       | Parse_bytecode.Not_supported msg ->
         Format.fprintf fmt "  parse failed: %s@." msg)
    | None ->
      Format.fprintf
        fmt
        "  (pc not registered as a function body; skipping)@."
