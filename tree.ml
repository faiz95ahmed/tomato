(* tree.ml *)
(* Faiz Ahmed *)

(* abstract syntax *)
type machine = 
    NFA of NFAState list
  | NPDA of NPDAState list
  | NDTM of NDTMState list

and NFAState = {
  name: string;
  transitions: NFATransition list
}

and NPDAState = {
  name: string;
  transitions: NPDATransition list
} 

and NDTMState = {
  name: string;
  transitions: NDTMTransition list
} 

and NFATransition = {
  tapeSymbol: string;
  nextStates: string list
}

and NPDATransition = {
  tapeSymbol: string;
  stackSymbol: string;
  nextStates: (string * string) list
} 

and NDTMTransition = {
  symbol: string;
  nextstates: (string * string * string) list
} 