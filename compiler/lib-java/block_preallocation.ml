open Code

type stats =
  { blocks_rewritten : int
  ; fields_streamed : int
  }

(* Only rewrite [Block] exprs with at least this many fields. Small
   blocks stay as the [Block (tag, fs)] expression so downstream
   kind inference gets [K_block (list)]. The win from streaming
   Set_fields only shows up once field liveness starts to bunch. *)
let large_block_threshold = 4

(* Description of one candidate MAKEBLOCK in a block body. [defs] is
   a parallel array to the original [fields]: entry [i] says where
   field [i] is defined — either [Body k] (a body [Let] at index
   [k]) or [Param] (value comes from [block.params] or an earlier
   outer scope, treated as "available at block entry"). [alloc_pos]
   is the body index where the [alloc_block] Let should be emitted
   — [None] means "at block entry" (prepended before body[0]). *)
type def_site =
  | Body of int
  | Param

type candidate =
  { make_pos : int       (* index in original body of the Let we drop *)
  ; carrier : Var.t      (* carrier Var, re-bound by the alloc_block Let *)
  ; tag : int
  ; fields : Var.t array
  ; defs : def_site array
  ; alloc_pos : int option (* None = at block entry; Some k = before body[k] *)
  }

(* Find the def-site of each field. Returns [None] if any field's
   def-site can't be resolved — SSA invariants (vars are param or
   body-Let) should make this impossible, but we guard against bugs
   in upstream passes by falling through to the default lowering. *)
let resolve_field_defs ~body ~params fields =
  let param_set =
    List.fold_left (fun s v -> Var.Set.add v s) Var.Set.empty params
  in
  let def_of_body =
    let tbl = Hashtbl.create 16 in
    Array.iteri
      (fun k instr ->
        match instr with
        | Let (v, _) -> Hashtbl.replace tbl v k
        | Set_field _ | Offset_ref _ | Array_set _ | Source_pc _ -> ())
      body;
    tbl
  in
  let n = Array.length fields in
  let defs = Array.make n Param in
  let ok = ref true in
  for i = 0 to n - 1 do
    let v = fields.(i) in
    match Hashtbl.find_opt def_of_body v with
    | Some k -> defs.(i) <- Body k
    | None -> if Var.Set.mem v param_set then defs.(i) <- Param else ok := false
  done;
  if !ok then Some defs else None

(* Compute where to put the [alloc_block] Let. If any field is a
   param (or otherwise not-body-defined), we need the block
   allocated at entry. Otherwise, allocate right before the
   earliest body-Let that defines a field. *)
let choose_alloc_pos defs =
  let has_param =
    Array.exists (function Param -> true | Body _ -> false) defs
  in
  if has_param
  then None
  else (
    let min_k = ref max_int in
    Array.iter
      (function
        | Body k -> if k < !min_k then min_k := k
        | Param -> ())
      defs;
    assert (!min_k <> max_int);
    Some !min_k)

(* Scan a block body for candidate MAKEBLOCKs. Returns a list of
   candidates (in body order), fit for the rewrite step. *)
let collect_candidates (b : block) =
  let n = Array.length b.body in
  let out = ref [] in
  for k = n - 1 downto 0 do
    match b.body.(k) with
    | Let (carrier, Block (tag, fields))
      when Array.length fields >= large_block_threshold ->
      (match resolve_field_defs ~body:b.body ~params:b.params fields with
       | None -> ()
       | Some defs ->
         let alloc_pos = choose_alloc_pos defs in
         out
           := { make_pos = k; carrier; tag; fields; defs; alloc_pos }
              :: !out)
    | _ -> ()
  done;
  !out

(* Build the two tables the rewriter needs:
   - [alloc_at_entry]: candidates whose alloc_pos = None (prepend
     at block entry).
   - [alloc_at k]: candidates whose alloc_pos = Some k (insert
     just before body[k]).
   - [writes_after k]: Set_field emissions to append just after
     body[k] fires. Stored in slot-ascending order so the emitted
     sequence is readable.
   - [writes_at_entry]: Set_fields for param-sourced fields,
     emitted right after any entry-time alloc_blocks. *)
