awk '/enp|em|wlan/ {i++; rx[i]=$2; tx[i]=$10}; END{print rx[2]-rx[1] " " tx[2]-tx[1]}' \
 <(cat /proc/net/dev; sleep 1; cat /proc/net/dev)

awk '{if(l1){print $2-l1,$10-l2} else{l1=$2; l2=$10;}}' \
  <(grep wlan0 /proc/net/dev) <(sleep 1; grep wlan0 /proc/net/dev)

# tput settings
# Command         Outputs
# tput el         clear all the text from the current cursor position to the end of the current line.
# tput ed         clear all the text from the current cursor position to the end of the screen.
# tput clear      clear all the text from the screen.
# tput civis      make the cursor invisible.
# tput cnorm      make the cursor normal again.
# tput cup X Y    move the cursor to the x,y position (0,0 is the top left).
# tput bold       start printing all text in bold font.
# tput smul       start printing underlined text.
# tput setb 4     start printing all text with a specified background colour (in this example, '4' means 'red').
# tput setf 4     start printing all text with a specified foreground colour (in this example, '4' means 'red').
# tput sgr0       make the font/colors normal again
