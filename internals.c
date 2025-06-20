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



void free_entry_st(element_symbol_table* st) {
    if (st == NULL) {
        // error?
        return;
    }
    // check if its null?
    free(st->name);
    // free(st->parameters_list);
}

void print_table(root_symbol_table* table_root)
{
    element_symbol_table* nextp = table_root->header;
    while (nextp != NULL)
    {
        char rtype[255];

        if (nextp->type_or_return == integer)
            strcpy(rtype, "int");
        else if(nextp->type_or_return == floatpoint)
            strcpy(rtype, "float");     
        else
            strcpy(rtype, "???");
        
        if (nextp->type_of_element == function)
        {
            printf("%s %s %s with %d args\n", 
                "function", 
                nextp->name,
                rtype,
                nextp->n_args);

            // como posso imprimir o numero de args
            for(int i=0; i<nextp->n_args;i++){
                printf("    arg %d: type %d\n",  
                    i+1,
                    nextp->parameters_list[i]);
            }
        }
        else if(nextp->type_of_element == variable)
        {
            printf("%s %s %s\n", 
                "variable", 
                nextp->name,
                rtype);
        }
        else
        {
            // error
            printf("%s %d %s %s\n", 
                "ERROR???? UNDEFINED", 
                nextp->type_or_return,
                nextp->name,
                rtype);
        }
        nextp = nextp->next;
    }
        
}


// new functions
root_symbol_table* new_symbol_table() {
    root_symbol_table*  table = NULL;
    table = calloc(1, sizeof(root_symbol_table));
    if (table == NULL) {
        // error? so what? end of the world?
    }
    return table;
}


void free_symbol_table_contents(root_symbol_table* table_root) {
    if (table_root->header == NULL ) { 
        // error? print something?
        return;
    }
    // print_table(table_root);
    element_symbol_table* curr;
    element_symbol_table* next;
    curr = table_root->header;
    next = curr->next;
    int finished = 0;
    while (!finished) {        
        free_entry_st(curr);
        free(curr);
        if (next == NULL)
            finished = 1;
        else
        {
            curr = next;
            next = curr->next;
        }
    }

}

void free_current_table(stack_symbol_table* stack ) {
    printf("free_current_table called\n");
    if (stack == NULL ) { 
        // error because we need a valid pointer
        // printf("ERRO STACK ERA VAZIA");
        return;
    }

    if (stack->current_table == NULL ) { 
        // error because we need a valid pointer
        // printf("ERRO current_table ERA VAZIA");
        return;
    }

    root_symbol_table* to_free = stack->current_table;
    stack->current_table = stack->current_table->mother_table;
    stack->current_table->next_table = NULL;
    free_symbol_table_contents(to_free);
    free(to_free);
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

    if (table_root == NULL ) { 
        // error because we need a valid pointer
        return;
    }

    if (table_root->header == NULL ) { 
        table_root->header = new_entry_variable2(variable_name, variable_type);
        return;
    }
    element_symbol_table* nextp = table_root->header;
    while (nextp->next != NULL)
    {
        nextp = nextp->next;
    }

    nextp->next = new_entry_variable2(variable_name, variable_type);
    nextp->next->next = NULL; // just to make sure
}


type_of_element* get_parameters_from_table(
    root_symbol_table* ftable_pointer,
    int nargs){

    if (ftable_pointer == NULL || nargs < 1 ) { 
        // error because we need a valid pointer
        return NULL;
    }


    type_of_element* args = malloc(nargs * sizeof(type_of_element));
    element_symbol_table* nextp = ftable_pointer->header;
    for(int i = 0; i < nargs; i++){
        args[i] = nextp->type_or_return;
        nextp = nextp->next;
    }
    return args;
}


// register functions to table
element_symbol_table* new_entry_function2(
    const char* name, 
    int return_type,
    int nargs,
    root_symbol_table* ftable_pointer) {
    element_symbol_table* p = NULL;
    p = calloc(1, sizeof(element_symbol_table));
    if (p != NULL) {
        p->type_of_element = function;
        p->name = strdup(name);
        p->next = NULL;

        p->type_or_return = return_type;
        p->n_args = nargs;

        p->ftable_pointer = ftable_pointer;



        // TODO INCLUDE PARAMETERS LIST IT HERE

        // call function to get this info from the
        // pointed table
        if (nargs > 0)
        {
            // TODO: check errors?
            p->parameters_list = get_parameters_from_table(
                p->ftable_pointer,
                nargs
            );
        }
        
    }
    return p;
}

