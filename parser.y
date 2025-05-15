%{
/*00219819 - MARIANA KOPPE PIERUCCI
 00243463 - VANESSA RIGHI COELHO*/
#include <stdio.h>
#include "asd.h"
#include <string.h>

int yylex(void);
void yyerror (char const *mensagem);
extern int get_line_number(void);
extern asd_tree_t *arvore;
%}
%debug

%define parse.error verbose

%start programa

%union {
  int intval;
  struct asd_tree* node;
  struct  svalor_lexico * valor_lexico;
}

%destructor { svalor_lexico_free($$); } <valor_lexico>

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
%token <valor_lexico> TK_ID TK_LI_INT TK_LI_FLOAT
%token TK_ER

// non terminals
%type <node> operando
%type <node> and
%type <node> igual_naoigual
%type <node> lista_de_elementos_wrapper
%type <node> comando_simples_chamada_de_funcao
%type <node> maior_menor
%type <node> acumulacao
%type <node> fator
%type <node> termo
%type <node> expressao
%type <node> comando_simples_comando_de_atribuicao
%type <node> sequencia_de_comandos_simples
%type <node> comando_simples
%type <node> variavel_inicializavel
%type <node> comando_simples_comandos_de_controle_de_fluxo
%type <node> declaracao_da_variavel
%type <node> comando_simples_comando_de_retorno
%type <node> bloco_de_comandos
%type <node> comando_simples_bloco_de_comandos
%type <node> construcao_condicional
%type <node> construcao_iterativa
%type <node> funcao
%type <node> cabecalho
%type <node> corpo
%type <node> sequencia_de_comandos_simples_possivelmente_vazia
%type <node> lista_de_elementos
%type <node> variavel
%type <node> nome_da_funcao
%type <node> lista_de_parametros_que_pode_ser_vazia
%type <node> lista_wrapper
%type <node> lista_de_parametros
%type <node> decl
%type <node> lista_de_argumentos
%type <node> argumento
%type <node> lista_de_argumentos_separados_por_virgula
%type <node> variavel_inicializacao
%type <node> tipo_inicializacao

%%


// Um programa na linguagem é composto por uma
// lista opcional de elementos

// Os elementos da lista são separados pelo operador
// vírgula e a lista é terminada pelo operador ponto-e-vírgula

// Cada elemento dessa lista é ou uma definição 
// de função ou uma declaração de variável.

programa
    : %empty
    | lista_de_elementos_wrapper
    {
        #ifdef DEBUG_MESSAGES
            printf(">programa: lista_de_elementos_wrapper\n");
        #endif
        // return the tree
        arvore = $1;
    } 
;

lista_de_elementos_wrapper
    :
    lista_de_elementos   ';'   
    {
        #ifdef DEBUG_MESSAGES
            printf(">lista_de_elementos_wrapper: lista_de_elementos ';'\n");
        #endif
        $$ = $1;
    } 
;

lista_de_elementos
    : variavel    
    {
        #ifdef DEBUG_MESSAGES
            printf("> variavel\n");
        #endif
    } 
    | funcao    
    {
        #ifdef DEBUG_MESSAGES
            printf("> funcao\n");
        #endif
        $$ = $1;
    } 
    | variavel ',' lista_de_elementos    
    {
        #ifdef DEBUG_MESSAGES
            printf("> lista_de_elementos ',' variavel\n");
        #endif
        // aqui a variavel pode ser vazia pois
        // nao incluo as decls
        if ($1 == NULL){
            $$ = $3;
        } else {
            asd_add_child($1, $3);
            $$ = $1;
        }
    }
    | funcao ',' lista_de_elementos      
    {
        #ifdef DEBUG_MESSAGES
            printf("> lista_de_elementos ',' funcao\n");
        #endif
        asd_add_child($1, $3);
        $$ = $1;
    } 
   
;

// variaveis
variavel
    : declaracao_da_variavel 
    {
        #ifdef DEBUG_MESSAGES
            printf("> variavel: declaracao_da_variavel\n");
        #endif
        asd_free($1);
        $$ = NULL;
    }

;

