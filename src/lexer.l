%{
    #include "y.tab.h"
    int num_lines = 0;
    int ifCtr  = 0;
    int braceCtr = 0;
%}

%%
"\n" ++num_lines;
\s; /* any space symbol ~= [ \f\n\r\t\v] */
"while" return WHILE;
"else if" return ELIF;
"if" { 
        ifCtr++;
        return IF; 
    };
"else" { 
        ifCtr--;
        return ELSE; 
    };
"return" return RETURN;
"print" return PRINT;
[_a-zA-Z]+[a-zA-Z0-9_]* {
    yylval.variable = strdup(yytext);
    return VAR;
    }; 
[0-9]+ {
    yylval.number = atoi(yytext);
    return NUM; 
    };
"-" return MINUS;
"+" return PLUS;
"*" return MUL;
"/" return DIV;
"%" return MOD;
"++" return INC;
"--" return DEC;
"=" return ASSIGN;
"+=" return PLUS_ASSIGN;
"-=" return MINUS_ASSIGN;
"*=" return MULT_ASSIGN;
"/=" return DIV_ASSIGN;
"%=" return MOD_ASSIGN;
">" return MORE;
"<" return LESS;
">=" return MORE_EQ;
"<=" return LESS_EQ;
"!=" return NOTEQ;
"==" return EQ;
";" return SEMICOLON;
"{" {
        braceCtr++;
        return *yytext;
    };
"}" {
        braceCtr--;
        return *yytext;
    };
"(" return *yytext;
")" return *yytext;
["'#@$&?\\~\|`,\^:\.\[\]] { 
    fprintf(stderr, "Syntax Error: unexpected symbol '%c' in line %d\n", *yytext, ++num_lines);
    exit(1);
};
%%



int yyerror() {
    fprintf(stderr, "Error, line %d\n", ++num_lines);
    exit(1);
}

int yywrap() {
    if (braceCtr) {
        fprintf(stderr, "Logical Error: not equal number '{' and '}'\n");
        exit(1);
    }
    if (ifCtr < 0) {
        fprintf(stderr, "Logical Error: number of 'else' is more than 'if'\n");
        exit(1);
    }
    fprintf(stderr, "Analyzer: Everything is correct\n");
    exit(1);
}
