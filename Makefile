CC = gcc
CFLAGS =
CPPFLAGS = -I dawn-libs/include
LDLIBS = -lsodium
DAWN_OBJECT = dawn-libs/bin/d_string.o

all: passwdgen2

.PHONY: passwdgen dawn-libs clean

passwdgen: passwdgen2

passwdgen2: $(DAWN_OBJECT)
	$(CC) $(CFLAGS) $(CPPFLAGS) src/passwdgen2.c $(DAWN_OBJECT) -o passwdgen $(LDLIBS)

$(DAWN_OBJECT): dawn-libs

dawn-libs:
	$(MAKE) -C dawn-libs d_string

clean:
	-rm passwdgen
	-rm -rf build
	$(MAKE) -C dawn-libs clean
