# compilers

Como rodar os testes:

```
cd testing
./run_cases.sh
```

# Etapa 3

Como visualizar a arvore gerada:
```
./etapa3 < ./testing/cases/etapa2/asl017 > graph.dot
dot -Tpng graph.dot -o graph.png
```