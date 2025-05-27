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
"reduce" {return T_reduce;}

"int" {yylval.tokentype = type_integer; return T_type;}
"float" {yylval.tokentype = type_real; return T_type;}

"(" {return '(';}
")" {return ')';}
"[" {return '[';}
"]" {return ']';} 
"+" {yylval.op.resulttype = type_integer; yylval.op.jvm_op = "add"; return T_op;}
"*" {yylval.op.resulttype = type_integer; yylval.op.jvm_op = "mul"; return T_op;}
"+." {yylval.op.resulttype = type_real; yylval.op.jvm_op = "add"; return T_op;}
"*." {yylval.op.resulttype = type_real; yylval.op.jvm_op = "mul"; return T_op;}

"min" {yylval.lexical = "java/lang/Math/min";  return T_static_op;}
"max" {yylval.lexical = "java/lang/Math/max"; return T_static_op;}

"=" {return '=';}

{VARIABLE} {yylval.lexical = strdup(yytext);  return T_id;}
{DIGITS}+ {yylval.lexical = strdup(yytext);  return T_num;}
{FLOAT} {yylval.lexical = strdup(yytext); return T_real;}

{newline}  { code_line++;}
[ \t] { /* nothing */ }
. {
	printf("Lexical Analysis: Unexpected String! :: (%s) . in line %d. \n",yytext,yylineno); }

%%
