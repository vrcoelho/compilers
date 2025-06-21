void undeclared_error_message(char* token_name);
void declared_error_message(char* token_name);

void variable_error_message(char* token_name);
void function_error_message(char* token_name);

void missing_args_error_message(char* token_name);
void excess_args_error_message();
void wrong_type_args_error_message();
void wrong_type_error_message();

void generic_error(int error_type,
    const char* custom_error_message);



extern int MAX_SIZE_SHORT_STRING;
extern int MAX_SIZE_ERROR_MESSAGE;


void get_error_name_from_code(char* nametype, int error_code);
void get_type_name_from_code(char* nametype, int type_code);


void check_compatible_attribution(int a_type, int b_type);
void check_return_passed_and_declared_in_expression(int a_type, int b_type);
void check_return_passed_and_declared_in_function(int a_type, int b_type) ;
void check_compatible_if_blocks(int a_type, int b_type) ;
int check_type_compatibility_operations(int a_type, int b_type);
