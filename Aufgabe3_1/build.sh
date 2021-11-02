flex scanner.l
gcc -o scanner scanner.c lex.yy.c
# execute: scanner < test.in
