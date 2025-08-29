#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <sys/time.h>
#include <time.h>

// TODO
// - Thread / connexion specific gaur.log file. 
typedef struct node_t node_t;

/**
 * struct node_t - A node of our semantic tree
 * @n_children: Number of children nodes.
 * @yykind: Kind of the node (given by flex / bison).
 * @rule_id: Rule id of node (given by bison), -1 if node is a terminal.
 * @rule_tag: Semantic tag associated with the node.
 * @rule_order: Order of appearance of the node when parsing.
 * @sem_val: Semantic value associated with the node, NULL if none.
 * @first_child: Pointer to the first child node.
 * @next_brother: Pointer to the next sibling node.
 */
struct node_t
{
    int n_children;
    int yykind;
    int rule_id;
    int rule_tag;
    int rule_order;
    char *sem_val;
    struct node_t *first_child;
    struct node_t *next_brother;
};

#define GAUR_TAB_MAX_L 10000

/**
 *  Tab serves as a stack of pt nodes until they are given a father
 * - Each shift increments the number of element in the array
 * - Each reduce reduce the number of elements by the number of rhs elements (direct childrens)
 */
thread_local node_t *tab[GAUR_TAB_MAX_L];

// stores the index of the next available position in the tab.
// index_tab - 1 corresponds to the index of the last shifted element.
thread_local int index_tab = 0;
// Signals a state of error for the collector. When in this mode, the trace is not
// fully produced, the semantic tree is missing.
thread_local int is_collector_error = 0;

thread_local int rule_counter = 0;
thread_local int n_terminal = 0;
thread_local int n_nonterminal = 0;
// Store query id
thread_local uint64_t ggid = 0;

// Is called at the beginning of each input parsing. Reinitialize values.
#define GAUR_PARSE_BEGIN(size, thd) \
    n_terminal = 0;                 \
    n_nonterminal = 0;              \
    ggid = thd->query_id;           \
    index_tab = 0;                  \
    tab[index_tab] = NULL;          \
    rule_counter = 0;               \
    is_collector_error = 0;


#define GET_TAG(i) (ggrulesem[i - 2])

#define GAUR_ERROR()                                           \
    do                                                         \
    {                                                          \
        collect_and_clean(ggid, n_terminal, n_nonterminal, 1); \
    } while (0);

#define GAUR_SHIFT(yytoken, yytokenvalue)                          \
    do                                                             \
    {                                                              \
        if (yytoken == YYSYMBOL_YYEOF)                             \
            collect_and_clean(ggid, n_terminal, n_nonterminal, 0); \
        else                                                       \
        {                                                          \
            shift(yytoken, yytokenvalue, ggid);                    \
            n_terminal++;                                          \
        }                                                          \
    } while (0);

#define GAUR_REDUCE(nrule, yylen, yykind)                                       \
    do                                                                          \
    { /* We substract 1 to nrule because of the bison internal yyaccept rule */ \
        n_nonterminal++;                                                        \
        reduce(yylen, nrule - 1, GET_TAG(nrule), yykind);                       \
    } while (0)

static struct
{
    int32_t value;
    const char *name;
} _tags_mapping[] = {
    {1 << 0, "DDL_ALTER"},
    {1 << 1, "DDL_CREATE"},
    {1 << 2, "DDL_DROP"},
    {1 << 3, "DML_DELETE_TRUNCATE"},
    {1 << 4, "DML_INSERT_REPLACE"},
    {1 << 5, "DML_MAINTENANCE"},
    {1 << 6, "DML_SELECT"},
    {1 << 7, "DML_UPDATE"},
    {1 << 8, "EXPRESSION_LOGIC"},
    {1 << 9, "PARTITIONING_STORAGE"},
    {1 << 10, "PRIVILEGES_SECURITY"},
    {1 << 11, "PROCEDURAL_LOGIC"},
    {1 << 12, "REPLICATION_MANAGEMENT"},
    {1 << 13, "SERVER_ADMIN"},
    {1 << 14, "SHOW_DESCRIBE_EXPLAIN"},
    {1 << 15, "STATEMENT_CONTROL"},
    {1 << 16, "STATEMENT_HELP"},
    {1 << 17, "STATEMENT_MANAGEMENT"},
    {1 << 18, "TRANSACTION_CONTROL"},
    {1 << 19, "WINDOW_ANALYTICS"},
};

