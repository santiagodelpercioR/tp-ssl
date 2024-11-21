%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

FIN_SENTENCIA   ["."]

A_BINARIO       "a_binario"
A_TEXTO         "a_texto"
IMPRIMIR        "imprimir"
ES              "es"
ABRIR_BLOQUE    "<"
CERRAR_BLOQUE   ">"

IDENTIFICADOR   [a-z][a-zA-Z0-9]{0,15}
LITERALCADENA   \"[^\n"]*\"
CARACTER        \'[^\']\'

%%

{FIN_SENTENCIA}     { /*printf("Token: FIN_SENTENCIA\n");*/ return FIN_SENTENCIA; }
{LITERALCADENA}     { /*printf("Token: LITERALCADENA (%s)\n", yytext);*/ yylval.str = strdup(yytext); return LITERALCADENA; }
{CARACTER}          { /*printf("Token: CARACTER (%s)\n", yytext);*/ yylval.str = strdup(yytext); return CARACTER; }

{A_BINARIO}         { /*printf("Token: A_BINARIO\n");*/ return A_BINARIO; }
{A_TEXTO}           { /*printf("Token: A_TEXTO\n"); */return A_TEXTO; }
{IMPRIMIR}          { /*printf("Token: IMPRIMIR\n"); */return IMPRIMIR; }
{ES}                { /*printf("Token: ES\n"); */return ES; }
{ABRIR_BLOQUE}      { /*printf("Token: ABRIR_BLOQUE\n"); */return ABRIR_BLOQUE; }
{CERRAR_BLOQUE}     { /*printf("Token: CERRAR_BLOQUE\n"); */return CERRAR_BLOQUE; }

{IDENTIFICADOR}     {/* printf("Token: IDENTIFICADOR (%s)\n", yytext); */yylval.str = strdup(yytext); return IDENTIFICADOR; }
[a-z][a-zA-Z0-9]{16,} {
    printf("Error: Identificador demasiado largo (%s)\n", yytext);
    return -1;
}

\n                  { yylineno++; }
\t                  { /* ignorar tabulaciones */ }
" "                 { /* ignorar espacios */ }


%%