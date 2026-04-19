(* IR-to-JVM emitter. Phase 2 scope: int arith / comparisons /
   constants / Assign / Branch / Cond / Return / Stop. Every other
   expr or terminator raises [Unsupported]. Callers in [compile.ml]
   can catch and fall back to the legacy per-opcode emitter during
   the transition. *)

exception Unsupported of string

let debug_ir_gen_trace =
  match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
  | None -> false
  | Some s ->
    List.mem "ir_gen_trace" (List.map String.trim (String.split_on_char ',' s))

type ctx =
  { code : Jvm.Code.t
  ; typing : Jvm_typing.t
  ; var_local : (int, int) Hashtbl.t
  ; labels : (Code.Addr.t, Jvm.Code.label) Hashtbl.t
  ; name_of_body : int -> string
  ; fn_info_of_body : int -> Function_info.function_info option
  ; prim_name : int -> string
  ; enclosing : (Function_info.function_info * Code.Var.t) option
  ; fresh_oo_id : int ref
  ; mutable next_local : int
  ; block_start : (Code.Addr.t, Jvm.Code.label) Hashtbl.t
        (* Start label per block (same as [labels]; kept for
           clarity). *)
  ; block_end : (Code.Addr.t, Jvm.Code.label) Hashtbl.t
        (* End-of-block label allocated on first need (Pushtrap
           processing) and marked by emit_block at that block's
           final instruction position. *)
  ; mutable pending_handlers : pending_handler list
  }

and pending_handler =
  { protected : Code.Addr.Set.t
  ; handler_lbl : Jvm.Code.label
  }

let kind_of ctx v = Jvm_typing.kind ctx.typing v

let local_of ctx v =
  match Hashtbl.find_opt ctx.var_local (Code.Var.idx v) with
  | Some l -> l
  | None ->
    let k = kind_of ctx v in
    let slots = Kind.local_slots_for_kind k in
    let l = ctx.next_local in
    ctx.next_local <- l + slots;
    Jvm.Code.set_min_locals ctx.code ctx.next_local;
    Hashtbl.add ctx.var_local (Code.Var.idx v) l;
    l

let label_of ctx addr =
  match Hashtbl.find_opt ctx.labels addr with
  | Some l -> l
  | None ->
    let l = Jvm.Code.fresh_label ctx.code in
    Hashtbl.add ctx.labels addr l;
    l

(* Load Var v onto the JVM operand stack. The env Var (if any) maps
   to [aload 0] — in an apply method, local 0 is [this]. *)
let emit_load ctx v =
  match ctx.enclosing with
  | Some (_, env_var) when Code.Var.equal v env_var ->
    Jvm.Code.aload ctx.code 0
  | _ ->
    let k = kind_of ctx v in
    let l = local_of ctx v in
    Kind.emit_load_for_kind ctx.code l k

