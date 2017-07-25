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
#                  a - Display memory usage information (free -k)
#                  b - Display disk space information (df -h)
#                  c - Display process information (ps u)
#                  o - Display options menu
#		   q - Quit
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Joao Berardo
#  ORGANIZATION: Langara
#       CREATED: 2017-07-07 08:59:02 PM
#      REVISION:  0.1
#===============================================================================

#-------------------------------------------------------------------------------
# DEBUG / TERMINAL OPTIONS
#-------------------------------------------------------------------------------
set -o nounset                                  # treat unset variables as an error
#set -e                                         # exit if any line in the script fails
#set -x                                          # prints each command that is going to be executed. only uncomment for debugging
trap "cleanUp 1" INT TERM EXIT                  # clean up if some error occur
stty -echo                                      # disable normal echoing in the terminal (avoid key press on screen)
tput civis                                      # make the cursor invisible
tabs 4
clear                                           # clear screen

#-------------------------------------------------------------------------------
# GLOBAL VARS
#-------------------------------------------------------------------------------
REFRESH=1                                       # time (in seconds) to refresh the screen
optsMenu=1                                      # 1 - show menu / 0 - hide menu
optsMem=0                                       # 1 - show mem info / 0 - hide mem info
optsDisk=0                                      # 1 - show disk info / 0 - hide disk info
optsPs=0                                        # 1 - show process info / 0 - hide process info

#-------------------------------------------------------------------------------
# COLORS / FORMAT
#-------------------------------------------------------------------------------
readonly RED='\E[0;31m'                                  # foregroung red
readonly GREEN='\E[0;32m'                                # foreground green
readonly WHITE='\E[1;4;98m'                              # white, bold and underline
readonly STD='\E[0;39m'                                  # default foreground

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  main()
#   DESCRIPTION: initial program function 
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
main()
{
  reset_screen
  show_all                                      # show options
  read_option                                   # read user input
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  reset_screen()
#   DESCRIPTION:  
#    PARAMETERS: --- 
#       RETURNS: --- 
#-------------------------------------------------------------------------------
reset_screen()
{
  tput cup 0 0
  tput reset
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_all()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
# FRIENDLY MESSAGES
#-------------------------------------------------------------------------------

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_info()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_info()
{
  echo -e "${GREEN}$*${STD}"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_error()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_error()
{
  echo -e "${RED}$*${STD}"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_header()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#--------------------------------------------------------------------------------
show_header()
{
  echo -e "${WHITE}$*${STD}"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_menu()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_menu()
{
  show_header "Options"
  echo "a) Show/Hide Memory Usage Information"
  echo "b) Show/Hide Disk Space Informaton"
  echo "c) Show/Hide Process Information"
  echo "o) Show/Hide List of Options"
  echo "q) Quit"
}


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_mem_info()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_mem_info()
{
  show_header "Memory Usage Information"
  free -kh
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_disk_info()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_disk_info()
{
  show_header "Disk Space Information"
  df -h
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_process_info()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_process_info()
{
  show_header "Process Information"
  ps -u 
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  read_option ()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
read_option()
{
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

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  toggle_menu()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
toggle_menu()
{
    if [[ $optsMenu -eq 0 ]]
    then
        optsMenu=1
    else
        optsMenu=0
    fi
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  toggle_mem()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
toggle_mem()
{
    if [[ $optsMem -eq 0 ]]
    then
        optsMem=1
    else
        optsMem=0
    fi
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  toggle_disk()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
toggle_disk()
{
    if [[ $optsDisk -eq 0 ]]
    then
        optsDisk=1
    else
        optsDisk=0
    fi
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  toggle_ps
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
toggle_ps()
{
    if [[ $optsPs -eq 0 ]]
    then
        optsPs=1
    else
        optsPs=0
    fi
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  cleanUp()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
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

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  getKey()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
# RUN PROGRAM
#-------------------------------------------------------------------------------
trap cleanUp SIGHUP SIGINT SIGTERM              # clean up and restore terminal cursor and colors if script is interrupted by Ctrl-C or error

while :
do
  main
done

exit 0
#--- current terminal dimensions ---#
#N_COLS=$(tput cols)
#N_LINES=$(tput lines)

