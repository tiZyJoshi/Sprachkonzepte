bison -d simpty.y
flex simpty.l
gcc -o simpty simpty.tab.c lex.yy.c
