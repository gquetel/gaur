
GAUR= ../../gaur
CPPFLAGS=-I ./include
CFLAGS=-g -Wall

GRAMMARFILE=sql_yacc.yy
INJECTFILE=../../src/injects/vector-pt.mysql.cpp

GCLASSIFY=gclassify
SKELETON=gaur_mysql.c

all: run

run: labels.json
	$(GAUR) --list labels.json $(GRAMMARFILE) -i $(INJECTFILE) -s $(SKELETON) -o gaur.modified.y

rules.extracted: 
	$(GAUR) -e $(GRAMMARFILE) -o rules.extracted
rules.extracted.full: 
	$(GAUR) -f $(GRAMMARFILE) -o rules.extracted 
	
labels.json:  rules.extracted 
	$(GCLASSIFY) -o labels.json rules.extracted ./tags/

clean: 
	rm -f parse gaur.modified.y *.c *.h *.o *.log rules.extracted labels.json sql_yacc.patch

# patch: modify-sql
# 	cd ~/repos/mysql-server && git diff > "$(CURDIR)/sql_yacc.patch"