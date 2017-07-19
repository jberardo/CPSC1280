#!/bin/bash

while getopts n: option
do
  case "${option}" in
    n)
      COUNT=${OPTARG}
      ;;
  esac
done

printf "%$(tput cols)s\n" | tr ' ' '=';
printf "Memory%-6sPID%-5sUser%-7sCommand\n";
printf "%$(tput cols)s\n" | tr ' ' '-';

ps -eo size,pid,user,command | sed "1 d" | sort -rn | if [[ -n $COUNT ]]; then head -n $COUNT; else cat; fi | \
awk '
  {
    units[1024**2] = "GB";
    units[1024]    = "MB";
    units[1]	   = "KB";
    for (x = 1024**3; x >= 1; x /= 1024) {
      if ($1 >= x) {
        if (x < 1024) {
          printf ("%-6.0f %-4s ", $1/x, units[x]);
        }
	else {
          printf ("%-6.2f %-4s ", $1/x, units[x]);
        }
	break;
      }
    }
  }
  {
    printf ("%-7s %-10s ", $2, $3);
  }
  {
    for (x = 4; x <= NF; x++) {
      printf ("%s ", $x);
    }
  print ("\r");
  }
';

printf "%$(tput cols)s\n"|tr ' ' '=';
