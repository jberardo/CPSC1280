#!/bin/bash

#===============================================================================
#
#          FILE: monitor.sh
#
#         USAGE: ./monitor.sh
#
#   DESCRIPTION: System resource monitor script
#
#       OPTIONS: 
#               h - Display/Hide Header (Time of Day, %CPU, Total Memory and Free Memory)
#               c - Display/Hide CPU Usage Graph
#               m - Display/Hide Memory Usage Graph
#               p - Display/Hide 5 most CPU-Intensive Processes (PID, User, State, %CPU, %MEM, Name)
#               o - Display/Hide Options Menu
#               q - Quit
#        AUTHOR: Joao Berardo
#  ORGANIZATION: Langara
#       CREATED: 2017-07-21 11:00:17 PM
#      REVISION:  1.0
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
trap "cleanUp 1" SIGHUP SIGINT SIGQUIT SIGTERM
trap "echo trap; exit 1"
#-------------------------------------------------------------------------------
# GLOBAL VARS
#-------------------------------------------------------------------------------
REFRESH=1                                        # time (in seconds) to refresh the screen
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
RED_FG="$(tput setaf 1)"                         # foreground red
GREEN_FG="$(tput setaf 2)"                       # foreground green
BLUE_FG="$(tput setaf 4)"                        # foreground blue
WHITE_FG="$(tput setaf 7)"                       # foreground white
CLS="$(tput clear)"                              # clear sreen
CLS_LINE="$(tput el)"                            # clear line
CLS_EOF="$(tput ed)"                             # clear from current cursor to end of screen
BOLD="$(tput bold)"                              # bold text
UL="$(tput smul)"                                # underline text
STD="$(tput sgr0)"                               # normal font/colors
CUR_SAVE="$(tput sc)"                            # save cursor position
CUR_LOAD="$(tput rc)"                            # restore cursor position

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  reset_screen()
#   DESCRIPTION:  
#-------------------------------------------------------------------------------
reset_screen()
{
  #tput reset
  tput clear
  tput cup 0 0
  tput civis
}

