#!/bin/bash -

#===============================================================================
#
#          FILE: monitor.sh
#
#         USAGE: ./monitor.sh 
#
#   DESCRIPTION: 
#
#       OPTIONS: 
#               h - Display/Hide Header (Time of Day, %CPU, Total Memory and Free Memory)
#               c - Display/Hide CPU Usage Graph
#               m - Display/Hide Memory Usage Graph
#               p - Display/Hide 5 most CPU-Intensive Processes (PID, User, State, %CPU, %MEM, Name)
#               o - Display/Hide Options Menu
#               q - Quit
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Joao Berardo
#  ORGANIZATION: Langara
#       CREATED: 2017-07-21 11:00:17 PM
#      REVISION:  0.1
#===============================================================================

#-------------------------------------------------------------------------------
# TRAP - CLEANUP
#-------------------------------------------------------------------------------
# traps codes / signals
# 1 - SIGHUP
# 2 - SIGINT
# 3 - SIGQUIT
# 9 - SIGKILL
# 15 - SIGTERM
trap "cleanUp 1" SIGHUP SIGINT SIGQUIT SIGTERM

#-------------------------------------------------------------------------------
# GLOBAL VARS
#-------------------------------------------------------------------------------
REFRESH=1                                        # time (in seconds) to refresh the screen
optsMenu=1                                       # 1 - show menu / 0 - hide menu
optsHeader=1                                     # 1 - show header / 0 - hide header
optsCPU=0                                        # 1 - show CPU Usage / 0 - hide CPU usage
optsMem=0                                        # 1 - show Mem Usage / 0 - hide Mem Usage
optsTop=0                                        # 1 - top 5 processes / 0 - hide top 5 processes

#-------------------------------------------------------------------------------
# COLORS / FORMAT
#-------------------------------------------------------------------------------
BLACK_FG="$(tput setaf 0)"                       # foreground black
RED_FG="$(tput setaf 1)"                         # foreground red
GREEN_FG="$(tput setaf 2)"                       # foreground green
YELLOW_FG="$(tput setaf 3)"                      # foreground yellow
BLUE_FG="$(tput setaf 4)"                        # foreground blue
MAGENTA_FG="$(tput setaf 5)"                     # foreground magenta
CYAN_FG="$(tput setaf 6)"                        # foreground cyan
WHITE_FG="$(tput setaf 7)"                       # foreground white

BLACK_BG="$(tput setaf 0)"                       # background black
RED_BG="$(tput setaf 1)"                         # background red
GREEN_BG="$(tput setaf 2)"                       # background green
YELLOW_BG="$(tput setaf 3)"                      # background yellow
BLUE_BG="$(tput setaf 4)"                        # background blue
MAGENTA_BG="$(tput setaf 5)"                     # background magenta
CYAN_BG="$(tput setaf 6)"                        # background cyan
WHITE_BG="$(tput setaf 7)"                       # background white

CLS="$(tput clear)"                              # clear sreen
CLS_LINE="$(tput el)"                            # clear line
CLS_EOF="$(tput ed)"                             # clear from current cursor to end of screen
CLS_CUR="$(tput civis)"                          # hide cursor
STD_CUR="$(tput cnorm)"                          # normal cursor

BOLD="$(tput bold)"                              # bold text
UL="$(tput smul)"                                # underline text
STD="$(tput sgr0)"                               # normal font/colors

CUR_SAVE="$(tput sc)"                            # save cursor position
CUR_LOAD="$(tput rc)"                            # restore cursor position

