%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "types.h"
%}

%option yylineno

ws [ \t]+
newline \n|\x0A|\x0D\x0A
digit [0-9]
digits {digit}+
letter [A-Za-z]
variable {letter}({letter}|{digit})*
set_op (intersect|union|diff)
%%
{ws} {/* do nothing */}
"var" {return T_VAR;}
"array" {return T_ARRAY;}
"of" {return T_OF;}
"set_of" {return T_SET_OF;}
"constraint" {return T_CONSTRAINT;}
"solve" {return T_SOLVE;}
"satisfy" {return T_SATISFY;}
"maximize" {return T_MAXIMIZE;}
"not" {return T_NOT;}
"true" {return T_TRUE;}
"false" {return T_FALSE;}
"subset" {return T_SUBSET;}
"in" {return T_IN;}

"bool" {return T_BOOL;}
"int" {return T_INT;}

":" {return ':';}
";" {return ';';}

{set_op} {yylval.lexical = strdup(yytext); return T_SET_OP;}
{digits} {yylval.number.type = type_integer; yylval.number.value = atoi(yytext); return T_NUM;}
{variable} {yylval.lexical = strdup(yytext); return T_ID;}

"[" {return '[';}
"]" {return ']';}
".." {return T_DOTS;}

"+" {return '+';}
"-" {return '-';}
"*" {return '*';}
"/" {return '/';}

">" {return '>';}
"<" {return '<';}
"==" {return T_EQ;}
">=" {return T_GE;}
"=<" {return T_LE;}

"#=" {return T_BOOL_ASGMNT;}

"~>" {return T_IMPLIES;}
"||" {return T_OR;}
"&&" {return T_AND;}

{newline} { /* Do nothing */ }
. {/*Do nothing*/}

%%


