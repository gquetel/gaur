#!/usr/bin/env python3
"""@package gnlp
Given a list of parser rules and a list of tags, assign labels in the form of flags to each parser rule
"""
import pandas as pd
import numpy as np
import argparse
import os

from pygaur import gnlp
from pygaur.utils import write_semantic_file


def get_tresholds(tags: list) -> list:
    """Dummy function that returns default tresholds values for each tag

    Args:
        tags (list): tags list

    Returns:
        list: thresholds list
    """
    return [0.3 for _ in range(len(tags))]

def get_tagfiles_from_folder(tagspath: str) -> list:
    l_filenames = sorted(os.listdir(tagspath))
    tags_files = []

    for filename in l_filenames:
        if filename.endswith(".tags"):
            tags_files.append(tagspath + filename)
    return tags_files


def create_random_semantic_file(
    tagspath: str, fp_output_sem: str, fp_extracted: str
):
    # l_tags: my random tags.
    tags_files = get_tagfiles_from_folder(tagspath)
    df_tags = gnlp.get_df_tags_keywords(tags_files[0])
    l_tags = df_tags.index.to_numpy()
    # Load extracted file to construct df_random's index with rules ids.
    df_extract = gnlp.load_extracted_file(fp_extracted)
    df_random = pd.DataFrame(0, index=df_extract.index, columns=l_tags)
    df_random.index.name = "random" # Makes labels.json without null value.
    np.random.seed(7)
    # Assign tag at random
    random_cols = np.random.randint(
        0, len(df_random.columns), size=len(df_random)
    )
    df_random.values[np.arange(len(df_random)), random_cols] = 1
    write_semantic_file([df_random], fp_output_sem, [l_tags], mode="json")


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
    list_df = []
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
        list_df.append(df_pred)
    write_semantic_file(list_df, fp_output_sem, ll_tags, mode="json")


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

    parser.add_argument(
        "-r",
        "--random",
        action="store_true",
        help="Randomly attribute given semantic tags.",
    )

    args = parser.parse_args()

    if args.output:
        filepath_output = args.output
    if args.stopwords:
        stop_words_set = gnlp.load_stop_words(args.stopwords)

    if args.random:
        create_random_semantic_file(
            tagspath=args.tagspath,
            fp_output_sem=filepath_output,
            fp_extracted=args.filename,
        )
    else:
        create_semantic_file_mysql(
            model_name,
            args.filename,
            filepath_output,
            args.tagspath,
            stop_words_set,
        )


if __name__ == "__main__":
    main()
