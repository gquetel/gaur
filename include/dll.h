/**
 * @file dll.h
 * @author gregor quetel 
 * @brief Functions defining a double linked list used to store parsed strings before printing them to the output grammar file.
 * @version 0.1
 * @date 2023-03-23
 * 
 * @copyright Copyright (c) 2023
 * 
 */
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct parsed_string
{
    char *data;
    char *format;

    struct parsed_string *next;
    struct parsed_string *prev;
};

/**
 * @brief Return and pop the last string from the DLL
 * 
 * @return struct parsed_string* 
 */
struct parsed_string *remove_tail();

/**
 * @brief Remove and pop the first string of the DLL
 * 
 * @return struct parsed_string* 
 */
struct parsed_string *remove_head();

/**
 * @brief Push a string at the end of the DLL
 *
 * @param format
 * @param data
 */
void add_tail(char *format, char *data);