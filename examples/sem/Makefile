
GAUR= ../../gaur
GAUR_FLAGS=-i  /usr/share/gaur/src/injects/vector-pt.c -l labels.json -o gaur.modified.y

FLEX = flex
BISON = bison -d -t
LDFLAGS= -L/opt/local/lib  -lm -lreadline 
CFLAGS=-g -Wall
GCLASSIFY=gclassify

SKELETON=/usr/share/bison/skeletons/gaur_yacc.c
GRAMMARFILE=parse.y
TAGS_FOLDER=../../data/mysql/expert-defined-tags/
INJECTFILE=../../src/injects/simple-vector.c
 
all: build

rules.extracted: 
	$(GAUR) -e $(GRAMMARFILE) -o rules.extracted

labels.json: rules.extracted
	$(GCLASSIFY) -o labels.json rules.extracted $(TAGS_FOLDER)


gaur.modified.y: parse.y labels.json
	$(GAUR) --list labels.json $(GRAMMARFILE) -i $(INJECTFILE) -s $(SKELETON) -o gaur.modified.y


parse.c : gaur.modified.y 
	$(BISON) -o parse.c gaur.modified.y

scan.c: parse.l
	$(FLEX) $(FLEXFLAGS) -o scan.c --header=scan.h parse.l 

parse.o:  parse.c parse.h scan.c
	$(CC) $(CFLAGS) -o parse.o -c parse.c 

scan.o: scan.c 
	$(CC) $(CFLAGS) -o scan.o -c scan.c 

build: parse.o scan.o
	$(CC)  -o parse parse.o scan.o $(LDFLAGS)

clean: 
	rm -f parse gaur.modified.y *.c *.h *.o parse.output *.log rules.extracted nterm_sem.txt  parse.dot
