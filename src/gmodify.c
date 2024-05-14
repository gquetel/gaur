
#include <gmodify.h>
#include <dll.h>
#include <regex.h>
#include <errno.h>

#define MAX_FLAG_SIZE 32
#define MAX_SIZE_NTERM 100
#define MAX_SIZE_CODE 10000
#define MAX_SIZE_RULE 100000
#define MAX_SIZE_JSON 64000

#define PATH_SKELETON "gaur_mysql.c"

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

/* --------------- Loading JSON file from pygaur --------------- */

char *read_semantic_file()
{
    char *b_json = NULL;
    /* Read JSON file in buffer for cJSON*/
    if (fseek(f_semantics, 0, SEEK_END) != 0)
    {
        perror("Error while looking for EOF of tagging file");
        exit(EXIT_FAILURE);
    }
    size_t filesize = ftell(f_semantics);
    if (filesize < 0)
    {
        perror("Error while getting size of tagging file");
        exit(EXIT_FAILURE);
    }
    if (fseek(f_semantics, 0, SEEK_SET) != 0)
    {
        perror("Error while setting pointer to begining of tagging file");
        exit(EXIT_FAILURE);
    }
    b_json = (char *)malloc((size_t)filesize + sizeof(""));
    if (b_json == NULL)
    {
        perror("Error while allocating memory for JSON buffer");
        exit(EXIT_FAILURE);
    }

    if (fread(b_json, sizeof(char), (size_t)filesize, f_semantics) != filesize)
    {
        free(b_json);
        perror("Error while reading JSON file");
        exit(EXIT_FAILURE);
    }
    b_json[filesize] = '\0';
    return b_json;
}
/**
 * @brief Parse JSON file and inject semantic array in the instrumented grammar file
 * See https://github.com/DaveGamble/cJSON for cJSON documentation and usage
 */
void p_semantic_array_from_json()
{
    // TODO: Maybe find some place to verify size of flags is both consistant and valid (1-32)

    /* Read json file and init data structures */
    char *b_json = read_semantic_file();
    cJSON *parsed = cJSON_Parse(b_json);
    if (parsed == NULL)
    {
        const char *error_ptr = cJSON_GetErrorPtr();
        if (error_ptr != NULL)
        {
            fprintf(stderr, "Error before: %s\n", error_ptr);
        }
        exit(EXIT_FAILURE);
    }

    if (b_json != NULL)
    {
        free(b_json);
    }

    const cJSON *general = NULL;
    const cJSON *rules = NULL;
    const cJSON *flags_number = NULL;

    cJSON *flags_array = NULL;
    cJSON *rule_name = NULL;
    cJSON *flag = NULL;
    cJSON *rules_number = NULL;

    /* In the first place, get how many flags are defined in file and how many rules */
    general = cJSON_GetObjectItemCaseSensitive(parsed, "GENERAL");
    if (!cJSON_IsObject(general) || general->child == NULL)
    {
        perror("Error while general field of JSON file");
        exit(EXIT_FAILURE);
    }

    flags_number = cJSON_GetObjectItemCaseSensitive(general, "flags_number");
    if (!cJSON_IsNumber(flags_number))
    {
        perror("Error while reading flags_number field of JSON file");
        exit(EXIT_FAILURE);
    }

    rules_number = cJSON_GetObjectItemCaseSensitive(general, "rules_number");
    if (!cJSON_IsNumber(rules_number))
    {
        perror("Error while reading rules_number field of JSON file");
        exit(EXIT_FAILURE);
    }

    int n_tags = flags_number->valueint;
    int n_rules = rules_number->valueint; /* Total number of rules defined in grammar, used to initialize ggrulesem */

    int rules_counter = 0; /* Counter for comment in ggrulesem array */

    /* Given the amount of tags we will not inject the same content  */
    switch (n_tags)
    {
    case 1: /* action */
        fprintf(f_out, "\n\tstatic const  int32_t ggrulesem[%d] = {\n", n_rules);

        cJSON_ArrayForEach(rules, cJSON_GetObjectItemCaseSensitive(parsed, "RULES"))
        {
            rule_name = cJSON_GetObjectItemCaseSensitive(rules, "name");

            if (!cJSON_IsString(rule_name))
            {
                perror("Error while reading name field of JSON file");
                exit(EXIT_FAILURE);
            }
            flags_array = cJSON_GetObjectItemCaseSensitive(rules, "flags");
            /* This switch case means we only have one flag: we take first elem of array */
            flag = cJSON_GetArrayItem(flags_array, 0);

            if (!cJSON_IsString(flag) || flag->valuestring == NULL)
            {
                perror("Error while reading flags field of JSON file");
                exit(EXIT_FAILURE);
            }

            fprintf(f_out, "\t\t0b%s, /* Rule number: %03d %s */\n", flag->valuestring, rules_counter, rule_name->valuestring);
            rules_counter++;
        }
        fprintf(f_out, "\t};\n");
        break;
    case 2: /* action, assets*/
        fprintf(f_out, "\n\tstatic const  int32_t ggrulesem[%d][2] = {\n", n_rules);
        cJSON_ArrayForEach(rules, cJSON_GetObjectItemCaseSensitive(parsed, "RULES"))
        {
            rule_name = cJSON_GetObjectItemCaseSensitive(rules, "name");

            if (!cJSON_IsString(rule_name))
            {
                perror("Error while reading name field of JSON file");
                exit(EXIT_FAILURE);
            }
            flags_array = cJSON_GetObjectItemCaseSensitive(rules, "flags");
            /* We have two elements: an action at index 0 of array flags and
             an object at index 1 of arrray flags */

            flag = cJSON_GetArrayItem(flags_array, 0);
            if (!cJSON_IsString(flag) || flag->valuestring == NULL)
            {
                perror("Error while reading flags field of JSON file");
                exit(EXIT_FAILURE);
            }
            fprintf(f_out, "\t\t{0b%s,", flag->valuestring); /* print action flag */

            flag = cJSON_GetArrayItem(flags_array, 1);
            if (!cJSON_IsString(flag) || flag->valuestring == NULL)
            {
                perror("Error while reading flags field of JSON file");
                exit(EXIT_FAILURE);
            }
            fprintf(f_out, "0b%s}, /* Rule number: %03d %s */\n", flag->valuestring, rules_counter, rule_name->valuestring);
            rules_counter++;
        }
        fprintf(f_out, "\t};\n");
        break;

    default:
        errno = EINVAL;
        perror("Invalid number of tags, must either be 1 or 2");
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

        p_semantic_array_from_json();
        fprintf(f_out, "}\n");
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