variavel_inicializavel
    : declaracao_da_variavel
    {
        #ifdef DEBUG_MESSAGES
            printf("> variavel_inicializavel: declaracao_da_variavel\n");
        #endif
        asd_free($1);
        $$ = NULL;
    }
    | declaracao_da_variavel  variavel_inicializacao
    {
        #ifdef DEBUG_MESSAGES
            printf("> declaracao_da_variavel  variavel_inicializacao\n");
        #endif
        asd_add_child($2, $1);
        $$ = $2;
    }
;

declaracao_da_variavel
    : TK_PR_DECLARE TK_ID TK_PR_AS tipo_da_variavel
     {
        #ifdef DEBUG_MESSAGES
            printf("> TK_PR_DECLARE TK_ID TK_PR_AS tipo_da_variavel\n");
        #endif
        // estou colocando o label na arvore, se nao precisar*
        // removo no nodo de cima

        // * nao precisaria porque se a variavel for apenas
        // declarada e nao inicializada
        // nao colocamos na arvore neste momento

        // colocando apenas o nome
        $$ = asd_new($2->value);
        // free o nome da variavel, no label
        svalor_lexico_free($2);
     }
;


tipo_da_variavel
    : TK_PR_INT
    | TK_PR_FLOAT
;


variavel_inicializacao
    : TK_PR_WITH tipo_inicializacao
    {
        $$ = asd_new("with");
        asd_add_child($$, 
            asd_new($2->label)
        );
        asd_free($2);
    }
    ;

tipo_inicializacao
    : TK_LI_INT
    {
        $$ = asd_new($1->value);
        svalor_lexico_free($1);
    }
    | TK_LI_FLOAT
    {
        $$ = asd_new($1->value);
        svalor_lexico_free($1);
    }
;

funcao
    : cabecalho corpo 
    {
        #ifdef DEBUG_MESSAGES
            printf(">funcao: cabecalho corpo\n");
            if ($2 == NULL) {printf("> o corpo eh vazio?s\n");}
            else{printf("> o corpo eh vazio?n\n");}
        #endif
        if ($2 != NULL) {
            asd_add_child($1, $2);
            
        }
        $$ = $1;
    }
;

corpo
    : bloco_de_comandos
;


cabecalho
    : nome_da_funcao TK_PR_RETURNS tipo_da_variavel
     lista_de_parametros_que_pode_ser_vazia TK_PR_IS
    {
        #ifdef DEBUG_MESSAGES
            printf("> cabecalho\n");
            printf("> nome_da_funcao TK_PR_RETURNS tipo_da_variavel lista_de_parametros_que_pode_ser_vazia TK_PR_IS\n");
            printf("%s\n", $1->label);
        #endif
        $$ = $1;
    }
;

nome_da_funcao
    : TK_ID 
    {
        $$ = asd_new($1->value);
        svalor_lexico_free($1);
    }
;

lista_de_parametros_que_pode_ser_vazia
    : %empty
    {
        #ifdef DEBUG_MESSAGES
            printf(">lista_de_parametros_que_pode_ser_vazia: empty\n");
        #endif
    }
    | lista_wrapper
;

lista_wrapper
    :
    TK_PR_WITH lista_de_parametros 
    {
        $$ = $2;
    }
;

lista_de_parametros
    :
    decl
    | lista_de_parametros ',' decl
;

decl
    :
    TK_ID TK_PR_AS tipo_de_parametro 
    {
        #ifdef DEBUG_MESSAGES
            printf(">decl: TK_ID TK_PR_AS tipo_de_parametro\n");
        #endif
        svalor_lexico_free($1);
    }
;

tipo_de_parametro
    : TK_PR_INT
    | TK_PR_FLOAT
;

bloco_de_comandos
    : '[' sequencia_de_comandos_simples_possivelmente_vazia ']'  {
        #ifdef DEBUG_MESSAGES
            printf("> '[' sequencia_de_comandos_simples_possivelmente_vazia ']'\n");
        #endif
        // even if its null
        $$ = $2;
    }

;


sequencia_de_comandos_simples_possivelmente_vazia
    : %empty
    {
        #ifdef DEBUG_MESSAGES
            printf(">sequencia_de_comandos_simples_possivelmente_vazia: %empty\n");
        #endif
        $$ = NULL;
    }

    | sequencia_de_comandos_simples 
    {
        #ifdef DEBUG_MESSAGES
            printf("> sequencia_de_comandos_simples\n");
        #endif
        $$ = $1;
    }
