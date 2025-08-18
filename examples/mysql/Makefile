
GAUR= ../../gaur
CPPFLAGS=-I ./include
CFLAGS=-g -Wall

GRAMMARFILE=sql_yacc.yy
INJECTFILE=../../src/injects/vector-pt.mysql-expert.cpp
TAGS_FOLDER=../../data/mysql/expert-defined-tags/

GCLASSIFY=gclassify.py
SKELETON=gaur_mysql.c

all: run

run: labels.json
	$(GAUR) --list labels.json $(GRAMMARFILE) -i $(INJECTFILE) -s $(SKELETON) -o gaur.modified.y

rules.extracted: 
	$(GAUR) -e $(GRAMMARFILE) -o rules.extracted
rules.extracted.full: 
	$(GAUR) -f $(GRAMMARFILE) -o rules.extracted 
	
labels.json:  rules.extracted 
	$(GCLASSIFY) -o labels.json rules.extracted $(TAGS_FOLDER)

clean: 
	rm -f parse gaur.modified.y *.c *.h *.o *.log rules.extracted labels.json sql_yacc.patch


# Rule to create patch file for the server. The source code of a mysql-server
# of the correct version under ~/repos/mysql-server.
patch: run
	cp ./gaur.modified.y ~/repos/mysql-server/sql/sql_yacc.yy
	cd ~/repos/mysql-server && git diff > "$(CURDIR)/sql_yacc.patch"