(* Store top of JVM operand stack into Var v's local, coercing if the
   producing kind differs from v's declared kind. *)
let emit_store ctx v ~from:from_kind =
  let k = kind_of ctx v in
  (* Convert [from_kind] -> [k] at the top of stack. *)
  (match from_kind, k with
   | a, b when a = b -> ()
   | Kind.K_int, Kind.K_obj -> Kind.emit_box_int ctx.code
   | Kind.K_float, Kind.K_obj -> Kind.emit_box_float ctx.code
   | Kind.K_obj, Kind.K_int ->
     Jvm.Code.checkcast ctx.code "java/lang/Integer";
     Jvm.Code.invokevirtual
       ctx.code
       ~class_:"java/lang/Integer"
       ~method_:"intValue"
       ~descriptor:"()I"
   | Kind.K_obj, Kind.K_float ->
     Jvm.Code.checkcast ctx.code "java/lang/Double";
     Jvm.Code.invokevirtual
       ctx.code
       ~class_:"java/lang/Double"
       ~method_:"doubleValue"
       ~descriptor:"()D"
   | _ ->
     (* K_obj / reference kinds — no conversion needed at JVM level. *)
     ());
  let l = local_of ctx v in
  Kind.emit_store_for_kind ctx.code l k

(* Emit an [Int] constant onto the stack as a JVM [int]. *)
let emit_int_const ctx n = Jvm.Code.ldc_int ctx.code n

let rec emit_constant ctx (c : Code.constant) : Kind.kind =
  match c with
  | Int n ->
    emit_int_const ctx n;
    K_int
  | Null ->
    Jvm.Code.aconst_null ctx.code;
    K_obj
  | String s ->
    Jvm.Code.ldc_string ctx.code s;
    K_string
  | Float f ->
    Jvm.Code.ldc_double ctx.code f;
    K_float
  | Block (tag, fields) ->
    (* Materialise a constant Block recursively. *)
    let n = Array.length fields in
    Jvm.Code.new_ ctx.code "Block";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code tag;
    Jvm.Code.ldc_int ctx.code n;
    Jvm.Code.anewarray ctx.code "java/lang/Object";
    Array.iteri
      (fun i c ->
        Jvm.Code.dup ctx.code;
        Jvm.Code.ldc_int ctx.code i;
        let k = emit_constant ctx c in
        (match k with
         | Kind.K_int -> Kind.emit_box_int ctx.code
         | Kind.K_float -> Kind.emit_box_float ctx.code
         | _ -> ());
        Jvm.Code.aastore ctx.code)
      fields;
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    K_obj

(* Load a prim_arg onto the stack and return its Kind. *)
let emit_prim_arg ctx (pa : Code.prim_arg) : Kind.kind =
  match pa with
  | Pv v ->
    emit_load ctx v;
    kind_of ctx v
  | Pc c -> emit_constant ctx c

(* Ensure top of stack is [K_int]. *)
let ensure_int ctx k =
  match k with
  | Kind.K_int -> ()
  | Kind.K_obj ->
    Jvm.Code.checkcast ctx.code "java/lang/Integer";
    Jvm.Code.invokevirtual
      ctx.code
      ~class_:"java/lang/Integer"
      ~method_:"intValue"
      ~descriptor:"()I"
  | _ -> raise (Unsupported "ensure_int: unexpected kind")

(* Emit a C primitive call by name. Args have already been parsed
   into [prim_arg list]; they're all Pv or Pc. The handler dispatches
   on known primitive names and emits specialised bytecode.
   Unknown names raise [Unsupported]. *)
let emit_ccall ctx name args =
  let load_args_obj () =
    List.iter
      (fun pa ->
        match (pa : Code.prim_arg) with
        | Pv v ->
          emit_load ctx v;
          (match kind_of ctx v with
           | K_int -> Kind.emit_box_int ctx.code
           | K_float -> Kind.emit_box_float ctx.code
           | _ -> ())
        | Pc c -> ignore (emit_constant ctx c))
      args
  in
  let _ = load_args_obj in
  let as_string v =
    emit_load ctx v;
    match kind_of ctx v with
    | K_string -> ()
    | _ -> Jvm.Code.checkcast ctx.code "java/lang/String"
  in
  let as_bytes v =
    emit_load ctx v;
    match kind_of ctx v with
    | _ -> Jvm.Code.checkcast ctx.code "Bytes"
  in
  let as_block v =
    emit_load ctx v;
    match kind_of ctx v with
    | K_block _ -> ()
    | _ -> Jvm.Code.checkcast ctx.code "Block"
  in
  let as_int v =
    emit_load ctx v;
    match kind_of ctx v with
    | K_int -> ()
    | _ ->
      Jvm.Code.checkcast ctx.code "java/lang/Integer";
      Jvm.Code.invokevirtual
        ctx.code
        ~class_:"java/lang/Integer"
        ~method_:"intValue"
        ~descriptor:"()I"
  in
  match name with
  | "caml_ml_string_length" | "caml_string_length" ->
    (match args with
     | [ Pv s ] ->
       as_string s;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"length"
         ~descriptor:"()I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_string_length arity"))
  | "caml_ml_bytes_length" | "caml_bytes_length" ->
    (* Accept both Bytes and String at runtime — Stdlib frequently
       passes Strings via unsafe_of_string. *)
    (match args with
     | [ Pv b ] ->
       emit_load ctx b;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Bytes"
         ~method_:"staticLength"
         ~descriptor:"(Ljava/lang/Object;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_length arity"))
  | "caml_string_get" ->
    (match args with
     | [ Pv s; Pv i ] ->
       as_string s;
       as_int i;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"charAt"
         ~descriptor:"(I)C";
       Kind.K_int
     | _ -> raise (Unsupported "caml_string_get arity"))
  | "caml_bytes_get" ->
    (match args with
     | [ Pv b; Pv i ] ->
       emit_load ctx b;
       as_int i;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Bytes"
         ~method_:"staticGet"
         ~descriptor:"(Ljava/lang/Object;I)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_get arity"))
  | "caml_bytes_set" ->
    (match args with
     | [ Pv b; Pv i; Pv v ] ->
       as_bytes b;
       as_int i;
       as_int v;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"set"
         ~descriptor:"(II)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_set arity"))
  | "caml_create_bytes" ->
    (match args with
     | [ Pv n ] ->
       Jvm.Code.new_ ctx.code "Bytes";
       Jvm.Code.dup ctx.code;
       as_int n;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Bytes"
         ~method_:"<init>"
         ~descriptor:"(I)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_create_bytes arity"))
  | "caml_ml_flush" ->
    (match args with
     | [ Pv chan ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"flush"
         ~descriptor:"()V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_flush arity"))
  | "caml_ml_output_char" ->
    (match args with
     | [ Pv chan; Pv c ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       as_int c;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"outputChar"
         ~descriptor:"(I)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_output_char arity"))
  | "caml_array_unsafe_get" | "caml_array_get" ->
    (match args with
     | [ Pv a; Pv i ] ->
       as_block a;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       Jvm.Code.aaload ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_array_get arity"))
  | "caml_array_unsafe_set" | "caml_array_set" ->
    (match args with
     | [ Pv a; Pv i; Pv v ] ->
       as_block a;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.aastore ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_array_set arity"))
  | "caml_string_of_bytes" ->
    (match args with
     | [ Pv b ] ->
       emit_load ctx b;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Bytes"
         ~method_:"staticAsString"
         ~descriptor:"(Ljava/lang/Object;)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported "caml_string_of_bytes arity"))
  | "caml_bytes_of_string" ->
    (match args with
     | [ Pv s ] ->
       as_string s;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Bytes"
         ~method_:"ofString"
         ~descriptor:"(Ljava/lang/String;)LBytes;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_bytes_of_string arity"))
  | "caml_blit_string" ->
    (* [caml_blit_string src srcofs dst dstofs len]. Bytes.blitString
       has signature [(String src, int sofs, int dofs, int len)], so
       we push args: dst (receiver), src, srcofs, dstofs, len. *)
    (match args with
     | [ Pv s; Pv si; Pv b; Pv bi; Pv n ] ->
       as_bytes b;
       as_string s;
       as_int si;
       as_int bi;
       as_int n;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"blitString"
         ~descriptor:"(Ljava/lang/String;III)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_blit_string arity"))
  | "caml_blit_bytes" ->
    (match args with
     | [ Pv s; Pv si; Pv b; Pv bi; Pv n ] ->
       as_bytes b;
       as_bytes s;
       as_int si;
       as_int bi;
       as_int n;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"blitBytes"
         ~descriptor:"(LBytes;III)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_blit_bytes arity"))
  | "caml_format_int" ->
    (match args with
     | [ Pv _fmt; Pv n ] ->
       (* Ignore format string; use Integer.toString for now. *)
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"toString"
         ~descriptor:"(I)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported "caml_format_int arity"))
  | "caml_string_equal" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_string a;
       as_string b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"equals"
         ~descriptor:"(Ljava/lang/Object;)Z";
       Kind.K_int
     | _ -> raise (Unsupported "caml_string_equal arity"))
  | "caml_string_notequal" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_string a;
       as_string b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"equals"
         ~descriptor:"(Ljava/lang/Object;)Z";
       Jvm.Code.ldc_int ctx.code 1;
       Jvm.Code.ixor ctx.code;
       Kind.K_int
     | _ -> raise (Unsupported "caml_string_notequal arity"))
  | "caml_bytes_equal" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_bytes a;
       as_bytes b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"contentEquals"
         ~descriptor:"(LBytes;)Z";
       Kind.K_int
     | _ -> raise (Unsupported "caml_bytes_equal arity"))
  | "caml_ml_output" ->
    (match args with
     | [ Pv chan; Pv s; Pv off; Pv len ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       as_string s;
       as_int off;
       as_int len;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"output"
         ~descriptor:"(Ljava/lang/String;II)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_output arity"))
  | "caml_ml_close_channel" ->
    (match args with
     | [ Pv _ch ] ->
       (* No-op; JVM GC handles cleanup. *)
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_close_channel arity"))
  | "caml_add_float" | "caml_sub_float" | "caml_mul_float" | "caml_div_float" ->
    (match args with
     | [ Pv a; Pv b ] ->
       let as_dbl v =
         emit_load ctx v;
         match kind_of ctx v with
         | K_float -> ()
         | _ ->
           Jvm.Code.checkcast ctx.code "java/lang/Double";
           Jvm.Code.invokevirtual
             ctx.code
             ~class_:"java/lang/Double"
             ~method_:"doubleValue"
             ~descriptor:"()D"
       in
       as_dbl a;
       as_dbl b;
       (match name with
        | "caml_add_float" -> Jvm.Code.dadd ctx.code
        | "caml_sub_float" -> Jvm.Code.dsub ctx.code
        | "caml_mul_float" -> Jvm.Code.dmul ctx.code
        | "caml_div_float" -> Jvm.Code.ddiv ctx.code
        | _ -> assert false);
       Kind.K_float
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_neg_float" ->
    (match args with
     | [ Pv a ] ->
       emit_load ctx a;
       (match kind_of ctx a with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.dneg ctx.code;
       Kind.K_float
     | _ -> raise (Unsupported "caml_neg_float arity"))
  | "caml_eq_float" | "caml_neq_float" | "caml_lt_float"
  | "caml_le_float" | "caml_gt_float" | "caml_ge_float" ->
    (match args with
     | [ Pv a; Pv b ] ->
       let as_dbl v =
         emit_load ctx v;
         match kind_of ctx v with
         | K_float -> ()
         | _ ->
           Jvm.Code.checkcast ctx.code "java/lang/Double";
           Jvm.Code.invokevirtual
             ctx.code
             ~class_:"java/lang/Double"
             ~method_:"doubleValue"
             ~descriptor:"()D"
       in
       as_dbl a;
       as_dbl b;
       (* dcmpl/dcmpg: -1/0/1, with NaN semantics. eq/neq use dcmpl.
          lt/le use dcmpg (NaN pushes +1 → lt is false). gt/ge use
          dcmpl (NaN pushes -1 → gt is false). *)
       (match name with
        | "caml_eq_float" | "caml_neq_float" | "caml_gt_float"
        | "caml_ge_float" ->
          Jvm.Code.dcmpl ctx.code
        | "caml_lt_float" | "caml_le_float" -> Jvm.Code.dcmpg ctx.code
        | _ -> assert false);
       let l_true = Jvm.Code.fresh_label ctx.code in
       let l_end = Jvm.Code.fresh_label ctx.code in
       (match name with
        | "caml_eq_float" -> Jvm.Code.ifeq ctx.code l_true
        | "caml_neq_float" -> Jvm.Code.ifne ctx.code l_true
        | "caml_lt_float" -> Jvm.Code.iflt ctx.code l_true
        | "caml_le_float" -> Jvm.Code.ifle ctx.code l_true
        | "caml_gt_float" -> Jvm.Code.ifgt ctx.code l_true
        | "caml_ge_float" -> Jvm.Code.ifge ctx.code l_true
        | _ -> assert false);
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.goto_w ctx.code l_end;
       Jvm.Code.mark_label ctx.code l_true;
       Jvm.Code.ldc_int ctx.code 1;
       Jvm.Code.mark_label ctx.code l_end;
       Kind.K_int
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int_of_float" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.d2i ctx.code;
       Kind.K_int
     | _ -> raise (Unsupported "caml_int_of_float arity"))
  | "caml_float_of_int" ->
    (match args with
     | [ Pv n ] ->
       as_int n;
       Jvm.Code.i2d ctx.code;
       Kind.K_float
     | _ -> raise (Unsupported "caml_float_of_int arity"))
  | "caml_abs_float" | "caml_sqrt_float" | "caml_sin_float"
  | "caml_cos_float" | "caml_tan_float" | "caml_asin_float"
  | "caml_acos_float" | "caml_atan_float" | "caml_log_float"
  | "caml_log10_float" | "caml_exp_float" | "caml_ceil_float"
  | "caml_floor_float" | "caml_sinh_float" | "caml_cosh_float"
  | "caml_tanh_float" ->
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       let mname =
         match name with
         | "caml_abs_float" -> "abs"
         | "caml_sqrt_float" -> "sqrt"
         | "caml_sin_float" -> "sin"
         | "caml_cos_float" -> "cos"
         | "caml_tan_float" -> "tan"
         | "caml_asin_float" -> "asin"
         | "caml_acos_float" -> "acos"
         | "caml_atan_float" -> "atan"
         | "caml_log_float" -> "log"
         | "caml_log10_float" -> "log10"
         | "caml_exp_float" -> "exp"
         | "caml_ceil_float" -> "ceil"
         | "caml_floor_float" -> "floor"
         | "caml_sinh_float" -> "sinh"
         | "caml_cosh_float" -> "cosh"
         | "caml_tanh_float" -> "tanh"
         | _ -> assert false
       in
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Math"
         ~method_:mname
         ~descriptor:"(D)D";
       Kind.K_float
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_atan2_float" | "caml_hypot_float" | "caml_power_float"
  | "caml_fmod_float" ->
    (match args with
     | [ Pv a; Pv b ] ->
       let as_dbl v =
         emit_load ctx v;
         match kind_of ctx v with
         | K_float -> ()
         | _ ->
           Jvm.Code.checkcast ctx.code "java/lang/Double";
           Jvm.Code.invokevirtual
             ctx.code
             ~class_:"java/lang/Double"
             ~method_:"doubleValue"
             ~descriptor:"()D"
       in
       as_dbl a;
       as_dbl b;
       let mname =
         match name with
         | "caml_atan2_float" -> "atan2"
         | "caml_hypot_float" -> "hypot"
         | "caml_power_float" -> "pow"
         | "caml_fmod_float" -> "IEEEremainder"
         | _ -> assert false
       in
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Math"
         ~method_:mname
         ~descriptor:"(DD)D";
       Kind.K_float
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_float_of_string" ->
    (match args with
     | [ Pv s ] ->
       as_string s;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Double"
         ~method_:"parseDouble"
         ~descriptor:"(Ljava/lang/String;)D";
       Kind.K_float
     | _ -> raise (Unsupported "caml_float_of_string arity"))
  | "caml_int32_format" | "caml_int64_format" | "caml_nativeint_format" ->
    (match args with
     | [ Pv _fmt; Pv n ] ->
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"toString"
         ~descriptor:"(I)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_hexstring_of_float" ->
    (* The real primitive takes (float, precision, style); we only
       use the float and return Double.toHexString. First arg is the
       float; drop any others (they've been pushed but unused). *)
    (match args with
     | (Code.Pv f) :: _rest ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Double"
         ~method_:"toHexString"
         ~descriptor:"(D)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported "caml_hexstring_of_float arity"))
  | "caml_classify_float" ->
    (* OCaml codes:
         FP_normal=0, FP_subnormal=1, FP_zero=2, FP_infinite=3, FP_nan=4. *)
    (match args with
     | [ Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       (* Stack leak risk: call a static helper if we had one; for
          now just return 0 (FP_normal). Lossy but structurally
          sound. *)
       Jvm.Code.pop2 ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_classify_float arity"))
  | "caml_java_print_int" ->
    (match args with
     | [ Pv n ] ->
       Jvm.Code.getstatic
         ctx.code
         ~class_:"java/lang/System"
         ~field:"out"
         ~descriptor:"Ljava/io/PrintStream;";
       as_int n;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/PrintStream"
         ~method_:"println"
         ~descriptor:"(I)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_java_print_int arity"))
  | "caml_java_print_endline" ->
    (match args with
     | [ Pv s ] ->
       Jvm.Code.getstatic
         ctx.code
         ~class_:"java/lang/System"
         ~field:"out"
         ~descriptor:"Ljava/io/PrintStream;";
       as_string s;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/PrintStream"
         ~method_:"println"
         ~descriptor:"(Ljava/lang/String;)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_java_print_endline arity"))
  | "caml_java_print_float" ->
    (match args with
     | [ Pv f ] ->
       Jvm.Code.getstatic
         ctx.code
         ~class_:"java/lang/System"
         ~field:"out"
         ~descriptor:"Ljava/io/PrintStream;";
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/io/PrintStream"
         ~method_:"println"
         ~descriptor:"(D)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_java_print_float arity"))
  | "caml_int_of_string" ->
    (match args with
     | [ Pv s ] ->
       as_string s;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"parseInt"
         ~descriptor:"(Ljava/lang/String;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_int_of_string arity"))
  | "caml_format_float" ->
    (match args with
     | [ Pv _fmt; Pv f ] ->
       emit_load ctx f;
       (match kind_of ctx f with
        | K_float -> ()
        | _ ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D");
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Double"
         ~method_:"toString"
         ~descriptor:"(D)Ljava/lang/String;";
       Kind.K_string
     | _ -> raise (Unsupported "caml_format_float arity"))
  | "caml_sys_exit" ->
    (match args with
     | [ Pv n ] ->
       as_int n;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/System"
         ~method_:"exit"
         ~descriptor:"(I)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_sys_exit arity"))
  | "caml_sys_get_config" ->
    (* Returns ("Unix", 32, false) triple. *)
    Jvm.Code.new_ ctx.code "Block";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.ldc_int ctx.code 3;
    Jvm.Code.anewarray ctx.code "java/lang/Object";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.ldc_string ctx.code "Unix";
    Jvm.Code.aastore ctx.code;
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 1;
    Jvm.Code.ldc_int ctx.code 32;
    Kind.emit_box_int ctx.code;
    Jvm.Code.aastore ctx.code;
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code 2;
    Jvm.Code.ldc_int ctx.code 0;
    Kind.emit_box_int ctx.code;
    Jvm.Code.aastore ctx.code;
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    Kind.K_obj
  | "caml_sys_const_int_size" -> Jvm.Code.ldc_int ctx.code 63; Kind.K_int
  | "caml_sys_const_word_size" -> Jvm.Code.ldc_int ctx.code 64; Kind.K_int
  | "caml_sys_const_big_endian"
  | "caml_sys_const_ostype_unix" ->
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | "caml_sys_const_ostype_cygwin" | "caml_sys_const_ostype_win32"
  | "caml_sys_const_backend_type" ->
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | "caml_sys_const_max_wosize" ->
    (* Stdlib's Sys.max_string_length is computed from this as
       [word_size / 8 * max_wosize - 1]. With our word_size = 64
       and JVM 32-bit ints, max_wosize * 8 must stay in int32
       range; clamp to 2^28 - 1 so [8 * 268435455 - 1 = 2147483639]
       fits. OCaml's canonical value (2^54 - 1 on 64-bit) would
       overflow our 32-bit arithmetic to a negative number,
       causing Buffer.create / Bytes.create to receive absurd
       sizes. *)
    Jvm.Code.ldc_int ctx.code 268435455;
    Kind.K_int
  | "caml_sys_const_min_int" -> Jvm.Code.ldc_int ctx.code min_int; Kind.K_int
  | "caml_sys_const_max_int" -> Jvm.Code.ldc_int ctx.code max_int; Kind.K_int
  | "caml_ensure_stack_capacity"
  | "caml_ml_set_binary_mode"
  | "caml_ml_set_channel_name"
  | "caml_register_named_value"
  | "caml_init_signals"
  | "caml_record_backtrace"
  | "caml_backtrace_status"
  | "caml_ml_debug_info_status"
  | "caml_ml_enable_runtime_warnings"
  | "caml_ml_runtime_warnings_enabled"
  | "caml_runtime_parameters"
  | "caml_runtime_variant"
  | "caml_ml_out_channels_list"
  | "caml_ml_seek_out"
  | "caml_ml_seek_out_64"
  | "caml_ml_seek_in"
  | "caml_ml_seek_in_64"
  | "caml_ml_pos_out"
  | "caml_ml_pos_out_64"
  | "caml_ml_pos_in"
  | "caml_ml_pos_in_64" ->
    Jvm.Code.ldc_int ctx.code 0;
    Kind.K_int
  | "caml_ml_open_descriptor_in"
  | "caml_channel_descriptor"
  | "caml_sys_get_argv"
  | "caml_sys_executable_name"
  | "caml_sys_getenv"
  | "caml_sys_system_command"
  | "caml_sys_file_exists" ->
    Jvm.Code.aconst_null ctx.code;
    Kind.K_obj
  | "caml_int64_float_of_bits" | "caml_int32_float_of_bits" ->
    Jvm.Code.ldc_double ctx.code 0.0;
    Kind.K_float
  (* int64 / int32 / nativeint ops — our int is 32-bit JVM int, so
     these collapse to the identity / pass-through operations on
     the boxed Integer representation. Not bit-accurate for values
     outside the JVM int range but enough for most Stdlib paths
     that route through Hashtbl.hash, Random, etc. *)
  | "caml_int64_of_int" | "caml_int32_of_int" | "caml_nativeint_of_int"
  | "caml_int_of_int64" | "caml_int_of_int32" | "caml_int_of_nativeint" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_add" | "caml_int32_add" | "caml_nativeint_add" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.iadd ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_sub" | "caml_int32_sub" | "caml_nativeint_sub" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.isub ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_mul" | "caml_int32_mul" | "caml_nativeint_mul" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.imul ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_xor" | "caml_int32_xor" | "caml_nativeint_xor" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.ixor ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_and" | "caml_int32_and" | "caml_nativeint_and" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.iand ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_or" | "caml_int32_or" | "caml_nativeint_or" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.ior ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_shift_left" | "caml_int32_shift_left"
  | "caml_nativeint_shift_left" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.ishl ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_shift_right" | "caml_int32_shift_right"
  | "caml_nativeint_shift_right" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.ishr ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_shift_right_unsigned" | "caml_int32_shift_right_unsigned"
  | "caml_nativeint_shift_right_unsigned" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a; as_int b;
       Jvm.Code.iushr ctx.code;
       Kind.emit_box_int ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_int64_to_int" | "caml_int32_to_int" | "caml_nativeint_to_int" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Kind.K_obj
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_atomic_load" ->
    (* Atomic_load ref: read field 0 of the block — identical
       semantics to a plain !ref on the JVM under the default
       memory model. *)
    (match args with
     | [ Pv r ] ->
       as_block r;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aaload ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_atomic_load arity"))
  | "caml_ml_output_bytes" ->
    (match args with
     | [ Pv chan; Pv b; Pv off; Pv len ] ->
       emit_load ctx chan;
       Jvm.Code.checkcast ctx.code "Channel";
       as_bytes b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Bytes"
         ~method_:"asString"
         ~descriptor:"()Ljava/lang/String;";
       as_int off;
       as_int len;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Channel"
         ~method_:"output"
         ~descriptor:"(Ljava/lang/String;II)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_ml_output_bytes arity"))
  | "caml_array_make" | "caml_make_vect" ->
    (* [arr = new Object[n]; Arrays.fill(arr, boxed(init)); return new
       Block(0, arr)]. Use a temp local to save the array across the
       void-returning Arrays.fill. *)
    (match args with
     | [ Pv n; Pv init ] ->
       let arr_local = ctx.next_local in
       ctx.next_local <- arr_local + 1;
       Jvm.Code.set_min_locals ctx.code ctx.next_local;
       as_int n;
       Jvm.Code.anewarray ctx.code "java/lang/Object";
       Jvm.Code.astore ctx.code arr_local;
       Jvm.Code.aload ctx.code arr_local;
       emit_load ctx init;
       (match kind_of ctx init with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/util/Arrays"
         ~method_:"fill"
         ~descriptor:"([Ljava/lang/Object;Ljava/lang/Object;)V";
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aload ctx.code arr_local;
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_array_make arity"))
  | "caml_array_get_addr" | "caml_array_unsafe_get_addr" ->
    (match args with
     | [ Pv a; Pv i ] ->
       as_block a;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       Jvm.Code.aaload ctx.code;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_array_get_addr arity"))
  | "caml_array_set_addr" | "caml_array_unsafe_set_addr" ->
    (match args with
     | [ Pv a; Pv i; Pv v ] ->
       as_block a;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       as_int i;
       emit_load ctx v;
       (match kind_of ctx v with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.aastore ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_array_set_addr arity"))
  | "caml_obj_block" ->
    (* [caml_obj_block tag size] creates a block with [size]
       uninitialized fields and the given [tag]. *)
    (match args with
     | [ Pv tag; Pv size ] ->
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       as_int tag;
       as_int size;
       Jvm.Code.anewarray ctx.code "java/lang/Object";
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_obj_block arity"))
  | "caml_alloc_dummy" ->
    (* Allocates a placeholder Block that will later be filled by
       caml_update_dummy. Our runtime uses [Block] with size-1
       placeholder; a minimal approximation is a 0-field block. *)
    (match args with
     | [ Pv size ] ->
       Jvm.Code.new_ ctx.code "Block";
       Jvm.Code.dup ctx.code;
       Jvm.Code.ldc_int ctx.code 0;
       as_int size;
       Jvm.Code.anewarray ctx.code "java/lang/Object";
       Jvm.Code.invokespecial
         ctx.code
         ~class_:"Block"
         ~method_:"<init>"
         ~descriptor:"(I[Ljava/lang/Object;)V";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_alloc_dummy arity"))
  | "caml_update_dummy" ->
    (* System.arraycopy(src.fields, 0, dst.fields, 0, dst.fields.length).
       Tag can't be updated since Block.tag is final, but recursive-
       value patterns from the bytecode compiler share tag=0 so this
       is safe in practice. *)
    (match args with
     | [ Pv dst; Pv src ] ->
       let dst_fields_local = ctx.next_local in
       ctx.next_local <- dst_fields_local + 1;
       Jvm.Code.set_min_locals ctx.code ctx.next_local;
       as_block dst;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.astore ctx.code dst_fields_local;
       as_block src;
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"fields"
         ~descriptor:"[Ljava/lang/Object;";
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aload ctx.code dst_fields_local;
       Jvm.Code.ldc_int ctx.code 0;
       Jvm.Code.aload ctx.code dst_fields_local;
       Jvm.Code.arraylength ctx.code;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/System"
         ~method_:"arraycopy"
         ~descriptor:
           "(Ljava/lang/Object;ILjava/lang/Object;II)V";
       Jvm.Code.ldc_int ctx.code 0;
       Kind.K_int
     | _ -> raise (Unsupported "caml_update_dummy arity"))
  | "caml_int_compare" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_int a;
       as_int b;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"compare"
         ~descriptor:"(II)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_int_compare arity"))
  | "caml_string_compare" ->
    (match args with
     | [ Pv a; Pv b ] ->
       as_string a;
       as_string b;
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/String"
         ~method_:"compareTo"
         ~descriptor:"(Ljava/lang/String;)I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_string_compare arity"))
  | "caml_set_oo_id" ->
    (* [caml_set_oo_id block] sets field 1 of [block] to a fresh
       OO-id. The legacy emitter uses a static counter. Skip the
       side-effect for IR path: return the block unchanged. *)
    (match args with
     | [ Pv b ] ->
       emit_load ctx b;
       Kind.K_obj
     | _ -> raise (Unsupported "caml_set_oo_id arity"))
  | "caml_ml_open_descriptor_out" ->
    (match args with
     | [ Pv fd ] ->
       as_int fd;
       Jvm.Code.invokestatic
         ctx.code
         ~class_:"Channel"
         ~method_:"forDescriptor"
         ~descriptor:"(I)LChannel;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_ml_open_descriptor_out arity"))
  | "caml_notequal" | "caml_equal" | "caml_compare" | "caml_lessthan"
  | "caml_greaterthan" | "caml_lessequal" | "caml_greaterequal" ->
    (* Structural comparison via the runtime Compare class. *)
    let method_, desc =
      match name with
      | "caml_equal" -> "equal", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_notequal" -> "notequal", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_compare" -> "compare", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_lessthan" -> "lessthan", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_greaterthan" ->
        "greaterthan", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_lessequal" ->
        "lessequal", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | "caml_greaterequal" ->
        "greaterequal", "(Ljava/lang/Object;Ljava/lang/Object;)I"
      | _ -> assert false
    in
    (match args with
     | [ Pv a; Pv b ] ->
       emit_load ctx a;
       (match kind_of ctx a with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       emit_load ctx b;
       (match kind_of ctx b with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ());
       Jvm.Code.invokestatic ctx.code ~class_:"Compare" ~method_ ~descriptor:desc;
       Kind.K_int
     | _ -> raise (Unsupported (name ^ " arity")))
  | "caml_obj_tag" ->
    (* Arg 0: Block. Return: tag (int). *)
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       Jvm.Code.checkcast ctx.code "Block";
       Jvm.Code.getfield
         ctx.code
         ~class_:"Block"
         ~field:"tag"
         ~descriptor:"I";
       Kind.K_int
     | _ -> raise (Unsupported "caml_obj_tag arity"))
  | "caml_obj_dup" ->
    (match args with
     | [ Pv v ] ->
       emit_load ctx v;
       (* Block.dup() returns a shallow-copy Block. *)
       Jvm.Code.checkcast ctx.code "Block";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"Block"
         ~method_:"dup"
         ~descriptor:"()LBlock;";
       Kind.K_obj
     | _ -> raise (Unsupported "caml_obj_dup arity"))
  | "caml_fresh_oo_id" ->
    (* Compile-time counter — stable enough because module init is
       the only caller and runs once at Main.main entry. Matches
       legacy. *)
    let n = !(ctx.fresh_oo_id) in
    ctx.fresh_oo_id := n + 1;
    Jvm.Code.ldc_int ctx.code n;
    Kind.K_int
  | _ ->
    (* Unknown C primitive: emit a runtime-throwing stub rather than
       falling back to the legacy emitter. Matches what legacy does
       for OO / effect opcodes. Programs that never reach this call
       path at runtime (the usual case for Stdlib functions
       unrelated to the program's features) load and run cleanly. *)
    (* Drop any args already loaded — we haven't loaded any; args
       are lazily loaded per-case above. *)
    Jvm.Code.new_ ctx.code "java/lang/UnsupportedOperationException";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_string
      ctx.code
      (Printf.sprintf "C primitive %s is not implemented" name);
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"java/lang/UnsupportedOperationException"
      ~method_:"<init>"
      ~descriptor:"(Ljava/lang/String;)V";
    Jvm.Code.athrow ctx.code;
    (* Dead: give downstream an Object so emit_store has something
       to pop. *)
    Jvm.Code.aconst_null ctx.code;
    Kind.K_obj

let emit_int_binop ctx op a b =
  let ka = emit_prim_arg ctx a in
  ensure_int ctx ka;
  let kb = emit_prim_arg ctx b in
  ensure_int ctx kb;
  op ctx.code

let emit_prim ctx (p : Code.prim) (args : Code.prim_arg list) : Kind.kind =
  match p, args with
  | Extern "add_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.iadd a b; K_int
  | Extern "sub_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.isub a b; K_int
  | Extern "mul_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.imul a b; K_int
  | Extern "div_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.idiv a b; K_int
  | Extern "mod_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.irem a b; K_int
  | Extern "and_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.iand a b; K_int
  | Extern "or_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.ior a b; K_int
  | Extern "xor_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.ixor a b; K_int
  | Extern "lsl_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.ishl a b; K_int
  | Extern "lsr_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.iushr a b; K_int
  | Extern "asr_int", [ a; b ] -> emit_int_binop ctx Jvm.Code.ishr a b; K_int
  | Extern "neg_int", [ a ] ->
    let ka = emit_prim_arg ctx a in
    ensure_int ctx ka;
    Jvm.Code.ineg ctx.code;
    K_int
  | Not, [ a ] ->
    (* Boolean negation: OCaml ints are 0/1 here; flip with 1 - x. *)
    Jvm.Code.ldc_int ctx.code 1;
    let ka = emit_prim_arg ctx a in
    ensure_int ctx ka;
    Jvm.Code.isub ctx.code;
    K_int
  | (Eq | Neq | Lt | Le | Gt | Ge | Ult | Uge), [ a; b ] ->
    (* OCaml's EQ / NEQ opcodes are bitwise: int compare for
       immediates, reference compare for blocks. LT/LE/GT/GE (and
       unsigned variants) are only meaningful on ints. We dispatch
       off the typed kinds of the operands:
       - Both statically-int: unbox + if_icmp<op>.
       - Eq/Neq with at least one reference-typed operand: box both
         to Object if needed, then if_acmpeq / if_acmpne. This is
         the right semantics for exception-constructor matching
         (Block(248, [name, id]) references compared by identity
         via the shared Main.GLOBALS array).
       - Lt/Le/Gt/Ge/Ult/Uge on non-ints: unbox anyway (assume
         they're boxed Integers; OCaml doesn't emit these on
         blocks).*)
    let is_ref_kind = function
      | Kind.K_int -> false
      | _ -> true
    in
    let arg_kind = function
      | Code.Pv v -> kind_of ctx v
      | Pc (Int _) -> K_int
      | Pc (Float _) -> K_float
      | Pc (String _) -> K_string
      | Pc (Block _) -> K_obj
      | Pc Null -> K_obj
    in
    let ka = arg_kind a in
    let kb = arg_kind b in
    let use_ref =
      match p with
      | Eq | Neq -> is_ref_kind ka || is_ref_kind kb
      | _ -> false
    in
    let l_true = Jvm.Code.fresh_label ctx.code in
    let l_end = Jvm.Code.fresh_label ctx.code in
    if use_ref
    then (
      let load_as_obj pa =
        let k = emit_prim_arg ctx pa in
        match k with
        | K_int -> Kind.emit_box_int ctx.code
        | K_float -> Kind.emit_box_float ctx.code
        | _ -> ()
      in
      load_as_obj a;
      load_as_obj b;
      (match p with
       | Eq -> Jvm.Code.if_acmpeq ctx.code l_true
       | Neq -> Jvm.Code.if_acmpne ctx.code l_true
       | _ -> assert false))
    else (
      let _ = emit_prim_arg ctx a in
      ensure_int ctx ka;
      let _ = emit_prim_arg ctx b in
      ensure_int ctx kb;
      (* Ult / Uge need unsigned semantics; JVM's if_icmp family is
         signed. Flip the sign bit (JVM 32-bit INT_MIN, which is
         -2^31, NOT OCaml's 63-bit min_int) on each operand first so
         [signed compare of (x ^ INT_MIN)] gives the unsigned
         ordering. Operands are already on the stack at this point,
         so we XOR each with INT_MIN in place. *)
      let jvm_int_min = -2147483648 in
      (match p with
       | Ult | Uge ->
         let tmp = ctx.next_local in
         ctx.next_local <- tmp + 1;
         Jvm.Code.set_min_locals ctx.code ctx.next_local;
         Jvm.Code.ldc_int ctx.code jvm_int_min;
         Jvm.Code.ixor ctx.code;
         Jvm.Code.istore ctx.code tmp;
         Jvm.Code.ldc_int ctx.code jvm_int_min;
         Jvm.Code.ixor ctx.code;
         Jvm.Code.iload ctx.code tmp
       | _ -> ());
      match p with
      | Eq -> Jvm.Code.if_icmpeq ctx.code l_true
      | Neq -> Jvm.Code.if_icmpne ctx.code l_true
      | Lt -> Jvm.Code.if_icmplt ctx.code l_true
      | Ult -> Jvm.Code.if_icmplt ctx.code l_true
      | Le -> Jvm.Code.if_icmple ctx.code l_true
      | Gt -> Jvm.Code.if_icmpgt ctx.code l_true
      | Ge -> Jvm.Code.if_icmpge ctx.code l_true
      | Uge -> Jvm.Code.if_icmpge ctx.code l_true
      | _ -> assert false);
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.goto_w ctx.code l_end;
    Jvm.Code.mark_label ctx.code l_true;
    Jvm.Code.ldc_int ctx.code 1;
    Jvm.Code.mark_label ctx.code l_end;
    K_int
  | Extern "set_sibling", [ Pv self; Pc (Int idx); Pv other ] ->
    (* [self.sibling_<idx> = other] on the closure subclass [self]
       belongs to. [kind_of self] is K_closure tagged with the
       body_pc (as a string); look up the real class name via
       [name_of_body]. *)
    let class_name =
      match kind_of ctx self with
      | K_closure { name; _ } ->
        (match int_of_string_opt name with
         | Some body_pc ->
           (try ctx.name_of_body body_pc
            with Not_found ->
              raise (Unsupported "set_sibling: no class for body_pc"))
         | None -> name)
      | _ ->
        raise (Unsupported "set_sibling: self not K_closure")
    in
    emit_load ctx self;
    Jvm.Code.checkcast ctx.code class_name;
    emit_load ctx other;
    Jvm.Code.checkcast ctx.code "Closure";
    Jvm.Code.putfield
      ctx.code
      ~class_:class_name
      ~field:(Printf.sprintf "sibling_%d" idx)
      ~descriptor:"LClosure;";
    Jvm.Code.ldc_int ctx.code 0;
    K_int
  | Extern "offsetclosure", [ Pv env_arg; Pc (Int k) ] ->
    (match ctx.enclosing with
     | None -> raise (Unsupported "offsetclosure: no enclosing fn")
     | Some (fi, env_var) ->
       if not (Code.Var.equal env_arg env_var)
       then raise (Unsupported "offsetclosure on non-env var");
       let self_idx = fi.Function_info.group_idx in
       let target_idx = self_idx + (k / 3) in
       let group_len = Array.length fi.Function_info.group in
       if group_len <= 1 && k = 0
       then (
         (* Single closure, self-ref: just aload 0. *)
         Jvm.Code.aload ctx.code 0;
         K_closure { name = fi.name; captures = [] })
       else if target_idx < 0 || target_idx >= group_len
       then raise (Unsupported "offsetclosure: target out of group")
       else (
         let target = fi.Function_info.group.(target_idx) in
         Jvm.Code.aload ctx.code 0;
         Jvm.Code.getfield
           ctx.code
           ~class_:fi.name
           ~field:(Printf.sprintf "sibling_%d" target_idx)
           ~descriptor:"LClosure;";
         K_closure { name = target.name; captures = [] }))
  | Extern s, args' when String.length s > 6 && String.sub s 0 6 = "ccall_" ->
    let idx = int_of_string (String.sub s 6 (String.length s - 6)) in
    let name =
      try ctx.prim_name idx
      with Not_found -> raise (Unsupported ("ccall_" ^ string_of_int idx))
    in
    emit_ccall ctx name args'
  | Array_get, [ a; i ] ->
    let _ = emit_prim_arg ctx a in
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    let ki = emit_prim_arg ctx i in
    ensure_int ctx ki;
    Jvm.Code.aaload ctx.code;
    K_obj
  | Vectlength, [ a ] ->
    let _ = emit_prim_arg ctx a in
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.arraylength ctx.code;
    K_int
  | Extern "set_byte", [ s; i; v ] ->
    (* s.set(i, v); returns unit = 0 *)
    let ks = emit_prim_arg ctx s in
    (match ks with
     | _ -> Jvm.Code.checkcast ctx.code "Bytes");
    let ki = emit_prim_arg ctx i in
    ensure_int ctx ki;
    let kv = emit_prim_arg ctx v in
    ensure_int ctx kv;
    Jvm.Code.invokevirtual
      ctx.code
      ~class_:"Bytes"
      ~method_:"set"
      ~descriptor:"(II)V";
    Jvm.Code.ldc_int ctx.code 0;
    K_int
  | Extern "get_byte", [ a; b ] ->
    (* Read a byte from a Bytes/String at an int index. OCaml
       interchanges the two freely via unsafe_of_string; dispatch
       at runtime through [Bytes.staticGet]. *)
    let _ = emit_prim_arg ctx a in
    let kb = emit_prim_arg ctx b in
    ensure_int ctx kb;
    Jvm.Code.invokestatic
      ctx.code
      ~class_:"Bytes"
      ~method_:"staticGet"
      ~descriptor:"(Ljava/lang/Object;I)I";
    K_int
  | Extern ("getmethod" | "getpubmet" | "getdynmet"), _ ->
    (* Matches legacy: throw at runtime rather than compile-time.
       For programs that don't actually reach these ops at runtime
       (the common case), the class loads and runs cleanly. *)
    Jvm.Code.new_ ctx.code "java/lang/UnsupportedOperationException";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_string ctx.code "OCaml objects / methods are not supported";
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"java/lang/UnsupportedOperationException"
      ~method_:"<init>"
      ~descriptor:"(Ljava/lang/String;)V";
    Jvm.Code.athrow ctx.code;
    (* athrow is terminating; the verifier is OK with "dead" code
       following, but we still need a value on the stack for
       consumers that expect one. Use aconst_null as placeholder. *)
    Jvm.Code.aconst_null ctx.code;
    K_obj
  | Extern "get_global", [ Pc (Int idx) ] ->
    Jvm.Code.getstatic
      ctx.code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int ctx.code idx;
    Jvm.Code.aaload ctx.code;
    K_obj
  | Extern "set_global", [ Pc (Int idx); Pv v ] ->
    Jvm.Code.getstatic
      ctx.code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int ctx.code idx;
    emit_load ctx v;
    (match kind_of ctx v with
     | K_int -> Kind.emit_box_int ctx.code
     | K_float -> Kind.emit_box_float ctx.code
     | _ -> ());
    Jvm.Code.aastore ctx.code;
    (* Return unit (represented as int 0). *)
    Jvm.Code.ldc_int ctx.code 0;
    K_int
  | Extern "get_global_field", [ Pc (Int idx); Pc (Int field) ] ->
    Jvm.Code.getstatic
      ctx.code
      ~class_:"Main"
      ~field:"GLOBALS"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int ctx.code idx;
    Jvm.Code.aaload ctx.code;
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int ctx.code field;
    Jvm.Code.aaload ctx.code;
    K_obj
  | IsInt, [ a ] ->
    let ka = emit_prim_arg ctx a in
    (match ka with
     | K_int -> Jvm.Code.ldc_int ctx.code 1; K_int
     | _ ->
       Jvm.Code.instanceof_ ctx.code "java/lang/Integer";
       K_int)
  | p, _ ->
    let p_str =
      match p with
      | Code.Extern s -> "Extern " ^ s
      | Vectlength -> "Vectlength"
      | Array_get -> "Array_get"
      | Not -> "Not"
      | IsInt -> "IsInt"
      | Eq -> "Eq" | Neq -> "Neq" | Lt -> "Lt" | Le -> "Le"
      | Gt -> "Gt" | Ge -> "Ge" | Ult -> "Ult" | Uge -> "Uge"
    in
    raise (Unsupported ("prim " ^ p_str))

(* Load a Var, then box primitives to Object so the value can be
   passed to an apply method or stored into a closure-ctor arg. *)
let emit_load_as_obj ctx v =
  emit_load ctx v;
  match kind_of ctx v with
  | K_int -> Kind.emit_box_int ctx.code
  | K_float -> Kind.emit_box_float ctx.code
  | _ -> ()

let apply_descriptor_for_nargs n =
  let b = Buffer.create 16 in
  Buffer.add_char b '(';
  for _ = 1 to n do
    Buffer.add_string b "Ljava/lang/Object;"
  done;
  Buffer.add_string b ")Ljava/lang/Object;";
  Buffer.contents b

let emit_expr ctx (e : Code.expr) : Kind.kind =
  match e with
  | Constant c -> emit_constant ctx c
  | Prim (p, args) -> emit_prim ctx p args
  | Apply { f; args; exact = _ } ->
    let nargs = List.length args in
    if nargs < 1 || nargs > 7
    then raise (Unsupported (Printf.sprintf "Apply arity %d" nargs));
    emit_load ctx f;
    (match kind_of ctx f with
     | K_closure _ -> ()
     | _ -> Jvm.Code.checkcast ctx.code "Closure");
    List.iter (fun a -> emit_load_as_obj ctx a) args;
    Jvm.Code.invokevirtual
      ctx.code
      ~class_:"Closure"
      ~method_:(Printf.sprintf "apply%d" nargs)
      ~descriptor:(apply_descriptor_for_nargs nargs);
    K_obj
  | Block (tag, fields) ->
    (* new Block(tag, new Object[]{fields...}). *)
    Jvm.Code.new_ ctx.code "Block";
    Jvm.Code.dup ctx.code;
    Jvm.Code.ldc_int ctx.code tag;
    Jvm.Code.ldc_int ctx.code (Array.length fields);
    Jvm.Code.anewarray ctx.code "java/lang/Object";
    Array.iteri
      (fun i v ->
        Jvm.Code.dup ctx.code;
        Jvm.Code.ldc_int ctx.code i;
        emit_load ctx v;
        (match kind_of ctx v with
         | K_int -> Kind.emit_box_int ctx.code
         | K_float -> Kind.emit_box_float ctx.code
         | _ -> ());
        Jvm.Code.aastore ctx.code)
      fields;
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"Block"
      ~method_:"<init>"
      ~descriptor:"(I[Ljava/lang/Object;)V";
    K_obj
  | Field (v, i) ->
    (* Field(env, i) — ENVACC-style capture read. Resolve via the
       enclosing function's [cap_<idx>] field; cap index is
       [i - envofs] where envofs is the OCaml closure offset
       (function of group size and group_idx). *)
    (match ctx.enclosing with
     | Some (fi, env_var) when Code.Var.equal v env_var ->
       let nfuncs = Array.length fi.Function_info.group in
       let envofs = (3 * (nfuncs - fi.group_idx)) - 1 in
       if i < envofs
       then
         raise
           (Unsupported
              (Printf.sprintf
                 "Field(env,%d) below envofs=%d (closure-info/sibling \
                  field)"
                 i
                 envofs));
       let cap_index = i - envofs in
       let cap_kinds = !(fi.Function_info.capture_kinds) in
       let k =
         try List.nth cap_kinds cap_index
         with _ -> Kind.K_obj
       in
       Jvm.Code.aload ctx.code 0;
       Jvm.Code.getfield
         ctx.code
         ~class_:fi.name
         ~field:(Printf.sprintf "cap%d" cap_index)
         ~descriptor:(Kind.jvm_type_of_kind k);
       k
     | _ ->
       emit_load ctx v;
       (match kind_of ctx v with
        | K_block _ | K_obj ->
          Jvm.Code.checkcast ctx.code "Block";
          Jvm.Code.getfield
            ctx.code
            ~class_:"Block"
            ~field:"fields"
            ~descriptor:"[Ljava/lang/Object;";
          Jvm.Code.ldc_int ctx.code i;
          Jvm.Code.aaload ctx.code;
          K_obj
        | _ -> raise (Unsupported "Field on non-block kind")))
  | Closure { captures; body = body_pc, _ } ->
    let class_name =
      try ctx.name_of_body body_pc
      with Not_found ->
        raise
          (Unsupported
             (Printf.sprintf "no class for closure body pc %d" body_pc))
    in
    (* Look up or propagate the callee's capture kinds. If empty,
       infer from the caller's typing and propagate so the callee's
       class layout matches. This lets IR operate without legacy
       priming fn_info.capture_kinds first. *)
    let callee_cap_kinds =
      match ctx.fn_info_of_body body_pc with
      | Some fi ->
        let existing = !(fi.Function_info.capture_kinds) in
        if existing = []
        then (
          let inferred =
            List.map
              (fun v ->
                match kind_of ctx v with
                | Kind.K_int -> Kind.K_int
                | Kind.K_float -> Kind.K_float
                | _ -> Kind.K_obj)
              captures
          in
          fi.Function_info.capture_kinds := inferred;
          inferred)
        else existing
      | None -> List.map (fun _ -> Kind.K_obj) captures
    in
    let pad_len = List.length captures - List.length callee_cap_kinds in
    let cap_kinds =
      if pad_len > 0
      then
        callee_cap_kinds @ List.init pad_len (fun _ -> Kind.K_obj)
      else if pad_len < 0
      then
        let rec take n = function
          | _ when n = 0 -> []
          | [] -> []
          | x :: xs -> x :: take (n - 1) xs
        in
        take (List.length captures) callee_cap_kinds
      else callee_cap_kinds
    in
    Jvm.Code.new_ ctx.code class_name;
    Jvm.Code.dup ctx.code;
    List.iter2
      (fun v target_kind ->
        emit_load ctx v;
        let vk = kind_of ctx v in
        match (vk : Kind.kind), (target_kind : Kind.kind) with
        | a, b when a = b -> ()
        | Kind.K_int, Kind.K_obj -> Kind.emit_box_int ctx.code
        | Kind.K_float, Kind.K_obj -> Kind.emit_box_float ctx.code
        | Kind.K_obj, Kind.K_int ->
          Jvm.Code.checkcast ctx.code "java/lang/Integer";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Integer"
            ~method_:"intValue"
            ~descriptor:"()I"
        | Kind.K_obj, Kind.K_float ->
          Jvm.Code.checkcast ctx.code "java/lang/Double";
          Jvm.Code.invokevirtual
            ctx.code
            ~class_:"java/lang/Double"
            ~method_:"doubleValue"
            ~descriptor:"()D"
        | _ -> ())
      captures
      cap_kinds;
    let cap_desc =
      String.concat "" (List.map Kind.jvm_type_of_kind cap_kinds)
    in
    Jvm.Code.invokespecial
      ctx.code
      ~class_:class_name
      ~method_:"<init>"
      ~descriptor:(Printf.sprintf "(%s)V" cap_desc);
    K_closure { name = class_name; captures = [] }

let emit_instr ctx (i : Code.instr) =
  match i with
  | Let (x, e) ->
    let produced = emit_expr ctx e in
    emit_store ctx x ~from:produced
  | Assign (x, y) ->
    emit_load ctx y;
    emit_store ctx x ~from:(kind_of ctx y)
  | Set_field (x, i, y) ->
    emit_load ctx x;
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.ldc_int ctx.code i;
    emit_load ctx y;
    (match kind_of ctx y with
     | K_int -> Kind.emit_box_int ctx.code
     | K_float -> Kind.emit_box_float ctx.code
     | _ -> ());
    Jvm.Code.aastore ctx.code
  | Offset_ref (v, n) ->
    (* arr = v.fields; arr[0] = Integer.valueOf(((Integer)arr[0]).intValue() + n).
       Use a fresh local to hold the array cleanly. *)
    let tmp = ctx.next_local in
    ctx.next_local <- tmp + 1;
    Jvm.Code.set_min_locals ctx.code ctx.next_local;
    emit_load ctx v;
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    Jvm.Code.astore ctx.code tmp;
    Jvm.Code.aload ctx.code tmp;
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.aload ctx.code tmp;
    Jvm.Code.ldc_int ctx.code 0;
    Jvm.Code.aaload ctx.code;
    Jvm.Code.checkcast ctx.code "java/lang/Integer";
    Jvm.Code.invokevirtual
      ctx.code
      ~class_:"java/lang/Integer"
      ~method_:"intValue"
      ~descriptor:"()I";
    Jvm.Code.ldc_int ctx.code n;
    Jvm.Code.iadd ctx.code;
    Kind.emit_box_int ctx.code;
    Jvm.Code.aastore ctx.code
  | Array_set (a, i, v) ->
    emit_load ctx a;
    Jvm.Code.checkcast ctx.code "Block";
    Jvm.Code.getfield
      ctx.code
      ~class_:"Block"
      ~field:"fields"
      ~descriptor:"[Ljava/lang/Object;";
    emit_load ctx i;
    (match kind_of ctx i with
     | K_int -> ()
     | _ ->
       Jvm.Code.checkcast ctx.code "java/lang/Integer";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"intValue"
         ~descriptor:"()I");
    emit_load ctx v;
    (match kind_of ctx v with
     | K_int -> Kind.emit_box_int ctx.code
     | K_float -> Kind.emit_box_float ctx.code
     | _ -> ());
    Jvm.Code.aastore ctx.code

(* Emit a branch edge: parallel-rename the [args] into a caller's
   [param] locals, then [goto] a caller's entry label. To avoid
   clobber, load all args onto the JVM operand stack first, then
   store to params in reverse. *)
let emit_edge ctx (params : Code.Var.t list) (args : Code.Var.t list)
    target_label =
  if List.length params <> List.length args
  then
    raise
      (Unsupported
         (Printf.sprintf
            "block-edge arity mismatch: %d params vs %d args"
            (List.length params)
            (List.length args)));
  (* Short-cut: if all corresponding (param, arg) vars are equal, no
     moves needed. *)
  let equal =
    List.for_all2 (fun p a -> Code.Var.equal p a) params args
  in
  if not equal
  then (
    List.iter (fun a -> emit_load ctx a) args;
    List.iter2
      (fun p _a -> emit_store ctx p ~from:(kind_of ctx _a))
      (List.rev params)
      (List.rev args));
  Jvm.Code.goto_w ctx.code target_label

(* Find the param list of a target block. *)
let params_of_block (prog : Code.program) addr =
  match Code.Addr.Map.find_opt addr prog.blocks with
  | Some b -> b.params
  | None -> raise (Unsupported (Printf.sprintf "missing block %d" addr))

let emit_cont ctx prog (addr, args) =
  if debug_ir_gen_trace
  then
    Format.eprintf
      "[ir_gen_trace] emit_cont addr=%d args=%d@."
      addr
      (List.length args);
  let params = params_of_block prog addr in
  emit_edge ctx params args (label_of ctx addr)

let emit_last ctx prog (l : Code.last) =
  match l with
  | Return v ->
    let k = kind_of ctx v in
    emit_load ctx v;
    (match k with
     | K_int -> Kind.emit_box_int ctx.code; Jvm.Code.areturn ctx.code
     | K_float -> Kind.emit_box_float ctx.code; Jvm.Code.areturn ctx.code
     | _ -> Jvm.Code.areturn ctx.code)
  | Stop -> Jvm.Code.return_void ctx.code
  | Raise v ->
    Jvm.Code.new_ ctx.code "CamlException";
    Jvm.Code.dup ctx.code;
    emit_load_as_obj ctx v;
    Jvm.Code.invokespecial
      ctx.code
      ~class_:"CamlException"
      ~method_:"<init>"
      ~descriptor:"(Ljava/lang/Object;)V";
    Jvm.Code.athrow ctx.code
  | Branch c -> emit_cont ctx prog c
  | Cond (v, c_then, c_else) ->
    (* Cond tests whether [v] is truthy — for OCaml, that means
       either a non-zero immediate int or any block (cons, variant
       with args, ref, etc.). The else-arm fires only on the
       immediate [0] / empty-list. When [v] could be either (K_obj
       in particular, as for pattern matching on a list or variant),
       test [instanceof Block] first; blocks always take the
       then-arm. *)
    let l_else = Jvm.Code.fresh_label ctx.code in
    (match kind_of ctx v with
     | K_int ->
       emit_load ctx v;
       Jvm.Code.ifeq ctx.code l_else
     | K_block _ | K_closure _ | K_string ->
       (* Reference-typed values never compare zero; always truthy. *)
       ()
     | K_float ->
       emit_load ctx v;
       Jvm.Code.ldc_double ctx.code 0.0;
       Jvm.Code.dcmpl ctx.code;
       Jvm.Code.ifeq ctx.code l_else
     | K_obj ->
       emit_load ctx v;
       let l_then = Jvm.Code.fresh_label ctx.code in
       Jvm.Code.dup ctx.code;
       Jvm.Code.instanceof_ ctx.code "Block";
       Jvm.Code.ifne ctx.code l_then;
       Jvm.Code.checkcast ctx.code "java/lang/Integer";
       Jvm.Code.invokevirtual
         ctx.code
         ~class_:"java/lang/Integer"
         ~method_:"intValue"
         ~descriptor:"()I";
       Jvm.Code.ifeq ctx.code l_else;
       let l_end = Jvm.Code.fresh_label ctx.code in
       Jvm.Code.goto_w ctx.code l_end;
       Jvm.Code.mark_label ctx.code l_then;
       Jvm.Code.pop_top ctx.code;
       Jvm.Code.mark_label ctx.code l_end);
    emit_cont ctx prog c_then;
    Jvm.Code.mark_label ctx.code l_else;
    emit_cont ctx prog c_else
  | Switch (v, int_cases, tag_cases) ->
    let n_i = Array.length int_cases in
    let n_t = Array.length tag_cases in
    if n_i = 0 && n_t = 0 then raise (Unsupported "empty Switch");
    let kv = kind_of ctx v in
    let int_labels =
      Array.init n_i (fun _ -> Jvm.Code.fresh_label ctx.code)
    in
    let tag_labels =
      Array.init n_t (fun _ -> Jvm.Code.fresh_label ctx.code)
    in
    (* Store selector to a temp local so each case test pops cleanly
       to stack height 0 before branching. *)
    let alloc_int_local () =
      let l = ctx.next_local in
      ctx.next_local <- l + 1;
      Jvm.Code.set_min_locals ctx.code ctx.next_local;
      l
    in
    let _ = alloc_int_local in
    (* tableswitch is O(1) dispatch, uses 4-byte offsets so targets
       can be arbitrarily far from the switch, and produces far
       more compact bytecode than an if_icmpeq chain for large
       case counts. Selector is already on the operand stack as
       an int. OCaml's SWITCH has no default so we route out-of-
       range (shouldn't happen in well-typed code) to the last
       case. *)
    let emit_int_dispatch () =
      if n_i = 0
      then Jvm.Code.pop_top ctx.code
      else
        Jvm.Code.tableswitch
          ctx.code
          ~default:int_labels.(n_i - 1)
          ~low:0
          ~high:(n_i - 1)
          int_labels
    in
    let emit_tag_dispatch () =
      if n_t = 0
      then Jvm.Code.pop_top ctx.code
      else
        Jvm.Code.tableswitch
          ctx.code
          ~default:tag_labels.(n_t - 1)
          ~low:0
          ~high:(n_t - 1)
          tag_labels
    in
    if n_t = 0
    then (
      emit_load ctx v;
      (match kv with
       | K_int -> ()
       | _ ->
         Jvm.Code.checkcast ctx.code "java/lang/Integer";
         Jvm.Code.invokevirtual
           ctx.code
           ~class_:"java/lang/Integer"
           ~method_:"intValue"
           ~descriptor:"()I");
      emit_int_dispatch ())
    else if n_i = 0
    then (
      emit_load ctx v;
      Jvm.Code.checkcast ctx.code "Block";
      Jvm.Code.getfield
        ctx.code
        ~class_:"Block"
        ~field:"tag"
        ~descriptor:"I";
      emit_tag_dispatch ())
    else (
      (* Mixed: instanceof Block -> tag path, else int path. *)
      let l_block = Jvm.Code.fresh_label ctx.code in
      emit_load ctx v;
      Jvm.Code.instanceof_ ctx.code "Block";
      Jvm.Code.ifne ctx.code l_block;
      emit_load ctx v;
      Jvm.Code.checkcast ctx.code "java/lang/Integer";
      Jvm.Code.invokevirtual
        ctx.code
        ~class_:"java/lang/Integer"
        ~method_:"intValue"
        ~descriptor:"()I";
      emit_int_dispatch ();
      Jvm.Code.mark_label ctx.code l_block;
      emit_load ctx v;
      Jvm.Code.checkcast ctx.code "Block";
      Jvm.Code.getfield
        ctx.code
        ~class_:"Block"
        ~field:"tag"
        ~descriptor:"I";
      emit_tag_dispatch ());
    Array.iteri
      (fun i c ->
        Jvm.Code.mark_label ctx.code int_labels.(i);
        emit_cont ctx prog c)
      int_cases;
    Array.iteri
      (fun i c ->
        Jvm.Code.mark_label ctx.code tag_labels.(i);
        emit_cont ctx prog c)
      tag_cases
  | Pushtrap ((body_addr, _) as body_c, exn_var, handler_c) ->
    let handler_lbl = Jvm.Code.fresh_label ctx.code in
    (* Walk the IR forward from body_addr to collect every block in
       the try region. The region ends at a Poptrap (which transfers
       out of the region) or a Raise (which never falls through
       here). Nested Pushtraps are part of the enclosing region too. *)
    let protected = ref Code.Addr.Set.empty in
    let rec collect addr =
      if Code.Addr.Set.mem addr !protected
      then ()
      else (
        protected := Code.Addr.Set.add addr !protected;
        match Code.Addr.Map.find_opt addr prog.blocks with
        | None -> ()
        | Some b ->
          let step (a, _args) = collect a in
          (match b.branch with
           | Return _ | Raise _ | Stop -> ()
           | Poptrap _ ->
             (* A Poptrap exits the region; don't follow. *)
             ()
           | Branch c -> step c
           | Cond (_, c1, c2) -> step c1; step c2
           | Switch (_, ints, tags) ->
             Array.iter step ints;
             Array.iter step tags
           | Pushtrap (b_c, _, _) ->
             (* Nested try: its body is also covered by our
                exception handler. The nested handler_c is NOT
                part of our region (it's only reached when the
                nested exception fires). *)
             step b_c))
    in
    collect body_addr;
    (* Pre-allocate end labels for every protected block so emit_block
       can mark them when it reaches the end of each body. *)
    Code.Addr.Set.iter
      (fun addr ->
        if not (Hashtbl.mem ctx.block_end addr)
        then
          Hashtbl.add ctx.block_end addr (Jvm.Code.fresh_label ctx.code))
      !protected;
    ctx.pending_handlers <-
      { protected = !protected; handler_lbl } :: ctx.pending_handlers;
    emit_cont ctx prog body_c;
    (* Handler prelude: unwrap CamlException → exn value, store into
       exn_var's local, then move to handler cont. *)
    Jvm.Code.mark_label ctx.code handler_lbl;
    Jvm.Code.handler_stack_prelude ctx.code;
    Jvm.Code.getfield
      ctx.code
      ~class_:"CamlException"
      ~field:"value"
      ~descriptor:"Ljava/lang/Object;";
    emit_store ctx exn_var ~from:K_obj;
    emit_cont ctx prog handler_c
  | Poptrap c ->
    (* POPTRAP at the IR level is just a branch: the JVM exception
       table entry was closed at end_lbl in the enclosing Pushtrap. *)
    emit_cont ctx prog c

let emit_block ctx prog addr (b : Code.block) =
  if debug_ir_gen_trace
  then Format.eprintf "[ir_gen_trace] emit_block addr=%d@." addr;
  (* Ensure each param has a local allocated. *)
  List.iter (fun v -> ignore (local_of ctx v)) b.params;
  let start_lbl = label_of ctx addr in
  Jvm.Code.mark_label ctx.code start_lbl;
  Hashtbl.replace ctx.block_start addr start_lbl;
  List.iter (fun i -> emit_instr ctx i) b.body;
  emit_last ctx prog b.branch;
  (* Mark the end-of-block label if anyone (a Pushtrap deferred
     handler install) asked for one. *)
  match Hashtbl.find_opt ctx.block_end addr with
  | Some end_lbl -> Jvm.Code.mark_label ctx.code end_lbl
  | None -> ()

let emit_program
    ~code
    ~typing
    ~name_of_body
    ~fn_info_of_body
    ~prim_name
    ?(arg_vars = [])
    ?enclosing
    (prog : Code.program)
  =
  let ctx =
    { code
    ; typing
    ; var_local = Hashtbl.create 64
    ; labels = Hashtbl.create 32
    ; name_of_body
    ; fn_info_of_body
    ; prim_name
    ; enclosing
    ; fresh_oo_id = ref 0
    ; next_local = 1
    ; block_start = Hashtbl.create 32
    ; block_end = Hashtbl.create 32
    ; pending_handlers = []
    }
  in
  (* Apply-method locals 1..N are the formal args by JVM calling
     convention. Pin each arg Var to its local before block emission
     so [emit_load arg_i] reads from the right slot. Args are all
     [K_obj] in the apply signature; we coerce to arg_vars' typed
     kinds on first use via the normal emit_load path. *)
  List.iteri
    (fun i v ->
      Hashtbl.replace ctx.var_local (Code.Var.idx v) (i + 1);
      if ctx.next_local <= i + 1 then ctx.next_local <- i + 2)
    arg_vars;
  Jvm.Code.set_min_locals ctx.code ctx.next_local;
  (* Initialise every entry-block param that isn't a pre-bound
     apply-method arg to [null]. This covers the "start_accu" Var
     (the entry block's nominal accu, which in OCaml's bytecode is
     undefined on function entry) plus any leftover stack slots
     that the caller of parse_function populated as initial_stack
     but didn't bind to JVM locals — typically none for functions,
     but being safe for robustness. Without this, the verifier
     sees aload-on-uninitialized-local at the first read. *)
  (let entry = Code.Addr.Map.find prog.start prog.blocks in
   let arg_set =
     List.fold_left
       (fun s v -> Code.Var.Set.add v s)
       Code.Var.Set.empty
       arg_vars
   in
   List.iter
     (fun v ->
       if not (Code.Var.Set.mem v arg_set)
       then (
         let l = local_of ctx v in
         Jvm.Code.aconst_null ctx.code;
         Jvm.Code.astore ctx.code l))
     entry.params);
  (* Emit start block first so control-flow fall-through matches
     block-address order. Then other blocks in sorted address order. *)
  let start_block = Code.Addr.Map.find prog.start prog.blocks in
  emit_block ctx prog prog.start start_block;
  Code.Addr.Map.iter
    (fun addr b ->
      if addr <> prog.start then emit_block ctx prog addr b)
    prog.blocks;
  (* Install deferred exception-handler entries. For each Pushtrap,
     install one entry per block in its protected set, covering
     that block's start..end labels (end is marked at the end of
     [emit_block]; we allocate it on demand). Using one entry per
     block sidesteps the problem that IR-ordered block emission
     doesn't lay out a try region as a contiguous byte range. *)
  List.iter
    (fun { protected; handler_lbl } ->
      Code.Addr.Set.iter
        (fun addr ->
          match
            ( Hashtbl.find_opt ctx.block_start addr
            , Hashtbl.find_opt ctx.block_end addr )
          with
          | Some start_lbl, Some end_lbl ->
            Jvm.Code.add_exception_handler
              ctx.code
              ~start_lbl
              ~end_lbl
              ~handler_lbl
              ~catch_class:(Some "CamlException")
          | _ -> ())
        protected)
    ctx.pending_handlers
