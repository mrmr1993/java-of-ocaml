open Instr
open Kind
open Function_info

(* Debug flags. Enable via [JAVA_OF_OCAML_DEBUG=times,primitives,functions,emit]. *)
let debug_times = Debug.find "times"
let debug_primitives = Debug.find "primitives"
let debug_functions = Debug.find "functions"
let debug_ir_emit = Debug.find "ir_emit"

(* Method-body size limit, normally the JVM's 65535-byte [Code]-attribute
   cap. Tests can set [JAVA_OF_OCAML_SPLIT_THRESHOLD=<bytes>] to force
   splitting on smaller bodies — far easier than coaxing OCaml into
   producing a genuine 64 KB method. *)
let method_size_limit =
  lazy
    (match Sys.getenv_opt "JAVA_OF_OCAML_SPLIT_THRESHOLD" with
     | Some s ->
       (match int_of_string_opt (String.trim s) with
        | Some n when n > 0 -> n
        | _ -> 65535)
     | None -> 65535)
let debug_deadcode = Debug.find "deadcode"
let debug_eval = Debug.find "eval"

let run_eval ~what prog =
  let prog, { Eval.folded } = Eval.run prog in
  if debug_eval ()
  then
    Format.eprintf
      "[eval] %s: folded %d expr%s@."
      what
      folded
      (if folded = 1 then "" else "s");
  prog

let run_deadcode ~what prog =
  let prog, { Deadcode.deleted_blocks; deleted_instrs } = Deadcode.run prog in
  if debug_deadcode ()
  then
    Format.eprintf
      "[deadcode] %s: -%d block%s, -%d instr%s@."
      what
      deleted_blocks
      (if deleted_blocks = 1 then "" else "s")
      deleted_instrs
      (if deleted_instrs = 1 then "" else "s");
  prog

let optimize ~what prog =
  let prog = run_eval ~what prog in
  run_deadcode ~what prog


(* Attempt to lower a function body (or the main init range) to the new
   Code IR via [Parse_bytecode]. This is a smoke pass for Phase 1 — the
   legacy forward-walk emitter still runs unconditionally. Failures are
   logged under the [ir] debug flag and otherwise silent; opcodes we
   haven't ported yet (CLOSURE, PUSHTRAP, SWITCH, ENVACC, ...) raise
   [Not_supported], which is expected. *)
let time_phase name f =
  if not (debug_times ())
  then f ()
  else
    let t = Timer.make () in
    let r = f () in
    Format.eprintf "[times] %s: %a s@." name Timer.print t;
    r

(* -------------------------------------------------------------------------- *)
(* Compile-wide driver. *)



