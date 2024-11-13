%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

void manejar_error(const char *mensaje);

extern FILE *yyin;
%}

%option noyywrap

A_BINARIO       "a_binario"
A_TEXTO         "a_texto"
IMPRIMIR        "imprimir"
ES              "es"

LETRA           [a-z]
DIGITO_BINARIO  [0-1]

SIGNOS_DE_PUNTUACION  [\{\}\(\)\.]

LITERALCADENA               \'[a-z]+\' 

IDENTIFICADOR   {LETRA}({LETRA}|{DIGITO_BINARIO}){0,15}

WHITESPACE      [ \t]+


%%

{WHITESPACE}              ; // Ignora espacios y tabulaciones
{A_BINARIO}       { return A_BINARIO; }
{A_TEXTO}         { return A_TEXTO; }
{IMPRIMIR}        { return IMPRIMIR; }
{ES}              { return ES; }
{LITERALCADENA}   { return LITERALCADENA; }
{IDENTIFICADOR}   { return IDENTIFICADOR; }

%%

void manejar_error(const char *mensaje) {
    fprintf(stderr, "Error: %s\n", mensaje);
    exit(1);
}

int main(int argc, char **argv) {       // argc es el numero de argumentos , argv es el arreglo que contiene los argumentos. 
    if (argc > 1) {
        FILE *archivo = fopen(argv[1], "r");
        if (!archivo) {
            manejar_error("No se puede abrir el archivo");
        }
        yyin = archivo; // Asignar el archivo de entrada a yyin
       } 
    else {
        printf("No se pasó ningún archivo. Usando entrada estándar.\n");
        yyin = stdin;  // Si no se pasa archivo, leer desde stdin
    }
    yylex();  // Ejecutar el analizador léxico
    return 0;
}