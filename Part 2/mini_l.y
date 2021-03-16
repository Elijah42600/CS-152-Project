/* Parser */
/* mini_l.y */

%{
extern int currPos, currLine;
#include "heading.h"
int yyerror(char* s);
int yylex(void);
#include <stdio.h>
%}

%union { int ival; char* sval; }

%token<ival> NUMBER
%token<sval> IDENT

%token FUNCTION
%token BEGIN_PARAMS
%token END_PARAMS
%token BEGIN_LOCALS
%token END_LOCALS
%token BEGIN_BODY
%token END_BODY
%token INTEGER
%token ARRAY
%token OF
%token IF
%token THEN
%token ENDIF
%token ELSE
%token WHILE
%token DO
%token BEGINLOOP
%token ENDLOOP
%token BREAK
%token READ
%token WRITE
%token AND
%token OR
%token NOT
%token TRUE
%token FALSE
%token RETURN
%token SUB
%token ADD
%token DIV
%token MULT
%token MOD
%token EQ
%token NEQ
%token GT
%token LT
%token GTE
%token LTE
%token SEMICOLON
%token COLON
%token COMMA
%token L_PAREN
%token R_PAREN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%token ASSIGN
%token EQUAL


%start prog_start

%%

prog_start: functions {printf("prog_start -> functions\n");}

functions: function functions {printf("functions -> function functions\n");} | epsilon {printf("functions -> epsilon\n");}

function: FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("function -> FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}

declarations: declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");} | epsilon {printf("declarations -> epsilon\n");}

statements: statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");} | epsilon {printf("statements -> epsilon\n");}

declaration: identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");} | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");} | identifiers INTEGER {printf("Syntax error at line %d: invalid declaration\n", currLine);}

identifiers: ident COMMA identifiers {printf("identifiers -> ident COMMA identifiers\n");} | ident {printf("identifiers -> ident\n");}

statement: var ASSIGN expression {printf("statement -> var ASSIGN expression\n");} | IF bool_exp THEN statements else ENDIF {printf("statement -> IF bool_exp THEN statements else ENDIF\n");} | WHILE bool_exp BEGINLOOP statements ENDLOOP {printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP\n");} | DO BEGINLOOP statements ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp\n");} | WRITE vars {printf("statement -> WRITE vars\n");} | READ vars {printf("statement -> READ vars\n");} | BREAK {printf("statement -> BREAK\n");} | RETURN expression {printf("statement -> RETURN expression\n");} | var EQUAL expression {printf("Syntax error at line %d: \":=\" expected\n", currLine);}

else: ELSE statements {printf("else -> ELSE statements\n");} | epsilon {printf("else -> epsilon\n");}

bool_exp: relation_and_exp bool_exp_opt {printf("bool_exp -> relation_and_exp bool_exp_opt\n");}

bool_exp_opt: OR relation_and_exp bool_exp_opt {printf("bool_exp_opt -> OR relation_and_exp bool_exp_opt\n");} | epsilon {printf("bool_exp_opt -> epsilon\n");}

relation_and_exp: relation_exp relation_and_exp_opt {printf("relation_and_exp -> relation_exp relation_and_exp_opt\n");}

relation_and_exp_opt: AND relation_exp relation_and_exp_opt {printf("relation_and_exp_opt -> AND relation_exp relation_and_exp_opt\n");} | epsilon {printf("relation_and_exp_opt -> epsilon\n");}

relation_exp: NOT relation_exp {printf("relation_exp -> NOT relation_exp\n");} | expression comp expression {printf("relation_exp -> expression comp expression\n");} | TRUE {printf("relation_exp -> TRUE\n");} | FALSE {printf("relation_exp -> FALSE\n");} | L_PAREN bool_exp R_PAREN {printf("relation_exp -> L_PAREN bool_exp R_PAREN\n");}

expression: multiplicative_expression expression_opt {printf("expression ->  multiplicative_expression expression_opt\n");}

expression_opt: ADD multiplicative_expression expression_opt {printf("expression_opt -> ADD multiplicative_expression expression_opt\n");} | SUB multiplicative_expression expression_opt {printf("expression_opt -> SUB multiplicative_expression expression_opt\n");} | epsilon {printf("expression_opt -> epsilon\n");}

multiplicative_expression: term multiplicative_expression_opt {printf("multiplicative_expression -> term multiplicative_expression_opt\n");}

multiplicative_expression_opt: MULT term multiplicative_expression_opt {printf("multiplicative_expression_opt -> MULT term multiplicative_expression_opt\n");} | DIV term multiplicative_expression_opt {printf("multiplicative_expression_opt -> DIV term multiplicative_expression_opt\n");} | MOD term multiplicative_expression_opt {printf("multiplicative_expression_opt -> MOD term multiplicative_expression_opt\n");} | epsilon {printf("multiplicative_expression_opt -> epsilon\n");}

comp: EQ {printf("comp -> EQ\n");} | NEQ {printf("comp -> NEQ\n");} | LT {printf("comp -> LT\n");} | GT {printf("comp -> GT\n");} | LTE {printf("comp -> LTE\n");} | GTE {printf("comp -> GTE\n");} 

term: SUB term2 {printf("term -> SUB term2\n");} | term2 {printf("term -> term2\n");} | ident L_PAREN expressions R_PAREN {printf("term -> ident L_PAREN expressions R_PAREN\n");}

term2: var {printf("term2 -> var\n");} | NUMBER {printf("term2 -> NUMBER\n");} | L_PAREN expression R_PAREN {printf("term2 -> L_PAREN expression R_PAREN\n");}

expressions: expression COMMA expressions {printf("expressions -> expression COMMA expressions\n");} | expression {printf("expressions -> expression\n");}

vars: var COMMA vars {printf("vars -> var COMMA vars\n");} | var {printf("vars -> var\n");}

var: ident {printf("var -> ident\n");} | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}

identifiers: ident COMMA identifiers {printf("identifiers -> ident COMMA identifiers\n");} | ident {printf("identifiers -> ident\n");}

ident: IDENT  {printf("ident -> IDENT %s\n", ($1));}

epsilon: {}

%%

int yyerror(char* s) //string
{
 
  extern char *yytext;	// defined and maintained in lex.c
  
  printf("ERROR: %s at symbol \"%s\" on line %d\n", s, yytext, currLine);
  exit(1);
}
