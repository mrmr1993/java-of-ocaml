
; arith.ml — auto-generated rules
(rule
 (target arith.bc)
 (deps arith.ml)
 (action (run ocamlc -no-check-prims -g %{deps} -o %{target})))

(rule
 (target arith.byte.output)
 (deps arith.bc)
 (action (with-stdout-to %{target} (run ocamlrun %{deps}))))

(rule
 (alias runtest)
 (action (diff arith.expected arith.byte.output)))

(rule
 (target arith.java.output)
 (deps arith.bc)
 (action
  (progn
   (bash "rm -rf arith-java && mkdir arith-java")
   (run %{bin:java_of_ocaml} %{deps} -o arith-java)
   (with-stdout-to %{target}
    (chdir arith-java (run java -cp . Main))))))

(rule
 (alias runtest)
 (action (diff arith.expected arith.java.output)))

; hello.ml — auto-generated rules
(rule
 (target hello.bc)
 (deps hello.ml)
 (action (run ocamlc -no-check-prims -g %{deps} -o %{target})))

(rule
 (target hello.byte.output)
 (deps hello.bc)
 (action (with-stdout-to %{target} (run ocamlrun %{deps}))))

(rule
 (alias runtest)
 (action (diff hello.expected hello.byte.output)))

(rule
 (target hello.java.output)
 (deps hello.bc)
 (action
  (progn
   (bash "rm -rf hello-java && mkdir hello-java")
   (run %{bin:java_of_ocaml} %{deps} -o hello-java)
   (with-stdout-to %{target}
    (chdir hello-java (run java -cp . Main))))))

(rule
 (alias runtest)
 (action (diff hello.expected hello.java.output)))
