lex.yy.c: 
	flex 862090863.lex

lexer: lex.yy.c
	gcc -o lexer lex.yy.c -lfl

clean: 
	rm -f *.o lex.c lex.yy.c tok.h y.tab.c y.tab.h y.output lexer
