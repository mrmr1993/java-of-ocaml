open Instr
open Kind
open Function_info

(* Debug flags. Enable via [JAVA_OF_OCAML_DEBUG=times,primitives,functions,emit]. *)
let debug_times = Debug.find "times"
let debug_times_detail = Debug.find "times_detail"
let debug_primitives = Debug.find "primitives"
let debug_functions = Debug.find "functions"
let debug_ir_emit = Debug.find "ir_emit"

(* Per-compile tally of methods that hit the 64 KB [Code]-attribute
   ceiling AFTER [Method_split] ran. Every entry is a correctness
   concession: the body was replaced with a runtime-throwing stub,
   so any path that reaches it at runtime fails. Tracked and
   reported at end-of-compile (and crashes the build when
   [JAVA_OF_OCAML_STRICT_SIZE] is set, so production builds can't
   silently ship stubbed methods). *)
type oversized_stub =
  { owner : string       (* "<main>", "<helper>", "<closure>" *)
  ; name : string
  ; size : int
  }

let oversized_stubs : oversized_stub list ref = ref []

(* Gated by [JAVA_OF_OCAML_DEBUG=split_shape]. Dumps CFG structure
   of a program that couldn't be cut under the size limit, so we
   can see at a glance whether the stub is forced by one giant
   block, by heavy trap structure, by already-split helpers that
   went no further, or some other shape. *)
let debug_split_shape = Debug.find "split_shape"

let dump_cfg_shape ~owner ~name (prog : Code.program) =
  if not (debug_split_shape ())
  then ()
  else
    let open Code in
    let n_blocks = Addr.Map.cardinal prog.blocks in
    let total_instrs = ref 0 in
    let max_block_cost = ref 0 in
    let max_block_instrs = ref 0 in
    let n_pushtrap = ref 0 in
    let n_invoke_tail = ref 0 in
    let n_branch = ref 0 in
    let n_cond = ref 0 in
    let n_switch = ref 0 in
    let n_return = ref 0 in
    let n_raise = ref 0 in
    let n_stop = ref 0 in
    let n_poptrap = ref 0 in
    (* Back-edges = a block branches to a target whose address
       precedes its own in a DFS post-order. Approximate cheaply
       by "target ≤ this addr" — good enough to flag loop shape
       without a full dominator calculation. *)
    let back_edges = ref 0 in
    let count_cont_as_back_edge src (tgt, _) =
      if tgt <= src then incr back_edges
    in
    Addr.Map.iter
      (fun addr (b : block) ->
        let body_len = Array.length b.body in
        total_instrs := !total_instrs + body_len;
        if body_len > !max_block_instrs then max_block_instrs := body_len;
        let cost = Code_cost.block b in
        if cost > !max_block_cost then max_block_cost := cost;
        match b.branch with
        | Return _ -> incr n_return
        | Raise _ -> incr n_raise
        | Stop -> incr n_stop
        | Branch c ->
          incr n_branch;
          count_cont_as_back_edge addr c
        | Cond (_, c1, c2) ->
          incr n_cond;
          count_cont_as_back_edge addr c1;
          count_cont_as_back_edge addr c2
        | Switch (_, ints, tags) ->
          incr n_switch;
          Array.iter (count_cont_as_back_edge addr) ints;
          Array.iter (count_cont_as_back_edge addr) tags
        | Pushtrap (body, _, handler) ->
          incr n_pushtrap;
          count_cont_as_back_edge addr body;
          count_cont_as_back_edge addr handler
        | Poptrap c ->
          incr n_poptrap;
          count_cont_as_back_edge addr c
        | Invoke_tail _ -> incr n_invoke_tail)
      prog.blocks;
    let prog_cost = Code_cost.program prog in
    Format.eprintf
      "[split_shape] %s %s: blocks=%d instrs=%d prog_cost=%d \
       max_block=(cost=%d instrs=%d) \
       terminators=(branch=%d cond=%d switch=%d invoke_tail=%d \
       pushtrap=%d poptrap=%d return=%d raise=%d stop=%d) \
       back_edges=%d@."
      owner
      name
      n_blocks
      !total_instrs
      prog_cost
      !max_block_cost
      !max_block_instrs
      !n_branch
      !n_cond
      !n_switch
      !n_invoke_tail
      !n_pushtrap
      !n_poptrap
      !n_return
      !n_raise
      !n_stop
      !back_edges