;

sequencia_de_comandos_simples
    : comando_simples 
    {
        #ifdef DEBUG_MESSAGES
            printf(">sequencia_de_comandos_simples: comando_simples\n");
            if (!($1 == NULL)) 
                  printf("%s\n", $1->label);
        #endif
        $$ = $1;
    }
    | comando_simples sequencia_de_comandos_simples {
        #ifdef DEBUG_MESSAGES
            printf("> comando_simples sequencia_de_comandos_simples\n");
            if (!($1 == NULL))
                printf("%s\n", $1->label);
            if (!($1 == NULL))
                asd_print($1);
            if (!($2 == NULL))
                asd_print($2);
        #endif
        if ($1 == NULL)
            $$ = $2;
        else if ($2 == NULL)
            $$ = $1;
        else
        {
            asd_add_child($1,$2);
            $$ = $1;
        }
    }
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
    {
        #ifdef DEBUG_MESSAGES
            printf("> TK_ID TK_PR_IS expressao\n");
            printf("%s\n", $1);
            printf("%s\n", $3->label);
        #endif
        $$ = asd_new("is");
        asd_add_child($$, 
            asd_new($1->value)
        );
        asd_add_child($$, $3);
        svalor_lexico_free($1);
    }
;

// chamada de funcao
comando_simples_chamada_de_funcao
    : TK_ID'(' lista_de_argumentos')' 
    {
        #ifdef DEBUG_MESSAGES
            printf("> comando_simples_chamada_de_funcao\n");
            printf("> TK_ID'(' lista_de_argumentos')'\n");
        #endif

        char *new_label;
        asprintf(&new_label, "call %s", $1->value);
        $$ = asd_new(new_label);

        // lista de argumentos pode ser vazio
        if ($3 != NULL)
            asd_add_child($$, $3);

        svalor_lexico_free($1);
        free(new_label);
    }
;

lista_de_argumentos
    : %empty
    {
        #ifdef DEBUG_MESSAGES
            printf("> lista_de_argumentos: empty\n");
        #endif
        $$ = NULL;
    }
    | lista_de_argumentos_separados_por_virgula
    { 
        #ifdef DEBUG_MESSAGES
            printf("lista_de_argumentos_separados_por_virgula\n");
        #endif
        $$ = $1;
    }
    ;

lista_de_argumentos_separados_por_virgula
    : argumento
    {
        $$ = $1;
    }
    | argumento ',' lista_de_argumentos_separados_por_virgula 
    {
        #ifdef DEBUG_MESSAGES
            printf(">argumento lista_de_argumentos_separados_por_virgula\n");
        #endif
        asd_add_child($1, $3);
        $$ = $1;
    }
;

argumento
    : expressao
;

comando_simples_comando_de_retorno
    : TK_PR_RETURN expressao TK_PR_AS tipo_da_variavel 
    {
        #ifdef DEBUG_MESSAGES
            printf("> TK_PR_RETURN expressao TK_PR_AS tipo_da_variavel\n");
        #endif
        $$ = asd_new("return");
        asd_add_child($$, $2);
    }
;

// controle de fluxo
comando_simples_comandos_de_controle_de_fluxo
    : construcao_condicional
    | construcao_iterativa
;

// if
construcao_condicional
    : TK_PR_IF '(' expressao ')' bloco_de_comandos 
    {
        #ifdef DEBUG_MESSAGES
            printf("> if simples \n");
            printf("> TK_PR_IF '(' expressao ')' bloco_de_comandos \n");
        #endif
        $$ = asd_new("if");
        asd_add_child($$, $3);
        asd_add_child($$, $5);

    }


    | TK_PR_IF '(' expressao ')' bloco_de_comandos TK_PR_ELSE bloco_de_comandos
    {
        #ifdef DEBUG_MESSAGES
            printf("> if com else \n");
            printf("> TK_PR_IF '(' expressao ')' bloco_de_comandos TK_PR_ELSE bloco_de_comandos \n");
        #endif

        $$ = asd_new("if");
        asd_add_child($$, $3);
        asd_add_child($$, $5);
        asd_add_child($$, $7);
    }

