#!/bin/bash

# Apache access log parser
# Displayed columns in order from left to right:

#    Date and time of access
#    HTTP CODE of response [200 in green, 404 in blue, rest in red]
#    IP address
#    Reverse DNS hostname [last 30 chars] [empty if NXDOMAIN]
#    Request [first 30 chars]

while read line
do
        # IP
          ip=$(echo $line | cut -d " " -f 1)

        # HOST
          host=$(host $ip | cut -d " " -f 5 | tail -1)
          if [[ ${#ip} -lt 15 ]]; then
                for (( i=$(echo "15-${#ip}"|bc); i>0; i-- )) do
                        ip="$ip "
                done
          fi

        # IF I DO NOT GET DOMAIN NAME
          if [[ $(echo "$host" | grep "NXDOMAIN" | wc -l ) -ne 0 ]]; then
                host=" - "
          fi

        # EVEN UP THE HOSTNAME TO SEE LAST 30 CHARS
          if [[ ${#host} -lt 30 ]]; then
                for (( i=$(echo "30-${#host}"|bc); i>0; i-- )) do
                        host="$host "
                done
          else
                host=${host:$(echo "${#host}-30"|bc)}
          fi

          dhost="\033[01;30m$host\033[00m"

        #   DISPLAY GOOGLEBOT CUSTOM DNS
          if [[ $(echo $host | grep google |wc -l) -eq 1 ]]; then
                dhost="\033[01;30mGOOGLEBOT\033[00m                     "
          fi

        # DATE
          date=$(echo $line | cut -d "[" -f 2 | cut -d "]" -f 1 | cut -d "+" -f 1)
                day=$(echo $date | cut -d ":" -f 1 | tr -d " ")
                dtime=$(echo $date | cut -d ":" -f 2- | tr -d " ")

        # REQUEST
          req=$(echo $line | cut -d "]" -f 2 | cut -d "\"" -f 2 | cut -d " " -f -2)
        # CUT REQUEST TO 30 CHARS
          dreq=${req:0:30}
        # CUSTOM REQUEST INFO IN CASE OF ADMIN PANEL
          if [[ $(echo $req | grep "admin.php" | wc -l) -eq 1 ]]; then
                dreq="\033[01;31mFAV\033[00m"
          fi

        # HTTP CODE
          code=$(echo $line | cut -d "\"" -f 3 | cut -d " " -f 2)
          hcode="\033[01;31m$code\033[00m";
          if [[ "$code" -eq "200" ]]; then
                hcode="\033[01;32m$code\033[00m";
          fi
          if [[ "$code" -eq "404" ]]; then
                hcode="\033[01;34m$code\033[00m";
          fi

        # DISPLAY
          # I DONT WANT TO DISPLAY FAVICON REQUESTS
          if [[ $(echo $req | grep "favicon.ico" | wc -l) -eq 1 ]]; then
                echo -n ""
          else
                echo -e "$day $dtime $hcode $ip $dhost $dreq"
          fi
done < /var/log/apache2/access.log
