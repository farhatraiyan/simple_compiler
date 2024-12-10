%{
#include <string.h>
#include "parse_tree.h"
#include "proj_bison.tab.h"
%}

blanks          [ \t\n]+
identifier      [_a-zA-Z0-9]+
num             (0|[1-9][0-9]*)
boollit         (false|true)
op2             ("*"|"div"|"mod")
op3             ("+"|"-")
op4             ("="|"!="|"<"|">"|"<="|">=")

%%

{blanks}        { /* ignore */ }

"("             return(LP);
")"             return(RP);
":="            return(ASGN);
";"             return(SC);

"if"            return(IF);
"then"          return(THEN);
"else"          return(ELSE);
"begin"         return(BEGIN_TOK);
"end"           return(END);
"while"         return(WHILE);
"do"            return(DO);
"program"       return(PROGRAM);
"var"           return(VAR);
"as"            return(AS);
"int"           return(INT);
"bool"          return(BOOL);

"writeInt"      return(WRITEINT);
"readInt"       return(READINT);

{num}           {
                    yylval.ival = atoi(yytext);
                    return(NUM);
                }

{boollit}       {
                    yylval.bval = (strcmp(yytext, "true") == 0);
                    return(BOOLLIT);
                }

{identifier}    {
                    yylval.sval = malloc(strlen(yytext) + 1);
                    strcpy(yylval.sval, yytext);
                    return(IDENTIFIER);
                }

{op2}    {
                    yylval.sval = malloc(strlen(yytext) + 1);
                    strcpy(yylval.sval, yytext);
                    return(OP2);
                }

{op3}    {
                    yylval.sval = malloc(strlen(yytext) + 1);
                    strcpy(yylval.sval, yytext);
                    return(OP3);
                }

{op4}    {
                    yylval.sval = malloc(strlen(yytext) + 1);
                    strcpy(yylval.sval, yytext);
                    return(OP4);
                }