;

// while
construcao_iterativa
    : TK_PR_WHILE '(' expressao ')' bloco_de_comandos 
    {
        #ifdef DEBUG_MESSAGES
            printf("> TK_PR_WHILE '(' expressao ')' bloco_de_comandos\n");
        #endif
        $$ = asd_new("while");
        asd_add_child($$, $3);
        asd_add_child($$, $5);
    }
;


expressao
    : and
    | expressao '|' and
    {
        $$ = asd_new("|");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
;

and
    : igual_naoigual
    | and '&' igual_naoigual {
        #ifdef DEBUG_MESSAGES
            printf(">&\n");
            printf("%s\n", $1->label);
            printf("%s\n", $3->label);
        #endif
        $$ = asd_new("&");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
;

igual_naoigual
    : maior_menor
    | igual_naoigual TK_OC_NE maior_menor
    {
        $$ = asd_new("!=");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
    | igual_naoigual TK_OC_EQ maior_menor 
    {
        #ifdef DEBUG_MESSAGES
            printf("> igual_naoigual TK_OC_EQ maior_menor\n");
            printf("%s\n", $3->label);
        #endif
        $$ = asd_new("==");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
;

maior_menor
    : acumulacao
    | maior_menor TK_OC_GE acumulacao
    {
        $$ = asd_new(">=");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
    | maior_menor TK_OC_LE acumulacao
        {
        $$ = asd_new("<=");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
    | maior_menor '>' acumulacao
    {
        $$ = asd_new(">");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
    | maior_menor '<' acumulacao
    {
        $$ = asd_new("<");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
;

acumulacao
    : fator
    | acumulacao '+' fator
    {
        #ifdef DEBUG_MESSAGES
            printf("> acumulacao '+' fator\n");
            printf("%s\n", $1->label);
            printf("%s\n", $3->label);
        #endif
        $$ = asd_new("+");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
    | acumulacao '-' fator
        {
        $$ = asd_new("-");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
;

fator
    : termo
    | fator '*' termo
    {
        #ifdef DEBUG_MESSAGES
            printf("> acumulacao '*' fator\n");
            printf("%s\n", $1->label);
            printf("%s\n", $3->label);
        #endif
        $$ = asd_new("*");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
    | fator '/' termo
    {
        $$ = asd_new("/");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
    | fator '%' termo
    {
        $$ = asd_new("%");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
    }
;

termo
    : operando
    | '(' expressao ')' {
        #ifdef DEBUG_MESSAGES
            printf(">'(' expressao ')'\n");
            printf("%s\n", $2->label);
        #endif
        $$ = $2;

    }
    | '+' termo
    {
        #ifdef DEBUG_MESSAGES
            printf(">'+' termo\n");
            printf("%s\n", $2->label);
        #endif
        $$ = asd_new("+");
        asd_add_child($$, $2);

    }

    | '-' termo
    {
        #ifdef DEBUG_MESSAGES
            printf(">'-' termo\n");
            printf("%s\n", $2->label);
        #endif
        $$ = asd_new("-");
        asd_add_child($$, $2);

    }

    | '!' termo
    {
        #ifdef DEBUG_MESSAGES
            printf(">'!' termo\n");
            printf("%s\n", $2->label);
        #endif
        $$ = asd_new("!");
        asd_add_child($$, $2);

    }
;


operando
    : 
    comando_simples_chamada_de_funcao
    | TK_ID
    {
        #ifdef DEBUG_MESSAGES
            printf("> TK_ID\n");
            printf("> %s\n", ($1));
        #endif

        $$ = asd_new($1->value);
        svalor_lexico_free($1);
    }


    | TK_LI_FLOAT
    {
        #ifdef DEBUG_MESSAGES
            printf("> TK_LI_FLOAT\n");
            printf("> %s\n", ($1));
        #endif

        $$ = asd_new($1->value);
        svalor_lexico_free($1);
    }


    | TK_LI_INT {
        #ifdef DEBUG_MESSAGES
            printf("> TK_LI_INT\n");
            printf("> %s\n", ($1));
        #endif

        $$ = asd_new($1->value);
        svalor_lexico_free($1);
    }
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