void register_function_to_tableofc(
    root_symbol_table* table_root,
    const char* name, 
    int return_type,
    int nargs,
    root_symbol_table* ftable_pointer) {

    if (table_root == NULL ) { 
        // error because we need a valid pointer
        return;
    }

    if (table_root->header == NULL ) { 
        table_root->header = new_entry_function2(name, return_type, nargs, ftable_pointer);
        return;
    }

    element_symbol_table* nextp = table_root->header;
    while (nextp->next != NULL)
    {
        nextp = nextp->next;
    }
    
    nextp->next = new_entry_function2(name, return_type, nargs, ftable_pointer);
    nextp->next->next = NULL; // just to make sure
}


// stack functions

stack_symbol_table* new_stack_of_tables() {
    stack_symbol_table* stack = NULL;
    stack = calloc(1, sizeof(stack_symbol_table));
    if (stack == NULL) {
        // error end of the world
    }
    stack->first_table = NULL;
    stack->current_table = NULL;
    return stack;

}

void register_table_to_stack(
    stack_symbol_table* stack, 
    root_symbol_table* table    
) {
    printf("register_table_to_stack called\n");
    if (stack == NULL) {
        // error we need a valid pointer
        return;
    }

    if (table == NULL) {
        // error we need a valid pointer
        return;
    }


    if (stack->first_table == NULL){
        stack->first_table = table;
        stack->current_table = table;
    } else {
        root_symbol_table* nextable = stack->first_table;
        while (nextable->next_table != NULL)
        {
            nextable = nextable->next_table;
        }
        nextable->next_table = table;
        table->mother_table = nextable;
        stack->current_table = table;
    }
}
   

void print_stack_of_tables( stack_symbol_table* stack) {
    if (stack == NULL) {
        // error we need a valid pointer
        return;
    }

    root_symbol_table* curr_table = stack->first_table;
    while(curr_table != NULL) { 
        printf("---\n");
        print_table(curr_table);
        curr_table = curr_table->next_table;
    } 
    printf("---end of print_stack_of_tables---\n");

}

// function that searchs for a variable going upwards on the tables

