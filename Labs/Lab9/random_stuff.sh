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


# SHORTER VERSION
stty_state=`stty -g`
  stty raw
  stty -echo
  keycode=`dd bs=1 count=1 2>/dev/null`
  keycode=`dd bs=1 count=1 2>/dev/null`
  keycode=`dd bs=1 count=1 2>/dev/null`
  if [ "$keycode" = "A" ];then echo up;fi
  if [ "$keycode" = "B" ];then echo dn;fi

# OTHER
#!/bin/bash
ESC=$(echo -en "\033")                     # define ESC
while :;do                                 # infinite loop
read -s -n3 key 2>/dev/null >&2            # read quietly three characters of served input
  if [ "$key" = "$ESC[A" ];then echo up;fi # if A is the result, print up
  if [ "$key" = "$ESC[B" ];then echo dn;fi #    B                      dn
  if [ "$key" = "$ESC[C" ];then echo ri;fi #    C                      ri
  if [ "$key" = "$ESC[D" ];then echo le;fi #    D                      le
done


# AND YET ANOTYHER ONE
#/bin/bash
       E='echo -e';e='echo -en';trap "R;exit" 2
     ESC=$( $e "\033")
    TPUT(){ $e "\033[${1};${2}H";}
   CLEAR(){ $e "\033c";}
   CIVIS(){ $e "\033[?25l";}
    DRAW(){ $e "\033%@\033(0";}
   WRITE(){ $e "\033(B";}
    MARK(){ $e "\033[7m";}
  UNMARK(){ $e "\033[27m";}
    BLUE(){ $e "\033c\033[H\033[J\033[37;44m\033[J";};BLUE
       C(){ CLEAR;BLUE;}
    HEAD(){ MARK;TPUT 1 4
            $E "BASH SELECTION MENU                       ";UNMARK
            DRAW
            for each in $(seq 1 9);do
             $E "   x                                        x"
            done;WRITE;}
            i=0; CLEAR; CIVIS;NULL=/dev/null
    FOOT(){ MARK;TPUT 11 4
            printf "ENTER=SELECT, UP/DN=NEXT OPTION           ";UNMARK;}
   ARROW(){ read -s -n3 key 2>/dev/null >&2
            if [[ $key = $ESC[A ]];then echo up;fi
            if [[ $key = $ESC[B ]];then echo dn;fi;}
POSITION(){ if [[ $cur = up ]];then ((i--));fi
            if [[ $cur = dn ]];then ((i++));fi
            if [[ i -lt 0   ]];then i=$LM;fi
            if [[ i -gt $LM ]];then i=0;fi;}
 REFRESH(){ after=$((i+1)); before=$((i-1))
            if [[ $before -lt 0  ]];then before=$LM;fi
            if [[ $after -gt $LM ]];then after=0;fi
            if [[ $j -lt $i      ]];then UNMARK;M$before;else UNMARK;M$after;fi
            if [[ $after -eq 0   ]] || [[ $before -eq $LM ]];then
            UNMARK; M$before; M$after;fi;j=$i;UNMARK;M$before;M$after;}
      M0(){ TPUT 3 20; $e "Option0";}
      M1(){ TPUT 4 20; $e "Option1";}
      M2(){ TPUT 5 20; $e "Option2";}
      M3(){ TPUT 6 20; $e "Option3";}
      M4(){ TPUT 7 20; $e "Option4";}
      M5(){ TPUT 8 20; $e "ABOUT  ";}
      M6(){ TPUT 9 20; $e "EXIT   ";}
     LM=6    #Last Menu number
    MENU(){ for each in $(seq 0 $LM);do M${each};done;}
    INIT(){ BLUE;HEAD;FOOT;MENU;}
      SC(){ REFRESH;MARK;$S;cur=`ARROW`;}
      ES(){ MARK;$e "\nENTER = main menu ";$b;read;INIT;};INIT
while [[ "$O" != " " ]]; do case $i in
      0) S=M0;SC;if [[ $cur = "" ]];then C;$e "o0:\n$(w        )\n";ES;fi;;
      1) S=M1;SC;if [[ $cur = "" ]];then C;$e "o1:\n$(ifconfig )\n";ES;fi;;
      2) S=M2;SC;if [[ $cur = "" ]];then C;$e "o2:\n$(df -h    )\n";ES;fi;;
      3) S=M3;SC;if [[ $cur = "" ]];then C;$e "o3:\n$(route -n )\n";ES;fi;;
      4) S=M4;SC;if [[ $cur = "" ]];then C;$e "o4:\n$(date     )\n";ES;fi;;
      5) S=M5;SC;if [[ $cur = "" ]];then C;$e "o5:\n$($e by oTo)\n";ES;fi;;
      6) S=M6;SC;if [[ $cur = "" ]];then C;exit 0;fi;;
