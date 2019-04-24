%{
#include <stdio.h>
#include <string.h>     // char* strdup(const char*) - alloc string and return char *

extern FILE *yyin;
FILE *asmFile;
void push();
void pop();

struct mark
{
    unsigned int mark[120];
	unsigned int number;
};

struct mark label = {0, 0};
int labelCtr = 0;

%}

%start begin



%union {
    int number;
    char *variable;
}

%token <number> NUM
%token <variable> VAR

%token PLUS MINUS MUL DIV MOD
%token WHILE ELIF IF ELSE RETURN PRINT SEMICOLON
%token INC DEC ASSIGN PLUS_ASSIGN MINUS_ASSIGN MULT_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token MORE LESS MORE_EQ LESS_EQ NOTEQ EQ 

%left PLUS MINUS 
%left MUL DIV MOD 

%destructor { free($$); } VAR
%destructor { free($$); } <variable>


%%
begin:                       
    | begin stat;
             
stat:   
    | expr SEMICOLON
    | assign SEMICOLON { printf("\tpop\n"); } 
    | while
    | if_else_elif
    | return SEMICOLON { printf("\tcall return\n");  printf("\tpop\n"); }
    | print SEMICOLON { printf("\tcall print\n"); printf("\tpop\n"); }
    | SEMICOLON
    | '{' begin '}'
    ;

expr:
    '(' expr ')'
    | expr MINUS expr { printf("\tsub\n"); }
    | expr PLUS expr { printf("\tadd\n"); }
	| expr MUL expr { printf("\tmul\n"); }
	| expr DIV expr { printf("\tdiv\n"); }
	| expr MOD expr { printf("\tmod\n"); }
    | NUM { printf("\tpush %d\n", $1); }
    | MINUS NUM { printf("\tpush %d\n", $2); printf("\tneg \n"); }
	| VAR  { printf("\tpush [%s]\n", $1); free($1); }
	| MINUS VAR { printf("\tpush [%s]\n", $2); printf("\tneg \n"); free($2); }
    | VAR INC { printf("\tpush [%s]\n", $1); printf("\tpush [%s]\n", $1); printf("\tpush 1\n"); printf("\tadd\n"); printf("\tstr [%s]\n", $1); printf("\tpop\n"); free($1);} 
	| INC VAR { printf("\tpush [%s]\n", $2); printf("\tpush 1\n"); printf("\tadd\n"); printf("\tstr [%s]\n", $2); free($2); }
	| VAR DEC { printf("\tpush [%s]\n", $1); printf("\tpush [%s]\n", $1); printf("\tpush 1\n"); printf("\tsub\n"); printf("\tstr [%s]\n", $1); printf("\tpop\n"); free($1); }
	| DEC VAR { printf("\tpush [%s]\n", $2); printf("\tpush 1\n"); printf("\tsub\n"); printf("\tstr [%s]\n", $2); free($2); }
    | MINUS VAR DEC { printf("\tpush [%s]\n", $2); printf("\tneg \n"); printf("\tpush [%s]\n", $2); printf("\tpush 1\n"); printf("\tsub\n"); printf("\tstr [%s]\n", $2); printf("\tpop\n"); free($2); }
    | MINUS VAR INC { printf("\tpush [%s]\n", $2); printf("\tneg \n"); printf("\tpush [%s]\n", $2); printf("\tpush 1\n"); printf("\tadd\n"); printf("\tstr [%s]\n", $2); printf("\tpop\n"); free($2); };

assign: 
    VAR ASSIGN assign { printf("\tstr [%s]\n", $1); free($1); }
    | VAR ASSIGN expr { printf("\tstr [%s]\n", $1); free($1); } 

while:
    WHILE '(' while_condition ')' stat { printf("\t\tjmp cycle%d\n", label.mark[label.number] + 1); printf("label%d:\n", label.mark[label.number]);  pop(); }

