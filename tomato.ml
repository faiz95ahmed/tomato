(* tomato.ml *)
(* Faiz Ahmed *)

let compile f = 
  let out_chan = open_out ("machine/machine.go")
  and lexbuf = Lexing.from_channel (open_in f) in
  try
      let parse () = Parser.program Lexer.token lexbuf in
      let checked = Check.check_program (parse ()) in
      Tran.set_chan out_chan;
      Tran.tran (checked);
      close_out out_chan;
  with 
  | Tran.TranslationError s ->
      print_string s;
      print_string "\n";
      exit 1
  | Lexer.SyntaxError s ->
      print_string s;
      print_string "\n";
      exit 1
  | Check.SemanticError s ->
      print_string s;
      print_string "\n";
      exit 1

let help () = print_string "tcc <file>\n"

let () = if Array.length Sys.argv = 1 then help ()
   else 
       let file = Array.get Sys.argv 1 in
       Format.printf "compiling %s\n" file;
       Format.print_flush ();
       compile file