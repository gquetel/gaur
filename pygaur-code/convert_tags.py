#!/usr/bin/env python3
""" 
    Script to convert tags association performed by LLM or other tools into the JSON 
    file expected by GAUR.
"""

# Make gclassify import work
# import sys
# sys.path.append("../")


import pandas as pd
import argparse

from pygaur.utils import write_semantic_file


def init_args() -> argparse.Namespace:
    """Argsparse initializing function.

    Returns:
        argparse.Namespace: Parsed arguments.
    """
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--csv",
        type=str,
        dest="csv",
        required=True,
        help="Filepath to the csv file.",
    )

    parser.add_argument(
        "--extracted",
        "-e",
        type=str,
        dest="extracted",
        required=True,
        help="Filepath to the extracted data.",
    )

    parser.add_argument(
        "--output",
        "-o",
        type=str,
        dest="output",
        required=True,
        help="Filepath to the output file.",
    )

    return parser.parse_args()

def load_tags(filepath : str):
    # This file does not list ALL rules, but the lfs name: one entry per group rule.
    df = pd.read_csv(filepath)
    unique_tags = sorted(df['tag'].unique())
   
    # First tag has the highest flag value, last one is 1.
    df_onehot = pd.DataFrame(0, index=df['rulename'], columns=unique_tags)
    for _, row in df.iterrows():
        rulename = row['rulename']
        tag = row['tag']
        df_onehot.at[rulename, tag] = 1
    return unique_tags, df_onehot

def expand_rules(filepath : str, df_tags : pd.DataFrame):
    """ From the file listing extracted rules by GAUR, and provided tag mapping (
    obtained from a LLM) associate the correct tag to each rule. 
    """
    results = []
    # Index is actual rule
    df_extract = pd.read_csv(
        filepath, names=["terminals", "code"], keep_default_na=False
    )
    for index, _ in df_extract.iterrows(): 
        # If no dot, is an mid rule action.  We split on '$' retrieve [1], and
        # search in df_tags the row ending with '_[1]'.
        if "." not in index:
            s = f"_{index.split('@')[1]}"
            key = next(idx for idx in df_tags.index if str(idx).endswith(s))
        else: 
            # If dot, retrieve [0] and search in df_tags the matching row, raise alert
            # if does not exist.   
            key = index.split(".")[0]

        # Retrieve tag given by LLM to that 
        tag_values = df_tags.loc[key].to_dict()
        tag_values['chatgpt-tags'] = index
        results.append(tag_values)

    df_res = pd.DataFrame(results).set_index('chatgpt-tags')
    return df_res
    


if __name__ == "__main__":
    args = init_args()
    tags, df_grouprules = load_tags(args.csv)
    df_tags = expand_rules(args.extracted, df_grouprules)
    write_semantic_file([df_tags], args.output, [tags], mode="json")