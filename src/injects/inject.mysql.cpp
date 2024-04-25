#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>

#define LOG_ENV "GAUR_LOGFILE"
#define MAX_SIZE_SEM 4096

static char *output_name = "gaur.log";

#define GAUR_PARSE_BEGIN(size, thd)        \
    char ggsem[MAX_SIZE_SEM] = "\0";       \
    uint64_t ggquery_id = thd->query_id; \

#define MARK_N(i) (ggrulesem[i - 2])

#define GAUR_SHIFT(yytoken)                                                                         \
    do                                                                                              \
    {                                                                                               \
        if (yytoken == YYSYMBOL_YYEOF)                                                              \
        {                                                                                           \
            FILE *f_logs;                                                                           \
            const char *env_fn = getenv(LOG_ENV);                                                   \
            if (env_fn)                                                                             \
                output_name = strdup(env_fn);                                                       \
            f_logs = fopen(output_name, "a");                                                       \
            if (f_logs == NULL)                                                                     \
            {                                                                                       \
                perror("GAUR data collector: cannot open file to output input informations.");      \
            }                                                                                       \
            else                                                                                    \
            {                                                                                       \
                fprintf(f_logs, "%" PRId64 ",%s\n", ggquery_id, ggsem); \
                fclose(f_logs);                                                                     \
            }                                                                                       \
        }                                                                                           \
    } while (0)

#define GAUR_REDUCE(nrule, yylen)                                           \
    do                                                                      \
    {                                                                       \
        char s_rule[16]; /*Save rule number string format*/                 \
        /* Bison adds an accept rule, to get the number of rule matching */ \
        /* with the line number in nterm_list file, we substract one */     \
        sprintf(s_rule, "%d:", nrule - 1);                                  \
        concat(ggsem, s_rule);                                              \
        int32_t nrule_flags = MARK_N(nrule); /*Save rule semantic*/         \
        if (!nrule_flags)                                                   \
        {                                                                   \
            concat(ggsem, "N ");                                            \
        }                                                                   \
        else                                                                \
        {                                                                   \
            char *ssem_root = seq(nrule_flags);                             \
            if (ssem_root == NULL)                                          \
            {                                                               \
                printf("Error with semantic of rule: %d,"                   \
                       "flag:% d\n ",                                     \
                       nrule, nrule_flags);                                 \
                break;                                                      \
            }                                                               \
            concat(ggsem, ssem_root);                                       \
        }                                                                   \
    } while (0)
;

/**
 * @brief UGLY FIX
 *
 * @param src
 * @param dest
 * @return char*
 */
char *concat(char *src, char *dest)
{
    if (MAX_SIZE_SEM > strlen(src) + strlen(dest) + 1)
    {
        return strcat(src, dest);
    }
    return src;
}
/**
 * @brief Popcount function
 *
 * @param i int32_t semantic representation through flags
 * @return int number of flags sets (number of semantics)
 */
int s_len(int32_t i)
{
    i = i - ((i >> 1) & 0x55555555);
    i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
    i = (i + (i >> 4)) & 0x0F0F0F0F;
    return (i * 0x01010101) >> 24;
}

/**
 * @brief Returns a pointer to a string representing the semantics associated to a given int32_t
 * You need to FREE the pointer after usage
 * @param flags int32_t semantic representation through flags
 * @return char* String representation, NULL if malloc failed
 */
char *seq(int32_t flags)
{
    char *res = (char *)malloc(sizeof(char) * MAX_SIZE_SEM);
    if (!res)
    {
        perror("failed to allocate sequence.\n");
        return NULL;
    }

    /* No semantic */
    if (flags == 0)
    {
        strcpy(res, "N");
        return res;
    }

    /* Only one semantic */
    if (s_len(flags) == 1)
    {
        if (flags & 0b10000)
            strcpy(res, "C ");
        if (flags & 0b01000)
            strcpy(res, "D ");
        if (flags & 0b00100)
            strcpy(res, "E ");
        if (flags & 0b00010)
            strcpy(res, "M ");
        if (flags & 0b00001)
            strcpy(res, "R ");
        return res;
    }

    /* More than one semantic */
    strcpy(res, "");
    char *tmp = NULL;
    if (flags & 0b10000)
    {
        concat(res, "C");
        tmp = seq(flags - 0b10000);
    }
    else if (flags & 0b01000)
    {
        concat(res, "D");
        tmp = seq(flags - 0b01000);
    }
    else if (flags & 0b00100)
    {
        concat(res, "E");
        tmp = seq(flags - 0b00100);
    }
    else if (flags & 0b01000)
    {
        concat(res, "M");
        tmp = seq(flags - 0b00010);
    }
    else if (flags & 0b00001)
    {
        concat(res, "R");
        tmp = seq(flags - 0b00001);
    }

    if (tmp == NULL)
        return NULL;

    /* Concat with rest of sequence */
    concat(res, tmp);
    return res;
}
