type t =
  { code : int array
  ; prims : string array
  ; globals : Obj.t array
  }

module Op = struct
  let acc0 = 0
  let acc1 = 1
  let acc2 = 2
  let acc3 = 3
  let acc4 = 4
  let acc5 = 5
  let acc6 = 6
  let acc7 = 7
  let acc = 8
  let push = 9
  let push_retaddr = 31
  let assign = 20
  let pushacc0 = 10
  let pushacc1 = 11
  let pushacc2 = 12
  let pushacc3 = 13
  let pushacc4 = 14
  let pushacc5 = 15
  let pushacc6 = 16
  let pushacc7 = 17
  let pushacc = 18
  let pop = 19
  let getglobal = 53
  let pushgetglobal = 54
  let c_call1 = 93
  let const0 = 99
  let const1 = 100
  let const2 = 101
  let const3 = 102
  let constint = 103
  let pushconst0 = 104
  let pushconst1 = 105
  let pushconst2 = 106
  let pushconst3 = 107
  let pushconstint = 108
  let addint = 110
  let subint = 111
  let mulint = 112
  let divint = 113
  let modint = 114
  let eq = 121
  let neq = 122
  let ltint = 123
  let leint = 124
  let gtint = 125
  let geint = 126
  let offsetint = 127
  let offsetref = 128
  let makeblock = 62
  let makeblock1 = 63
  let makeblock2 = 64
  let makeblock3 = 65
  let getfield0 = 67
  let getfield1 = 68
  let getfield2 = 69
  let getfield3 = 70
  let getfield = 71
  let setfield0 = 73
  let setfield1 = 74
  let setfield2 = 75
  let setfield3 = 76
  let setfield = 77
  let vectlength = 79
  let branch = 84
  let branchif = 85
  let branchifnot = 86
  let switch = 87
  let boolnot = 88
  let pushtrap = 89
  let poptrap = 90
  let raise_ = 91
  let isint = 129
  let reraise = 146
  let raise_notrace = 147
  let stop = 143
  let apply = 32
  let apply1 = 33
  let apply2 = 34
  let apply3 = 35
  let appterm = 36
  let appterm1 = 37
  let appterm2 = 38
  let appterm3 = 39
  let return = 40
  let restart = 41
  let grab = 42
  let closure = 43
  let closurerec = 44
  let offsetclosurem3 = 45
  let offsetclosure0 = 46
  let offsetclosure3 = 47
  let offsetclosure = 48
  let pushoffsetclosurem3 = 49
  let pushoffsetclosure0 = 50
  let pushoffsetclosure3 = 51
  let pushoffsetclosure = 52
  let envacc1 = 21
  let envacc2 = 22
  let envacc3 = 23
  let envacc4 = 24
  let envacc = 25
  let pushenvacc1 = 26
  let pushenvacc2 = 27
  let pushenvacc3 = 28
  let pushenvacc4 = 29
  let pushenvacc = 30
  let event = 144
  let break = 145
end

(* Classification of opcodes following js_of_ocaml's [Instr.kind]. What we
   need is the in-code size of each instruction: opcode word + N argument
   words. Most ops have a fixed size; [Switch] and [Closurerec] are
   variable-length (size depends on the args themselves). *)

type kind =
  | Nullary         (* 1 word: opcode only *)
  | Unary           (* 2 words: opcode + 1 arg *)
  | Binary          (* 3 words: opcode + 2 args *)
  | Jump            (* 2 words *)
  | Cond_jump       (* 2 words *)
  | Cmp_jump        (* 3 words *)
  | Switch          (* variable: 2 + (low16(arg) + high16(arg)) *)
  | Closure         (* 3 words *)
  | Closurerec      (* variable: 3 + arg1 *)
  | Nullary_call    (* 1 word *)
  | Unary_call      (* 2 words *)
  | Binary_call     (* 3 words *)
  | Stop_n of int   (* 1 + n words *)

(* Opcode metadata table. Indexed by opcode number (0-143). Must stay in sync
   with ocaml/runtime/caml/opcodes.h. Length 144. *)
