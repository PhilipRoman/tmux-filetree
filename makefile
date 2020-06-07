.SUFFIXES:
.POSIX:

.PHONY: install

# where to install?
PREFIX ?= /usr/local/bin

# possible names of Lua executable
LUA_NAMES := lua lua5.3 lua5.2 lua5.1 luajit
LUA ?= $(shell for x in $(LUA_NAMES); do \
	if which $$x > /dev/null; then \
		which $$x; break; \
	fi; \
done)

install: tmux-filetree.lua
	@echo ============ Installing in $(PREFIX), set \$$PREFIX to change the location ============
	(echo "#!$(LUA)"; cat $<) > $(PREFIX)/tmux-filetree
	chmod +x $(PREFIX)/tmux-filetree

uninstall:
	@rm -v $(PREFIX)/tmux-filetree
