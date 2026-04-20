open Code

(* All costs are upper bounds on the emitted bytes. The emitter's
   per-op costs come from [Jvm_code] (each push/store/op takes 1–3
   bytes), plus a few bytes for kind-coercion checkcasts and
   box/unbox calls. We add modest slack (1–2 bytes per op) so the
   estimate stays conservative in the face of unusual kinds. *)

let rec constant = function
  | Int _ -> 5          (* iconst / bipush / sipush / ldc *)
  | Float _ -> 5        (* ldc2_w (3) + box/boxless *)
  | String _ -> 5       (* ldc / ldc_w *)
  | Null -> 1
  | Block (_, fields) ->
    (* new + dup + ctor + field stores. Each field is its own
       constant recursion, dup + ldc + aastore ≈ 8 extra bytes. *)
    20 + Array.fold_left (fun acc c -> acc + 8 + constant c) 0 fields

let prim_cost = function
  | Vectlength | Array_get -> 12
  | Not | IsInt -> 10
  | Eq | Neq | Lt | Le | Gt | Ge | Ult | Uge -> 16
  | Extern _ ->
    (* Conservative upper bound: many externs compile to a single
       invokevirtual (6 bytes), but the unknown-extern path falls
       back to a runtime-throwing stub of ~40 bytes. Picking the
       larger keeps us safe. *)
    40

let prim_arg_cost = function
  | Pv _ -> 3        (* aload + possible checkcast *)
  | Pc c -> constant c

let expr = function
  | Apply { args; _ } ->
    (* checkcast Closure, load each arg boxed, invokevirtual
       applyN(Object...)Object. *)
    20 + (6 * List.length args)
  | Block (_, fields) -> 15 + (6 * Array.length fields)
  | Field _ -> 10
  | Closure { captures; _ } -> 18 + (5 * List.length captures)
  | Constant c -> constant c
  | Prim (p, args) ->
    prim_cost p + List.fold_left (fun acc a -> acc + prim_arg_cost a) 0 args

let instr = function
  | Let (_, e) -> 6 + expr e            (* expr result + store to local *)
  | Set_field _ -> 14
  | Offset_ref _ -> 14
  | Array_set _ -> 18
  | Source_pc _ -> 0                    (* no emitted bytes *)

let last = function
  | Return _ -> 8
  | Raise _ -> 14                        (* new + dup + load + ctor + athrow *)
  | Stop -> 2
  | Branch (_, args) -> 8 + (4 * List.length args)
  | Cond (_, (_, a1), (_, a2)) ->
    (* Test + conditional branch + two edge sequences + goto. *)
    30 + (4 * (List.length a1 + List.length a2))
  | Switch (_, ints, tags) ->
    let n = Array.length ints + Array.length tags in
    (* Worst case: tableswitch header (~16) + padding + 4 bytes per
       case target, plus per-case edge moves. Overestimate a little. *)
    24 + (10 * n)
  | Pushtrap (_, _, _) -> 10        (* entry bookkeeping — exception
                                       entries are installed post-emit *)
  | Poptrap (_, args) -> 6 + (4 * List.length args)
  | Invoke_tail { args; _ } ->
    (* aload 0 (or nothing for static), load each arg as Object,
       invokevirtual/static, areturn. *)
    12 + (4 * List.length args)

let block (b : block) =
  Array.fold_left (fun acc i -> acc + instr i) 0 b.body + last b.branch

(* Conservative upper bound on per-instruction bytes. Callers use
   this with [Array.length body] for an O(1) "could this block need
   splitting?" filter that dodges the full walk on the overwhelming
   majority of blocks. Keep strictly >= every return value of
   [instr]: an [Apply] with many args or a [Closure] with many
   captures can run large; 256 bytes is enough slack that we'd need
   a single instruction with ~40 extern-call args to breach it. *)
let max_instr_cost = 256

(* Entry prologue overhead: the emitter pre-binds arg_vars to locals
   and null-initialises remaining start-block params. Tiny compared
   to the body but accounted for so [program] and [subset] align. *)
let entry_overhead (prog : program) =
  match Addr.Map.find_opt prog.start prog.blocks with
  | None -> 0
  | Some b -> 6 * List.length b.params

let program (prog : program) =
  let body =
    Addr.Map.fold (fun _ b acc -> acc + block b) prog.blocks 0
  in
  entry_overhead prog + body

(* [Array.length]-based upper bound on [program]. Cheap (no per-instr
   walk); [max_instr_cost * total_instrs + per_block_slack]. When
   this sits comfortably under the method-size limit we can skip the
   exact [program] walk entirely — the common case for the tens of
   thousands of tiny closures in a real link. *)
let program_upper_bound (prog : program) =
  let body_slack = 64 in
  Addr.Map.fold
    (fun _ b acc ->
      acc + (Array.length b.body * max_instr_cost) + body_slack)
    prog.blocks
    (entry_overhead prog)

let subset (prog : program) keep =
  let body =
    Addr.Set.fold
      (fun a acc ->
        match Addr.Map.find_opt a prog.blocks with
        | None -> acc
        | Some b -> acc + block b)
      keep
      0
  in
  entry_overhead prog + body

