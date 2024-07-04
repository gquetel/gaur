#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

typedef struct child_t child_t;
typedef struct node_t node_t;

// TODO Merge node_t et node_pt
struct node_t
{
    const char *data;
    int nb_child;
    struct child_t *child;
};

struct child_t
{
    node_t *child;
    child_t *brother;
};

#define MAX_LENGHT 30

node_t *tab[MAX_LENGHT];
int index_tab = 0;

child_t *start_bro = NULL;
child_t *end_bro = NULL;

int nb_graph = 0;

/**
 * @brief Called when shift occurs, will be pushed in the pile afterwards
 *
 * @param data lhs name
 */
void shift(const char *data)
{

    // TODO replace by strdup & add action + objet fields ?
    const char *info = malloc(strlen(data));
    info = data;

    tab[index_tab] = malloc(sizeof(node_t));
    tab[index_tab]->nb_child = 0;
    tab[index_tab]->data = info;
    tab[index_tab]->child = NULL;
    index_tab++;
}

/**
 * @brief Part of the reduce which takes all sons and attribute them to their father
 *
 * @param num
 * @return int
 */
int small_reduce(int num)
{
    if (start_bro == NULL)
    {
        start_bro = malloc(sizeof(child_t));

        start_bro->child = tab[num];
        start_bro->brother = NULL;
        end_bro = start_bro;
    }
    else
    {
        end_bro->brother = malloc(sizeof(child_t));
        end_bro->brother->child = tab[num];
        end_bro->brother->brother = NULL;
        end_bro = end_bro->brother;
    }

    return tab[num]->nb_child;
}

/**
 * @brief Create a node and populate its values
 *
 * @param nb_child
 * @param data
 */
void reduce(int nb_child, const char *data)
{

    start_bro = NULL;
    end_bro = NULL;
    int nb_child_tot = nb_child;

    for (int i = 0; i < nb_child; i++)
    {
        index_tab--;
        nb_child_tot += small_reduce(index_tab);
    }

    const char *info = malloc(strlen(data));
    info = data;

    tab[index_tab] = malloc(sizeof(node_t));
    tab[index_tab]->data = info;
    tab[index_tab]->nb_child = nb_child_tot;
    tab[index_tab]->child = start_bro;
    index_tab++;
}

/*                        PRINT TREE                         */

/**
 * @brief Print tree, and relationships between nodes
 *
 * @param index
 * @param printed
 * @param f
 * @return int
 */
int print_MY(int index, node_t *printed, FILE *f)
{

    if (printed == NULL)
        return 1;

    if (printed->child != NULL)
    {
        int i = index;
        fprintf(f, "%d>", index + printed->nb_child);
        child_t *child = printed->child;

        while (child != NULL)
        {
            if (child->child == NULL)
                return 1;

            i += child->child->nb_child + 1;
            fprintf(f, "%d:", i - 1);

            child = child->brother;
        }
        fprintf(f, " ");

        i = index;
        child = printed->child;

        while (child != NULL)
        {
            print_MY(i, child->child, f);
            i += child->child->nb_child + 1;
            child = child->brother;
        }
    }
    return 0;
}

/**
 * @brief Print node data
 *  |index:label:action:object
 * @param index
 * @param printed
 * @param f
 * @return int
 */
int print_node_MY(int index, node_t *printed, FILE *f)
{

    if (printed == NULL)
        return 1;

    fprintf(f, "|%d", index + printed->nb_child);
    fprintf(f, ":%s", printed->data);

    child_t *child = printed->child;
    int width = 0;
    while (child != NULL)
    {
        width++;
        child = child->brother;
    }
    fprintf(f, ":action:object ");

    int i = index;
    child = printed->child;
    while (child != NULL)
    {
        print_node_MY(i, child->child, f);
        i += child->child->nb_child + 1;
        child = child->brother;
    }

    return 0;
}

void print_tree_MY(FILE *f)
{
    fprintf(f, ",\"");
    print_node_MY(0, tab[index_tab - 1], f);
    print_MY(0, tab[index_tab - 1], f);
    fprintf(f, "\"");
}

/*                       PRINT PARAMETRE ARBRE                       */

int depth(node_t *evaluated)
{
    if (evaluated == NULL)
        return 0;

    int max = 0;
    int actual;

    child_t *child = evaluated->child;
    while (child != NULL)
    {
        actual = depth(child->child);

        if (actual > max)
            max = actual;

        child = child->brother;
    }

    return max + 1;
}

