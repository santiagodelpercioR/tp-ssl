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

%%

{FIN_SENTENCIA}     { return FIN_SENTENCIA; }
{CONST_INTEGER}     { printf("\nCONST_INTEGER (%s)", yytext); }
{LITERALCADENA}     { yylval.str = strdup(yytext); return LITERALCADENA; }

{A_BINARIO}         { return A_BINARIO; }
{A_TEXTO}           { return A_TEXTO; }
{IMPRIMIR}          { return IMPRIMIR; }
{ES}                { return ES; }

{IDENTIFICADOR}     { yylval.str = strdup(yytext); return IDENTIFICADOR; }

\n                  { yylineno++; }
\t                  { /* ignore tabs */ }
" "                 { /* ignore spaces */ }

%%
