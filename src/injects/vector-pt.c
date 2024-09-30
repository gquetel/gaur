#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

typedef struct node_t node_t;

struct node_t
{
    int nb_child;
    int rule_id;
    int rule_order;
    int rule_action;
    int rule_asset;
    struct node_t *first_child;
    struct node_t *next_brother;
};

#define MAX_LENGHT 10

/* tab servers as a stack of pt nodes until they are given a father
- Each shift increments the number of element in the array
- Each reduce reduce the number of elements by the number of rhs elements (direct childrens)
*/
node_t *tab[MAX_LENGHT];

/* index_tab stores the index of the next available position in the tab,
 index_tab - 1 corresponds to the index of the last shifted element (when index_tab > 0s) */

int index_tab = 0;
int is_collector_error = 0;
int rule_counter = 0;

/**
 * @brief Called when shift occurs, will be pushed in the pile afterwards
 *
 */
void shift(int rule_id)
{
    if (index_tab >= MAX_LENGHT || is_collector_error)
    {
        fprintf(stderr, "gaur data collector - shift(): incorrect index_tab: %d\n", index_tab);
        is_collector_error = 1;
        return;
    }

    tab[index_tab] = malloc(sizeof(node_t));
    tab[index_tab]->nb_child = 0;
    tab[index_tab]->first_child = NULL;
    tab[index_tab]->next_brother = NULL;
    tab[index_tab]->rule_action = 0;
    tab[index_tab]->rule_asset = 0;
    tab[index_tab]->rule_id = rule_id;
    tab[index_tab]->rule_order = rule_counter++;
    index_tab++;
}

/**
 * @brief Create a node and retrieve its children
 *
 * @param nb_child Number of node children (rule rhs)
 */
void reduce(int nb_child, int r_id, int r_asset, int r_action)
{
    if (is_collector_error) /* Skip reduction if tree is already messed up */
        return;

    node_t *father_node = malloc(sizeof(node_t));
    father_node->rule_id = r_id;
    father_node->rule_action = r_action;
    father_node->rule_asset = r_asset;
    father_node->rule_order = rule_counter++;
    father_node->nb_child = nb_child;

    if (nb_child > 0)
    {
        /* We have at least a child: retrieve first node child (tab[index_tab - 1]) */
        index_tab--;
        int remaining_children = nb_child - 1; // Store number of remaining children to associate to father.
        father_node->first_child = tab[index_tab];

        node_t *last_children = father_node->first_child; // Store children on which to append next brother

        /* collect nb_child last values of array tab and associate them to their father */
        for (int i = 0; i < remaining_children; i++)
        {
            index_tab--;
            if (index_tab < 0 || index_tab >= MAX_LENGHT)
            {
                fprintf(stderr, "gaur data collector - reduce(): incorrect index_tab: %d\n", index_tab);
                is_collector_error = 1;
                return;
            }

            last_children->next_brother = tab[index_tab];
            last_children = last_children->next_brother;
        }
    }
    /* When no child, first_child stays at NULL. */
    tab[index_tab] = father_node;
    index_tab++;
}

#define GAUR_PARSE_BEGIN(size, state_stack) \
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

#define GAUR_SHIFT(yytoken)                                      \
    do                                                           \
    {                                                            \
        if (yytoken == YYSYMBOL_YYEOF)                           \
            create_logentry(ggid, terminal_c, nonterminal_c, 0); \
        shift(yytoken);                                          \
        terminal_c++;                                            \
    } while (0);

