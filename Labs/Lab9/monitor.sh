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
# 9 - SIGKILL (can't trap)
# 15 - SIGTERM
trap "tput cnorm; cleanUp 1" SIGHUP SIGQUIT SIGTERM
trap "echo no no no" SIGINT

#-------------------------------------------------------------------------------
# GLOBAL VARS
#-------------------------------------------------------------------------------
REFRESH=1                                        # time (in seconds) to refresh the screen
ERR_NO=0                                         # exit error number
optsMenu=1                                       # 1 - show menu / 0 - hide menu
optsHeader=1                                     # 1 - show header / 0 - hide header
optsCPU=0                                        # 1 - show CPU Usage / 0 - hide CPU usage
optsMem=0                                        # 1 - show Mem Usage / 0 - hide Mem Usage
optsTop=0                                        # 1 - top 5 processes / 0 - hide top 5 processes
#--- current terminal dimensions ---#
N_COLS="$(tput cols)"
N_LINES="$(tput lines)"

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
  echo "posX=$1 and posY=$2"
  tput cup "$posX $posY"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  reset_screen()
#   DESCRIPTION:  
#-------------------------------------------------------------------------------
reset_screen()
{
#HOME=$(tput cup 0 0)
ED=$(tput ed)
EL=$(tput el)
ROWS=$(tput lines)
COLS=$(tput cols)
printf '%s%s' "$HOME" "$ED"
#printf '%-*.*s%s\n' "$COLS $COLS $LINE $EL"
printf '%s%s' "$ED" "$HOME"
  tput home
  tput clear
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
  #tput rev
  tput bold
  echo -e "$*${STD}"
  tput sgr0
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  format_header()
#   DESCRIPTION:  format the header to display on top
#    PARAMETERS:  message to format
#-------------------------------------------------------------------------------
format_header()
{
  # header rows = 3
  # header cols = 30
  #printf "%40s\n" "${BLUE_FG}This text is blue${STD}"
  #tput sc
  #tput bold
  #tput smul
  currDate="$(date '+%a, %b %Y @ %T')"
  #cpuUsage=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}')
  data=$(ps aux --no-headers | awk -F" " '{CPU+=$3} {MEM+=$4} END {print MEM" " CPU}')

  cpuUsage=$(echo "$data" | cut -d' ' -f1)
  memUsage=$(echo "$data" | cut -d' ' -f2)
  memUsage=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
  #netSpeed=$(awk '/eno|enp|em|wlan/ {i++; rx[i]=$2; tx[i]=$10}; END{print rx[2]-rx[1] " " tx[2]-tx[1]}' <(cat /proc/net/dev; cat /proc/net/dev))
  NIC="$(ls -1 /sys/class/net/ | head -1)"
  R1=$(cat "/sys/class/net/$NIC/statistics/rx_bytes")
  T1=$(cat "/sys/class/net/$NIC/statistics/tx_bytes")
  sleep 1
  R2=$(cat "/sys/class/net/$NIC/statistics/rx_bytes")
  T2=$(cat "/sys/class/net/$NIC/statistics/tx_bytes")

  #if [[ "$R1" -eq "$R2" ]]
  #then
  #  R2=$(cat "/sys/class/net/$NIC/statistics/rx_packets")
  #fi

  #if [[ "$T1" -eq "$T2" ]]
  #then
  #  T2=$(cat "/sys/class/net/$NIC/statistics/tx_packets")
  #fi

  downSpeed=$((("$T2"-"$T1")/1024))
  upSpeed=$((("$R2"-"$R1")/1024))

  #downSpeed="$(echo "$netSpeed" | cut -d' ' -f1)"
  #upSpeed="$(echo "$netSpeed" | cut -d' ' -f2)"
#  RXPREV=-1
#  TXPREV=-1
#  RX="$(cat /sys/class/net/"${NIC}"/statistics/rx_bytes)"
#  TX="$(cat /sys/class/net/"${NIC}"/statistics/tx_bytes)"
#if [ $RXPREV -ne -1 ] ; then
#    let downSpeed=$RX-$RXPREV/1024/1024
#    let upSpeed=$TX-$TXPREV/1024/1024
#fi
#  RXPREV=$RX
#  TXPREV=$TX
  tput cup 0 1
  printf "%s\n" "$BLUE_FG""Hostname: $STD  $GREEN_FG $(hostname)$STD"
  tput cup 1 1
  printf "%s\n" "$BLUE_FG$(date)$STD"
  tput cup 0 40
  TOTALMEM=$(free -mh | head -2 | tail -1| awk '{print $2}')
  FREEMEM=$(free -mh | head -2 | tail -1| awk '{print $4}')
  printf "%s\n" "$BLUE_FG""CPU:$STD$GREEN_FG $cpuUsage%$BLUE_FG MEM:$STD$GREEN_FG $TOTALMEM/$FREEMEM$STD"
  tput cup 1 40
  echo "$BLUE_FG Tx:$GREEN_FG $upSpeed$BLUE_FG k/s Rx:$GREEN_FG $downSpeed$BLUE_FG k/s $STD"
#  echo -e "$WHITE_FG"
#  echo -e "$BOLD"
#  echo -e "$GREEN_FG"
#  tput cup 0 0
#  echo -e "$*"
#  echo -e "$STD"
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
  #reset_screen
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
#    reset_screen
    show_header
  fi

  if [[ $optsCPU -eq 1 ]]
  then
#    reset_screen
    show_cpu
  fi

  if [[ $optsMem -eq 1 ]]
  then
#    reset_screen
    show_mem
  fi

  if [[ $optsTop -eq 1 ]]
  then
#    reset_screen
    show_top
  fi

  if [[ $optsMenu -eq 1 ]]
  then
#    reset_screen
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
  #cpuUsage=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}')
  data=$(ps aux --no-headers | awk -F" " '{CPU+=$3} {MEM+=$4} END {print MEM" " CPU}')

  cpuUsage=$(echo "$data" | cut -d' ' -f1)
  memUsage=$(echo "$data" | cut -d' ' -f2)
  memUsage=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
  netSpeed=$(awk '/enp|em|wlan/ {i++; rx[i]=$2; tx[i]=$10}; END{print rx[2]-rx[1] " " tx[2]-tx[1]}' \
    <(cat /proc/net/dev; cat /proc/net/dev))
  downSpeed="$(echo "$netSpeed" | cut -d' ' -f1)"
  upSpeed="$(echo "$netSpeed" | cut -d' ' -f2)"

  format_header "$currDate    CPU: $cpuUsage%  MEM: $memUsage  Rx: $downSpeed kbps Tx: $upSpeed Kb/s"
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
  tput cup 3 1
  echo ""
  tput cup 0 0
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_mem()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_mem()
{
  # title
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
  #ps -eo pid,%mem,%cpu,fname --sort=-%mem | head -n6
  #ps k-%mem -eo pid,user,state,%cpu,%mem,fname | head -n5
  tput setaf 5
  tput bold
  tput smul
  echo "Top CPU"
  tput sgr0
  topCpu="$(ps -eo pid,pcpu -o comm= | sort -k2 -n -r | head -5)"
  echo "$topCpu"
  
  tput setaf 5
  tput bold
  tput smul
  echo "Top MEM"
  tput sgr0
  topMem="$(ps -eo pid,pmem -o comm= | sort -k2 -n -r | head -5)"
  echo "$topMem"

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
    h) toggle_header ; reset_screen ;;
    c) toggle_cpu ;reset_screen ;;
    m) toggle_mem ; reset_screen ;;
    p) toggle_top ; reset_screen ;;
    o) toggle_menu ; reset_screen ;;
    q) cleanUp 0 ; reset_screen ;;
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
  if [[ "$ERR_NO" -lt 0 ]]
  then
    show_error "Error code: $ERR_NO"
  else
    show_info "Exited sucessfully"
  fi

  # restore colors
  echo -e "${STD}"
  tput cup 1 0
  tput cnorm
  exit "$ERR_NO"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  getKey()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
