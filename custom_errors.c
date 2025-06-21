#include "errors.h"
#include "internals.h"
#include "custom_errors.h"
#include <stdio.h>
#include <string.h>
// custom error messages

int MAX_SIZE_SHORT_STRING = 100;
int MAX_SIZE_ERROR_MESSAGE = 256;

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

void excess_args_error_message() {
    extern int yylineno;
    printf("Erro %d: funcao chamada com excesso de argumentos na linha %d\n", 
        ERR_EXCESS_ARGS, yylineno);
}

void wrong_type_error_message() {
    extern int yylineno;
    printf("Erro %d: tipos incompativeis na linha %d\n", 
        ERR_WRONG_TYPE, 
        yylineno);
}

void get_error_name_from_code(char* nametype, int error_code)
{
    switch (error_code) {
        case 10:
            strcpy(nametype, "ERR_UNDECLARED");
            break;
        case 11:
            strcpy(nametype, "ERR_DECLARED");
            break;
        case 20:
            strcpy(nametype, "ERR_VARIABLE");
            break;
        case 21:
            strcpy(nametype, "ERR_FUNCTION");
            break;
        case 30:
            strcpy(nametype, "ERR_WRONG_TYPE");
            break;
        case 40:
            strcpy(nametype, "ERR_MISSING_ARGS");
            break;
        case 41:
            strcpy(nametype, "ERR_EXCESS_ARGS");
            break;
        case 42:
            strcpy(nametype, "ERR_WRONG_TYPE_ARGS");
            break;
        default:
            strcpy(nametype, "!ERRO_INDEFINIDO");
        }
}


void get_type_name_from_code(char* nametype, int type_code){   
        if (type_code == integer)
            strcpy(nametype, "int");
        else if(type_code == floatpoint)
            strcpy(nametype, "float");
        else if(type_code == -100)
            strcpy(nametype, "vazio");    
        else
            strcpy(nametype, "???");

}

void generic_error(int error_type,
    const char* custom_error_message){
    extern int yylineno;
    // TODO PRINT ERROR_NAME AS WELL
    char error_name[MAX_SIZE_SHORT_STRING];
    get_error_name_from_code(error_name, error_type);
    printf("Erro %s (code %d) na linha %d: %s\n",
        error_name, 
        error_type, 
        yylineno,
        custom_error_message);
}