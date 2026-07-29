#!/usr/bin/env sh

if [ "$#" -ne 2 ]; then
	echo "Usage: %s INPUT OUTPUT\n" >&2
	exit 2
fi

input=$1
output=$2

awk '
BEGIN {
	print "elements = {"
}

length($0) > 0 {
	if (have_previous) {
		printf "\t%s,\n", previous
	}
	previous = $0
	have_previous = 1
}

END {
	if (have_previous) {
		printf "\t%s\n", previous
	}
	print "}"
}
' "$input" > "$output"
