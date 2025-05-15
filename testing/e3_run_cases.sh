#!/bin/bash

# arquivo de testes para testar todos os teste cases

# redirects > /dev/null to the file, emptying it
> testcases_output

rm ./cases/etapa3/results/*

ok=0
err=0
eq=0
neq=0

#########################
#### testes etapa3
#########################

# run testes da etapa2
for case in ./cases/etapa2/asl*
do
    filename=$(basename "$case")

    return_expected=0    
    line=$(head -n 1 "$case")
    if [ "$line" != "//CORRECT" ]
    then
        return_expected=1
    fi

    # se espero que va funcionar
    if [ "$return_expected" -eq 0 ]
    then
        touch ./cases/etapa3/results/"$filename"
        > ./cases/etapa3/results/"$filename"
        # 2>&1 manda tanto o stderr quanto stdout
        ./../../compilers/etapa3 < "$case" >> ./cases/etapa3/results/"$filename" 2>&1

        # captura resultado aqui, logo apos execucao
        result=$?

        # se o retorno do codigo c foi igual ao esperado
        if [ "$result" -eq "$return_expected" ]
        then
            dot -Tpng ./cases/etapa3/results/"$filename" -o ./cases/etapa3/results/"$filename".png > /dev/null 2>&1
            result2=$?
            if [ "$result2" -ne 0 ]
            then
                echo "                  > case $filename: nao gerou arvore"
                err=$((err + 1))
            else
                ok=$((ok + 1))
            fi
        else
            # ou seja, deu algum erro...
            echo "                  > caso $filename: leak"
            err=$((err + 1)) 
        fi
    fi
done

echo "====="
echo "cases from etapa2:"
echo "====="
echo "ok: $ok"
echo "error: $err"

#########################
#### testes etapa3
#########################

ok=0
err=0

for case in ./cases/etapa3/professor/z*
do
    filename=$(basename "$case")
    # echo "EXECUTANDO $filename"

    if [[ "$filename" =~ ^z.*\.ref.dot$ ]]
    then
        # resposta a gerar gabarito

        dot -Tpng ./cases/etapa3/professor/"$filename" -o ./cases/etapa3/results/"$filename"_resposta.png > /dev/null 2>&1
    else
        # caso de teste per se
    
        # nesse caso todos os testes devem terminar com ok
        return_expected=0    
       
        touch ./cases/etapa3/results/"$filename"
        > ./cases/etapa3/results/"$filename"
        # 2>&1 manda tanto o stderr quanto stdout
        ./../../compilers/etapa3 < "$case" >> ./cases/etapa3/results/"$filename" 2>&1

        # captura resultado aqui, logo apos execucao
        result=$?

        # se o retorno do codigo c foi igual ao esperado
        if [ "$result" -eq "$return_expected" ]
        then
            # echo "caso $filename: OK"
            # se esperava ser sucesso
            if [ "$result" -eq 0 ]
            then
                :

                # posso criar o png da arvore gerada
                dot -Tpng ./cases/etapa3/results/"$filename" -o ./cases/etapa3/results/"$filename".png > /dev/null 2>&1
            
            fi
            ok=$((ok + 1))

            

            # como deu certo, verifico se as arvores geradas sao iguais
            python3 compare_trees.py ./cases/etapa3/results/"$filename" ./cases/etapa3/professor/"$filename".ref.dot

            result2=$?
            if [ "$result2" -eq 0 ]
            then
                eq=$((eq + 1))
            else
                neq=$((neq + 1))
                echo "                  ] caso $filename: arvore diferente"
            fi
            


        else
            # se o retorno do codigo c foi igual ao esperado
            # ou seja, um leak
            echo "                  > caso $filename: leak"
            err=$((err + 1))
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