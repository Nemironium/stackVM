.PHONY: all clean rebuild

TARGET = analyzer
DIR = build
SRCDIR = src
CC = gcc
CFLAGS = -IYaccLex -g -O0
CXX = g++
CXXFLAGS = -std=c++14
LEX = lex 
YACC = yacc 

all: $(TARGET)

$(TARGET):
	mkdir -p $(DIR)
	$(YACC) -d $(SRCDIR)/parser.y -o $(DIR)/y.tab.c
	$(LEX) -o $(DIR)/lex.yy.c $(SRCDIR)/lexer.l
	$(CC) $(DIR)/y.tab.c $(DIR)/lex.yy.c $(CFLAGS) -o $(TARGET)
	$(CXX) $(SRCDIR)/preprocessor.cpp -o preprocessor $(CXXFLAGS)

clean:
	rm -rf $(DIR)
	rm -f $(TARGET)
	rm -f preprocessor

rebuild: clean all