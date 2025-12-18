# GAUR


GAUR is a parser-based instrumentation framework designed to collect **lexical, syntactic, and explicit semantic observations** for application-level intrusion detection systems (AIDS). It operates by automatically instrumenting GNU Bison grammars, enabling data collection at **parse time**, with **negligible runtime overhead** and **no runtime natural language processing**.

The instrumentation method is further described in our paper: TODO

Examples of instrumented applications are available at [gaur-instrumented-apps](https://github.com/gquetel/gaur-instrumented-apps/).
# Installation

To build GAUR, the following tools are required:

- gcc
- make
- flex
- bison

At runtime, the processing pipeline relies on Python packages defined in `pygaur/requirements.txt`.

A `shell.nix` file is provided to create a reproducible environment containing all required dependencies.

After cloning the repository, GAUR can be built using:

```
$ git clone https://github.com/gquetel/gaur.git

$ make build
```

This produces a `gaur` executable in the current directory.

```
$ ./gaur -h
Usage: gaur [options] -l file file
Transform a Bison grammar into an instrumented one.

Options:
-d, --dot Produce a dot file for the input grammar
-e, --extract Produce a file containing all grammar nonterminals
-h, --help Display this help and exit
-i, --inject=FILE Path to the prologue code to inject
-l, --list=FILE Path to the rule-to-semantic-tags mapping file
-o, --output=FILE Write output to FILE
-s, --skeleton=FILE Path to a custom Bison skeleton to use

If the option -o is not used, the default output grammar filename is:
gaur.modified.y
```



# Overview of the GAUR Pipeline

GAUR follows a **three-phase architecture** that explicitly separates semantic modeling from runtime data collection.

1. **Semantic Model Definition**
2. **Static Rule-to-Semantic Tag Attribution**
3. **Parser instrumentation***

## 1. Semantic Model Definition  


A **semantic model** is a set of semantic tags that explicitly describe how user inputs interact with the application or system. GAUR does not impose any specific model. The semantic model is defined **prior to instrumentation** and can be:

- Defined manually by a domain expert
- Generated automatically using Large Language Models (LLMs)

This step is external to GAUR and produces a fixed list of semantic tags.



## 2. Static Rule-to-Semantic Tag Attribution

Each grammar rule is statically associated with one (or more) semantic tags from the chosen semantic model. This attribution is performed **once**, before deployment.

## Rule Data Extraction

GAUR can extract descriptive information from a Bison grammar to assist this attribution process. For each grammar rule, it extracts:

- Left-hand side nonterminal name
- Right-hand side terminals and nonterminals
- Identifiers found in semantic action code

The extracted data is exported as a CSV file where each line corresponds to a specific grammar rule instance. For example:
```
column_attribute.5,ON_SYM UPDATE_SYM,PT_on_update_column_attr
```

## Attribution Mechanisms

The association between grammar rules and semantic tags can be performed using different strategies, such as:

- Expert-driven labeling and embedding-based similarity (e.g., Sentence-BERT)
- LLM-based classification (we provide the [prompt](data/prompt.md) used to instantiate the semantic model and associate tags to MySQL grammar rules).

These mechanisms are implemented in `pygaur` and are **not part of the data collector's runtime**. The output is a static mapping file that associates each grammar rule identifier with semantic tags.

## 3. Parser Instrumentation 

GAUR instruments the input Bison grammar to embed data collection logic directly into the generated parser.

This is achieved through two mechanisms:

1. **Custom Bison Skeleton**
2. **Injected Data Collection Code**

## Custom Skeleton

GAUR can rely on a custom Bison skeleton that introduces hooks at key parsing stages, such as:

- Parser initialization
- Token shifts
- Rule reductions
- Parsing termination or error handling

This ensures tight integration with the parser’s execution flow.

## Injected Data Collection Code

The injected code defines macros and data structures used to build observations during parsing. Typical macros include:

- `GAUR_PARSE_BEGIN`: initializes data collection structures
- `GAUR_SHIFT`: monitors token consumption and parsing completion
- `GAUR_REDUCE`: records rule reductions and associated semantic tags
- `GAUR_ERROR`: handles syntactic or memory errors
- `GET_SEMANTIC_TAG`: retrieves semantic tags associated with a rule identifier

An array mapping rule identifiers to their semantic tags is injected into the parser using the mapping file provided via the `--list` option.

# Runtime Data Collection

For each processed input, GAUR produces a **tree-structured representation** that encodes:

- **Lexical information**: terminal types and values
- **Syntactic information**: grammar rule identifiers and parse tree hierarchy
- **Semantic information**: explicit semantic tags associated with applied rules

This representation is generated:

- Upon successful parsing
- Or upon parsing failure (ensuring coverage of invalid inputs)

Flattening this structure into feature vectors (e.g., counters or Boolean features) is a **post-processing step** and is not part of GAUR itself.

# Relationship to pygaur

`pygaur` is an auxiliary toolchain used to assist with:

- Rule data extraction
- Semantic model instantiation
- Rule-to-tag attribution