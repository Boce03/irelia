%option noyywrap

%{
    #include <iostream>
    #include <cstdlib>
    #include <cstdio>
    #include <string>

    #include "parser.tab.hpp"
    
    #define FILE_NAME (256)

    extern void yyerror(const std::string& s);


    /*
        enums together with state mechanism in flex enable us to sent different tokens
        with same content, but they differ in meaning in our grammar (so we dodge shift/reduce conflicts), and to do different actions on same matched pattern depending on situation (in our case, different flags .CONFIG, :, >)
    */
    typedef enum{
        TARGET,
        ASSET,
        OPTION,
        EXECUTE
    }State;

    State state = TARGET;
%}

%x execute_s
%x option_s

%%

\.(config|CONFIG) {
    state = OPTION;
    return CONFIG_T;
}

<option_s>-[^ \t\n]+ {
    yylval.s = new std::string(yytext);
    return OPTION_T;
} 

<option_s>[ \t] { }

\.(target|TARGET) {
    return GLOBAL_TARGET_T;
}


[^ \t\n/\0:>]+ {
    if (strlen(yytext) > FILE_NAME) {
        yyerror("file name exceeds file name limit of 256 characters");
    }

    yylval.s = new std::string(yytext);
    
    return (state == TARGET)? TARGET_T : ASSET_T;
}

">"[ \t]* {
    state = EXECUTE;
    BEGIN(execute_s);
    return '>';
}

<execute_s>[^\n]* {
    yylval.s = new std::string(yytext);
    return EXECUTE_T;
}

<option_s,execute_s>"\n" {
    state = TARGET;
    BEGIN(INITIAL);
    return '\n';
}

: {
    if (state == OPTION) {
        BEGIN(option_s);
    } else if (state == TARGET) {
        state = ASSET;
    }

    return *yytext;
}

"\n" {
    if (state == ASSET) {
        state = TARGET;
    }

    return *yytext;
}

[ \t] { }

. {
    yyerror("invalid character");
}

%%