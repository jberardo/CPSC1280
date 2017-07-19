#!/bin/bash

_key()
{
  local kp
  ESC=$'\e'
  _KEY=
  read -d '' -sn1 _KEY &
  case $_KEY in
    "$ESC")
        while read -d '' -sn1 -t1 kp
        do
          #_KEY=$_KEY$kp
          #case $kp in
            #[a-zA-NP-Z~]) break;;
          #esac
          free -k
        done
    ;;
  esac
  printf -v "${1:-_KEY}" "%s" "$_KEY"
}

_key x


case $x in
  $'\e[11~' | $'\e[OP') key=F1 ;;
  $'\e[12~' | $'\e[OQ') key=F2 ;;
  $'\e[13~' | $'\e[OR') key=F3 ;;
  $'\e[14~' | $'\e[OS') key=F4 ;;
  $'\e[15~') key=F5 ;;
  $'\e[16~') key=F6 ;;
  $'\e[17~') key=F7 ;;
  $'\e[18~') key=F8 ;;
  $'\e[19~') key=F9 ;;
  $'\e[20~') key=F10 ;;
  $'\e[21~') key=F11 ;;
  $'\e[22~') key=F12 ;;
  $'\e[A' ) key=UP ;;
  $'\e[B' ) key=DOWN ;;
  $'\e[C' ) key=RIGHT ;;
  $'\e[D' ) key=LEFT ;;
  ?) key=$x ;;
  *) key=??? ;;
esac

echo "You have pressed $key"
