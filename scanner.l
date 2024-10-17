%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void manejar_error(const char *mensaje);
%}

%option noyywrap


LETRA           [a-z]
ENTERO          [0-9]+
MIENTRAS        "mientras"
IMPRIMIR        "imprimir"
ES              "es"
CADENA          "cadena"


OPERADOR_ARITMETICO   [\+\-\*/%]
OPERADOR_BOOLEANO     "=="|"!="|">"|"<"|">="|"<="
SIGNOS_DE_PUNTUACION  [\(\)]

%%

{ENTERO}         { printf("Entero: %s\n", yytext); }
{MIENTRAS}       { printf("Palabra reservada: %s\n", yytext); }
{IMPRIMIR}       { printf("Palabra reservada: %s\n", yytext); }
{ES}             { printf("Palabra reservada: %s\n", yytext); }
{CADENA}         { printf("Palabra reservada: %s\n", yytext); }
{OPERADOR_ARITMETICO} { printf("Operador aritmetico: %s\n", yytext); }
{OPERADOR_BOOLEANO}   { printf("Operador booleano: %s\n", yytext); }
{SIGNOS_DE_PUNTUACION} { printf("Signo de puntuacion: %s\n", yytext); }


%%

void manejar_error(const char *mensaje) {
    fprintf(stderr, "Error: %s\n", mensaje);
    exit(1);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *archivo = fopen(argv[1], "r");
        if (!archivo) {
            manejar_error("No se puede abrir el archivo");
        }
        yyin = archivo; // Asignar el archivo de entrada a yyin
    }
    yylex(); // Llamar al analizador lexico
    return 0;
}