/**
 * @brief Get current timestamp
 * @return Static string containing formatted timestamp (not thread-safe)
 */
const char *get_timestamp()
{
    static char timestamp_buffer[64];
    struct timeval tv;
    struct tm *timeinfo;

    gettimeofday(&tv, NULL);
    timeinfo = gmtime(&tv.tv_sec);

    snprintf(timestamp_buffer, sizeof(timestamp_buffer),
             "%04d-%02d-%02dT%02d:%02d:%02d.%06ldZ [ERROR]",
             timeinfo->tm_year + 1900,
             timeinfo->tm_mon + 1,
             timeinfo->tm_mday,
             timeinfo->tm_hour,
             timeinfo->tm_min,
             timeinfo->tm_sec,
             tv.tv_usec);

    return timestamp_buffer;
}

/**
 * @brief Called when a shift occurs, we create a node_t object and store it in the tab
 *
 * @param yykind Kind of shifted item (given by flex / bison).
 * @param yyvaluep Pointer to the item semantic value
 * @param ggid Identifier generated by MySQL
 */
void shift(int yykind, YYSTYPE const *const yyvaluep, int ggid)
{
    // Skip shift if tree is already messed up
    if (is_collector_error)
        return;

    if (index_tab >= GAUR_TAB_MAX_L)
    {
        fprintf(stderr, "%s GAUR - shift(): incorrect index_tab: %d for query %d\n",
                get_timestamp(), index_tab, ggid);
        is_collector_error = 1;
        return;
    }
    tab[index_tab] = (struct node_t *)malloc(sizeof(struct node_t));
    tab[index_tab]->n_children = 0;
    tab[index_tab]->first_child = NULL;
    tab[index_tab]->next_brother = NULL;
    tab[index_tab]->rule_tag = 0;
    tab[index_tab]->yykind = yykind;
    tab[index_tab]->rule_id = -1;
    tab[index_tab]->rule_order = rule_counter++;

    switch (yykind)
    {
    case YYSYMBOL_TEXT_STRING:
    case YYSYMBOL_IDENT_QUOTED:
    case YYSYMBOL_DECIMAL_NUM:
    case YYSYMBOL_FLOAT_NUM:
    case YYSYMBOL_NUM:
    case YYSYMBOL_LONG_NUM:
    case YYSYMBOL_HEX_NUM:
    case YYSYMBOL_LEX_HOSTNAME:
    case YYSYMBOL_ULONGLONG_NUM:
    case YYSYMBOL_DOLLAR_QUOTED_STRING_SYM:
    case YYSYMBOL_NCHAR_STRING:
    case YYSYMBOL_BIN_NUM:
    {
        tab[index_tab]->sem_val = strdup(yyvaluep->lexer.lex_str.str);
        break;
    }
    default:
    {
        tab[index_tab]->sem_val = NULL;
        break;
    }
    }
    index_tab++;
}

/**
 * @brief Called when a parser reduction occurs, we create a father node_t object,
 * associate it with its children, remove them from tab and store the father in tab.
 *
 * @param n_children Number of rule rhs (number of children to retrieve in tab)
 * @param r_id Rule id (given by bison)
 * @param tag Rule semantic tag
 * @param yykind Kind of the node (given by flex / bison)
 */
