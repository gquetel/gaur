
#include <dll.h>

struct parsed_string *head = NULL;
struct parsed_string *tail = NULL;
struct parsed_string *current = NULL;

struct parsed_string *remove_tail()
{
    struct parsed_string *entry;
    if (head == NULL)
        return NULL;
    else
    {
        entry = tail;
        if (tail->prev != NULL)
        {
            tail->prev->next = NULL;
        }
        struct parsed_string *prev = tail->prev;
        tail->prev = NULL;
        tail = prev;
    }
    return entry;
}

struct parsed_string *remove_head()
{
    struct parsed_string *entry;
    if (head == NULL)
        return NULL;
    else
    {
        entry = head;
        if (tail->next != NULL)
        {
            tail->next->prev = NULL;
        }
        struct parsed_string *next = head->next;
        head->next = NULL;
        head = next;
    }
    return entry;
}

void add_tail(char *format, char *data)
{
    struct parsed_string *entry = malloc(sizeof *entry);
    if (entry)
    {
        entry->format = strdup(format);
        entry->data = strdup(data);
        entry->next = NULL;
        entry->prev = NULL;

        if (head == NULL)
        {
            head = entry;
            tail = entry;
        }
        else
        {
            tail->next = entry;
            entry->prev = tail;
            tail = entry;
        }
    }
    else
    {
        perror("Error when creating a new stack entry.");
    }
}