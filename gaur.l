/* Disable warnings about unused functions*/
%option noyywrap noinput nounput nodefault
/* set yy_flex_debug to 1 */
%option debug 
/* Keep track of the line number */
%option yylineno

%{
	#include <string.h>
	#include "gaur.tab.h"

  #define MAX_SIZE_LITERAL 1024

	void yyerror(const char* msg);
  char * val_id;
	char  buf_lit[MAX_SIZE_LITERAL];
%}

/* State after recognizing a first "%%" */
%x SC_GRAMMAR 
/* State after recognizing a second "%%" */
%x SC_EPILOGUE 
/* State after reading an id */
%x SC_AFTER_IDENTIFIER 
/* State after reading simple qutoe which introduce a char literal */
%x SC_CHAR_LITERAL
/* State after reading quotes which introduce a string literal */
%x SC_STRING_LITERAL
/* State after reading a brack in an action */
%x SC_BRACED_CODE
/* State after encountering multi line comment symbol */
%x SC_YACC_COMMENT
/* State after encountering a less than symbol (tag) */
%x SC_TAG
/* State after encountering left bracket than symbol (code) */
%x SC_BOX_BRACKET

letter    [.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_]
id        {letter}({letter}|[-0-9])*
word      [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_]+
eol       \n|\r\n
space     [ \n\t\r]
id_lpar  {id}\(
  
%%

%{
static int first = 1;
static int bracket_count = 0;
static int tag_count = 0;

/* When changing state, this variable helps us to save parent state to return to */
static int current_state = 0;

  if (first)
    {
      buf_lit[0] = '\0';
      first = 0;
      yylineno=0;
      yy_flex_debug=0;
    }	
%}

<INITIAL>{
  
  "%%" {
      BEGIN SC_GRAMMAR;
      return PERCENT_PERCENT;
  }

   \"	{
		strcpy(buf_lit, "");
    current_state = YY_START;
		BEGIN(SC_STRING_LITERAL);
	}  

  . {   
      yylval.prologue = strdup(yytext);
      return STRING_PROLOGUE; 
  }
 
  {eol}  {return NEWLINE;}
  <<EOF>> {
    yyterminate();
    }
}

<SC_GRAMMAR>{
  "%%" {
      BEGIN SC_EPILOGUE; 
      return PERCENT_PERCENT;
  }

  {id} {
    current_state = YY_START;
    BEGIN SC_AFTER_IDENTIFIER;
    val_id = strdup(yytext);
  }

	/* Code detection in rule */
	"{"	 {
    bracket_count = 1;
    BEGIN SC_BRACED_CODE; 
    return L_BRACKET;
  }

	/* String detection*/
	\"	{
		strcpy(buf_lit, "");
    current_state = YY_START;
		BEGIN(SC_STRING_LITERAL);
	}  

	/* Character detection*/
	\' {
		strcpy(buf_lit, "");
    current_state = YY_START;
		BEGIN(SC_CHAR_LITERAL);
	}
  /* tag detection */
  "<"         {
    tag_count=1;
    BEGIN SC_TAG;
    return LESS_THAN;
  }

  /* named reference */
  "[" {
    current_state = YY_START;
    BEGIN SC_BOX_BRACKET;
  }
  "%code"                 {return PERCENT_CODE;}
  "%default-prec"         {return PERCENT_DEFAULT_PREC;}
  "%empty"  						  {return PERCENT_EMPTY;}
  "%no-default-prec"      {return PERCENT_NO_DEFAULT_PREC;}
  "%prec"                 {return PERCENT_PREC;}
  "%printer"              {return PERCENT_PRINTER;}
  "%start"                {return PERCENT_START;}
  "%token"                {return PERCENT_TOKEN;}
  "%type"                 {return PERCENT_TYPE;}
  "%union"                {return PERCENT_UNION;}

  [ \f\t\v\r]|{eol}				{continue;}
  ":"	 							      {return COLON;}
  "|"  							      {return PIPE;}
  ";"  							      {return SEMICOLON;}

	
	.         						  {yyerror("Invalid character");}
	<<EOF>>   						  {yyterminate();}
}

<SC_TAG>{
  "<" {
    tag_count++;
    return LESS_THAN;
  }

  ">" {
    tag_count--;
    if(tag_count == 0){
      BEGIN SC_GRAMMAR;
    }
    return MORE_THAN;
  }

  ([^<>]|->)+ {
    yylval.string_lit = strdup(yytext);
    return TAG;

  }

  <<EOF>> {
    yyterminate();
  }

}

