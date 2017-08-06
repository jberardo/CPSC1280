#!/bin/sh
watchit()
{
  HOME=$(tput cup 0 0)
  ED=$(tput ed)
  EL=$(tput el)

  printf '%s%s' "$HOME" "$ED"

  while true
  do
    ROWS=$(tput lines)
    COLS=$(tput cols)
    CMD="$*"

    ${SHELL:=sh} -c "$CMD" | head -n "$ROWS" | while IFS= read LINE; do
      printf '%-*.*s%s\n' "$COLS" "$COLS" "$LINE" "$EL"
    done

    printf '%s%s' "$ED" "$HOME"

    sleep 1

  done
}
