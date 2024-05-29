#!/bin/bash
NLPBIN="gclassify"

# Currently not using stopwords 

for i in data/grammars/*.y; do
    echo ">>> Beginning test with: $i "
    ./gaur -e -o "output/rules.extracted" "$i"
    errno=$?
    if [ $errno -ne 0 ]; then
        echo "Error while extracting $i - skipping next tests..."
        continue
    fi
    ${NLPBIN} -o output/nterm_sem.txt output/rules.extracted"
    errno=$?
    if [ $errno -ne 0 ]; then
        echo "Error while executing gclassify $i - skipping next tests..."
        continue
    fi
    ./gaur --list output/nterm_sem.txt -o output/gaur.modified.y "$i" 
    
    bison -v gaur.modified.y -b "output/"
    if [ $errno -ne 0 ]; then
        echo "Error while parsing modified grammar for $i - skipping next tests..."
        continue
    fi

    bison -v "$i" --report-file original.output -b "output/"
    diff "output/gaur.modified.output" "output/original.output"   
    rm -f output/*.output output/*.c output/*.h gaur.modified.y output/*.txt output/*.cc output/*.hh
done
