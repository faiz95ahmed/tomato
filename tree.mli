(* tree.mli *)
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
val make_nfa_state : string * transition list * bool -> nfa_state

(* |make_nfa_transition| -- construct an NFA transition node *)
val make_nfa_transition : string * string list -> nfa_transition

(* |make_npda_state| -- construct an NPDA state node with dummy ident *)
val make_npda_state : string * transition list * bool -> npda_state

(* |make_npda_transition| -- construct an NPDA transition node *)
val make_npda_transition : string * string * string list -> npda_transition

(* |make_ndtm_state| -- construct an NDTM state node with dummy ident *)
val make_ndtm_state : string * transition list * bool -> ndtm_state

(* |make_ndtm_transition| -- construct an NDTM transition node *)
val make_ndtm_transition : string * string list -> ndtm_transition
