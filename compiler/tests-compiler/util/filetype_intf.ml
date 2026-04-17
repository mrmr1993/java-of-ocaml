module type S = sig
  type ocaml_text

  type ocaml_file

  type cmo_file

  type bc_file

  type class_file

  type jar_file

  val read_file : string -> string

  val write_file : string -> string -> unit

  val read_ocaml : ocaml_file -> ocaml_text

  val write_ocaml : name:string -> ocaml_text -> ocaml_file

  val ocaml_text_of_string : string -> ocaml_text

  val string_of_ocaml_text : ocaml_text -> string

  val path_of_ocaml_file : ocaml_file -> string

  val path_of_cmo_file : cmo_file -> string

  val path_of_bc_file : bc_file -> string

  val path_of_class_file : class_file -> string

  val path_of_jar_file : jar_file -> string

  val ocaml_file_of_path : string -> ocaml_file

  val cmo_file_of_path : string -> cmo_file

  val bc_file_of_path : string -> bc_file

  val class_file_of_path : string -> class_file

  val jar_file_of_path : string -> jar_file
end
