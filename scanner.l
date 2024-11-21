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

{FIN_SENTENCIA}     { return FIN_SENTENCIA; }
{LITERALCADENA}     { yylval.str = strdup(yytext); return LITERALCADENA; }
{CARACTER}          { yylval.str = strdup(yytext); return CARACTER; }

{A_BINARIO}         { return A_BINARIO; }
{A_TEXTO}           { return A_TEXTO; }
{IMPRIMIR}          { return IMPRIMIR; }
{ES}                { return ES; }
{ABRIR_BLOQUE}      { return ABRIR_BLOQUE; }
{CERRAR_BLOQUE}     { return CERRAR_BLOQUE; }

{IDENTIFICADOR}     { yylval.str = strdup(yytext); return IDENTIFICADOR; }
[a-z][a-zA-Z0-9]{16,} {
    printf("Error: Identificador demasiado largo (%s)\n", yytext);
    return -1;
}

\n                  { yylineno++; }
\t                  {  }
" "                 {  }

%%