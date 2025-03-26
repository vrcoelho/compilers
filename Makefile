etapa1: lex.yy.o main.o
	gcc -o etapa1 lex.yy.o main.o

main.o: main.c
	gcc -c main.c

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

lex.yy.c: scanner.l
	flex scanner.l 

clean:
	-rm *.o lex.yy.c etapa1 etapa1.tgz

package:
	tar cvzf etapa1.tgz *.c *.h scanner.l Makefile