let opcodes =
  [| "ACC0", Nullary
   ; "ACC1", Nullary
   ; "ACC2", Nullary
   ; "ACC3", Nullary
   ; "ACC4", Nullary
   ; "ACC5", Nullary
   ; "ACC6", Nullary
   ; "ACC7", Nullary
   ; "ACC", Unary
   ; "PUSH", Nullary
   ; "PUSHACC0", Nullary
   ; "PUSHACC1", Nullary
   ; "PUSHACC2", Nullary
   ; "PUSHACC3", Nullary
   ; "PUSHACC4", Nullary
   ; "PUSHACC5", Nullary
   ; "PUSHACC6", Nullary
   ; "PUSHACC7", Nullary
   ; "PUSHACC", Unary
   ; "POP", Unary
   ; "ASSIGN", Unary
   ; "ENVACC1", Nullary
   ; "ENVACC2", Nullary
   ; "ENVACC3", Nullary
   ; "ENVACC4", Nullary
   ; "ENVACC", Unary
   ; "PUSHENVACC1", Nullary
   ; "PUSHENVACC2", Nullary
   ; "PUSHENVACC3", Nullary
   ; "PUSHENVACC4", Nullary
   ; "PUSHENVACC", Unary
   ; "PUSH_RETADDR", Unary
   ; "APPLY", Unary_call
   ; "APPLY1", Nullary_call
   ; "APPLY2", Nullary_call
   ; "APPLY3", Nullary_call
   ; "APPTERM", Stop_n 2
   ; "APPTERM1", Stop_n 1
   ; "APPTERM2", Stop_n 1
   ; "APPTERM3", Stop_n 1
   ; "RETURN", Stop_n 1
   ; "RESTART", Nullary
   ; "GRAB", Unary
   ; "CLOSURE", Closure
   ; "CLOSUREREC", Closurerec
   ; "OFFSETCLOSUREM3", Nullary
   ; "OFFSETCLOSURE0", Nullary
   ; "OFFSETCLOSURE3", Nullary
   ; "OFFSETCLOSURE", Unary
   ; "PUSHOFFSETCLOSUREM3", Nullary
   ; "PUSHOFFSETCLOSURE0", Nullary
   ; "PUSHOFFSETCLOSURE3", Nullary
   ; "PUSHOFFSETCLOSURE", Unary
   ; "GETGLOBAL", Unary
   ; "PUSHGETGLOBAL", Unary
   ; "GETGLOBALFIELD", Binary
   ; "PUSHGETGLOBALFIELD", Binary
   ; "SETGLOBAL", Unary
   ; "ATOM0", Nullary
   ; "ATOM", Unary
   ; "PUSHATOM0", Nullary
   ; "PUSHATOM", Unary
   ; "MAKEBLOCK", Binary
   ; "MAKEBLOCK1", Unary
   ; "MAKEBLOCK2", Unary
   ; "MAKEBLOCK3", Unary
   ; "MAKEFLOATBLOCK", Unary
   ; "GETFIELD0", Nullary
   ; "GETFIELD1", Nullary
   ; "GETFIELD2", Nullary
   ; "GETFIELD3", Nullary
   ; "GETFIELD", Unary
   ; "GETFLOATFIELD", Unary
   ; "SETFIELD0", Nullary
   ; "SETFIELD1", Nullary
   ; "SETFIELD2", Nullary
   ; "SETFIELD3", Nullary
   ; "SETFIELD", Unary
   ; "SETFLOATFIELD", Unary
   ; "VECTLENGTH", Nullary
   ; "GETVECTITEM", Nullary
   ; "SETVECTITEM", Nullary
   ; "GETBYTESCHAR", Nullary
   ; "SETBYTESCHAR", Nullary
   ; "BRANCH", Jump
   ; "BRANCHIF", Cond_jump
   ; "BRANCHIFNOT", Cond_jump
   ; "SWITCH", Switch
   ; "BOOLNOT", Nullary
   ; "PUSHTRAP", Cond_jump
   ; "POPTRAP", Nullary
   ; "RAISE", Stop_n 0
   ; "CHECK_SIGNALS", Nullary
   ; "C_CALL1", Unary_call
   ; "C_CALL2", Unary_call
   ; "C_CALL3", Unary_call
   ; "C_CALL4", Unary_call
   ; "C_CALL5", Unary_call
   ; "C_CALLN", Binary_call
   ; "CONST0", Nullary
   ; "CONST1", Nullary
   ; "CONST2", Nullary
   ; "CONST3", Nullary
   ; "CONSTINT", Unary
   ; "PUSHCONST0", Nullary
   ; "PUSHCONST1", Nullary
   ; "PUSHCONST2", Nullary
   ; "PUSHCONST3", Nullary
   ; "PUSHCONSTINT", Unary
   ; "NEGINT", Nullary
   ; "ADDINT", Nullary
   ; "SUBINT", Nullary
   ; "MULINT", Nullary
   ; "DIVINT", Nullary
   ; "MODINT", Nullary
   ; "ANDINT", Nullary
   ; "ORINT", Nullary
   ; "XORINT", Nullary
   ; "LSLINT", Nullary
   ; "LSRINT", Nullary
   ; "ASRINT", Nullary
   ; "EQ", Nullary
   ; "NEQ", Nullary
   ; "LTINT", Nullary
   ; "LEINT", Nullary
   ; "GTINT", Nullary
   ; "GEINT", Nullary
   ; "OFFSETINT", Unary
   ; "OFFSETREF", Unary
   ; "ISINT", Nullary
   ; "GETMETHOD", Nullary
   ; "BEQ", Cmp_jump
   ; "BNEQ", Cmp_jump
   ; "BLTINT", Cmp_jump
   ; "BLEINT", Cmp_jump
   ; "BGTINT", Cmp_jump
   ; "BGEINT", Cmp_jump
   ; "ULTINT", Nullary
   ; "UGEINT", Nullary
   ; "BULTINT", Cmp_jump
   ; "BUGEINT", Cmp_jump
   ; "GETPUBMET", Binary
   ; "GETDYNMET", Nullary
   ; "STOP", Stop_n 0
   ; "EVENT", Nullary
   ; "BREAK", Nullary
   ; "RERAISE", Stop_n 0
   ; "RAISE_NOTRACE", Stop_n 0
   ; "GETSTRINGCHAR", Nullary
   ; "PERFORM", Nullary_call
   ; "RESUME", Nullary_call
   ; "RESUMETERM", Stop_n 1
   ; "REPERFORMTERM", Stop_n 1
  |]

