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
    bloques
    ;

bloques:
    bloques bloque
    | bloque
    ;

bloque:
    ABRIR_BLOQUE sentencias CERRAR_BLOQUE
    ;

sentencias:
    sentencias sentencia
    | sentencia
    ;

sentencia:
    operacion
    ;

operacion:
    LITERALCADENA A_BINARIO ES IDENTIFICADOR FIN_SENTENCIA {
        char result[2048];
        a_binario($1, result); // Convertir el literal a binario
        set_variable($4, result, "cadena"); 
    }
    | LITERALCADENA A_TEXTO ES IDENTIFICADOR FIN_SENTENCIA {
        char result[2048];
        a_texto($1, result); // Convertir el literal a texto
        set_variable($4, result, "cadena"); 
    }
    | CARACTER ES IDENTIFICADOR FIN_SENTENCIA {
        set_variable($3, $1, "caracter"); 
    }
    | LITERALCADENA ES IDENTIFICADOR FIN_SENTENCIA {
        set_variable($3, $1, "cadena"); 
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

    // No reiniciar las variables al comenzar un nuevo análisis
    // var_count = 0;  // Eliminado para que las variables persistan entre ejecuciones de yyparse

    // Limpiar las variables solo al finalizar
    // yydebug = 1;  // Activa el modo de depuración
    yyparse();  // Llama al parser

    // Al finalizar el análisis, limpiar las variables
    var_count = 0;  // Ahora se limpia solo al final, no entre ejecuciones

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

    char clean_text[2048];
    int len = strlen(text);

    // Remover comillas
    if (text[0] == '"' && text[len - 1] == '"') {
        strncpy(clean_text, text + 1, len - 2);
        clean_text[len - 2] = '\0';
    } else {
        strncpy(clean_text, text, len);
        clean_text[len] = '\0';
    }

    output[0] = '\0'; // Iniciar cadena vacía
    for (int i = 0; clean_text[i] != '\0'; i++) {
        char byte[9];
        for (int j = 7; j >= 0; --j) {
            byte[7 - j] = ((clean_text[i] >> j) & 1) ? '1' : '0';
        }
        byte[8] = '\0';
        strcat(output, byte);
    }
}


char* get_variable(const char *name) {
    char clean_name[2048];
    int len = strlen(name);

    // Remover comillas si están presentes
    if (name[0] == '"' && name[len - 1] == '"') {
        strncpy(clean_name, name + 1, len - 2);
        clean_name[len - 2] = '\0';
    } else {
        strncpy(clean_name, name, len);
        clean_name[len] = '\0';
    }

    for (int i = 0; i < var_count; i++) {
        //printf("Buscando variable %s, comparando con %s\n", clean_name, variables[i].name);  // Mensaje de depuración
        if (strcmp(variables[i].name, clean_name) == 0) {
            return variables[i].value;
        }
    }
    return NULL;
}



void set_variable(const char *name, const char *value, const char *type) {
    char clean_value[2048];
    int len = strlen(value);

    // Remover comillas si están presentes
    if (value[0] == '"' && value[len - 1] == '"') {
        strncpy(clean_value, value + 1, len - 2);
        clean_value[len - 2] = '\0';
    } else {
        strncpy(clean_value, value, len);
        clean_value[len] = '\0';
    }

    // Buscar si ya existe la variable
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i].name, name) == 0) {
            // Sobrescribir el valor y el tipo
            strncpy(variables[i].value, clean_value, sizeof(variables[i].value) - 1);
            variables[i].value[sizeof(variables[i].value) - 1] = '\0';
            strncpy(variables[i].type, type, sizeof(variables[i].type) - 1);
            variables[i].type[sizeof(variables[i].type) - 1] = '\0';
            //printf("Variable %s redefinida como %s\n", name, clean_value);
            return;
        }
    }

    // Si no existe, agregar una nueva
    if (var_count < MAX_VARIABLES) {
        strncpy(variables[var_count].name, name, sizeof(variables[var_count].name) - 1);
        variables[var_count].name[sizeof(variables[var_count].name) - 1] = '\0';
        strncpy(variables[var_count].value, clean_value, sizeof(variables[var_count].value) - 1);
        variables[var_count].value[sizeof(variables[var_count].value) - 1] = '\0';
        strncpy(variables[var_count].type, type, sizeof(variables[var_count].type) - 1);
        variables[var_count].type[sizeof(variables[var_count].type) - 1] = '\0';
        //printf("Variable %s definida como %s\n", name, clean_value);
        var_count++;
    } else {
        fprintf(stderr, "Error: Límite de variables alcanzado.\n");
    }
}




