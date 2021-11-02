/* MSE-3 BB Sprachkonzepte WS 2020/2021 H.Moritsch */

/* Intermediate Representation: Abstract Syntax Tree
*/
#define MAX 100

/* Variable reference
*/
typedef struct tVARREF {
    // Version 1: char * name;
    int index;  // Version 2
    } VARREF;

/* Expression
*/
typedef struct tEXPR {
    enum { IS_NUM=0, IS_VAR, IS_OP } typ;
    union {
        int number;            /* integer number */
        VARREF * varref;       /* variable reference */
        struct {
            enum { EQ=0, NE, GT, GE, LT, LE,
                   PLUS, MINUS, MULT, DIV,
                   AND, OR, NOT } operator; /* operator */
            struct tEXPR * operand1;        /* 1st operand */
            struct tEXPR * operand2;        /* 2nd operand */
            } operation;
        } node;
    } EXPR;

/* Assignment statement
*/
typedef struct tASSIGN {
    VARREF * varref;   /* variable reference */
    EXPR   * expr;     /* expression on right hand side */
    } ASSIGN;

/* IF with Single Asssignment
*/
typedef struct tIFSA {
    enum { IF_EQZ=0, IF_LTZ, IF_GTZ } typ;
    VARREF * varref;   
    ASSIGN * assign;
    } IFSA;

/* Statement
*/
typedef struct tSTMT {
    enum { IS_ASSIGN=0, IS_IFSA } typ;
    union {
        ASSIGN * assign;
        IFSA   * ifsa;
        struct tWHILE * loop; // WHILE defined below!
        } node;
    struct tSTMT * next; 
    } STMT;

/* List of statements
*/
typedef struct tSTMT_LIST {
    STMT * first;
    STMT * last;
    } STMT_LIST;

/* While loop statement
*/
typedef struct tWHILE {
    enum { W_EQZ=0, W_LTZ, W_GTZ } typ;
    EXPR * expr;
    STMT_LIST * stmtlist;
    } WHILE;
    
/* Program: root node of the program's AST
*/
typedef struct tPROG {
    STMT_LIST * stmtlist; /* list of statements */
    } PROG;

// -------------------------------
PROG * prog;          // root node of syntax tree
char * symtab[MAX+1]; // symbol table containing variables
int symcount = 1;
// -------------------------------