let note_oversized_stub ?prog ~owner ~name ~size () =
  oversized_stubs := { owner; name; size } :: !oversized_stubs;
  Format.eprintf
    "[warning] %s %s oversized after split (%d bytes > 65535) — \
     body replaced with a runtime-throwing stub@."
    owner
    name
    size;
  match prog with
  | Some p -> dump_cfg_shape ~owner ~name p
  | None -> ()

let strict_size_mode () =
  match Sys.getenv_opt "JAVA_OF_OCAML_STRICT_SIZE" with
  | Some ("1" | "true" | "yes") -> true
  | _ -> false

let report_oversized_stubs_and_maybe_fail () =
  match !oversized_stubs with
  | [] -> ()
  | stubs ->
    let n = List.length stubs in
    Format.eprintf
      "[warning] %d method%s stubbed after exceeding the JVM 64 KB \
       [Code]-attribute limit; affected call paths fail at runtime.@."
      n
      (if n = 1 then "" else "s");
    List.iter
      (fun { owner; name; size } ->
        Format.eprintf "[warning]   %-10s %s (%d bytes)@." owner name size)
      (List.rev stubs);
    if strict_size_mode ()
    then
      failwith
        (Printf.sprintf
           "refusing to emit %d oversized stub%s \
            (JAVA_OF_OCAML_STRICT_SIZE=1). Run without the flag to \
            get the class files with stubs in place, or fix \
            [Method_split] to not give up on these programs."
           n
           (if n = 1 then "" else "s"))

