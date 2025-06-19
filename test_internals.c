#include <stdlib.h>
#include <stdio.h>
#include "internals.h"

int main() {
    // como vai ser o teste?
    // vou criar uma entrada
    // colocar coisas nela
    // quero liberar ela
    // nao pode dar nenhum erro naquela 
    // flag de controle da memoria

    root_symbol_table* table = new_symbol_table();

    char newfuncname[] = "iamfunction";
    int functype = 1;


    register_variable_to_tableofc(table, newfuncname, functype);



    char newfuncname2[] = "second_function";
    int functype2 = 0;
    register_variable_to_tableofc(table, newfuncname2, functype2);


    print_table(table);

    printf("%s\n", "hello");



    // new testing


    
    stack_symbol_table* stack = new_stack_of_tables();
    register_table_to_stack(stack, table);




    // creating a second table
    root_symbol_table* table2 = new_symbol_table();
    char newfuncname3[] = "variable_da_tabela2";
    int functype3 = 0;
    register_variable_to_tableofc(table2, newfuncname3, functype3);

    printf("%s\n", "hello2");
    register_table_to_stack(stack, table2);
    print_stack_of_tables(stack);
    // adding the second t


    // prints only the current
    printf("%s\n", "hello3here");
    print_table(stack->current_table);



    // search for the variable?
    int r = search_variable_on_stack(stack, "second_function");
    printf("achou?: %d\n", r);


    free_symbol_table_contents(table);
    free(table);

    

    free_symbol_table_contents(table2);
    free(table2);

    free(stack);




    return 0;
}