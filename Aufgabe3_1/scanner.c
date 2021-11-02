#include <stdio.h>
extern int yylex (void);
extern char *yytext;

int main(int argc, char **argv) {
    int token;
    do {
        token = yylex();
        printf("token %2d ", token);
        if (token != 12)  // token #12 = EOL (end of line)
            printf("%s", yytext); 
        else 
            printf("\\n");
        printf("\n"); 
        } while (token != 14); // token #14 = END
    printf("\n");
    }
