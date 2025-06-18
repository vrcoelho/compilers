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

for case in ./gabarito/cases/q*
do
    filename=$(basename "$case")
    echo "EXECUTANDO $filename"

        return_expected=1 
        line=$(head -n 1 "$case")
        case "$line" in
            "//ERR_UNDECLARED")
                return_expected=10
                ;; 
            "//ERR_DECLARED")
                return_expected=11
                ;;
            "//ERR_VARIABLE")
                return_expected=20
                ;;
            "//ERR_FUNCTION")
                return_expected=21
                ;;
            "//ERR_WRONG_TYPE")
                return_expected=30
                ;;
            "//ERR_MISSING_ARGS")
                return_expected=40
                ;;
            "//ERR_EXCESS_ARGS")
                return_expected=41
                ;;
            "//ERR_WRONG_TYPE_ARGS")
                return_expected=42
                ;;
        esac

         
       
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