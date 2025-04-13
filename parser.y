%{
#include <stdio.h>

int yylex(void);
void yyerror (char const *mensagem);
extern int get_line_number(void);
%}

%define parse.error verbose

%start programa

/*
** A seguir, definição dos tokens terminais.
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

/* 
%precedence IF_SEM_ELSE
%precedence IF_COM_ELSE

%precedence MENOS_UNARIO

Um programa na linguagem é composto por uma
lista opcional de elementos. Os elementos da lista
são separados pelo operador vírgula e a lista é ter-
minada pelo operador ponto-e-vírgula. Cada ele-
mento dessa lista é ou uma definição de função ou
uma declaração de variável
*/
programa
    : %empty
    | lista_de_elementos      
;

lista_de_elementos
    : variavel
    | funcao
    | lista_de_elementos variavel
    | lista_de_elementos funcao
;

/* 
Declaração de Variável: Consiste no token
TK_PR_DECLARE seguido do token TK_ID, que
é por sua vez seguido do token TK_PR_AS e
enfim seguido do tipo. O tipo pode ser ou
o token TK_PR_FLOAT ou o token TK_PR_INT.
Uma variável pode ser opcionalmente iniciali-
zada caso sua declaração seja seguida do token
TK_PR_WITH e de um literal. Um literal pode ser
ou o token TK_LI_INT ou o token TK_LI_FLOAT
*/
variavel
    :  declaracao_da_variavel',' tipo_da_variavel
;

/* 
** [...] O tipo pode ser int, float e bool. [...]
*/
tipo_da_variavel
    : TK_PR_INT
    | TK_PR_FLOAT
;

/* [...] lista composta de pelo menos um nome de variável
** (identificador) SEPARADAS POR PONTO-E-VÍRGULA [...]
NÃO SEI SE TÁ CERTO
*/
declaracao_da_variavel
    :  declaracao_da_variavel ';' TK_PR_DECLARE TK_ID TK_PR_AS
    | TK_PR_DECLARE TK_ID TK_PR_AS
;

inicializa_variavel
        : TK_PR_WITH tipo_da_variavel
        ;


/* 
** Cada função é definida por um cabeçalho e um
** corpo, sendo que esta definição não é terminada
** por vírgula. [...] O corpo da função é
** um bloco de comandos.
*/
funcao
    : cabecalho corpo
;

corpo
    : bloco_de_comandos
;

/* 
** [...] O cabeçalho consiste na lista de pa-
** râmetros, o operador composto TK_OC_OR, o tipo
** de retorno seguido da barra e o nome da função. [...]
** A lista de parâmetros é dada entre parênteses [...]
*/
cabecalho
    : '(' lista_de_parametros_que_pode_ser_vazia ')' TK_OC_OR tipo_de_retorno '/' nome_da_funcao
;

nome_da_funcao
    : TK_IDENTIFICADOR
;

/*
** [...] Tal tipo pode ser int, float e bool. [...]
*/
tipo_de_retorno
    : TK_PR_INT
    | TK_PR_FLOAT
;

/*
** [...] A lista de parâmetros é [...] composta por 
** zero ou mais parâmetros de entrada, separados por
** ponto-e-vírgula. Cada parâmetro é definido pelo seu
** tipo e nome. [...]
*/
lista_de_parametros_que_pode_ser_vazia
    : %empty
    | tipo_de_parametro nome_de_parametro
    | lista_de_parametros tipo_de_parametro nome_de_parametro
;

lista_de_parametros
    : tipo_de_parametro nome_de_parametro ';'
    | lista_de_parametros tipo_de_parametro nome_de_parametro ';'
;

tipo_de_parametro
    : TK_PR_INT
    | TK_PR_FLOAT
;

nome_de_parametro
    : TK_ID
;

/*
** Um bloco de comandos é definido entre chaves,
** e consiste em uma sequência, possivelmente va-
** zia, de comandos simples cada um terminado
** por vírgula. [...]
*/
bloco_de_comandos
    : '{' sequencia_de_comandos_simples_possivelmente_vazia '}'
;

sequencia_de_comandos_simples_possivelmente_vazia
    : %empty
    | sequencia_de_comandos_simples
;

sequencia_de_comandos_simples
    : comando_simples ','
    | sequencia_de_comandos_simples comando_simples ','
;

/*
** (3.4) Comandos Simples
** (A) Bloco de comandos
** (B) Declaração de variável
** (C) Comando de atribuição
** (D) Chamada de função
** (E) Comando de retorno
** (F) Comandos de controle de fluxo
*/
comando_simples
    : comando_simples_bloco_de_comandos
    | comando_simples_declaracao_de_variavel
    | comando_simples_comando_de_atribuicao
    | comando_simples_chamada_de_funcao
    | comando_simples_comando_de_retorno
    | comando_simples_comandos_de_controle_de_fluxo
;

/*
** (A) Bloco de comandos
**
** [...] Um bloco de comandos é considerado como
** um comando único simples, recursivamente,
** e pode ser utilizado em qualquer construção
** que aceite um comando simples.
*/
comando_simples_bloco_de_comandos
    : bloco_de_comandos
