#!/bin/bash

usage()
{
  echo "Usage: $0 <dir> <msg>"
  exit 1
}

show_error()
{
  echo "Error: $1"
  exit 1
}

[ "$#" != 2 ] && usage

DIR=$1
MSG=$2
cd "$DIR" || show_error "Invalid Directory"
echo "pushing..."
git add "$PWD" || show_error "Error adding files";
git commit -m "$MSG" || show_error "Error commiting";
git push || show_error "Error pushing to server";
echo "done"
cd - || show_error "Cannot go back to previous directory";

exit 0
