open Instr
open Kind
open Function_info
open State

(* Debug flags. Enable via [JAVA_OF_OCAML_DEBUG=times,primitives,functions,emit]. *)
let debug_times = Debug.find "times"
let debug_primitives = Debug.find "primitives"
let debug_functions = Debug.find "functions"
let debug_labels = Debug.find "labels"
let debug_ir = Debug.find "ir"
let debug_ir_gen = Debug.find "ir_gen"
let debug_ir_emit = Debug.find "ir_emit"

(* IR emission is on by default. Set [JAVA_OF_OCAML_IR=0] to disable
   and use the legacy forward-walk emitter exclusively. Kept as an
   escape hatch while we stabilise the IR path. *)
let ir_emit_enabled () =
  match Sys.getenv_opt "JAVA_OF_OCAML_IR" with
  | Some ("0" | "false" | "FALSE") -> false
  | _ -> true

(* Attempt to lower a function body (or the main init range) to the new
   Code IR via [Parse_bytecode]. This is a smoke pass for Phase 1 — the
   legacy forward-walk emitter still runs unconditionally. Failures are
   logged under the [ir] debug flag and otherwise silent; opcodes we
   haven't ported yet (CLOSURE, PUSHTRAP, SWITCH, ENVACC, ...) raise
   [Not_supported], which is expected. *)
let ir_smoke_function
    arr
    ~(name_of_body : int -> string)
    ~(fn_info_of_body : int -> Function_info.function_info option)
    ~(prim_name : int -> string)
    (fi : Function_info.function_info)
  =
  if not (debug_ir ())
  then ()
  else (
    let body_pc = arr.(fi.body_start_idx).pc in
    let end_pc = arr.(fi.body_end_idx).pc in
    let instrs = Array.to_list arr in
    try
      let prog, _params, env_var =
        Parse_bytecode.parse_function
          instrs
          ~start_pc:body_pc
          ~end_pc:(end_pc + 1)
          ~nargs:fi.nargs
          ~ncaps:fi.ncaps
      in
      Format.eprintf "[ir] %s: parsed ok@." fi.name;
      if debug_ir_gen ()
      then (
        let cp = Jvm.Cp.create () in
        let code = Jvm.Code.create cp in
        let typing = Jvm_typing.infer prog in
        (try
           Jvm_generate.emit_program
             ~code
             ~typing
             ~name_of_body
             ~fn_info_of_body
             ~prim_name
             ~enclosing:(fi, env_var)
             prog;
           Format.eprintf "[ir_gen] %s: emitted ok@." fi.name
         with Jvm_generate.Unsupported msg ->
           Format.eprintf "[ir_gen] %s: Unsupported — %s@." fi.name msg))
    with
    | Parse_bytecode.Not_supported msg ->
      Format.eprintf "[ir] %s: Not_supported — %s@." fi.name msg
    | exn ->
      Format.eprintf
        "[ir] %s: unexpected exception — %s@."
        fi.name
        (Printexc.to_string exn))

let ir_smoke_main arr ~name_of_body ~fn_info_of_body ~prim_name ~fn_body_pcs =
  let _ = name_of_body in
  let _ = fn_info_of_body in
  let _ = prim_name in
  if not (debug_ir ())
  then ()
  else (
    let instrs =
      Array.to_list arr
      |> List.filter (fun (ins : Instr.instr) ->
           not (Hashtbl.mem fn_body_pcs ins.pc))
    in
    match instrs with
    | [] -> ()
    | first :: _ ->
      let start_pc = first.pc in
      let last = List.nth instrs (List.length instrs - 1) in
      let end_pc = last.pc + 1 in
      (try
         let _prog = Parse_bytecode.parse_main instrs ~start_pc ~end_pc in
         Format.eprintf "[ir] main: parsed ok@."
       with
       | Parse_bytecode.Not_supported msg ->
         Format.eprintf "[ir] main: Not_supported — %s@." msg
       | exn ->
         Format.eprintf
           "[ir] main: unexpected exception — %s@."
           (Printexc.to_string exn)))

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

