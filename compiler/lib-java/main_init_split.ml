(* See [main_init_split.mli] for the rationale. The pass runs after
   [Parse_bytecode.parse_main] but before [Method_split.split]: if it
   succeeds, each unit gets its own [Code.program] that [Method_split]
   will further split only if that unit's init alone exceeds the
   JVM 64 KB limit. Cross-unit dispatch becomes ordinary
   [invokestatic] in [Main.main], so stack depth is O(1) per module
   instead of O(num_modules). *)

type unit_slice =
  { modname : string
  ; method_name : string
  ; prog : Code.program
  }

type plan =
  { units : unit_slice list
  ; driver_entry_addr : Code.Addr.t
  }

type result =
  | Split of plan
  | Rejected of string

(* ----------------------------------------------------------------- *)
(* Unit-name sanitation + uniquing.                                   *)

let is_ident_char c =
  (c >= 'a' && c <= 'z')
  || (c >= 'A' && c <= 'Z')
  || (c >= '0' && c <= '9')
  || c = '_'

let sanitise s =
  let b = Buffer.create (String.length s) in
  String.iter
    (fun c -> Buffer.add_char b (if is_ident_char c then c else '_'))
    s;
  let out = Buffer.contents b in
  if out = "" then "anon" else out

let unique_method_names (modnames : string list) : string list =
  let seen : (string, int) Hashtbl.t = Hashtbl.create 16 in
  List.map
    (fun m ->
      let base = "init_" ^ sanitise m in
      match Hashtbl.find_opt seen base with
      | None ->
        Hashtbl.add seen base 1;
        base
      | Some n ->
        Hashtbl.replace seen base (n + 1);
        Printf.sprintf "%s_%d" base (n + 1))
    modnames

(* ----------------------------------------------------------------- *)
(* Assign each block to a unit.                                       *)

(* Find the range of bytecode PCs this block covers, from its
   [Source_pc] markers. Returns [None] when the block carries no
   markers at all (parser-synthesized prelude blocks). *)
let block_pc_range (b : Code.block) : (int * int) option =
  let min_pc = ref max_int in
  let max_pc = ref min_int in
  Array.iter
    (function
      | Code.Source_pc pc ->
        if pc < !min_pc then min_pc := pc;
        if pc > !max_pc then max_pc := pc
      | _ -> ())
    b.body;
  if !min_pc = max_int then None else Some (!min_pc, !max_pc)

(* Linear scan into the sorted unit list. The list is tiny relative
   to the block count in real programs, and units are disjoint, so a
   naive walk is fine. *)
let unit_index_of_pc (units : Bytecode.Unit.t array) pc : int option =
  let n = Array.length units in
  let rec loop i =
    if i >= n then None
    else
      let u = units.(i) in
      if pc >= u.start_pc && pc < u.end_pc then Some i
      else loop (i + 1)
  in
  loop 0

(* ----------------------------------------------------------------- *)
(* CFG helpers.                                                       *)

let successors (b : Code.block) : Code.Addr.t list =
  match b.branch with
  | Code.Return _ | Raise _ | Stop | Invoke_tail _ -> []
  | Branch (a, _) -> [ a ]
  | Cond (_, (a, _), (b, _)) -> [ a; b ]
  | Switch (_, ints, tags) ->
    let from_arr arr = Array.to_list arr |> List.map fst in
    from_arr ints @ from_arr tags
  | Pushtrap ((body, _), _, (handler, _)) -> [ body; handler ]
  | Poptrap (a, _) -> [ a ]

(* ----------------------------------------------------------------- *)
(* Planning.                                                          *)

let extra_block_starts (units : Bytecode.Unit.t list) : int list =
  List.map (fun (u : Bytecode.Unit.t) -> u.start_pc) units

