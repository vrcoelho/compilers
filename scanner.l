%{
 /*00219819 - MARIANA KOPPE PIERUCCI
 00243463 - VANESSA RIGHI COELHO*/
// #include "tokens.h"
#include "parser.tab.h"

int get_line_number(void);

%}

%option noyywrap yylineno

%%

 /* palavras reservadas */
"as"         return TK_PR_AS;
"declare"    return TK_PR_DECLARE;  
"else"       return TK_PR_ELSE;
"float"      return TK_PR_FLOAT;
"if"         return TK_PR_IF;
"int"        return TK_PR_INT;
"is"         return TK_PR_IS;
"return"     return TK_PR_RETURN; 
"returns"    return TK_PR_RETURNS;
"while"      return TK_PR_WHILE;
"with"       return TK_PR_WITH; 

 /* operadores compostos */
"<="         return TK_OC_LE;
">="         return TK_OC_GE;
"=="         return TK_OC_EQ;
"!="         return TK_OC_NE;

 /* caracteres especiais */
[\!\*\%\+\-\<\>\=\&\;\/\,]|[\(\)\[\]\|]  return yytext[0];

 /* literal float */
[0-9]*\.[0-9]+      return TK_LI_FLOAT;

 /* literal int */
[0-9]+             return TK_LI_INT;

 /* identificadores */
[a-z_][a-z_0-9]*    return TK_ID;


[[:space:]]+   { /* Ignore whitespace */ }

"//".*  { /* Ignore comments */ }

.   { return TK_ER; }

%%

int get_line_number() {
  return yylineno;
}
