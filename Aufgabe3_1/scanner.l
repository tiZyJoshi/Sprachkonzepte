/* MSE-3 BB Sprachkonzepte WS 2019 H.Moritsch      */
/* print sequence of token string and token number */

%{
enum { PLUS=0, MULT, MINUS, DIV, POWER,  SQRT, LEFT, RIGHT, DEFINE, ASSIGN, ID, NUMBER, EOL, OTHER, END} token_type;
/*     #0      #1    #2     #3   #4      #5    #6    #7     #8      #9      #10 #11     #12  #13    #14   */
%}

/* single input file */
%option noyywrap 

/* yytext: the token as string */

%%

"**"        return POWER; 
"sqrt"      return SQRT; 

"+"         return PLUS; 
"*"         return MULT;
"-"         return MINUS;
"/"         return DIV;

"("         return LEFT; 
")"         return RIGHT;

"def"       return DEFINE;
":="        return ASSIGN;
"$"         return END;

[a-z][a-z0-9]*      return ID;
[0-9]+(\.[0-9]+)?   return NUMBER;

^[ \t]*\n   /* ignore empty lines */

[ \t]       /* ignore space and tab within line */

\n          return EOL;         /* end of line */

.           return OTHER;       /* the rest is (character wise) recognized as OTHER token  */

%%