void reduce(int n_children, int r_id, int tag, int yykind)
{
    // Skip reduction if tree is already messed up
    if (is_collector_error)
        return;

    // Create father and populate entries with information given by function params.
    node_t *father_node = (struct node_t *)malloc(sizeof(struct node_t));
    if (!father_node)
    {
        fprintf(stderr, "%s GAUR - reduce(): malloc failed\n", get_timestamp());
        is_collector_error = 1;
        return;
    }
    father_node->rule_id = r_id;
    father_node->rule_tag = tag;
    father_node->rule_order = rule_counter++;
    father_node->n_children = n_children;
    father_node->yykind = yykind;
    father_node->sem_val = NULL;

    if (n_children > 0)
    {
        // First child to associate is at index_tab - 1.
        index_tab--;

        // Check whether the existing node in tab is not null.
        if (tab[index_tab] == NULL)
        {
            fprintf(stderr, "%s GAUR - reduce(): Expected children is NULL\n", get_timestamp());
            is_collector_error = 1;
            return;
        }
        // Then associate the first child.
        father_node->first_child = tab[index_tab];
        node_t *last_children = father_node->first_child;

        // We iterate over children, last_children correspond to the last child added
        // to the father's list. Each new popped child is therefore added as the
        // next_brother, and then considered as the new last_children.
        // We associate the remaining children to the father.
        for (int i = 0; i < (n_children - 1); i++)
        {
            index_tab--;
            if (index_tab < 0 || index_tab >= GAUR_TAB_MAX_L)
            {
                fprintf(stderr, "%s GAUR - reduce(): incorrect index_tab: %d\n", get_timestamp(), index_tab);
                is_collector_error = 1;
                return;
            }
            if (tab[index_tab] == NULL)
            {
                fprintf(stderr, "%s GAUR - reduce(): Expected children is NULL\n", get_timestamp());
                is_collector_error = 1;
                return;
            }
            last_children->next_brother = tab[index_tab];
            last_children = last_children->next_brother;
        }
        last_children->next_brother = NULL;
    }
    if (index_tab < 0 || index_tab >= GAUR_TAB_MAX_L)
    {
        fprintf(stderr, "%s GAUR - reduce(): final index_tab=%d out of range\n", get_timestamp(), index_tab);
        is_collector_error = 1;
        return;
    }

    tab[index_tab] = father_node;
    index_tab++;
}

/**
 * @brief Return gaur logfile pointer, creates it if necessary.
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
            fprintf(f_logs, "query_id,n_terminal,n_nonterminal,is_syntax_error,semantic_tree,depth\n");
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
    if (is_collector_error || tree_root == NULL)
        return 0;

    int max = 0;
    int current;

    node_t *next_child = tree_root->first_child;

    for (int i = 0; i < tree_root->n_children; i++)
    {
        if (next_child == NULL)
        {
            fprintf(stderr, "%s GAUR - get_tree_depth(): child list shorter than n_children=%d\n",
                    get_timestamp(), tree_root->n_children);
            is_collector_error = 1;
            return 0;
        }
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
    /* If root node is null, no children or error we return  */
    if (root_node == NULL || root_node->n_children == 0 || is_collector_error)
        return;

    fprintf(f, " %d>", root_node->rule_order);
    node_t *current_node = root_node->first_child;
    /* Print edges between root_node and its children. */
    for (int i = 0; i < root_node->n_children; i++)
    {
        if (current_node == NULL)
        {
            fprintf(stderr, "%s GAUR - print_edges_relation(): Child list is shorter than n_children (%d).\n",
                    get_timestamp(), root_node->n_children);
            is_collector_error = 1;
            return;
        }
        fprintf(f, "%d:", current_node->rule_order);
        current_node = current_node->next_brother;
    }
    /* Now iterate over children to display their edges */
    current_node = root_node->first_child;
    for (int i = 0; i < root_node->n_children; i++)
    {
        print_edges_relation(current_node, f);
        current_node = current_node->next_brother;
    }
}

/**
 * @brief Sanitize the sem_value of node.
 * - We enclosed the whole semantic tree in double quotes: every occurence of double
 *      quotes must be doubled within the string;
 * - We also need to make sure no ":" is present, we replace them by GAUR_SEMICOLON
 *     which is replaced back when preprocessing the log traces;
 * - We also need to make sure no "|" is present
 * @param sem_val
 * @param f
 */
void safe_sem_value_print(char *sem_val, FILE *f)
{
    if (sem_val != NULL)
    {
        for (size_t i = 0; i < strlen(sem_val); i++)
        {
            if (sem_val[i] == '"')
                fprintf(f, "\"\"");
            else if (sem_val[i] == '|')
                fprintf(f, "G_PIPE");
            else if (sem_val[i] == ':')
                fprintf(f, "G_SEMICOLON");
            else
                fprintf(f, "%c", sem_val[i]);
        }
    }
}

