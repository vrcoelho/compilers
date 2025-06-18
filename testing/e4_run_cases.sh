#!/bin/bash

# arquivo de testes para testar todos os teste cases
# referentes a etapa4

# redirects > /dev/null to the file, emptying it
> testcases_output

#########################
#### testes etapa4
#########################

ok=0
err=0

get_expected_return() {
    case "$1" in
        "//ERR_UNDECLARED") echo 10 ;;
        "//ERR_DECLARED") echo 11 ;;
        "//ERR_VARIABLE") echo 20 ;;
        "//ERR_FUNCTION") echo 21 ;;
        "//ERR_WRONG_TYPE") echo 30 ;;
        "//ERR_MISSING_ARGS") echo 40 ;;
        "//ERR_EXCESS_ARGS") echo 41 ;;
        "//ERR_WRONG_TYPE_ARGS") echo 42 ;;
        *) echo 1 ;; # default case
    esac
}

for case in ./gabarito/cases/q*
do
    filename=$(basename "$case")
    echo "EXECUTANDO $filename"

        return_expected=1 
        line=$(head -n 1 "$case")
        return_expected=$(get_expected_return $line)         
       
        touch ./cases/etapa4/results/"$filename"
        > ./cases/etapa4/results/"$filename"
        # 2>&1 manda tanto o stderr quanto stdout
        ./../../compilers/etapa4 < "$case" >> ./cases/etapa4/results/"$filename" 2>&1

        # captura resultado aqui, logo apos execucao
        result=$?

        # se o retorno do codigo c foi igual ao esperado
        if [ "$result" -eq "$return_expected" ]
        then
            
            ok=$((ok + 1))          

        else
            # se o retorno do codigo c nao foi igual ao esperado
            # ou seja, um leak OU
            # so pegamos o erro errado
            echo "                  > caso $filename: leak or ? returned $result"
            err=$((err + 1))



            if [ "$return_expected" -eq 10 ]
            # se eu queria que fosse ERR_UNDECLARED
            then
                :
                # resultado esperado
                echo "  > expecting $return_expected (ERR_UNDECLARED) returned $result"
            fi

            if [ "$return_expected" -eq 11 ]
            # se eu queria que fosse ERR_DECLARED
            then
                :
                # resultado esperado
                echo "  > expecting $return_expected (ERR_DECLARED) returned $result"
            fi
        fi  

done

echo "====="
echo "ABOUT LEAKS & GENERAL EXEC:"
echo "====="
echo "ok: $ok"
echo "error: $err"

echo "====="
echo "ABOUT TREE EQUIVALENCE:"
echo "====="
echo "equal: $eq"
echo "not equal: $neq"