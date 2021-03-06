(* tree.ml *)
(* Faiz Ahmed *)

(* abstract syntax *)
type machine = 
    NFA of string * state list
  | NPDA of string * state list
  | NDTM of string * state list

and state = 
    NFAState of nfa_state
  | NPDAState of npda_state
  | NDTMState of ndtm_state

and nfa_state = {
  name: string;
  mutable ident: int option;
  is_accepting: bool;
  nfa_transitions: transition list
}

and npda_state = {
  name: string;
  mutable ident: int option;
  is_accepting: bool;
  npda_transitions: transition list
} 

and ndtm_state = {
  name: string;
  mutable ident: int option;
  is_accepting: bool;
  ndtm_transitions: transition list
} 

and transition = 
    NFATransition of nfa_transition
  | NPDATransition of npda_transition
  | NDTMTransition of ndtm_transition

and nfa_transition = {
  tapeSymbol: string;
  nfa_nextStates: string list
}

and npda_transition = {
  tapeSymbol: string;
  stackSymbol: string;
  npda_nextStates: (string * string) list
} 

and ndtm_transition = {
  tapeSymbol: string;
  ndtm_nextStates: (string * string * string) list
}

(* |make_nfa_state| -- construct an NFA state node with dummy ident *)
let make_nfa_state (s, ts, accept) = { name = s; ident = None; is_accepting = accept; nfa_transitions = ts }

(* |make_nfa_transition| -- construct an NFA transition node *)
let make_nfa_transition (s, ns) = { tapeSymbol = s; nfa_nextStates = ns }

(* |make_npda_state| -- construct an NPDA state node with dummy ident *)
let make_npda_state (s, ts, accept) = { name = s; ident = None; is_accepting = accept; npda_transitions = ts }

(* |make_npda_transition| -- construct an NPDA transition node *)
let make_npda_transition (s1, s2, ns) = { tapeSymbol = s1; stackSymbol = s2; npda_nextStates = ns }

(* |make_ndtm_state| -- construct an NDTM state node with dummy ident *)
let make_ndtm_state (s, ts, accept) = { name = s; ident = None; is_accepting = accept; ndtm_transitions = ts }

(* |make_ndtm_transition| -- construct an NDTM transition node *)
let make_ndtm_transition (s, ns) = { tapeSymbol = s; ndtm_nextStates = ns }
