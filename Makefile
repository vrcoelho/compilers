CC=gcc
DEPS = tokens.h
OBJ = lex.yy.o main.o

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $<

etapa1: $(OBJ)
	$(CC) -o $@ $^

lex.yy.c: scanner.l
	flex scanner.l 

clean:
	-rm *.o lex.yy.c etapa1 etapa1.tgz

package:
	tar cvzf etapa1.tgz *.c *.h scanner.l Makefile