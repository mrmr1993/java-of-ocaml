(* See [cmi_reader.mli]. Uses only the stable [Cmi_format] /
   [Types] / [Path] surface of [compiler-libs], so the reader
   carries across 4.14 / 5.x without a dedicated shim. If that
   stops being true, slot it behind [bytecode_compat]. *)

type facade_kind =
  | K_int
  | K_long
  | K_string
  | K_float
  | K_bool
  | K_unit
  | K_fun of facade_kind list * facade_kind
  | K_other

type binding =
  { name : string
  ; field_index : int
  ; kind : facade_kind
  }

type t =
  { modname : string
  ; field_chain : int list
  ; bindings : binding list
  }

(* --- Type classification ------------------------------------------
   We peel [Tlink] / [Tsubst] chains with [Types.get_desc] and match
   on the head. [Tconstr] with a known base path + no type args maps
   to a [facade_kind]; arrows recursively classify argument and
   return types. Anything else — polymorphic, higher-order, variant,
   record, tuple, first-class module — returns [K_other]. *)

let base_of_path p =
  (* [Path.name] produces dotted form like [Stdlib.Int64.t]; [Path.last]
     gives just [t]. We look at both the full name and the head so
     that, e.g., [int] from [Stdlib] vs a user-defined [Foo.int] are
     distinguishable even though both have [last = "int"]. *)
  Path.name p, Path.last p

let rec classify ty =
  match Types.get_desc ty with
  | Tarrow (_, dom, codom, _) ->
    (* Flatten right-associative arrows so a curried [int -> int ->
       int] surfaces as [K_fun ([K_int; K_int], K_int)]. *)
    let d = classify dom in
    (match classify codom with
     | K_fun (args, ret) -> K_fun (d :: args, ret)
     | ret -> K_fun ([ d ], ret))
  | Tconstr (p, [], _) ->
    let full, last = base_of_path p in
    (match full, last with
     | "int", _ | "Stdlib.int", _ -> K_int
     | "int64", _ | "Stdlib.int64", _ | "Stdlib.Int64.t", _ -> K_long
     | "nativeint", _ | "Stdlib.nativeint", _ -> K_long
     | "string", _ | "Stdlib.string", _ | "Stdlib.String.t", _ -> K_string
     | "bytes", _ | "Stdlib.bytes", _ -> K_string
     | "float", _ | "Stdlib.float", _ -> K_float
     | "bool", _ | "Stdlib.bool", _ -> K_bool
     | "unit", _ | "Stdlib.unit", _ -> K_unit
     | _, _ -> K_other)
  | Tconstr (_, _ :: _, _) ->
    (* Parameterised type constructors (['a list], ['a array], ...)
       fall through to opaque for now — they're tractable but each
       needs a deliberate signature decision (generic in Java? erase?
       wrap?) and the first landing keeps the scope tight. *)
    K_other
  | Tvar _ | Tunivar _ -> K_other
  | Ttuple _ | Tobject _ | Tfield _ | Tnil -> K_other
  | Tpackage _ | Tvariant _ | Tpoly _ -> K_other
  | Tlink _ | Tsubst _ ->
    (* [get_desc] should have peeled these; if it didn't we're
       looking at a malformed type_expr. Treat as opaque rather
       than asserting. *)
    K_other

(* --- Signature walk ------------------------------------------------
   Module-struct field layout: [Sig_value], [Sig_module], [Sig_class]
   and [Sig_typext] each consume a slot; [Sig_type] and
   [Sig_modtype] / [Sig_class_type] do not. Only [Sig_value] is
   surfaced as a binding in this pass — the rest only matter for
   their offset-bumping effect. *)

let consumes_slot : Types.signature_item -> bool = function
  | Sig_value (_, vd, _) ->
    (* [Val_prim] bindings are inlined at call sites and do not land
       in the module block. *)
    (match vd.val_kind with Val_prim _ -> false | _ -> true)
  | Sig_module _ | Sig_class _ | Sig_typext _ -> true
  | Sig_type _ | Sig_modtype _ | Sig_class_type _ -> false

let walk_signature sig_items =
  let bindings = ref [] in
  let idx = ref 0 in
  List.iter
    (fun item ->
      (match item with
       | Types.Sig_value (id, vd, _) ->
         (* Skip primitives: a [Val_prim] binding does not land in
            the module block; the call site inlines the primitive. *)
         (match vd.val_kind with
          | Val_prim _ -> ()
          | _ ->
            bindings :=
              { name = Ident.name id
              ; field_index = !idx
              ; kind = classify vd.val_type
              }
              :: !bindings)
       | _ -> ());
      if consumes_slot item then incr idx)
    sig_items;
  List.rev !bindings

