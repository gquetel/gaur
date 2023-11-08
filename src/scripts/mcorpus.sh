#!/bin/bash

for i in data/grammars/*.y; do
    echo ">>> Beginning test with: $i "
    ./gaur -e -o "output/nterm_list.txt" "$i"
    errno=$?
    if [ $errno -ne 0 ]; then
        echo "Error while extracting $i - not including grammar in corpus"
        continue
    fi
    cat output/nterm_list.txt >> output/corpus.txt
    rm output/nterm_list.txt
done

