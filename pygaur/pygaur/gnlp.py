import pandas as pd
import math
from sentence_transformers import SentenceTransformer


def init_sentence_model(model_name: str) -> SentenceTransformer:
    """ Returns an instancied SentenceTransformer model

    Args:
        model_name (str): model to use

    Returns:
        SentenceTransformer:
    """

    model = SentenceTransformer(model_name)
    return model


def compute_similarity(document: str, model: SentenceTransformer, possible_tags: list, list_keywords: list) -> dict:
    """ Compute semantic similarity scores between document and all tags in possible tags using model.

    Args:
        document (str): document to compute semantic similarity for
        model (SentenceTransformer): Instancied SentenceTransformer model
        possible_tags (list): list of tags to compute semantic similarity with
        list_keywords (list): list of keywords related to tags

    Returns:
        dict: dictionnary of semantic similarity scores, indexes are tags and values are associated score
    """
    embedding = model.encode(document)
    best_values = {tag: -1 for tag in possible_tags}

    for keyword in list_keywords.index:
        tag, vector = list_keywords.loc[keyword]
        cs = cosine_similarity(embedding, vector[0])
        if (cs > best_values[tag]):
            best_values[tag] = cs
    return best_values


def build_tags_and_keywords_lists(model: SentenceTransformer, filepath: str) -> tuple:
    """Build the list of keywords and the list of possible tags. 

    We return a tuple of : (list_keywords, possible_tags)
    (1) list_keywords is a dataframe of keywords, their tags and their embeddings
    (2) possible_tags is a list of the different tags defined in tags file
    Args:
        model (SentenceTransformer): models to compute embeddings with

    Returns:
        tuple: (list_keywords, possible_tags)
    """
    df = pd.DataFrame()

    with open(filepath, 'r') as f:
        lines = f.readlines()
        for line in lines:
            keywords = line.split(',')
            keywords = [keyword.rstrip() for keyword in keywords]
            tag = [keywords[0] for _ in range(len(keywords))]
            vectors = []

            for keyword in keywords:
                vectors.append(model.encode(keyword))
            df = pd.concat([df, pd.DataFrame(
                {'keyword': keywords, 'tag': tag, 'vector': vectors})])
    df.set_index('keyword', inplace=True)
    possible_tags = df['tag'].unique()
    return (df, possible_tags)


def load_extracted_file(filepath: str) -> pd.DataFrame:
    """Generate a DataFrame from grammar extracted data by GAUR

    Args:
        filepath (str): path to file of extracted data by GAUR

    Returns:
        pd.DataFrame: Dataframe with index = lhs, columns = [terminals, code]
    """
    df_extract = pd.read_csv(
        filepath, names=["terminals", "code"], keep_default_na=False)
    return df_extract


def load_stop_words(filepath: str) -> set:
    """ Returns a set of stopwords from file denoted by filepath

    Args:
        filepath (str): path to file of stopwords, one stopword per line

    Returns:
        set: set of stopwords 
    """
    set_stop_words = set()
    with open(filepath) as f:
        lines = f.readlines()
        for line in lines:
            set_stop_words.add(line.rstrip())
    return set_stop_words


def post_process_weight(df_pred: pd.DataFrame):
    """ Updates modify weights based on create and delete weights

    As we consider creations and delete operations as modify ones we have to 
    update modify weights based on the values of create and modify
    Args:
        df_pred (pd.DataFrame): dataframe containing predictions to update
    """
    df_pred['modify'] = df_pred.apply(lambda row: max(
        row['create'], row['delete'], row['modify']), axis=1)


def cosine_similarity(v1: list, v2: list) -> float:
    """Returns cosine similarity score between two embeddings of same size

    Cosine similarity is a value between -1 and 1. A value close to 1 means that the two embeddings are
    similar. In our use case it means the two embedded inputs are semantically similar. 

    Args:
        v1 (list): Vector embedding
        v2 (list): Vector embedding

    Returns:
        float: Cosine similarity score
    """
    sumxx, sumxy, sumyy = 0, 0, 0
    for i in range(len(v1)):
        x = v1[i]
        y = v2[i]
        sumxx += x*x
        sumyy += y*y
        sumxy += x*y
    return sumxy/math.sqrt(sumxx*sumyy)


def keep_maximum_score(df_pred: pd.DataFrame):
    """ For each rule, keeps the maximum score of all tags"""

    def __keep_maximum_score(row):
        max_col = row.idxmax()
        row[row.index != max_col] = -1
        return row
    df_pred = df_pred.apply(__keep_maximum_score, axis=1)
    return df_pred


def apply_treshold_nterm(df_pred: pd.DataFrame, tresholds: list, possible_tags: list):
    """ Sets semantic score to 1 if prediction is superior to tresholds

    Args:
        df_pred (pd.DataFrame): Dataframe of predictions
        tresholds (list): list of tresholds for each tag
        possible_tags (list): list of tags
    """

    for itag in range(len(possible_tags)):
        def filter_nterm(x): return 0 if tresholds[itag] > x else 1
        df_pred[possible_tags[itag]
                ] = df_pred[possible_tags[itag]].apply(filter_nterm)


