GAUR= ../../gaur
GAUR_FLAGS=-i ../../src/inject.c -l nterm_sem.txt -o gaur.modified.y
BISON = bison -d -t
LDFLAGS= -L/opt/local/lib -lreadline -lm 
FLEX = flex
CFLAGS=-g -Wall
NLPPATH:=/home/gquetel/Desktop/usine/NLP/



all: build

nterm_list.txt: parse.y 
	$(GAUR) --extract parse.y 

nterm_sem.txt: nterm_list.txt
	python3 $(NLPPATH)ntcategrz.py -o nterm_sem.txt nterm_list.txt -s $(NLPPATH)outputs/stopwordlist.txt

gaur.modified.y: parse.y nterm_sem.txt
	$(GAUR) $(GAUR_FLAGS) parse.y 

parse.c : gaur.modified.y 
	$(BISON) -o parse.c gaur.modified.y

parse.o:  parse.c parse.h
	$(CC) $(CPPFLAGS) -o parse.o -c parse.c 

build: parse.o
	$(CC)  -o calc parse.o $(LDFLAGS)

clean: 
	rm -f calc gaur.modified.y parse.c parse.h parse.o parse.output *.log nterm_list.txt