(* Emit bytecode that materialises a global-value tree into a live
   [Block]. Used by the globals-init prelude (no State threading
   needed since we target [main]'s [<clinit>]-style setup). Uses
   a fresh JVM local to park the [Object[]] between anewarray and
   the Block ctor call. *)
let rec emit_materialise_value code (v : Global_view.global_field_value) =
  match v with
  | Gv_int n ->
    Jvm.Code.ldc_int code n;
    Kind.emit_box_int code
  | Gv_string s -> Jvm.Code.ldc_string code s
  | Gv_float d ->
    Jvm.Code.ldc_double code d;
    Kind.emit_box_float code
  | Gv_int64 n ->
    (* Truncate to JVM int — most DATA-section int32/int64/nativeint
       constants (Int32.zero, Int64.one, Nativeint.minus_one, etc.)
       fit in 32 bits. Box as Integer so downstream [as_int] unboxes
       via the usual checkcast+intValue. Lossy for 64-bit payloads
       (double-bit-pattern constants, large int64 literals); those
       cases are tracked separately. *)
    Jvm.Code.ldc_int code (Int64.to_int n);
    Kind.emit_box_int code
  | Gv_block (tag, fields) ->
    emit_materialise_block_constant code tag fields
  | Gv_null -> Jvm.Code.aconst_null code

and emit_materialise_block_constant code tag fields =
  let n = List.length fields in
  Jvm.Code.new_ code "Block";
  Jvm.Code.dup code;
  Jvm.Code.ldc_int code tag;
  Jvm.Code.ldc_int code n;
  Jvm.Code.anewarray code "java/lang/Object";
  List.iteri
    (fun i fv ->
      Jvm.Code.dup code;
      Jvm.Code.ldc_int code i;
      emit_materialise_value code fv;
      Jvm.Code.aastore code)
    fields;
  Jvm.Code.invokespecial
    code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V"

(* Emit code that populates [Main.GLOBALS] from the bytecode's DATA
   section. Runs first thing in [Main.main] so module init (which
   SETGLOBALs the dynamic module records) sees a pre-populated table
   holding the pre-marshalled values (exception descriptors, atom
   blocks, etc.). Globals whose shape we can't classify statically are
   left [null]; anything that reads them before a SETGLOBAL writes
   them will trip NullPointerException at runtime. *)
(* Populate [Main.ARGV] from [main]'s [String[]] argument: wrap the
   argv array as a new [Block(0, Object[])] and stash it in the
   static field. Called at the very top of [main], before
   [emit_globals_init], so [caml_sys_argv] can read it safely as
   soon as any code runs. *)
let emit_sys_argv_prologue code =
  (* Build [ARGV = new Block(0, ["Main"; args.0; args.1; ...])].
     Java's [main(String[] args)] omits the program name so we
     synthesise one — [Sys.argv.(0)] is never empty in OCaml.

     Layout:
       fresh[0]    = "Main"
       fresh[1..n] = args[0..n-1]  via System.arraycopy
     where [n = args.length]. *)
  Jvm.Code.new_ code "Block";
  Jvm.Code.dup code;
  Jvm.Code.ldc_int code 0 (* tag *);
  Jvm.Code.aload code 0 (* args *);
  Jvm.Code.arraylength code;
  Jvm.Code.ldc_int code 1;
  Jvm.Code.iadd code;
  Jvm.Code.anewarray code "java/lang/Object";
  let fresh = 1 in
  Jvm.Code.set_min_locals code (fresh + 1);
  Jvm.Code.astore code fresh;
  (* fresh[0] = "Main" *)
  Jvm.Code.aload code fresh;
  Jvm.Code.ldc_int code 0;
  Jvm.Code.ldc_string code "Main";
  Jvm.Code.aastore code;
  (* System.arraycopy(args, 0, fresh, 1, args.length) *)
  Jvm.Code.aload code 0;
  Jvm.Code.ldc_int code 0;
  Jvm.Code.aload code fresh;
  Jvm.Code.ldc_int code 1;
  Jvm.Code.aload code 0;
  Jvm.Code.arraylength code;
  Jvm.Code.invokestatic
    code
    ~class_:"java/lang/System"
    ~method_:"arraycopy"
    ~descriptor:"(Ljava/lang/Object;ILjava/lang/Object;II)V";
  Jvm.Code.aload code fresh;
  Jvm.Code.invokespecial
    code
    ~class_:"Block"
    ~method_:"<init>"
    ~descriptor:"(I[Ljava/lang/Object;)V";
  Jvm.Code.putstatic
    code
    ~class_:"Main"
    ~field:"ARGV"
    ~descriptor:"LBlock;"

(* Emit the bytecode that populates a single [Main.GLOBALS[i]] slot,
   given [i] and the classified entry. Shared between the inline and
   chunked-helper paths below. *)
let emit_globals_entry code i =
  let open Global_view in
  function
  | G_unsupported -> ()
  | G_int n ->
    Jvm.Code.getstatic
      code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int code i;
    Jvm.Code.ldc_int code n;
    Kind.emit_box_int code;
    Jvm.Code.aastore code
  | G_string s ->
    Jvm.Code.getstatic
      code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int code i;
    Jvm.Code.ldc_string code s;
    Jvm.Code.aastore code
  | G_float d ->
    Jvm.Code.getstatic
      code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int code i;
    Jvm.Code.ldc_double code d;
    emit_box_float code;
    Jvm.Code.aastore code
  | G_int64 n ->
    Jvm.Code.getstatic
      code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int code i;
    Jvm.Code.ldc_int code (Int64.to_int n);
    Kind.emit_box_int code;
    Jvm.Code.aastore code
  | G_block (tag, fields) ->
    Jvm.Code.getstatic
      code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int code i;
    emit_materialise_block_constant code tag fields;
    Jvm.Code.aastore code

(* [emit_globals_init cp globals ~main_code] allocates the [GLOBALS]
   array in [main_code] and then populates it. For small programs the
   population is inlined directly into [main_code]; for large programs
   it's split into static helper methods (returned as [method_desc]s
   so the caller can attach them to [Main]) so [main_code] doesn't
   blow through the 65535-byte [Code]-attribute limit. Each global
   entry costs roughly 15–30 bytes depending on its kind, so we
   chunk at [globals_chunk_size] entries ≈ 20 KB worth of bytecode
   per helper — well under the limit. *)
let globals_chunk_size = 1000

let emit_globals_init cp globals ~main_code =
  let n = Array.length globals in
  Jvm.Code.ldc_int main_code n;
  Jvm.Code.anewarray main_code "java/lang/Object";
  Jvm.Code.putstatic
    main_code
    ~class_:"Main"
    ~field:"GLOBALS"
    ~descriptor:"[Ljava/lang/Object;";
  if n <= globals_chunk_size
  then (
    for i = 0 to n - 1 do
      emit_globals_entry main_code i (Global_view.inspect_global globals i)
    done;
    [])
  else (
    let helpers = ref [] in
    let chunk_start = ref 0 in
    let chunk_idx = ref 0 in
    while !chunk_start < n do
      let chunk_end = min n (!chunk_start + globals_chunk_size) in
      let helper_code = Jvm.Code.create cp in
      Jvm.Code.set_min_locals helper_code 0;
      for i = !chunk_start to chunk_end - 1 do
        emit_globals_entry
          helper_code
          i
          (Global_view.inspect_global globals i)
      done;
      Jvm.Code.return_void helper_code;
      let name = Printf.sprintf "init_globals_%d" !chunk_idx in
      helpers
        := { Jvm.name
           ; descriptor = "()V"
           ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
           ; code = helper_code
           }
           :: !helpers;
      Jvm.Code.invokestatic
        main_code
        ~class_:"Main"
        ~method_:name
        ~descriptor:"()V";
      incr chunk_idx;
      chunk_start := chunk_end
    done;
    List.rev !helpers)

