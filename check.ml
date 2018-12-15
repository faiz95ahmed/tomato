(* check.ml *)
(* Faiz Ahmed *)

(* enforce a variety of constraints upon the nodes of the AST *)

open Str
open Tree

exception SemanticError of string

let semError s = raise (SemanticError (s (*^ ", line: " ^ (string_of_int !lineno)*)))

let num_states = ref 0

let env = (Hashtbl.create 100, ref [], ref None)
(* env is 3 mutable data structures, hence all functions are not pure, and have side effects *)
(* length of list maintained as List.length is an O(n) operation, and it would need to be called every time defineState is called *)

let full_match r s = 
  if string_match (regexp r) s 0 
  then match_end() == String.length s
  else false

let defineState (s1, (hsh, ls, start_state)) = 
  match s1 with
   NFAState s ->    (match Hashtbl.find_opt hsh s.name with
                      Some x -> semError (s.name ^ " already defined")
                    | None -> Hashtbl.add hsh s.name s1;
                              s.ident <- Some (!num_states);
                              ls := s.name::(!ls);
                              incr num_states)
 | NPDAState s ->   (match Hashtbl.find_opt hsh s.name with
                      Some x -> semError (s.name ^ " already defined")
                    | None -> Hashtbl.add hsh s.name s1;
                              s.ident <- Some (!num_states);
                              ls := s.name::(!ls);
                              incr num_states)
 | NDTMState s ->   (match Hashtbl.find_opt hsh s.name with
                      Some x -> semError (s.name ^ " already defined")
                    | None -> Hashtbl.add hsh s.name s1;
                              s.ident <- Some (!num_states);
                              ls := s.name::(!ls);
                              incr num_states)

let findState s (hsh, _, _) =
  match Hashtbl.find_opt hsh s with
    Some x -> x
  | None -> semError ("state "^ s ^ " undefined")           

let check_npda_next (next_state, stack_symbols) = 
  let x = findState next_state env in
  if not (full_match ".*" stack_symbols) then semError ("invalid stack_symbols: " ^ stack_symbols)

let check_ndtm_next (next_state, symbol_to_write, direction) =
  let x = findState next_state env in
  if not (full_match "." symbol_to_write) then semError ("invalid write symbol (must be one character in length): " ^ symbol_to_write);
  if not (full_match "[rlRL]" direction) then semError ("invalid direction (must be r, l, R, or L): " ^ direction)

let check_transition t =
  match t with 
     NFATransition x -> if full_match "." x.tapeSymbol then List.iter (function (s) -> ignore (findState s env)) x.nfa_nextStates
                        else semError ("invalid tape symbol (LHS of transition must be one character in length): " ^ x.tapeSymbol)
   | NPDATransition y -> if full_match "." y.tapeSymbol then 
                         (if full_match "." y.stackSymbol then
                          List.iter check_npda_next y.npda_nextStates
                          else semError ("invalid stack symbol (must be one character in length): " ^ y.stackSymbol))
                        else semError ("invalid tape symbol (LHS of transition must be one character in length): " ^ y.tapeSymbol)
   | NDTMTransition z -> if full_match "." z.tapeSymbol then List.iter check_ndtm_next z.ndtm_nextStates
                         else semError ("invalid tape symbol (LHS of transition must be one character in length): " ^ z.tapeSymbol)


let check_transitions s = match s with
                            NFAState x -> List.iter check_transition x.nfa_transitions
                          | NPDAState x -> List.iter check_transition x.npda_transitions
                          | NDTMState x -> List.iter check_transition x.ndtm_transitions
                          | _ -> semError "invalid"
  


let check_state s = match s with
    NFAState x -> if full_match "[a-z][a-zA-Z0-9]*" x.name then
                  defineState (s, env)
                  else semError ("invalid state name: " ^ x.name)
  | NPDAState x -> if full_match "[a-z][a-zA-Z0-9]*" x.name then
                   defineState (s, env)
                   else semError ("invalid state name: " ^ x.name)
  | NDTMState x -> if full_match "[a-z][a-zA-Z0-9]*" x.name then
                   defineState (s, env)
                   else semError ("invalid state name: " ^ x.name)
  | _ -> semError "invalid"

let check_program p = 
  match p with
    NFA (start_state, states) | NPDA (start_state, states) | NDTM (start_state, states) -> List.iter check_state states;
                                                                                           let s = findState start_state env in
                                                                                           let (_,_, startRef) = env in
                                                                                           (match s with 
                                                                                             NFAState x -> startRef := x.ident
                                                                                           | NPDAState x -> startRef := x.ident
                                                                                           | NDTMState x -> startRef := x.ident);
                                                                                           List.iter check_transitions states;
                                                                                           (p, env)
                                                                                  

                                                                                           
                                                                                           