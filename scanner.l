%{
 /*00219819 - MARIANA KOPPE PIERUCCI
 00243463 - VANESSA COELHO*/
#include "tokens.h"

int get_line_number(void);

%}

  /* 
  ** `%option noyywrap` Makes the scanner not call `yywrap()` upon an end-of-file, 
  ** but simply assume that there are no more files to scan
  ** (until the user points yyin at a new file and calls `yylex()` again).
  **
  ** When the scanner receives an end-of-file indication from YY_INPUT,
  ** it then checks the `yywrap()` function. If `yywrap()` returns false (zero),
  ** then it is assumed that the function has gone ahead and set up yyin to
  ** point to another input file, and scanning continues. If it returns true
  ** (non-zero), then the scanner terminates, returning 0 to its caller.
  ** Note that in either case, the start condition remains unchanged;
  ** it does not revert to INITIAL.
  ** 
  ** If you do not supply your own version of `yywrap()`, then you must either
  ** use `%option noyywrap` (in which case the scanner behaves as though `yywrap()`
  ** returned 1), or you must link with `-lfl` to obtain the default version of
  ** the routine, which always returns 1. 
  */
%option noyywrap

  /* 
  ** Directs flex to generate a scanner that maintains the number of the current line
  ** read from its input in the global variable `yylineno`.
  */
%option yylineno

  /* Definição de quais são os caracteres especiais */
ESPECIAL [!*/%+-<>[]()=,;&|]


%%

  /*
  ** Definição dos tokens a serem reconhecidos.
  ** 
  ** Existem  tokens  que  correspondem  a  caracteres  particulares, como vírgula,
  ** ponto-e-vírgula, parênteses, para os quais é mais conveniente usar seu próprio
  ** código ASCII (convertido  para  inteiro)  como  valor  de  retorno  que  os 
  ** identifica.  
  **
  ** Para os tokens compostos, como palavras reservadas e identificadores, utiliza-se
  ** uma constante, conforme o arquivo tokens.h fornecido, para representá-los.
  **
  ** Os tokens se enquadram em diferentes categorias: 
  **   (1) palavras reservadas da linguagem;
  **   (2) caracteres especiais;
  **   (3) operadores compostos; 
  **   (4) identificadores;
  **   (5) literais;
  */

  /* (1) -> Palavras reservadas da linguagem */
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
 /* "bool"       return TK_PR_BOOL; (não precisa ter de acordo com a definição)

 /* (2) -> Caracteres especiais */
{ESPECIAL}   return yytext[0];

  /* (3) -> Operadores compostos */
"<="         return TK_OC_LE;
">="         return TK_OC_GE;
"=="         return TK_OC_EQ;
"!="         return TK_OC_NE;
 /*"&"          return TK_OC_AND;
"|"          return TK_OC_OR; (não precisa)*/

  /* (5) -> Literais */
[0-9]+              return TK_LIT_INT;
[0-9]*\.[0-9]+      return TK_LIT_FLOAT;
    /* "true"              return TK_LIT_TRUE;    // Declarados aqui acima do (4) para não serem acidentalmente reconhecidos como identificadores!
"false"             return TK_LIT_FALSE; (NÃO VAI PRECISAR) */   // Declarados aqui acima do (4) para não serem acidentalmente reconhecidos como identificadores!

  /* (4) -> Identificadores */
[a-z_][a-z_0-9]*    return TK_ID;

  /* Ignorar whitespace */
  /* 
  ** In addition to characters and ranges of characters, character classes can also contain character class expressions.
  ** These are expressions enclosed inside `[:` and `:]` delimiters (which themselves must appear between the `[` and `]` 
  ** of the character class; other elements may occur inside the character class, too). The valid expressions are:
  **
  ** [:alnum:] [:alpha:] [:blank:]
  ** [:cntrl:] [:digit:] [:graph:]
  ** [:lower:] [:print:] [:punct:]
  ** [:space:] [:upper:] [:xdigit:]
  **
  ** These expressions all designate a set of characters equivalent to the corresponding standard C `isXXX' function.
  ** Reference: http://man.he.net/man3/isspace
  */
[[:space:]]

  /* Ignorar comentários single-line. */
"//".*


  /* Qualquer outra coisa: lançar erro */
.       return TK_ER;

%%

int get_line_number() {
  return yylineno;
}
