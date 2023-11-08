%option noyywrap noinput nounput nodefault

%{
    #include <stdio.h>
    #include "parse.h"
    	void yyerror(const char* msg);
%}

%%

create|CREATE {   return  CREATE;}
delete|DELETE {   return DELETE ;}
execute|EXECUTE {  return EXECUTE ;}
modify|MODIFY {  return MODIFY ;}
show|SHOW {  return SHOW ;}
\n|\r\n  {return NEWLINE;}
"+" { return PLUS;}
[ \t]+   {continue;}


