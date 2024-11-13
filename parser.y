%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char s);
int yylex(void);

%}

%token A_BINARIO A_TEXTO IMPRIMIR ES
%token IDENTIFICADOR LITERALCADENA

%%

programa:
    instrucciones
    ;

instrucciones:
    instrucciones instruccion
    | instruccion
    ;

instruccion:
    A_BINARIO IDENTIFICADOR ES LITERALCADENA { printf("Convertir %s a binario con valor %s\n", $2, $4); }
    | A_TEXTO IDENTIFICADOR ES LITERALCADENA { printf("Convertir %s a texto con valor %s\n", $2, $4); }
    | IMPRIMIR IDENTIFICADOR { printf("Imprimir %s\n", $2); }
    ;

%%

void yyerror(const chars) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    return yyparse();
}