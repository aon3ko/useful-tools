#!/bin/sh

file="$HOME/.ssh/known_hosts"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <line> [line ...]" >&2
  exit 1
fi
if [ ! -f "$file" ]; then
  echo "File not found: $file" >&2
  exit 1
fi

script=
for parameter do
  case "$parameter" in
    ''|*[!0-9]*)
      echo "Line must be a positive integer: $parameter" >&2
      exit 1
      ;;
  esac

  if [ "$parameter" -lt 1 ]; then
    echo "Line must be a positive integer: $parameter" >&2
    exit 1
  fi

  script="${script}${parameter}d;"
done

sed -i "$script" "$file"