(* --- Path resolution ----------------------------------------------
   Accept either [Foo.cmi] or [foo.cmi] across the search path.
   First hit wins. *)

let find_cmi ~search_paths ~modname =
  let candidates =
    [ modname ^ ".cmi"
    ; String.uncapitalize_ascii modname ^ ".cmi"
    ; String.capitalize_ascii modname ^ ".cmi"
    ]
  in
  let try_dir d =
    List.find_map
      (fun f ->
        let p = Filename.concat d f in
        if Sys.file_exists p then Some p else None)
      candidates
  in
  List.find_map try_dir search_paths

let read ~search_paths ~modname =
  match find_cmi ~search_paths ~modname with
  | None ->
    failwith
      (Printf.sprintf
         "java_of_ocaml --export-module %s: no matching .cmi on the \
          search path (%s)"
         modname
         (if search_paths = [] then "empty; pass -I / --cmi-path"
          else String.concat ":" search_paths))
  | Some path ->
    let infos =
      try Cmi_format.read_cmi path
      with e ->
        failwith
          (Printf.sprintf
             "java_of_ocaml --export-module %s: failed to read %s: %s"
             modname
             path
             (Printexc.to_string e))
    in
    { modname = infos.cmi_name
    ; field_chain = []
    ; bindings = walk_signature infos.cmi_sign
    }

(* --- Nested-module descent ----------------------------------------
   Walk one [Sig_module] at a time. At each step, count slot-
   consuming signature items before the target submodule so we
   recover its field index in its parent's module block, then
   follow its body — [Mty_signature] directly, or [Mty_ident]
   after path-resolution — to resolve the next segment.

   Path resolution is intentionally lightweight: we do not set up
   a full [Env.t]. Instead we carry a stack of enclosing
   signatures (innermost first) plus a lazy cache of external
   [.cmi]s reachable from the search path, and look up modtype /
   module paths by name inside that stack. This is approximate
   but handles the common shapes ([Pident X] referring to a local
   [module type X = ...], [Pdot (Pident M, "X")] referring to a
   modtype exported from a sibling [.cmi]). Functors, applicative
   paths, and module-alias chases are out of scope and produce a
   clear error message. *)

type env =
  { search_paths : string list
  ; cmi_cache : (string, Types.signature) Hashtbl.t
  ; mutable enclosing : Types.signature list
        (* Innermost first. Used to resolve [Pident] paths. *)
  }

let make_env search_paths =
  { search_paths
  ; cmi_cache = Hashtbl.create 16
  ; enclosing = []
  }

let load_cmi_sig env modname =
  match Hashtbl.find_opt env.cmi_cache modname with
  | Some s -> Some s
  | None ->
    (match find_cmi ~search_paths:env.search_paths ~modname with
     | None -> None
     | Some p ->
       (try
          let infos = Cmi_format.read_cmi p in
          Hashtbl.add env.cmi_cache modname infos.cmi_sign;
          Some infos.cmi_sign
        with _ -> None))

let find_submodule (sig_items : Types.signature_item list) ~name =
  let idx = ref 0 in
  let result = ref None in
  List.iter
    (fun item ->
      (match item with
       | Types.Sig_module (id, _, md, _, _) when Ident.name id = name ->
         if !result = None then result := Some (!idx, md)
       | _ -> ());
      if consumes_slot item then incr idx)
    sig_items;
  !result

let find_modtype_in_sig (sig_items : Types.signature_item list) ~name =
  List.find_map
    (function
      | Types.Sig_modtype (id, decl, _) when Ident.name id = name ->
        Some decl.mtd_type
      | _ -> None)
    sig_items

let find_module_in_sig (sig_items : Types.signature_item list) ~name =
  List.find_map
    (function
      | Types.Sig_module (id, _, md, _, _) when Ident.name id = name ->
        Some md.md_type
      | _ -> None)
    sig_items

(* Resolve a module path ([Pident] / [Pdot], we ignore [Papply] and
   anything else) to the signature items it names. Used as the
   parent-lookup step for [Pdot] modtype paths and for [Mty_alias]
   chases. *)
