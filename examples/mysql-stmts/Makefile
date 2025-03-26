
GAUR= ../../gaur
CPPFLAGS=-I ./include
CFLAGS=-g -Wall

GRAMMARFILE=sql_yacc.yy
INJECTFILE=../../src/injects/vector-pt.mysql-stmt.cpp
TAGS_FOLDER=../../data/mysql/mysqldev-tags/

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

# We expect ~/repos/mysql-server/ to be the git repository at a the following
# commit version: ee079e5ca930ce5ed0643326abadeed8cd41fffc
patch: 
	cp gaur.modified.y ~/repos/mysql-server/sql/sql_yacc.yy
	cd ~/repos/mysql-server && git diff > "$(CURDIR)/sql_yacc.patch" && git restore sql/sql_yacc.yy
