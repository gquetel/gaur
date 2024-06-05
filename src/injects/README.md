# Inject files

Directory listing of the different GAUR injection files. These files consist of the data collector code and define the routines executed when the parser performs a reduction, a shift or finishes to parse an input.
We denote the rule number by its associated line number in the generated file `rules.extracted`. The semantic of a rule is the computed semantic given by `gclassify`.

| Filename                         | Description                                                                                                                             |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `simple-vector.c`                | Output an entry in a csv format with the following informations : query_id, semantic_trace, terminal_c, nonterminal_c, is_syntax_error. |
| `simple-vector.mysql.cpp`        | Same as `simple-vector.c` but adapted for MySQL parser code.                                                                            |
| `simple-vector.wquery.mysql.cpp` | Not usable right now, bugs with csv formating. Aims to add a column with the input at the origin of this log entry                      |


## simple-vector semantic trace format: 
In pseudo-bison code

``` 
trace:  node "|" trace |  node ; 
node: rule_number ":" action_tag ":" object_tag ; 

action_tag: STRING | %empty;
object_tag: STRING | %empty;
rule_number: INT ; 
```