def compute_nterm_semantic_max(filepath: str, model, possible_tags: list, set_stop_words: set, list_keywords: list):
    """ Compute semantic similarity score with the previously defined tags for all documents in file denoted by filepath


    The input file must contain one document per line. One document represents one rule from the grammar. RULE_COUNTER is an integer representing the rule number from the set of rules associated to lhs.
    Format: lhs.RULE_COUNTER [Nonterminals] [Action alphabetical symbol] 

    This method compute semantic similarity scores for lhs and rhs compared to our tags. The rule score is obtain through the computation of the maximum between lhs and rhs scores.
    Args:
        filepath (str): File containing documents of extracted data from Bison grammar,
        model (SentenceTransformer): SentenceTransformer model to compute embeddings and semantic similarity scores with
        possible_tags (_type_): Tags to compare documents to
        set_stop_words (_type_): Stop words to remove from documents
        list_keywords (_type_): Keywords to compare documents to

    Returns:
        pd.DataFrame: Dataframe where indexes are "lhs.RULE_COUNTER", and columns corresponds to tags 
    """
    results = {}
    df_extract = load_extracted_file(filepath)

    for lhs, row in df_extract.iterrows():
        rhs = " ".join([row["terminals"], row["code"]])
        best_values = {tag: -1 for tag in possible_tags}

        rhs = rhs.lower()  # Standardize
        rhs = ' '.join([word for word in rhs.split()  # Stop words removal
                        if word not in set_stop_words])

        rhs = rhs.lower()  # lowercase
        rhs = rhs.replace("_", " ") # Replace underscore by space
        rhs = list(dict.fromkeys(rhs.split(" ")))  # uniq
        rhs = " ".join(rhs)
        if row["code"]:
            try:
                embedding_rhs = model.encode(rhs)
                embedding_lhs = model.encode(lhs)
                # Test similarity for each keyword, and retain highest similarity value for each tag
                for keyword in list_keywords.index:
                    tag, vector = list_keywords.loc[keyword]
                    cs = cosine_similarity(
                        embedding_rhs, vector)
                    if (cs > best_values[tag]):
                        best_values[tag] = cs

                    cs = cosine_similarity(
                        embedding_lhs, vector)
                    if (cs > best_values[tag]):
                        best_values[tag] = cs

            except KeyError:
                pass
        results[lhs] = best_values.values()
    return pd.DataFrame(results, index=possible_tags).transpose()


def compute_nterm_semantic_mean(filepath: str, model: SentenceTransformer, possible_tags, set_stop_words, list_keywords) -> pd.DataFrame:
    """ Compute semantic similarity score with the previously defined tags for all documents in file denoted by filepath


    The input file must contain one document per line. One document represents one rule from the grammar. RULE_COUNTER is an integer representing the rule number from the set of rules associated to lhs.
    Format: lhs.RULE_COUNTER [Nonterminals] [Action alphabetical symbol] 

    This method compute semantic similarity scores for lhs and rhs compared to our tags. The rule score is obtain through the computation of the average between lhs and rhs scores.
    Args:
        filepath (str): File containing documents of extracted data from Bison grammar,
        model (SentenceTransformer): SentenceTransformer model to compute embeddings and semantic similarity scores with
        possible_tags (_type_): Tags to compare documents to
        set_stop_words (_type_): Stop words to remove from documents
        list_keywords (_type_): Keywords to compare documents to

    Returns:
        pd.DataFrame: Dataframe where indexes are "lhs.RULE_COUNTER", and columns corresponds to tags 
    """
    results = {}
    df_extract = load_extracted_file(filepath)

    for lhs, row in df_extract.iterrows():
        rhs = " ".join([row["terminals"], row["code"]]).rstrip('\n')
        best_values = {tag: -1 for tag in possible_tags}
        lhs = lhs.rstrip('\n')

        # No code -> No semantic
        if row["code"]:
            rhs = rhs.lower()  # Standardize
            rhs = ' '.join([word for word in rhs.split()  # Stop words removal
                            if word not in set_stop_words])

            rhs = rhs.lower()  # lowercase
            rhs = list(dict.fromkeys(rhs.split(" ")))  # uniq
            rhs = " ".join(rhs)
            try:
                embedding_rhs = model.encode(rhs)
                embedding_lhs = model.encode(lhs)
                # Test similarity for each keyword, and retain highest similarity value for each tag
                for keyword in list_keywords.index:
                    tag, vector = list_keywords.loc[keyword]
                    cs1 = cosine_similarity(
                        embedding_rhs, vector[0])

                    cs2 = cosine_similarity(
                        embedding_lhs, vector[0])
                    cs = cs1+cs2 / 2

                    if (cs > best_values[tag]):
                        best_values[tag] = cs

            except KeyError:
                pass
        results[lhs] = best_values.values()

    return pd.DataFrame(results, index=possible_tags).transpose()
