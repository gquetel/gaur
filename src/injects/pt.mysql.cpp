#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

typedef struct child_t child_t;
typedef struct node_t node_t;

struct node_t
{
    int nb_child;
    int rule_id;
    int rule_action;
    int rule_asset;
    struct child_t *child;
};

struct child_t
{
    node_t *child;
    child_t *brother;
};

#define MAX_LENGHT 300

/* tab servers as a stack of pt nodes until they are given a father
- Each shift increments the number of element in the array
- Each reduce reduce the number of elements by the number of rhs elements (direct childrens)
*/

/* index_tab stores the index of the next available position in the tab,
index_tab - 1 corresponds to the index of the last shifted element (when index_tab > 0s) */

#define GAUR_PARSE_BEGIN(size, thd) \
    int terminal_c = 0;             \
    int nonterminal_c = 0;          \
    uint64_t ggid = thd->query_id;  \
    int index_tab = 0;              \
    child_t *start_bro = NULL;      \
    child_t *end_bro = NULL;        \
    int is_collector_error = 0;     \
    node_t *tab[MAX_LENGHT];

#define GET_ACTION_TAG(i) (ggrulesem[i - 2][0])
#define GET_ASSET_TAG(i) (ggrulesem[i - 2][1])

#define GAUR_ERROR()                                                                             \
    do                                                                                           \
    {                                                                                            \
        create_logentry(ggid, terminal_c, nonterminal_c, 1, is_collector_error, tab, index_tab); \
    } while (0);

#define GAUR_SHIFT(yytoken)                                      \
    do                                                           \
    {                                                            \
        if (yytoken == YYSYMBOL_YYEOF)                           \
            create_logentry(ggid, terminal_c, nonterminal_c, 0,  \
                            is_collector_error, tab, index_tab); \
        shift(yytoken, index_tab, is_collector_error, tab);      \
        terminal_c++;                                            \
    } while (0);

