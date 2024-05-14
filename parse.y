%{
  #include <string.h>
  #include <stdlib.h>
extern int yylex();
extern int yyparse();
extern void yyerror(const char* s);

void create_table(char * str){
  free(str);
 }
void delete_table(char * str){
  free(str);
 }
void modify_table(char * str){
  free(str);
 }
void show_table(char * str){
  free(str);
 }
void execute_function(char * str){
  free(str);
 }

 void newline(char * str){
  free(str);
 }

%}


%union {
    char *str;
}

%token <str> CREATE DELETE MODIFY SHOW EXECUTE PLUS NEWLINE;
%type  create_table;
%type  delete_table;
%type  modify_table;
%type  execute_function;
%type  show_table;
%type  newline;
%type  modify_and_create;
%type  instruction;


%%

input: newline | instructions newline ;

instructions: instruction
| instructions instruction
;

instruction:  create_table |  delete_table |  modify_table 
|   show_table |  execute_function |  modify_and_create   ;

create_table: CREATE {create_table($1);}
delete_table: DELETE {delete_table($1);}
modify_table: MODIFY {modify_table($1);}
show_table: SHOW {show_table($1);}
modify_and_create: modify_table PLUS create_table    
execute_function: EXECUTE {execute_function($1);}
newline: %empty | NEWLINE  {newline($1);}

%% 
void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}

int
main (int argc, char const* argv[])
{
    #ifdef YYDEBUG
    yydebug = 0;
  #endif

  /* Enable parse traces on option -p.  */
  for (int i = 1; i < argc; ++i)
    if (!strcmp (argv[i], "-p"))
      yydebug = 1;
  return yyparse ();
}
