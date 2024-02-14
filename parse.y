%{
extern int yylex();
extern int yyparse();
extern void yyerror(const char* s);

void create_table(){
 }
void delete_table(){
 }
void modify_table(){
 }
void show_table(){
 }
void execute_function(){
 }

%}


%union {
    char *str;
}
%token <str> CREATE DELETE MODIFY SHOW EXECUTE PLUS NEWLINE;
%type <str> create_table;
%type <str> delete_table;
%type <str> modify_table;
%type <str> execute_function;
%type <str> show_table;
%type <str> newline;
%type <str> modify_and_create;
%type <str> instruction;


%%

input: newline | instructions newline ;

instructions: instruction
| instructions instruction
;

instruction:  create_table |  delete_table |  modify_table 
|   show_table |  execute_function |  modify_and_create   ;

create_table: CREATE {$$ = $1; create_table();}
delete_table: DELETE {$$ = $1;delete_table();}
modify_table: MODIFY {$$ = $1;modify_table();}
show_table: SHOW {$$ = $1;show_table();}
modify_and_create: modify_table PLUS create_table  {$$ = $1;};  
execute_function: EXECUTE {$$ = $1;execute_function();}
newline: NEWLINE {$$ = $1;}

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
