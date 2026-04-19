open Bytecode

(* Unique id counter for predefined exception descriptors. OCaml's
   runtime uses negative ids assigned by Symtable.init; the absolute
   value doesn't matter to our codegen — it only relies on object
   identity — but we keep the sign consistent with the runtime
   convention to avoid surprising anyone who inspects globals. *)
let next_predef_id = ref 0

let fresh_predef_id () =
  decr next_predef_id;
  !next_predef_id

(* Build a real OCaml exception descriptor: a tag-248 block of
   [| name; id |]. Matches the shape Global_view.classify_field
   expects (tag 248 < no_scan_tag, so it's walked as a normal block
   of 2 fields). *)
let make_exn_descriptor name : Obj.t =
  let id = fresh_predef_id () in
  let block = Obj.new_block Obj.object_tag 2 in
  Obj.set_field block 0 (Obj.repr name);
  Obj.set_field block 1 (Obj.repr id);
  block

(* --- Merged primitive table -----------------------------------------
   Primitives referenced across all units. We keep first-seen order so
   output is deterministic; a hashtable indexes the reverse direction
   for fast [Reloc_primitive] resolution. *)
module Prim_table = struct
  type t =
    { mutable rev : string list  (* most-recently-added first *)
    ; mutable len : int
    ; index : (string, int) Hashtbl.t
    }

  let create () = { rev = []; len = 0; index = Hashtbl.create 32 }

  let intern t name =
    match Hashtbl.find_opt t.index name with
    | Some i -> i
    | None ->
      let i = t.len in
      Hashtbl.add t.index name i;
      t.rev <- name :: t.rev;
      t.len <- i + 1;
      i

  let to_array t = Array.of_list (List.rev t.rev)
end

(* --- Globals builder ------------------------------------------------ *)
module Globals = struct
  type t =
    { mutable rev : Obj.t list
    ; mutable len : int
    }

  let create () = { rev = []; len = 0 }

  let append t obj =
    let i = t.len in
    t.rev <- obj :: t.rev;
    t.len <- i + 1;
    i

  let to_array t = Array.of_list (List.rev t.rev)
end

let link (units : unit_info list) : t =
  let globals = Globals.create () in
  let prim_table = Prim_table.create () in

  (* 1. Predefined exceptions at canonical indices.
        [Runtimedef.builtin_exceptions] is the same list Symtable.init
        walks, so the i-th exception lands at globals slot i. *)
  let predef_slots : (string, int) Hashtbl.t = Hashtbl.create 16 in
  Array.iter
    (fun name ->
      let desc = make_exn_descriptor name in
      let idx = Globals.append globals desc in
      Hashtbl.add predef_slots name idx)
    Runtimedef.builtin_exceptions;

  (* 2. Reserve one global slot per compunit up-front. That way
        [Reloc_getcompunit] entries in earlier units can resolve to
        slots for later-declared units (forward references are
        legal). SETGLOBAL at runtime is what populates the slot. *)
  let compunit_slots : (string, int) Hashtbl.t = Hashtbl.create 16 in
  List.iter
    (fun u ->
      let idx = Globals.append globals (Obj.repr 0) in
      Hashtbl.add compunit_slots u.cu_name idx)
    units;

  (* 3. Walk each unit's relocs, intern literals / primitives and
        patch the code words. *)
  let slot_for_compunit name =
    match Hashtbl.find_opt compunit_slots name with
    | Some i -> i
    | None ->
      (* Partial link: reserve a placeholder slot for a unit we
         haven't seen. A later link step (or the runtime loader,
         for units that live in pre-linked Stdlib classes) would
         populate this. *)
      let i = Globals.append globals (Obj.repr 0) in
      Hashtbl.add compunit_slots name i;
      i
  in
  let patch u (reloc, word_off) =
    ignore u;
    let idx =
      match reloc with
      | Reloc_literal obj ->
        Globals.append globals obj
      | Reloc_getcompunit name | Reloc_setcompunit name ->
        slot_for_compunit name
      | Reloc_getpredef name ->
        (match Hashtbl.find_opt predef_slots name with
         | Some i -> i
         | None ->
           failwith
             (Printf.sprintf
                "linker: unknown predefined exception %s (referenced from %s)"
                name
                u.cu_name))
      | Reloc_primitive name ->
        Prim_table.intern prim_table name
    in
    u.cu_code.(word_off) <- idx
  in
  List.iter (fun u -> List.iter (patch u) u.cu_reloc) units;

  (* 4. Concatenate patched unit code into one array, tracking each
        unit's base word-offset so debug events can be re-keyed. *)
  let total_len =
    List.fold_left (fun acc u -> acc + Array.length u.cu_code) 0 units
  in
  let code = Array.make total_len 0 in
  let debug = Hashtbl.create 64 in
  let base = ref 0 in
  List.iter
    (fun u ->
      Array.blit u.cu_code 0 code !base (Array.length u.cu_code);
      Hashtbl.iter
        (fun pc loc -> Hashtbl.replace debug (!base + pc) loc)
        u.cu_debug;
      base := !base + Array.length u.cu_code)
    units;

  (* 5. Per-unit primitive declarations also feed the merged table.
        Matters mostly when a unit's [cu_primitives] lists primitives
        that never appear in a [Reloc_primitive] — keeps the table
        consistent with [read_exe], which carries the full PRIM
        section regardless of references. *)
  List.iter
    (fun u ->
      Array.iter
        (fun name -> ignore (Prim_table.intern prim_table name))
        u.cu_prims)
    units;

  { code
  ; prims = Prim_table.to_array prim_table
  ; globals = Globals.to_array globals
  ; debug
  }
