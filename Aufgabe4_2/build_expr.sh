bison -d -v expr.y
flex expr.l
gcc -o expr expr.tab.c lex.yy.c
