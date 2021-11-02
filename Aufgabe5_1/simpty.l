/* MSE-3 BB Sprachkonzepte WS 2020/2021 H.Moritsch */

%{
#include "simpty.tab.h"
%}

%option yylineno
%option noyywrap 

%%

"eqz"       return EQZ;
"ltz"       return LTZ;
"gtz"       return GTZ;
"end"       return END;

"+"         return PLUS_OP; 
"-"         return MINUS_OP; 
"*"         return MULT_OP; 
"/"         return DIV_OP; 
"("         return LEFT_PAR; 
")"         return RIGHT_PAR;
"="         return ASSIGN_OP;

[0-9]+         yylval.intnum = atoi(yytext);   return NUMBER;
[a-z_][a-z0-9]*  yylval.string = strdup(yytext); return IDENTIFIER;

^[ \t\r]*\n
[ \t\r]
\n          return EOL;

%%
