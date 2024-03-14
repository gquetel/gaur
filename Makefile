LEX = flex
BISON = bison -d -t
CC = gcc 

CPPFLAGS=-I ./include
CFLAGS=-g -Wall
GRAMMARFILE=parse.y
INJECTFILE=/usr/local/gaur/src/injects/inject.c
GCLASSIFY=/home/gquetel/repos/pygaur/gclassify.py

all: run   

# -------------------- INSTALLATION FILES   --------------------
install: /usr/local/gaur/src/injects/ /usr/share/bison/skeletons/

output: 
	@mkdir -p $@

/usr/local/gaur/src/injects/: src/injects/*.c src/injects/*.cpp | /usr/local/gaur/src/
	sudo cp -r src/injects/*.c $@
	sudo cp -r src/injects/*.cpp $@

/usr/local/gaur/src/:
	    sudo mkdir -p /usr/local/gaur/src/injects/

/usr/share/bison/skeletons/: src/skeletons/
	sudo cp src/skeletons/ $@


# -------------------- BUILD GAUR BINARY --------------------
build: output install gaur 

gaur: gmodify.o dll.o lex.yy.o gaur.tab.o 
	$(CC) $(CFLAGS) -o gaur $^  

lex.yy.c: gaur.l gaur.tab.h
	$(LEX) gaur.l

gaur.tab.c gaur.tab.h: gaur.y
	$(BISON) gaur.y 

gmodify.o: ./src/gmodify.c ./include/gmodify.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

dll.o: ./src/dll.c ./include/dll.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

lex.yy.o: lex.yy.c gaur.tab.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

gaur.tab.o: gaur.tab.c gaur.tab.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

# -------------------- INSTRUMENT  --------------------

run: gaur output/nterm_sem.csv
	./gaur --list output/nterm_sem.csv $(GRAMMARFILE) -i $(INJECTFILE)  -o output/gaur.modified.y

output/stopwordlist.txt: output/corpus.txt
	mswlist output/corpus.txt -o output/stopwordlist.txt
	
output/nterm_list.txt: gaur | output
	./gaur -e $(GRAMMARFILE) -o output/nterm_list.txt

output/nterm_sem.csv:  output/nterm_list.txt output/output.dot | output
	$(GCLASSIFY) -o output/nterm_sem.csv output/nterm_list.txt

output/output.dot: gaur | output
	./gaur -d parse.y -o output/parse.dot

graph:  output/output.dot
	dot -Tsvg  output/output.dot -o output/parse.svg
	xdg-open output/parse.svg

# -------------------- TEST & Clean --------------------
output/corpus.txt: gaur | output
	src/scripts/mcorpus.sh
	
corpus: output/corpus.txt

clean: 
	@rm -f gaur gaur.tab.c lex.yy.c gaur.tab.h gaur.modified.y
	@rm -f gaur.parse.y gaur.parse.tab.c gaur.parse.tab.h 
	@rm -f *.o *.svg *.dot *.output
	@rm -rf output 
	@cd examples/ ; make clean

# -------------------- UNINSTALL   --------------------
uninstall:
	@sudo rm -rf /usr/local/gaur/ 

