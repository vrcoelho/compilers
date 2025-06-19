%{
/*00219819 - MARIANA KOPPE PIERUCCI
 00243463 - VANESSA RIGHI COELHO*/

/*
OLA PROFESSOR

O SEGUINTE CODIGO NO MOMENTO NAO ESTA SENDO 
CAPAZ DE RECONHECER OS TIPOS, LOGO NAO EH CAPAZ
DE IDENTIFICAR OS SEGUINTES ERROS:
- ERR_WRONG_TYPE
- ERR_WRONG_TYPE_ARGS

INFELIZMENTE NAO CONSEGUI RESOLVER OS LEAKS ENVOLVIDOS
EM ASSOCIAR OS TIPOS AOS NODOS.
IREI ARRUMAR ESTE PROBLEMA DURANTE A SEMANA, PARA O PROXIMO
ROUND.

O CODIGO TAMBEM SERA REFATORADO, PARA REMOVER A QUANTIDADE
DE CODIGO PRESENTE DENTRO DAS REGRAS SEMANTICAS.

*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "asd.h"
#include "internals.h"
#include "errors.h"

int yylex(void);
void yyerror (char const *mensagem);
extern int get_line_number(void);
extern asd_tree_t *arvore;

extern stack_symbol_table* stack_of_tables;
extern int n_args;
extern int n_args_on_call;

int flag_function_just_created_scope = 0;

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
%type <node> elemento
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

%type <intval> tipo_da_variavel tipo_de_parametro

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
        // return the tree
        arvore = $1;
    } 
;

lista_de_elementos_wrapper
    :
    lista_de_elementos   ';'   
    {
        $$ = $1;
    } 
;

lista_de_elementos
    : elemento
    | elemento ',' lista_de_elementos
    {
        // ambos elemento e lista_de_elementos podem ser
        // vazias pois nao incluo as decls
        if (($1 != NULL) && ($3 != NULL))
            asd_add_child($1, $3);
            
        if ($1 != NULL)
            $$ = $1;
        else if ($3 != NULL)
            $$ = $3;
    }
;

elemento
    : variavel
    | funcao
;

// variaveis
variavel
    : declaracao_da_variavel 
    {
        asd_free($1);
        $$ = NULL;
    }
;

variavel_inicializavel
    : declaracao_da_variavel
    {
        asd_free($1);
        $$ = NULL;
    }
    | declaracao_da_variavel  variavel_inicializacao
    {
        asd_add_child($2, $1);
        $$ = $2;
    }
;

declaracao_da_variavel
    : TK_PR_DECLARE TK_ID TK_PR_AS tipo_da_variavel
     {
        // estou colocando o label na arvore, se nao precisar*
        // removo no nodo de cima

        // * nao precisaria porque se a variavel for apenas
        // declarada e nao inicializada
        // nao colocamos na arvore neste momento

        // colocando apenas o nome
        $$ = asd_new($2->value);
        // free o nome da variavel, no label
        

        // actually I need to check if variable name does not
        // already exists
        int r = search_name_taken_on_stack(stack_of_tables, $2->value);
        if (r == 1)
        {
            // then it was already declared either
            // as a variable or a function
            free_stack_and_all_tables(stack_of_tables);
            declared_error_message($2->value);
            svalor_lexico_free($2);
            exit(ERR_DECLARED);
        }

        // if not used yet, we register to the current table
        register_variable_to_tableofc(
            stack_of_tables->current_table, 
            $2->value, 
            $4);     

        svalor_lexico_free($2);
    }
;


tipo_da_variavel
    : TK_PR_INT
    {
        $$ = integer;
    }
    | TK_PR_FLOAT
    {
        $$ = floatpoint;
    }
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
        if ($2 != NULL) {
            asd_add_child($1, $2);
            
        }
        $$ = $1;
    }
;

corpo
    : bloco_de_comandos
    {
        // we created the scope from the function def
        // and can free after the body was parsed
        // free_current_table(stack_of_tables);
    }
;


cabecalho
    :
    nome_da_funcao
    {
        n_args = 0;
        root_symbol_table* func_table = new_symbol_table();
        register_table_to_stack(stack_of_tables, func_table);
        flag_function_just_created_scope = 1;
    }
    TK_PR_RETURNS tipo_da_variavel
    lista_de_parametros_que_pode_ser_vazia TK_PR_IS
    {

        // ATTENTION INCLUDING THAT RULE ON TOP,
        // SHIFT ALL AFTER IT INDEXES BY ONE

        $$ = $1;
        // $$ = $2;

        int r = search_name_taken_on_stack(stack_of_tables, $1->label);
        if (r == 1)
        {
            // then it was already declared either
            // as a variable or a function
            free_stack_and_all_tables(stack_of_tables);
            printf("ERR_DECLARED\n");
            exit(ERR_DECLARED);
        }

        // TODO check this points
        // FIX na verdade aqui tenho que registrar na tabela acima dessa
        // temos que colocar a funcao na tabela
        register_function_to_tableofc(
            // this is enough?
            // can the mother table be null? will the function handle this?
            stack_of_tables->current_table->mother_table,
            // $1->label,
            // $3,
            $1->label,
            $4,
            n_args
        );

        n_args = -1;
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
        $$ = NULL;
    }
    | lista_wrapper
;

lista_wrapper
    : TK_PR_WITH lista_de_parametros 
    {
        $$ = $2;
    }
;

lista_de_parametros
    : decl
    | lista_de_parametros ',' decl
;

decl
    : TK_ID TK_PR_AS tipo_de_parametro 
    {

        // aqui eu tambem deveria declarar o parametro
        // e checar se ele ja existe

        // TODO REFACTOR
        // copiado da parte da declaracao_da_variavel
         // actually I need to check if variable name does not
        // already exists
        int r = search_name_taken_on_stack(stack_of_tables, $1->value);
        if (r == 1)
        {
            // then it was already declared either
            // as a variable or a function
            free_stack_and_all_tables(stack_of_tables);
            declared_error_message($1->value);
            svalor_lexico_free($1);
            exit(ERR_DECLARED);
        }

        // if not used yet, we register to the current table
        register_variable_to_tableofc(
            stack_of_tables->current_table, 
            $1->value, 
            $3);
        // copiado da parte da declaracao_da_variavel
        // TODO REFACTOR

        // contagem do numero de args
        n_args++;

        svalor_lexico_free($1);
    }
;

tipo_de_parametro
    : TK_PR_INT
    {
        $$ = integer;
    }
    | TK_PR_FLOAT
    {
        $$ = floatpoint;
    }
;

bloco_de_comandos
    : '[' cria_escopo sequencia_de_comandos_simples_possivelmente_vazia destroi_escopo ']'  {
        // even if its null
        $$ = $3;
    }
;


cria_escopo
    : %empty
    {
        if (!flag_function_just_created_scope)
        {
            root_symbol_table* scope_table = new_symbol_table();
            register_table_to_stack(stack_of_tables, scope_table);
        }
        else
            flag_function_just_created_scope = 0;
    }
;

destroi_escopo
    : %empty
    {
        free_current_table(stack_of_tables);
    }
;

sequencia_de_comandos_simples_possivelmente_vazia
    : %empty
    {
        $$ = NULL;
    }
    | sequencia_de_comandos_simples 
;

sequencia_de_comandos_simples
    : comando_simples 
    | comando_simples sequencia_de_comandos_simples {
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
        $$ = asd_new("is");
        asd_add_child($$, 
            asd_new($1->value)
        );
        asd_add_child($$, $3);


        // we need to check if the variable was declared before
        // so it must exist on the current table or before
        int r = search_variable_on_stack(
            stack_of_tables,
            $1->value);

        // it was actually a function!
        if (r == 3) {
            // Enfim, caso o identificador dito função 
            // seja utilizado como variável, deve-se lançar
            // o erro ERR_FUNCTION
            function_error_message($1->value);
            svalor_lexico_free($1);
            free_stack_and_all_tables(stack_of_tables);
            exit(ERR_FUNCTION);
        }

        // not found
        if (r == -1)
        {
            undeclared_error_message($1->value);
            svalor_lexico_free($1);
            free_stack_and_all_tables(stack_of_tables);
            exit(ERR_UNDECLARED);
        }

        // now we must check if the expression is compatible
        // r = type from the searched (and found!) variable
        check_type_compatibility(r, $3->node_type);

        svalor_lexico_free($1);
    }
;

// chamada de funcao
comando_simples_chamada_de_funcao
    : 
    TK_ID {n_args_on_call = 0;}  '(' lista_de_argumentos')' 
    {
        // ADDING THE NEW ACTION ON TOP
        // SHIFTS THE INDEX BY ONE AFTER THE FIRST
        char *new_label;

        asprintf(&new_label, "call %s", $1->value);

        $$ = asd_new(new_label);

        // lista de argumentos pode ser vazio

        // if ($3 != NULL)
        //     asd_add_child($$, $3);
        if ($4 != NULL)
            asd_add_child($$, $4);

        int received_args = n_args_on_call;

        // well we do need to check if the function exists
        int r = search_function_on_stack(
            stack_of_tables,
            $1->value
        );
        // it was a variable!
        if (r == 5) {
            // we are calling a variable as a function
            // Caso o identificador dito variável seja 
            // usado como uma função, deve-se lançar o
            // erro ERR_VARIABLE


            variable_error_message($1->value);
            svalor_lexico_free($1);
            free_stack_and_all_tables(stack_of_tables);

            // tenho q dar free em todas as tabelas q ja aloquei

            exit(ERR_VARIABLE);

        }
        else if (r == 1)
        {
            // we did found and it was indeed a function
            // but we now must check the number of args
            int argsok = check_args_function_on_stack(
                stack_of_tables,
                $1->value,
                received_args
            );

            if (argsok == 11) // too few
            {
                missing_args_error_message($1->value);
                svalor_lexico_free($1);
                free_stack_and_all_tables(stack_of_tables);
                exit(ERR_MISSING_ARGS);
            } else if (argsok == 22) // too much
            {
                excess_args_error_message($1->value);
                svalor_lexico_free($1);
                free_stack_and_all_tables(stack_of_tables);
                exit(ERR_EXCESS_ARGS);
            } 
            // TODO
            // IMPLEMENT ELSE HERE
            // o que acontece se essa funcao retornar um erro?

        } 
        else {
            undeclared_error_message($1->value);
            svalor_lexico_free($1);
            free_stack_and_all_tables(stack_of_tables);
            exit(ERR_UNDECLARED);
        }
        svalor_lexico_free($1);
        free(new_label);
    }
;

lista_de_argumentos
    : %empty
    {
        $$ = NULL;
    }
    | lista_de_argumentos_separados_por_virgula
;

lista_de_argumentos_separados_por_virgula
    : argumento
    {
        $$ = $1;
    }
    | argumento ',' lista_de_argumentos_separados_por_virgula 
    {
        asd_add_child($1, $3);
        $$ = $1;
    }
;

argumento
    : expressao
    {
        // to be able to count how many args we
        // passed to the function call
        n_args_on_call++;
    }
;

comando_simples_comando_de_retorno
    : TK_PR_RETURN expressao TK_PR_AS tipo_da_variavel 
    {

        check_type_compatibility(
            $2->node_type,
            $4
        );

        // TODO how will we know the return of
        // the current function? we need to go
        // back on the pointers somehow

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
        $$ = asd_new("if");
        asd_add_child($$, $3);
        if ($5 != NULL)
            asd_add_child($$, $5);
    }
    | TK_PR_IF '(' expressao ')' bloco_de_comandos TK_PR_ELSE bloco_de_comandos
    {
        $$ = asd_new("if");
        asd_add_child($$, $3);
        if ($5 != NULL)
            asd_add_child($$, $5);
        if ($7 != NULL)
            asd_add_child($$, $7);
    }
;

construcao_iterativa
    : TK_PR_WHILE '(' expressao ')' bloco_de_comandos 
    {
        $$ = asd_new("while");
        asd_add_child($$, $3);
        if ($5 != NULL)
            asd_add_child($$, $5);
    }
;

expressao
    : and
    | expressao '|' and
    {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new("|");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
;

and
    : igual_naoigual
    | and '&' igual_naoigual {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new("&");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
;

igual_naoigual
    : maior_menor
    | igual_naoigual TK_OC_NE maior_menor
    {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new("!=");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
    | igual_naoigual TK_OC_EQ maior_menor 
    {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new("==");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
;

maior_menor
    : acumulacao
    | maior_menor TK_OC_GE acumulacao
    {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new(">=");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
    | maior_menor TK_OC_LE acumulacao
        {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new("<=");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
    | maior_menor '>' acumulacao
    {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new(">");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
    | maior_menor '<' acumulacao
    {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new("<");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
;

acumulacao
    : fator
    | acumulacao '+' fator
    {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new("+");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
    | acumulacao '-' fator
    {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new("-");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
;

fator
    : termo
    | fator '*' termo
    {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new("*");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
    | fator '/' termo
    {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new("/");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
    | fator '%' termo
    {
        check_type_compatibility($1->node_type, $3->node_type);
        $$ = asd_new("%");
        asd_add_child($$, $1);
        asd_add_child($$, $3);
        $$->node_type = $1->node_type;
    }
;

termo
    : operando
    | '(' expressao ')' {
        $$ = $2;
        $$->node_type = $2->node_type;
    }
    | '+' termo
    {
        $$ = asd_new("+");
        asd_add_child($$, $2);
        $$->node_type = $2->node_type;
    }
    | '-' termo
    {
        $$ = asd_new("-");
        asd_add_child($$, $2);
        $$->node_type = $2->node_type;
    }
    | '!' termo
    {
        $$ = asd_new("!");
        asd_add_child($$, $2);
        $$->node_type = $2->node_type;
    }
;

operando
    : comando_simples_chamada_de_funcao
    {
        $$ = $1;
        // preciso verificar qual o retorno da funcao
    }
    | TK_ID
    {
        $$ = asd_new($1->value);

        // aqui preciso verificar a tabela de simbolos
        // ver se existe e pegar o tipo
        int r = search_variable_on_stack(
            stack_of_tables,
            $1->value);

        // not found
        if (r == -1)
        {
            undeclared_error_message($1->value);
            svalor_lexico_free($1);
            free_stack_and_all_tables(stack_of_tables);
            exit(ERR_UNDECLARED);
        }

        // otherwise we do have a type
        svalor_lexico_free($1);
        $$->node_type = r;
    }
    | TK_LI_FLOAT
    {
        $$ = asd_new($1->value);
        svalor_lexico_free($1);
        $$->node_type = floatpoint;
    }
    | TK_LI_INT {
        $$ = asd_new($1->value);
        svalor_lexico_free($1);
        $$->node_type = integer;
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
        fprintf(
            stderr,
            "Erro na linha %d: %s. Token atual: '%s'",
            yylineno,
            s,
            yytext
        );

        if (yychar < (sizeof(yytname) / sizeof(yytname[0])) )
            fprintf(
                stderr,
                " (%s)",
                yytname[yychar]
            );

        printf("\n");
    }

    else
        fprintf(
            stderr,
            "Erro na linha %d: %s. Token atual: <EOF or invalid>\n",
            yylineno,
            s
        );
}


// custom error messages

void undeclared_error_message(char* token_name) {
    extern int yylineno;
    printf("Erro %d: identificador %s foi utilizado sem ter sido declarado na linha %d\n", 
        ERR_UNDECLARED, 
        token_name,
        yylineno);
}

void declared_error_message(char* token_name) {
    extern int yylineno;
    printf("Erro %d: identificador %s redeclarado na linha %d\n", 
        ERR_DECLARED,
        token_name,
        yylineno);
}

void variable_error_message(char* token_name) {
    extern int yylineno;
    printf("Erro %d: variavel %s foi utilizada como funcao na linha %d\n", 
        ERR_VARIABLE, token_name, yylineno);
}

void function_error_message(char* token_name) {
    extern int yylineno;
    printf("Erro %d: funcao %s foi utilizada como uma variavel na linha %d\n", 
        ERR_FUNCTION, token_name, yylineno);
}

void missing_args_error_message(char* token_name) {
    extern int yylineno;
    printf("Erro %d: funcao %s chamada com argumentos faltando na linha %d\n", 
        ERR_MISSING_ARGS, token_name, yylineno);
}

void excess_args_error_message(char* token_name) {
    extern int yylineno;
    printf("Erro %d: funcao %s chamada com excesso de argumentos na linha %d\n", 
        ERR_EXCESS_ARGS, token_name, yylineno);
}

void wrong_type_error_message() {
    extern int yylineno;
    printf("Erro %d: tipos incompativeis na linha %d\n", 
        ERR_WRONG_TYPE, 
        yylineno);
}


// checks if the types are compatible
int check_type_compatibility(int a_type, int b_type){
    if (a_type != b_type)
    {
        // then it was already declared either
        // as a variable or a function
        free_stack_and_all_tables(stack_of_tables);
        wrong_type_error_message();
        exit(ERR_WRONG_TYPE);
    }
}