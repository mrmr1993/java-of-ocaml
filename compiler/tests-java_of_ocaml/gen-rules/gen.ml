(* Emit per-test dune stanzas for every [<name>.ml] that has a matching
   [<name>.expected]. Each test is compiled to bytecode with [ocamlc],
   handed to [java_of_ocaml] to produce a [<name>-java/] directory of
   JVM classes, then run with [java -cp <name>-java Main]. The captured
   stdout is diffed against [<name>.expected] under the [runtest] alias.

   Run via the top-level [dune] rule:

     (rule
      (deps (glob_files *.ml))
      (action (with-stdout-to dune.inc.gen (run gen-rules/gen.exe))))

   with a [(diff dune.inc dune.inc.gen)] check under [runtest] so a
   newly-added [<name>.{ml,expected}] pair is detected as a test diff
   at the next [dune runtest], and accepted via [dune promote]. *)

let is_identifier s =
  String.length s > 0
  && String.for_all
       (function
         | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' -> true
         | _ -> false)
       s

let () = set_binary_mode_out stdout true

let () =
  let files = Sys.readdir "." in
  Array.sort compare files;
  Array.iter
    (fun f ->
      if Filename.extension f = ".ml"
      then (
        let base = Filename.chop_extension f in
        if is_identifier base && Sys.file_exists (base ^ ".expected")
        then
          (* Collapse the java_of_ocaml compile + java run into one rule:
             dune directory-target deps are awkward to plumb through to
             a downstream [(chdir ...)] consumer (the dir isn't re-hydrated
             in the second rule's sandbox). Doing both in one action also
             mirrors how [js_of_ocaml]'s test rules shape up — compile to
             .js and run with node in a single pipeline. *)
          Printf.printf
            {|
; %s.ml — auto-generated rules
(rule
 (target %s.bc)
 (deps %s.ml)
 (action (run ocamlc -no-check-prims -g %%{deps} -o %%{target})))

(rule
 (target %s.byte.output)
 (deps %s.bc)
 (action (with-stdout-to %%{target} (run ocamlrun %%{deps}))))

(rule
 (alias runtest)
 (action (diff %s.expected %s.byte.output)))

(rule
 (target %s.java.output)
 (deps %s.bc)
 (action
  (progn
   (bash "rm -rf %s-java && mkdir %s-java")
   (run %%{bin:java_of_ocaml} %%{deps} -o %s-java)
   (with-stdout-to %%{target}
    (chdir %s-java (run java -cp . Main))))))

(rule
 (alias runtest)
 (action (diff %s.expected %s.java.output)))
|}
            base base base base base base base base base base base base base base base))
    files
