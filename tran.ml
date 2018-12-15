(* tran.ml *)
(* Faiz Ahmed *)

(* translate annotated AST into a machine module *)
open Check
open Tree

exception TranslationError of string

let tranError s = raise (TranslationError s)

(* code generation *)
let chan = ref stdout
(* let vars = ref (Hashtbl.create 100) *)

let set_chan new_chan = chan := new_chan

let gen v = output_string !chan v; output_string !chan "\n"

let gen_header () = gen "package machine\n"

let nfa_header () = gen 
"type NFA struct {
  Q0 int
  FinalStates []bool
  StateNames []string
  Transitions []map[rune][]int
}"

let npda_header () = gen 
"type NPDANext struct {
  NextState int
  StackSymbol rune
}
type NPDA struct {
  Q0 int
  FinalStates []bool
  StateNames []string
  Transitions []map[uint64][]NPDANext
}"

let ndtm_header () = gen 
"type NDTMNext struct {
  NextState int
  WriteSymbol rune
  MoveRight bool
}
type NDTM struct {
  Q0 int
  FinalStates []bool
  StateNames []string
  Transitions []map[rune][]NDTMNext
}"

let gen_final_states_helper state =  match state with
                                       NFAState s -> string_of_bool s.is_accepting
                                     | NPDAState s -> string_of_bool s.is_accepting
                                     | NDTMState s -> string_of_bool s.is_accepting

let gen_final_states states (_, ls, _) = let str = List.fold_left (fun e s -> e ^ ", " ^ gen_final_states_helper s) "" states in
                                         gen (Printf.sprintf "  finalStatesSlice := []bool{%s}" (String.sub str 2 ((String.length str) - 2)))

let get_state_name state =  match state with
                              NFAState s -> s.name
                            | NPDAState s -> s.name
                            | NDTMState s -> s.name                                                  

let get_state_ident state = match state with
                              NFAState s -> (match s.ident with Some x -> x | None -> tranError "no state identity")
                            | NPDAState s -> (match s.ident with Some x -> x | None -> tranError "no state identity")
                            | NDTMState s -> (match s.ident with Some x -> x | None -> tranError "no state identity")

let str_to_ident str hsh = match Hashtbl.find_opt hsh str with
                            Some s -> get_state_ident s
                          | None -> tranError "invalid state name"

let gen_state_names states (_, ls, _) = let str = List.fold_left (fun e s -> e ^ ", " ^ "\"" ^ get_state_name s ^ "\"") "" states in
                                        gen (Printf.sprintf "  stateNamesSlice := []string{%s}" (String.sub str 2 ((String.length str) - 2)))
                                        
let get_transitions state = match state with
                              NFAState s -> s.nfa_transitions
                            | NPDAState s -> s.npda_transitions
                            | NDTMState s -> s.ndtm_transitions

let gen_nfa_transition tr n hsh = match tr with
                                  NFATransition t -> let str = List.fold_left (fun e s -> e ^ ", " ^ (string_of_int (str_to_ident s hsh))) "" t.nfa_nextStates in
                                                     gen (Printf.sprintf "  transitions%d%s := []int{%s}" n t.tapeSymbol (String.sub str 2 ((String.length str) - 2)));
                                                     gen (Printf.sprintf "  transitionsArray[%d]['%s'] = transitions%d%s" n t.tapeSymbol n t.tapeSymbol)
                                 | _ -> tranError "invalid transition type"

let gen_nfa_state (hsh, _, _) state = let trans = get_transitions state in
                                      let n = (get_state_ident state) in
                                      gen (Printf.sprintf "  transitionsArray[%d] = make(map[rune][]int)" n);
                                      List.iter (fun tr -> gen_nfa_transition tr n hsh) (get_transitions state)

let gen_nfa states (hsh, ls, start_state) = gen "func GetMachine() *NFA {";
                                            gen ("  startState := " ^ (string_of_int (match !start_state with Some c -> c)));
                                            gen_final_states states env;
                                            gen_state_names states env;
                                            gen (Printf.sprintf "  var transitionsArray [%d]map[rune][]int" (List.length !ls));
                                            List.iter (gen_nfa_state env) states;
                                            gen "  runnable := new(NFA)";
                                            gen "  runnable.Q0 = startState";
                                            gen "  runnable.FinalStates = finalStatesSlice";
                                            gen "  runnable.StateNames = stateNamesSlice";
                                            gen (Printf.sprintf "  runnable.Transitions = transitionsArray[0:%d]" (List.length !ls));
                                            gen "  return runnable";
                                            gen "}"

let gen_npda states (hsh, ls, start_state) = gen ""
                                             
let gen_ndtm states (hsh, ls, start_state) = gen ""

let tran (p, env) = 
        match p with
              NFA (_, states) -> gen_header(); nfa_header(); gen_nfa states env
            | NPDA (_, states) -> gen_header(); npda_header(); gen_npda states env
            | NDTM (_, states) -> gen_header(); ndtm_header(); gen_ndtm states env
            | _ -> tranError "expected tree" 

          
