#!/bin/bash
# constructed by oTo
# mentioned just to respond to one arrow-key (up or down) and exit
# and to work on different UNIX systems
ESC=$(echo -en "\033")
                                 ####### for LINUX and AIX this is the same
                                 sttyvar="stty -echo  cbreak"
if [ "`uname`" = "HP-UX" ]; then sttyvar="stty  echo -icanon"; fi
if [ "`uname`" = "SunOS" ]; then sttyvar="stty -echo  icanon"; fi

GetKey(){                                                               # type dd, wait for input and...
    first=`dd bs=1 count=1 2>/dev/null`; case "$first" in $ESC)         # intercept first character
   second=`dd bs=1 count=1 2>/dev/null`; case "$second" in '['|'0'|'O') # intercept second one (different for some consoles)
    third=`dd bs=1 count=1 2>/dev/null`; case "$third" in               # intercept the third character in a string
                        A|OA) first=UP;;                                # decision for up
                        B|OB) first=DN;;                                # decision for down arrow-keys
                          *) first="$first$second$third";; esac;;       # all the other combinations send to eternity ;)
                          *) first="$first$second";;
esac ;; esac; echo "$first";}
ARROW(){ stty -echo cbreak;Key=`GetKey`
           case "$Key" in
               UP) echo "UP";;                                          # on key up print UP
               DN) echo "DN";;                                          # on key down print DN
                *) echo "`echo \"$Key\" | dd  2>/dev/null`";;           # ignore the rest
           esac;}
cursor=$(ARROW)
reset                                                                   # screen reset is required or you will notice
     if [[ "$cursor" = "UP" ]]; then echo UP; fi                        # some confused behavior after script ends.
     if [[ "$cursor" = "DN" ]]; then echo DN; fi

