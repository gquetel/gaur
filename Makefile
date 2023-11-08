LEX = flex
BISON = bison -d -t
CC = gcc 

CPPFLAGS=-I ./include
CFLAGS=-g -Wall
G=parse.y

all: run   

# -------------------- INSTALLATION FILES   --------------------
install: /usr/local/gaur/src/inject.c /usr/share/bison/skeletons/gaur_yacc.c 

output: 
	@mkdir -p $@

# File to inject into grammar prologue
/usr/local/gaur/src/inject.c: src/inject.c | /usr/local/gaur/src 
	sudo cp src/inject.c $@

# Custom bison skeleton
/usr/share/bison/skeletons/gaur_yacc.c: src/skeleton/gaur_yacc.c
	sudo cp src/skeleton/gaur_yacc.c $@

/usr/local/gaur/src:
	    sudo mkdir -p $@


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
	./gaur --list output/nterm_sem.csv $(G) -o output/gaur.modified.y

output/stopwordlist.txt: output/corpus.txt
	mswlist output/corpus.txt -o output/stopwordlist.txt
	
output/nterm_list.txt: gaur | output
	./gaur -e $(G) -o output/nterm_list.txt

output/nterm_sem.csv:  output/nterm_list.txt output/output.dot | output
	gclassify -o output/nterm_sem.csv output/nterm_list.txt

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