let collect_pc_to_label
    code
    ~arr
    ~scan_range:(scan_lo, scan_hi)
    ~target_range:(tgt_lo_pc, tgt_hi_pc)
    ~skip_pcs
  =
  let tbl = Hashtbl.create 4 in
  let debug_labels = Debug.find "labels" in
  for i = scan_lo to scan_hi do
    if not (Hashtbl.mem skip_pcs arr.(i).pc)
    then
      List.iter
        (fun target_pc ->
          if target_pc >= tgt_lo_pc
             && target_pc <= tgt_hi_pc
             && not (Hashtbl.mem tbl target_pc)
          then (
            let lbl = Jvm.Code.fresh_label code in
            if debug_labels ()
            then
              Format.eprintf
                "[label] id=%d target_pc=%d from_pc=%d (%s)@."
                (Jvm.Code.label_id lbl)
                target_pc
                arr.(i).pc
                (Bytecode.opcode_name arr.(i).opcode);
            Hashtbl.add tbl target_pc lbl))
        (branch_targets arr.(i))
  done;
  tbl

let emit_range state arr (lo, hi) ~skip_pcs =
  for i = lo to hi do
    if not (Hashtbl.mem skip_pcs arr.(i).pc)
    then Emit_instr.emit_instr state arr.(i)
  done

(* Emit code that populates [Main.GLOBALS] from the bytecode's DATA
   section. Runs first thing in [Main.main] so module init (which
   SETGLOBALs the dynamic module records) sees a pre-populated table
   holding the pre-marshalled values (exception descriptors, atom
   blocks, etc.). Globals whose shape we can't classify statically are
   left [null]; anything that reads them before a SETGLOBAL writes
   them will trip NullPointerException at runtime. *)
let emit_globals_init code globals =
  let n = Array.length globals in
  Jvm.Code.ldc_int code n;
  Jvm.Code.anewarray code "java/lang/Object";
  Jvm.Code.putstatic
    code
    ~class_:"Main"
    ~field:"GLOBALS"
    ~descriptor:"[Ljava/lang/Object;";
  for i = 0 to n - 1 do
    match Global_view.inspect_global globals i with
    | G_unsupported -> ()
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
    | G_block (tag, fields) ->
      Jvm.Code.getstatic
        code
        ~class_:"Main"
        ~field:"GLOBALS"
        ~descriptor:"[Ljava/lang/Object;";
      Jvm.Code.ldc_int code i;
      (* [emit_materialise_block_constant] needs a [state] for its
         [allocate_local] calls — synthesise a throwaway one. *)
      let throwaway_state =
        { code
        ; globals
        ; prims = [||]
        ; supported_prims = Hashtbl.create 0
        ; functions = Hashtbl.create 0
        ; fn_by_name = Hashtbl.create 0
        ; pc_to_label = Hashtbl.create 0
        ; branch_target_state = Hashtbl.create 0
        ; cfg = None
        ; block_params = Hashtbl.create 0
        ; acc_live = false
        ; acc_kind = K_int
        ; slots = []
        ; oc_stack_depth = 0
        ; next_local = 1
        ; pending_cmp = None
        ; nargs = 0
        ; ncaps = 0
        ; capture_kinds = []
        ; enclosing_function_name = None
        ; pending_handlers = Hashtbl.create 0
        ; open_traps = []
        ; fresh_oo_id_counter = ref 0
        ; pending_retaddrs = 0
        ; last_was_terminator = true
        ; slot_obj_locals = Hashtbl.create 8
        }
      in
      Emit_stack.emit_materialise_block_constant throwaway_state tag fields;
      Jvm.Code.aastore code
  done

