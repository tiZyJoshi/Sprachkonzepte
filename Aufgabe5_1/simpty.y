/* MSE-3 BB Sprachkonzepte WS 2020/2021 H.Moritsch */
/* code generation for TinyVM */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "simpty_ir.h"

#define new(T) (T*) malloc(sizeof(T));

extern int yylex(void);

extern int yylineno;
extern char *yytext;
int yyerror(char *s);

int lookup(char * s); 

int regcount;
int labelcount = 1;

%}

/* Tokens und Nonterminalen ist die Variable yylval zugeordnet 
   (entspricht $1, ..., $$), deren Typ als Union aus mehreren 
   Komponenten definiert wird.
*/

%union {
    char * string;
    int intnum;
    int opcode;
    struct tVARREF * varref;
    struct tEXPR   * expr;
    struct tASSIGN * assign;
    struct tIFSA   * ifsa;
    struct tSTMT   * stmt;
    struct tSTMT_LIST   * stmtlist;
    // FILL IN
    struct tWHILE  * loopwhile;
    struct tPROG   * prog;
    }

/* Tokens */

%token PLUS_OP MULT_OP MINUS_OP DIV_OP
%token LEFT_PAR RIGHT_PAR
%token ASSIGN_OP
%token EQZ LTZ GTZ
%token EOL
%token END

/* Typen für Terminale: <Union-Komponente> Token */

%token <string> IDENTIFIER
%token <intnum> NUMBER

/* Typen für Nonterminale: <Union-Komponente> Syntaxvariable */

%type <opcode>      plusop multop zcondition
%type <varref>      variableref
%type <expr>        expression term factor 
%type <assign>      assignment
%type <ifsa>        ifsassign
%type <stmt>        statement
%type <stmtlist>    statements
// FILL IN
%type <whileexpr>   whileloop
%type <prog>        program

%start program

%%

program:    statements
                {
                prog->stmtlist = $1;
                }
            ;

statements: statements statement
                {
                $$ = $1;
                $$->last->next = $2;
                $$->last = $2;
                }
            | statement
                {
                $$ = new(STMT_LIST);
                $$->first = $1;
                $$->last  = $1;
                }
            ;
            
statement:  assignment
                {
                $$ = new(STMT);
                $$->next = NULL;
                $$->typ = IS_ASSIGN;
                $$->node.assign = $1;
                }
            | ifsassign
                {
                $$ = new(STMT);
                $$->next = NULL;
                $$->typ = IS_IFSA;
                $$->node.ifsa = $1;
                }
            ;

ifsassign:  variableref zcondition assignment
                {
                $$ = new(IFSA);
                $$->varref = $1;
                $$->typ = $2;
                $$->assign = $3;
                }
            ;

// FILL IN
whileloop:  expression zcondition statements
                {
                $$ = new(WHILE);
                $$->expr = $1;
                $$->typ = $2;
                $$->stmtlist = $3;
                }
            ;

assignment: variableref ASSIGN_OP expression EOL
                {
                $$ = new(ASSIGN);
                $$->varref = $1;
                $$->expr = $3;
                }
            ;

expression: expression plusop term 
                {
                $$ = new(EXPR); int iii=1;
                $$->typ = IS_OP;
                $$->node.operation.operand1 = $1;
                $$->node.operation.operator = $2;
                $$->node.operation.operand2 = $3;
                }
            | term
                { $$ = $1; }
            ;

term:       term multop factor
                {
                $$ = new(EXPR);
                $$->typ = IS_OP;
                $$->node.operation.operand1 = $1;
                $$->node.operation.operator = $2;
                $$->node.operation.operand2 = $3;
                }
            | factor
                { $$ = $1; }
            ;

factor:     LEFT_PAR expression RIGHT_PAR
                {
                $$ = $2;
                }
            | variableref
                {
                $$ = new(EXPR);
                $$->typ = IS_VAR;
                $$->node.varref = $1;
                }
            | NUMBER
                {
                $$ = new(EXPR);
                $$->typ = IS_NUM;
                $$->node.number = $1;
                }
            ;

variableref: IDENTIFIER
                {
                $$ = new(VARREF);
                int k = lookup($1);
                $$->index = k;
                if (k == 0) {
                    if (symcount <= MAX) {
                        symtab[symcount] = $1;
                        $$->index = symcount++;
                        }
                    else {
                        printf("max number (%d) of variables exceeded, \"%s\" not allowed\n", MAX, $1); 
                        $$->index = 0;
                        }
                    }
                }
            ;

zcondition: EQZ
                { $$ = IF_EQZ;}
            | LTZ 
                { $$ = IF_LTZ;}
            | GTZ 
                { $$ = IF_GTZ;}
            ;

plusop:     PLUS_OP
                { $$ = PLUS;}
            | MINUS_OP
                { $$ = MINUS;}
            ;

