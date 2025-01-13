/* C declaration */
%{ 
  #include <errno.h>
  #include <getopt.h>
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h> 
 
  #include <gmodify.h>

  #define OUTPUT_FILENAME "gaur.modified.y"
  #define INJECT_FILENAME "/usr/local/gaur/src/injects/inject.c"
  #define EXTRACT_FILENAME "nterm_list.csv"

  extern int yylex();
  extern int yyparse();
  extern void yylex_destroy();
  extern void yyerror(const char* s);
  extern FILE* yyin;
  char *latest_id_colon;
  char* latest_symbol;  
%}

/* YACC Declarations */
%expect 0
%verbose
%union{
  char *prologue;
  int int_lit;
  char* epilogue;
  char* code;
  char* string_tag;

  char* id;
  char* string_lit;
}

%token <epilogue>     STRING_EPILOGUE
%token <prologue>     STRING_PROLOGUE
%token <code>         ID_CODE_LPAR
%token <code>         ID_CODE
%token <code>         SYMBOL_CODE
%token <string_lit>   TAG
%token <id>           ID  
%token <id>           ID_COLON             
%token <string_lit>   STRING           
%token <string_lit>   CHAR_LITERAL     
%token <int_lit>      INT_LITERAL    
%token <id>           BRACKETED_ID       
%token                L_BRACKET  
%token                R_BRACKET  
%token
  TSTRING             _("translatable string")
  PERCENT_TOKEN       "%token"
  PERCENT_NTERM       "%nterm"
  PERCENT_TYPE        "%type"
  PERCENT_DESTRUCTOR  "%destructor"
  PERCENT_PRINTER     "%printer"
  PERCENT_LEFT        "%left"
  PERCENT_RIGHT       "%right"
  PERCENT_NONASSOC    "%nonassoc"
  PERCENT_PRECEDENCE  "%precedence"
  PERCENT_PREC        "%prec"
  PERCENT_DPREC       "%dprec"
  PERCENT_MERGE       "%merge"
  PERCENT_CODE            "%code"
  PERCENT_DEFAULT_PREC    "%default-prec"
  PERCENT_EXPECT          "%expect"
  PERCENT_EXPECT_RR       "%expect-rr"
  PERCENT_NO_DEFAULT_PREC "%no-default-prec"
  PERCENT_START           "%start"
  BRACED_PREDICATE  "%?{...}"
  COLON             ":"
  DOLLAR_DOLLAR     "$$"
  PERCENT_PERCENT   "%%"
  PIPE              "|"
  SEMICOLON         ";"
  TAG_ANY           "<*>"
  TAG_NONE          "<>"
  LESS_THAN         "<"
  MORE_THAN         ">"
  PERCENT_EMPTY "%empty"
  PERCENT_UNION "%union"
  PERCENT_PARAM "%param"
  NEWLINE       "\n";
  
%%
/* Grammar rules */

 
input:
  prologue {print(); p_functions_definitions();}PERCENT_PERCENT {pstr("\n%%\n\n");} grammar epilogue {print(); end_print();}
;

prologue: %empty
| prologue NEWLINE {pstr("\n");}
| prologue STRING_PROLOGUE {pstr($2); free($2);}
| prologue STRING {pstr_f("\"%s\"", $2); free($2);}
;

epilogue:  %empty
| epilogue PERCENT_PERCENT  {pstr("\n%%\n\n");}
| epilogue NEWLINE {pstr("\n");}
| epilogue STRING_EPILOGUE {pstr($2); free($2);}
;

/* BISON Declaration */
grammar_declaration: symbol_declaration
| code_props_type L_BRACKET {pstr("{");}  code R_BRACKET {pstr("}");} generic_symlist
| PERCENT_CODE L_BRACKET {pstr("{");}  code R_BRACKET {pstr("}");}
| PERCENT_CODE ID L_BRACKET {pstr("{");}  code R_BRACKET {pstr("}");}
| PERCENT_UNION {pstr("%union");} union_name L_BRACKET {pstr("{");}  code R_BRACKET {pstr("}");}
| PERCENT_DEFAULT_PREC {pstr("%default-prec ");}
| PERCENT_NO_DEFAULT_PREC {pstr("%no-default-prec ");}
| PERCENT_START {pstr("%start");} symbols.1
;