getKey()
{
  #stty cbreak -echo
  local key
  echo "$key"
}

#-------------------------------------------------------------------------------
# DEBUG
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# RUN PROGRAM
#-------------------------------------------------------------------------------

tput civis
#BLUE(){ echo -en "\033c\033[0;1m\033[37;44m\033[J";} 

#BLUE
while :
do
  main
done

tput cnorm

exit 0

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

# Check if connected to Internet or not
ping -c 1 google.com &> /dev/null && echo "Connected" || echo "Disconnected"
# Check OS Type
echo -e "OS Type : $(uname -o)"
# Check Architecture
echo -e "Architecture : $(uname -m)"
# Check Kernel Release
echo -e "Kernel Release : $(uname -r)"
# Check hostname
echo -e "Hostname : $HOSTNAME"
# Check Internal IP
echo -e "Internal IP : $(hostname -I)"
# Check External IP
echo -e "External IP : $(curl -s ipecho.net/plain;echo)"
# Check DNS
echo -e "Name Servers : $(sed '1 d' /etc/resolv.conf | awk '{print $2}')"
# Check Logged In Users
echo -e "Logged users : $(who)"
# Check Disk Usages
echo -e "Disk Usages : $(df -h | grep '\/dev\/sda*')"
# Check System Uptime
#tecuptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
echo -e "Uptime Days/(HH:MM): $(uptime | awk '{print $3,$4}' | cut -f1 -d,)"
