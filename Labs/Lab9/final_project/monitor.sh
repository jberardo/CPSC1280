#!/bin/bash - 
#===============================================================================
#
#          FILE: monitor.sh
# 
#         USAGE: ./monitor.sh 
# 
#   DESCRIPTION: Monitor system resources real-time
# 
#       OPTIONS:
#		a: Display memory usage information. (Just display the output of the free -k command.)
#		b: Display disk space information. (Just display the output of the df -h command.)
#		c: Display process information. (Just display the output of the ps u command.)
#		o: Display the five options(a, b, c, o, and q)available to the user, along with their
#		    description.(Pressing q will quit the script.)
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Joao Berardo, jsalgadoberard00@mylangara.ca
#  ORGANIZATION: Langara
#       CREATED: 2017-07-07 10:29:39 AM
#      REVISION:  ---
#===============================================================================
# Use $(command) for command substitution
#DATE=`date +%F`
#DATE=$(date +%F)  <-- better

set -o nounset                              # Treat unset variables as an error


#-------------------------------------------------------------------------------
# DEBUG
#-------------------------------------------------------------------------------
# only uncomment for debugging
# exits as soon as any line in the bash script fails
set -e
# prints each command that is going to be executed
set -x

#-------------------------------------------------------------------------------
# Terminal Settings
#-------------------------------------------------------------------------------
#  disable normal echoing in the terminal.
#  this avoids key presses that might "contaminate" the screen
#  during the program execution
stty -echo
# make the cursor invisible
tput civis
tabs 4
clear

#-------------------------------------------------------------------------------
# GLobal vars
#-------------------------------------------------------------------------------
REFRESH=1
# list of options to show/hide menu (1 - enabled / 0 - disabled)
# opts=( menu mem disk ps )
opts[0]=1 # menu
opts[1]=0 # mem
opts[2]=0 # disk
opts[3]=0 # ps

#--- current terminal dimensions ---#
#N_COLS=$(tput cols)
#N_LINES=$(tput lines)

# Move the cursor on the upper left angle of the terminal.
#reset_screen

#-------------------------------------------------------------------------------
# COLOSRS / FORMAT
#-------------------------------------------------------------------------------
# foreground
RED='\E[0;31m'
GREEN='\E[0;32m'
# bold and underline
WHITE='\E[1;4;98m'
# default foreground
STD='\E[0;39m'

#-------------------------------------------------------------------------------
# MAIN FUNCTION
#-------------------------------------------------------------------------------
main ()
{
  reset_screen
  show_all
  #read_option
}

show_all ()
{
  uptime
  echo ""

  if (($opts[1])); then
    show_mem_info
  fi

  if (($opts[2])); then
    show_disk_info
  fi

  if (($opts[3])); then
    show_process_info
  fi

  if ((opts[0])); then
    show_menu
  fi

  read_option
}

#-------------------------------------------------------------------------------
# DISPLAY MENU
#-------------------------------------------------------------------------------
show_menu ()
{
  show_header "Options"
  echo "a) Show/Hide Memory Usage Information"
  echo "b) Show/Hide Disk Space Informaton"
  echo "c) Show/Hide Process Information"
  echo "o) Show/Hide List of Options"
  echo "q) Quit"
}

#-------------------------------------------------------------------------------
# FRIENDLY MESSAGES
#-------------------------------------------------------------------------------
show_info ()
{
  echo -e "${GREEN}$*${STD}"
}

show_error ()
{
  echo -e "${RED}$*${STD}"
}

show_header ()
{
  echo -e "${WHITE}$*${STD}"
}

#-------------------------------------------------------------------------------
# MONITOR FUNCTIONS
#-------------------------------------------------------------------------------
show_mem_info ()
{
  show_header "Memory Usage Information"
  free -kh
}

show_disk_info ()
{
  show_header "Disk Space Information"
  df -h
}

show_process_info ()
{
  show_header "Process Information"
  ps u
}

#-------------------------------------------------------------------------------
# RUN OPTIONS
#-------------------------------------------------------------------------------
read_option ()
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
    a) choice ${opts[0]} ;;
    b) choice ${opts[1]} ;;
    c) choice ${opts[2]} ;;
    o) choice ${opts[3]} ;;
    q) cleanUp 0 ;;
    *) show_all ;;
  esac

#  case $REPLY in
#    a) show_mem_info ;;
#    b) show_disk_info ;;
#    c) show_process_info ;;
#    o) show_all ;;
#    q) cleanUp 0 ;;
#    *) ;;
#  esac

  if [ $? -ne 0 ]; then
    cleanUp 1
  fi
}

choice () {
    local choice=$1
    if [[ ${opts[choice]} ]] # toggle
    then
        opts[choice]=
    else
        opts[choice]=1
    fi
}

cleanUp()
{
  # perform program cleanup on exit (if needed)
  # and exit with appropriate status
  #clear
  # restore echoing
  stty echo
  reset_screen
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

reset_screen()
{
  #tput cup 0 0
  tput reset
}

#-------------------------------------------------------------------------------
# RUN PROGRAM
#-------------------------------------------------------------------------------
# restore terminal settings if we call exit
trap cleanUp 2
# Clean up the everything, restore terminal cursor and colors
# if script is interrupted by <Ctrl-c>
trap cleanUp SIGHUP SIGINT SIGTERM

while :
do
  main
done

exit 0
