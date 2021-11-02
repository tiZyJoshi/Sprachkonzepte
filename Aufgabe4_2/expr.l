/* The generated (from expr.y) parser calls the scanner generated from expr.l   */

%{
/* the token declarations created with 'bison -d'; see expr.y                   */
#include "expr.tab.h"
%}

/* this enables numbering of input lines (for error reporting)                  */
%option yylineno

/* single input file (libfl not needed) */
%option noyywrap

/* lower case names for regular expression names, upper case for tokens
   tokens have to be defined in expr.y!                                         */

/* yytext: the token, as a string
   yylval: value of the token (returned to the parser)                          */

%%

"+"         return PLUS_OP; 
"*"         return MULT_OP;
"-"         return MINUS_OP;
"/"         return DIV_OP;

"("         return PAR_LEFT; 
")"         return PAR_RIGHT;

[0-9]+(\.[0-9]+)?   {
                        double val;
                        sscanf(yytext, "%lf", &val);
                        yylval.fpnum = val;
                        return FPNUM;
                    }

[a-z]       {
                yylval.mem_idx = (int) yytext[0];
                return MEMORY;
            }
"="         return ASSIGN;

^[ \t]*\n                       /* ignore empty lines                           */
[ \t]                           /* ignore space, tab within line                */

\n          return EOL;         /* end of line                                  */
.           return OTHER;       /* anything else is recognized as OTHER token   */

%%


