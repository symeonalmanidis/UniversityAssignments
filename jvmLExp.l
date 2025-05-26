/*
Grammar with semantics and type checking.
Lexical Analyser
*/

%{
#include <stdlib.h>
#include <string.h>
int code_line = 1;
%}

DIGITS [0-9]
LETTER [a-zA-Z]
VARIABLE {LETTER}({LETTER}|{DIGITS}|_)*
FLOAT {DIGITS}+\.{DIGITS}+
newline \n|\x0A|\x0D\x0A
%%
"start" {return T_start;}
"end" {return T_end;}
"print" {return T_print;}

"(" {return '(';}
")" {return ')';}
"+" {return '+';}
"*" {return '*';}
"+." {return T_fplus;}
"*." {return T_fmul;}
"=" {return '=';}

{VARIABLE} {yylval.lexical = strdup(yytext);  return T_id;}
{DIGITS}+ {yylval.lexical = strdup(yytext);  return T_num;}
{FLOAT} {yylval.lexical = strdup(yytext); return T_real;}

{newline}  { code_line++;}
[ \t] { /* nothing */ }
. {
	printf("Lexical Analysis: Unexpected String! :: (%s) . in line %d. \n",yytext,yylineno); }

%%
