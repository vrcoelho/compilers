CFLAGS += -fsanitize=address
# CFLAGS += -DDEBUG_MESSAGES

parser.tab.c parser.tab.h: parser.y
	bison -d -v --report=all parser.y

lex.yy.c: scanner.l
	flex scanner.l

lex.yy.o: lex.yy.c parser.tab.h internals.h
	gcc $(CFLAGS) -c lex.yy.c

main.o: main.c parser.tab.h asd.h internals.h errors.h
	gcc $(CFLAGS) -c main.c

clean:
	-rm *.o lex.yy.c parser.tab.c parser.tab.h etapa* parser.output

# === Etapa 1 ===
etapa1:  lex.yy.o main.o
	gcc $(CFLAGS) -o etapa1 lex.yy.o main.o

package1:
	tar cvzf etapa1.tgz *.c *.h scanner.l Makefile

# === Etapa 2 ===
etapa2: parser.tab.o lex.yy.o main.o
	gcc $(CFLAGS) -o etapa2 parser.tab.o lex.yy.o main.o

package2:
	tar cvzf etapa2.tgz etapa2 *.c *.h *.y scanner.l Makefile

# === Etapa 3 ===
etapa3: parser.tab.o lex.yy.o main.o asd.o internals.o
	gcc $(CFLAGS) -o etapa3 parser.tab.o lex.yy.o main.o asd.o internals.o

package3:
	tar cvzf etapa3.tgz Makefile asd.c asd.h internals.c internals.h *.y *.l main.c tokens.h

# === Etapa 4 ===
etapa4: parser.tab.o lex.yy.o main.o asd.o internals.o
	gcc $(CFLAGS) -o etapa4 parser.tab.o lex.yy.o main.o asd.o internals.o

# === usado pelo professor ===
# === etapa atual
all: etapa3
