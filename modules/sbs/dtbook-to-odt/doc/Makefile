#!/usr/bin/make -f

EMACS := emacs
ORG_MODE_DIR := $(CURDIR)/org-mode

LOAD_ORG_MODE := (progn (add-to-list (quote load-path) \"$(ORG_MODE_DIR)/lisp\")\
                        (add-to-list (quote load-path) \"$(ORG_MODE_DIR)/contrib/lisp\")\
                        (load \"$(ORG_MODE_DIR)/lisp/org-loaddefs.el\")\
                        (load \"$(ORG_MODE_DIR)/contrib/lisp/htmlize\"))

all : $(ORG_MODE_DIR) dtbook-to-odt.html

%.html : %.org
	$(EMACS) --batch\
	         --eval "(progn $(LOAD_ORG_MODE)\
	                        (setq org-html-htmlize-output-type (quote css)\
	                              org-html-postamble nil\
	                              org-src-lang-modes (quote ((\"odt\" . nxml) (\"dtbook\" . nxml)))))"\
	         --visit=$<\
	         --funcall=org-html-export-to-html

$(ORG_MODE_DIR) :
	git clone -b release_8.1 "git://orgmode.org/org-mode.git" --depth 1 $@
	cd $@ && EMACS="$(EMACS)" make oldorg

clean :
	rm -rf dtbook-to-odt.html

.PHONY : clean
