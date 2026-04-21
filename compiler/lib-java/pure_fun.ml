open Code

(* --- Known-pure C primitives ------------------------------------------
   A C primitive is pure iff it has no observable side effect and never
   mutates state visible to the program. Conservative: we only include
   ones whose implementation in [runtime-java/] and OCaml semantics we
   can verify as read-only. Everything else (I/O, bytes/array mutation,
   exception-raising helpers) stays impure. *)

module String_set = Set.Make (String)

let pure_extern_set =
  List.fold_left
    (fun s n -> String_set.add n s)
    String_set.empty
    [ (* Structural comparison on immutable shapes — reads only. *)
      "caml_equal"
    ; "caml_notequal"
    ; "caml_compare"
    ; "caml_lessthan"
    ; "caml_greaterthan"
    ; "caml_lessequal"
    ; "caml_greaterequal"
    ; "caml_int_compare"
    ; "caml_string_compare"
    ; "caml_string_equal"
    ; "caml_string_notequal"
    ; "caml_string_lessthan"
    ; "caml_string_lessequal"
    ; "caml_string_greaterthan"
    ; "caml_string_greaterequal"
    ; (* Block introspection — reads tag / size. *)
      "caml_obj_tag"
    ; (* Sys constants — pure by construction. *)
      "caml_sys_get_config"
    ; "caml_sys_const_big_endian"
    ; "caml_sys_const_word_size"
    ; "caml_sys_const_int_size"
    ; "caml_sys_const_max_wosize"
    ; "caml_sys_const_ostype_unix"
    ; "caml_sys_const_ostype_win32"
    ; "caml_sys_const_ostype_cygwin"
    ; "caml_sys_const_backend_type"
    ]

let is_pure_extern name = String_set.mem name pure_extern_set

(* --- Pure-expr predicate parameterised on a pure-closure set --------- *)

type t = Var.Set.t

let empty = Var.Set.empty

let pure_expr pure_funs = function
  | Block _ | Field _ | Closure _ | Constant _ -> true
  | Apply { f; args = _; exact } -> exact && Var.Set.mem f pure_funs
  | Prim (prim, _args) ->
    (match prim with
     | Vectlength | Not | IsInt | Eq | Neq | Lt | Le | Gt | Ge | Ult | Uge ->
       true
     | Array_get ->
       (* May raise [Invalid_argument] out of bounds. *)
       false
     | Extern name -> is_pure_extern name)
  | Invoke_helper _ ->
    (* Helper methods extracted by [Method_split]'s Let_in cut can
       have arbitrary side-effects (they might raise, perform I/O,
       etc.). Not pure. *)
    false

let pure_instr pure_funs = function
  | Let (_, e) -> pure_expr pure_funs e
  | Set_field _ | Offset_ref _ | Array_set _ -> false
  | Source_pc _ -> true

(* --- Traversal ------------------------------------------------------
   Walk each block reachable from a starting pc. A block is pure when:
   - Its terminator is not [Raise].
   - Every instruction is pure (under the currently-known [funs] set).
   - Every successor block is pure.
   Back-edges (cycles) drop us to "conservatively impure" — we can't
   prove loop termination. Matches [Pure_fun] in jsoo. *)

module AddrTbl = Hashtbl.Make (struct
  type t = int

  let equal = Int.equal
  let hash = Hashtbl.hash
end)

(* Local [fold_children] on a [blocks] map (no free_pc / start
   needed). Mirrors [Code.fold_children] without the program
   wrapper. *)
let fold_children_blocks blocks pc f init =
  let b = Addr.Map.find pc blocks in
  let step (a, _args) acc = f a acc in
  match b.branch with
  | Return _ | Raise _ | Stop | Invoke_tail _ -> init
  | Branch c -> step c init
  | Cond (_, c1, c2) -> init |> step c1 |> step c2
  | Switch (_, ints, tags) ->
    let after_ints = Array.fold_left (fun acc c -> step c acc) init ints in
    Array.fold_left (fun acc c -> step c acc) after_ints tags
  | Pushtrap (body, _, handler) -> init |> step body |> step handler
  | Poptrap c -> step c init

let rec traverse blocks pc visited pure_blocks funs =
  if AddrTbl.mem visited pc
  then AddrTbl.mem pure_blocks pc
  else if not (Addr.Map.mem pc blocks)
  then
    (* Closure body lives in another function's IR (the compile
       driver parses each CLOSURE/CLOSUREREC body as its own program).
       Conservatively impure — we can't see the body here. *)
    false
  else (
    AddrTbl.add visited pc ();
    let pure = block blocks pc visited pure_blocks funs in
    let pure =
      fold_children_blocks
        blocks
        pc
        (fun pc' acc ->
          let pure' = traverse blocks pc' visited pure_blocks funs in
          acc && pure')
        pure
    in
    if pure then AddrTbl.add pure_blocks pc ();
    pure)

and block blocks pc visited pure_blocks funs =
  let b = Addr.Map.find pc blocks in
  let term_pure =
    match b.branch with
    | Raise _ | Invoke_tail _ -> false
    | _ -> true
  in
  Array.fold_left
    (fun pure i ->
      (match i with
       | Let (x, Closure { body = pc', _; _ }) ->
         let pure' = traverse blocks pc' visited pure_blocks funs in
         if pure' then funs := Var.Set.add x !funs
       | _ -> ());
      pure && pure_instr !funs i)
    term_pure
    b.body

let f (p : program) : t =
  let visited = AddrTbl.create 64 in
  let pure_blocks = AddrTbl.create 64 in
  let funs = ref Var.Set.empty in
  let _ = traverse p.blocks p.start visited pure_blocks funs in
  !funs
