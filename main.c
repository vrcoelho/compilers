#include <stdio.h>
#include "asd.h"
#include "internals.h"
extern int yyparse(void);
extern int yylex_destroy(void);
extern int yydebug;
asd_tree_t *arvore = NULL;
stack_symbol_table* stack_of_tables = NULL;

int n_args = -1;
int n_args_on_call = -1;

int main(int argc, char **argv)
{
  stack_of_tables = new_stack_of_tables();
  root_symbol_table* global_table = new_symbol_table();
  register_table_to_stack(stack_of_tables, global_table);
  // yydebug = 1;
  int ret = yyparse();
  asd_print_graphviz(arvore);
  asd_free(arvore);
  yylex_destroy();
  return ret;
}
