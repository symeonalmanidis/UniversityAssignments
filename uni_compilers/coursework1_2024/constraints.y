%{
#include <stdio.h>
#include <stdlib.h>

/* std bool C lib for true/false and bool type.*/
#include <stdbool.h>

// To remove persistent warning..
int yylex();
void yyerror (const char * msg);
/* Error Messages Macros*/
#define ERR_VAR_DECL(VAR,LINE) fprintf(stderr, "Var %s Already Declared (line %d)", VAR, LINE); yyerror("Var already defined"); yynerrs++
#define ERR_VAR_MISSING(VAR,LINE) fprintf(stderr, "Undefined Variable %s (line %d)", VAR, LINE); yyerror("Variable Declation fault"); yynerrs++
#define ERR_INT_ARG(LINE) fprintf(stderr, "Expecting int argument (line %d)", LINE); yyerror("Invalid argument (int needed)"); yynerrs++
#define ERR_RNG_DECL(LINE) fprintf(stderr, "Wrong Ranges declared (line %d)", LINE); yyerror("Range decleration fault"); yynerrs++
#define ERR_SET_TYPE_DECL(LINE) fprintf(stderr, "Wrong Type in set delcaration (line %d)", LINE); yyerror("Invalid set type"); yynerrs++
#define ERR_SET_ARG(LINE) fprintf(stderr, "Args are not sets, line %d", LINE); yyerror("Invalid argument (set needed)"); yynerrs++
#define ERR_IDX_TYPE(LINE) fprintf(stderr, "Index must be an integer (line %d)", LINE); yyerror("Invalid argument (int needed)"); yynerrs++
#define ERR_BOOL_ARG(LINE) fprintf(stderr, "Expecting a boolean in a logical (line %d)", LINE); yyerror("Invalid argument (bool needed)"); yynerrs++
#define ERR_ARR_ARG(LINE) fprintf(stderr, "Expecting an array (line %d)", LINE); yyerror("Invalid argument (array needed)"); yynerrs++



int yylineno;
#include "types.h"
/* Required for accessing functions of the symbol Table. */
#include "symbolTable.h"
/* pointer for the symbol table.*/
ST_TABLE_TYPE symbolTable;

%}

%define parse.error verbose

/* Union of lexical values defined. 
lexical is for the name of the variables
type is the type defined in the enumerated ParType found in types.h
** You can change the union
*/
%union{
   char *lexical;
   ParType type;
   struct {
        ParType type;
        int value; } number;
}

%type <type> Base_type
%type <type> Arg
%type <type> BoolArg
%type <type> NumExpression  
%type <type> SetExpression
%type <type> Unary
%type <type> BoolExpr

%token T_VAR "var"
%token T_ARRAY "array"
%token T_OF "of"
%token T_SET_OF "set_of"
%token T_CONSTRAINT "constraint"
%token T_SOLVE "solve"
%token T_SATISFY "satisfy"
%token T_MAXIMIZE "maximize"
%token T_TRUE "true"
%token T_FALSE "false"
%token T_SUBSET "subset"
%token T_IN "in"

%token T_BOOL "bool"
%token T_INT "int"

%token ':'
%token ';'

%token <lexical> T_SET_OP
%token <number> T_NUM
%token <lexical> T_ID

%token '['
%token ']'
%token T_DOTS ".." 

%token '+'
%token '-'
%token '*'
%token '/'

%token '<'
%token '>'
%token T_EQ "==" 
%token T_GE ">=" 
%token T_LE "=<" 

%token T_BOOL_ASGMNT "#=" 

%token T_IMPLIES "~>"
%token T_OR "||"
%token T_AND "&&"
%token T_NOT "not"

%left '+' '-'
%left '*' '/' 

%nonassoc "~>"
%left "||"
%left "&&"

%%

Model : {symbolTable=NULL;} Items
      ;
Items : %empty
      | Item ';' Items
      | error ';' Items
      ;
Item  : Var_item 
      | Constraint_item
      | Solve_item
      ;
Var_item : "var" Base_type ':' T_ID {if ($2 != type_error && !addvar(&symbolTable, $4, $2)) {ERR_VAR_DECL($4,yylineno);}}
         | "var" "set_of" Base_type ':' T_ID {if ($3 != type_integer) {ERR_SET_TYPE_DECL(yylineno);} else if (!addvar(&symbolTable, $5, type_int_set)) {ERR_VAR_DECL($5,yylineno);} }
         | "var" "array" '[' T_NUM ".." T_NUM ']' "of" Base_type ':' T_ID {if ($4.value > $6.value) {ERR_RNG_DECL(yylineno);} 
                                                                           else if ($9 == type_integer && !addvar(&symbolTable, $11, type_int_array)) {ERR_VAR_DECL($11,yylineno);}
                                                                           else if ($9 == type_bool && !addvar(&symbolTable, $11, type_bool_array)) {ERR_VAR_DECL($11,yylineno);}
                                                                           else if ($9 == type_error) {}}
         ;
Base_type   : "bool" {$$ = type_bool;}
            | "int" {$$ = type_integer;}
            | T_NUM ".." T_NUM {if ($1.value > $3.value) {ERR_RNG_DECL(yylineno); $$ = type_error;} else {$$ = type_integer;}}
            ;