multop:     MULT_OP   
                { $$ = MULT;}
            | DIV_OP
                { $$ = DIV;}
            ;

%%

int lookup(char * s) { 
    int i;
    for (i=1; i < symcount; i++) {
        if (strcmp(s,symtab[i])==0) 
            return(i);
        }
    return(0);
    }

void print_reg(int n) {
    if (n <= 0 ) 
        printf("$0");
    else {
        if (n < symcount) 
            printf("%s", symtab[n]);
        else 
            printf("tmp%d", n);
        }
    }

int gen_expr(EXPR * expr) { 
    // always returns register which contains expression value
    // in case of a number => load number into $0
    int reg1, reg2, returnreg;
    char op;
    switch(expr->typ) {
        case IS_NUM:    // load of a number is done via $0
            printf("load $0 %d ; $0 <- %d\n", expr->node.number, expr->node.number);
            returnreg = 0;
        break;
        case IS_VAR:    // return register where variable is stored
            returnreg = expr->node.varref->index;
        break;
        case IS_OP:
            reg1 = gen_expr(expr->node.operation.operand1);
            reg2 = gen_expr(expr->node.operation.operand2);
            switch(expr->node.operation.operator) {
                case PLUS:  printf("add"); op = '+'; break;
                case MINUS: printf("sub"); op = '-'; break;
                case MULT:  printf("mul"); op = '*'; break;
                case DIV:   printf("div"); op = '/'; break;
                }
            printf(" $%d $%d $%d", ++regcount, reg1, reg2);
            printf(" ; "); print_reg(regcount); printf(" <- ");
                print_reg(reg1); printf(" %c ", op); print_reg(reg2); printf("\n");
            returnreg = regcount;
        break;
        }
    return returnreg;
    }

void gen_assign(ASSIGN * assign) {
    int rexp;
    rexp = gen_expr(assign->expr);
    printf("load $%d $%d", assign->varref->index, rexp);
    printf(" ; "); print_reg(assign->varref->index); printf(" <- "); 
        print_reg(rexp); printf("\n");
    }

void gen_ifsa(IFSA * ifsa) {
    int labelnr = labelcount++;
    char* op;
    switch(ifsa->typ) {
        case IF_EQZ: printf("jne"); op = "=" ; break;
        case IF_LTZ: printf("jge"); op = ">="; break;
        case IF_GTZ: printf("jle"); op = "<="; break;
        }
    printf(" $%d 0 label_%d", ifsa->varref->index, labelnr);
    printf(" ; if "); print_reg(ifsa->varref->index); printf(" %s 0 goto label_%d\n", op, labelnr);
    gen_assign(ifsa->assign);
    printf(":label_%d\n", labelnr);
    }

void gen_statements(STMT_LIST * statements) {
    STMT * s;
    for (s = statements->first; s != NULL; s = s->next) {
        switch(s->typ) {
            case IS_ASSIGN:   
                gen_assign(s->node.assign);
            break;
            case IS_IFSA:   
                gen_ifsa(s->node.ifsa);
            break;
            // FILL IN
            }
        }
    }

void gen_while(WHILE * while_loop) {
    // FILL IN
    int startLabel = labelcount++;
    int endLabel = labelcount++;
    char* op;
    switch(while_loop->typ) {
        case IF_EQZ: printf("jne"); op = "=" ; break;
        case IF_LTZ: printf("jge"); op = ">="; break;
        case IF_GTZ: printf("jle"); op = "<="; break;
        }
    printf(":label_%d\n", startLabel);
    printf(" ; if !("); gen_expr(while_loop->expr); printf(" %s 0) goto label_%d\n", op, endLabel);
    gen_statements(while_loop->stmtlist);
    printf(" goto label_%d\n", startLabel);
    printf(":label_%d\n", endLabel);
    }

int main(int argc, char **argv) {
    int i;
    prog = new(PROG);
    symtab[0] = "NULL";
    if (yyparse() == 0) { // no syntax error
        printf("; variables\n");    // variables in registers $1, ... 
        for (i=1; i < symcount; i++) {
            printf("; %s in $%d\n", symtab[i], i);
            }
    printf("\n");
        // generate target code
        regcount = symcount-1;              // temporaries in registers symcount, ...
        gen_statements(prog->stmtlist);
        printf("\n");
        for (i=1; i < symcount; i++) {
            printf("echo %s:\n", symtab[i]);
            printf("load $0 $%d\n", i);
            // printf("call write ; %s\n", symtab[i]);
            printf("call write\n");
            }
        printf("stop\n", symtab[i], i);
        }
    }

int yyerror(char *s) {
    printf("%s in line %d at token ",s, yylineno);
    if (yytext[0] != '\n') printf("\"%s\"\n",yytext);
    else printf("\"\\n\"\n");
    }


