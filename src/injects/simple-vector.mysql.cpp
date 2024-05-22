#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

typedef struct _node_pt
{
    int rule_number;
    int rule_action;
    int rule_asset;
    struct _node_pt *next;
} _Node_pt;

#define GAUR_PARSE_BEGIN(size, thd)  \
    struct _node_pt *first = NULL;   \
    struct _node_pt *current = NULL; \
    int terminal_c = 0;              \
    int nonterminal_c = 0;           \
    uint64_t ggid = thd->query_id;

#define GET_ACTION_TAG(i) (ggrulesem[i - 2][0])
#define GET_ASSET_TAG(i) (ggrulesem[i - 2][1])

#define GAUR_SHIFT(yytoken)                                          \
    do                                                               \
    {                                                                \
        if (yytoken == YYSYMBOL_YYEOF)                               \
            create_logentry(first, ggid, terminal_c, nonterminal_c); \
        terminal_c++;                                                \
    } while (0);

#define GAUR_REDUCE(nrule, yylen)                                               \
    do                                                                          \
    { /* We substract 1 to nrule because of the bison accept rule offset*/      \
        if (first == NULL)                                                      \
        {                                                                       \
            first = (struct _node_pt *)malloc(sizeof(struct _node_pt));         \
            first->rule_action = GET_ACTION_TAG(nrule);                         \
            first->rule_number = nrule - 1;                                     \
            first->rule_asset = GET_ASSET_TAG(nrule);                           \
            first->next = NULL;                                                 \
            current = first;                                                    \
        }                                                                       \
        else                                                                    \
        {                                                                       \
            current->next = (struct _node_pt *)malloc(sizeof(struct _node_pt)); \
            current = current->next;                                            \
            current->rule_action = GET_ACTION_TAG(nrule);                       \
            current->rule_asset = GET_ASSET_TAG(nrule);                         \
            current->rule_number = nrule - 1;                                   \
            current->next = NULL;                                               \
        }                                                                       \
        nonterminal_c++;                                                        \
    } while (0)

enum
{
    // Hopefully, temporary
    _CREATE = 1 << 4,
    _DELETE = 1 << 3,
    _EXECUTE = 1 << 2,
    _MODIFY = 1 << 1,
    _READ = 1 << 0,
};

static struct
{
    int value;
    const char *name;
} _actions_mapping[] = {
    {_CREATE, "CREATE"},
    {_DELETE, "DELETE"},
    {_EXECUTE, "EXECUTE"},
    {_MODIFY, "MODIFY"},
    {_READ, "READ"},
};

enum
{
    _TABLE = 1 << 10,
    _INDEX = 1 << 9,
    _VIEW = 1 << 8,
    _USER = 1 << 7,
    _PROCEDURE = 1 << 6,
    _DATABASE = 1 << 5,
    _FUNCTION = 1 << 4,
    _INSTANCE = 1 << 3,
    _LOGFILE = 1 << 2,
    _SERVER = 1 << 1,
    _TRIGGER = 1 << 0,

};

static struct
{
    int value;
    const char *name;
} _assets_mapping[] = {
    {_TABLE, "TABLE"},
    {_INDEX, "INDEX"},
    {_VIEW, "VIEW"},
    {_USER, "USER"},
    {_PROCEDURE, "PROCEDURE"},
    {_DATABASE, "DATABASE"},
    {_FUNCTION, "FUNCTION"},
    {_INSTANCE, "INSTANCE"},
    {_LOGFILE, "LOGFILE"},
    {_SERVER, "SERVER"},
    {_TRIGGER, "TRIGGER"},
};

/**
 * @brief Create the log entry corresponding to parsed input.
 *
 * @param first
 */
void create_logentry(struct _node_pt *first, uint64_t query_id, int terminal_c, int nonterminal_c)
{
    const char *output_name = "gaur.log";
    FILE *f_logs = fopen(output_name, "a");
    if (f_logs == NULL)
    {
        perror("Gaur: cannot open file to log file");
    }
    else
    {
        struct _node_pt *current = first;
        fprintf(f_logs, "%" PRId64 ",\"", query_id); /* Print Input ID*/
        while (current != NULL)
        { /* Iterate over tree nodes, print their number (given by yyn)*/
            fprintf(f_logs, "%d:", current->rule_number);

            /* Then compare tag with flags and print corresponding action */
            for (size_t i = 0; i < sizeof(_actions_mapping) / sizeof(_actions_mapping[0]); i++)
            {
                if (current->rule_action & _actions_mapping[i].value)
                {
                    fprintf(f_logs, "%s", _actions_mapping[i].name);
                    break;
                }
            }
            /* Same for assets, we want a separator: */
            fprintf(f_logs, ":");
            for (size_t i = 0; i < sizeof(_assets_mapping) / sizeof(_assets_mapping[0]); i++)
            {
                if (current->rule_asset & _assets_mapping[i].value)
                {
                    fprintf(f_logs, "%s", _assets_mapping[i].name);
                    break;
                }
            }
            fprintf(f_logs, "|");
            struct _node_pt *tmp = current;
            current = current->next;
            free(tmp);
        }

        /* Other features */
        fprintf(f_logs, "\",%d,%d\n", terminal_c, nonterminal_c);
        fclose(f_logs);
    }
}
