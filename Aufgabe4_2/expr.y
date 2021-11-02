%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex(void); // scanner routine

extern int yylineno;    // returned by scanner (for use in yyerror)
extern char *yytext;    // current token
int yyerror(char *s);   // current line number
double res;
double mem[26];
%}

%union {
	double fpnum;
        int mem_idx;
}
%type <fpnum> expr term factor
%type <mem_idx> assign_mem


// token definitions
%token PLUS_OP MINUS_OP MULT_OP DIV_OP 
%token PAR_LEFT PAR_RIGHT
%token ASSIGN
%token EOL
%token OTHER

// terminal symbols
%token <mem_idx> MEMORY
%token <fpnum> FPNUM

// start variable
%start lines

%%

/* lower case names for nonterminals (variables), upper case for terminals (tokens)
 
   Semantic actions between "{" and "}" after the right-hand side of a rule
   contain C-code with "pseudovariables":

   $$ represents the variable being recognized (left-hand side of the rule),
   $1, $2, $3, ... represent values of each symbol on the right-hand side:
   $i refers to the value associated with the i-th grammar symbol (variable 
   or terminal!) on the right.
 
   A semantic action is performed when there is a reduction by the associated
   rule, so normally the semantic action computes a value for $$ using the $i's.

   The type of the pseudovariables is the same as the type of yylval (the value
   of the current token on the stack). 
*/

lines   : lines line
        |                           // empty right-hand side: lines -> epsilon
        ;

line    : expr EOL                  {
				    	res = $1;
				    	printf("%.3f\n", res);
				    } // print result value and save to res
      	| assign_mem EOL
        ;

expr    : expr PLUS_OP term         { $$ = $1 + $3; }         // perform addition 
        | expr MINUS_OP term        { $$ = $1 - $3; }         // perform subtraction
        | term                      { $$ = $1; }
        ;

term    : term MULT_OP factor       { $$ = $1 * $3; }         // perform multiplication
        | term DIV_OP factor        { $$ = $1 / $3; }         // perform division
        | factor                    { $$ = $1; }
        ;

factor  : FPNUM                     { $$ = $1; }
        | MEMORY   		    { $$ = mem[$1-97]; }
        | PAR_LEFT expr PAR_RIGHT   { $$ = $2; }
        ;

assign_mem : ASSIGN MEMORY	    {
					mem[$2-97] = res;
					printf("%.3f\n", res);
				    } // print result and save to mem
        ;

%%

int main(int argc, char **argv) {
    if (yyparse() == 0) {   // if parser routine returns without error         
        printf("ok\n");
        }
    }

int yyerror(char *s) {
    printf("%s in line %d at token \"%s\"\n", s, yylineno, yytext);
    }

