%{
/*00219819 - MARIANA KOPPE PIERUCCI
 00243463 - VANESSA RIGHI COELHO*/
#include <stdio.h>

int yylex(void);
void yyerror (char const *mensagem);
extern int get_line_number(void);
%}

%debug

%define parse.error verbose




%precedence MAIS_UNARIO
%precedence MENOS_UNARIO

%start programa

/*
DEFINICAO DE TOKENS
*/
%token TK_PR_AS
%token TK_PR_DECLARE
%token TK_PR_ELSE
%token TK_PR_FLOAT
%token TK_PR_IF
%token TK_PR_INT
%token TK_PR_IS
%token TK_PR_RETURN
%token TK_PR_RETURNS
%token TK_PR_WHILE
%token TK_PR_WITH
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_ID
%token TK_LI_INT
%token TK_LI_FLOAT
%token TK_ER

%%


// Um programa na linguagem é composto por uma
// lista opcional de elementos

// Os elementos da lista são separados pelo operador vírgula e a lista é terminada pelo operador ponto-e-vírgula

// Cada elemento dessa lista é ou uma definição 
// de função ou uma declaração de variável.

programa
    :
    %empty
    | lista_de_elementos_wrapper   
;

lista_de_elementos_wrapper
    :
    lista_de_elementos   ';'   
;

lista_de_elementos
    : 
    variavel
    | funcao
    | lista_de_elementos ',' variavel
    | lista_de_elementos ',' funcao
   
;

// variaveis
variavel
    : 
     declaracao_da_variavel 

;

variavel_inicializavel
    :
    declaracao_da_variavel
    | declaracao_da_variavel  variavel_inicializacao
;

declaracao_da_variavel
    :
     TK_PR_DECLARE TK_ID TK_PR_AS tipo_da_variavel
;


tipo_da_variavel
    : TK_PR_INT
    | TK_PR_FLOAT
;


variavel_inicializacao
    : TK_PR_WITH tipo_inicializacao
    ;

tipo_inicializacao
    : TK_LI_INT
    | TK_LI_FLOAT
;

// funcoes
funcao
    :
    cabecalho corpo
;

corpo
    :
     bloco_de_comandos
;


cabecalho
    : nome_da_funcao TK_PR_RETURNS tipo_da_variavel
     lista_de_parametros_que_pode_ser_vazia TK_PR_IS

;

nome_da_funcao
    : TK_ID
;


// argc as int, argv as int

lista_de_parametros_que_pode_ser_vazia
    : %empty
    | lista_wrapper
;

lista_wrapper
    :
    TK_PR_WITH lista_de_parametros
;

lista_de_parametros
    :
    decl
    | lista_de_parametros ',' decl
;

decl
    :
    TK_ID TK_PR_AS tipo_de_parametro
;

tipo_de_parametro
    : TK_PR_INT
    | TK_PR_FLOAT
;

// bloco de comandos
bloco_de_comandos
    : 
    '[' sequencia_de_comandos_simples_possivelmente_vazia ']'

;



sequencia_de_comandos_simples_possivelmente_vazia
    : %empty
    | sequencia_de_comandos_simples
;

sequencia_de_comandos_simples
    : comando_simples 
    | sequencia_de_comandos_simples comando_simples 
;


// Comandos Simples
// bloco de comandos
// declaração de variável
// comando de atribuição
// chamada de função
// comando de retorno
// comandos de controle de fluxo

comando_simples
    : 
    comando_simples_bloco_de_comandos
    | variavel_inicializavel
    | comando_simples_comando_de_atribuicao
    | comando_simples_chamada_de_funcao
    | comando_simples_comando_de_retorno
    | comando_simples_comandos_de_controle_de_fluxo
;

// !importante
// Um bloco de comandos
// é considerado como um comando único simples
// e pode ser utilizado em qualquer construção que
// aceite um comando simples

comando_simples_bloco_de_comandos
    : bloco_de_comandos
;

comando_simples_comando_de_atribuicao
    : TK_ID TK_PR_IS expressao
;

// chamada de funcao
comando_simples_chamada_de_funcao
    : TK_ID'(' lista_de_argumentos')'
;

lista_de_argumentos
    : %empty
    | argumento
    | lista_de_argumentos_separados_por_virgula argumento
;

lista_de_argumentos_separados_por_virgula
    : argumento ','
    | lista_de_argumentos_separados_por_virgula argumento ','
;

argumento
    : expressao
;

// retorno
comando_simples_comando_de_retorno
    : TK_PR_RETURN expressao TK_PR_AS tipo_da_variavel
;

// controle de fluxo
comando_simples_comandos_de_controle_de_fluxo
    : construcao_condicional
    | construcao_iterativa
;

// isso eh o problema do dangling else
// TODO review...

// if
construcao_condicional
    : TK_PR_IF '(' expressao ')' bloco_de_comandos 
    | TK_PR_IF '(' expressao ')' bloco_de_comandos TK_PR_ELSE bloco_de_comandos
;

// while
construcao_iterativa
    : TK_PR_WHILE '(' expressao ')' bloco_de_comandos
;


expressao
    : and
    | expressao '|' and
;

and
    : igual_naoigual
    | and '&' igual_naoigual
;

igual_naoigual
    : maior_menor
    | igual_naoigual TK_OC_NE maior_menor
    | igual_naoigual TK_OC_EQ maior_menor
;

maior_menor
    : acumulacao
    | maior_menor TK_OC_GE acumulacao
    | maior_menor TK_OC_LE acumulacao
    | maior_menor '>' acumulacao
    | maior_menor '<' acumulacao
;

acumulacao
    : fator
    | acumulacao '+' fator
    | acumulacao '-' fator
;

fator
    : termo
    | fator '*' termo
    | fator '/' termo
    | fator '%' termo
;

termo
    : operando
    | '(' expressao ')'
    | '+' termo %prec MAIS_UNARIO
    | '-' termo %prec MENOS_UNARIO
    | '!' termo
;


operando
    : 
    comando_simples_chamada_de_funcao
    | TK_ID
    | TK_LI_FLOAT
    | TK_LI_INT
;

%%

// funcao de erro para debug
void yyerror (char const *s) {
    extern int yylineno;
    extern int yychar;
    extern char *yytext;

    extern const char *const yytname[];

    if (yychar >= 0)
    {
        fprintf(stderr, "Erro na linha %d: %s. Token atual: '%s'",
                yylineno, s, yytext);

        if (yychar < (sizeof(yytname) / sizeof(yytname[0])) )
            fprintf(stderr, " (%s)", 
            yytname[yychar]);

        printf("\n");
    }

    else
        fprintf(stderr, "Erro na linha %d: %s. Token atual: <EOF or invalid>\n",
                yylineno, s);
}
