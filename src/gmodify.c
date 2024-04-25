
#include <gmodify.h>
#include <dll.h>
#include <regex.h>
#include <errno.h>

#define MAX_FLAG_SIZE 32
#define MAX_SIZE_NTERM 100
#define MAX_SIZE_CODE 10000
#define MAX_SIZE_RULE 100000
#define PATH_SKELETON "gaur_yacc.c"

static FILE *f_out;         /* Modified grammar output file OR nonterminal list */
static FILE *f_inject_code; /* Input file to inject code in prologue*/
static FILE *f_semantics;
static regex_t re_sym;
static regex_t re_terminal;

static bool is_modified_axiom = false;   /* Indicate if the axiom has already been modified */
static bool is_lhs_type_defined = false; /* Indicate if $$ can be used */
static bool is_last_item_action = false; /* To check for mid rule actions */

static int counter_rule = 0; /* Count suffix in extracted data*/
static int counter_mra = 0;  /* Count number of midrule action*/

static char rule_group_buffer[MAX_SIZE_RULE]; /* Store extracted data of whole set of grammar rules*/
static size_t len_rule_group_buffer = 0;

static char action_buffer[MAX_SIZE_CODE];
static size_t len_action_buffer = 0;

char *current_lhs = NULL;

static int gaur_mode = M_DEFAULT;

/* -------------------- INTERNAL FUNCTIONS --------------------*/

/**
 * @brief Internal function to store extracted data of a whole set of rule.
 * We cannot directly output data in file as if a midrule action occurs in a set of rules it will be declared before by bison
 * And we need to keep the same order as bison
 * @param source
 */
void append_rule_group_buffer(char *source)
{
    size_t s_len = strlen(source);

    if (len_rule_group_buffer + s_len < MAX_SIZE_RULE)
    {
        strncat(rule_group_buffer, source, s_len);
        len_rule_group_buffer += s_len;
    }
    else
    {
        printf("append_rule_group_buffer: too small buffer for size %zu",
               (len_rule_group_buffer + s_len));
    }
}
/**
 * @brief Internal function to store extracted data from action code
 *
 * @param source buffer to append to action_buffer
 */
void append_action_buffer(char *source)
{
    size_t s_len = strlen(source);

    if (len_action_buffer + s_len < MAX_SIZE_CODE)
    {
        strncat(action_buffer, source, s_len);
        len_action_buffer += s_len;
    }
    else
    {
        printf("append_action_buffer: too small buffer for size %zu",
               (len_action_buffer + s_len));
    }
}

/* -------------------- INIT Func --------------------*/

void init_output_file(char *fn_out)
{
    f_out = fopen(fn_out, "w");
    if (f_out == NULL)
    {
        perror("Cannot write in output file");
        exit(EXIT_FAILURE);
    }
}

void init_inject_file(char *fn_inject)
{

    f_inject_code = fopen(fn_inject, "r");
    if (f_inject_code == NULL)
    {
        perror("Cannot open file to inject code from");
        printf("%s\n", fn_inject);
        exit(EXIT_FAILURE);
    }
}

void init_semantic_file(char *fn_semantics)
{
    if (fn_semantics != NULL)
    {
        f_semantics = fopen(fn_semantics, "r");
        if (f_semantics == NULL)
        {
            perror("Cannot open file to inject code from");
            exit(EXIT_FAILURE);
        }
    }
}
/* -------------------- GAUR MODES --------------------*/

void set_mode(int mode)
{
    gaur_mode = mode;
}

int get_gaur_mode()
{
    return gaur_mode;
}

/**
 * @brief Print the rules-labels array in the instrumented grammar file.
 * Called by p_functions_definitions
 */
