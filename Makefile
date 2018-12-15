############
OCAMLC=/usr/bin/env ocamlc
OCAMLC_FLAGS=
OCAMLLEX=/usr/bin/env ocamllex
OCAMLYACC=/usr/bin/env ocamlyacc
############
all: tomato

parser.ml: parser.mly
	$(OCAMLYACC) $<

lexer.ml: lexer.mll
	$(OCAMLLEX) $<

tomato: tree.ml check.ml tomato.ml tran.ml lexer.ml parser.ml
	$(OCAMLC) $(OCAMLC_FLAGS) parser.mli
	$(OCAMLC) $(OCAMLC_FLAGS) -o $@ str.cma tree.ml check.ml tran.ml parser.ml lexer.ml  tomato.ml

############