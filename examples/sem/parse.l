%option noyywrap noinput nounput nodefault

%{
    #include <stdio.h>
    #include "parse.h"
    	void yyerror(const char* msg);
%}

%%

create|CREATE { yylval.str = strdup(yytext)  ;return  CREATE;}
delete|DELETE { yylval.str = strdup(yytext) ;return DELETE ;}
execute|EXECUTE { yylval.str = strdup(yytext) ;return EXECUTE ;}
modify|MODIFY {yylval.str = strdup(yytext)  ;return MODIFY ;}
show|SHOW {  yylval.str = strdup(yytext);return SHOW ;}
\n|\r\n  {yylval.str = strdup(yytext);return NEWLINE;}
"+" { return PLUS;}
[ \t]+   {continue;}


