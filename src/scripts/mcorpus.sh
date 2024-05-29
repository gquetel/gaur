#!/bin/bash

for i in data/grammars/*.y; do
    echo ">>> Beginning test with: $i "
    ./gaur -e -o "output/rules.extracted" "$i"
    errno=$?
    if [ $errno -ne 0 ]; then
        echo "Error while extracting $i - not including grammar in corpus"
        continue
    fi
    cat output/rules.extracted >> output/corpus.txt
    rm output/rules.extracted
done

