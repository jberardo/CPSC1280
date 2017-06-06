#!/bin/sh

# fancy messages
RED='\033[1;31m'
WHITE='\033[1;37m'
STD='\033[0;0;39m'

# function to display the menu
function show_menu {
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1.    List files in current directory"  
	echo "2.    Display current date"  
	echo "3.    Display 'dmesg' output"  
	echo "4.    Quit"  
}

# main function of the script
function main {
	# read user input and take an action
	function read_options() {
		local choice
		read -p "Enter choice [ 1-4 ] " choice
		case $choice in
			1) clear; echo -e "${WHITE}Listing contents of $PWD${STD}"; echo; ls -la; echo; echo;;
			2) clear; echo -e "${WHITE}Current datetime is:${STD} `date`"; echo; echo ;;
			3) clear; echo "dmesg output" ; dmesg; echo; echo ;;
			4) quit ;;
			*) echo -e "${RED}Wrong choice, please try again.${STD}" ;;
		esac
	}

	while true
	do
		show_menu
		read_options
	done
}

# quit the program
function quit {
	echo -e "${RED}Bye!${STD}"
	exit 0
}

# clear the screen when initializing
clear

# loop until user choose to exit
while :
do
	main
done
