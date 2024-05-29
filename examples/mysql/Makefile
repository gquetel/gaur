
GAUR= ../../gaur
CPPFLAGS=-I ./include
CFLAGS=-g -Wall
GRAMMARFILE=mysql.y
INJECTFILE=/usr/local/gaur/src/injects/simple-vector.mysql.cpp
GCLASSIFY=gclassify
SKELETON=gaur_mysql.c

all: run

run: labels.gaur
	$(GAUR) --list labels.gaur $(GRAMMARFILE) -i $(INJECTFILE) -s $(SKELETON) -o gaur.modified.y

rules.extracted: 
	$(GAUR) -e $(GRAMMARFILE) -o rules.extracted

labels.gaur:  rules.extracted 
	$(GCLASSIFY) -o labels.gaur rules.extracted ~/.local/lib/python3.10/site-packages/pygaur/data/mysql/tags/

modify-sql: run
	cp gaur.modified.y /home/gquetel/repos/mysql-server/sql/sql_yacc.yy 

clean: 
	rm -f parse gaur.modified.y *.c *.h *.o *.log rules.extracted labels.gaur
