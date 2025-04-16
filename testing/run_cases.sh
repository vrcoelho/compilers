#!/bin/bash

# arquivo de testes para testar todos os teste cases

# redirects > /dev/null to the file, emptying it
> testcases_output

for case in ./cases/etapa2/asl*
do
    filename=$(basename "$case")
    # echo "EXECUTANDO $filename"

    return_expected=0    
    line=$(head -n 1 "$case")
    if [ "$line" != "//CORRECT" ]
    then
        return_expected=1
    fi

    # executa nosso programa
    echo "===================" >> testcases_output
    echo "TESTE $case" >> testcases_output

    # 2>&1 manda tanto o stderr quanto stdout
    ./../../compilers/parser < "$case" >> testcases_output 2>&1

    # captura resultado aqui, logo apos execucao
    result=$?

    echo "\n===================" >> testcases_output
    echo "" >> testcases_output


    

    # se o retorno do codigo c foi 0 (sucesso)
    if [ "$result" -eq "$return_expected" ]
    then
        echo "caso $filename: OK"
    else
        echo "              caso $filename: ERROR"
    fi
done