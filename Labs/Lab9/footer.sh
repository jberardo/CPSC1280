#!/bin/bash 
L=$(tput lines)
L1=${L}
(( L1-- ))
C=$(tput cols)
tput cup "${L}" 0
tail -f /var/log/syslog | while read line; do 
  tput sc
  printf "\e[1;${L1}r\e[${L1};${C}f" 
  echo; echo ${line}
  printf "\e[1;${L}r" && tput rc
done


