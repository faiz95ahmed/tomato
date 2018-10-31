(* 
lexer.mll
Faiz Ahmed
see: http://caml.inria.fr/pub/docs/manual-ocaml/lexyacc.html
*)
{

  open Parser

  let lineno = ref 1                      (* Current line in input file *)

  let keywords = [
    "begin", BEGIN; "end", END; "nfa", NFA; "npda", NPDA; "ndtm", NDTM; "state", STATE
    
  ]

  exception SyntaxError of string

  let syntaxError msg = raise (SyntaxError (msg ^ ", line: " ^ (string_of_int !lineno)))

}

let blank = [' ' '\r' '\t']
let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z']
let ident = (alpha | digit) (alpha | digit | '_')*

rule token = parse
    | ':'      { COLON }
    | ','      { COMMA }
    | ';'      { SEMICOLON }
    | '('      { LEFTPAREN }
    | ')'      { RIGHTPAREN }
    | ident as i {
        let l = String.lowercase i in
        try List.assoc l keywords
        with Not_found -> IDENT i   
    }
    | '\n'     { incr lineno; token lexbuf }
    | blank    { token lexbuf }
    | _        { syntaxError "bad token" }
    | eof      { EOF }

{

  (* empty trailer *)  
}