void p_semantic_array()
{
    /* Chech how many tags have been declared, for now we only support 1 or 2*/
    int n_tags = 0;
    int nb_rules = 0;

    if ((n_tags = fgetc(f_semantics)) == EOF)
    {
        perror("Error while reading semantic file");
        exit(EXIT_FAILURE);
    }
    n_tags -= '0';

    /* Semantic array injection */
    switch (n_tags)
    {
    case 1: /* action */
    {
        char b_size_flag[MAX_FLAG_SIZE];
        char b_nterm[MAX_SIZE_NTERM];

        long flag_size;

        /* Skip comma */
        fgetc(f_semantics);

        /* Read until comma or EOF*/
        if (fscanf(f_semantics, "%31[^,]", b_size_flag) != 1)
        {
            perror("Error while reading semantic file");
            exit(EXIT_FAILURE);
        }
        /* Get flag value and checks its validity */
        flag_size = strtol(b_size_flag, NULL, 10);
        if (flag_size > 32 || flag_size < 1)
        {
            perror("Invalid flag size, must be between 1 and 32");
            exit(EXIT_FAILURE);
        }

        /* Read EOL */
        if (fgets(b_nterm, MAX_SIZE_NTERM, f_semantics) == NULL || feof(f_semantics))
        {
            perror("Error while reading semantic file");
            exit(EXIT_FAILURE);
        }

        /* We can start to print array */
        fprintf(f_out, "\nstatic const  int32_t ggrulesem[] = {\n");
        char b_score[MAX_FLAG_SIZE];

        while (!feof(f_semantics) && !ferror(f_semantics))
        {
            // Read SIZE_FLAG-1 first characters (semantic values)
            if (fgets(b_score, flag_size + 1, f_semantics) == NULL)
            {
                if (feof(f_semantics))
                    break; /* In case of newline eof can be triggered here */
                perror("Error while reading semantic file");
                exit(EXIT_FAILURE);
            }

            // Prints comma, comment, name of nontemrinal newline
            if (fgets(b_nterm, MAX_SIZE_NTERM, f_semantics) == NULL || feof(f_semantics))
            {
                perror("Error while reading semantic file");
                exit(EXIT_FAILURE);
            }
            b_nterm[strcspn(b_nterm, "\n")] = 0;
            fprintf(f_out, "\t0b%s, /* Rule number: %03d %s */\n", b_score, nb_rules, b_nterm);
            nb_rules++;
        }
        fprintf(f_out, "};\n}\n");
        break;
    }
    case 2: /* action, object */
        // TODO
        break;
    default:
        errno = EINVAL;
        perror("Invalid number of tags, must either be 1 or 2");
        exit(EINVAL);
        break;
    }
}
/* -------------------- GRAMMAR INSTRUMENTALIZATION --------------------*/
void p_functions_definitions()
{
    if (gaur_mode == M_DEFAULT)
    {
        char ch;
        fprintf(f_out, "\n%%skeleton \"");
        fprintf(f_out, PATH_SKELETON);
        fprintf(f_out, "\"\n");

        fprintf(f_out, "\n%%code{\n\n");
        /* Static inject file */
        while ((ch = fgetc(f_inject_code)) != EOF)
            fputc(ch, f_out);

        p_semantic_array();
    }
}

void print()
{
    if (gaur_mode == M_DEFAULT)
    {
        struct parsed_string *ptr = remove_head();
        while (ptr != NULL)
        {
            fprintf(f_out, ptr->format, ptr->data);
            free(ptr->data);
            free(ptr->format);
            free(ptr);
            ptr = remove_head();
        }
    }
}

void pstr(char *string)
{
    add_tail("%s", string);
}

void pstr_f(char *format, char *string)
{
    add_tail(format, string);
}