if_else_elif:
    if_expr elif_expr else_expr {  printf("label%d:\n", label.mark[label.number] + 1);  pop(); }
	| if_expr elif_expr {  printf("label%d:\n", label.mark[label.number] + 1);  pop(); }
	| if_expr else_expr {  printf("label%d:\n", label.mark[label.number] + 1);  pop(); }
	| if_expr {  printf("label%d:\n", label.mark[label.number] + 1); pop(); };

return: 
    RETURN
    | RETURN expr;

print:
    PRINT '(' expr ')';

while_condition:
    condition_expr { printf("\tpush 0\n"); printf("\tcmp\n"); printf("\tpop\n"); printf("\tje label%d\n",label.mark[label.number]);}
	| condition_expr EQ expr { printf("\tcmp\n"); printf("\tpop\n"); printf("\tjz label%d\n", label.mark[label.number]); }
	| condition_expr NOTEQ expr { printf("\tcmp\n"); printf("\tpop\n"); printf("\tje label%d\n", label.mark[label.number]);}
	| condition_expr LESS_EQ expr { printf("\tcmp\n"); printf("\tpop\n"); printf("\tja label%d\n", label.mark[label.number]);}
	| condition_expr MORE_EQ expr {  printf("\tcmp\n"); printf("\tpop\n"); printf("\tjb label%d\n", label.mark[label.number]);}
	| condition_expr LESS expr { printf("\tcmp\n"); printf("\tpop\n");  printf("\tjbe label%d\n", label.mark[label.number]);}
	| condition_expr MORE expr { printf("\tcmp\n"); printf("\tpop\n");  printf("\tjae label%d\n", label.mark[label.number]);}	
	| condition_expr condition_assign condition_expr  { printf("\tpush 0\n"); printf("\tcmp\n"); printf("\tpop\n"); printf("\tjz label%d\n", label.mark[label.number]);}
	| condition_assign { printf("\tpush 0\n"); printf("\tcmp\n"); printf("\tpop\n"); printf("\tjz label%d\n", label.mark[label.number]);}

condition_expr:
    '(' condition_expr ')' { push(); printf("cycle%d:\n", label.mark[label.number]+1); }
	| condition_expr MINUS condition_expr { push(); printf("cycle%d:\n", label.mark[label.number]+1);  printf("\tsub\n"); }
	| condition_expr PLUS condition_expr { push(); printf("cycle%d:\n", label.mark[label.number]+1); printf("\tadd\n"); }
	| condition_expr MUL condition_expr { push(); printf("cycle%d:\n", label.mark[label.number]+1); printf("\tmul\n"); }
	| condition_expr DIV condition_expr { push(); printf("cycle%d:\n", label.mark[label.number]+1); printf("\tdiv\n"); }
	| condition_expr MOD condition_expr { push(); printf("cycle%d:\n", label.mark[label.number]+1); printf("\tmod\n"); }
	| NUM { push(); printf("cycle%d:\n", label.mark[label.number]+1);  printf("\tpush %d\n", $1); }
	| MINUS NUM { push(); printf("cycle%d:\n", label.mark[label.number]+1); printf("\tpush %d\n", $2); printf("\tneg\n"); }
	| VAR  { push(); printf("cycle%d:\n", label.mark[label.number]+1); printf("\tpush [%s]\n", $1); free($1); }
	| MINUS VAR { push(); printf("cycle%d:\n", label.mark[label.number]+1);  printf("\tpush [%s]\n", $2); printf("neg\n"); free($2); }
	| VAR INC { push(); printf("cycle%d:\n", label.mark[label.number]+1); printf("\tpush [%s]\n", $1); printf("\tpush [%s]\n", $1); printf("\tpush 1\n"); printf("add\n"); printf("\tstr [%s]\n", $1); printf("\tpop\n"); free($1); }
	| INC VAR { push(); printf("cycle%d:\n", label.mark[label.number]+1);  printf("\tpush [%s]\n", $2); printf("\tpush 1\n"); printf("\tadd\n"); printf("\tstr [%s]\n", $2); free($2); }
	| VAR DEC { push(); printf("cycle%d:\n", label.mark[label.number]+1);  printf("\tpush [%s]\n", $1); printf("\tpush [%s]\n", $1); printf("\tpush 1\n"); printf("\tsub\n"); printf("\tstr [%s]\n", $1); printf("\tpop\n"); free($1); }
	| DEC VAR { push(); printf("cycle%d:\n", label.mark[label.number]+1);  printf("\tpush [%s]\n", $2); printf("\tpush 1\n"); printf("\tsub\n"); printf("\tstr [%s]\n", $2); free($2); }
	| MINUS VAR INC { push(); printf("cycle%d:\n", label.mark[label.number]+1); printf("\tneg \n"); printf("\tpush [%s]\n", $2); printf("\tpush [%s]\n", $2); printf("\tpush 1\n"); printf("\tadd\n"); printf("\tstr [%s]\n", $2); printf("\tpop\n"); free($2); }
    | MINUS VAR DEC { push(); printf("cycle%d:\n", label.mark[label.number]+1); printf("\tneg \n"); printf("\tpush [%s]\n", $2); printf("\tpush [%s]\n", $2); printf("\tpush 1\n"); printf("\tsub\n"); printf("\tstr [%s]\n", $2); printf("\tpop\n"); free($2); };

