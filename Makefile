include makex.mk

PREFIX := $(firstword $(wildcard $(PREFIX) $(HOME)/.local $(HOME)))

TAGREF = $(PREFIX)/bin/tagref

welcome:
	@echo '${CYAN}Tagref${NORMAL} installation'

## install tagref to $(PREFIX)/bin/tagref
install: $(TAGREF)

$(TAGREF): tagref.lua | $(LUAX)
	$(LUAX) -o $@ $<


# TODO : license : WTFPL ?
