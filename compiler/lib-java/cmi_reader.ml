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
    ; bindings = walk_signature infos.cmi_sign
    }
