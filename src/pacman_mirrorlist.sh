#!/usr/bin/env bash

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 <CountryCode>"
	exit 1
fi

if [ "$EUID" -ne 0 ]; then
	echo "Error: This script must be run as root." >&2
	exit 1
fi


url="https://archlinux.org/mirrorlist/?protocol=http&ip_version=4&ip_version=6&country=${1}"

tmpfile=$(mktemp /tmp/downloaded.XXXXXX)
if ! curl -s -S "$url" -o "$tmpfile"; then
	echo "Error: Failed to download file from $url"
	exit 1
fi

output="/etc/pacman.d/mirrorlist"
sed 's/#//' "$tmpfile" > "$output"

echo "Processed file saved to $output"