let plan (cands : candidate list) =
  let alloc_at_entry = ref [] in
  let alloc_at = Hashtbl.create 8 in
  let writes_at_entry = ref [] in
  let writes_after = Hashtbl.create 16 in
  let add_write tbl k w =
    let prev = try Hashtbl.find tbl k with Not_found -> [] in
    Hashtbl.replace tbl k (w :: prev)
  in
  let push_entry_write w = writes_at_entry := w :: !writes_at_entry in
  List.iter
    (fun c ->
      (match c.alloc_pos with
       | None -> alloc_at_entry := c :: !alloc_at_entry
       | Some k ->
         let prev = try Hashtbl.find alloc_at k with Not_found -> [] in
         Hashtbl.replace alloc_at k (c :: prev));
      Array.iteri
        (fun slot def ->
          let field_var = c.fields.(slot) in
          match def with
          | Param -> push_entry_write (c.carrier, slot, field_var)
          | Body k -> add_write writes_after k (c.carrier, slot, field_var))
        c.defs)
    cands;
  ( List.rev !alloc_at_entry
  , alloc_at
  , List.rev !writes_at_entry
  , writes_after )

let alloc_instr c =
  Let
    ( c.carrier
    , Prim
        ( Extern "alloc_block"
        , [ Pc (Int c.tag); Pc (Int (Array.length c.fields)) ] ) )

let set_field_instr (carrier, slot, v) = Set_field (carrier, slot, v)

(* Rewrite one block. [fields_streamed_ref] accumulates the total
   count of Set_fields emitted — used for stats. *)
let rewrite_block ~fields_streamed_ref (b : block) =
  let cands = collect_candidates b in
  if cands = []
  then b, false
  else (
    let drop_positions = Hashtbl.create 8 in
    List.iter (fun c -> Hashtbl.replace drop_positions c.make_pos ()) cands;
    let alloc_at_entry_list, alloc_at, writes_at_entry, writes_after =
      plan cands
    in
    let out = ref [] in
    let emit i = out := i :: !out in
    (* Entry-time prefix: alloc for every entry-alloc candidate,
       followed by their param-sourced Set_fields. *)
    List.iter (fun c -> emit (alloc_instr c)) alloc_at_entry_list;
    List.iter (fun w -> emit (set_field_instr w)) writes_at_entry;
    fields_streamed_ref := !fields_streamed_ref + List.length writes_at_entry;
    (* Walk the original body. *)
    Array.iteri
      (fun k instr ->
        (match Hashtbl.find_opt alloc_at k with
         | Some cs -> List.iter (fun c -> emit (alloc_instr c)) cs
         | None -> ());
        if Hashtbl.mem drop_positions k
        then ()
        else emit instr;
        match Hashtbl.find_opt writes_after k with
        | Some ws ->
          (* Stored reversed by add_write; reverse for ascending
             slot order in the emitted sequence. *)
          let ws = List.rev ws in
          List.iter (fun w -> emit (set_field_instr w)) ws;
          fields_streamed_ref := !fields_streamed_ref + List.length ws
        | None -> ())
      b.body;
    let body = Array.of_list (List.rev !out) in
    { b with body }, true)

let run (prog : program) : program * stats =
  let blocks_rewritten = ref 0 in
  let fields_streamed = ref 0 in
  let blocks =
    Addr.Map.map
      (fun b ->
        let b', rewrote =
          rewrite_block ~fields_streamed_ref:fields_streamed b
        in
        if rewrote then incr blocks_rewritten;
        b')
      prog.blocks
  in
  ( { prog with blocks }
  , { blocks_rewritten = !blocks_rewritten
    ; fields_streamed = !fields_streamed
    } )

let f prog =
  let prog, _ = run prog in
  prog
