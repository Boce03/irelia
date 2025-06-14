%option noyywrap

%{
    #include <iostream>
    #include <cstdlib>
    #include <cstdio>
    #include <string>

    #include "parser.tab.hpp"
    
    #define FILE_NAME (256)

    extern void yyerror(const std::string& s);

    typedef enum{
        NONE,
        OPTION,
        EXECUTE
    }State;

    State state = NONE;
%}

%x execute_s
%x option_s

%%

\.(config|CONFIG) {
    state = OPTION;
    return CONFIG_T;
}

<option_s>-[^ \t\n] {
    yylval.s = new std::string(yytext);
    return OPTION_T;
} 

<option_s>[ \t] { }

\.(target|TARGET) {
    return TARGET_T;
}


[^ \t\n/\0:>] {
    if (std::strlen(yytext) > FILE_NAME) {
        yyerror("file name exceeds file name limit of 256 characters");
    }

    yylval.s = new std::string(yytext);
    return FILE_T;    
}

">"[ \t]* {
    state = EXECUTE;
    BEGIN(execute_s);
    return '>';
}

<execute_s>[^\n] {
    yylval.s = new std::string(yytext);
    return EXECUTE_T;
}

<option_s, execute_s>"\n" {
    state = NONE;
    BEGIN(INITIAL);
    return SEP_T;
}

: {
    if (state == OPTION) {
        BEGIN(option_s);
    }

    return *yytext;
}

"\n" {
    return SEP_T;
}

<*><<EOF>> {
    return SEP_T;
}

[ \t] { }

. {
    yyerror("invalid character");
}

%%