int leaf(node_t *evaluated)
{
    if (evaluated == NULL)
        return 0;

    if (evaluated->child == NULL)
        return 1;

    int add = 0;

    child_t *child = evaluated->child;
    while (child != NULL)
    {
        add += leaf(child->child);

        child = child->brother;
    }

    return add;
}

// we also print the number of leaf, number of node
// and the depth of the tree
void print_parameters(FILE *f)
{
    int depth_tree = depth(tab[index_tab - 1]);
    fprintf(f, ",%d", depth_tree);
}

void print_tree(FILE *f)
{
    print_tree_MY(f);
    print_parameters(f);
}
typedef struct _node_pt
{
    int rule_number;
    int rule_action;
    int rule_asset;
    struct _node_pt *next;
} _Node_pt;

#define GAUR_PARSE_BEGIN(size, state_stack) \
    struct _node_pt *first = NULL;          \
    struct _node_pt *current = NULL;        \
    int terminal_c = 0;                     \
    int nonterminal_c = 0;                  \
    uint64_t ggid = (long)&state_stack[0];

#define GET_ACTION_TAG(i) (ggrulesem[i - 2][0])
#define GET_ASSET_TAG(i) (ggrulesem[i - 2][1])

#define GAUR_ERROR()                                                \
    do                                                              \
    {                                                               \
        create_logentry(first, ggid, terminal_c, nonterminal_c, 1); \
    } while (0);

#define GAUR_SHIFT(yytoken)                                             \
    do                                                                  \
    {                                                                   \
        if (yytoken == YYSYMBOL_YYEOF)                                  \
            create_logentry(first, ggid, terminal_c, nonterminal_c, 0); \
        shift(yysymbol_name(yytoken));                                  \
        terminal_c++;                                                   \
    } while (0);

#define GAUR_REDUCE(nrule, yylen)                                          \
    do                                                                     \
    { /* We substract 1 to nrule because of the bison accept rule offset*/ \
        if (first == NULL)                                                 \
        {                                                                  \
            first = malloc(sizeof(struct _node_pt));                       \
            first->rule_action = GET_ACTION_TAG(nrule);                    \
            first->rule_number = nrule - 1;                                \
            first->rule_asset = GET_ASSET_TAG(nrule);                      \
            first->next = NULL;                                            \
            current = first;                                               \
        }                                                                  \
        else                                                               \
        {                                                                  \
            current->next = malloc(sizeof(struct _node_pt));               \
            current = current->next;                                       \
            current->rule_action = GET_ACTION_TAG(nrule);                  \
            current->rule_asset = GET_ASSET_TAG(nrule);                    \
            current->rule_number = nrule - 1;                              \
            current->next = NULL;                                          \
        }                                                                  \
        nonterminal_c++;                                                   \
        reduce(yylen, yysymbol_name(yyr1[nrule]));                         \
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
    _TABLESPACE = 1 << 11,
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
    {_TABLESPACE, "TABLESPACE"},
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
 * @brief Check existence of file, if not exists create it, and create header line, then return file pointer.
 * If already exists, just return file pointer.
 *
 * @return FILE*
 */
FILE *gaur_open_file()
{
    const char *output_name = "gaur.log";
    FILE *f_logs = fopen(output_name, "r");
    if (f_logs == NULL)
    {
        f_logs = fopen(output_name, "w");
        if (f_logs != NULL)
        {
            fprintf(f_logs, "query_id,semantic_trace,terminal_c,nonterminal_c,is_syntax_error,parse_tree,depth\n");
        }
    }
    else
    {
        fclose(f_logs);
        f_logs = fopen(output_name, "a");
    }

    return f_logs;
}

/**
 * @brief Create the log entry corresponding to parsed input.
 *
 * @param first
 */
void create_logentry(struct _node_pt *first, uint64_t query_id, int terminal_c, int nonterminal_c, int is_error)
{
    FILE *f_logs = gaur_open_file();
    if (f_logs != NULL)
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
            /* Same for assets */
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
        fprintf(f_logs, "\",%d,%d,%d", terminal_c, nonterminal_c, is_error);
        print_tree(f_logs);

        fprintf(f_logs, "\n");
        fclose(f_logs);
    }
    else
    {
        perror("Gaur: Could not open log file.");
    }
}
