(* See the .mli for the design. The implementation is
   intentionally boring: JSON in, records out, plus a handful of
   merge / lookup helpers. *)

type stub =
  { prim_name : string
  ; class_name : string
  ; method_name : string
  ; descriptor : string
  ; arity : int
  ; weakdef : bool
  ; shorthand : bool
  ; source_path : string
  }

type t = stub list  (* Keyed access is rare at codegen time; a flat
                       list with a lookup table built on demand is
                       fine for the registry sizes we expect. *)

let empty : t = []

let all_stubs t = t

let find t name = List.find_opt (fun s -> s.prim_name = name) t

(* --- JVM descriptor helpers ---------------------------------------
   A descriptor like [(Ljava/lang/Object;J)Ljava/lang/Object;] has
   parameter types between the parens and a return type after. We
   only need to count parameters here — the actual descriptor string
   is passed through verbatim to the emitter. *)

let arity_of_descriptor desc =
  let n = String.length desc in
  if n < 2 || desc.[0] <> '('
  then invalid_arg ("stub_registry: malformed descriptor " ^ desc);
  let rec loop i acc =
    if i >= n then invalid_arg ("stub_registry: unterminated descriptor " ^ desc)
    else
      match desc.[i] with
      | ')' -> acc
      | 'B' | 'C' | 'D' | 'F' | 'I' | 'J' | 'S' | 'Z' ->
        loop (i + 1) (acc + 1)
      | 'L' ->
        (* L<name>; *)
        let j = ref (i + 1) in
        while !j < n && desc.[!j] <> ';' do incr j done;
        if !j >= n then invalid_arg ("stub_registry: unterminated L in " ^ desc);
        loop (!j + 1) (acc + 1)
      | '[' -> loop (i + 1) acc
      | c ->
        invalid_arg
          (Printf.sprintf "stub_registry: unexpected char %c in %s" c desc)
  in
  loop 1 0

let default_descriptor ~arity =
  let buf = Buffer.create (arity * 18 + 18) in
  Buffer.add_char buf '(';
  for _ = 1 to arity do Buffer.add_string buf "Ljava/lang/Object;" done;
  Buffer.add_string buf ")Ljava/lang/Object;";
  Buffer.contents buf

let split_target ~source_path target =
  match String.rindex_opt target '.' with
  | None ->
    failwith
      (Printf.sprintf "stub_registry (%s): target %S must be \
                       ClassName.methodName"
         source_path target)
  | Some i ->
    let cls = String.sub target 0 i in
    let meth = String.sub target (i + 1) (String.length target - i - 1) in
    (* JVM binary names use '/'; source usually uses '.'. Accept
       either in the manifest and normalise to slash. *)
    let cls = String.map (fun c -> if c = '.' then '/' else c) cls in
    cls, meth

(* --- JSON parsing --------------------------------------------------
   The schema is small enough that we walk the Yojson tree by hand;
   that avoids pulling in yojson.deriving just for two optional
   fields. *)

