
import pandas as pd
import json

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