code:  %empty
| code NEWLINE  {pstr("\n");}
| code L_BRACKET {pstr("{");}  code R_BRACKET {pstr("}");}
| code ID_CODE {pstr($2); free($2);}
| code SYMBOL_CODE {pstr($2);  free($2);}
| code STRING {pstr_f("\"%s\"", $2); free($2);}
| code CHAR_LITERAL {pstr_f("\'%s\'", $2);free($2);}
| code DOLLAR_DOLLAR {pstr("$$"); detected_lhs();}
| code ID_CODE_LPAR {pstr($2); extract_function_calls($2); free($2);}
;

code_props_type: PERCENT_DESTRUCTOR {pstr("%destructor");}
| PERCENT_PRINTER {pstr("%printer");}
;

union_name: %empty
| ID {pstr_f("\"%s\"", $1);free($1);}
;

symbol_declaration: PERCENT_NTERM {pstr("%nterm");} nterm_decls
| PERCENT_TOKEN {pstr("%token ");} token_decls
| PERCENT_TYPE {pstr("%type ");} symbol_decls
| precedence_declarator token_decls_for_prec
;

precedence_declarator: PERCENT_LEFT{pstr("%right ");}
| PERCENT_RIGHT {pstr("%left ");}
| PERCENT_NONASSOC  {pstr("%nonassoc ");}
| PERCENT_PRECEDENCE {pstr("%precedence ");}
;

tag.opt: %empty 
| LESS_THAN {pstr("<");} TAG {pstr($3);free($3);}  MORE_THAN {pstr(">");}
;

generic_symlist: generic_symlist_item
| generic_symlist generic_symlist_item
;

generic_symlist_item: symbol
| tag
;

tag: LESS_THAN {pstr("<");} TAG {pstr($3);free($3);}  MORE_THAN {pstr(">");}
| TAG_ANY {pstr("<*>");}
| TAG_NONE {pstr("<>");}
;


nterm_decls: token_decls
;

token_decls: token_decl.1 
| LESS_THAN {pstr("<");} TAG {pstr($3);free($3);}  MORE_THAN {pstr(">");} token_decl.1 
| token_decls  TAG token_decl.1 
;

token_decl.1: token_decl
| token_decl.1 token_decl
;

token_decl: id int alias {free(latest_symbol);}
;

int : %empty
| INT_LITERAL
;

alias: %empty
| STRING {pstr_f("\"%s\"", $1);free($1);}
| TSTRING 
;

token_decls_for_prec: token_decl_for_prec.1
| TAG token_decl_for_prec.1
| token_decl_for_prec TAG token_decl_for_prec.1
;

token_decl_for_prec: id int {free(latest_symbol);}
| STRING
;

token_decl_for_prec.1: token_decl_for_prec
| token_decl_for_prec.1 token_decl_for_prec
;
 
symbol_decls: symbols.1
| LESS_THAN {pstr("<");} TAG {pstr($3);free($3);}  MORE_THAN {pstr(">");} symbols.1 
| symbol_decls LESS_THAN {pstr("<");} TAG {pstr($4);free($4);}  MORE_THAN {pstr(">");} symbols.1 
;


symbols.1: symbol
| symbols.1 symbol
;

grammar: rules_or_grammar_declaration 
| grammar  rules_or_grammar_declaration
;

rules_or_grammar_declaration: rules {pstr("\n\n");}
| grammar_declaration SEMICOLON {pstr(";\n\n");}
;

/* ID_COLON ([ID]) COLON rules */
rules: ID_COLON { 
        pstr($1);
        latest_id_colon = strdup($1); 
        extract_lhs(latest_id_colon);
        free($1);} 
  named_ref COLON  {pstr(":\n");} 
  rhses.1  {free(latest_id_colon);end_group_rule();}
;

/* Recognizes the right-hand side of a rule */
rhses.1:  rhs  
| rhses.1 PIPE {pstr("\n|");  signal_new_rule(latest_id_colon);}  rhs 
| rhses.1 SEMICOLON {pstr("\n;");}  
;

/*Recognize the components of one rule*/
rhs: %empty 
| rhs tag.opt L_BRACKET {pstr("{"); } code R_BRACKET {signal_action(); pstr("}");} named_ref
| rhs symbol named_ref {extract_rhs_content(latest_symbol); add_edge(latest_id_colon,latest_symbol);check_midrule_action();}
| rhs PERCENT_EMPTY {pstr("%empty ");check_midrule_action();} 
| rhs PERCENT_PREC {pstr("%prec ");} symbol  {free(latest_symbol);check_midrule_action();}
| rhs PERCENT_MERGE LESS_THAN {pstr("<");} TAG {pstr($5);} MORE_THAN {pstr(">");check_midrule_action();}  
| rhs PERCENT_EXPECT INT_LITERAL {check_midrule_action();}
| rhs PERCENT_DPREC INT_LITERAL {check_midrule_action();}
| rhs BRACED_PREDICATE  {check_midrule_action();}
| rhs PERCENT_EXPECT_RR INT_LITERAL {check_midrule_action();}
;

