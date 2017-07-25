#!/bin/bash -

#===============================================================================
#
#          FILE: monitor.sh
#
#         USAGE: ./monitor.sh
#
#   DESCRIPTION: Real-time system resource monitor
#
#       OPTIONS:
#                  a
#                  b
#                  c
#                  o
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Joao Berardo
#  ORGANIZATION: Langara
#       CREATED: 2017-07-07 08:59:02 PM
#      REVISION:  0.1
#===============================================================================

#--- DEBUG ---#
set -o nounset                              # Treat unset variables as an error
#set -e                                      # Exits as soon as any line in the bash script fails
# prints each command that is going to be executed. only uncomment for debugging
#set -x
trap "cleanUp 1" INT TERM EXIT
#--- Terminal Settings ---#
#  Disable normal echoing in the terminal.
#  This avoids key presses that might "contaminate" the screen
# during the program execution
stty -echo
# make the cursor invisible
tput civis
tabs 4
clear

#--- global vars ---#
REFRESH=1
# list of options to show/hide menu (1 - enabled / 0 - disabled)
# opts=( menu mem disk ps )
optsMenu=1 # menu
optsMem=0 # mem
optsDisk=0 # disk
optsPs=0 # ps

#--- current terminal dimensions ---#
#N_COLS=$(tput cols)
#N_LINES=$(tput lines)

# Move the cursor on the upper left angle of the terminal.
#reset_screen

#--- COLORS/FORMAT ---#
# foreground
RED='\E[0;31m'
GREEN='\E[0;32m'
# bold and underline
WHITE='\E[1;4;98m'
# default foreground
STD='\E[0;39m'

#--- MAIN FUNCTION ---#
main()
{
  reset_screen
  show_all
  read_option
}

reset_screen()
{
  #tput cup 0 0
  tput reset
}

show_all()
{
  uptime
  
  if [[ optsMenu -eq 1 ]]
  then
    show_menu
  fi

  if [[ optsMem -eq 1 ]]
  then
    show_mem_info
  fi

  if [[ optsDisk -eq 1 ]]
  then
    show_disk_info
  fi

  if [[ optsPs -eq 1 ]]
  then
    show_process_info
  fi

  #read_option
}

#--- FRIENDLY MESSAGES ---#
show_info()
{
  echo -e "${GREEN}$*${STD}"
}

show_error()
{
  echo -e "${RED}$*${STD}"
}

show_header()
{
  echo -e "${WHITE}$*${STD}"
}

#--- MONITOR FUNCTIONS ---#

show_menu()
{
  show_header "Options"
  echo "a) Show/Hide Memory Usage Information"
  echo "b) Show/Hide Disk Space Informaton"
  echo "c) Show/Hide Process Information"
  echo "o) Show/Hide List of Options"
  echo "q) Quit"
}

show_mem_info()
{
  show_header "Memory Usage Information"
  free -kh
}

show_disk_info()
{
  show_header "Disk Space Information"
  df -h
}

show_process_info()
{
  show_header "Process Information"
  ps -e -n10
}

#--- RUN OPTIONS ---#
read_option()
{
  #local choice
  #read -p "Enter choice: " choice
  #read -d'' -s -n1
  #read -d'' choice
  #echo $choice && sleep 2


  #echo -n "Enter choice"

  #read -s -n 1 choice
  #choice=$(dd count=1 2>/dev/null) #|| return $?
  #getChar choice

  # read options:
  # -t N (wait for a maximum of N seconds for user input)
  # -n N (read n characters)
  # -s (don't wait for enter to be pressed)
  local REPLY
  read -t $REFRESH -n 1 REPLY

  case $REPLY in
    a) toggle_ps ;;
    b) toggle_mem ;;
    c) toggle_disk ;;
    o) toggle_menu ;;
    q) cleanUp 0 ;;
    *) show_all ;;
  esac

  if [ $? -ne 0 ]
  then
    cleanUp 1
  fi
}

toggle_menu()
{
    if [[ $optsMenu -eq 0 ]]
    then
        optsMenu=1
    else
        optsMenu=0
    fi
}

toggle_mem()
{
    if [[ $optsMem -eq 0 ]]
    then
        optsMem=1
    else
        optsMem=0
    fi
}

toggle_disk()
{
    if [[ $optsDisk -eq 0 ]]
    then
        optsDisk=1
    else
        optsDisk=0
    fi
}

toggle_ps()
{
    if [[ $optsPs -eq 0 ]]
    then
        optsPs=1
    else
        optsPs=0
    fi
}


cleanUp()
{
  # perform program cleanup on exit (if needed)
  # and exit with appropriate status
  #clear
  # restore echoing
  stty echo
  #reset_screen
  # restore cursor
  tput cnorm

  if [[ $1 -lt 0 ]]
  then
    show_error "Error code: $1"
  else
    show_info "Exited sucessfully"
  fi

  # restore colors
  echo -e "${STD}"

  exit "$1"
}

getKey()
{
  #stty="$(stty -g)"

  #trap "stty $stty; trap SIGINT; return 128" SIGINT

  #stty cbreak -echo

  local key
  #while true; do
    #key=$(dd count=1 2>/dev/null) || return $?


    #if [ -z "$1" ] || [[ "$key" == [$1] ]]; then
      #break
    #  echo "test"
    #fi
  #done

  #stty $stty

  echo "$key"
  #cleanUp 0
}

#--- RUN PROGRAM ---#

# restore terminal settings if we call exit
#trap cleanUp 2
# Clean up the everythin, restore terminal cursor and colors
# if script is interrupted by Ctrl+C
trap cleanUp SIGHUP SIGINT SIGTERM

while :
do
  main
done

exit 0
