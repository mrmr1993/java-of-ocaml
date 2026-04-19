# Building on OCaml 4.14.2 for a large test binary

The default build uses the local switch at `./_opam` (OCaml 5.3). That
path keeps the full test suite green and is what everyday development
runs against.

When we need to read bytecode from an OCaml 4.14 producer — today, the
[a large test binary](https://github.com/a test project/a large test binary) client — we build the
compiler on a **second, named global switch** pinned to 4.14.2. Because
4.14 and 5.x changed the `Cmo_format` layout incompatibly (see
[`compiler/lib-java/bytecode_compat.mli`](../compiler/lib-java/bytecode_compat.mli)),
the compiler linked to one major version cannot unmarshal `.cmo` / `.cma`
files produced by the other — the on-disk records carry the writer's
record shape, and `Marshal.from_channel` reads them back into the
running compiler's own type definition. Mismatched layouts silently
misalign fields.

## Switch bootstrap (one-time)

```bash
# Create a fresh global switch and install our dependencies into it.
# --no-switch keeps your current shell on the 5.3 switch.
opam switch create java_of_ocaml_414 ocaml-base-compiler.4.14.2 --no-switch
opam install --switch=java_of_ocaml_414 -y dune cmdliner
```

`ppxlib` / `ppx_expect` are deliberately omitted here — the 4.14 build
targets the compiler binary and the runtime classes. The expect-test
suite under `compiler/tests-compiler/` stays on the 5.3 switch.

## Building + running on 4.14

```bash
eval $(opam env --switch=java_of_ocaml_414 --set-switch)
dune build --build-dir=_build_414 compiler/bin-java_of_ocaml
_build_414/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe --help
```

`--build-dir=_build_414` keeps the 4.14 build outputs out of the
default `_build/` tree so the two switches don't step on each other.
`_build_*/` is gitignored.

Switching back to 5.3 is `eval $(opam env --switch=. --set-switch)`
(the local switch is referred to by its directory path).

## Where the compat shim sits

- `compiler/lib-java/bytecode_compat.mli` — the normalised interface.
- `compiler/lib-java/bytecode_compat_4.ml` — 4.14 impl; classifies
  `Reloc_getglobal of Ident.t` as compunit vs predef via
  `Ident.is_predef`; maps `cu_required_globals` through `Ident.name`.
- `compiler/lib-java/bytecode_compat_5.ml` — 5.x passthrough.
- `compiler/lib-java/dune` — `(rule (enabled_if (< %{ocaml_version}
  "5")) (copy# bytecode_compat_4.ml bytecode_compat.ml))` and its 5.x
  twin pick the right file at build time.

Adding a new compat point means: add an entry to `bytecode_compat.mli`,
implement it in both `_4.ml` and `_5.ml`, reference via `Bytecode_compat.*`.

## Smoke-testing against a large test binary artefacts

typical `_build/default/` contains per-library `.cmo` files (under
`.<name>.objs/byte/`) and `.cma` archives. A quick sanity check
the reader digests them cleanly:

```bash
_build_414/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe \
  --list-missing-prims \
  ../a large test binary/_build/default/src/lib/some_library/some_library.cma
```

A successful run prints whatever a large test binary-specific C primitives still need
JVM-side implementations (e.g. `some_native_primitive`, `ml_z_to_bits`).
A failed run would mean the shim is missing a field — treat that as a
format-compat bug, not a primitive-coverage bug.

Full end-to-end (compile to classes, no execution yet — primitives
typically still missing):

```bash
mkdir -p /tmp/a large test binary-out
_build_414/default/compiler/bin-java_of_ocaml/java_of_ocaml.exe \
  ../a large test binary/_build/default/src/lib/.../some_module.cmo \
  -o /tmp/a large test binary-out
ls /tmp/a large test binary-out   # Main.class + runtime classes
```
