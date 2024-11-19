%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Estructura para almacenar las variables y sus valores
typedef struct {
    char name[100];    // Nombre de la variable
    char value[2048];  // Valor de la variable
} Variable;

#define MAX_VARIABLES 100
Variable variables[MAX_VARIABLES];
int var_count = 0;

void yyerror(const char *s);
int yylex(void);

void a_texto(const char *bin, char *output);
void a_binario(const char *text, char *output);
char* get_variable(const char *name);
void set_variable(const char *name, const char *value);

extern FILE *yyin;
extern int yylineno;  // Declaración externa de yylineno
%}

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
    A_BINARIO IDENTIFICADOR ES LITERALCADENA FIN_SENTENCIA {
        char result[2048];
        a_binario($4, result);
        set_variable($2, result);
    }
    | A_TEXTO IDENTIFICADOR ES LITERALCADENA FIN_SENTENCIA {
        char result[2048];
        a_texto($4, result);
        set_variable($2, result);
    }
    | IMPRIMIR IDENTIFICADOR FIN_SENTENCIA {
        char *value = get_variable($2);
        if (value) {
            printf("%s\n", value);
        } else {
            printf("Error: Variable '%s' no definida.\n", $2);
        }
    }
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
    // yydebug = 1;  // Activa el modo de depuración
    yyparse();
    fclose(input);
    return 0;
}

void a_texto(const char *bin, char *output) {
    char clean_bin[512];
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
    if (len % 8 != 0) {
        snprintf(output, 2048, "Error: La longitud del binario no es múltiplo de 8.");
        return;
    }

    // Procesar los bits en bloques de 8
    for (int i = 0; i < len; i += 8) {
        char byte[9] = {0};
        strncpy(byte, clean_bin + i, 8);
        output[i / 8] = (char)strtol(byte, NULL, 2);
    }
    output[len / 8] = '\0'; // Terminar la cadena
}

void a_binario(const char *text, char *output) {
    output[0] = '\0'; // Iniciar cadena vacía
    for (int i = 0; text[i] != '\0'; i++) {
        char byte[9];
        for (int j = 7; j >= 0; --j) {
            byte[7 - j] = ((text[i] >> j) & 1) ? '1' : '0';
        }
        byte[8] = '\0';
        strcat(output, byte);
    }
}

char* get_variable(const char *name) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i].name, name) == 0) {
            return variables[i].value;
        }
    }
    return NULL;
}

void set_variable(const char *name, const char *value) {
    // Buscar si ya existe la variable
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i].name, name) == 0) {
            strncpy(variables[i].value, value, sizeof(variables[i].value) - 1);
            variables[i].value[sizeof(variables[i].value) - 1] = '\0';
            return;
        }
    }
    // Si no existe, agregar una nueva
    if (var_count < MAX_VARIABLES) {
        strncpy(variables[var_count].name, name, sizeof(variables[var_count].name) - 1);
        variables[var_count].name[sizeof(variables[var_count].name) - 1] = '\0';
        strncpy(variables[var_count].value, value, sizeof(variables[var_count].value) - 1);
        variables[var_count].value[sizeof(variables[var_count].value) - 1] = '\0';
        var_count++;
    } else {
        fprintf(stderr, "Error: Límite de variables alcanzado.\n");
    }
}

