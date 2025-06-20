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




typedef enum {variable = 55, function = 66} variable_or_function;
typedef enum {integer = 77, floatpoint = 88} type_of_element;


typedef struct args_counter_st
{
    int args_passed;
    struct args_counter_st* next;
} args_counter;

typedef struct root_symbol_table_st
{
    // points to the next symbol
    struct element_symbol_table_st* header;
    struct root_symbol_table_st* mother_table;
    struct root_symbol_table_st* next_table;
} root_symbol_table;


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
    // the actual table with its scope
    root_symbol_table* ftable_pointer;

    // points to the next symbol
    struct element_symbol_table_st* next;
} element_symbol_table;



typedef struct stack_symbol_table_st {
    struct root_symbol_table_st* first_table;
    struct root_symbol_table_st* current_table;
} stack_symbol_table;


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

void register_function_to_tableofc(
    root_symbol_table* table_root,
    const char* name, 
    int return_type,
    int nargs,
    root_symbol_table* ftable_pointer);

type_of_element* get_parameters_from_table(
    root_symbol_table* ftable_pointer,
    int nargs);

stack_symbol_table* new_stack_of_tables();
void register_table_to_stack(
    stack_symbol_table* stack, 
    root_symbol_table* table    
);

void print_stack_of_tables( stack_symbol_table* stack);


int search_variable_on_table(
    root_symbol_table* table,
    const char* varname
);

int search_variable_on_stack(
    stack_symbol_table* stack_of_tables,
    const char* varname
);


void free_current_table(
    stack_symbol_table* stack );

int free_stack_and_all_tables(
    stack_symbol_table* stack_of_tables
);


int search_function_on_table(
    root_symbol_table* table,
    const char* funcName
);

int search_function_on_stack(
    stack_symbol_table* stack_of_tables,
    const char* funcName
);


int check_args_function_on_table(
    root_symbol_table* table,
    const char* funcName,
    int received_args
);

int check_args_function_on_stack(
    stack_symbol_table* stack_of_tables,
    const char* funcName,
    int received_args
) ;


int search_name_taken_on_table(
    root_symbol_table* table,
    const char* name
);

int search_name_taken_on_stack(
    stack_symbol_table* stack_of_tables,
    const char* name
);


int check_type_compatibility(int a_type, int b_type);


// arguments functions
args_counter* new_argscounter();
void create_and_stack_args_counter();
void unstack_args_counter();
void increase_current_args_counter();
int get_current_args_current();
void print_args_counter();