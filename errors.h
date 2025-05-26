#define ERR_UNDECLARED       10 //2.2
#define ERR_DECLARED         11 //2.2
#define ERR_VARIABLE         20 //2.3
#define ERR_FUNCTION         21 //2.3
#define ERR_WRONG_TYPE       30 //2.4
#define ERR_MISSING_ARGS     40 //2.5
#define ERR_EXCESS_ARGS      41 //2.5
#define ERR_WRONG_TYPE_ARGS  42 //2.5

void undeclared_error_message(char* token_name);
void declared_error_message(char* token_name);

void variable_error_message(char* token_name);
void function_error_message(char* token_name);

void missing_args_error_message(char* token_name);
void excess_args_error_message(char* token_name);