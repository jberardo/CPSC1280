#!/bin/bash

speed()
{
  IF=$1
  DEVICE="enp0s31f6"

  # make the cursor invisible
  tput civis

  while true
  do
    R1=`cat /sys/class/net/$DEVICE/statistics/rx_bytes`
    T1=`cat /sys/class/net/$DEVICE/statistics/tx_bytes`
    R2=`cat /sys/class/net/$DEVICE/statistics/rx_bytes`
    T2=`cat /sys/class/net/$DEVICE/statistics/tx_bytes`
    TBPS=`expr $T2 - $T1`
    RBPS=`expr $R2 - $R1`
    TKBPS=`expr $TBPS / 1024`
    RKBPS=`expr $RBPS / 1024`

    tput cup 1 15
    echo "TX $TKBPS kB/s RX $RKBPS kB/s"
  done

  # make the cursor invisible
  tput cnorm
}

trap "tput cnorm; exit" SIGHUP SIGINT SIGTERM

clear the screen
tput clear

# Move cursor to screen location X,Y (top left is 0,0)
tput cup 3 15

# Set a foreground colour using ANSI escape
tput setaf 3
echo "Display hostname/%cpu/%mem"
tput sgr0

tput cup 5 17
# Set reverse video mode
tput rev
echo "M A I N - M E N U"
tput sgr0

tput cup 7 15
echo "1. User Management"

tput cup 8 15
echo "2. Service Management"

tput cup 9 15
echo "3. Process Management"

tput cup 10 15
echo "4. Backup"

speed

# Set bold mode
tput bold
tput cup 12 15
read -p "Enter your choice [1-4] " choice

tput clear
tput sgr0
tput rc
