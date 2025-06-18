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

declare -A passed_by_type
declare -A failed_by_type

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

# Function to map code to label
label_error() {
    case "$1" in
        10) echo "ERR_UNDECLARED" ;;
        11) echo "ERR_DECLARED" ;;
        20) echo "ERR_VARIABLE" ;;
        21) echo "ERR_FUNCTION" ;;
        30) echo "ERR_WRONG_TYPE" ;;
        40) echo "ERR_MISSING_ARGS" ;;
        41) echo "ERR_EXCESS_ARGS" ;;
        42) echo "ERR_WRONG_TYPE_ARGS" ;;
        *) echo "?" ;;
    esac
}

for case in ./gabarito/cases/q*
do
    filename=$(basename "$case")
    # echo "EXECUTANDO $filename"

        return_expected=1 
        line=$(head -n 1 "$case")
        return_expected=$(get_expected_return $line)
        expected_label=$(label_error "$return_expected")         
       
        touch ./cases/etapa4/results/"$filename"
        > ./cases/etapa4/results/"$filename"
        # 2>&1 manda tanto o stderr quanto stdout
        ./../../compilers/etapa4 < "$case" >> ./cases/etapa4/results/"$filename" 2>&1

        # captura resultado aqui, logo apos execucao
        result=$?
        result_label=$(label_error "$result")

        # se o retorno do codigo c foi igual ao esperado
        if [ "$result" -eq "$return_expected" ]
        then
            
            ok=$((ok + 1))          
            passed_by_type["$expected_label"]=$((passed_by_type["$expected_label"] + 1))
        
        else
            # se o retorno do codigo c nao foi igual ao esperado
            # ou seja, um leak OU
            # so pegamos o erro errado
            err=$((err + 1))
            failed_by_type["$expected_label"]=$((failed_by_type["$expected_label"] + 1))
    

            if 
               [ "$return_expected" -eq 10 ]             ||  
               [ "$return_expected" -eq 11 ]             ||
               [ "$return_expected" -eq 21 ]
            # se eu queria que fosse 
            # ERR_UNDECLARED | ERR_DECLARED | ERR_FUNCTION
            then
                echo "CASE $filename"
                returned_label=$(label_error "$result")
                echo "  > expecting $return_expected ($expected_label)"
                echo "      > returned $result ($returned_label)"
                echo ""
            fi
        fi  

done

echo "====="
echo "SUMMARY:"
echo "====="
echo "ok: $ok"
echo "error: $err"

echo "==========================="
echo "Detailed by Error Type:"
echo "==========================="

all_error_types=("ERR_UNDECLARED" "ERR_DECLARED" "ERR_VARIABLE" "ERR_FUNCTION" "ERR_WRONG_TYPE" "ERR_MISSING_ARGS" "ERR_EXCESS_ARGS" "ERR_WRONG_TYPE_ARGS" "SUCCESS")

for error in "${all_error_types[@]}"; do
    pass=${passed_by_type[$error]:-0}
    fail=${failed_by_type[$error]:-0}
    total=$((pass + fail))
    if [ "$total" -gt 0 ]; then
        echo "[$(printf '%-20s' "$error")] $(printf '%-17s' "Total: $total ($pass/$total)") | ✅: $(printf '%2s' "$pass") | ❌: $(printf '%2s' "$fail")"
    fi
done


echo "==========================="