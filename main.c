#include <stdio.h>
#include "asd.h"
extern int yyparse(void);
extern int yylex_destroy(void);
extern int yydebug;
asd_tree_t *arvore = NULL;
int main (int argc, char **argv)
{
  // yydebug = 1;
  int ret = yyparse();
  asd_print_graphviz(arvore);
  asd_free(arvore);
  yylex_destroy();
  return ret;
}
