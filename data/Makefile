GRAMMARS_DIR := ./grammars
GAUR_PATH := ../gaur

all: extract

extract: $(GRAMMARS_DIR)/*.y
	for file in $^ ;   do echo $${file} ; $(GAUR_PATH) --extract  -o $${file}.sem $${file}  ; done

clean: 
	@rm -f gaur.modified.y
	@rm -f ./grammars/*.sem
.PHONY: all
