bison -d parser.y
flex scanner.l
gcc lex.yy.c parser.tab.c -o compilador -lfl