#define GAUR_REDUCE(nrule, yylen)                                              \
    do                                                                         \
    { /* We substract 1 to nrule because of the bison accept rule offset*/     \
        nonterminal_c++;                                                       \
        reduce(yylen, nrule - 1, GET_ASSET_TAG(nrule), GET_ACTION_TAG(nrule)); \
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
 * @brief Compute the depth of a tree starting from a given node.
 *
 *  Should only be called if input is syntactically valid: the tree is complete
 * @param tree_root
 * @return int Depth of tree.
 */
int get_tree_depth(node_t *tree_root)
{
    if (tree_root == NULL)
        return 0;

    int max = 0;
    int current;

    node_t *next_child = tree_root->first_child;
    while (next_child != NULL)
    {
        current = get_tree_depth(next_child);

        if (current > max)
            max = current;

        next_child = next_child->next_brother;
    }
    return max + 1;
}

/**
 * @brief Function to print additionnal tree features:
 * Depth of the tree
 * @param f
 */
void print_tree_features(FILE *f)
{
    int depth_tree = get_tree_depth(tab[index_tab - 1]);
    fprintf(f, ",%d", depth_tree);
}

/**
 * @brief Print in given file the edges between nodes in the given tree.
 *
 * Each root node edges relations are represented with the following
 * custom format: X>Y:Y':Y''...:  where X is the root node rule order, and Y, Y', Y''...
 * are the rule order of the children of the root node.
 *
 * @param root_node First node of the tree
 * @param f File to output to
 */
void print_edges_relation(node_t *root_node, FILE *f)
{
    /* If root node is null or no children we return */
    if (root_node == NULL || root_node->first_child == NULL)
        return;

    fprintf(f, " %d>", root_node->rule_order);
    node_t *current_node = root_node->first_child;
    /* Print edges between root_node and its children. */
    while (current_node != NULL)
    {
        fprintf(f, "%d:", current_node->rule_order);
        current_node = current_node->next_brother;
    }
    /* Now iterate over children to display their edges */
    current_node = root_node->first_child;
    while (current_node != NULL)
    {
        print_edges_relation(current_node, f);
        current_node = current_node->next_brother;
    }
}

/**
 * @brief Print nodes, and their attributes
 *  | appearance_int:rule_id:action:object
 * @param printed
 * @param f
 */
void print_nodes_attr(node_t *root_node, FILE *f)
{
    // TODO: append all text to a buffer and only print once

    if (root_node == NULL)
        return;

    fprintf(f, "|%d:%d:", root_node->rule_order, root_node->rule_id);

    /* Print action tag */
    for (size_t i = 0; i < sizeof(_actions_mapping) / sizeof(_actions_mapping[0]); i++)
    {
        if (root_node->rule_action & _actions_mapping[i].value)
        {
            fprintf(f, "%s", _actions_mapping[i].name);
            break;
        }
    }
    fprintf(f, ":");
    for (size_t i = 0; i < sizeof(_assets_mapping) / sizeof(_assets_mapping[0]); i++)
    {
        if (root_node->rule_asset & _assets_mapping[i].value)
        {
            fprintf(f, "%s", _assets_mapping[i].name);
            break;
        }
    }

    node_t *current_node = root_node->first_child;
    while (current_node != NULL)
    {
        print_nodes_attr(current_node, f);
        current_node = current_node->next_brother;
    }
}

/**
 * @brief Wrapper for nodes and edges printing
 *
 * @param f
 */
void print_tree_MY(FILE *f)
{
    fprintf(f, ",\"");
    print_nodes_attr(tab[index_tab - 1], f);
    fprintf(f, "||"); /* Allows to separate node declaration from edges*/
    print_edges_relation(tab[index_tab - 1], f);
    fprintf(f, "\"");
}

void free_node(node_t *evaluated)
{
}

/**
 * @brief Callable to clean tree nodes.
 *
 */
void free_tree()
{
    for (int index = 0; index < index_tab; index++)
    {
        free_node(tab[index]);
    }
}
/**
 * @brief Create the log entry corresponding to parsed input.
 *
 * @param first
 */
void create_logentry(uint64_t query_id, int terminal_c, int nonterminal_c, int is_error)
{
    FILE *f_logs = gaur_open_file();
    if (f_logs != NULL)
    {
        fprintf(f_logs, "%" PRId64 ",", query_id); /* Print Input ID*/
        fprintf(f_logs, "%d,%d,%d", terminal_c, nonterminal_c, is_error);

        if (is_collector_error)
            fprintf(f_logs, ",,\n"); // One for pt, one for depth
        else
        {
            print_tree_MY(f_logs);
            print_tree_features(f_logs);
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