#-------------------------------------------------------------------------------
# FRIENDLY MESSAGES
#-------------------------------------------------------------------------------
#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_title()
#   DESCRIPTION:  
#    PARAMETERS:  ---
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
  #sleep 1
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
#-------------------------------------------------------------------------------
show_info()
{
  echo -e "${GREEN_FG}$*${STD}"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_error()
#   DESCRIPTION:  
#    PARAMETERS:  ---
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
    show_mem_usage
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
  echo ""
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
  #currDate="$(date '+%a, %b %Y @ %T')"
  ##cpuUsage=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}')
  #data=$(ps aux --no-headers | awk -F" " '{CPU+=$3} {MEM+=$4} END {print MEM" " CPU}')

  #cpuUsage=$(echo "$data" | cut -d' ' -f1)
  #memUsage=$(echo "$data" | cut -d' ' -f2)
  #memUsage=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
  #netSpeed=$(awk '/enp|em|wlan/ {i++; rx[i]=$2; tx[i]=$10}; END{print rx[2]-rx[1] " " tx[2]-tx[1]}' \
  #  <(cat /proc/net/dev; cat /proc/net/dev))
  #downSpeed="$(echo "$netSpeed" | cut -d' ' -f1)"
  #upSpeed="$(echo "$netSpeed" | cut -d' ' -f2)"

  #format_header "$currDate    CPU: $cpuUsage%  MEM: $memUsage  Rx: $downSpeed kbps Tx: $upSpeed Kb/s"
  currTime=$(date "+%H:%M")
  cpuUsage=$(ps aux --no-headers | awk -F" " '{CPU+=$3} END {print CPU}')
  totalMem=$(free -k | awk 'NR==2{print $2}')
  freeMem=$(free -k | awk 'NR==2{print $3}')
  
  echo "$currTime CPU: $cpuUsage% MEM: $totalMem K total, $freeMem K free"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_cpu()
#   DESCRIPTION:  display CPU usage graph
#-------------------------------------------------------------------------------
currentRow=2
currentCol=0
show_cpu()
{
  show_title "=> CPU Usage"

  cpuUsage=$(ps aux --no-headers | awk -F" " '{CPU+=$3} END {print CPU}' | cut -d. -f1)
  totalCols=$(tput cols)

  usageString="${RED_FG}*${STD}"
  freeString="."

  if (( "$currentCol" > totalCols ))
  then
    currentCol=0
  fi

  if ((cpuUsage > 80))
  then
    cpuString[0]+="$usageString"
  else
    cpuString[0]+="$freeString"
  fi

  if ((cpuUsage > 60))
  then
    cpuString[1]+="$usageString"
  else
    cpuString[1]+="$freeString"
  fi

  if ((cpuUsage > 40))
  then
    cpuString[2]+="$usageString"
  else
    cpuString[2]+="$freeString"

  fi
  if ((cpuUsage > 20))
  then
    cpuString[3]+="$usageString"
  else
    cpuString[3]+="$freeString"
  fi

  if ((cpuUsage > 0))
  then
    cpuString[4]+="$usageString"
  else
    cpuString[4]+="$freeString"
  fi

  #tput cup $((currentRow)) 0
  echo "${cpuString[0]}"
  #tput cup $((currentRow+1)) 0
  echo "${cpuString[1]}"
  #tput cup $((currentRow+2)) 0
  echo "${cpuString[2]}"
  #tput cup $((currentRow+3)) 0
  echo "${cpuString[3]}"
  #tput cup $((currentRow+4)) 0
  echo "${cpuString[4]}"

  ((currentCol++))
}

for i in $(seq 0 4)
do
  memString[i]=""
done
currentMemCol=0
show_mem_usage()
{
  show_title "\n=> Memory Usage"

  totalCols=$(tput cols)
  memUsage=$(free | awk 'NR==2{print $3/$2*100}' | cut -d'.' -f1)
  usageString="${RED_FG}*${STD}"
  freeString="."

  # if number of characters in memUsage is greater then terminal cols, reset current column
  if [[ $(wc -w | "$memUsage") -lt "$totalCols" ]]
  then
    currentMemCol=0
    cut -c -"$totalCols"
    for i in $(seq 0 4)
    do
      ${memString}[i]="$(cut -c -4)"
    done
  fi

  if (("$optsCPU" == 1))
  then
    currentMemRow=9
  else
    currentMemRow=3
  fi

  if ((memUsage > 80))
  then
    memString[0]="$usageString${memString[0]}"
  else
    memString[0]="$freeString${memString[0]}"
  fi

  if ((memUsage > 60))
  then
    memString[1]="$usageString${memString[1]}"
  else
    memString[1]="$freeString${memString[1]}"
  fi

  if ((memUsage > 40))
  then
    memString[2]="$usageString${memString[2]}"
  else
    memString[2]="$freeString${memString[2]}"
  fi

  if ((memUsage > 20))
  then
    memString[3]="$usageString${memString[3]}"
  else
    memString[3]="$freeString${memString[3]}"
  fi

  if ((memUsage > 0))
  then
    memString[4]="$usageString${memString[4]}"
  else
    memString[4]="$freeString${memString[4]}"
  fi

  #tput cup $currentMemRow 0
  echo "${memString[0]}"
  #tput cup $((currentMemRow+1)) 0
  echo "${memString[1]}"
  #tput cup $((currentMemRow+2)) 0
  echo "${memString[2]}"
  #tput cup $((currentMemRow+3)) 0
  echo "${memString[3]}"
  #tput cup $((currentMemRow+4)) 0
  echo "${memString[4]}"

  ((currentMemCol++))
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  show_mem()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------
show_mem()
{
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
  echo ""
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

  
  #tput setaf 5
  #tput bold
  #tput smul
  #echo "Top CPU"
  #tput sgr0
  topCpu="$(ps -eo pid,user,state,pcpu,pmem,comm | sort -k4 -n -r | head -n6)"
  echo "$topCpu"
  
  #tput setaf 5
  #tput bold
  #tput smul
  #echo "Top MEM"
  #tput sgr0
  #topMem="$(ps -eo pid,pmem -o comm= | sort -k2 -n -r | head -5)"
  #echo "$topMem"

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
  tput sgr0
  tput cup 0 0
  tput cnorm

  if [[ "$1" -lt 0 ]]
  then
    show_error "Error code: $1"
  else
    show_info "Exited sucessfully"
  fi

  exit "$1"
}

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  getKey()
#   DESCRIPTION:  
#    PARAMETERS:  ---
#       RETURNS:  ---
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# RUN PROGRAM
#-------------------------------------------------------------------------------

while :
do
  main
done
#tput smul – begin underline mode
#tput rmul – exit underline mode
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
# THINGS TO DO
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
