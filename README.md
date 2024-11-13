Tercer Entrega: Scanner
a)	Desarrollar un scanner en  Flex para las categorías léxicas
b)	Implementar argumentos de la línea de comando (programa comando)

flex scanner.l          # Compila el archivo Flex
gcc lex.yy.c -o ejecutable -lfl  # Compila el archivo generado
./ejecutable test.txt   # Ejecuta el scanner con el archivo de entrada


Cuarta Entrega: Parser
a)	Desarrollar un parser  en  BISON para las categorías sintácticas
b)	Implementar argumentos de la línea de comando (programa comando) 