condition_assign:
    VAR ASSIGN condition_expr { printf("\tstr [%s]\n", $1); free($1); }
    | VAR ASSIGN condition_assign { printf("\tstr [%s]\n", $1); free($1); }
    ;

if_expr:
	IF '(' if_condition ')' stat { printf("\tjmp label%d\n", label.mark[label.number] + 1); printf("label%d:\n", label.mark[label.number]); }
	;
elif_expr:
	elif_expr { printf("\tjmp label%d\n", label.mark[label.number] + 1); printf("label%d:\n", label.mark[label.number]); }
	| ELIF '(' if_condition ')' stat { printf("\tjmp label%d\n", label.mark[label.number] + 1); printf("label%d:\n", label.mark[label.number]); };

else_expr:
	ELSE stat;

if_condition:
    expr { push(); printf("\tpush 0\n"); printf("\tcmp\n"); printf("\tpop\n"); printf("\tjz label%d\n",label.mark[label.number]);}
	| expr EQ expr { push();  printf("\tcmp\n"); printf("\tpop\n"); printf("\tjz label%d\n", label.mark[label.number]); }
	| expr NOTEQ expr { push();  printf("\tcmp\n"); printf("\tpop\n"); printf("\tje label%d\n", label.mark[label.number]);}
	| expr LESS_EQ expr { push();  printf("\tcmp\n"); printf("\tpop\n"); printf("\tja label%d\n", label.mark[label.number]);}
	| expr MORE_EQ expr { push();  printf("\tcmp\n"); printf("\tpop\n"); printf("\tjb label%d\n", label.mark[label.number]);}
	| expr LESS expr { push(); printf("\tcmp\n"); printf("\tpop\n");  printf("\tjbe label%d\n", label.mark[label.number]);}
	| expr MORE expr { push();  printf("\tcmp\n"); printf("\tpop\n");  printf("\tjae label%d\n", label.mark[label.number]);}	
	| expr assign expr  {push(); printf("\tpush 0\n"); printf("\tcmp\n"); printf("\tpop\n"); printf("\tjz label%d\n", label.mark[label.number]);}
	| assign { push();  printf("\tpush 0\n"); printf("\tcmp\n"); printf("\tpop\n"); printf("\tjz label%d\n", label.mark[label.number]);}
%%

int main(int argc, char const *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "parser: Error, no file. Try ./analyzer.z \"filename.z\"\n");
        return -1;
    }
    if (yyin = fopen(argv[1], "r")) 
        printf("start:\n");
		yyparse();
        if (yyin)
            fclose(yyin);
    else {
        fprintf(stderr, "parser: Error, Cannot open file: \"%s\"\n", argv[1]);
        return -1;
    }
}

void push()
{
	label.number++;
	label.mark[label.number] = label.mark[label.number - 1] + 10*labelCtr;
	labelCtr++;
}
void pop()
{
	label.number--;
}
