/* parser.mly */
/* Faiz Ahmed */

%{

open Tree

%}

%token <string> IDENT

/* keywords */

%token BEGIN END EOF
%token NFA NPDA NDTM
%token STATE

/* punctuation */

%token LEFTPAREN RIGHTPAREN
%token COLON COMMA SEMICOLON


%type <Tree.machine> program
%start program


%%

/* general machine grammar */

program:
    NFA BEGIN nfaStateList END              { NFA $3 }
  | NPDA BEGIN npdaStateList END            { NPDA $3 }
  | NDTM BEGIN ndtmStateList END            { NDTM $3} ;


/***********************/
/***** NFA grammar *****/
/***********************/

nfaStateList:
    nfaState                                { [$1] }
  | nfaState nfaStateList                   { $1 :: $2 } ;

nfaState:
    STATE IDENT BEGIN nfaTransitions END    { NFAState ($2, $4)} ;

nfaTransitions:
    nfaTransition                           { [$1] }
  | nfaTransition nfaTransitions            { $1 :: $2 } ;

nfaTransition:
    IDENT COLON nfaNextStates               { NFATransition ($1, $3)} ;

nfaNextStates:
    nfaNextState                            { [$1] }
  | nfaNextState COMMA nfaNextStates        { $1 :: $2 } ;

nfaNextState:
    IDENT                                   { $1 } ;


/************************/
/***** NPDA grammar *****/
/************************/

npdaStateList:
    npdaState                               { [$1] }
  | npdaState npdaStateList                 { $1 :: $2 } ;

npdaState:
    STATE IDENT BEGIN npdaTransitions END   { NPDAState ($2, $4)} ;

npdaTransitions:
    npdaTransition                          { [$1] }
  | npdaTransition npdaTransitions          { $1 :: $2 } ;

npdaTransition:
    LPAR IDENT COMMA IDENT RPAR COLON npdaNextStates
                                            { NPDATransition ($2, $4, $7)} ;

npdaNextStates:
    npdaNextState                           { [$1] }
  | npdaNextState COMMA npdaNextStates      { $1 :: $2 } ;

npdaNextState:
    LPAR IDENT COMMA IDENT RPAR             { ($2, $4) } ;


/************************/
/***** NDTM grammar *****/
/************************/

ndtmStateList:
    ndtmState                               { [$1] }
  | ndtmState ndtmStateList                 { $1 :: $2 } ;

ndtmState:
    STATE IDENT BEGIN ndtmTransitions END   { NDTMState ($2, $4)} ;

ndtmTransitions:
    ndtmTransition                          { [$1] }
  | ndtmTransition ndtmTransitions          { $1 :: $2 } ;

ndtmTransition:
    IDENT COLON ndtmNextStates              { NDTMTransition ($1, $3)} ;

ndtmNextStates:
    ndtmNextState                           { [$1] }
  | ndtmNextState COMMA ndtmNextStates      { $1 :: $2 } ;

ndtmNextState:
    LPAR IDENT COMMA IDENT COMMA IDENT RPAR { ($2, $4, $6) } ;



