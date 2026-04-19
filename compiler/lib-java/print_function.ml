open Instr

module Int_set = Set.Make (Int)

let pc_upper_bound_after ~sorted_body_pcs pc =
  let n = Array.length sorted_body_pcs in
  let rec find i =
    if i >= n then max_int
    else if sorted_body_pcs.(i) > pc then sorted_body_pcs.(i)
    else find (i + 1)
  in
  find 0

(* Find the array index of the instruction at [pc], or raise if
   there is none. *)
let index_of_pc arr pc =
  let n = Array.length arr in
  let rec loop i =
    if i >= n
    then
      failwith
        (Printf.sprintf
           "print_function: no instruction at pc %d (array has %d entries)"
           pc
           n)
    else if arr.(i).pc = pc
    then i
    else loop (i + 1)
  in
  loop 0

let is_terminator_opcode op = Instr.is_terminator op

let format_int_set s =
  if Int_set.is_empty s
  then "{}"
  else
    "{"
    ^ String.concat
        ","
        (Int_set.elements s |> List.map string_of_int)
    ^ "}"

let print fmt arr ~sorted_body_pcs ~pc =
  let start_idx = index_of_pc arr pc in
  let upper = pc_upper_bound_after ~sorted_body_pcs pc in
  let n = Array.length arr in
  Format.fprintf
    fmt
    "[print-function] body pc=%d (idx=%d), pc_upper_bound=%s@."
    pc
    start_idx
    (if upper = max_int then "∞" else string_of_int upper);
  let outstanding = ref Int_set.empty in
  let last_terminator = ref (-1) in
  let stopped_reason = ref `Fell_off in
  let i = ref start_idx in
  (try
     while !i < n do
       let ins = arr.(!i) in
       if ins.pc >= upper
       then (
         stopped_reason := `Crossed_next_fn;
         raise Exit);
       (* Update outstanding set: remove this pc if it was a pending
          target, then add any new targets from this instruction. *)
       outstanding := Int_set.remove ins.pc !outstanding;
       List.iter
         (fun t ->
           if t <> ins.pc
           then outstanding := Int_set.add t !outstanding)
         (branch_targets ins);
       let is_term = is_terminator_opcode ins.opcode in
       if is_term then last_terminator := !i;
       let ends_here = is_term && Int_set.is_empty !outstanding in
       let targets = branch_targets ins in
       Format.fprintf
         fmt
         "  idx=%d pc=%d %-24s %s%s%s outstanding=%s@."
         !i
         ins.pc
         (Bytecode.opcode_name ins.opcode)
         (if Array.length ins.args = 0
          then ""
          else
            "args=["
            ^ String.concat
                ","
                (Array.to_list ins.args |> List.map string_of_int)
            ^ "] ")
         (if targets = []
          then ""
          else
            "targets=["
            ^ String.concat "," (List.map string_of_int targets)
            ^ "] ")
         (if is_term then "TERM " else "")
         (format_int_set !outstanding);
       if ends_here
       then (
         stopped_reason := `Natural_end;
         raise Exit);
       incr i
     done;
     stopped_reason := `EOF
   with Exit -> ());
  let reason =
    match !stopped_reason with
    | `Natural_end -> "terminator + empty outstanding"
    | `Crossed_next_fn ->
      Printf.sprintf
        "crossed next function at pc %d (fallback to last terminator)"
        upper
    | `EOF -> "end of instruction array"
    | `Fell_off -> "unreachable"
  in
  Format.fprintf
    fmt
    "[print-function] stopped: %s; last_terminator_idx=%d%s@."
    reason
    !last_terminator
    (if !last_terminator < start_idx
     then " (BEFORE body start — no terminator in range)"
     else "")
