%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Estructura para almacenar las variables y sus valores
typedef struct {
    char name[100];    // Nombre de la variable
    char value[2048];  // Valor de la variable
    char type[10];     // Tipo de dato: "cadena" o "caracter"
} Variable;

#define MAX_VARIABLES 100
Variable variables[MAX_VARIABLES];
int var_count = 0;

void yyerror(const char *s);
int yylex(void);

void a_texto(const char *bin, char *output);
void a_binario(const char *text, char *output);
char* get_variable(const char *name);
void set_variable(const char *name, const char *value, const char *type);

extern FILE *yyin;
extern int yylineno;  // Declaración externa de yylineno
%}

%union {
    char *str;
}

%token <str> A_BINARIO A_TEXTO IMPRIMIR ES FIN_SENTENCIA
%token <str> IDENTIFICADOR LITERALCADENA CARACTER
%token <str> ABRIR_BLOQUE CERRAR_BLOQUE

%%

programa:
    sentencias
    ;

sentencias:
    sentencias sentencia
    | sentencia
    ;

sentencia:
    ABRIR_BLOQUE operaciones CERRAR_BLOQUE
    ;

operaciones:
    operaciones operacion
    | operacion
    ;


operacion:
    A_BINARIO IDENTIFICADOR ES LITERALCADENA FIN_SENTENCIA {
        char result[2048];
        a_binario($4, result);
        set_variable($2, result, "cadena");
    }
    | A_TEXTO IDENTIFICADOR ES LITERALCADENA FIN_SENTENCIA {
        char result[2048];
        a_texto($4, result);
        set_variable($2, result, "cadena");
    }
    | IDENTIFICADOR ES CARACTER FIN_SENTENCIA {
        set_variable($1, $3, "caracter");
    }
    | IDENTIFICADOR ES LITERALCADENA FIN_SENTENCIA {  
        set_variable($1, $3, "cadena");
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
    if (argc > 1) {
        // Si se pasa un archivo como argumento, lo abre
        FILE *input = fopen(argv[1], "r");
        if (!input) {
            perror(argv[1]);
            return 1;
        }
        yyin = input;
    } else {
        // Si no se pasa archivo, usa la entrada estándar
        yyin = stdin;
        printf("Ingrese texto para analizar (Ctrl+D para finalizar en Linux/Mac, Ctrl+Z en Windows):\n");
    }

    // yydebug = 1;  // Activa el modo de depuración
    yyparse();  // Llama al parser

    // Si se abrió un archivo, lo cierra
    if (argc > 1) {
        fclose(yyin);
    }

    return 0;
}

void a_texto(const char *bin, char *output) {
    if (strlen(bin) == 0) {
        snprintf(output, 2048, "Error: Binario vacío.");
        return;
    }
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
    if (strlen(text) == 0) {
        snprintf(output, 2048, "Error: Texto vacío.");
        return;
    }
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

void set_variable(const char *name, const char *value, const char *type) {
    // Buscar si ya existe la variable
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i].name, name) == 0) {
            // Sobrescribir el valor y el tipo
            strncpy(variables[i].value, value, sizeof(variables[i].value) - 1);
            variables[i].value[sizeof(variables[i].value) - 1] = '\0';
            strncpy(variables[i].type, type, sizeof(variables[i].type) - 1);
            variables[i].type[sizeof(variables[i].type) - 1] = '\0';
            return;
        }
    }
    // Si no existe, agregar una nueva
    if (var_count < MAX_VARIABLES) {
        strncpy(variables[var_count].name, name, sizeof(variables[var_count].name) - 1);
        variables[var_count].name[sizeof(variables[var_count].name) - 1] = '\0';
        strncpy(variables[var_count].value, value, sizeof(variables[var_count].value) - 1);
        variables[var_count].value[sizeof(variables[var_count].value) - 1] = '\0';
        strncpy(variables[var_count].type, type, sizeof(variables[var_count].type) - 1);
        variables[var_count].type[sizeof(variables[var_count].type) - 1] = '\0';
        var_count++;
    } else {
        fprintf(stderr, "Error: Límite de variables alcanzado.\n");
    }
}

