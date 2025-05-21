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

    char varname[] = "teste_variavel";

    element_symbol_table* v = new_entry_variable(varname);
    // free_entry_st(v);
    // free(v);
    

    char funcname[] = "teste_funcao";

    element_symbol_table* f = new_entry_function(funcname, 0, NULL);
    free_entry_st(f);
    free(f);

    type_of_element arglist[2];
    arglist[0] = integer;
    arglist[1] = floatpoint;

    element_symbol_table* f2 = new_entry_function(
        funcname, 2, &arglist[0]);

    
    printf("%s\n", f2->name);

    // creates a table to hold the symbols
    root_symbol_table root = {NULL};

    insert_to_table(&root, f2);

    printf("%s\n", f2->name);



    insert_to_table(&root, v);

    printf("%s\n", v->name);


    printf("%s\n", root.header->next->name);

    print_table(&root);

    // free used stuff

    free_entry_st(f2);
    free(f2);

    free_entry_st(v);
    free(v);


    return 0;
}