named_ref: %empty
| BRACKETED_ID {pstr("[");pstr($1);free($1);pstr("]");}  
;

id: ID {latest_symbol = strdup($1);pstr_f("%s ", $1); free($1);}
| CHAR_LITERAL {latest_symbol = strdup($1);pstr_f("'%s' ", $1);free($1);}
;

symbol: id
| STRING {latest_symbol = strdup($1);pstr_f("\"%s\"", $1);free($1);}
;

%% 

int main(int argc, char **argv)
{

#ifdef YYDEBUG
    yydebug = 0;
#endif

    const struct option long_opts[] = {
        {"dot", no_argument, NULL, 'd'},
        {"extract", no_argument, NULL, 'e'},
        {"help", no_argument, NULL, 'h'},
        {"inject", required_argument, NULL, 'i'},
        {"list", required_argument, NULL, 'l'},
        {"output", required_argument, NULL, 'o'},
        {NULL, 0, NULL, 0}};

    char *input_filename = NULL; /* Grammar file to instrumentalize/extract nontemrinals. */
    char *output_filename = OUTPUT_FILENAME;  /* Instrumentalized grammar, or for --extract, nonterminal list file. */
    char *injected_filename = INJECT_FILENAME; /* File to inject as code in grammar prologue.  */

    bool has_semantic_file_provided = false;
    bool has_defined_output = false;

    int optc;

    /* Options parser */
    while ((optc = getopt_long(argc, argv, "defhi:l:o:s:", long_opts, NULL)) != -1)
    {
        switch (optc)
        {
        case 'd':
            set_mode(M_DOT);
            break;

        case 'e':
            // Extract mode, only need to initalize output file
            output_filename = EXTRACT_FILENAME;
            set_mode(M_EXTRACT);
            break;
        
        case 'f':
            output_filename = EXTRACT_FILENAME;
            set_mode(M_EXTRACT_FULL);
            break;

        case 'h':
            fputs(
                "Usage: gaur [options] -l file file \n"
                "Take a YACC grammar as input and output an instrumented version containing our data collector.\n"
                "Options: \n"
                "-d,  --dot               Produce a dot file for the input grammar\n"
                "-e,  --extract           Produce a file used for rule labelisation\n"
                "-h,  --help,             Display this help and exit\n"
                "-i,  --inject=FILE       Path to the prologue code to inject\n"
                "-l,  --list=FILE         Path to the nonterminals semantics list\n"
                "-o,  --output=FILE       Leave output to FILE\n"
                "-s,  --skeleton=FILE     Path to the skeleton file to use to produce by bison to produce the parser code\n"
                "If the option -o is not used, the default output grammar filename is gaur.modified.y\n",
                stdout);
            exit(EXIT_SUCCESS);

        case 'i':
            injected_filename = optarg;
            break;

        case 'l':
            init_semantic_file(optarg);
            has_semantic_file_provided = true;

        case 'o':
            output_filename = optarg;
            has_defined_output = true;
            break;

        case 's':
            init_skeleton_file(optarg);
            break;
        }
    }

    /* Open input grammar file */
    if (argv[optind] == NULL)
    {
        errno = EINVAL;
        perror("No input grammar file provided, try 'gaur --help' for more information");
        exit(errno);
    }

    input_filename = argv[optind];
    yyin = fopen(input_filename, "r");
    if (yyin == NULL)
    {
        fprintf(stderr, "Cannot open file: %s,  %s\n", input_filename, strerror(errno));
        exit(errno);
    }

    if (get_gaur_mode() == M_EXTRACT || get_gaur_mode() == M_EXTRACT_FULL)
    {
        init_output_file(output_filename);
        init_extraction();
    }

    if (get_gaur_mode() == M_DOT)
    {
        if (has_defined_output)
        {
            init_output_file(output_filename);
        }
        else
        {
            init_output_file(DOT_FILE_NAME);
        }

        init_dot();
    }

    if (get_gaur_mode() == M_DEFAULT)
    {
        init_output_file(output_filename);
        init_inject_file(injected_filename);
        if (!has_semantic_file_provided)
        {
            errno = EINVAL;
            perror("No semantic file provided, try 'gaur --help' for more information");
            exit(errno);
        }
    }

    int result = yyparse();
    fclose(yyin);
    yylex_destroy();    /* Function call to clean heap usage, defined by flex. */
    return result;
}
