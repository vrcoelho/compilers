typedef struct svalor_lexico
{
    int line_number;
    char *token_type;
    char *value;
} svalor_lexico_st;

svalor_lexico_st *svalor_lexico_new(
    int line_number,
    const char *token_type,
    const char *value);

void svalor_lexico_free(svalor_lexico_st *v);


// we need a new structure

typedef enum {variable, function} variable_or_function;
typedef enum {integer, floatpoint} type_of_element;

typedef struct element_symbol_table_st
{
    // both
    variable_or_function type_of_element;
    type_of_element type_or_return; 
    char* name;

    // variables
    int ivalue;
    float fvalue;
    //      |-> do i actually need this?

    // functions
    int n_args;
    type_of_element* parameters_list;

    // points to the next symbol
    struct element_symbol_table_st* next;
} element_symbol_table;

typedef struct root_symbol_table_st
{
    // points to the next symbol
    struct element_symbol_table_st* header;
} root_symbol_table;

element_symbol_table* new_entry_variable(const char* name);
element_symbol_table* new_entry_function(
    const char* name, 
    int nargs, 
    type_of_element * argslist);



void insert_to_table(
    root_symbol_table* table_root,
    element_symbol_table* element);







// really used functions

void free_entry_st(element_symbol_table* st);
    
void print_table(root_symbol_table* table_root);

root_symbol_table* new_symbol_table();
void free_symbol_table_contents(root_symbol_table* table_root);

element_symbol_table* new_entry_variable2(
    const char* name,
    int type_of_variable);

void register_variable_to_tableofc(
    root_symbol_table* table_root,
    const char* variable_name,
    int variable_type);