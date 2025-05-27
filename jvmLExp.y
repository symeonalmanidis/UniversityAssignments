%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Flex Declarations
/* Just for being able to show the code_line number were the error occurs.*/
extern int code_line;
extern FILE *yyout;
int yylex();
/* Error Related Functions and Macros*/
int yyerror(const char *);
int no_errors;
/* Error Messages Macros*/
#define ERR_VAR_DECL(VAR,LINE) fprintf(stderr,"Variable :: %s in code_line %d. ",VAR,LINE); yyerror("Var already defined");YYERROR
#define ERR_VAR_MISSING(VAR,LINE) fprintf(stderr,"Variable %s NOT declared, in code_line %d.",VAR,LINE); yyerror("Variable Declation fault");YYERROR
#define ERR_TYPE_MISSMATCH(EXPECTED,LINE) fprintf(stderr,"TYPE ERROR: Expected %s  in code_line %d.",EXPECTED,LINE); yyerror("Type missmatch");YYERROR

// Type Definitions and JVM command related Functions
#include "jvmLangTypesFunctions.h"
// Symbol Table definitions and Functions
#include "symbolTable.h"
/* Defining the Symbol table. A simple linked list. */
ST_TABLE_TYPE symbolTable;
#include "codeFacilities.h"

struct reduce_context {
  char * static_op_path;
  ParType type;  
};

struct reduce_context curr_rc;

#define TYPE_TO_STRING(TYPE) (TYPE == type_integer? "integer" : (TYPE == type_real? "real" : "error"))

%}
/* Output informative error messages (bison Option) */
%define parse.error verbose

%union{
  char *lexical;
  ParType tokentype;
  struct reduce_context rc;
  struct {
    ParType resulttype;
    char * jvm_op;
  } op;
}


/* Token declarations and their respective types */

%token T_start "start"
%token T_end "end"
%token T_print "print"
%token T_reduce "reduce"

%token <tokentype> T_type

%token '('
%token ')'
%token '['
%token ']'
%token <op> T_op

%token <lexical> T_static_op

%token '='

%token <lexical> T_id;
%token <lexical> T_num;
%token <lexical> T_real;


%type <tokentype> expr

%%
program: "start" T_id {create_preample($2); symbolTable=NULL; }
			stmts "end"
			{insertINSTRUCTION("return");
       insertINSTRUCTION(".end method\n");}
	;

stmts: closed_stmt stmts
      | error stmts
      | %empty
      ;

closed_stmt: '(' stmt ')';

stmt : printcmd | asmt ;

printcmd : "print" expr {
         insertINSTRUCTION("getstatic java/lang/System/out Ljava/io/PrintStream;");
         insertINSTRUCTION("swap");
         insertINVOKEVITRUAL("java/io/PrintStream/println",$2,type_void);
};

asmt : '=' T_id expr {ParType var_type;
                      if (!(var_type = lookup_type(symbolTable, $2))) {addvar(&symbolTable,$2,$3); var_type = $3;}
                      typeDefinition(var_type,$3);
                      insertSTORE($3,lookup_position(symbolTable,$2));};

expr : T_num {$$ = type_integer; pushInteger(atoi($1));}
     | T_real {$$ = type_real; insertLDC($1);}
     | T_id {if (($$ = lookup_type(symbolTable, $1))) {insertLOAD($$,lookup_position(symbolTable,$1));}
            else {ERR_VAR_MISSING($1, code_line);}}
     | T_type expr {if ($1 != $2) {insertCONVERSION($2, $1);}}
     | T_op expr expr {if ($1.resulttype == $2 && $1.resulttype == $3) {$$ = $1.resulttype; insertOPERATION($1.resulttype, $1.jvm_op);} 
                      else {ERR_TYPE_MISSMATCH(TYPE_TO_STRING($1.resulttype), code_line);} }
     | T_static_op expr expr {$$ = typeDefinition($2,$3); 
                              insertINVOKESTATIC_MULTIARG($1, $$, 2, $2, $3);}
     | "reduce" T_static_op '[' expr <rc>{$$ = curr_rc; curr_rc.static_op_path=$2; curr_rc.type=$4;}[prev_rc] reduceexprlist ']' {$$ = curr_rc.type; curr_rc = $prev_rc;}
     | '(' expr ')' {$$ = $2;}
     ;

reduceexprlist : expr {typeDefinition($1, curr_rc.type);
                       insertINVOKESTATIC_MULTIARG(curr_rc.static_op_path, curr_rc.type, 2, curr_rc.type, curr_rc.type);} reduceexprlist
               | %empty
               ;
%%


/* The usual yyerror */
int yyerror (const char * msg)
{
  fprintf(stderr, " ERROR: %s (line %d).\n", msg,code_line);
  no_errors++;
}

/* Other error Functions*/

/* The lexer... */
#include "jvmLExp.lex.c"

/* Main */
int main(int argc, char **argv ){
   FILE* jasmin_file;
   ++argv, --argc;  /* skip over program name */
   if ( argc > 0 && (yyin = fopen( argv[0], "r")) == NULL)
    {
      fprintf(stderr,"File %s NOT FOUND in current directory.\n Using stdin.\n",argv[0]);
      yyin = stdin;
    }
  

    // Calling the parser
   int result = yyparse();

   fprintf(stderr,"Errors found %d.\n",no_errors);
   // If no errors are found then 
   if (no_errors == 0){
      if ( argc > 1) {jasmin_file = fopen(argv[1], "w");}
      else {
          fprintf(stderr,"No second argument defined. Output to screen.\n\n");
          jasmin_file = stdout;
     }
     print_int_code(jasmin_file);
     fclose(jasmin_file);
     }

   /// Need to remove even empty file.
   if (no_errors != 0 ) {
      fprintf(stderr,"No Code Generated.\n");}
   print_symbol_table(symbolTable); /* uncomment for debugging. */

  return result;
}
