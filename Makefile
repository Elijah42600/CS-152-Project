#lex.yy.c: 
#	flex 862090863.lex
#
#lexer: lex.yy.c
#	gcc -o lexer lex.yy.c y.tab.c -lfl
#

OBJS	= bison.o lex.o main.o

CC	= g++
CFLAGS	= -g -Wall -ansi -pedantic

parser:		$(OBJS)		
		$(CC) $(CFLAGS) $(OBJS) -o parser -lfl

lex.o:		lex.c
		$(CC) $(CFLAGS) -c lex.c -o lex.o

lex.c:		862090863.lex
		flex 862090863.lex
		cp lex.yy.c lex.c

bison.o:	bison.c
		$(CC) $(CFLAGS) -c bison.c -o bison.o

bison.c:	mini_l.y 
		bison -d -dy -v mini_l.y
		cp y.tab.c bison.c
		cmp -s y.tab.h tok.h || cp y.tab.h tok.h

main.o:		main.c
		$(CC) $(CFLAGS) -c main.c -o main.o
	
lex.o yac.o main.o:	heading.h

lex.o main.o:	tok.h

clean: 		
		rm -f *.o *~ lex.c lex.yy.c bison.c tok.h y.tab.c y.tab.h y.output parser