/**
 * @brief Print nodes, and their attributes
 *  order_int:symbol_kind:rule_id:semantic_tag::sem_value
 * @param root_node
 * @param f
 */
void print_nodes_attr(node_t *root_node, FILE *f)
{
    // TODO: append all text to a buffer and only print once
    if (root_node == NULL || is_collector_error)
        return;

    fprintf(f, "|%d:%d:%d:", root_node->rule_order, root_node->yykind, root_node->rule_id);

    /* Now print semantic tag */
    for (size_t i = 0; i < sizeof(_tags_mapping) / sizeof(_tags_mapping[0]); i++)
    {
        if (root_node->rule_tag & _tags_mapping[i].value)
        {
            fprintf(f, "%s", _tags_mapping[i].name);
            break;
        }
    }
    // Program parsing trace expect 2 tags fields, I could change the parsing function
    // but it's simpled to print an empty 2nd field that we simply ignore.
    fprintf(f, "::");
    if (root_node->sem_val != NULL)
    {
        safe_sem_value_print(root_node->sem_val, f);
    }

    node_t *current_node = root_node->first_child;
    for (int i = 0; i < root_node->n_children; i++)
    {
        if (current_node == NULL)
        {
            fprintf(stderr, "%s GAUR - print_nodes_attr(): Child list is shorter than n_children (%d).\n",
                    get_timestamp(), root_node->n_children);
            is_collector_error = 1;
            return;
        }
        print_nodes_attr(current_node, f);
        current_node = current_node->next_brother;
    }
}

/**
 * @brief Free the memory allocated for a node and its children
 *
 * @param node Tree node to free
 */
void free_node_and_child(node_t *node)
{
    if (node == NULL)
        return;

    node_t *current_node = node->first_child;
    for (int i = 0; i < node->n_children; i++)
    {
        if (current_node == NULL)
        {
            fprintf(stderr,
                    "%s GAUR - free_node_and_child() - child list shorter than n_children=%d at index %d\n",
                    get_timestamp(), node->n_children, i);
            break;
        }
        node_t *next = current_node->next_brother;
        free_node_and_child(current_node);
        current_node = next;
    }

    if (node->sem_val != NULL)
    {
        free(node->sem_val);
    }

    free(node);
}

/**
 * @brief Wrapper for nodes and edges printing
 *
 * @param f
 */
void print_tree_MY(FILE *f)
{
    // Checks on the validity of the tree are done in caller.
    fprintf(f, ",\"");
    print_nodes_attr(tab[index_tab - 1], f);
    fprintf(f, "||-||"); /* Allows to separate node declaration from edges*/
    print_edges_relation(tab[index_tab - 1], f);
    fprintf(f, "\"");
}

/**
 * @brief Create the log entry corresponding to parsed input and clean the semantic tree data structure
 *
 * @param query_id id to identify query, generated by MySQL
 * @param n_terminal number of terminal nodes in semantic tree
 * @param n_nonterminal number of non-terminal nodes in semantic tree
 * @param is_error presence of syntax error
 */
void collect_and_clean(uint64_t query_id, int n_terminal, int n_nonterminal, int is_error)
{
    // Case where tree is empty / invalid.
    if (index_tab == 0 || tab[index_tab - 1] == NULL)
        return;

    FILE *f_logs = gaur_open_file();
    if (f_logs != NULL)
    {
        fprintf(f_logs, "%" PRId64 ",", query_id); /* Print Input ID*/
        fprintf(f_logs, "%d,%d,%d", n_terminal, n_nonterminal, is_error);

        if (is_collector_error)
            fprintf(f_logs, ",,\n"); // One for pt, one for depth
        else
        {
            print_tree_MY(f_logs);
            print_tree_features(f_logs);
            fprintf(f_logs, "\n");
        }
        fclose(f_logs);
    }
    else
    {
        perror("Gaur: Could not open log file.");
    }

    // TODO: Add check on index_tab

    for (int i = 1; i <= index_tab; i++)
    {
        free_node_and_child(tab[index_tab - i]);
        tab[index_tab - i] = NULL;
    }
}
