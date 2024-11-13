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
{IDENTIFICADOR}   { yylval.str = strdup(yytext); return IDENTIFICADOR; }
{LITERALCADENA}   { yylval.str = strdup(yytext); return LITERALCADENA; }

.                  { manejar_error("Caracter no reconocido"); }

%%

void manejar_error(const char *mensaje) {
    fprintf(stderr, "Error: %s\n", mensaje);
}