#define GAUR_REDUCE(nrule, yylen)                                             \
    do                                                                        \
    { /* We substract 1 to nrule because of the bison accept rule offset*/    \
        nonterminal_c++;                                                      \
        reduce(yylen, nrule - 1, GET_ASSET_TAG(nrule), GET_ACTION_TAG(nrule), \
               index_tab, tab, is_collector_error, start_bro, end_bro);       \
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
 * @brief Called when shift occurs, will be pushed in the pile afterwards
 *
 */
void shift(int rule_id, int index_tab, int is_collector_error, node_t *tab[])
{
    if (index_tab >= MAX_LENGHT || is_collector_error)
    {
        fprintf(stderr, "gaur data collector - shift(): incorrect index_tab: %d\n", index_tab);

        is_collector_error = 1;
        return;
    }

    tab[index_tab] = (struct node_t *)malloc(sizeof(node_t));
    tab[index_tab]->nb_child = 0;
    tab[index_tab]->child = NULL;
    tab[index_tab]->rule_action = 0;
    tab[index_tab]->rule_asset = 0;
    tab[index_tab]->rule_id = rule_id;
    index_tab++;
}

/**
 * @brief Part of the reduce which takes all sons and attribute them to their father
 *
 * @param num
 * @return int
 */
int small_reduce(int num, child_t *start_bro, child_t *end_bro, node_t *tab[])
{
    if (start_bro == NULL)
    {
        start_bro = (struct child_t *)malloc(sizeof(child_t));

        start_bro->child = tab[num];
        start_bro->brother = NULL;
        end_bro = start_bro;
    }
    else
    {
        end_bro->brother = (struct child_t *)malloc(sizeof(child_t));
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
 */
void reduce(int nb_child, int r_id, int r_asset, int r_action, int index_tab, node_t *tab[], int is_collector_error, child_t *start_bro, child_t *end_bro)
{

    if (is_collector_error) /* Skip reduction if tree is already messed up */
        return;
    start_bro = NULL;
    end_bro = NULL;
    int nb_child_tot = nb_child;

    for (int i = 0; i < nb_child; i++)
    {
        index_tab--;
        if (index_tab < 0 || index_tab >= MAX_LENGHT)
        {
            fprintf(stderr, "gaur data collector - reduce(): incorrect index_tab: %d\n", index_tab);

            is_collector_error = 1;
            return;
        }
        nb_child_tot += small_reduce(index_tab, start_bro, end_bro, tab);
    }

    tab[index_tab] = (struct node_t *)malloc(sizeof(node_t));
    tab[index_tab]->nb_child = nb_child_tot;
    tab[index_tab]->child = start_bro;
    tab[index_tab]->rule_action = r_action;
    tab[index_tab]->rule_asset = r_asset;
    tab[index_tab]->rule_id = r_id;
    index_tab++;
}

int get_tree_depth(node_t *evaluated)
{
    if (evaluated == NULL)
        return 0;

    int max = 0;
    int actual;

    child_t *child = evaluated->child;
    while (child != NULL)
    {
        actual = get_tree_depth(child->child);

        if (actual > max)
            max = actual;

        child = child->brother;
    }

    return max + 1;
}

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
            fprintf(f_logs, "query_id,terminal_c,nonterminal_c,is_syntax_error,parse_tree,depth\n");
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
 * @brief Function to print additionnal tree features:
 * Depth of the tree
 * @param f
 */
void print_tree_features(FILE *f, node_t *tab[], int index_tab)
{
    int depth_tree = get_tree_depth(tab[index_tab - 1]);
    fprintf(f, ",%d", depth_tree);
}

/**
 * @brief Print tree, and relationships between nodes
 *
 * @param index
 * @param printed
 * @param f
 * @return int
 */
int print_edges_relation(int index, node_t *printed, FILE *f)
{

    if (printed == NULL)
        return 1;

    if (printed->child != NULL)
    {
        int i = index;
        child_t *child = printed->child;
        fprintf(f, " %d>", index + printed->nb_child);

        while (child != NULL)
        {
            if (child->child == NULL)
                return 1;

            i += child->child->nb_child + 1;
            fprintf(f, "%d:", i - 1);

            child = child->brother;
        }

        i = index;
        child = printed->child;

        while (child != NULL)
        {
            print_edges_relation(i, child->child, f);
            i += child->child->nb_child + 1;
            child = child->brother;
        }
    }
    return 0;
}

/**
 * @brief Print nodes, and their attributes
 *  |index:label:action:object
 * @param index
 * @param printed
 * @param f
 * @return int
 */
int print_nodes_attr(int index, node_t *printed, FILE *f)
{

    if (printed == NULL)
        return 1;
    child_t *child = printed->child;

    fprintf(f, "|%d:node_name:", index + printed->nb_child);

    /* Now print action */
    for (size_t i = 0; i < sizeof(_actions_mapping) / sizeof(_actions_mapping[0]); i++)
    {
        if (printed->rule_action & _actions_mapping[i].value)
        {
            fprintf(f, "%s", _actions_mapping[i].name);
            break;
        }
    }
    fprintf(f, ":");
    for (size_t i = 0; i < sizeof(_assets_mapping) / sizeof(_assets_mapping[0]); i++)
    {
        if (printed->rule_asset & _assets_mapping[i].value)
        {
            fprintf(f, "%s", _assets_mapping[i].name);
            break;
        }
    }

    int i = index;
    while (child != NULL)
    {
        print_nodes_attr(i, child->child, f);
        i += child->child->nb_child + 1;
        child = child->brother;
    }
    return 0;
}

void print_tree_MY(FILE *f, node_t *tab[], int index_tab)
{
    fprintf(f, ",\"");
    print_nodes_attr(0, tab[index_tab - 1], f);
    fprintf(f, "||"); /* Allows to separate node declaration from edges*/
    print_edges_relation(0, tab[index_tab - 1], f);
    fprintf(f, "\"");
}

/**
 * @brief Create the log entry corresponding to parsed input.
 */
void create_logentry(uint64_t query_id, int terminal_c, int nonterminal_c, int is_error, int is_collector_error, node_t *tab[], int index_tab)
{
    FILE *f_logs = gaur_open_file();
    if (f_logs != NULL)
    {
        fprintf(f_logs, "%" PRId64 ",", query_id); /* Print Input ID*/
        fprintf(f_logs, "%d,%d,%d", terminal_c, nonterminal_c, is_error);
        if (is_collector_error || index_tab < 1)
            fprintf(f_logs, ",,\n"); // One for pt, one for depth
        else
        {
            print_tree_MY(f_logs, tab, index_tab);
            print_tree_features(f_logs, tab, index_tab);
            fprintf(f_logs, "\n");
        }
        // clean_tab();
        fclose(f_logs);
    }
    else
    {
        perror("Gaur: Could not open log file.");
    }
}