let plan (prog : Code.program) ~(units : Bytecode.Unit.t list) : result =
  if units = []
  then Rejected "no unit ranges"
  else
    let units_arr = Array.of_list units in
    let n_units = Array.length units_arr in
    (* Assign each block to a unit index. The entry block is allowed
       to carry no PC markers (parser prelude); it becomes part of
       unit 0 so it runs before anything else. *)
    let assign = Hashtbl.create (Code.Addr.Map.cardinal prog.blocks) in
    let straddle = ref None in
    let outside = ref None in
    Code.Addr.Map.iter
      (fun addr (b : Code.block) ->
        match block_pc_range b with
        | None ->
          if addr = prog.start
          then Hashtbl.add assign addr 0
          else (
            (* Non-entry block without any source marker is unusual
               but not fatal on its own; we assign by looking at
               successors in a second pass. Mark as pending. *)
            Hashtbl.add assign addr (-1))
        | Some (lo, hi) ->
          (match unit_index_of_pc units_arr lo, unit_index_of_pc units_arr hi with
           | None, _ | _, None ->
             if !outside = None then outside := Some (addr, lo, hi)
           | Some i, Some j when i = j -> Hashtbl.add assign addr i
           | Some i, Some j ->
             if !straddle = None then straddle := Some (addr, i, j, lo, hi)))
      prog.blocks;
    match !straddle with
    | Some (addr, i, j, lo, hi) ->
      Rejected
        (Printf.sprintf
           "block %s straddles units %s..%s (pcs %d..%d)"
           (Code.Addr.to_string addr)
           units_arr.(i).modname
           units_arr.(j).modname
           lo
           hi)
    | None ->
      match !outside with
      | Some (addr, lo, hi) ->
        Rejected
          (Printf.sprintf
             "block %s has pcs %d..%d outside any unit range"
             (Code.Addr.to_string addr)
             lo
             hi)
      | None ->
        (* Second pass: resolve pending (-1) assignments by looking
           at successors. If a pending block has any assigned
           successor, inherit the min successor unit; if not, drop. *)
        let progress = ref true in
        while !progress do
          progress := false;
          Hashtbl.iter
            (fun addr idx ->
              if idx = -1
              then
                let b = Code.Addr.Map.find addr prog.blocks in
                let succs = successors b in
                let succ_idxs =
                  List.filter_map
                    (fun a -> Hashtbl.find_opt assign a)
                    succs
                  |> List.filter (fun i -> i >= 0)
                in
                match succ_idxs with
                | [] -> ()
                | i :: rest ->
                  let min_i = List.fold_left min i rest in
                  Hashtbl.replace assign addr min_i;
                  progress := true)
            assign
        done;
        let unresolved =
          Hashtbl.fold
            (fun addr idx acc -> if idx = -1 then addr :: acc else acc)
            assign
            []
        in
        (match unresolved with
         | a :: _ ->
           Rejected
             (Printf.sprintf
                "block %s has no source marker and no assigned successor"
                (Code.Addr.to_string a))
         | [] ->
           (* Edge-locality check. Every CFG edge must stay within
              a unit. Crosses-unit edges are the thing we're trying
              to avoid — if they survived the parser, we can't
              honestly split. *)
           (* Cross-unit edges are permitted only when the source
              block ends in a plain [Branch]: the fall-through
              pattern the OCaml linker uses to chain unit inits.
              We record each such block so it can have its
              terminator rewritten to [Stop] inside its slice —
              the driver then invokes the next slice as an
              ordinary method call. Anything other than a plain
              [Branch] (a [Cond] or [Switch] targeting the next
              unit, say) is a control-flow pattern we can't turn
              into a sequential dispatch without more work, so we
              reject. *)
           let rewrite_to_stop = Hashtbl.create 16 in
           let reject = ref None in
           Code.Addr.Map.iter
             (fun addr (b : Code.block) ->
               let ui = Hashtbl.find assign addr in
               let crosses =
                 List.exists
                   (fun succ ->
                     match Hashtbl.find_opt assign succ with
                     | Some uj -> uj <> ui
                     | None -> false)
                   (successors b)
               in
               if crosses && !reject = None
               then
                 match b.branch with
                 | Code.Branch (_, _) -> Hashtbl.add rewrite_to_stop addr ()
                 | _ ->
                   reject :=
                     Some
                       (Printf.sprintf
                          "block %s in unit %s has non-Branch cross-unit \
                           terminator"
                          (Code.Addr.to_string addr)
                          units_arr.(ui).modname))
             prog.blocks;
           (match !reject with
            | Some why -> Rejected why
            | None ->
              (* Trap-locality check. If [compute_trap_contexts] says
                 any block in unit N has a pushtrap in its active
                 context that was itself in unit M (M < N), we can't
                 split — the handler jump would escape the unit. *)
              try
                let contexts = Code.compute_trap_contexts prog in
                let trap_cross = ref None in
                Hashtbl.iter
                  (fun addr ctx ->
                    let ui =
                      match Hashtbl.find_opt assign addr with
                      | Some i -> i
                      | None -> -1
                    in
                    if ui >= 0
                    then
                      List.iter
                        (fun trap_addr ->
                          match Hashtbl.find_opt assign trap_addr with
                          | Some uj when uj <> ui ->
                            if !trap_cross = None
                            then trap_cross := Some (addr, ui, trap_addr, uj)
                          | _ -> ())
                        ctx)
                  contexts;
                match !trap_cross with
                | Some (addr, ui, trap_addr, uj) ->
                  Rejected
                    (Printf.sprintf
                       "block %s in unit %s has active pushtrap from %s in unit %s"
                       (Code.Addr.to_string addr)
                       units_arr.(ui).modname
                       (Code.Addr.to_string trap_addr)
                       units_arr.(uj).modname)
                | None ->
                  (* Build per-unit block maps, rewriting every
                     cross-unit [Branch] source terminator to [Stop]
                     so the slice's IR has no dangling references to
                     blocks in other units. *)
                  let per_unit = Array.make n_units Code.Addr.Map.empty in
                  Code.Addr.Map.iter
                    (fun addr (b : Code.block) ->
                      let i = Hashtbl.find assign addr in
                      let b =
                        if Hashtbl.mem rewrite_to_stop addr
                        then { b with branch = Code.Stop }
                        else b
                      in
                      per_unit.(i) <- Code.Addr.Map.add addr b per_unit.(i))
                    prog.blocks;
                  (* Each unit's entry block is the one at its
                     [start_pc]; if the unit has any block at all,
                     we find it by linear search. Unit 0 also owns
                     the original [prog.start] (the parser prelude
                     block), so we treat [prog.start] specially:
                     it's the driver entry, and we route it through
                     unit 0. *)
                  let entry_of unit_idx =
                    let u = units_arr.(unit_idx) in
                    let found = ref None in
                    Code.Addr.Map.iter
                      (fun addr (b : Code.block) ->
                        if !found = None
                        then
                          match block_pc_range b with
                          | Some (lo, _) when lo = u.start_pc -> found := Some addr
                          | _ -> ())
                      per_unit.(unit_idx);
                    !found
                  in
                  let missing_entry = ref None in
                  let slices_rev = ref [] in
                  let modnames_rev = ref [] in
                  for i = 0 to n_units - 1 do
                    if Code.Addr.Map.is_empty per_unit.(i)
                       || !missing_entry <> None
                    then ()
                    else
                      match entry_of i with
                      | None -> missing_entry := Some i
                      | Some entry ->
                        let sub =
                          { Code.start = entry
                          ; blocks = per_unit.(i)
                          ; free_pc = prog.free_pc
                          }
                        in
                        slices_rev :=
                          (units_arr.(i).modname, sub) :: !slices_rev;
                        modnames_rev :=
                          units_arr.(i).modname :: !modnames_rev
                  done;
                  match !missing_entry with
                  | Some i ->
                    Rejected
                      (Printf.sprintf
                         "unit %s has blocks but no block starting at its entry pc %d"
                         units_arr.(i).modname
                         units_arr.(i).start_pc)
                  | None ->
                    let modnames = List.rev !modnames_rev in
                    let method_names = unique_method_names modnames in
                    let slices = List.rev !slices_rev in
                    let unit_slices =
                      List.map2
                        (fun (modname, prog) method_name ->
                          { modname; method_name; prog })
                        slices
                        method_names
                    in
                    Split
                      { units = unit_slices
                      ; driver_entry_addr = prog.start
                      }
              with Failure msg ->
                Rejected ("trap-context computation failed: " ^ msg)))
