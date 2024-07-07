
GAUR= ../../gaur
CPPFLAGS=-I ./include
CFLAGS=-g -Wall
GRAMMARFILE=mysql.y
INJECTFILE=/usr/share/gaur/src/injects/vector-pt.mysql.cpp
GCLASSIFY=gclassify
SKELETON=gaur_mysql.c

all: run

run: labels.json
	$(GAUR) --list labels.json $(GRAMMARFILE) -i $(INJECTFILE) -s $(SKELETON) -o gaur.modified.y

rules.extracted: 
	$(GAUR) -e $(GRAMMARFILE) -o rules.extracted

labels.json:  rules.extracted 
	$(GCLASSIFY) -o labels.json rules.extracted ~/.local/lib/python3.10/site-packages/pygaur/data/mysql/tags/

modify-sql: run
	cp gaur.modified.y /home/gquetel/repos/mysql-server/sql/sql_yacc.yy 

clean: 
	rm -f parse gaur.modified.y *.c *.h *.o *.log rules.extracted labels.json
