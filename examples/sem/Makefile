
GAUR= ../../gaur
GAUR_FLAGS=-i ../../src/inject.c -l nterm_sem.txt -o gaur.modified.y
BISON = bison -d -t
LDFLAGS= -L/opt/local/lib -lreadline -lm 
FLEX = flex
CFLAGS=-g -Wall

 
all: build

nterm_list.csv: parse.y 
	$(GAUR) --extract parse.y 

nterm_sem.txt: nterm_list.csv parse.dot
	gclassify -o nterm_sem.txt nterm_list.csv

gaur.modified.y: parse.y nterm_sem.txt
	$(GAUR) $(GAUR_FLAGS) parse.y 
parse.dot: 
	../../gaur -d parse.y
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
	rm -f parse gaur.modified.y *.c *.h *.o parse.output *.log nterm_list.txt