let compile ~bc ~out_dir =
  let total = if debug_times () then Some (Timer.make ()) else None in
  let parsed = time_phase "parse-bytecode" (fun () -> Bytecode.read_exe bc) in
  let prim_table = Prim.find_supported_prims parsed in
  if Hashtbl.length prim_table = 0
  then
    failwith
      "java_of_ocaml: bytecode references none of the supported primitives \
       (caml_java_print_endline, caml_java_print_int, ...).";
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
  if debug_ir ()
  then (
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
    ir_smoke_main arr ~name_of_body ~fn_info_of_body ~prim_name ~fn_body_pcs;
    List.iter
      (fun fi ->
        ir_smoke_function arr ~name_of_body ~fn_info_of_body ~prim_name fi)
      !func_list);
  time_phase "kind-inference" (fun () ->
    List.iter
      (fun (fi : function_info) ->
        fi.return_kind := Inference.infer_return_kind arr !func_list fi;
        fi.arg_kinds := Inference.infer_arg_kinds arr prim_table fi)
      !func_list);
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
  let fresh_oo_id_counter = ref 0 in
  (* Globals-init prelude is emitted later — after we've decided
     between IR and legacy for the main body, so a failed IR attempt
     doesn't leave half-written globals-init bytes in [main_code]. *)
  let post_end_pc =
    if end_idx + 1 < Array.length arr then arr.(end_idx + 1).pc else max_int
  in
  let pc_to_label =
    collect_pc_to_label
      main_code
      ~arr
      ~scan_range:(start_idx, end_idx)
      ~target_range:(arr.(start_idx).pc, post_end_pc)
      ~skip_pcs:fn_body_pcs
  in
  let state =
    { code = main_code
    ; globals = parsed.globals
    ; prims = parsed.prims
    ; supported_prims = prim_table
    ; functions
    ; fn_by_name
    ; pc_to_label
    ; branch_target_state = Hashtbl.create 4
    ; cfg = None
    ; block_params = Hashtbl.create 0
    ; acc_live = false
    ; acc_kind = K_int
    ; slots = []
    ; oc_stack_depth = 0
    ; next_local = 1 (* local 0 reserved for [String[] args] *)
    ; pending_cmp = None
    ; nargs = 0
    ; ncaps = 0
    ; capture_kinds = []
    ; enclosing_function_name = None
    ; pending_handlers = Hashtbl.create 2
    ; open_traps = []
    ; fresh_oo_id_counter
    ; pending_retaddrs = 0
        ; last_was_terminator = true
        ; slot_obj_locals = Hashtbl.create 8
    }
  in
  if debug_labels ()
  then
    Hashtbl.iter
      (fun pc lbl ->
        Format.eprintf "[main] label_id=%d at pc=%d@." (Jvm.Code.label_id lbl) pc)
      pc_to_label;
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
      if not (ir_emit_enabled ())
      then None
      else (
        (* Don't filter out fn_body_pcs — the parser's block-boundary
           scan needs the full instruction stream to find successor
           PCs via addr_map. Function bodies aren't reachable via
           fall-through (their entry pc is only ever a caller of
           a CLOSURE/CLOSUREREC body-pc argument, which doesn't
           appear in [Instr.branch_targets]), so they won't get
           processed as blocks. *)
        let instrs = Array.to_list arr in
        match instrs with
        | [] -> None
        | first :: _ ->
          let last = List.nth instrs (List.length instrs - 1) in
          let start_pc = first.pc in
          let end_pc = last.pc + 1 in
          (* Emit into a scratch code so we can discard on IR
             failure without contaminating main_code. *)
          let scratch = Jvm.Code.create cp in
          Jvm.Code.set_min_locals scratch 1;
          (try
             let prog = Parse_bytecode.parse_main instrs ~start_pc ~end_pc in
             let typing = Jvm_typing.infer prog in
             Jvm_generate.emit_program
               ~code:scratch
               ~typing
               ~name_of_body
               ~fn_info_of_body
               ~prim_name
               prog;
             if debug_ir_emit ()
             then Format.eprintf "[ir_emit] <main>: used IR@.";
             Some scratch
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
             None))
    in
    (match try_main_ir () with
     | Some _scratch_ir_code ->
       emit_globals_init main_code parsed.globals;
       let instrs = Array.to_list arr in
       let first = List.hd instrs in
       let last = List.nth instrs (List.length instrs - 1) in
       let prog =
         Parse_bytecode.parse_main
           instrs
           ~start_pc:first.pc
           ~end_pc:(last.pc + 1)
       in
       let typing = Jvm_typing.infer prog in
       Jvm_generate.emit_program
         ~code:main_code
         ~typing
         ~name_of_body
         ~fn_info_of_body
         ~prim_name
         prog
     | None ->
       emit_globals_init main_code parsed.globals;
       emit_range state arr (start_idx, end_idx) ~skip_pcs:fn_body_pcs;
       (match Hashtbl.find_opt pc_to_label post_end_pc with
        | Some lbl -> Jvm.Code.mark_label main_code lbl
        | None -> ());
       drop_live_acc state;
       Jvm.Code.return_void main_code));
  let main_method =
    { Jvm.name = "main"
    ; descriptor = "([Ljava/lang/String;)V"
    ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
    ; code = main_code
    }
  in
  let globals_field =
    { Jvm.name = "GLOBALS"
    ; descriptor = "[Ljava/lang/Object;"
    ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
    }
  in
  let main_class_bytes =
    Jvm.assemble_class
      ~class_name:"Main"
      ~super_name:"java/lang/Object"
      ~cp
      ~fields:[ globals_field ]
      ~methods:[ main_method ]
      ~access_flags:0x0021 (* ACC_PUBLIC | ACC_SUPER *)
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
        let initial_slots =
          let rec make k =
            if k >= fn_info.nargs
            then []
            else { kind = K_obj; local = k + 1 } :: make (k + 1)
          in
          make 0
        in
        let pc_to_label =
          collect_pc_to_label
            apply_code
            ~arr
            ~scan_range:(fn_info.body_start_idx, fn_info.body_end_idx)
            ~target_range:
              (arr.(fn_info.body_start_idx).pc, arr.(fn_info.body_end_idx).pc)
            ~skip_pcs:(Hashtbl.create 0)
        in
        let cfg =
          Cfg.build
            arr
            ~body_start:fn_info.body_start_idx
            ~body_end:fn_info.body_end_idx
        in
        (* Pre-populate the fixed depth→local map with the incoming
           args. Arg [k] (from top) is at depth_from_bottom
           [nargs - 1 - k] and sits in JVM local [k + 1] by the apply
           method's signature. Every later [slot_obj_local] lookup
           returns the same local, stable across all paths. *)
        let fn_slot_obj_locals = Hashtbl.create 8 in
        for k = 0 to fn_info.nargs - 1 do
          Hashtbl.add fn_slot_obj_locals (fn_info.nargs - 1 - k) (k + 1)
        done;
        let state =
          { code = apply_code
          ; globals = parsed.globals
          ; prims = parsed.prims
          ; supported_prims = prim_table
          ; functions
          ; fn_by_name
          ; pc_to_label
          ; branch_target_state = Hashtbl.create 4
          ; cfg = Some cfg
          ; block_params = Hashtbl.create 4
          ; acc_live = false
          ; acc_kind = K_int
          ; slots = initial_slots
          ; oc_stack_depth = fn_info.nargs
          ; next_local = 1 + fn_info.nargs
          ; pending_cmp = None
          ; nargs = fn_info.nargs
          ; ncaps
          ; capture_kinds = cap_kinds
          ; enclosing_function_name = Some fn_info.name
          ; pending_handlers = Hashtbl.create 2
          ; open_traps = []
          ; fresh_oo_id_counter
          ; pending_retaddrs = 0
          ; last_was_terminator = true
          ; slot_obj_locals = fn_slot_obj_locals
          }
        in
        (* IR-first strategy when JAVA_OF_OCAML_IR=1: attempt the IR
           path into a fresh [Jvm.Code.t]; fall back to the legacy
           per-opcode emitter only on Not_supported / Unsupported.
           This lets us compile programs legacy can't (e.g. its
           pre-existing "POPTRAP without matching PUSHTRAP"
           misfires on deeper Stdlib code) as long as IR handles
           them. *)
        let try_ir () =
          if not (ir_emit_enabled ())
          then None
          else (
            let body_pc = arr.(fn_info.body_start_idx).pc in
            let end_pc = arr.(fn_info.body_end_idx).pc in
            try
              let prog, params, env_var =
                Parse_bytecode.parse_function
                  (Array.to_list arr)
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
              let ir_code = Jvm.Code.create fn_cp in
              Jvm.Code.set_min_locals ir_code (1 + fn_info.nargs);
              let typing = Jvm_typing.infer prog in
              let body_pc_to_fi = Hashtbl.create 64 in
              Hashtbl.iter
                (fun _name fi ->
                  Hashtbl.replace body_pc_to_fi fi.Function_info.body_pc fi)
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
              Jvm_generate.emit_program
                ~code:ir_code
                ~typing
                ~name_of_body
                ~fn_info_of_body
                ~prim_name
                ~arg_vars
                ~enclosing:(fn_info, env_var)
                prog;
              if debug_ir_emit ()
              then Format.eprintf "[ir_emit] %s: used IR@." fn_info.name;
              Some ir_code
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
              None)
        in
        let apply_code =
          match try_ir () with
          | Some ir_code -> ir_code
          | None ->
            emit_range
              state
              arr
              (fn_info.body_start_idx, fn_info.body_end_idx)
              ~skip_pcs:(Hashtbl.create 0);
            apply_code
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
          ; descriptor = Emit_closure.ctor_descriptor_for_captures cap_kinds
          ; access_flags = 0x0001
          ; code = ctor_code
          }
        in
        let apply_method =
          { Jvm.name = Printf.sprintf "apply%d" fn_info.nargs
          ; descriptor = Emit_apply.apply_descriptor_for_nargs fn_info.nargs
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
        let bytes =
          Jvm.assemble_class
            ~class_name:fn_info.name
            ~super_name:"Closure"
            ~cp:fn_cp
            ~fields
            ~methods:[ ctor; arity_method; apply_method ]
            ~access_flags:0x0031
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
    List.iter (fun (name, bytes) -> write_class name bytes) closure_class_files);
  match total with
  | Some t -> Format.eprintf "[times] total: %a s@." Timer.print t
  | None -> ()
