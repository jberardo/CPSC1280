#!/bin/bash

# tab width
tabs 4
clear

#----- Set Colors -----#
RED='\033[0;41;30m'
STD='\033[0;0;39m'

# Main
function main
{
    show_menus
    read_options
}

# Display menus
show_menus()
{
    clear
    echo "~~~~~~~~~~~~~~~~~~~~~"    
    echo " M A I N - M E N U"
    echo "~~~~~~~~~~~~~~~~~~~~~"
    echo "1. Question 2 (ps)"
    echo "2. Question 3 (XML)"
    echo "3. Question 4 (Shakespeare)"
    echo "3. Question 5 (ls -la)"
    echo "5. Exit"
}

# read input from the keyboard and take a action
# Exit when user the user select 5 form the menu option.
read_options()
{
    local choice
    read -p "Enter choice [ 1 - 5 ] " choice

    case $choice in
        1) question01 ;;
        2) question02 ;;
        3) question03 ;;
        4) question04 ;;
        5) exit 0 ;;
        *) echo -e "${RED}Invalid option${STD}" && sleep 2
    esac

    if [ "$?" -ne 0 ]; then
        echo -e "${RED}An error occured. Try again.${STD}" && sleep 2
    fi

}

question01()
{
  ps aux --no-headers | awk -F" " '{CPU+=$3} {MEM+=$4} END {print "Total memory usage: "MEM"% Total CPU usage: "CPU"%"}'
  read -p "Prees any key to continue"
}

question02()
{
  awk -f question3.awk question3input.txt
  read -p "Prees any key to continue"
}

question03()
{
  awk -f question4.awk question4input.txt
  read -p "Prees any key to continue"
}

question04()
{
  ls -la | awk -f question5.awk
  read -p "Prees any key to continue"
}

#RUN
while :
do
  main
done
