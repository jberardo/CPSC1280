#!/bin/sh

HOME=$(tput cup 0 0)
ED=$(tput ed)
EL=$(tput el)
ROWS=$(tput lines)
COLS=$(tput cols)

printf '%s%s' "$HOME" "$ED"

while true
do
  CMD="$*"
  ${SHELL:=sh} -c "$CMD" | head -n $ROWS | while IFS= read LINE; do
    printf '%-*.*s%s\n' $COLS $COLS "$LINE" "$EL"
  done
done

printf '%s%s' "$ED" "$HOME"

sleep 1