move()
{
  posX="$1"
  posY="$2"

  tput cup "$posX $posY"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  reset_screen()
#   DESCRIPTION:  
#-------------------------------------------------------------------------------
reset_screen()
{
  tput cup 0 0
  tput reset
  echo "$CLS_CUR"

}

#-------------------------------------------------------------------------------
# FRIENDLY MESSAGES
#-------------------------------------------------------------------------------
#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_title()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_title()
{
  tput rev
  echo -e "${WHITE_FG}$*${STD}"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  format_header()
#   DESCRIPTION:  format the header to display on top
#    PARAMETERS:  message to format
#-------------------------------------------------------------------------------
format_header()
{
  #tput sc
  #tput bold
  #tput smul
  echo -e "$BOLD"
  echo -e "$GREEN_FG"
  tput cup 0 0
  echo -e "$*"
  echo -e "$STD"
  #tput rc
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_info()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_info()
{
  echo -e "${GREEN_FG}$*${STD}"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_error()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_error()
{
  echo -e "${RED_FG}$*${STD}"
}


#-------------------------------------------------------------------------------
# DEBUG / TERMINAL OPTIONS
#-------------------------------------------------------------------------------
set -o nounset                                   # Treat unset variables as an error
stty -echo                                       # disable normal echoing in the terminal (avoid key press on screen)
echo "$STD"
echo "$CLS"                                      # make the cursor invisible
tabs 4

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  main()
#   DESCRIPTION:
#-------------------------------------------------------------------------------
main()
{
  reset_screen
  show_all                                      # show options
  read_option                                   # read user input
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_all()
#   DESCRIPTION:  
#-------------------------------------------------------------------------------
show_all()
{
  if [[ $optsHeader -eq 1 ]]
  then
    show_header
  fi

  if [[ $optsCPU -eq 1 ]]
  then
    show_cpu
  fi

  if [[ $optsMem -eq 1 ]]
  then
    show_mem
  fi

  if [[ $optsTop -eq 1 ]]
  then
    show_top
  fi

  if [[ $optsMenu -eq 1 ]]
  then
    show_menu
  fi
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_menu()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_menu()
{
  show_title "=> Options"
  echo "h) Show/Hide Header"
  echo "c) Show/Hide CPU Usage Graph"
  echo "m) Show/Hide Memory Usage Graph"
  echo "p) Show/Hide Top Processes"
  echo "o) Show/Hide List of Options"
  echo "q) Quit"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_header()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#--------------------------------------------------------------------------------
show_header()
{
  # date format
  # %d - day (01, 02...)
  # %m - month (01...12)
  # %b - month (Jan, ...)
  # %B - month (January, ...)
  # %Y - year (1990, 1991, ...)
  # %y - year (90, 91, ...)
  # %a - week day (Sun, Mon, ...)
  # %H - hour (24h)
  # %I - hour (12h)
  # %M - minute (00...59)
  # %S - seconds (00...60)
  # %T - time (%H:%M:%S)
  # %n - new line
  # %t - tab
  # header format:
  # Sun, July 23 @ 00:00:00    CPU: XX%   MEM: XX%     Rx: xx K/s Tx: xx K/s
  currDate="$(date '+%a, %b %Y @ %T')"
  cpuUsage=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}')

  memUsage="32"
  netSpeed=$(awk '/enp|em|wlan/ {i++; rx[i]=$2; tx[i]=$10}; END{print rx[2]-rx[1] " " tx[2]-tx[1]}' \
    <(cat /proc/net/dev; cat /proc/net/dev))
  downSpeed="$(echo "$netSpeed" | cut -d' ' -f1)"
  upSpeed="$(echo "$netSpeed" | cut -d' ' -f2)"

  format_header "$currDate    CPU: $cpuUsage%  MEM: $memUsage%  Rx: $downSpeed kbps Tx: $upSpeed Kb/s"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_cpu()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_cpu()
{
  show_title "=> CPU Usage Information"
#  free -kh
#TOTALMEM=`free -mh | head -2 | tail -1| awk '{print $2}'`
#USEDMEM=`free -mh | head -2 | tail -1| awk '{print $3}'`
#FREEMEM=`free -mh | head -2 | tail -1| awk '{print $4}'`

#echo -e "Memory\tTotal\tUsed\tFree\t%Free"
#echo -e "\t$TOTALMEM\t$USEDMEM\tFREEMEM"
    ps -eo pid,%mem,%cpu,fname --sort=-%mem | head -n6
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_mem()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_mem()
{
  show_title "=> Memory Usage Information"
#  free -kh
TOTALMEM=$(free -mh | head -2 | tail -1| awk '{print $2}')
USEDMEM=$(free -mh | head -2 | tail -1| awk '{print $3}')
FREEMEM=$(free -mh | head -2 | tail -1| awk '{print $4}')

echo -e "Memory\tTotal\tUsed\tFree\t%Free"
echo -e "\t$TOTALMEM\t$USEDMEM\t$FREEMEM\t%"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_top()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_top()
{
#  show_title "=> Top memory using processs/application"
#  echo "PID %MEM RSS COMMAND"
#  echo `ps aux | awk '{print $2, $4, $6, $11}' | sort -k3rn | head -n 5`
#
#  show_title "=> Top CPU using process/application"
#  echo `top b -n1 | head -17 | tail -11`
  show_title "=> Most CPU-Intensive Processes"
  #ps k-%cpu -eo pid,user,state,%cpu,%mem,fname | head -n5
  ps -eo pid,%mem,%cpu,fname --sort=-%mem | head -n6
  #ps k-%mem -eo pid,user,state,%cpu,%mem,fname | head -n5
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_process_info()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_process_info()
{
  show_title "Process Information"
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
  read -t "$REFRESH" -n 1 REPLY

  case $REPLY in
    h) toggle_header ;;
    c) toggle_cpu ;;
    m) toggle_mem ;;
    p) toggle_top ;;
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
#          NAME:  toggleHeader()
#   DESCRIPTION:  
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
toggle_header()
{
  [[ $optsHeader -eq 0 ]] && optsHeader=1 || optsHeader=0
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
#          NAME:  toggle_cpu()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
toggle_cpu()
{
    if [[ $optsCPU -eq 0 ]]
    then
        optsCPU=1
    else
        optsCPU=0
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
#          NAME:  toggle_top
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
toggle_top()
{
    if [[ $optsTop -eq 0 ]]
    then
        optsTop=1
    else
        optsTop=0
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
  stty echo                                     # restore echoing
  reset_screen
  echo "$STD"
  echo "$STD_CUR"

  tput cup 0 0
  if [[ $1 -lt 0 ]]
  then
    show_error "Error code: $1"
  else
    show_info "Exited sucessfully"
  fi

  # restore colors
  echo -e "${STD}"
  tput cup 1 0
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

#tput Color Capabilities:
#tput setab [1-7] – Set a background color using ANSI escape
#tput setb [1-7] – Set a background color
#tput setaf [1-7] – Set a foreground color using ANSI escape
#tput setf [1-7] – Set a foreground color

#tput Text Mode Capabilities:
#tput bold – Set bold mode
#tput dim – turn on half-bright mode
#tput smul – begin underline mode
#tput rmul – exit underline mode
#tput rev – Turn on reverse mode
#tput smso – Enter standout mode (bold on rxvt)
#tput rmso – Exit standout mode
#tput sgr0 – Turn off all attributes
#tput sc        Save the cursor position
#tput rc        Restore the cursor position

#Color Code for tput:
#0 – Black
#1 – Red
#2 – Green
#3 – Yellow
#4 – Blue
#5 – Magenta
#6 – Cyan
#7 – White

#
# THINGS TO DO
#

# Real time down/up network speed
#awk '/enp|em|wlan/ {i++; rx[i]=$2; tx[i]=$10}; END{print rx[2]-rx[1] " " tx[2]-tx[1]}' \
# <(cat /proc/net/dev; sleep 1; cat /proc/net/dev)

#Disk: df -lh | awk '{if ($6 == "/") { print "Total\tFree\tPerc\n"$2"\t"$4"\t"$5 }}'
#Memory: free -mh | grep "Mem" |  awk '{ print "Total\tUsed\n"$2"\t"$3}'

