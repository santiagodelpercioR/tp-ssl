bison -d parser.y
flex scannerDebug.l
gcc lex.yy.c parser.tab.c -o compilador -lfl