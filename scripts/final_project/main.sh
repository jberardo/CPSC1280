skeleton.sh
Part 1: Skeleton
Allow user to show/hide different modules

Menu Option   Module Description
    a         Display mem usage info (free -k)
    b         Display disk space information (df -h)
    c         Display process information (ps u)
    o         Display all options
    q         Quit

Modules:
Disabled -> do not output to the screen
Pressing an option shows/hides a module
The user can enable/disable (show/hide) modules choosing from menu

First executed, only the menu (i.e. option 'o') module should be enabled
Refresh the screen once every second
Put each module’s code into its own function

Screen:
Options: (bold and underlined)
a) Show/Hide Memory Usage Information
b) Show/Hide Disk Space Information
c) Show/Hide Process Information
o) Show/Hide List of options
q) Quit

Memory Usage Information (bold and underline)
free -k

Disk Space Information (bold and underline)
fd -h

Process Information (bold and underline)
ps u

Commands used can be categorized into two groups:
 - produce a single output then exit
 - run continuously

Avoid using commands that run continuously!
Instead, use the commands that produce a single output, and re-execute them every time you refresh the screen

Use the read Command for User Input AND as a Timer
One of the commands inside the loop listens for user input, and the other commands change the display as requested

The read command will get user input and put it into a variable ($REPLY by default)
Some read useful options:
 - -t N (wait for a maximum of N seconds for user input)
 - -n N (read n characters)
 - -s (don't wait for enter to be pressed)

Periodically Updating the Display
Each loop our script will output more and more text to the terminal
Reset the cursor to the top of the screen every time the loop executes
We can do this with tput command. It is useful for changing different aspects of the terminal, such as:
 - current position of the cursor on the terminal screen

Examples of tput:
  - tput lines (Output the number of lines of the terminal)
  - tput cols (Output the number of columns of the terminal)
  - tput cup X Y (Moves the cursor to the x,y position (0,0 is the top left)

Terminal Codes
Terminal code is a special sequence of ASCII characters
It tells the terminal to perform a special operation
Examples:
 - tput el        clear text from the current cursor position to the end of the current line
 - tput ed        clear all the text from the current cursor position to the end of the screen
 - tput clear     clear all the text from the screen
 - tput civis     make the cursor invisible
 - tput cnorm     make the cursor normal again.
 - tput cup X Y   move the cursor to the x,y position
 - tput bold      start printing all text in bold font
 - tput smul      start printing underlined text
 - tput setb 4    start printing with background color ('4' means 'red')
 - tput setf 4    start printing with foreground color ('4' means 'red')
 - tput sgr0      make the font/colors normal again
 - tput sc        Save the cursor position
 - tput rc        Restore the cursor position

Example of usage:
$ clearScreen="`tput clear`"
$ echo $clearScreen

Color Code for tput:
  0 – Black
  1 – Red
  2 – Green
  3 – Yellow
  4 – Blue
  5 – Magenta
  6 – Cyan
  7 – White



# Draw  eleven green lines.
tput cup 5 0
for n in `seq 11`; do
      echo $BLANK80
done

#  Disable normal echoing in the terminal.
#  This avoids key presses that might "contaminate" the screen
#+ during the program execution
stty -echo
# Restore echoing.
stty echo

# Set the column of the finish line.
WINNING_POS=74

# Define the time the race started (after a loop)
START_TIME=`date +%s`
# Define the time the race finished (before a loop)
FINISH_TIME=`date +%s`


# COL variable needed by following "while" construct.
COL=0

while [ $COL -lt $WINNING_POS ]; do
...
done

# Set background color to green and enable blinking text.
echo -ne '\E[30;42m'
echo -en '\E[5m'
# Make the winning horse blink.
tput cup `expr $MOVE_HORSE + 5` \
`cat  horse_${MOVE_HORSE}_position | head -n 1`
$DRAW_HORSE
# Disable blinking text.
echo -en '\E[25m'

set -e
let i++ or ((i++))