RelOp : '>'
      | '<'
      | "=="
      | ">="
      | "=<"
      ;
Constraint_item   : "constraint" BoolExpr {if ($2 != type_bool) {/*handle error*/}}
                  | "constraint" T_ID "#=" BoolExpr {if (lookup(symbolTable, $2)) {if (lookup_type(symbolTable, $2) != type_bool) {ERR_BOOL_ARG(yylineno);} } else {ERR_VAR_MISSING($2,yylineno);}
                                                     if ($4 != type_bool) {/*handle error*/}}
                  ;
BoolExpr : BoolExpr "~>" BoolExpr {if ($1 == type_bool && $3 == type_bool) {$$ = type_bool;} else {$$ = type_error;}}
         | BoolExpr "&&" BoolExpr {if ($1 == type_bool && $3 == type_bool) {$$ = type_bool;} else {$$ = type_error;}}
         | BoolExpr "||" BoolExpr {if ($1 == type_bool && $3 == type_bool) {$$ = type_bool;} else {$$ = type_error;}}
         | Unary {$$ = $1;}
         ; 
Unary : "not" BoolArg {$$ = $2;} 
      | BoolArg {$$ = $1;}
      ;
BoolArg  : NumExpression RelOp NumExpression {$$ = type_bool;}
         | SetExpression {if ($1 == type_bool) {$$ = type_bool;} else {$$ = type_error;}}
         | "true" {$$ = type_bool;}
         | "false" {$$ = type_bool;}
         | Arg {if ($1 == type_bool) {$$ = type_bool;} else {ERR_BOOL_ARG(yylineno); $$ = type_error;}}
         ;
NumExpression  : NumExpression '+' NumExpression {if ($1 == type_integer && $3 == type_integer) {$$ = type_integer;} else {$$ = type_error;}}
               | NumExpression '-' NumExpression {if ($1 == type_integer && $3 == type_integer) {$$ = type_integer;} else {$$ = type_error;}}
               | NumExpression '*' NumExpression {if ($1 == type_integer && $3 == type_integer) {$$ = type_integer;} else {$$ = type_error;}}
               | NumExpression '/' NumExpression {if ($1 == type_integer && $3 == type_integer) {$$ = type_integer;} else {$$ = type_error;}}
               | Arg {if ($1 == type_error) {$$ = type_error;} else if ($1 == type_integer) {$$ = type_integer;} else {ERR_INT_ARG(yylineno); $$ = type_error;}}
               ;
SetExpression  : Arg "subset" Arg T_SET_OP Arg {if ($1 == type_int_set && $3 == type_int_set && $5 == type_int_set) {$$ = type_bool;} else {ERR_SET_ARG(yylineno); $$ = type_error;}}
               | Arg "subset" Arg              {if ($1 == type_error || $3 == type_error) {$$ = type_error;} else if ($1 == type_int_set && $3 == type_int_set) {$$ = type_bool;} else {ERR_SET_ARG(yylineno); $$ = type_error;}}
               | Arg "in" Arg                  {if ($1 == type_error || $3 == type_error) {$$ = type_error;} else if ($1 == type_integer && $3 == type_int_set) {$$ = type_bool;} else {ERR_SET_ARG(yylineno); $$ = type_error;}}
               ;
Arg   : T_NUM {$$ = type_integer;}
      | T_ID             {if (lookup(symbolTable, $1)) {$$ = lookup_type(symbolTable, $1);} else {ERR_VAR_MISSING($1,yylineno); $$ = type_error;}}
      | T_ID '[' Arg ']' {if (lookup(symbolTable, $1)) 
                              {if(lookup_type(symbolTable, $1) == type_int_array) {$$ = type_integer;} 
                              else if(lookup_type(symbolTable, $1) == type_bool_array) {$$ = type_bool;} 
                              else {ERR_ARR_ARG(yylineno); $$ = type_error;}} 
                          else {ERR_VAR_MISSING($1,yylineno); $$ = type_error;} 
                          if ($3 != type_integer) {ERR_IDX_TYPE(yylineno); $$ = type_error;}}
      ;
Solve_item : "solve" SolutionType;
SolutionType   : "satisfy" 
               | "maximize" T_ID {if (lookup(symbolTable, $2)) {if (lookup_type(symbolTable, $2) != type_integer) {ERR_INT_ARG(yylineno);}} else {ERR_VAR_MISSING($2,yylineno);}}
               ;
%%
#include "constraints.lex.c"


void yyerror (const char * msg)
{
   fprintf(stderr,"Error(line %d) : %s\n",yylineno, msg); 
}

// Additonal Functions



int main(int argc, char **argv ){
  
   ++argv, --argc;  /* skip over program name */
   if ( argc > 0 )
       yyin = fopen( argv[0], "r" );
   else
      yyin = stdin;

   int result = yyparse();

   if (result == 0 && yynerrs == 0)
      printf("Syntax OK!\n");
   else
      printf("There were %d errors in code. Failure!\n", yynerrs);
   return result;
}