esac;POSITION;done


 Function HEAD
To have at least some minimal frame around your menu, custom function HEAD will draw a header and side lines.
It will not give you an exact frame, because it will took me a few more lines of "empty coding".
You will get left and right border. As you already noticed some commands are separated with too much spaces.
Those spaces are responsible for your program layout.
So adjust them the way you like.
Function FOOT
To have frame closed, we need to add also something at the bottom.
There should be short usage description as you can see it from a picture below.
In both cases MARK and UNMARK custom functions are used to reverse background and foreground colors.
So you do not need too much 'drawing'.
Function POSITION
This function locates and manages menu selection positions.
Without this one you will get an error when cursor keys will be pressed too many times.
Instead of that, this function gives you a nice rotating effect.
When you come to the end of menus you can press down arrow-key one more time and you will be returned to the start.
The same applies if you go from another direction.
Function REFRESH
To prevent too much refreshing, I constructed a simple hack that will refresh only menus at the neighbors positions.
Without that full screen might need to be refreshed for each your action. What it actually does is the following:
for every pressed up or down arrow-key, it 'repaints' menu options this way: sets normal layout for options in front
and after selected option, paints selected option with the inverted color scheme.
'while' loop
At the end of script, you will find numbered lines, where can you put your commands or even functions.
If you will use custom functions, they need to be defined at the start of this script.
Or you can also call them from another file this way (also at the beginning of menu script):

. /path/to/functions-file

# OTHER??

#!/bin/bash
clear;E='echo -n';e=echo;p=proc;v=version;m='model name';ci=cpuinfo;mi=meminfo
t=tput;NUL=/dev/null;$t civis;trap "$e;$t cnorm;exit" 2;n=netstat;h=hostname
u=uname;a=awk;c=cat;BLUE(){ $e -en "\033c\033[1m\033[37;44m\033[J";}
g=grep;IP=$(/sbin/ip addr show|grep inet|awk '{print $2}')
while :;do $t cup 0 0;iptables -L -n 2>$NUL|$g -i 'reject\|drop' >$NUL
if [ "$?" = "0" ];then fw=on;else fw='off!';fi;OUT(){
$E -e "\033[30;42m"
$e " SYSTEM STATUS                                     << update=5s ctrl+c >> "
$E -e "\033[37;44m"
$e "  Server             > $($h) $($u -r) $($c /$p/$v |$a '{print $9,$10,$11}') "
$e "  SSH/SSL            > $(openssl version 2>&1|head -1)  "
$e "  Processor          > $($g "$m" /$p/$ci|$a '{print $4,$5,$6,$7,$8,$9}'|uniq -c)"
$e "  System load        > $($c /$p/loadavg |$a '{print $1,$2,$3}')  "
$e "  Uptime             > $(uptime|cut -f2 -dp|cut -f1 -d,)  "
$e "  SWAP (usage)       > "$($g Swap[Total\|Free] /proc/$mi)"  "
$e "  RAM (usage)        > "$($g Mem[Total\|Free] /proc/$mi)"  "
$e "  Disks usage        > "$(df|$g /|grep -v '/run'|$a '{print $5,$6}')"  "
$e "  Date and time      > $(date)  "
$e "  Runlevel           > $(runlevel)  "
$e "  Logged in Users    > $(users)  "
$e "  Processes          > $(top -b -n1|$g Tasks|cut -f2- -d,|tr -s ' ')  "
$e "  Open ports (tcp)   > "$($n -an|$g 'LISTEN '|$a '{print $4}'|cut -f2 -d:|sort|uniq)"  "
$e "  Open ports (udp)   > "$($n -an|$g ^udp|$a '{print $4}'|cut -f2 -d:|sort|uniq)"  "
$e "  Default Gateway(s) > "$(netstat -rn|$g UG|$a '{print $2}')"  "
$e "  DNS                > "$($g nameser /etc/resolv.conf|$a '{print $2}')"  "
$e "  Net status         > "$IP""
$e "  Firewall           > $fw  "
$E ' ________________________________________________________________________'

