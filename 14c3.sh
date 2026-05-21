#!/usr/bin/env bash

at_command() {
	exec 99<>"$1"
	echo -e "$1\r" >&99
	read answer <&99
	read answer <&99
	echo "$answer"
	exec 99>&-
}

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 <AT device path>"
	exit 1
fi

if [ "$EUID" -ne 0 ]; then
	echo "Error: This script must be run as root." >&2
	exit 1
fi

VENDOR_ID_HASH="3df8c719"
RAW_CHALLENGE=$(at_command "at+gtfcclockgen")
CHALLENGE=$(echo "$RAW_CHALLENGE" | grep -o '0x[0-9a-fA-F]\+' | awk '{print $1}')
if [ -n "$CHALLENGE" ]; then
	echo "Got challenge: $CHALLENGE"
else
	echo "No challenge from AT device $1, $RAW_CHALLENGE"
	exit 1
fi
HEX_CHALLENGE=$(printf "%08x" "$CHALLENGE")
COMBINED_CHALLENGE="${HEX_CHALLENGE}$(printf "%.8s" "${VENDOR_ID_HASH}")"
RESPONSE_HASH=$(echo "$COMBINED_CHALLENGE" | xxd -r -p | sha256sum | cut -d ' ' -f 1)
TRUNCATED_RESPONSE=$(printf "%.8s" "$RESPONSE_HASH")
RESPONSE=$(printf "%d" "0x$TRUNCATED_RESPONSE")
echo "Sending response to WWAN modem: $RESPONSE"
UNLOCK_RESPONSE=$(at_command "at+gtfcclockver=$RESPONSE")
if [[ "$UNLOCK_RESPONSE" == "+GTFCCLOCKVER:"* ]]; then
	UNLOCK_RESULT=$(echo "$UNLOCK_RESPONSE" | grep -o '[0-9]\+')
	if [[ "$UNLOCK_RESULT" == "1" ]]; then
		echo "FCC unlock succeeded"
		exit 0
	else
		echo "FCC unlock failed. Got result: $UNLOCK_RESULT"
		exit 1
	fi
else
	echo "Unlock failed. Got response: $UNLOCK_RESPONSE"
	exit 1
fi
