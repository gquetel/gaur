# GAUR NLP Repository 

This repository contains different Python scripts to manipulate the data extracted by the GAUR tool. 

## Installation

We provide a whl file containing the classification script, it can be installed as follows:

```
pip install dist/pygaur-0.1-py3-none-any.whl 
```

```
pip install dist/pygaur-0.1-py3-none-any.whl   --no-deps --force-reinstall
```
## Usage 
The main script is the `gclassify.py` one. It expects a GAUR-generated data file where each line corresponds to a Bison grammar rule and associated information (action code, terminals). From this file and the characteristics defined in the tag `data/tags/` folder, it computes flags for each rule and type of characteristic using NLP techniques. 
```
python3 gclassify.py gaur_output tags_filepath
```

We provide an example of tags for MySQL as well as the extracted data with GAUR on the MySQL Bison grammar. By using the following command a file `labels.gaur` will be created.
```
python3 gclassify.py pygaur/data/mysql/extracted/mysql.gaur /home/gquetel/repos/pygaur/pygaur/data/mysql/tags/
```


### Output format 
The output file follows the following structure: 
- On the first line, is displayed the number of characteristics that each grammar rule is characterized by.
- On the same line and divided by commas, for each characteristic we provide the number of bits needed to represent its associated flag.
- Then for each grammar rule in the input file, we output the flags (the number of flags equals the number of characteristics) followed by the rule name and a newline.

## Other features: 
-  A stopword list can also be provided to remove words with no meaning from the extracted data. 

## Terminology
- **Characteristic**: A kind of data that defines the parser rule. Each file in the tag folder defines a new type of characteristic. We propose the `action` and `object` characteristics for DBMS applications.  