int search_variable_on_table(
    root_symbol_table* table,
    const char* varname
) {
    if (table == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (varname == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (table->header == NULL) {
        // error we need a valid pointer
        return -2;
    }
    // comeco a procurar na tabela
    element_symbol_table* curr = table->header;
    while(curr != NULL)
    {
        // checa se o nome bate
        if (strcmp(varname, curr->name) == 0)
        {
            // the name matches
            // was it really a variable?
            if (curr->type_of_element == variable)
                // return 1;
                return curr->type_or_return;
            else
                return 3;
        }
        curr = curr->next;
    }
    // not found
    return -1;
}


int search_variable_on_stack(
    stack_symbol_table* stack_of_tables,
    const char* varname
) {
    if (stack_of_tables == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (stack_of_tables->current_table == NULL) {
        // error we need a valid pointer
        return -2;
    }

    root_symbol_table* curr_table = stack_of_tables->current_table;

    int i = 1;
    while(curr_table != NULL) {
        int r = search_variable_on_table(curr_table, varname);
        if (r == 1 | r == 3 | r > 70)
            // integer = 77, floatpoint = 88
            return r;
        i++;
        curr_table = curr_table->mother_table;
    }
    return -1;
}


int free_stack_and_all_tables(
    stack_symbol_table* stack_of_tables
) {
    if (stack_of_tables == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (stack_of_tables->current_table == NULL) {
        // error we need a valid pointer
        return -2;
    }

    root_symbol_table* curr_table = stack_of_tables->current_table;

    int i = 1;
    while(curr_table != NULL) {
        // printf("Cleaning table: %d\n", i);
        root_symbol_table* next_to_free = curr_table->mother_table;
        free_symbol_table_contents(curr_table);
        curr_table = next_to_free;
        i++;
    }
    return 1;
}



int search_function_on_table(
    root_symbol_table* table,
    const char* funcName
) {
    if (table == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (funcName == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (table->header == NULL) {
        // error we need a valid pointer
        return -2;
    }
    element_symbol_table* curr = table->header;
    while(curr != NULL)
    {
        if (strcmp(funcName, curr->name) == 0)
        {
            // the name matches
            // was it really a function?
            if (curr->type_of_element == function)
                return 1; // found
            else
                return 5; // it was a variable
        }

        curr = curr->next;
    }

    // not found
    return -1;
}


int search_function_on_stack(
    stack_symbol_table* stack_of_tables,
    const char* funcName
) {
    if (stack_of_tables == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (stack_of_tables->current_table == NULL) {
        // error we need a valid pointer
        return -2;
    }

    root_symbol_table* curr_table = stack_of_tables->current_table;

    int i = 1;
    while(curr_table != NULL) {
        // printf("Searching on table: %d\n", i);
        int r = search_function_on_table(curr_table, funcName);
        if (r == 1 | r == 5)
            return r;
        i++;
        curr_table = curr_table->mother_table;
    }
    return -1;
}


/// checks if the num of args
// in the function call is correct

// sucess codes:
// 1 ok
// 5 it was a variable (not a function)
// 11 received less args
// 22 received more args

// error codes:
// -1 data not found
// -2 null pointer
// -3 empty current table

int check_args_function_on_table(
    root_symbol_table* table,
    const char* funcName,
    int received_args
) {
    if (table == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (funcName == NULL) {
        // error we need a valid pointer
        return -2;
    }
    
    if (table->header == NULL) {
        // the table could be just empty...
        return -3;
    }
    // comeco a procurar na tabela
    
    element_symbol_table* curr = table->header;
    while(curr != NULL)
    {
        if (strcmp(funcName, curr->name) == 0)
        {
            // the name matches
            // was it really a function?
            if (curr->type_of_element == function)
            {
                if (received_args == curr->n_args)
                // checking the n args
                    return 1; // tudo certo
                else if (received_args < curr->n_args)
                    return 11;
                else if (received_args > curr->n_args)
                    return 22;
            }
            else
                return 5; // it was a variable
        }

        curr = curr->next;
    }

    // not found
    return -1;
}


int check_args_function_on_stack(
    stack_symbol_table* stack_of_tables,
    const char* funcName,
    int received_args
) {
    if (stack_of_tables == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (stack_of_tables->current_table == NULL) {
        // error we need a valid pointer
        return -2;
    }

    root_symbol_table* curr_table = stack_of_tables->current_table;

    int i = 1;
    while(curr_table != NULL) {
        int r = check_args_function_on_table(
            curr_table,
            funcName,
            received_args);
        if (r != -1 && r != -3)
            return r;
        i++;
        curr_table = curr_table->mother_table;
    }
    return -1;
}










// to find if something was already declared
int search_name_taken_on_table(
    root_symbol_table* table,
    const char* name
) {
    if (table == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (name == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (table->header == NULL) {
        // error we need a valid pointer
        return -2;
    }
    // comeco a procurar na tabela
    element_symbol_table* curr = table->header;
    while(curr != NULL)
    {
        // checa se o nome bate

        if (strcmp(name, curr->name) == 0)
        {
                return 1;
        }

        curr = curr->next;
    }

    // not found
    return -1;
}


int search_name_taken_on_stack(
    stack_symbol_table* stack_of_tables,
    const char* name
) {
    if (stack_of_tables == NULL) {
        // error we need a valid pointer
        return -2;
    }

    if (stack_of_tables->current_table == NULL) {
        // error we need a valid pointer
        return -2;
    }

    root_symbol_table* curr_table = stack_of_tables->current_table;

    int i = 1;
    while(curr_table != NULL) {
        // printf("Searching on table: %d\n", i);
        int r = search_name_taken_on_table(curr_table, name);
        if (r == 1)
            return r;
        i++;
        curr_table = curr_table->mother_table;
    }
    return -1;
}


// arguments functions

args_counter* pt_top_counter_args= NULL;
args_counter* pt_current_counter_args= NULL;


args_counter* new_argscounter(){
    args_counter* argument_counter_pointer = NULL;
    argument_counter_pointer = calloc(1, sizeof(args_counter));
    argument_counter_pointer->args_passed = 0;
    argument_counter_pointer->next = NULL;
    return argument_counter_pointer;
}

void create_and_stack_args_counter() {
    if (pt_top_counter_args == NULL) { 
        pt_current_counter_args = new_argscounter();
        pt_top_counter_args = pt_current_counter_args;
        return;
    }

    args_counter* newargs = new_argscounter();

    pt_current_counter_args->next = newargs;
    pt_current_counter_args = newargs;
}

void unstack_args_counter() {
    if (pt_top_counter_args == NULL) { 
        return;
    }

    // pega penultimo
    args_counter* pu = pt_top_counter_args;

    // se eu sou o ultimo
    if (pu->next == NULL)
    {
        // free pu
        free(pu);
        pt_current_counter_args = NULL;
        pt_top_counter_args = NULL;
    }
    else{
        while(pu->next != NULL && pu->next->next != NULL)
        {
            pu = pu->next;
        }

        // tem que free o ultimo (pu->next)
        free(pu->next);

        pu->next = NULL;
        pt_current_counter_args = pu;
    }
}

void print_args_counter() {
    if (pt_top_counter_args == NULL)
    {
        printf("empty\n");
        return;
    }
        
    printf("=====\n");
    args_counter* current = pt_top_counter_args;
    while(current!=NULL)
    {
        printf("args %d\n", current->args_passed);
        current = current->next;
    }
    printf("=====\n");
}

// seria o mesmo que so acessar e add pelo ponteiro
void increase_current_args_counter() {
    if (pt_current_counter_args == NULL) { 
        // ERROR
        return;
    }
    pt_current_counter_args->args_passed++;
}

int get_current_args_current() {
    if (pt_current_counter_args == NULL) { 
        return -1;
    }
    return pt_current_counter_args->args_passed;
}