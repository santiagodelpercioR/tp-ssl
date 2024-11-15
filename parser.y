%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);

void a_texto(const char *bin);
void a_binario(const char *text);

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
    A_BINARIO IDENTIFICADOR ES LITERALCADENA FIN_SENTENCIA {a_binario($4); }
    | A_TEXTO IDENTIFICADOR ES LITERALCADENA FIN_SENTENCIA {a_texto($4);  }
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

void a_texto(const char *bin) {
    char clean_bin[512]; 
    char text[256];      
    int len = strlen(bin);

    // Remover las comillas si están presentes
    if (bin[0] == '"' && bin[len - 1] == '"') {
        strncpy(clean_bin, bin + 1, len - 2); 
        clean_bin[len - 2] = '\0';           
    } else {
        strncpy(clean_bin, bin, len);        
        clean_bin[len] = '\0';
    }

    len = strlen(clean_bin);
    printf("Binary input sin comillas: %s\n", clean_bin);

    // Verificar si la longitud es múltiplo de 8
    if (len % 8 != 0) {
        printf("Error: la longitud del binario no es múltiplo de 8.\n");
        return;
    }

    // Procesar los bits en bloques de 8
    for (int i = 0; i < len; i += 8) {
        char byte[9] = {0};
        strncpy(byte, clean_bin + i, 8);
        text[i / 8] = (char)strtol(byte, NULL, 2);
    }

    text[len / 8] = '\0'; 
    printf("Texto resultante: %s\n", text);
}

void a_binario(const char *text) {
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
