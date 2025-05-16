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