void end_group_rule()
{
    is_modified_axiom = true;
    is_lhs_type_defined = false;
    is_last_item_action = false;

    if (gaur_mode == M_EXTRACT)
    {
        append_rule_group_buffer(action_buffer);

        fprintf(f_out, "%s\n", rule_group_buffer);

        strcpy(rule_group_buffer, "");
        strcpy(action_buffer, ",");

        len_rule_group_buffer = 0;
        len_action_buffer = 0;
    }
    if (gaur_mode == M_DOT)
    {
        fprintf(f_out, "\"%s\"[rules=%d];\n", current_lhs, counter_rule);
    }
    free(current_lhs);
    counter_rule = 0;
}

void detected_lhs()
{
    is_lhs_type_defined = true;
}

/* -------------------- DOT FILE  --------------------*/
void init_dot()
{
    if (regcomp(&re_sym, "[a-zA-Z]+(_[a-zA-Z]+)*", REG_EXTENDED | REG_NOSUB) != 0)
    {

        perror("Cannot initialize regex for symbols");
        exit(EXIT_FAILURE);
    }

    fprintf(f_out, "digraph D { concentrate=true \n");
}

int match_symbols(const char *string)
{
    int status;
    /* Match to all symbols (UPPERCASE_ + lowercase_)*/
    status = regexec(&re_sym, string, (size_t)0, NULL, 0);

    if (status != 0)
        return (0);

    return (1);
}

int match_terminals(const char *string)
{
    int status;
    /* Match to all terminals (UPPERCASE_)*/
    status = regexec(&re_terminal, string, (size_t)0, NULL, 0);

    if (status != 0)
        return (0);

    return (1);
}

void add_edge(char *node1, char *node2)
{
    if (get_gaur_mode() == M_DOT)
    {
        if (match_symbols(node2))
            fprintf(f_out, "\"%s\" -> \"%s\";\n", node1, node2);
    }
    free(node2);
}

void end_dot_file()
{
    if (get_gaur_mode() == M_DOT)
    {
        fprintf(f_out, "}");
        fclose(f_out);
    }
    regfree(&re_sym);
    regfree(&re_terminal);
}

/* -------------------- NONTERMINALS EXTRACT --------------------*/

void init_extraction()
{
    strcpy(rule_group_buffer, "");
    strcpy(action_buffer, ",");

    if (regcomp(&re_terminal, "[A-Z]+(_[A-Z]+)*", REG_EXTENDED | REG_NOSUB) != 0)
    {

        perror("Cannot initialize regex for nonterminals");
        exit(EXIT_FAILURE);
    }
}

void extract_nterm(char *nterm)
{
    current_lhs = strdup(nterm);
    if (gaur_mode == M_EXTRACT)
    {
        char tmp[MAX_SIZE_NTERM];
        snprintf(tmp, sizeof(tmp), "%s.%d,", nterm, counter_rule);
        append_rule_group_buffer(tmp);
    }
    counter_rule++;
}

void extract_action(char *action_literal)
{
    if (gaur_mode == M_EXTRACT)
    {
        char tmp[MAX_SIZE_CODE];
        snprintf(tmp, sizeof(tmp), " %s", action_literal);
        append_action_buffer(tmp);
    }
}

void extract_terminal(char *string)
{
    if (gaur_mode == M_EXTRACT && match_terminals(string))
    {
        char tmp[MAX_SIZE_CODE];
        snprintf(tmp, sizeof(tmp), "%s ", string);
        append_rule_group_buffer(tmp);
    }
}

void signal_new_rule(char *nterm)
{
    if (gaur_mode == M_EXTRACT)
    {
        char tmp[2];
        append_rule_group_buffer(action_buffer);
        strcpy(action_buffer, ",");

        strcpy(tmp, "\n");
        append_rule_group_buffer(tmp);
    }
    extract_nterm(nterm);
    is_last_item_action = false;
}

void signal_action()
{
    is_last_item_action = true;
}

void check_midrule_action()
{
    if (gaur_mode == M_EXTRACT)
    {
        if (is_last_item_action)
        {
            counter_mra++;
            fprintf(f_out, "$@%d\n", counter_mra);
        }
    }
    is_last_item_action = false;
}