;

/*
** (B) Declaração de variável
**
** Consiste no tipo da variável seguido de uma 
** lista composta de pelo menos um nome de variável
** (identificador) separadas por ponto-e-vírgula.
** Os tipos podem ser aqueles descritos na seção
** sobre variáveis globais.
*/
comando_simples_declaracao_de_variavel
    : tipo_da_variavel_local lista_de_variaveis_locais
;

tipo_da_variavel_local
    : tipo_da_variavel_global
;

lista_de_variaveis_locais
    : TK_IDENTIFICADOR
    | lista_de_variaveis_locais_separadas_por_ponto_e_virgula TK_IDENTIFICADOR
;

lista_de_variaveis_locais_separadas_por_ponto_e_virgula
    : TK_IDENTIFICADOR ';'
    | lista_de_variaveis_locais_separadas_por_ponto_e_virgula TK_IDENTIFICADOR ';'
;

/*
** (C) Comando de atribuição
**
** O comando de atribuição consiste em um
** identificador seguido pelo caractere de
** igualdade seguido por uma expressão.
*/
comando_de_atribuicao
    : TK_ID TK_PR_IS '=' expressao
;

/*
** (D) Chamada de função
**
** Uma chamada de função consiste no nome da função,
** seguida de argumentos entre parênteses separados
** por ponto-e-vírgula. Um argumento pode ser uma expressão.
*/
chamada_de_funcao
    : TK_ID'(' lista_de_argumentos')'
;

lista_de_argumentos
    : %empty
    | argumento
    | lista_de_argumentos_separados_por_virgula argumento
;

lista_de_argumentos_separados_por__virgula
    : argumento ','
    | lista_de_argumentos_separados_por_virgula argumento ','
;

argumento
    : expressao
;

/*
** (E) Comando de retorno
**
** Trata-se do token return seguido de uma expressão.
*/
comando_de_retorno
    : TK_PR_RETURN expressao TK_PR_AS tipo_da_variavel
;

/*
** (F) Comandos de controle de fluxo
**
** A linguagem
** possui uma construção condicional e uma itera-
** tiva para controle estruturado de fluxo. A condici-
** onal consiste no token if seguido de uma expres-
** são entre parênteses e então por um bloco de co-
** mandos obrigatório. O else, sendo opcional, é se-
** guido de um bloco de comandos, obrigatório caso
** o else seja empregado. Temos apenas uma cons-
** trução de repetição que é o token while seguido
** de uma expressão entre parênteses e de um bloco
** de comandos.
*/
comando_simples_comandos_de_controle_de_fluxo
    : construcao_condicional
    | construcao_iterativa
;

/*
** A condicional consiste no token if seguido de uma
** expressão entre parênteses e então por um bloco de
** comandos obrigatório. O else, sendo opcional, é se-
** guido de um bloco de comandos, obrigatório caso
** o else seja empregado.
*/
construcao_condicional
    : TK_PR_IF '(' expressao ')' bloco_de_comandos %prec IF_SEM_ELSE
    | TK_PR_IF '(' expressao ')' bloco_de_comandos TK_PR_ELSE bloco_de_comandos %prec IF_COM_ELSE
;

/*
** Temos apenas uma construção de repetição que é
** o token while seguido de uma expressão entre
** parênteses e de um bloco de comandos.
*/
construcao_iterativa
    : TK_PR_WHILE '(' expressao ')' bloco_de_comandos
;

/*
** (3.5) Expressões
**
** Expressões tem operandos e operadores, sendo
** este opcional. Os operandos podem ser (a) identi-
** ficadores, (b) literais e (c) chamada de função. As
** expressões podem ser formadas recursivamente
** pelo emprego de operadores. Elas também permi-
** tem o uso de parênteses para forçar uma associati-
** vidade ou precedência diferente daquela tradicio-
** nal. A associatividade é à esquerda (portanto im-
** plemente recursão à esquerda nas regras gramati-
** cais).
**
** As operações podem ser, em ordem descendente
** de precedência:
**
** Binárias:
**  OR
**  AND
**  NE EQ
**  GE LE > <
**  - +
**  % / *
**
** Unárias:
**  ! -
**  ()
**
** A resolução de conflitos foi feita com base na explicação
** em https://efxa.org/2014/05/17/techniques-for-resolving-common-grammar-conflicts-in-parsers/
*/
expressao
    : and
    | expressao TK_OC_OR and
;

and
    : igual_naoigual
    | and TK_OC_AND igual_naoigual
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
    | '!' termo
    | '-' termo %prec MENOS_UNARIO
;

/*
** Os operandos podem ser (a) identificadores,
** (b) literais e (c) chamada de função.
*/
operando
    : TK_ID
    | TK_LIT_FLOAT
    | TK_LIT_INT
    | comando_simples_chamada_de_funcao
;

%%

/*
** Ref.: https://www.gnu.org/software/bison/manual/bison.html#Error-Reporting-Function
*/
void yyerror (char const *s) {
    fprintf(stderr, "\nErro de sintaxe detectado. Linha: %d\n", get_line_number());
    fprintf(stderr, "%s\n", s);
}
