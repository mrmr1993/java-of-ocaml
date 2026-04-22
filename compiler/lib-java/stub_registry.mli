(* Registry mapping OCaml C-primitive names to user-provided Java
   stubs. Each stub is a [public static] method in a Java class,
   selected by a JSON manifest that the driver feeds the compiler.

   The manifest (one file per bundle, possibly several bundles per
   compile) is a flat object:

   {
     "core_unix_getrlimit": "UnixStubs.core_unix_getrlimit",
     "unix_O_RDONLY": {
       "target": "UnixStubs.unix_O_RDONLY",
       "descriptor": "()J"
     }
   }

   Values are either a [ClassName.methodName] shorthand (which
   implies the default all-[Object] descriptor) or a record with
   optional [descriptor] / [weakdef] fields. *)

type stub =
  { prim_name : string
  ; class_name : string   (* e.g. "UnixStubs" (binary name, '/' separated) *)
  ; method_name : string  (* Java method name *)
  ; descriptor : string   (* JVM method descriptor *)
  ; arity : int           (* parameter count, derived from descriptor *)
  ; weakdef : bool        (* if true, hardcoded handler wins *)
  ; shorthand : bool      (* true if the manifest entry was the
                             [Class.method] shorthand — the
                             descriptor is a placeholder, and the
                             emitter should build the real one from
                             the call-site arity. False when the
                             descriptor came explicitly from the
                             manifest. *)
  ; source_path : string  (* manifest path, for diagnostics *)
  }

type t

(** [empty] is a registry with no stubs. *)
val empty : t

(** [load_manifests paths] reads each JSON file and returns a merged
    registry. Later entries for the same prim-name are rejected with
    [Failure] unless one side has [weakdef: true], in which case the
    non-weak one wins silently.

    [.java] source paths referenced by targets are resolved relative
    to the manifest file's directory by [java_sources] below; the
    registry itself just stores class names. *)
val load_manifests : string list -> t

(** [load_string ~source_path s] parses a JSON manifest from an
    in-memory string. Used to read the built-in stubs list that's
    embedded at compile time, without reaching out to the
    filesystem. *)
val load_string : source_path:string -> string -> t

(** [find t name] returns the stub registered for an OCaml primitive
    name, if any. *)
val find : t -> string -> stub option

(** [all_stubs t] returns every registered stub in load order. Useful
    for the driver when packaging output classes. *)
val all_stubs : t -> stub list

(** [java_sources ~manifest_dir t] returns all [.java] paths that
    need to be compiled alongside the manifest. Each returned path
    is absolute. In v1 we expect sources to live in
    [manifest_dir]; the set is computed by collecting every distinct
    [class_name] and resolving [manifest_dir ^/ class_name ^ ".java"].
    Callers can layer discovery policy on top — this helper is only
    for the default case. *)
val java_sources : manifest_dir:string -> t -> string list

(** [merge_defaults ~builtin ~user] produces a registry in which
    entries from [user] override same-named entries from [builtin]
    (modulo the [weakdef] flag on either side — see the module
    docstring above). Used to apply user overrides on top of the
    compiler's own built-in stub list. *)
val merge_defaults : builtin:t -> user:t -> t
