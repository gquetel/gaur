#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

// structure de donnée nous permettant de stocker un arbre
typedef struct child_t child_t;
typedef struct node_t node_t;

struct node_t
{
    char *data;
    int rule_id;
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

/*                      CONSTRUCTION DE L'ABRE                        */

// Pour l'écriture en format CSV il faut abolument éviter
// les virgules ont les replaces donc par un autre charactère
void syntax_check(char *word)
{

    for (int i = 0; i < strlen(word); i++)
    {
        if (word[i] == ',')
            word[i] = '#';
    }
}

// Lors d'un shift on ajoute une feuille qui sera
// stocker dans un tableau jouant le role de pile
void shift(const char *data, const int rule_id)
{
    char *info = malloc(strlen(data));
    strcpy(info, data);
    syntax_check(info);

    tab[index_tab] = malloc(sizeof(node_t));
    tab[index_tab]->nb_child = 0;
    tab[index_tab]->data = info;
    tab[index_tab]->child = NULL;
    tab[index_tab]->rule_id = rule_id;
    index_tab++;
}

// Partie du reduce visant à dépiler les élements nécessaire de la pile
// Et à en profiter pour les relierà leur père
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

// Fonction appellé lors d'un reduce, permettant de créer
// l'élement noueds
void reduce(int nb_child, const char *data, const int rule_id)
{

    start_bro = NULL;
    end_bro = NULL;
    int nb_child_tot = nb_child;

    for (int i = 0; i < nb_child; i++)
    {
        index_tab--;
        nb_child_tot += small_reduce(index_tab);
    }

    char *info = malloc(strlen(data));
    strcpy(info, data);
    syntax_check(info);

    tab[index_tab] = malloc(sizeof(node_t));
    tab[index_tab]->data = info;
    tab[index_tab]->nb_child = nb_child_tot;
    tab[index_tab]->child = start_bro;
    tab[index_tab]->rule_id = rule_id;
    index_tab++;
}
/*                        ARBRE mon format                          */

// Un noeud déclare ces fils par '>', '|' sert à montré la fin du nom du fils
int print_MY(int index, node_t *printed, FILE *f)
{

    if (printed == NULL)
        return 1;

    if (printed->child != NULL)
    {
        int i = index;
        // fprintf(f, "%d.%d>", printed->rule_id, index + printed->nb_child); // rule_id
        fprintf(f, "%s.%d>", printed->data, index + printed->nb_child);

        child_t *child = printed->child;

        while (child != NULL)
        {
            if (child->child == NULL)
                return 1;

            i += child->child->nb_child + 1;
            // fprintf(f, "%d.%d|", child->child->rule_id, i - 1); // print rule id
            fprintf(f, "%s.%d|", child->child->data, i - 1);

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

// Le premier affichage sert à facilement connaitre la racine de l'abre
void print_tree_MY(FILE *f)
{
    fprintf(f, ",\"|%s.%d ", tab[index_tab - 1]->data, tab[index_tab - 1]->nb_child);
    // fprintf(f, ",\"|%d.%d ", tab[index_tab - 1]->rule_id, tab[index_tab - 1]->nb_child); // print rule id
    print_MY(0, tab[index_tab - 1], f);
    fprintf(f, "\""); // End of parse tree string
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

int width_stage(node_t *evaluated, int stage, int stages[])
{
    if (evaluated == NULL)
        return 0;

    if (evaluated->child == NULL)
        return 1;

    int add = 0;
    int nb_direct_child = 0;

    child_t *child = evaluated->child;
    while (child != NULL)
    {
        add += width_stage(child->child, stage + 1, stages);

        child = child->brother;
        nb_direct_child++;
    }
    stages[stage] += nb_direct_child;

    return add;
}

/**
 * @brief For the time being, simply prints the depth of the tree.
 *
 * @param f
 */
void print_parameters(FILE *f)
{
    int depth_tree = depth(tab[index_tab - 1]);
    fprintf(f, ",%d", depth_tree); // depth column

    /*
    int total_node = tab[index_tab - 1]->nb_child + 1;  // remove compiler warnings
    int stages[depth_tree];

    for (int i = 0; i < depth_tree; i++)
    {
        stages[i] = 0;
    }

    int nb_leaf = width_stage(tab[index_tab-1], 0, stages); // remove compiler warnings

    fprintf(f, ",%d", nb_leaf); // i.e terminal_c -> Redundant
    fprintf(f, ",%f", ((double) total_node)/(total_node - nb_leaf)); // Leaf / Node total ratio

    for(int i = 0; i < depth_tree; i++){
        fprintf(f, ",%d",  stages[i]);
    }*/
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
        shift(yysymbol_name(yytoken), yytoken);                         \
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
        reduce(yylen, yysymbol_name(yyr1[nrule - 1]), nrule);              \
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
