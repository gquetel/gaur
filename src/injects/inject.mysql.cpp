#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#define LOG_ENV "GAUR_LOGFILE"

typedef struct _node_pt
{
    int rule_number;
    int rule_semantic;
    struct _node_pt *next;
} _Node_pt;

#define GAUR_PARSE_BEGIN(size, thd)  \
    struct _node_pt *first = NULL;   \
    struct _node_pt *current = NULL; \
    uint64_t ggid = thd->query_id;

#define MARK_N(i) (ggrulesem[i - 2])

#define GAUR_SHIFT(yytoken)               \
    do                                    \
    {                                     \
        if (yytoken == YYSYMBOL_YYEOF)    \
            create_logentry(first, ggid); \
    } while (0);

#define GAUR_REDUCE(nrule, yylen)                                               \
    do                                                                          \
    { /* We substract 1 to nrule because of the bison accept rule offset */     \
        if (first == NULL)                                                      \
        {                                                                       \
            first = (struct _node_pt *)malloc(sizeof(struct _node_pt));         \
            first->rule_semantic = MARK_N(nrule);                               \
            first->rule_number = nrule - 1;                                     \
            first->next = NULL;                                                 \
            current = first;                                                    \
        }                                                                       \
        else                                                                    \
        {                                                                       \
            current->next = (struct _node_pt *)malloc(sizeof(struct _node_pt)); \
            current = current->next;                                            \
            current->rule_semantic = MARK_N(nrule);                             \
            current->rule_number = nrule - 1;                                   \
            current->next = NULL;                                               \
        }                                                                       \
    } while (0)

enum
{
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
} _sem_mapping[] = {
    {_CREATE, "CREATE"},
    {_DELETE, "DELETE"},
    {_EXECUTE, "EXECUTE"},
    {_MODIFY, "MODIFY"},
    {_READ, "READ"},
};

/**
 * @brief Create the log entry corresponding to parsed input.
 *
 * @param first
 */
void create_logentry(struct _node_pt *first, uint64_t query_id)
{
    FILE *f_logs;
    const char *output_name = "gaur.log";

    const char *env_fn = getenv(LOG_ENV);
    if (env_fn)
        f_logs = fopen(strdup(env_fn), "a");
    else
        f_logs = fopen(output_name, "a");

    if (f_logs == NULL)
    {
        perror("Gaur: cannot open file to log file");
    }
    else
    {
        struct _node_pt *current = first;
        fprintf(f_logs, "%" PRId64 " -- ", query_id); /* Print Input ID*/
        while (current != NULL)
        { /* Iterate over tree nodes, print their number (given by yyn)*/
            fprintf(f_logs, "%d:", current->rule_number);

            /* Then compare tag with flags and print corresponding semantic */
            for (size_t i = 0; i < sizeof(_sem_mapping) / sizeof(_sem_mapping[0]); i++)
            {
                if (current->rule_semantic & _sem_mapping[i].value)
                {
                    fprintf(f_logs, "%s", _sem_mapping[i].name);
                    break;
                }
            }
            fprintf(f_logs, ", ");

            struct _node_pt *tmp = current;
            current = current->next;
            free(tmp);
        }
        fprintf(f_logs, "\n");
        fclose(f_logs);

        /* Reset nodes */
        first = NULL;
        current = NULL;
    }
}
