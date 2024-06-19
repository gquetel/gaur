LEX = flex
BISON = bison -d -t
CC = gcc 

CPPFLAGS=-I ./include
CFLAGS=-g -Wall
GRAMMARFILE=parse.y
INJECTFILE=~/.gaur/src/injects/inject.c
GCLASSIFY=gclassify

all: build  

# -------------------- INSTALLATION FILES   --------------------
install: ~/.gaur/src/injects/ ~/.gaur/src/skeletons/

output: 
	@mkdir -p $@

~/.gaur/src/injects/: src/injects/*.c src/injects/*.cpp 
	mkdir -p ~/.gaur/src/injects/
	cp -r src/injects/*.c $@
	cp -r src/injects/*.cpp $@

~/.gaur/src/skeletons/: src/skeletons/*.c
	mkdir -p ~/.gaur/src/skeletons/
	cp src/skeletons/* $@

# -------------------- BUILD GAUR BINARY --------------------
build: output install gaur 

gaur: gmodify.o dll.o lex.yy.o gaur.tab.o cJSON.o
	$(CC) $(CFLAGS) -o gaur $^  

lex.yy.c: gaur.l gaur.tab.h
	$(LEX) gaur.l

gaur.tab.c gaur.tab.h: gaur.y
	$(BISON) gaur.y 

gmodify.o: ./src/gmodify.c ./include/gmodify.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

cJSON.o: ./src/cJSON.c ./include/cJSON.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

dll.o: ./src/dll.c ./include/dll.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

lex.yy.o: lex.yy.c gaur.tab.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

gaur.tab.o: gaur.tab.c gaur.tab.h
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

# -------------------- TODO: restructurate theses rules  --------------------

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
	rm -rf ~/.gaur/ 

