#include "errors.h"
#include <stdio.h>
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
