%.o: %.c
	gcc -c $<

parser.tab.c parser.tab.h: parser.y
	bison -d -v parser.y

lex.yy.c: scanner.l
	flex scanner.l

lex.yy.o: lex.yy.c parser.tab.h
	gcc -c lex.yy.c

main.o: main.c parser.tab.h asd.h
	gcc -c main.c

clean:
	-rm *.o lex.yy.c parser.tab.c parser.tab.h etapa* parser.output

# === Etapa 1 ===
etapa1:  lex.yy.o main.o
	gcc -o etapa1 lex.yy.o main.o

package1:
	tar cvzf etapa1.tgz *.c *.h scanner.l Makefile

# === Etapa 2 ===
etapa2: parser.tab.o lex.yy.o main.o
	gcc -o etapa2 parser.tab.o lex.yy.o main.o

package2:
	tar cvzf etapa2.tgz etapa2 *.c *.h *.y scanner.l Makefile

# === Etapa 3 ===
etapa3: parser.tab.o lex.yy.o main.o asd.o
	gcc -o etapa3 parser.tab.o lex.yy.o main.o asd.o