#include <stdlib.h>
#include <stdio.h>
#include "internals.h"
#include "custom_errors.h"

int yylineno = 99;

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

    // checks we can acess the returned types in the array
    type_of_element* args = get_parameters_from_table(
        table,
        2
    );
    printf("%s\n", "types in array:");
    printf("%d\n", args[0]);
    printf("%d\n", args[1]);

    

    stack_symbol_table* stack = new_stack_of_tables();
    register_table_to_stack(stack, table);


    // creating a second table
    root_symbol_table* table2 = new_symbol_table();
    char newfuncname3[] = "variable_da_tabela2";
    int functype3 = floatpoint;
    register_variable_to_tableofc(table2, newfuncname3, functype3);


    char newvarname4[] = "parametro_func2";
    int functype4 = integer;
    register_variable_to_tableofc(table2, newvarname4, functype4);


    printf("%s\n", "print stack of tables");
    register_table_to_stack(stack, table2);
    print_stack_of_tables(stack);
    // adding the second t


    // prints only the current
    printf("%s\n", "print tabela atual");
    print_table(stack->current_table);



    // search for the variable?
    int r = search_variable_on_stack(stack, "second_function");
    printf("achou?: %d\n", r);



    // need to register a function
    // and then register its args
    // nessa primeira tabela, vou registrar umafuncao
    // cuja sua propria tabela de escopo eh table2
    printf("registrando funcao\n");
    char newfuncname5[] = "funcaotestandoagora";
    register_function_to_tableofc(
        table,
        newfuncname5,
        integer,
        2,
        table2
    );
    print_stack_of_tables(stack);



    

    // teste funcoes de acesso
    element_symbol_table* e = get_function_entry_on_stack(
        stack,
        newfuncname5
    );

    printf("arg: %d\n", e->parameters_list[1]);
    






    // free resources
    free_symbol_table_contents(table);
    free(table);    

    free_symbol_table_contents(table2);
    free(table2);

    free(stack);


    // // testes para a criacao do
    // // contador de argumentos
    // int i = 5;
    // for(int j = 0; j < i; j++)
    // {
    //     create_and_stack_args_counter();
    //     print_args_counter();
    // }

    // i=3;
    // for(int j = 0; j < i; j++)
    // {
    //     unstack_args_counter();
    //     print_args_counter();
    // }

    // increase_current_args_counter();
    // increase_current_args_counter();
    // printf("%d\n", get_current_args_current() );



    char nametype[MAX_SIZE_SHORT_STRING];
    get_type_name_from_code(nametype, integer);
    printf("%s\n", nametype );

    get_type_name_from_code(nametype, floatpoint);
    printf("%s\n", nametype );

    get_type_name_from_code(nametype, integer);
    printf("%s\n", nametype );

    get_type_name_from_code(nametype, floatpoint);
    printf("%s\n", nametype );

    get_type_name_from_code(nametype, 33);
    printf("%s\n", nametype );

    get_type_name_from_code(nametype, floatpoint);
    printf("%s\n", nametype );


    get_error_name_from_code(nametype, 10);
    printf("%s\n", nametype );


    wrong_type_error_message();

    generic_error(10, "");

    return 0;
}