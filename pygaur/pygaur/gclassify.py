#!/usr/bin/env python3
"""@package gnlp
    Given a list of parser rules and a list of tags, assign labels in the form of flags to each parser rule
"""
import pandas as pd
import argparse
import os

from pygaur import gnlp

def compute_threshold_semantic(tags: list) -> list:
    """Simple function that returns a list of tresholds for each tag

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


def write_semantic_file(list_df: list, filepath: str, mode: str = "json"):
    """Write the rule labels to a file in the form of flags

    Args:
        list_df (list): list of dataframes containing flags, one dataframe for each type of tag
        filepath (str): filepath to the output file
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
            import json

            # Create a nested dictionary
            config = {}
            config["GENERAL"] = {}
            config["GENERAL"]["flags_number"] = len(df_flags.columns)
            config["GENERAL"]["flags_sizes"] = [flag for flag in flags_size]
            config["GENERAL"]["rules_number"] = len(df_flags.index)
            config["GENERAL"]["flags_names"] = [
                df.index.name for df in list_df
            ]
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


def create_semantic_file(
    model_name: str,
    filepath: str,
    filepath_output: str,
    tagspath: str,
    stop_words_set: set,
):
    """Main function that iterates over each tag file (.tag extension) in the tags folder and
        and attributes labels to each rule from the input file.

    Args:
        model_name (str): Sentence BERT model name
        filepath (str): Filepath to file which contains rule informations
        tagspath (str): Filepath to folder containing the different tag files
        filepath_output (str): Filepath for result file
        stop_words_set (set): Set of stop words to ignore for similarity computation
    """
    model = gnlp.init_sentence_model(model_name)

    df_labels = []
    for tag_file in os.listdir(os.fsencode(tagspath)):
        if tag_file.endswith(b".tags"):
            filename = os.fsdecode(tag_file)
            tag_filepath = "".join([tagspath, filename])

            list_keywords, possible_tags = gnlp.build_tags_and_keywords_lists(
                model, tag_filepath
            )
            print("> Defined", filename, " tags:", possible_tags)
            df_pred = gnlp.compute_nterm_semantic_max(
                filepath, model, possible_tags, stop_words_set, list_keywords
            )
            tresholds = compute_threshold_semantic(possible_tags)

            # For now we want at most a single label
            df_pred = gnlp.keep_maximum_score(df_pred)

            gnlp.apply_treshold_nterm(df_pred, tresholds, possible_tags)

            # Save tags category (given by filename without extension .tags) to dataframes index name.
            df_pred.index.name = os.path.splitext(filename)[0]
            df_labels.append(df_pred)

    write_semantic_file(df_labels, filepath_output, mode="json")


def create_semantic_file_mysql(
    model_name: str,
    filepath: str,
    filepath_output: str,
    tagspath: str,
    stop_words_set: set,
):
    """Main function that iterates over each tag file (.tag extension) in the tags folder and
        and attributes labels to each rule from the input file.

    Args:
        model_name (str): Sentence BERT model name
        filepath (str): Filepath to file which contains rule informations
        tagspath (str): Filepath to folder containing the different tag files
        filepath_output (str): Filepath for result file
        stop_words_set (set): Set of stop words to ignore for similarity computation
    """
    model = gnlp.init_sentence_model(model_name)
    df_labels = []

    # In directory denoted by tagspath, we are expecting two files:
    # 1. A file with  a list of actions tags
    # 2. A file with a list of object tags

    ACTIONS_FILENAME = "actions.tags"
    OBJECTS_FILENAME = "objects.tags"

    full_path_actions = tagspath + ACTIONS_FILENAME
    full_path_objects = tagspath + OBJECTS_FILENAME

    try:
        os.path.exists(full_path_actions)
    except FileNotFoundError:
        print("No actions.tags file found in specified path", filepath_output)
        exit()
    try:
        os.path.exists(full_path_objects)
    except FileNotFoundError:
        print("No objects.tags file found in specified path", filepath_output)
        exit()

    tag_files = [full_path_actions, full_path_objects]
    for tag_file in tag_files:
        list_keywords, possible_tags = gnlp.build_tags_and_keywords_lists(
            model, tag_file
        )
        tag_type = tag_file.split("/")[-1].rstrip(".tags")
        print(f"> Defined {tag_type} tags:{possible_tags}")
        df_pred = gnlp.compute_nterm_semantic_max(
            filepath, model, possible_tags, stop_words_set, list_keywords
        )
        tresholds = compute_threshold_semantic(possible_tags)

        # For now we want at most a single label
        df_pred = gnlp.keep_maximum_score(df_pred)

        gnlp.apply_treshold_nterm(df_pred, tresholds, possible_tags)

        # Save tags category (given by filename without extension .tags) to dataframes index name.
        df_pred.index.name = os.path.splitext(tag_type)[0]
        df_labels.append(df_pred)

    write_semantic_file(df_labels, filepath_output, mode="json")


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
