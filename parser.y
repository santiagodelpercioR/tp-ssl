%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);

void bin_to_text(const char *bin);
void text_to_bin(const char *text);

extern FILE *yyin;
extern int yylineno;  // Declaración externa de yylineno
%}

%debug
%union {
    char *str;
}

%token <str> A_BINARIO A_TEXTO IMPRIMIR ES FIN_SENTENCIA
%token <str> IDENTIFICADOR LITERALCADENA

%%

programa:
    instrucciones
    ;

instrucciones:
    instrucciones instruccion
    | instruccion
    ;

instruccion:
    A_BINARIO IDENTIFICADOR ES LITERALCADENA FIN_SENTENCIA { bin_to_text($4); }
    | A_TEXTO IDENTIFICADOR ES LITERALCADENA FIN_SENTENCIA { text_to_bin($4); }
    | IMPRIMIR IDENTIFICADOR FIN_SENTENCIA { printf("Imprimir %s\n", $2); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error de sintaxis en la línea %d: %s\n", yylineno, s);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        perror(argv[1]);
        return 1;
    }

    yyin = input;
    yydebug = 1;  // Activa el modo de depuración
    yyparse();
    fclose(input);
    return 0;
}

void bin_to_text(const char *bin) {
    char text[256];
    int len = strlen(bin);
    for (int i = 0; i < len; i += 8) {
        char byte[9] = {0};
        strncpy(byte, bin + i, 8);
        text[i / 8] = strtol(byte, NULL, 2);
    }
    text[len / 8] = '\0';
    printf("Binary to text: %s\n", text);
}

void text_to_bin(const char *text) {
    char bin[2048] = {0};
    for (int i = 0; text[i] != '\0'; i++) {
        char byte[9];
        for (int j = 7; j >= 0; --j) {
            byte[j] = ((text[i] >> (7 - j)) & 1) + '0';
        }
        byte[8] = '\0';
        strcat(bin, byte);
    }
    printf("Text to binary: %s\n", bin);
}
