#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <parameter.h>
#include <sodium.h>

enum pattern {
	P_DIGIT = (0x01 << 0),
	P_ALBTU = (0x01 << 1),
	P_ALBTL = (0x01 << 2)
};
struct patternx {
	char start;
	char range;
	enum pattern match;
};
struct patternx contilist[3] = {{'0', 10, P_DIGIT}, {'A', 26, P_ALBTU}, {'a', 26, P_ALBTL}};

int main(int argc, char *argv[]) {
	enum pattern pattern;
	unsigned int keylength = 0, range;

	if (sodium_init() < 0) {
		printf("libsodium init fail.\n");
		return EXIT_FAILURE;
	}

	PARAMPARSE(argc, argv) {
		if ((argv[pos][innerpos] >= '0') && (argv[pos][innerpos] <= '9')) {
			pattern |= P_DIGIT;
			range += contilist[0].range;
		}
		if ((argv[pos][innerpos] >= 'A') && (argv[pos][innerpos] <= 'Z')) {
			pattern |= P_ALBTU;
			range += contilist[1].range;
		}
		if ((argv[pos][innerpos] >= 'a') && (argv[pos][innerpos] <= 'z')) {
			pattern |= P_ALBTL;
			range += contilist[2].range;
		}
	}
	else
		keylength = atoi(argv[pos]);
	if (keylength < 1) {
		printf("\
usage:	 passwdgen [option pattern] <generate length>\n\
options: 0-9 A-Z a-z\n\
sample:	 passwdgen -aZ0 8\n");
		return EXIT_SUCCESS;
	}
	if (pattern == 0) {
		pattern = P_DIGIT | P_ALBTU | P_ALBTL;
		range = 62;
	}

	for (int pos = 0; pos < keylength; pos++) {
		unsigned int thisbyte = randombytes_uniform(range);
		for (int innerpos = 0; innerpos < 3; innerpos++)
			if ((pattern & contilist[innerpos].match) != 0 ) {
				if (thisbyte < contilist[innerpos].range) {
					putc(contilist[innerpos].start + thisbyte, stdout);
					break;
				}
				else {
					thisbyte -= contilist[innerpos].range;
				}
			}
	}
	putc('\n', stdout);
	return EXIT_SUCCESS;
}