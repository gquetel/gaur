/**
 * @file gmodify.h
 * @author gregor quetel
 *
 * @brief Functions to print the instrumented grammar into the output file / extract grammar information /
 * Create dot file.
 *
 * @version 0.1
 * @date 2023-02-27
 * @copyright Copyright (c) 2023
 *
 */
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cJSON.h>

/* GAUR MODES */
#define M_DEFAULT 1
#define M_DOT 2
#define M_EXTRACT 3

#define DOT_FILE_NAME "parse.dot"

#define MAX_LINES_SEMANTIC_FILE 2048

/**
 * @brief
 *
 * @param fn_out grammar output filename/nonterminal list filename
 */
void init_output_file(char *fn_out);

/**
 * @brief
 *
 * @param fn_semantics filename of nterm:semantics file
 */

void init_semantic_file(char *fn_semantics);

/**
 * @brief Init skeleton filename
 *
 * @param fn_skeleton filename to save
 */
void init_skeleton_file(char *fn_skeleton);

/**
 * @brief
 *
 * @param fn_inject filename of file to inject in grammar prologue
 */

void init_inject_file(char *fn_inject);

/* -------------------- GRAMMAR INSTRUMENTALIZATION --------------------*/

/**
 * @brief Empty the DLL of parsed code and prints it to the output grammar file
 *
 */
void print();

/**
 * @brief Print to output grammar file the given string
 *
 * @param string String to print in the file
 */
void pstr(char *string);

/**
 * @brief Print to output grammar file the given a format string and a string
 *
 * @param format Format to apply
 * @param string String to print in the file
 */
void pstr_f(char *format, char *string);

/**
 * @brief Add in the output file prologue the functions definitions needed to build and use the stack of nonterminals.
 *
 * @return int Number of char written.
 */
void p_functions_definitions();

/**
 * @brief Called at the end of a group rule to reinitialise variables and print newlines.
 */
void end_group_rule();

/**
 * @brief Signal that a $$ sign has been parsed
 * $$ can thus be used to store its value
 */
void detected_lhs();

/* -------------------- GAUR MODES --------------------*/

/**
 * @brief Set GAUR mode (DEFAULT 1 |DOT 2 |EXTRACT 3)
 *
 * @param mode
 */
void set_mode(int mode);

/**
 * @brief Get the GAUR mode
 *
 * @return int (DEFAULT 1 |DOT 2 |EXTRACT 3)
 */
int get_gaur_mode();

/* -------------------- NONTERMINALS EXTRACT --------------------*/

/**
 * @brief In extract mode, prints nonterminal name to output file
 *
 * @param nterm nonterminial to write
 */
void extract_nterm(char *nterm);

/**
 * @brief In extract mode, prints actions to output file
 *
 * @param action_literal
 */
void extract_function_calls(char *action_literal);

/**
 * @brief
 *
 * @param string
 */
void extract_terminal(char *string);

/**
 * @brief
 *
 * @param nterm
 */
void signal_new_rule(char *nterm);

/**
 * @brief
 *
 */
void signal_action();

/**
 * @brief
 *
 */
void check_midrule_action();

void init_extraction();

/* -------------------- DOT FILE  --------------------*/

/**
 * @brief Initialize regex
 *
 */
void init_dot();
/**
 * @brief Add an edge in the dot file, representing a production rule.
 *
 * @param node1 Left-hand side nonterminal
 * @param node2 Right-hand side nontermial
 */
void add_edge(char *node1, char *node2);

/**
 * @brief Close file
 *
 */
void end_print();