let opcode_name op =
  if op < 0 || op >= Array.length opcodes
  then Printf.sprintf "<opcode %d>" op
  else fst opcodes.(op)

let instr_size t pc =
  let op = t.code.(pc) in
  if op < 0 || op >= Array.length opcodes
  then
    failwith (Printf.sprintf "bytecode: unknown opcode %d at pc %d" op pc);
  match snd opcodes.(op) with
  | Nullary | Nullary_call -> 1
  | Unary | Unary_call | Jump | Cond_jump -> 2
  | Binary | Binary_call | Cmp_jump | Closure -> 3
  | Stop_n n -> n + 1
  | Switch ->
    let sz = t.code.(pc + 1) in
    2 + (sz land 0xffff) + ((sz lsr 16) land 0xffff)
  | Closurerec ->
    let nfuncs = t.code.(pc + 1) in
    3 + nfuncs

(* OCaml bumps the trailer magic on every bytecode-format change. We accept
   any "Caml1999X..." magic: the layout described below is stable across the
   bumps we care about (4.x through 5.3+); incompatible layout changes would
   anyway manifest as decoding failures further down. *)
let magic_prefix = "Caml1999X"

let read_exe path =
  let ic = open_in_bin path in
  let total = in_channel_length ic in
  (* Trailer layout (last 16 bytes): [num_sections:u32 BE][magic:12 bytes].
     Before that: num_sections entries of [name:4][len:u32 BE].
     Sections themselves come before the TOC, in file order, starting after
     any optional shebang line. *)
  seek_in ic (total - 16);
  let num_sections = input_binary_int ic in
  let read_magic = really_input_string ic 12 in
  if not (String.length read_magic = 12
          && String.sub read_magic 0 (String.length magic_prefix)
             = magic_prefix)
  then failwith (Printf.sprintf "bytecode: bad magic %S" read_magic);
  let toc_pos = total - 16 - (8 * num_sections) in
  seek_in ic toc_pos;
  let toc =
    Array.init num_sections (fun _ ->
      let name = really_input_string ic 4 in
      let len = input_binary_int ic in
      name, len)
  in
  let total_section_len = Array.fold_left (fun acc (_, l) -> acc + l) 0 toc in
  let first_pos = toc_pos - total_section_len in
  let offsets =
    let p = ref first_pos in
    Array.map
      (fun (name, len) ->
        let off = !p in
        p := !p + len;
        name, off, len)
      toc
  in
  let find_section name =
    let result = ref None in
    Array.iter
      (fun (n, off, len) -> if n = name then result := Some (off, len))
      offsets;
    !result
  in
  let code =
    match find_section "CODE" with
    | None -> failwith "bytecode: missing CODE section"
    | Some (off, len) ->
      if len mod 4 <> 0
      then failwith "bytecode: CODE section length not a multiple of 4";
      seek_in ic off;
      let n = len / 4 in
      let buf = Bytes.create len in
      really_input ic buf 0 len;
      Array.init n (fun i ->
        Int32.to_int (Bytes.get_int32_le buf (i * 4)))
  in
  let prims =
    match find_section "PRIM" with
    | None -> [||]
    | Some (off, len) ->
      seek_in ic off;
      let raw = really_input_string ic len in
      let parts = String.split_on_char '\000' raw in
      let parts =
        match List.rev parts with
        | "" :: rest -> List.rev rest
        | _ -> parts
      in
      Array.of_list parts
  in
  let globals =
    match find_section "DATA" with
    | None -> [||]
    | Some (off, _len) ->
      seek_in ic off;
      (Marshal.from_channel ic : Obj.t array)
  in
  close_in ic;
  { code; prims; globals }

let prim_index t name =
  let n = Array.length t.prims in
  let rec loop i =
    if i >= n then None
    else if t.prims.(i) = name then Some i
    else loop (i + 1)
  in
  loop 0