let compile_t
      ?(print_functions = [])
      ?(print_ir = [])
      ~parsed
      ~out_dir
      () =
  let total = if debug_times () then Some (Timer.make ()) else None in
  let prim_table = Prim.find_supported_prims parsed in
  (* A zero-primitive input is legitimate for separate-compilation
     inputs: a [.cmo]'s [cu_primitives] only lists C primitives
     directly declared by [external] in that unit, and most user
     modules declare none. The full primitive table only appears
     once Stdlib (and anything else providing C stubs) is in the
     link. Downstream passes cope with an empty table. *)
  if debug_primitives ()
  then (
    Format.eprintf "[primitives] resolved %d:@." (Hashtbl.length prim_table);
    Hashtbl.iter
      (fun idx (name, _, seed) ->
        Format.eprintf "  %d -> %s%s@." idx name (if seed then " (seed)" else ""))
      prim_table);
  let instrs = time_phase "decode" (fun () -> decode_all parsed) in
  let arr = Array.of_list instrs in
  let start_idx, end_idx = 0, Array.length arr - 1 in
  if debug_functions ()
  then
    Format.eprintf
      "[functions] whole bytecode: idx %d..%d (pc %d..%d)@."
      start_idx
      end_idx
      arr.(start_idx).pc
      arr.(end_idx).pc;
  (* Pre-scan for every CLOSUREREC / CLOSURE in the whole bytecode. *)
  let functions = Hashtbl.create 64 in
  let func_list = ref [] in
  let fn_body_pcs = Hashtbl.create 64 in
  let fn_count = ref 0 in
  let fn_scan_timer = if debug_times () then Some (Timer.make ()) else None in
  (* First pass: collect every function body_pc up front, so when we
     compute body ranges below we can bound each one by the next
     function's body_pc. Without this bound the range-walker can
     consume sibling bodies whole whenever a forward branch points
     past the natural terminator. *)
  let all_body_pcs = ref [] in
  for i = start_idx to end_idx do
    let ins = arr.(i) in
    if ins.opcode = closurerec_op
    then (
      let nf = ins.args.(0) in
      for k = 0 to nf - 1 do
        all_body_pcs := (ins.pc + 3 + ins.args.(2 + k)) :: !all_body_pcs
      done)
    else if ins.opcode = closure_op
    then all_body_pcs := (ins.pc + ins.args.(1) + 2) :: !all_body_pcs
  done;
  (match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
   | Some s when List.mem "setglobals" (String.split_on_char ',' s) ->
     for i = start_idx to end_idx do
       let ins = arr.(i) in
       if ins.opcode = Bytecode.Op.setglobal
       then
         Format.eprintf
           "[setglobal] pc=%d idx=%d@." ins.pc ins.args.(0)
     done
   | _ -> ());
  (match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
   | Some s when List.mem "globals" (String.split_on_char ',' s) ->
     let g = parsed.globals in
     for i = 0 to Array.length g - 1 do
       let classified =
         match Global_view.inspect_global g i with
         | G_int n -> Printf.sprintf "G_int %d" n
         | G_string s -> Printf.sprintf "G_string %S" s
         | G_float _ -> "G_float"
         | G_int64 n -> Printf.sprintf "G_int64 %Ld" n
         | G_block (tag, fields) ->
           let f0 =
             match fields with
             | Gv_string s :: _ -> Printf.sprintf " f0=%S" s
             | _ -> ""
           in
           Printf.sprintf "G_block tag=%d size=%d%s" tag (List.length fields) f0
         | G_unsupported -> "G_unsupported"
       in
       Format.eprintf "[global] %d: %s@." i classified
     done
   | _ -> ());
  let sorted_body_pcs =
    List.sort_uniq compare !all_body_pcs |> Array.of_list
  in
  let pc_upper_bound_after pc =
    let n = Array.length sorted_body_pcs in
    let rec find i =
      if i >= n then max_int
      else if sorted_body_pcs.(i) > pc then sorted_body_pcs.(i)
      else find (i + 1)
    in
    find 0
  in
  List.iter
    (fun pc ->
      Print_function.print Format.err_formatter arr ~sorted_body_pcs ~pc)
    print_functions;
  for i = start_idx to end_idx do
    let ins = arr.(i) in
    if ins.opcode = closurerec_op || ins.opcode = closure_op
    then (
      let recursive = ins.opcode = closurerec_op in
      let nfuncs, nvars, body_pc_of =
        if recursive
        then (
          let nf = ins.args.(0) in
          let nv = ins.args.(1) in
          nf, nv, fun k -> ins.pc + 3 + ins.args.(2 + k))
        else (
          let nv = ins.args.(0) in
          1, nv, fun _ -> ins.pc + ins.args.(1) + 2)
      in
      let group = Array.make nfuncs (Obj.magic () : function_info) in
      for k = 0 to nfuncs - 1 do
        let body_pc = body_pc_of k in
        let pc_upper_bound = pc_upper_bound_after body_pc in
        let body_start_idx, body_end_idx, nargs =
          find_function_body_range arr ~pc_upper_bound body_pc
        in
        let name = Printf.sprintf "ocaml_fn_%d" !fn_count in
        incr fn_count;
        let info =
          { name
          ; closurerec_pc = ins.pc
          ; body_pc
          ; body_start_idx
          ; body_end_idx
          ; nargs
          ; ncaps = nvars
          ; return_kind = ref K_int
          ; arg_kinds = ref (List.init nargs (fun _ -> K_int))
          ; capture_kinds = ref []
          ; recursive
          ; group_idx = k
          ; group = [||]
          }
        in
        group.(k) <- info;
        if k = 0 then Hashtbl.add functions ins.pc info;
        func_list := info :: !func_list;
        let pre_start =
          let rec find i =
            if i >= Array.length arr then i
            else if arr.(i).pc = body_pc then i
            else find (i + 1)
          in
          find 0
        in
        for j = pre_start to body_end_idx do
          Hashtbl.replace fn_body_pcs arr.(j).pc ()
        done
      done;
      Array.iter (fun info -> info.group <- group) group)
  done;
  (match fn_scan_timer with
   | Some t ->
     Format.eprintf
       "[times] function-scan (%d fns): %a s@."
       !fn_count
       Timer.print
       t
   | None -> ());
  let fn_by_name = Hashtbl.create 64 in
  List.iter
    (fun (fi : function_info) -> Hashtbl.add fn_by_name fi.name fi)
    !func_list;
  (* --print-ir PC debug dumps. Resolve PCs against the function-info
     table once it's populated, so we know which are main vs function
     bodies and can feed the right nargs/ncaps to parse_function. *)
  (match print_ir with
   | [] -> ()
   | pcs ->
     let fn_info_of_body =
       let by_body = Hashtbl.create 64 in
       List.iter
         (fun (fi : function_info) ->
           Hashtbl.replace by_body fi.body_pc fi)
         !func_list;
       fun pc -> Hashtbl.find_opt by_body pc
     in
     let main_start_pc =
       if Array.length arr = 0 then 0 else arr.(0).pc
     in
     List.iter
       (fun pc ->
         Print_ir.print
           Format.err_formatter
           ~arr
           ~fn_info_of_body
           ~main_start_pc
           ~pc)
       pcs);
  (* Legacy-only kind inference removed. The IR path uses
     [Jvm_typing.infer] on each function's Code.program instead. *)
  if debug_functions ()
  then
    List.iter
      (fun (fi : function_info) ->
        Format.eprintf
          "[functions] %s: nargs=%d ncaps=%d pc=%d body=[%d..%d] return=%s \
           args=[%s]@."
          fi.name
          fi.nargs
          fi.ncaps
          fi.body_pc
          fi.body_start_idx
          fi.body_end_idx
          (string_of_kind !(fi.return_kind))
          (String.concat "," (List.map string_of_kind !(fi.arg_kinds))))
      !func_list;
  let cp = Jvm.Cp.create () in
  let main_code = Jvm.Code.create cp in
  let main_split_helpers = ref [] in
  (* If post-split main still overflows 65535 bytes, the driver
     replaces [main_code] with the fallback stub below. Tracked
     via this ref because [Jvm.Code.t] has no reset. *)
  let main_code_override = ref None in
  (* Globals-init prelude is emitted later — after we've decided
     between IR and legacy for the main body, so a failed IR attempt
     doesn't leave half-written globals-init bytes in [main_code]. *)
  let _ = end_idx in
  (* Block addresses land on OCaml branch targets, which rarely coincide
     with a debug-event pc (events sit at expression boundaries). To
     still attribute each block to a line, fall back to the line of
     the next event with pc >= [pc]. Pre-sort the pcs once so each
     lookup is O(log n). *)
  let sorted_debug_pcs =
    let arr =
      Hashtbl.fold
        (fun pc (d : Bytecode.debug_loc) acc -> (pc, d.line) :: acc)
        parsed.debug
        []
      |> List.sort (fun (a, _) (b, _) -> compare a b)
      |> Array.of_list
    in
    arr
  in
  let line_of_pc pc =
    let n = Array.length sorted_debug_pcs in
    if n = 0
    then None
    else
      let lo = ref 0 and hi = ref (n - 1) and found = ref (-1) in
      while !lo <= !hi do
        let mid = (!lo + !hi) / 2 in
        let mpc, _ = sorted_debug_pcs.(mid) in
        if mpc >= pc
        then (
          found := mid;
          hi := mid - 1)
        else lo := mid + 1
      done;
      if !found = -1
      then None
      else
        let _, line = sorted_debug_pcs.(!found) in
        Some line
  in
  (match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
   | Some s when List.mem "dbug" (String.split_on_char ',' s) ->
     Format.eprintf "[dbug] %d events@." (Hashtbl.length parsed.debug);
     let pcs =
       Hashtbl.fold (fun pc d acc -> (pc, d) :: acc) parsed.debug []
       |> List.sort (fun (a, _) (b, _) -> compare a b)
     in
     List.iter
       (fun (pc, (d : Bytecode.debug_loc)) ->
         Format.eprintf
           "[dbug] pc=%d file=%s line=%d mod=%s@."
           pc
           d.file
           d.line
           d.modname)
       pcs
   | _ -> ());
  (* Resolve a [SourceFile] class attribute from the debug table:
     the file of the lowest-pc event at or after [from_pc]. Returns
     [None] when [-g] wasn't used (debug table empty). *)
  let source_file_from pc_range_start =
    let best = ref None in
    Hashtbl.iter
      (fun pc (d : Bytecode.debug_loc) ->
        if pc >= pc_range_start && d.file <> ""
        then
          match !best with
          | Some (prev_pc, _) when prev_pc <= pc -> ()
          | _ -> best := Some (pc, d.file))
      parsed.debug;
    match !best with
    | Some (_, f) -> Some (Filename.basename f)
    | None -> None
  in
  (* Pick a source file for the Main class. Heuristic: the file of
     the highest-pc event before Std_exit whose module isn't in the
     Stdlib/Camlinternal* set — that is the user's last compilation
     unit. Fall back to the first event if none matches (e.g. only
     the Stdlib itself was compiled with [-g]). *)
  let main_source_file =
    let std_exit_pc = ref max_int in
    Hashtbl.iter
      (fun pc (d : Bytecode.debug_loc) ->
        if d.modname = "Std_exit" && pc < !std_exit_pc then std_exit_pc := pc)
      parsed.debug;
    let is_user_module m =
      m <> "Stdlib"
      && not
           (String.length m >= 7 && String.sub m 0 7 = "Stdlib_")
      && not
           (String.length m >= 13 && String.sub m 0 13 = "Camlinternal")
      && m <> "Std_exit"
    in
    let best = ref None in
    Hashtbl.iter
      (fun pc (d : Bytecode.debug_loc) ->
        if pc < !std_exit_pc && is_user_module d.modname
        then
          match !best with
          | Some (p, _) when p >= pc -> ()
          | _ -> best := Some (pc, d.file))
      parsed.debug;
    match !best with
    | Some (_, f) -> Some (Filename.basename f)
    | None -> source_file_from 0
  in
  time_phase "emit-main" (fun () ->
    let body_pc_to_fi = Hashtbl.create 64 in
    List.iter
      (fun (fi : function_info) -> Hashtbl.replace body_pc_to_fi fi.body_pc fi)
      !func_list;
    let name_of_body pc =
      match Hashtbl.find_opt body_pc_to_fi pc with
      | Some fi -> fi.name
      | None -> raise Not_found
    in
    let fn_info_of_body pc = Hashtbl.find_opt body_pc_to_fi pc in
    let prim_name idx =
      if idx < 0 || idx >= Array.length parsed.prims
      then raise Not_found
      else parsed.prims.(idx)
    in
    let try_main_ir () =
        (* Don't filter out fn_body_pcs — the parser's block-boundary
           scan needs the full instruction stream to find successor
           PCs via addr_map. Function bodies aren't reachable via
           fall-through (their entry pc is only ever a caller of
           a CLOSURE/CLOSUREREC body-pc argument, which doesn't
           appear in [Instr.branch_targets]), so they won't get
           processed as blocks. *)
        if Array.length arr = 0
        then None
        else (
          let first = arr.(0) in
          let last = arr.(Array.length arr - 1) in
          let start_pc = first.pc in
          let end_pc = last.pc + 1 in
          try
             let prog = Parse_bytecode.parse_main arr ~start_pc ~end_pc in
             let prog = optimize ~what:"<main>" prog in
             let typing = Jvm_typing.infer prog in
             (* Run the splitter as an IR pass on main too. Main's
                helpers are static methods on the [Main] class;
                [Invoke_tail { is_static = true }] gets emitted as
                [invokestatic], matching. *)
             let limit = Lazy.force method_size_limit in
             let split_result =
               Method_split.split
                 ~limit
                 ~class_name:"Main"
                 ~is_static:true
                 ~return_kind:Method_split.Return_void
                 prog
             in
             let helpers =
               List.map
                 (fun (h : Method_split.helper) ->
                   let helper_code = Jvm.Code.create cp in
                   Jvm.Code.set_min_locals
                     helper_code
                     (List.length h.params);
                   Jvm_generate.emit_program
                     ~code:helper_code
                     ~typing
                     ~name_of_body
                     ~fn_info_of_body
                     ~prim_name
                     ~arg_vars:h.params
                     ~line_of_pc
                     ~unbox_args:true
                     ~is_static:true
                     h.prog;
                   { Jvm.name = h.method_name
                   ; descriptor = h.descriptor
                   ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
                   ; code = helper_code
                   })
                 split_result.helpers
             in
             Some (split_result.head, typing, helpers)
           with
           | Parse_bytecode.Not_supported msg ->
             if debug_ir_emit ()
             then
               Format.eprintf "[ir_emit] <main>: legacy (parse: %s)@." msg;
             None
           | Jvm_generate.Unsupported msg ->
             if debug_ir_emit ()
             then
               Format.eprintf "[ir_emit] <main>: legacy (gen: %s)@." msg;
             None)
    in
    (match try_main_ir () with
     | Some (head, typing, helpers) ->
       emit_sys_argv_prologue main_code;
       let globals_helpers =
         emit_globals_init cp parsed.globals ~main_code
       in
       main_split_helpers := helpers @ globals_helpers;
       Jvm_generate.emit_program
         ~code:main_code
         ~typing
         ~name_of_body
         ~fn_info_of_body
         ~prim_name
         ~line_of_pc
         head;
       let size = Jvm.Code.resolved_size main_code in
       if size > 65535
       then (
         if debug_ir_emit ()
         then
           Format.eprintf
             "[ir_emit] <main>: post-split still oversized (size=%d) \
              — stubbing@."
             size;
         main_split_helpers := [];
         (* Build a fresh stub into a new [Code.t]; the emitter
            never exposes a reset, so we swap [main_code] out at
            assembly time via [main_code_override]. *)
         let stub = Jvm.Code.create cp in
         Jvm.Code.set_min_locals stub 1;
         Jvm.Code.new_ stub "java/lang/UnsupportedOperationException";
         Jvm.Code.dup stub;
         Jvm.Code.ldc_string
           stub
           (Printf.sprintf
              "Main body too large to split (%d bytes > 65535)"
              size);
         Jvm.Code.invokespecial
           stub
           ~class_:"java/lang/UnsupportedOperationException"
           ~method_:"<init>"
           ~descriptor:"(Ljava/lang/String;)V";
         Jvm.Code.athrow stub;
         main_code_override := Some stub)
       else if debug_ir_emit ()
       then
         Format.eprintf
           "[ir_emit] <main>: used IR (helpers=%d)@."
           (List.length helpers)
     | None ->
       emit_sys_argv_prologue main_code;
       let globals_helpers =
         emit_globals_init cp parsed.globals ~main_code
       in
       main_split_helpers := globals_helpers;
       Jvm.Code.new_ main_code "java/lang/UnsupportedOperationException";
       Jvm.Code.dup main_code;
       Jvm.Code.ldc_string
         main_code
         "IR emitter gave up on main init; legacy retired";
       Jvm.Code.invokespecial
         main_code
         ~class_:"java/lang/UnsupportedOperationException"
         ~method_:"<init>"
         ~descriptor:"(Ljava/lang/String;)V";
       Jvm.Code.athrow main_code));
  let main_method =
    { Jvm.name = "main"
    ; descriptor = "([Ljava/lang/String;)V"
    ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
    ; code =
        (match !main_code_override with
         | Some c -> c
         | None -> main_code)
    }
  in
  let globals_field =
    { Jvm.name = "GLOBALS"
    ; descriptor = "[Ljava/lang/Object;"
    ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
    }
  in
  let dls_field =
    { Jvm.name = "DLS_STATE"
    ; descriptor = "Ljava/lang/Object;"
    ; access_flags = 0x0009
    }
  in
  (* [Sys.argv] backing store. Populated from [main(String[])]'s
     argument at method entry (see [emit_sys_argv_prologue]), read
     by [caml_sys_argv] / [caml_sys_executable_name]. *)
  let argv_field =
    { Jvm.name = "ARGV"
    ; descriptor = "LBlock;"
    ; access_flags = 0x0009
    }
  in
  let main_class_bytes =
    Jvm.assemble_class
      ?source_file:main_source_file
      ~class_name:"Main"
      ~super_name:"java/lang/Object"
      ~cp
      ~fields:[ globals_field; dls_field; argv_field ]
      ~methods:(main_method :: !main_split_helpers)
      ~access_flags:0x0021 (* ACC_PUBLIC | ACC_SUPER *)
      ()
  in
  (* Hoist the per-closure function-table rebuild out of the inner
     loop. It takes the full [fn_by_name] ~ O(|fns|) per call and
     on stdlib+Base (~7500 fns) was compounding into a quadratic
     factor. The compiled-in [instrs] array is passed to
     [parse_*] directly — see [Parse_bytecode.parse_function] and
     friends, which now take an array. *)
  let body_pc_to_fi = Hashtbl.create (Hashtbl.length fn_by_name) in
  Hashtbl.iter
    (fun _name (fi : function_info) ->
      Hashtbl.replace body_pc_to_fi fi.body_pc fi)
    fn_by_name;
  let name_of_body pc =
    match Hashtbl.find_opt body_pc_to_fi pc with
    | Some fi -> fi.Function_info.name
    | None -> raise Not_found
  in
  let fn_info_of_body pc = Hashtbl.find_opt body_pc_to_fi pc in
  let prim_name idx =
    if idx < 0 || idx >= Array.length parsed.prims
    then raise Not_found
    else parsed.prims.(idx)
  in
  let closure_class_files = time_phase "emit-closures" (fun () ->
    List.map
      (fun (fn_info : function_info) ->
        let cap_kinds = !(fn_info.capture_kinds) in
        let ncaps = List.length cap_kinds in
        let fn_cp = Jvm.Cp.create () in
        let ctor_code = Jvm.Code.create fn_cp in
        Jvm.Code.set_min_locals ctor_code (1 + ncaps);
        Jvm.Code.aload ctor_code 0;
        Jvm.Code.invokespecial
          ctor_code
          ~class_:"Closure"
          ~method_:"<init>"
          ~descriptor:"()V";
        List.iteri
          (fun i k ->
            Jvm.Code.aload ctor_code 0;
            emit_load_for_kind ctor_code (i + 1) k;
            Jvm.Code.putfield
              ctor_code
              ~class_:fn_info.name
              ~field:(Printf.sprintf "cap%d" i)
              ~descriptor:(jvm_type_of_kind k))
          cap_kinds;
        Jvm.Code.return_void ctor_code;
        let apply_code = Jvm.Code.create fn_cp in
        Jvm.Code.set_min_locals apply_code (1 + fn_info.nargs);
        (* Emit the apply body from the IR. On IR failure, write a
           runtime-throwing stub into [apply_code] so the class
           still loads. *)
        let try_ir () =
          let body_pc = arr.(fn_info.body_start_idx).pc in
          let end_pc = arr.(fn_info.body_end_idx).pc in
          try
              let prog, params, env_var =
                Parse_bytecode.parse_function
                  arr
                  ~start_pc:body_pc
                  ~end_pc:(end_pc + 1)
                  ~nargs:fn_info.nargs
                  ~ncaps
              in
              let arg_vars =
                let rec take n = function
                  | _ when n = 0 -> []
                  | [] -> []
                  | x :: xs -> x :: take (n - 1) xs
                in
                take fn_info.nargs params
              in
              let prog = optimize ~what:fn_info.name prog in
              let ir_code = Jvm.Code.create fn_cp in
              Jvm.Code.set_min_locals ir_code (1 + fn_info.nargs);
              let typing = Jvm_typing.infer prog in
              (* Run the 64 KB splitter as an IR pass: it returns the
                 (possibly rewritten) head plus an ordered list of
                 helper programs. Each helper is emitted as its own
                 method; the head carries [Invoke_tail] terminators
                 that the emitter lowers to [invokevirtual; areturn]
                 at the cut boundaries. *)
              let limit = Lazy.force method_size_limit in
              let split_result =
                Method_split.split
                  ~limit
                  ~class_name:fn_info.name
                  ~is_static:false
                  ~return_kind:Method_split.Return_object
                  ~env_var
                  prog
              in
              let split_helpers =
                List.map
                  (fun (h : Method_split.helper) ->
                    let helper_code = Jvm.Code.create fn_cp in
                    Jvm.Code.set_min_locals
                      helper_code
                      (1 + List.length h.params);
                    Jvm_generate.emit_program
                      ~code:helper_code
                      ~typing
                      ~name_of_body
                      ~fn_info_of_body
                      ~prim_name
                      ~arg_vars:h.params
                      ~enclosing:(fn_info, env_var)
                      ~line_of_pc
                      ~unbox_args:true
                      h.prog;
                    { Jvm.name = h.method_name
                    ; descriptor = h.descriptor
                    ; access_flags = 0x0001 (* ACC_PUBLIC *)
                    ; code = helper_code
                    })
                  split_result.helpers
              in
              Jvm_generate.emit_program
                ~code:ir_code
                ~typing
                ~name_of_body
                ~fn_info_of_body
                ~prim_name
                ~arg_vars
                ~enclosing:(fn_info, env_var)
                ~line_of_pc
                split_result.head;
              let head_size = Jvm.Code.resolved_size ir_code in
              let helper_sizes =
                List.map
                  (fun (m : Jvm.method_desc) ->
                    Jvm.Code.resolved_size m.code)
                  split_helpers
              in
              let too_big size = size > 65535 in
              if too_big head_size || List.exists too_big helper_sizes
              then (
                if debug_ir_emit ()
                then
                  Format.eprintf
                    "[ir_emit] %s: post-split still oversized \
                     (head=%d helpers=[%s])@."
                    fn_info.name
                    head_size
                    (String.concat
                       ","
                       (List.map string_of_int helper_sizes));
                None)
              else (
                if debug_ir_emit ()
                then
                  Format.eprintf
                    "[ir_emit] %s: used IR (helpers=%d)@."
                    fn_info.name
                    (List.length split_helpers);
                Some (ir_code, split_helpers))
            with
            | Parse_bytecode.Not_supported msg ->
              if debug_ir_emit ()
              then
                Format.eprintf
                  "[ir_emit] %s: legacy (parse: %s)@."
                  fn_info.name
                  msg;
              None
            | Jvm_generate.Unsupported msg ->
              if debug_ir_emit ()
              then
                Format.eprintf
                  "[ir_emit] %s: legacy (gen: %s)@."
                  fn_info.name
                  msg;
              None
        in
        let apply_code, split_helpers =
          match try_ir () with
          | Some (ir_code, helpers) -> ir_code, helpers
          | None ->
            (* IR couldn't handle this function. Emit a method body
               that throws at runtime so the class still loads;
               anything that actually invokes it will see a
               descriptive UnsupportedOperationException. Avoids
               needing the legacy forward-walk emitter as a
               fallback. *)
            Jvm.Code.set_min_locals apply_code (1 + fn_info.nargs);
            Jvm.Code.new_
              apply_code
              "java/lang/UnsupportedOperationException";
            Jvm.Code.dup apply_code;
            Jvm.Code.ldc_string
              apply_code
              (Printf.sprintf
                 "IR emitter gave up on %s; legacy retired"
                 fn_info.name);
            Jvm.Code.invokespecial
              apply_code
              ~class_:"java/lang/UnsupportedOperationException"
              ~method_:"<init>"
              ~descriptor:"(Ljava/lang/String;)V";
            Jvm.Code.athrow apply_code;
            apply_code, []
        in
        let cap_fields =
          List.mapi
            (fun i k ->
              { Jvm.name = Printf.sprintf "cap%d" i
              ; descriptor = jvm_type_of_kind k
              ; access_flags = 0x0011
              })
            cap_kinds
        in
        let sibling_fields =
          let n = Array.length fn_info.group in
          if n <= 1
          then []
          else
            List.init n (fun i ->
              { Jvm.name = Printf.sprintf "sibling_%d" i
              ; descriptor = "LClosure;"
              ; access_flags = 0x0001
              })
        in
        let fields = cap_fields @ sibling_fields in
        let ctor =
          { Jvm.name = "<init>"
          ; descriptor =
              (let b = Buffer.create 16 in
               Buffer.add_char b '(';
               List.iter
                 (fun k -> Buffer.add_string b (jvm_type_of_kind k))
                 cap_kinds;
               Buffer.add_string b ")V";
               Buffer.contents b)
          ; access_flags = 0x0001
          ; code = ctor_code
          }
        in
        let apply_method =
          { Jvm.name = Printf.sprintf "apply%d" fn_info.nargs
          ; descriptor =
              (let b = Buffer.create 16 in
               Buffer.add_char b '(';
               for _ = 1 to fn_info.nargs do
                 Buffer.add_string b "Ljava/lang/Object;"
               done;
               Buffer.add_string b ")Ljava/lang/Object;";
               Buffer.contents b)
          ; access_flags = 0x0001
          ; code = apply_code
          }
        in
        let arity_code = Jvm.Code.create fn_cp in
        Jvm.Code.set_min_locals arity_code 1;
        Jvm.Code.ldc_int arity_code fn_info.nargs;
        Jvm.Code.ireturn arity_code;
        let arity_method =
          { Jvm.name = "arity"
          ; descriptor = "()I"
          ; access_flags = 0x0001
          ; code = arity_code
          }
        in
        let fn_source_file = source_file_from fn_info.body_pc in
        let bytes =
          Jvm.assemble_class
            ?source_file:fn_source_file
            ~class_name:fn_info.name
            ~super_name:"Closure"
            ~cp:fn_cp
            ~fields
            ~methods:([ ctor; arity_method; apply_method ] @ split_helpers)
            ~access_flags:0x0031
            ()
        in
        fn_info.name, bytes)
      !func_list)
  in
  let write_class name bytes =
    let path = Filename.concat out_dir (name ^ ".class") in
    let oc = open_out_bin path in
    output_string oc bytes;
    close_out oc
  in
  time_phase "write-classes" (fun () ->
    write_class "Main" main_class_bytes;
    write_class "Block" (Jvm.block_class_bytes ());
    write_class "Closure" (Jvm.closure_class_bytes ());
    write_class "CamlException" (Jvm.camlexception_class_bytes ());
    write_class "PartialClosure" (Jvm.partial_closure_class_bytes ());
    write_class "Compare" (Jvm.compare_class_bytes ());
    write_class "Channel" (Jvm.channel_class_bytes ());
    write_class "Bytes" (Jvm.bytes_class_bytes ());
    write_class "Format" (Jvm.format_class_bytes ());
    write_class "Ephemeron" (Jvm.ephemeron_class_bytes ());
    write_class "JavaFFI" (Jvm.java_ffi_class_bytes ());
    List.iter (fun (name, bytes) -> write_class name bytes) closure_class_files);
  match total with
  | Some t -> Format.eprintf "[times] total: %a s@." Timer.print t
  | None -> ()

(* Magic-number-dispatched front end. Executables go straight to the
   pipeline; one or more [.cmo] / [.cma] inputs are flattened into a
   single unit list and passed through [Linker.link] to produce an
   equivalent [Bytecode.t].

   Mixed input kinds are not supported: an executable already contains
   a fully-linked globals table, so mixing it with separately-
   compiled inputs would double-assign slots. Callers either hand us
   one [.bc] or a list of [.cmo]/[.cma]. *)
let compile
      ?(print_functions = [])
      ?(print_ir = [])
      ~bcs
      ~out_dir
      () =
  let parsed =
    time_phase "read-bytecode" (fun () ->
      match List.map Bytecode.read_file bcs with
      | [] -> failwith "java_of_ocaml: no input files"
      | [ Exe t ] -> t
      | inputs when List.exists (function Bytecode.Exe _ -> true | _ -> false) inputs ->
        failwith
          "java_of_ocaml: an executable (.bc) input cannot be combined \
           with other inputs; pass either one .bc, or a list of .cmo / \
           .cma files."
      | inputs ->
        let units =
          List.concat_map
            (function
              | Bytecode.Exe _ -> assert false (* handled above *)
              | Bytecode.Cmo u -> [ u ]
              | Bytecode.Cma us -> us)
            inputs
        in
        Linker.link units)
  in
  compile_t ~print_functions ~print_ir ~parsed ~out_dir ()

(* Share the "read bcs into a [Bytecode.t]" part of [compile] so the
   primitive-coverage check can reuse it without duplicating the
   magic-number dispatch. *)
let read_bcs bcs =
  match List.map Bytecode.read_file bcs with
  | [] -> failwith "java_of_ocaml: no input files"
  | [ Exe t ] -> t
  | inputs when List.exists (function Bytecode.Exe _ -> true | _ -> false) inputs ->
    failwith
      "java_of_ocaml: an executable (.bc) input cannot be combined \
       with other inputs; pass either one .bc, or a list of .cmo / \
       .cma files."
  | inputs ->
    let units =
      List.concat_map
        (function
          | Bytecode.Exe _ -> assert false
          | Bytecode.Cmo u -> [ u ]
          | Bytecode.Cma us -> us)
        inputs
    in
    Linker.link units

module String_set = Set.Make (String)

let list_missing_prims ~bcs =
  let parsed = read_bcs bcs in
  let known =
    List.fold_left
      (fun s n -> String_set.add n s)
      String_set.empty
      Known_prims.names
  in
  let missing = ref String_set.empty in
  Array.iter
    (fun name ->
      (* Skip the [%xxx] "inlined extern" pseudo-primitives — those
         compile to specific bytecode opcodes ([%addint] →
         [ADDINT] etc.) rather than C_CALLs, so missing handlers
         for them wouldn't surface as "C primitive not implemented"
         runtime errors. The C_CALL path only reaches real C
         primitives, which are the ones without a leading [%]. *)
      if String.length name > 0 && name.[0] = '%'
      then ()
      else if not (String_set.mem name known)
      then missing := String_set.add name !missing)
    parsed.Bytecode.prims;
  String_set.elements !missing
