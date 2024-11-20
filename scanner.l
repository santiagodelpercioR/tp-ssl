%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

CONST_INTEGER   (-?[1-9][0-9]{0,4})|0
FIN_SENTENCIA   ["."]

A_BINARIO       "a_binario"
A_TEXTO         "a_texto"
IMPRIMIR        "imprimir"
ES              "es"

IDENTIFICADOR   [a-zA-Z_][a-zA-Z0-9_]*
LITERALCADENA   \"[^\n"]*\"
CARACTER        \'[^\']\'

%%

{FIN_SENTENCIA}     { printf("Token: FIN_SENTENCIA\n"); return FIN_SENTENCIA; }
{CONST_INTEGER}     { printf("Token: CONST_INTEGER (%s)\n", yytext); }
{LITERALCADENA}     { printf("Token: LITERALCADENA (%s)\n", yytext); yylval.str = strdup(yytext); return LITERALCADENA; }
{CARACTER}          { printf("Token: CARACTER (%s)\n", yytext); yylval.str = strdup(yytext); return CARACTER; }

{A_BINARIO}         { printf("Token: A_BINARIO\n"); return A_BINARIO; }
{A_TEXTO}           { printf("Token: A_TEXTO\n"); return A_TEXTO; }
{IMPRIMIR}          { printf("Token: IMPRIMIR\n"); return IMPRIMIR; }
{ES}                { printf("Token: ES\n"); return ES; }

{IDENTIFICADOR}     { printf("Token: IDENTIFICADOR (%s)\n", yytext); yylval.str = strdup(yytext); return IDENTIFICADOR; }

\n                  { yylineno++; }
\t                  { /* ignorar tabulaciones */ }
" "                 { /* ignorar espacios */ }

%%
