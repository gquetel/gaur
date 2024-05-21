
GAUR= ../../gaur
CPPFLAGS=-I ./include
CFLAGS=-g -Wall
GRAMMARFILE=mysql.y
INJECTFILE=/usr/local/gaur/src/injects/inject.assets.mysql.cpp
GCLASSIFY=gclassify

all: run

run: labels.gaur
	$(GAUR) --list labels.gaur $(GRAMMARFILE) -i $(INJECTFILE) -s gaur_mysql.c -o gaur.modified.y

nterm_list.txt: 
	$(GAUR) -e $(GRAMMARFILE) -o nterm_list.txt

labels.gaur:  nterm_list.txt 
	$(GCLASSIFY) -o labels.gaur nterm_list.txt ~/.local/lib/python3.10/site-packages/pygaur/data/mysql/tags/

modify-sql: run
	cp gaur.modified.y /home/gquetel/repos/mysql-server/sql/sql_yacc.yy 

clean: 
	rm -f parse gaur.modified.y *.c *.h *.o *.log nterm_list.txt labels.gaur
