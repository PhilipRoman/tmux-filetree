.POSIX:
.SUFFIXES:

.PHONY: install docs uninstall

# where to install?
PREFIX ?= /usr/local

# possible names of Lua executable
LUA_NAMES += lua lua5.3 lua5.2 lua5.1 luajit
LUA ?= $(shell for x in $(LUA_NAMES); do \
	if which $$x > /dev/null; then \
		which $$x; break; \
	fi; \
done)

ASCIIDOCTOR ?= $(strip $(shell which asciidoctor))

install: tmux-filetree.lua docs
	@echo "============ Installing in $(PREFIX), set \$$PREFIX to change the location" ============
	(echo "#!$(LUA)"; cat $<) > $(PREFIX)/bin/tmux-filetree
	chmod +x $(PREFIX)/bin/tmux-filetree
ifneq ($(ASCIIDOCTOR),)
	@cp -v man/tmux-filetree.1 $(PREFIX)/share/man/man1/
endif

uninstall:
	@rm -v $(PREFIX)/tmux-filetree

man/%.1: man/%.adoc
	asciidoctor -b manpage $<

ifneq ($(ASCIIDOCTOR),)
docs: man/tmux-filetree.1
else
docs:
	@echo ============ "asciidoctor not found, man-pages won't be installed, set \$$ASCIIDOCTOR to override" ============
endif
