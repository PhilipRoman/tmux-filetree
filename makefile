.POSIX:
.SUFFIXES:

.PHONY: install docs uninstall

# where to install?
PREFIX ?= /usr/local

# possible names of Lua executable
LUA_NAMES += lua lua5.3 lua5.2 lua5.1 luajit
LUA ?= $(shell for x in $(LUA_NAMES); do \
	if command -v $$x >/dev/null 2>&1; then \
		command -v $$x; break; \
	fi; \
done)

ASCIIDOCTOR ?= $(strip $(shell command -v asciidoctor 2>/dev/null))

install: tmux-filetree.lua man/tmux-filetree.1
	@echo "============ Installing in $(PREFIX), set \$$PREFIX to change the location" ============
	(echo "#!$(LUA)"; cat $<) > $(PREFIX)/bin/tmux-filetree
	chmod +x $(PREFIX)/bin/tmux-filetree
	@cp -v man/tmux-filetree.1 "$(PREFIX)/share/man/man1/"

uninstall:
	@rm -v $(PREFIX)/tmux-filetree

ifneq ($(ASCIIDOCTOR),)
man/%.1: man/%.adoc
	asciidoctor -b manpage $<
endif

docs: man/tmux-filetree.1