let rec resolve_module_path env (p : Path.t) : Types.signature option =
  match p with
  | Pident id ->
    let name = Ident.name id in
    (match
       List.find_map (fun s -> find_module_in_sig s ~name) env.enclosing
     with
     | Some mt -> resolve_module_type env mt
     | None -> load_cmi_sig env name)
  | Pdot (parent, name) ->
    (match resolve_module_path env parent with
     | None -> None
     | Some sig_items ->
       match find_module_in_sig sig_items ~name with
       | None -> None
       | Some mt -> resolve_module_type env mt)
  | _ -> None

(* Resolve an [Mty_ident]-style path reference to its target
   module-type, returning the target [module_type] (one dereference
   step; the caller keeps resolving until it lands on
   [Mty_signature]). *)
and resolve_modtype_path env (p : Path.t) : Types.module_type option =
  match p with
  | Pident id ->
    let name = Ident.name id in
    (match
       List.find_map
         (fun s -> find_modtype_in_sig s ~name)
         env.enclosing
     with
     | Some mtd -> mtd
     | None -> None)
  | Pdot (parent, name) ->
    (match resolve_module_path env parent with
     | None -> None
     | Some sig_items ->
       (match find_modtype_in_sig sig_items ~name with
        | Some (Some mt) -> Some mt
        | Some None -> None  (* abstract module type *)
        | None -> None))
  | _ -> None

(* Collapse a [module_type] chain into its underlying [signature],
   chasing [Mty_ident] (path to a module type) and [Mty_alias]
   (path to a module). Bounded iteration to guard against
   pathological inputs. *)
and resolve_module_type ?(fuel = 8) env (mt : Types.module_type)
    : Types.signature option
  =
  if fuel <= 0 then None
  else
    match mt with
    | Mty_signature s -> Some s
    | Mty_ident p ->
      (match resolve_modtype_path env p with
       | None -> None
       | Some mt' -> resolve_module_type ~fuel:(fuel - 1) env mt')
    | Mty_alias p ->
      (match resolve_module_path env p with
       | None -> None
       | Some s -> Some s)
    | Mty_functor _ -> None

let rec descend env sig_items ~path =
  match path with
  | [] -> Ok ([], sig_items)
  | name :: rest ->
    match find_submodule sig_items ~name with
    | None ->
      Error (Printf.sprintf "no submodule %S in signature" name)
    | Some (fidx, md) ->
      (* Push the parent sig so it's in scope for resolving any
         [Mty_ident] references encountered below. *)
      env.enclosing <- sig_items :: env.enclosing;
      let inner =
        match md.md_type with
        | Mty_signature s -> Some s
        | (Mty_ident _ | Mty_alias _) as mt -> resolve_module_type env mt
        | Mty_functor _ -> None
      in
      let result =
        match inner with
        | None ->
          Error
            (Printf.sprintf
               "submodule %S body could not be resolved to an explicit \
                signature (Mty_functor / Mty_alias to a non-loadable \
                module, or an Mty_ident chain that bottomed out at an \
                abstract module type)"
               name)
        | Some inner_sig ->
          match descend env inner_sig ~path:rest with
          | Error _ as e -> e
          | Ok (chain, leaf) -> Ok (fidx :: chain, leaf)
      in
      env.enclosing <- List.tl env.enclosing;
      result

let read_path ~search_paths ~outer ~sub_path =
  match find_cmi ~search_paths ~modname:outer with
  | None ->
    failwith
      (Printf.sprintf
         "java_of_ocaml --export-module %s.%s: no matching .cmi on \
          the search path (%s)"
         outer
         (String.concat "." sub_path)
         (if search_paths = [] then "empty; pass -I / --cmi-path"
          else String.concat ":" search_paths))
  | Some path ->
    let infos =
      try Cmi_format.read_cmi path
      with e ->
        failwith
          (Printf.sprintf
             "java_of_ocaml --export-module %s.%s: failed to read %s: %s"
             outer
             (String.concat "." sub_path)
             path
             (Printexc.to_string e))
    in
    let env = make_env search_paths in
    (* Seed the cache so [Pident <outer>] self-references resolve. *)
    Hashtbl.add env.cmi_cache infos.cmi_name infos.cmi_sign;
    match descend env infos.cmi_sign ~path:sub_path with
    | Error why ->
      failwith
        (Printf.sprintf
           "java_of_ocaml --export-module %s.%s: %s"
           outer
           (String.concat "." sub_path)
           why)
    | Ok (chain, leaf) ->
      { modname =
          String.concat "." (infos.cmi_name :: sub_path)
      ; field_chain = chain
      ; bindings = walk_signature leaf
      }