(* Accumulating bucketed timer. [times_detail] aggregates per-step
   cost across a loop (per-function work inside emit-closures,
   per-helper work inside main's split-and-emit path) and prints
   the totals + call counts at the end. Zero cost when the flag
   is off. *)
module Timer_bucket = struct
  type entry = { mutable total : float; mutable count : int }
  type t =
    { table : (string, entry) Hashtbl.t
    ; label : string
    ; mutable printed : bool
    }
  let make label : t =
    let t = { table = Hashtbl.create 8; label; printed = false } in
    (* Print on process exit too, so a [failwith] inside an emitted
       bucket still leaves the partial breakdown visible. Flag guards
       against double-printing when the normal path already called
       [print]. *)
    at_exit (fun () ->
      if debug_times_detail () && not t.printed
      then (
        t.printed <- true;
        let entries =
          Hashtbl.fold (fun k v acc -> (k, v) :: acc) t.table []
          |> List.sort (fun (_, a) (_, b) -> compare b.total a.total)
        in
        let total = List.fold_left (fun a (_, e) -> a +. e.total) 0.0 entries in
        Format.eprintf "[times_detail] %s (at_exit) total=%.2fs:@." t.label total;
        List.iter
          (fun (k, e) ->
            Format.eprintf
              "[times_detail]   %-24s %6.2fs (%d calls, %.2fms avg)@."
              k e.total e.count
              (1000.0 *. e.total /. float_of_int (max 1 e.count)))
          entries));
    t
  let track t name f =
    if not (debug_times_detail ())
    then f ()
    else
      let start = Sys.time () in
      let r = f () in
      let elapsed = Sys.time () -. start in
      let e =
        match Hashtbl.find_opt t.table name with
        | Some e -> e
        | None ->
          let e = { total = 0.0; count = 0 } in
          Hashtbl.add t.table name e;
          e
      in
      e.total <- e.total +. elapsed;
      e.count <- e.count + 1;
      r
  let snapshot fmt ~label (t : t) =
    if debug_times_detail ()
    then (
      let entries =
        Hashtbl.fold (fun k v acc -> (k, v) :: acc) t.table []
        |> List.sort (fun (_, a) (_, b) -> compare b.total a.total)
      in
      let total = List.fold_left (fun a (_, e) -> a +. e.total) 0.0 entries in
      Format.fprintf fmt "[times_detail] %s total=%.2fs:@." label total;
      List.iter
        (fun (k, e) ->
          Format.fprintf
            fmt
            "[times_detail]   %-24s %6.2fs (%d calls, %.2fms avg)@."
            k e.total e.count
            (1000.0 *. e.total /. float_of_int (max 1 e.count)))
        entries)
  let print fmt ~label (t : t) =
    if debug_times_detail ()
    then (
      t.printed <- true;
      snapshot fmt ~label t)
end

(* Method-body size limit passed to [Method_split]. The JVM's
   [Code]-attribute cap is 65535 bytes, but [Code_cost] is an
   estimate (conservative by design, but not byte-exact); using the
   full cap as the split budget left too little headroom and some
   post-split helpers overran by a few kilobytes on the OCaml 4.14
   Base / Core stdlib. A 15% margin has been enough to eat the
   residual estimate error on every input tested.
   Tests override via [JAVA_OF_OCAML_SPLIT_THRESHOLD=<bytes>] to
   force splitting on smaller bodies — far easier than coaxing
   OCaml into producing a genuine 55 KB method. *)
let method_size_limit =
  lazy
    (match Sys.getenv_opt "JAVA_OF_OCAML_SPLIT_THRESHOLD" with
     | Some s ->
       (match int_of_string_opt (String.trim s) with
        | Some n when n > 0 -> n
        | _ -> 55000)
     | None -> 55000)
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

let run_block_prealloc ~what prog =
  let prog, { Block_preallocation.blocks_rewritten; fields_streamed } =
    Block_preallocation.run prog
  in
  if debug_eval ()
  then
    Format.eprintf
      "[block_prealloc] %s: rewrote %d block%s, streamed %d field%s@."
      what
      blocks_rewritten
      (if blocks_rewritten = 1 then "" else "s")
      fields_streamed
      (if fields_streamed = 1 then "" else "s");
  prog

let optimize ~what prog =
  let prog = run_block_prealloc ~what prog in
  let prog = run_eval ~what prog in
  let prog = run_deadcode ~what prog in
  (* Spill long-lived few-use vars through a shared Block carrier
     before [Method_split] sees them. Shrinks the intra-block
     chunker's live-at-cut sets on large-scale inputs, which in turn
     narrows the helper method arities downstream. *)
  let prog = Spill_long_lived.f prog in
  (* Collapse cross-block forwarding chains into one threaded
     carrier — attacks the inter-block equivalent of the same
     pathology, so [Method_split]'s cut-augmented helpers stop
     carrying hundreds of pass-through params each. *)
  Cross_block_spill.f prog


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
    (* Preserve the full 64-bit payload as a boxed [java.lang.Long].
       Stdlib's [infinity] / [nan] / [max_float] / [min_float] are
       constructed via [caml_int64_float_of_bits] on specific bit
       patterns (e.g. [0x7FF0_0000_0000_0000L]); truncating to 32
       bits silently zeros the high half and yields 0.0 at init. *)
    Jvm.Code.ldc_long code n;
    Kind.emit_box_long code
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
    Jvm.Code.ldc_long code n;
    Kind.emit_box_long code;
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

(* Wire runtime-side references that need the predefined exception
   descriptors from [GLOBALS]. Runs right after [emit_globals_init]
   so [GLOBALS[i]] is populated by the time we read it.

   Currently just [End_of_file] at slot 4, used by [Channel] on EOF. *)
let emit_runtime_init_after_globals main_code =
  Jvm.Code.getstatic
    main_code
    ~class_:"Main"
    ~field:"GLOBALS"
    ~descriptor:"[Ljava/lang/Object;";
  Jvm.Code.ldc_int main_code 4;
  Jvm.Code.aaload main_code;
  Jvm.Code.putstatic
    main_code
    ~class_:"Channel"
    ~field:"endOfFileExn"
    ~descriptor:"Ljava/lang/Object;"

(* [emit_globals_init globals ~main_code] allocates the [GLOBALS]
   array in [main_code] and then populates it. Entries flow into
   [main_code] until it approaches the 65535-byte [Code]-attribute
   limit, then spill into sibling classes — each chunk becomes a
   standalone class [Main$globals_<N>] with its own constant pool
   and a single [init()V] static method. [main_code] reaches them
   via cross-class [invokestatic].

   Using sibling classes (rather than sibling methods on [Main])
   keeps each chunk's CP independent; [Main]'s CP was overflowing
   the class-file u2 limit (65534 entries) on data-heavy inputs
   where globals-init alone contributed hundreds of thousands of
   [ldc_string] / [new Block] entries.

   Chunk boundary is decided from the actual emitted byte count
   ([Jvm.Code.current_size]), not a fixed entry count: globals span a
   wide size range (a small int constant compiles to a few bytes; a
   large block-shaped global with nested constants can run into the
   hundreds), and a fixed-N rule has to either be very conservative
   to be safe or risk overflow on data-heavy inputs.

   Margin: [chunk_byte_limit] sits ~5 KB under the JVM cap so the
   next entry plus the closing [return_void] / [invokestatic]
   sequence can't push past the boundary. A single global entry
   that is itself > 5 KB (e.g. a giant inline data table) would
   still overflow — that's a separate problem requiring per-entry
   splitting and isn't observed on the inputs we currently run. *)
let chunk_byte_limit = 60000

let assemble_sibling_class
      ?source_file
      ~class_name
      ~method_name
      ~descriptor
      ~cp
      ~code
      () =
  Jvm.assemble_class
    ?source_file
    ~class_name
    ~super_name:"java/lang/Object"
    ~cp
    ~fields:[]
    ~methods:
      [ { Jvm.name = method_name
        ; descriptor
        ; access_flags = 0x0009 (* ACC_PUBLIC | ACC_STATIC *)
        ; code
        }
      ]
    ~access_flags:0x0021 (* ACC_PUBLIC | ACC_SUPER *)
    ()

let emit_globals_init globals ~main_code =
  let n = Array.length globals in
  Jvm.Code.ldc_int main_code n;
  Jvm.Code.anewarray main_code "java/lang/Object";
  Jvm.Code.putstatic
    main_code
    ~class_:"Main"
    ~field:"GLOBALS"
    ~descriptor:"[Ljava/lang/Object;";
  let sibling_classes = ref [] in
  let chunk_idx = ref 0 in
  let current = ref None in
  let finalize_helper () =
    match !current with
    | None -> ()
    | Some (helper_cp, helper_code, helper_class) ->
      Jvm.Code.return_void helper_code;
      let bytes =
        assemble_sibling_class
          ~class_name:helper_class
          ~method_name:"init"
          ~descriptor:"()V"
          ~cp:helper_cp
          ~code:helper_code
          ()
      in
      sibling_classes := (helper_class, bytes) :: !sibling_classes;
      Jvm.Code.invokestatic
        main_code
        ~class_:helper_class
        ~method_:"init"
        ~descriptor:"()V";
      current := None;
      incr chunk_idx
  in
  let start_helper () =
    let helper_class = Printf.sprintf "Main$globals_%d" !chunk_idx in
    let helper_cp = Jvm.Cp.create () in
    let helper_code = Jvm.Code.create helper_cp in
    Jvm.Code.set_min_locals helper_code 0;
    current := Some (helper_cp, helper_code, helper_class);
    helper_code
  in
  for i = 0 to n - 1 do
    let target =
      match !current with
      | Some (_, c, _) -> c
      | None -> start_helper ()
    in
    emit_globals_entry target i (Global_view.inspect_global globals i);
    match !current with
    | Some (_, c, _) when Jvm.Code.current_size c > chunk_byte_limit ->
      finalize_helper ()
    | _ -> ()
  done;
  finalize_helper ();
  List.rev !sibling_classes

let compile_t
      ?(print_functions = [])
      ?(print_ir = [])
      ?(print_tree = [])
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
    let lo = ref 0 and hi = ref n in
    while !lo < !hi do
      let mid = (!lo + !hi) / 2 in
      if sorted_body_pcs.(mid) > pc then hi := mid else lo := mid + 1
    done;
    if !lo >= n then max_int else sorted_body_pcs.(!lo)
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
        let pre_start, _ =
          Parse_bytecode.range_indices arr ~start_pc:body_pc ~end_pc:(body_pc + 1)
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
  (match print_tree with
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
         Print_tree.print
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
  (* Sibling classes emitted alongside [Main] to keep each
     constant pool under the JVM u2 limit of 65534 entries. The
     globals-init helpers live here, as do the [Method_split]
     helpers for main's body (each on its own [Main$split_<N>]
     class so every helper's CP is independent of [Main]'s). *)
  let main_sibling_classes = ref [] in
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
  (* [source_file_from] needs the file of the smallest pc >=
     [pc_range_start] in the debug map. The original implementation
     did [Hashtbl.iter] per call, which was quadratic across
     ~111k closures × full-debug-map scan (≈88s on the test input).
     Precompute a sorted (pc, file) array once and binary-search per
     query: O(n log n) build + O(log n) per call. *)
  let debug_pc_sorted =
    let arr =
      Hashtbl.fold
        (fun pc (d : Bytecode.debug_loc) acc ->
          if d.file = "" then acc else (pc, d.file) :: acc)
        parsed.debug
        []
      |> Array.of_list
    in
    Array.sort (fun (a, _) (b, _) -> compare a b) arr;
    arr
  in
  let source_file_from pc_range_start =
    let n = Array.length debug_pc_sorted in
    let lo = ref 0 and hi = ref n in
    while !lo < !hi do
      let m = (!lo + !hi) / 2 in
      let pc, _ = debug_pc_sorted.(m) in
      if pc < pc_range_start then lo := m + 1 else hi := m
    done;
    if !lo >= n
    then None
    else
      let _, f = debug_pc_sorted.(!lo) in
      Some f
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
    (* Preserve the full relative path (typically repo-root-relative)
       so stack traces pinpoint the source file without ambiguity.
       JVMS 4.7.10 reserves [SourceFile] for a bare name, but real
       JVMs treat it as opaque and print whatever is there — which is
       what stack-trace consumers need. *)
    match !best with
    | Some (_, f) -> Some f
    | None -> source_file_from 0
  in
  let main_tb = Timer_bucket.make "emit-main" in
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
             let prog =
               Timer_bucket.track main_tb "parse_main" (fun () ->
                 Parse_bytecode.parse_main arr ~start_pc ~end_pc)
             in
             let prog =
               Timer_bucket.track main_tb "optimize" (fun () ->
                 optimize ~what:"<main>" prog)
             in
             let typing =
               Timer_bucket.track main_tb "typing.infer" (fun () ->
                 Jvm_typing.infer prog)
             in
             let limit = Lazy.force method_size_limit in
             let split_result =
               Timer_bucket.track main_tb "method_split.split" (fun () ->
                 Method_split.split
                   ~limit
                   ~class_name:"Main"
                   ~is_static:true
                   ~return_kind:Method_split.Return_void
                   prog)
             in
             (* Move each [Method_split] helper out to its own sibling
                class [Main$split_<idx>]. Each sibling has its own
                constant pool, so the helpers' CP pressure stops
                accumulating into [Main]'s. Invoke_tail targets in
                the head (and in other helpers) that reference
                [Main.<helper>] are rewritten to
                [Main$split_<idx>.<helper>]. *)
             let placement = Hashtbl.create (List.length split_result.helpers) in
             List.iteri
               (fun idx (h : Method_split.helper) ->
                 Hashtbl.add
                   placement
                   h.method_name
                   (Printf.sprintf "Main$split_%d" idx))
               split_result.helpers;
             let rewrite_last (l : Code.last) =
               match l with
               | Code.Invoke_tail ({ class_ = "Main"; method_; _ } as it) ->
                 (match Hashtbl.find_opt placement method_ with
                  | Some sibling -> Code.Invoke_tail { it with class_ = sibling }
                  | None -> l)
               | _ -> l
             in
             let rewrite_prog (p : Code.program) =
               { p with
                 Code.blocks =
                   Code.Addr.Map.map
                     (fun (b : Code.block) -> { b with branch = rewrite_last b.branch })
                     p.blocks
               }
             in
             let head = rewrite_prog split_result.head in
             let split_sibling_classes =
               Timer_bucket.track main_tb "emit_helpers" (fun () ->
                 List.map
                   (fun (h : Method_split.helper) ->
                     let helper_cp = Jvm.Cp.create () in
                     let helper_code = Jvm.Code.create helper_cp in
                     Jvm.Code.set_min_locals
                       helper_code
                       (List.length h.params);
                     let h_prog = rewrite_prog h.prog in
                     (try
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
                          h_prog
                      with Failure msg ->
                        Format.eprintf
                          "[ir_emit] main helper %s: %s (params=%d, \
                           blocks=%d)@."
                          h.method_name
                          msg
                          (List.length h.params)
                          (Code.Addr.Map.cardinal h_prog.blocks);
                        raise (Failure msg));
                     (* [Method_split]'s cost estimator sometimes
                        underestimates — a helper that looked under
                        the 64 KB limit emits past it and the class
                        assembler raises [Method_too_large]. Detect
                        that here and swap the body for a runtime-
                        throwing stub so the rest of the program
                        still compiles. The stub fires only if
                        execution reaches this helper; for most
                        programs that path is never exercised. *)
                     let helper_cp, helper_code =
                       let size = Jvm.Code.resolved_size helper_code in
                       (match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
                        | Some s
                          when List.mem "cost_vs_emit"
                                 (String.split_on_char ',' s) ->
                          let est = Code_cost.program h_prog in
                          Format.eprintf
                            "[cost_vs_emit] %s: estimate=%d actual=%d \
                             ratio=%.2f blocks=%d@."
                            h.method_name
                            est
                            size
                            (float_of_int size /. float_of_int (max 1 est))
                            (Code.Addr.Map.cardinal h_prog.blocks)
                        | _ -> ());
                       if size <= 65535
                       then helper_cp, helper_code
                       else (
                         note_oversized_stub
                           ~prog:h_prog
                           ~owner:"<helper>"
                           ~name:h.method_name
                           ~size
                           ();
                         let stub_cp = Jvm.Cp.create () in
                         let stub = Jvm.Code.create stub_cp in
                         Jvm.Code.set_min_locals
                           stub
                           (List.length h.params);
                         Jvm.Code.new_
                           stub
                           "java/lang/UnsupportedOperationException";
                         Jvm.Code.dup stub;
                         Jvm.Code.ldc_string
                           stub
                           (Printf.sprintf
                              "Main helper %s too large to split (%d bytes > 65535)"
                              h.method_name
                              size);
                         Jvm.Code.invokespecial
                           stub
                           ~class_:
                             "java/lang/UnsupportedOperationException"
                           ~method_:"<init>"
                           ~descriptor:"(Ljava/lang/String;)V";
                         Jvm.Code.athrow stub;
                         stub_cp, stub)
                     in
                     let sibling = Hashtbl.find placement h.method_name in
                     let bytes =
                       assemble_sibling_class
                         ?source_file:main_source_file
                         ~class_name:sibling
                         ~method_name:h.method_name
                         ~descriptor:h.descriptor
                         ~cp:helper_cp
                         ~code:helper_code
                         ()
                     in
                     sibling, bytes)
                   split_result.helpers)
             in
             Some (head, typing, split_sibling_classes)
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
     | Some (head, typing, split_sibling_classes) ->
       emit_sys_argv_prologue main_code;
       let globals_sibling_classes =
         Timer_bucket.track main_tb "emit_globals_init" (fun () ->
           emit_globals_init parsed.globals ~main_code)
       in
       emit_runtime_init_after_globals main_code;
       main_sibling_classes :=
         split_sibling_classes @ globals_sibling_classes;
       Timer_bucket.track main_tb "emit_head" (fun () ->
         try
           Jvm_generate.emit_program
             ~code:main_code
             ~typing
             ~name_of_body
             ~fn_info_of_body
             ~prim_name
             ~is_static:true
             ~line_of_pc
             head
         with Failure msg ->
           Format.eprintf
             "[ir_emit] main head: %s (blocks=%d)@."
             msg
             (Code.Addr.Map.cardinal head.blocks);
           raise (Failure msg));
       let size =
         Timer_bucket.track main_tb "resolved_size" (fun () ->
           Jvm.Code.resolved_size main_code)
       in
       if size > 65535
       then (
         note_oversized_stub
           ~prog:head
           ~owner:"<main>"
           ~name:"main"
           ~size
           ();
         main_split_helpers := [];
         main_sibling_classes := [];
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
           (List.length split_sibling_classes)
     | None ->
       emit_sys_argv_prologue main_code;
       let globals_sibling_classes =
         emit_globals_init parsed.globals ~main_code
       in
       emit_runtime_init_after_globals main_code;
       main_sibling_classes := globals_sibling_classes;
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
  Timer_bucket.print Format.err_formatter ~label:"emit-main" main_tb;
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
  let closure_tb = Timer_bucket.make "emit-closures" in
  let closure_class_files = time_phase "emit-closures" (fun () ->
    let r =
    let fn_count = List.length !func_list in
    let fn_progress = ref 0 in
    let fn_progress_start = Sys.time () in
    let progress_step = max 1 (fn_count / 20) in
    List.map
      (fun (fn_info : function_info) ->
        incr fn_progress;
        if debug_times () && !fn_progress mod progress_step = 0
        then (
          Format.eprintf
            "[times] emit-closures: %d/%d (%.1f s elapsed)@."
            !fn_progress
            fn_count
            (Sys.time () -. fn_progress_start);
          if debug_times_detail ()
          then
            Timer_bucket.snapshot
              Format.err_formatter
              ~label:"emit-closures (running)"
              closure_tb);
        Timer_bucket.track closure_tb "fn_total" (fun () ->
        let cap_kinds, ncaps, fn_cp, ctor_code =
          Timer_bucket.track closure_tb "ctor_emit" (fun () ->
            let cap_kinds = !(fn_info.capture_kinds) in
            let ncaps = List.length cap_kinds in
            let fn_cp = Jvm.Cp.create () in
            let ctor_code = Jvm.Code.create fn_cp in
            (* Each capture param occupies [local_slots_for_kind] slots
               in the constructor's local frame; K_int / K_float use 2
               slots, everything else uses 1. *)
            let total_slots =
              List.fold_left
                (fun acc k -> acc + Kind.local_slots_for_kind k) 1 cap_kinds
            in
            Jvm.Code.set_min_locals ctor_code total_slots;
            Jvm.Code.aload ctor_code 0;
            Jvm.Code.invokespecial
              ctor_code
              ~class_:"Closure"
              ~method_:"<init>"
              ~descriptor:"()V";
            let _ =
              List.fold_left
                (fun (i, slot) k ->
                  Jvm.Code.aload ctor_code 0;
                  emit_load_for_kind ctor_code slot k;
                  Jvm.Code.putfield
                    ctor_code
                    ~class_:fn_info.name
                    ~field:(Printf.sprintf "cap%d" i)
                    ~descriptor:(jvm_type_of_kind k);
                  i + 1, slot + Kind.local_slots_for_kind k)
                (0, 1)
                cap_kinds
            in
            Jvm.Code.return_void ctor_code;
            cap_kinds, ncaps, fn_cp, ctor_code)
        in
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
                Timer_bucket.track closure_tb "parse_function" (fun () ->
                  Parse_bytecode.parse_function
                    arr
                    ~start_pc:body_pc
                    ~end_pc:(end_pc + 1)
                    ~nargs:fn_info.nargs
                    ~ncaps)
              in
              let arg_vars =
                let rec take n = function
                  | _ when n = 0 -> []
                  | [] -> []
                  | x :: xs -> x :: take (n - 1) xs
                in
                take fn_info.nargs params
              in
              let prog =
                Timer_bucket.track closure_tb "optimize" (fun () ->
                  optimize ~what:fn_info.name prog)
              in
              let ir_code = Jvm.Code.create fn_cp in
              Jvm.Code.set_min_locals ir_code (1 + fn_info.nargs);
              let typing =
                Timer_bucket.track closure_tb "typing.infer" (fun () ->
                  Jvm_typing.infer prog)
              in
              let limit = Lazy.force method_size_limit in
              let split_result =
                Timer_bucket.track closure_tb "method_split.split" (fun () ->
                  Method_split.split
                    ~limit
                    ~class_name:fn_info.name
                    ~is_static:false
                    ~return_kind:Method_split.Return_object
                    ~env_var
                    prog)
              in
              let split_helpers =
                Timer_bucket.track closure_tb "emit_helpers" (fun () ->
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
                    split_result.helpers)
              in
              Timer_bucket.track closure_tb "emit_head" (fun () ->
                Jvm_generate.emit_program
                  ~code:ir_code
                  ~typing
                  ~name_of_body
                  ~fn_info_of_body
                  ~prim_name
                  ~arg_vars
                  ~enclosing:(fn_info, env_var)
                  ~line_of_pc
                  split_result.head);
              let head_size =
                Timer_bucket.track closure_tb "resolved_size" (fun () ->
                  Jvm.Code.resolved_size ir_code)
              in
              let helper_sizes =
                Timer_bucket.track closure_tb "resolved_size" (fun () ->
                  List.map
                    (fun (m : Jvm.method_desc) ->
                      Jvm.Code.resolved_size m.code)
                    split_helpers)
              in
              (match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
               | Some s
                 when List.mem "cost_vs_emit"
                        (String.split_on_char ',' s) ->
                 let est = Code_cost.program split_result.head in
                 Format.eprintf
                   "[cost_vs_emit] %s head: estimate=%d actual=%d \
                    ratio=%.2f blocks=%d@."
                   fn_info.name
                   est
                   head_size
                   (float_of_int head_size /. float_of_int (max 1 est))
                   (Code.Addr.Map.cardinal split_result.head.blocks);
                 List.iter2
                   (fun (h : Method_split.helper) actual ->
                     let est = Code_cost.program h.prog in
                     Format.eprintf
                       "[cost_vs_emit] %s/%s: estimate=%d actual=%d \
                        ratio=%.2f blocks=%d@."
                       fn_info.name
                       h.method_name
                       est
                       actual
                       (float_of_int actual /. float_of_int (max 1 est))
                       (Code.Addr.Map.cardinal h.prog.blocks))
                   split_result.helpers
                   helper_sizes
               | _ -> ());
              let too_big size = size > 65535 in
              if too_big head_size || List.exists too_big helper_sizes
              then (
                let worst =
                  List.fold_left max head_size helper_sizes
                in
                note_oversized_stub
                  ~prog
                  ~owner:"<closure>"
                  ~name:fn_info.name
                  ~size:worst
                  ();
                if debug_ir_emit ()
                then
                  Format.eprintf
                    "[ir_emit]   detail: %s head=%d helpers=[%s]@."
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
        Timer_bucket.track closure_tb "fn_finalize" (fun () ->
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
        let fn_source_file =
          Timer_bucket.track closure_tb "source_file_from" (fun () ->
            source_file_from fn_info.body_pc)
        in
        let bytes =
          Timer_bucket.track closure_tb "assemble_class" (fun () ->
            Jvm.assemble_class
              ?source_file:fn_source_file
              ~class_name:fn_info.name
              ~super_name:"Closure"
              ~cp:fn_cp
              ~fields
              ~methods:([ ctor; arity_method; apply_method ] @ split_helpers)
              ~access_flags:0x0031
              ())
        in
        fn_info.name, bytes)))
      !func_list
    in
    Timer_bucket.print Format.err_formatter ~label:"emit-closures" closure_tb;
    r)
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
    write_class "DummyClosure" (Jvm.dummy_closure_class_bytes ());
    write_class "Compare" (Jvm.compare_class_bytes ());
    write_class "Channel" (Jvm.channel_class_bytes ());
    write_class "Bytes" (Jvm.bytes_class_bytes ());
    write_class "Format" (Jvm.format_class_bytes ());
    write_class "Ephemeron" (Jvm.ephemeron_class_bytes ());
    write_class "JavaFFI" (Jvm.java_ffi_class_bytes ());
    write_class "Mutex" (Jvm.mutex_class_bytes ());
    write_class "CondVar" (Jvm.cond_var_class_bytes ());
    write_class "BigArray" (Jvm.big_array_class_bytes ());
    write_class "ThreadPrim" (Jvm.thread_prim_class_bytes ());
    List.iter (fun (name, bytes) -> write_class name bytes) !main_sibling_classes;
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
      ?(print_tree = [])
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
  oversized_stubs := [];
  compile_t ~print_functions ~print_ir ~print_tree ~parsed ~out_dir ();
  report_oversized_stubs_and_maybe_fail ()

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