let parse_entry ~source_path ~prim_name ~default_arity = function
  | `String target ->
    let class_name, method_name = split_target ~source_path target in
    let arity = default_arity in
    let descriptor = default_descriptor ~arity in
    { prim_name
    ; class_name
    ; method_name
    ; descriptor
    ; arity
    ; weakdef = false
    ; shorthand = true
    ; source_path
    }
  | `Assoc fields ->
    let target =
      match List.assoc_opt "target" fields with
      | Some (`String s) -> s
      | Some _ ->
        failwith
          (Printf.sprintf "stub_registry (%s): %s target must be a string"
             source_path prim_name)
      | None ->
        failwith
          (Printf.sprintf "stub_registry (%s): %s missing \"target\""
             source_path prim_name)
    in
    let class_name, method_name = split_target ~source_path target in
    let descriptor =
      match List.assoc_opt "descriptor" fields with
      | Some (`String s) -> s
      | Some _ ->
        failwith
          (Printf.sprintf
             "stub_registry (%s): %s descriptor must be a string"
             source_path prim_name)
      | None -> default_descriptor ~arity:default_arity
    in
    let arity = arity_of_descriptor descriptor in
    let weakdef =
      match List.assoc_opt "weakdef" fields with
      | Some (`Bool b) -> b
      | Some _ ->
        failwith
          (Printf.sprintf "stub_registry (%s): %s weakdef must be a bool"
             source_path prim_name)
      | None -> false
    in
    (* Warn on unknown keys — gentle guard against typos without
       locking the schema. *)
    List.iter
      (fun (k, _) ->
        match k with
        | "target" | "descriptor" | "weakdef" -> ()
        | other ->
          Printf.eprintf
            "[stub_registry] warning (%s): unknown key %S on %s\n%!"
            source_path other prim_name)
      fields;
    { prim_name
    ; class_name
    ; method_name
    ; descriptor
    ; arity
    ; weakdef
    ; shorthand = false
    ; source_path
    }
  | other ->
    failwith
      (Printf.sprintf "stub_registry (%s): %s entry must be a string \
                       or object, got %s"
         source_path prim_name (Yojson.Safe.to_string other))

(* Arity for the default-descriptor branch: inferred from the actual
   Java method at compile time. At JSON-read time we don't know it
   — the shorthand must pass through a second pass that fills in
   the true arity after javac reports each method's signature. For
   v1 we default to 0 and the driver overwrites it once the class
   has been compiled; callers that don't do that second pass are
   assumed to only use the full-record form with [descriptor]. *)
let shorthand_default_arity = 0

let parse_json ~source_path json =
  match json with
  | `Assoc entries ->
    List.map
      (fun (prim_name, value) ->
        parse_entry
          ~source_path
          ~prim_name
          ~default_arity:shorthand_default_arity
          value)
      entries
  | _ ->
    failwith
      (Printf.sprintf "stub_registry: %s: top-level must be a JSON object"
         source_path)

let load_file path =
  let json =
    try Yojson.Safe.from_file path
    with Yojson.Json_error msg ->
      failwith
        (Printf.sprintf "stub_registry: JSON parse error in %s: %s" path msg)
  in
  parse_json ~source_path:path json

let load_string ~source_path s =
  let json =
    try Yojson.Safe.from_string s
    with Yojson.Json_error msg ->
      failwith
        (Printf.sprintf "stub_registry: JSON parse error in %s: %s"
           source_path msg)
  in
  parse_json ~source_path json

(* Merge two registries. Collisions: unless one side is weakdef,
   fail; otherwise the non-weak wins. *)
let merge_pair ~first ~second =
  let by_name = Hashtbl.create (List.length first + List.length second) in
  List.iter (fun s -> Hashtbl.replace by_name s.prim_name s) first;
  List.iter
    (fun s ->
      match Hashtbl.find_opt by_name s.prim_name with
      | None -> Hashtbl.replace by_name s.prim_name s
      | Some existing ->
        (match existing.weakdef, s.weakdef with
         | true, false -> Hashtbl.replace by_name s.prim_name s
         | false, true -> ()  (* keep [existing] *)
         | _ ->
           failwith
             (Printf.sprintf
                "stub_registry: duplicate entry for %s (in %s and %s); \
                 mark one with \"weakdef\": true to disambiguate"
                s.prim_name existing.source_path s.source_path)))
    second;
  Hashtbl.fold (fun _ v acc -> v :: acc) by_name []

let load_manifests paths =
  let registries = List.map load_file paths in
  List.fold_left (fun acc next -> merge_pair ~first:acc ~second:next)
    [] registries

let merge_defaults ~builtin ~user =
  (* User overrides builtin. The merge logic is the same as between
     two user files — weakdef on user means keep builtin. *)
  merge_pair ~first:builtin ~second:user

let java_sources ~manifest_dir t =
  let seen = Hashtbl.create 8 in
  (* Include every [.java] file in [manifest_dir] — helper classes
     like [FooHandle] that a caller classes reference but that
     don't appear in any manifest entry would otherwise be missed
     by the javac invocation. *)
  (try
     Array.iter
       (fun f ->
         if Filename.extension f = ".java"
         then
           Hashtbl.replace seen (Filename.concat manifest_dir f) ())
       (Sys.readdir manifest_dir)
   with Sys_error _ -> ());
  (* Still honour the manifest-named classes explicitly; protects
     against a setup where the manifest lives in a different
     directory than its sources. *)
  List.iter
    (fun s ->
      let leaf =
        match String.rindex_opt s.class_name '/' with
        | None -> s.class_name
        | Some i ->
          String.sub s.class_name (i + 1) (String.length s.class_name - i - 1)
      in
      let path = Filename.concat manifest_dir (leaf ^ ".java") in
      Hashtbl.replace seen path ())
    t;
  Hashtbl.fold (fun k () acc -> k :: acc) seen []
