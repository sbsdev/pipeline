#!/usr/bin/make -f

EMACS := emacs
ORG_MODE_DIR := $(CURDIR)/make/org-mode

LOAD_ORG_MODE := (progn (add-to-list (quote load-path) \"$(ORG_MODE_DIR)/lisp\")\
                        (add-to-list (quote load-path) \"$(ORG_MODE_DIR)/contrib/lisp\")\
                        (load \"$(ORG_MODE_DIR)/lisp/org-loaddefs.el\")\
                        (load \"$(ORG_MODE_DIR)/contrib/lisp/htmlize\"))

.PHONY : all
all : doc

.PHONY : doc
doc : target/doc/doc/dtbook-to-odt.html
	mvn resources:copy-resources jar:jar install:install-file

target/doc/doc/dtbook-to-odt.html : target/doc/doc/%.html : src/main/doc/%.org $(ORG_MODE_DIR)
	mkdir -p $(dir $@)
	$(EMACS) --batch\
	         --eval "(progn $(LOAD_ORG_MODE)\
	                        (setq org-html-htmlize-output-type (quote css)\
	                              org-html-postamble nil\
	                              org-src-lang-modes (quote ((\"odt\" . nxml) (\"dtbook\" . nxml)))))"\
	         --visit=$<\
	         --funcall=org-html-export-to-html
	mv $(patsubst %.org,%.html,$<) $@

$(ORG_MODE_DIR) :
	mkdir -p $(dir $@)
	git clone -b release_8.1 "git://orgmode.org/org-mode.git" --depth 1 $@
	cd $@ && make EMACS="$(EMACS)" oldorg

.PHONY : clean
clean :
	rm -rf target
