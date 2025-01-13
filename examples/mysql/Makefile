
GAUR= ../../gaur
CPPFLAGS=-I ./include
CFLAGS=-g -Wall
GRAMMARFILE=sql_yacc.yy
INJECTFILE=/usr/share/gaur/src/injects/vector-pt.mysql.cpp
GCLASSIFY=~/repos/pygaur/gclassify.py
SKELETON=gaur_mysql.c

all: run

run: labels.json
	$(GAUR) --list labels.json $(GRAMMARFILE) -i $(INJECTFILE) -s $(SKELETON) -o gaur.modified.y

rules.extracted: 
	$(GAUR) -e $(GRAMMARFILE) -o rules.extracted
rules.extracted.full: 
	$(GAUR) -f $(GRAMMARFILE) -o rules.extracted 
	
labels.json:  rules.extracted 
	$(GCLASSIFY) -o labels.json rules.extracted /home/gquetel/repos/pygaur/pygaur/data/mysql/tags/

modify-sql: run
	cp gaur.modified.y /home/gquetel/repos/mysql-server/sql/sql_yacc.yy 

clean: 
	rm -f parse gaur.modified.y *.c *.h *.o *.log rules.extracted labels.json sql_yacc.patch

patch: modify-sql
	cd ~/repos/mysql-server && git diff > "$(CURDIR)/sql_yacc.patch"