CC = gcc
CFLAGS =
CPPFLAGS = -I dawn-libs/include
LDLIBS = -lsodium
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
DAWN_OBJECT = dawn-libs/bin/d_string.o
SH_FILES = pacman_mirrorlist.sh 14c3.sh kh.sh nft-formatter.sh

all: passwdgen2

.PHONY: passwdgen dawn-libs install uninstall clean

passwdgen: passwdgen2

passwdgen2: $(DAWN_OBJECT)
	$(CC) $(CFLAGS) $(CPPFLAGS) src/passwdgen2.c $(DAWN_OBJECT) -o passwdgen $(LDLIBS)

$(DAWN_OBJECT): dawn-libs

dawn-libs:
	$(MAKE) -C dawn-libs d_string

install: passwdgen2
	install -d "$(DESTDIR)$(BINDIR)"
	install -m 755 passwdgen "$(DESTDIR)$(BINDIR)/passwdgen"
	install -m 755 $(SH_FILES) "$(DESTDIR)$(BINDIR)/"

uninstall:
	-rm -f "$(DESTDIR)$(BINDIR)/passwdgen"
	-rm -f $(addprefix "$(DESTDIR)$(BINDIR)"/,$(SH_FILES))

clean:
	-rm passwdgen
	$(MAKE) -C dawn-libs clean
