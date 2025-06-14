irelia: parser.o lexer.o
	g++ parser.o lexer.o -o irelia

parser.o: parser.tab.hpp parser.tab.cpp
	g++ -c parser.tab.cpp -o parser.o

lexer.o: lex.yy.c
	g++ -c lex.yy.c -o lexer.o

lex.yy.c: lexer.l parser.tab.hpp
	flex -l lexer.l

parser.tab.hpp parser.tab.cpp: parser.ypp
	bison -d -v -Wcounterexamples parser.ypp

.PHONY: clean

clean:
	rm -rf *.tab.* *.o *.yy.* p*.output irelia