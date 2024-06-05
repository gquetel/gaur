# GAUR usage example with dummy grammar 

W defined a dummy `sem` grammar whose objective is to illustrate how to use GAUR. This folder consists of: 
- A `parse.y` bison grammar file that defines the grammar. 
- Its associate simple lexer `parse.l`.
- The csv file produced by the extract mode of gaur `nterm_list.csv`.
- The output of `pygaur` given the `nterm_list.csv`.
- And the `Makefile` which defines commands to instrument the grammar. 

## Details 

We here detail the overall grammar instrumentation pipeline of the `sem` grammar. 

### Data extraction

Once `gaur` has been compiled, we can extract rules information used by `pygaur` for the inference part: 

```
../../gaur --extract parse.y 
```

This generates the `nterm_list.csv` file. For each rule, it contains left-hand side nonterminal names, right-hand side terminals, and alphabetic words found in action code.

### Rule label inference:
In a normal scenario, you would use the `pygaur` package to generate semantic labels for each parser rule from the `nterm_list.csv` file. To make this example without installing `pygaur` we pre-computed the program output given the grammar file `parse.y` and included it in the repository. The file `nterm_sem.json` corresponds to that output and must now be given to GAUR to instrument the grammar file. Labels are represented in the form of flags (in case we authorize multiple labels for a single rule, which is not the case for now). Here is an outline of the file produced by `pygaur`. 

```json
 "GENERAL": {
  "flags_number": 2, // 2 =  Action and object flags, used when declaring ggrulesem
  "flags_sizes": [  // Must be > 0 and < 32
   5, 
   11 
  ],
  "rules_number": 18, //Number of rules in grammar, used when declaring ggrulesem
  "flags_names": [
   "actions",
   "objects"
  ]
 },
 "RULES": [
  { // Each entry here will correspond to a new entry in ggrulesem with its associated tags
   "name": "input.0",
   "flags": [
    "00000",
    "00000000000"
   ]
  },
  {
   "name": "input.1",
   "flags": [
    "00000",
    "00000000000"
   ]
  }, 
  [...]
 ]
```
The fields in RULES allow us to create the rule -> labels array that we include in the instrumented parser.


## Instrumentation
Now that we have the grammar file to the instrument, the semantic information, and the skeleton to use to generate the parser we can instrument the grammar: 

``` 
../../gaur -i ../../src/injects/simple-vector.c -l nterm_sem.json -o gaur.modified.y parse.y
```

Then the instrumented parser can be given to bison and then compiled: 
```
bison -d -t -o parse.c gaur.modified.y
flex  -o scan.c --header=scan.h parse.l 
cc -g -Wall -o parse.o -c parse.c 
cc -g -Wall -o scan.o -c scan.c 
cc  -o parse parse.o scan.o -L/opt/local/lib -lreadline -lm 
```

We can test the log production by starting the parser: 
```
./parse
create 
>> Ctrl+D to send EOF and terminate parsing
```

A a log file named `gaur.log` is created.