<SC_AFTER_IDENTIFIER>{ 

  "[" {
    yylval.id = val_id;
    BEGIN SC_BOX_BRACKET;
    return ID;
  }

  ":" {
    yyless(0);
    yylval.id = val_id;
    BEGIN SC_GRAMMAR;
    return ID_COLON;
  }

 .|\n {
    yyless(0);
    yylval.id = val_id;
    BEGIN SC_GRAMMAR;
    return ID;
  } 

  <<EOF>> {
    yyterminate();
  }
}

<SC_BOX_BRACKET>{
  {id} {
    val_id = strdup(yytext);
  }

  "]" {
    yylval.id = val_id;
    BEGIN current_state;
    return BRACKETED_ID;
  }

  .|\n {
    yyerror("Invalid character inside box bracket.");
  }

  <<EOF>> {
    yyterminate();
  }
}

<SC_STRING_LITERAL>{
	\"|\\\\\"  {   
		BEGIN(current_state); 
		yylval.string_lit = strdup(buf_lit);   
 		return STRING;
	}

	{eol}  { yyerror("Invalid string literal\n"); }
  
   
	.|\\\" {  strcat(buf_lit,yytext); }
	<<EOF>>  {yyterminate();}
}

<SC_CHAR_LITERAL>{
	\'  {   
		if(strlen(buf_lit) == 0) yyerror("char literal is empty");
		if(strlen(buf_lit) > 1)  {yyerror("extra character in char literal");}

		BEGIN(current_state); 
		yylval.string_lit = strdup(buf_lit);
		return CHAR_LITERAL;
	}

	\\n\'	{
		/* Ulgy hack to accept \n as character and bypass char count */
		strcat(buf_lit, "\\n");
		
		BEGIN(current_state); 
		yylval.string_lit = strdup(buf_lit);
		return CHAR_LITERAL;
	}

  \\0' {
    /* Ulgy hack to accept \0 as character and bypass char count */
		strcat(buf_lit, "\\n");


		BEGIN(current_state); 
		yylval.string_lit = strdup(buf_lit);
		return CHAR_LITERAL;
  }
	
	.  {		
		strcat(buf_lit,yytext);
	}

  {eol}    {yyerror("Unexepected newline");}
	<<EOF>>  {yyterminate();}
}

<SC_BRACED_CODE>{
  /* TODO:
  Action code can be of different languages which can be recognized using the %language directive, see
  https://www.gnu.org/software/bison/manual/html_node/Decl-Summary.html#index-_0025language. Ultimately 
  we might want to pass all action code to a dedicated parser (either C, C++, Java, etc.) to properly 
  extract function calls and other interseting data. */
  "{"    {
    bracket_count++;
    return L_BRACKET;
  }  

  "}" {
    bracket_count--;
    if(bracket_count == 0){
      BEGIN SC_GRAMMAR;
    }
    return R_BRACKET;
  }

  "$$" {
    return DOLLAR_DOLLAR;
  }

  /* Literal detection */
  \"	{
		strcpy(buf_lit, "");
    current_state = YY_START;
		BEGIN(SC_STRING_LITERAL);
	}  
	\' {
		strcpy(buf_lit, "");
    current_state = YY_START;
		BEGIN(SC_CHAR_LITERAL);
	}

  {id_lpar} {
    yyless(yyleng-1); /* return the '('  ti the input stream */
    yylval.code = strdup(yytext);
    return ID_CODE_LPAR;
  }

  {word} { 
    yylval.code = strdup(yytext);
    return ID_CODE;
  }

  . {   
      yylval.code = strdup(yytext);
      return SYMBOL_CODE; 
  }

  {eol}    {return NEWLINE;}
 	<<EOF>>  {yyterminate();}
}

<SC_GRAMMAR,SC_AFTER_IDENTIFIER,SC_BRACED_CODE,INITIAL>{
  /* Comments management */
  "//".*                  {continue;}
  "/*" {
    current_state = YY_START;
    BEGIN SC_YACC_COMMENT;
  }
}

<SC_YACC_COMMENT>{
  "*/"     BEGIN current_state;
  .|{eol}  continue;
  <<EOF>>  yyerror("Unfinished comment");
}

<SC_EPILOGUE>{ 
	.  {   
			yylval.prologue = strdup(yytext);
			return STRING_EPILOGUE; 
	}
  {eol}                     {return NEWLINE;}
  <<EOF>>       {yyterminate(); }
}


%% 

void yyerror(const char* msg) {
  fprintf(stderr, "line %d: %s: '%s'\n", yylineno, msg, yytext);
  exit(1);
}