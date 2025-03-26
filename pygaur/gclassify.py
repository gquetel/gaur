#!/usr/bin/env python3
"""@package gnlp
Given a list of parser rules and a list of tags, assign labels in the form of flags to each parser rule
"""
import pandas as pd
import argparse
import os
import json
from pygaur import gnlp


def get_tresholds(tags: list) -> list:
    """ Dummy function that returns default tresholds values for each tag

    Args:
        tags (list): tags list

    Returns:
        list: thresholds list
    """
    return [0.3 for _ in range(len(tags))]


def check_indexes(list_df: list) -> bool:
    """Returns true if all dataframes in given list possess the same indexes in the same order

    Args:
        list_df (list): list of dataframes

    Returns:
        bool: True if all dataframes have the same indexes
    """
    first_index = list_df[0].index
    for df in list_df[1::]:
        if not df.index.equals(first_index):
            return False
    return True


def write_semantic_file(
    list_df: list, filepath: str, ll_tags: list, mode: str = "json"
):
    """Write as json all informations required by GAUR to inject semantic knowledge into the parser.

    Args:
        list_df (list): Dataframes (each representing a semantic class) with the flag value for each rule (representing the associated label).
        filepath (str): Filepath to write json file to
        ll_tags (list): Lists (each representing a semantic class), of possible semantic tag values.
        mode (str, optional): Defaults to "json".

    Raises:
        Exception: _description_
        Exception: _description_
    """
    if check_indexes(list_df):
        df_flags = pd.DataFrame(index=list_df[0].index)
        flags_size = []  # Stores the amount of bits for each flag

        for i, df in enumerate(list_df):
            # Concat all values of a row and convert them to a binary value
            flags = df.apply(
                lambda row: int("".join(row.astype(str)), 2), axis=1
            )
            df_flags[f"flag_{i}"] = flags
            # Store flag size value
            flags_size.append(len("".join(df.iloc[0].astype(str))))

        if mode == "custom":
            # Deprecated, do not use.
            with open(filepath, "w") as f:
                # Write in file the number of flags
                f.write(f"{len(df_flags.columns)},")

                # Write the number of bits required for each flag
                for size in flags_size:
                    f.write(f"{size},")
                f.write("\n")

                for index, row in df_flags.iterrows():
                    # Write in file the binary value of each column value
                    flags_binary = [
                        f"{flag:0{size}b}"
                        for flag, size in zip(row, flags_size)
                    ]
                    f.write(f"{''.join(flags_binary)}{index}\n")
                f.close()
        elif mode == "json":

            # Create a nested dictionary
            config = {}
            config["GENERAL"] = {}
            config["GENERAL"]["flags_number"] = len(df_flags.columns)
            config["GENERAL"]["flags_sizes"] = [flag for flag in flags_size]
            config["GENERAL"]["rules_number"] = len(df_flags.index)
            config["GENERAL"]["flags_names"] = [
                df.index.name for df in list_df
            ]
            config["GENERAL"]["tag_values"] = {}

            # Supposedly len(list_df) == len(ll_tags)
            for i, df in enumerate(list_df):
                config["GENERAL"]["tag_values"][df.index.name] = list(
                    ll_tags[i]
                )

            config["RULES"] = []

            # Create dictionnary entry for each rule
            for index, row in df_flags.iterrows():
                rule = {
                    "name": index,
                    "flags": [
                        f"{flag:0{size}b}"
                        for flag, size in zip(row, flags_size)
                    ],
                }
                config["RULES"].append(rule)

            # Write the dictionary to a file using json
            with open(filepath, "w") as f:
                json.dump(config, f, indent=1)
        else:
            raise Exception("Invalid mode", mode)
    else:
        raise Exception("Indexes of the dataframes are not the same")


def get_tagfiles_from_folder(tagspath: str) -> list:
    l_filenames = sorted(os.listdir(tagspath))
    tags_files = []

    for filename in l_filenames:
        if filename.endswith(".tags"):
            tags_files.append(tagspath + filename)
    return tags_files


def create_semantic_file_mysql(
    model_name: str,
    fp_extracted: str,
    fp_output_sem: str,
    tagspath: str,
    stop_words_set: set,
):
    """Main function that iterates over each tag file (.tag extension) in the tags folder and
        and attributes labels to each rule from the input file.

    Args:
        model_name (str): Sentence BERT model name
        fp_extracted (str): Filepath to file which contains rule informations
        fp_output_sem (str): Filepath for result file
        tagspath (str): Filepath to folder containing the different .tags files
        stop_words_set (set): Set of stop words to ignore for similarity computation
    """
    model = gnlp.init_sentence_model(model_name)
    tags_files = get_tagfiles_from_folder(tagspath)
    df_labels = []
    ll_tags = (
        []
    )  # List of lists of semantic tags ( a list for each semantic class)

    for fp_tags in tags_files:
        df_keywords = gnlp.get_tags_keywords_embeddings(model, fp_tags)
        possible_tags = df_keywords["tag"].unique()
        ll_tags.append(possible_tags)
        tag_type = fp_tags.split("/")[-1].removesuffix(".tags")

        print(f"> Defined {tag_type} tags:{possible_tags}")
        df_pred = gnlp.compute_nterm_semantic_max(
            fp_extracted, model, possible_tags, stop_words_set, df_keywords
        )
        tresholds = get_tresholds(possible_tags)

        # For now we want at most a single label
        df_pred = gnlp.keep_maximum_score(df_pred)

        gnlp.apply_treshold_nterm(df_pred, tresholds, possible_tags)

        # Save tags category (given by filename without extension .tags) to dataframes index name.
        df_pred.index.name = os.path.splitext(tag_type)[0]
        df_labels.append(df_pred)

    write_semantic_file(df_labels, fp_output_sem, ll_tags, mode="json")


def main():
    filepath_output = "output/labels.gaur"
    model_name = "multi-qa-MiniLM-L6-cos-v1"
    stop_words_set = set()

    parser = argparse.ArgumentParser(
        description="Compute semantic similarity of documents extracted from a Bison grammar with already defined tags."
    )
    parser.add_argument(
        "filename", type=str, help="list of nonterminals, one per line."
    )
    parser.add_argument(
        "tagspath", type=str, help="Path to folder containing tags files."
    )
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        help="destination filepath",
        metavar="filename",
        dest="output",
    )
    parser.add_argument(
        "-s",
        "--stwords",
        type=str,
        help="stopwords list filepath",
        metavar="stopwords",
        dest="stopwords",
    )
    args = parser.parse_args()

    if args.output:
        filepath_output = args.output
    if args.stopwords:
        stop_words_set = gnlp.load_stop_words(args.stopwords)

    create_semantic_file_mysql(
        model_name,
        args.filename,
        filepath_output,
        args.tagspath,
        stop_words_set,
    )


if __name__ == "__main__":
    main()
