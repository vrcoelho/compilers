#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "internals.h"

svalor_lexico_st *svalor_lexico_new(
    int line_number,
    const char *token_type,
    const char *value)
{
    svalor_lexico_st *a = NULL;
    a = calloc(1, sizeof(svalor_lexico_st));
    if (a != NULL)
    {
        a->line_number = line_number;
        a->token_type = strdup(token_type);
        a->value = strdup(value);
    }
    return a;
}

void svalor_lexico_free(svalor_lexico_st *v)
{
    if (v != NULL)
    {
        free(v->token_type);
        free(v->value);
        free(v);
    }
    else
    {
        printf("Erro: %s recebeu parâmetro v = %p.\n", __FUNCTION__, v);
    }
}