/* parser.mly */
/* Faiz Ahmed */

%{

open Tree

%}

%token <string> IDENT

/* keywords */

%token BEGIN END EOF
%token NFA NPDA NDTM
%token STATE START FINAL

/* punctuation */

%token LPAR RPAR
%token COLON COMMA SEMICOLON


%type <Tree.machine> program
%start program


%%

/* general machine grammar */

program:
    NFA START IDENT BEGIN nfaStateList END              { NFA ($3, $5) }
  | NPDA START IDENT BEGIN npdaStateList END            { NPDA ($3, $5) }
  | NDTM START IDENT BEGIN ndtmStateList END            { NDTM ($3, $5)} ;


/***********************/
/***** NFA grammar *****/
/***********************/

nfaStateList:
    nfaState                                { [$1] }
  | nfaState nfaStateList                   { $1 :: $2 } ;

nfaState:
    STATE IDENT BEGIN nfaTransitions END    { NFAState (make_nfa_state ($2, $4, false)) }
  | FINAL IDENT BEGIN nfaTransitions END    { NFAState (make_nfa_state ($2, $4, true)) } ;

nfaTransitions:
    nfaTransition                           { [$1] }
  | nfaTransition nfaTransitions            { $1 :: $2 } ;

nfaTransition:
    IDENT COLON nfaNextStates               { NFATransition (make_nfa_transition ($1, $3)) } ;

nfaNextStates:
    nfaNextState                            { [$1] }
  | nfaNextState COMMA nfaNextStates        { $1 :: $3 } ;

nfaNextState:
    IDENT                                   { $1 } ;


/************************/
/***** NPDA grammar *****/
/************************/

npdaStateList:
    npdaState                               { [$1] }
  | npdaState npdaStateList                 { $1 :: $2 } ;

npdaState:
    STATE IDENT BEGIN npdaTransitions END    { NPDAState (make_npda_state ($2, $4, false)) }
  | FINAL IDENT BEGIN npdaTransitions END    { NPDAState (make_npda_state ($2, $4, true)) } ;

npdaTransitions:
    npdaTransition                          { [$1] }
  | npdaTransition npdaTransitions          { $1 :: $2 } ;

npdaTransition:
    LPAR IDENT COMMA IDENT RPAR COLON npdaNextStates
                                            { NPDATransition (make_npda_transition ($2, $4, $7)) } ;

npdaNextStates:
    npdaNextState                           { [$1] }
  | npdaNextState COMMA npdaNextStates      { $1 :: $3 } ;

npdaNextState:
    LPAR IDENT COMMA IDENT RPAR             { ($2, $4) } ;


/************************/
/***** NDTM grammar *****/
/************************/

ndtmStateList:
    ndtmState                               { [$1] }
  | ndtmState ndtmStateList                 { $1 :: $2 } ;

ndtmState:
    STATE IDENT BEGIN ndtmTransitions END    { NDTMState (make_ndtm_state ($2, $4, false)) }
  | FINAL IDENT BEGIN ndtmTransitions END    { NDTMState (make_ndtm_state ($2, $4, true)) } ;

ndtmTransitions:
    ndtmTransition                          { [$1] }
  | ndtmTransition ndtmTransitions          { $1 :: $2 } ;

ndtmTransition:
    IDENT COLON ndtmNextStates              { NDTMTransition (make_ndtm_transition ($1, $3)) } ;

ndtmNextStates:
    ndtmNextState                           { [$1] }
  | ndtmNextState COMMA ndtmNextStates      { $1 :: $3 } ;

ndtmNextState:
    LPAR IDENT COMMA IDENT COMMA IDENT RPAR { ($2, $4, $6) } ;



