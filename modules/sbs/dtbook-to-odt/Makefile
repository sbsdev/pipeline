#!/usr/bin/make -f

EMACS := /Applications/Emacs.app/Contents/MacOS/Emacs
ORG_MODE_DIR := $(CURDIR)/make/org-mode

LOAD_ORG_MODE := (progn (add-to-list (quote load-path) \"$(ORG_MODE_DIR)/lisp\")\
                        (add-to-list (quote load-path) \"$(ORG_MODE_DIR)/contrib/lisp\")\
                        (load \"$(ORG_MODE_DIR)/lisp/org-loaddefs.el\")\
                        (load \"$(ORG_MODE_DIR)/contrib/lisp/htmlize\"))

doc/dtbook-to-odt.html : doc/%.html : doc/%.org $(ORG_MODE_DIR)/lisp/org-loaddefs.el
	mkdir -p $(dir $@)
	$(EMACS) --batch\
	         --eval "(progn $(LOAD_ORG_MODE)\
	                        (setq org-html-htmlize-output-type (quote css)\
	                              org-html-postamble nil\
	                              org-src-lang-modes (quote ((\"odt\" . nxml) (\"dtbook\" . nxml)))))"\
	         --visit=$<\
	         --funcall=org-html-export-to-html
	mv $(patsubst %.org,%.html,$<) $@

$(ORG_MODE_DIR)/lisp/org-loaddefs.el : | $(ORG_MODE_DIR)
	cd $(ORG_MODE_DIR) && make EMACS="$(EMACS)" oldorg

$(ORG_MODE_DIR) :
	mkdir -p $(dir $@)
	git clone  -b release_8.1 "https://code.orgmode.org/bzg/org-mode.git" --depth 1 $@
