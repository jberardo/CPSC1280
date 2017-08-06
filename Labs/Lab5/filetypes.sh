#!/bin/sh

if [[ $# -eq 0 || $# -ge 2 ]]
then
  echo "Usage: $0 /path/to/files"
  exit 1
fi

DIR="$1"

TXT_FILE=$(file -i $DIR/* | grep -i "ascii" | wc -l)
OTHERS=$(file -i $DIR/* | grep -iv "ascii" | wc -l)

echo "Found $TXT_FILE text files."
echo "Found $OTHERS files of other types."

exit 0
