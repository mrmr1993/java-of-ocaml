# stubs-contrib — out-of-tree C-primitive stubs

Stubs for OCaml libraries whose C primitives `js_of_ocaml` does
not ship in its built-in runtime. Each subdirectory corresponds to
one upstream opam package; pass the manifest to
`java_of_ocaml --stub-manifest` to enable it for a compile.

Layout mirrors `js_of_ocaml`'s: library-level granularity, and
the libraries that upstream includes (`Str`, `Bigarray`, `Unix`,
etc.) live under `runtime-java/stubs/` and are always loaded;
anything not upstream lives here and is opt-in.

## Current libraries

| Directory               | Package(s)                                         | Manifest                                |
| ----------------------- | -------------------------------------------------- | --------------------------------------- |
| `integers/`             | `integers`                                         | `stubs-contrib/integers/stubs.json`     |
| `ctypes/`               | `ctypes` (ldouble, ldouble_complex, POSIX typedefs) | `stubs-contrib/ctypes/stubs.json`       |
| `core_unix/`            | `core_unix`, `core_linux`, `bigstring`, `iobuf`    | `stubs-contrib/core_unix/stubs.json`    |

## Why this layout

`js_of_ocaml` keeps its built-in runtime flat under `runtime/js/`
(`str.js`, `unix.js`, `bigarray.js`, …) — one file per OCaml library,
always bundled. For libraries outside that set (e.g. `integers`),
upstream community packages like `integers_stubs_js` ship a `.js`
file that user projects pull in via a dune stanza:

```dune
(library
 (name integers_stubs_js)
 (js_of_ocaml (javascript_files ./runtime.js)))
```

Projects then just add `(libraries integers_stubs_js)` to their
own `dune` and the stubs land automatically.

We mirror both halves:

- Built-in stubs (`Str` so far) live under `runtime-java/stubs/`,
  are compiled by our build, embedded as bytes into the compiler,
  and always written alongside `Main.class`.
- Out-of-tree stubs (this directory) aren't in the built-in set.
  Users pass one `--stub-manifest` flag per library they need.

Longer-term: if an OCaml project that depends on, say, `integers`
wants a clean `(libraries integers_stubs_java)` analog, they can
create a dune library with a `runtime.java` + `stubs.json` and a
dune rule that walks those to produce a manifest for
`java_of_ocaml`. That wrapper-library pattern doesn't require
anything beyond what the compiler already supports.

## Usage example — compiling a caller executable

A large test binary transitively depends on `integers` + `ctypes` (the latter via
a platform-specific ctypes-binding module's macOS `_NSGetExecutablePath` binding) + most of
`core_unix`. Enable all three manifests:

```
java_of_ocaml \
  --stub-manifest stubs-contrib/integers/stubs.json \
  --stub-manifest stubs-contrib/ctypes/stubs.json \
  --stub-manifest stubs-contrib/core_unix/stubs.json \
  target.bc -o out
java -Xss16m -cp out Main
```

Omitting a manifest means any primitive it would have provided
compiles to a runtime-throwing `UnsupportedOperationException`
stub — safe at class-load, fails at the first actual call.
