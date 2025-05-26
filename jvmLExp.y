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


%}
/* Output informative error messages (bison Option) */
%define parse.error verbose

%union{
  char *lexical;
  ParType tokentype;
}


/* Token declarations and their respective types */

%token T_start "start"
%token T_end "end"
%token T_print "print"

%token '('
%token ')'
%token '+'
%token '*'
%token T_fplus "+."
%token T_fmul "*."

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

stmts: '(' stmt ')' stmts
      | %empty
      ;

stmt : printcmd | asmt;

printcmd : "print" expr {
         insertINSTRUCTION("getstatic java/lang/System/out Ljava/io/PrintStream;");
         insertINSTRUCTION("swap");
         insertINVOKEVITRUAL("java/io/PrintStream/println",$2,type_void) ;
};

asmt : '=' T_id expr {addvar(&symbolTable,$2,$3); insertSTORE($3,lookup_position(symbolTable,$2));};

expr : T_num {$$ = type_integer; pushInteger(atoi($1));}
     | T_real {$$ = type_real; insertLDC($1);}
     | T_id {$$ = lookup_type(symbolTable,$1); insertLOAD($$,lookup_position(symbolTable,$1));}
     | '+' expr expr {$$ = type_integer; insertOPERATION(type_integer,"add");}
     | '*' expr expr {$$ = type_integer; insertOPERATION(type_integer,"mul");}
     | "+." expr expr {$$ = type_real; insertOPERATION(type_real,"add");}
     | "*." expr expr {$$ = type_real; insertOPERATION(type_real,"mul");}
     | '(' expr ')' {$$ = $2;}
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
