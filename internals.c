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







element_symbol_table* new_entry_variable(const char* name) {
    element_symbol_table* p = NULL;
    p = calloc(1, sizeof(element_symbol_table));
    if (p != NULL) {
        p->type_of_element = variable;
        p->name = strdup(name);
        p->next = NULL;

        // since it is not a function
        p->n_args = -1;
        p->parameters_list = NULL;
    }
    return p;
}

element_symbol_table* new_entry_function(
    const char* name, 
    int nargs, 
    type_of_element * argslist) {
    element_symbol_table* p = NULL;
    p = calloc(1, sizeof(element_symbol_table));
    if (p != NULL) {
        p->type_of_element = function;
        p->name = strdup(name);
        p->next = NULL;

        p->n_args = nargs;
        if (nargs == 0)
            p->parameters_list = NULL;
        if (nargs > 0)
            if (argslist == NULL)
            {
                printf("error parameters list can not be null if nargs > 0");
                return NULL;
            } else {
                // to I need to re-copy everything?
                p->parameters_list = argslist;
                printf("%d\n", p->parameters_list[1]);
            }
        
    }
    return p;
}

void free_entry_st(element_symbol_table* st) {
    if (st == NULL) {
        // error?
        return;
    }
    // check if its null?
    free(st->name);
    // free(st->parameters_list);
}

// ===========================

// i need to actually have a table with the entries
// based on its name I need to search for a 


// a table has a list of entrys
// and a pointer to its parent table? 
//   |-> not sure we actually need it
//   |-> because we will have a `stack` with pointers to the tables




// i am like setting the pointers but I actually need
// to create the pointers, I believe. and set it up
// adiciona ao ultimo da tabela?
void insert_to_table(
    root_symbol_table* table_root,
    element_symbol_table* element) {

    if (table_root->header == NULL ) { 
        if (element == NULL) {
            // todo error
        }
        table_root->header = element;
        printf("pointed to element %s\n", element->name);
        printf("pointed to table_root %s\n", (table_root->header)->name);
        return;
    }
    printf("i got here\n");
    element_symbol_table* nextp = table_root->header;
    while (nextp->next != NULL)
    {
        nextp = nextp->next;
        printf("a\n");
    }

    
    nextp->next = element;
    element->next = NULL; // just to make sure

    printf("pointed to nextp %s\n", (element)->name);
}


void print_table(root_symbol_table* table_root)
{
    element_symbol_table* nextp = table_root->header;
    while (nextp != NULL)
    {
        printf("%s\n", nextp->name);

        nextp = nextp->next;
    }
        

}


















element_symbol_table* new_entry_variable2(
    const char* name,
    int type_of_variable) {
    element_symbol_table* p = NULL;
    p = calloc(1, sizeof(element_symbol_table));
    if (p != NULL) {
        p->type_of_element = variable;
        p->name = strdup(name);
        p->type_or_return = type_of_variable;
        p->next = NULL;

        // since it is not a function
        p->n_args = -1;
        p->parameters_list = NULL;
    }
    return p;
}


void register_variable_to_tableofc(
    root_symbol_table* table_root,
    const char* variable_name,
    int variable_type) {

    if (table_root->header == NULL ) { 
        table_root->header = new_entry_variable2(variable_name, variable_type);
        return;
    }
    printf("i got here\n");
    element_symbol_table* nextp = table_root->header;
    while (nextp->next != NULL)
    {
        nextp = nextp->next;
        printf("a\n");
    }

    
    nextp->next = new_entry_variable2(variable_name, variable_type);
    nextp->next->next = NULL; // just to make sure
}