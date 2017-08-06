awk '/em1/ {i++; rx[i]=$2; tx[i]=$10}; END{print rx[2]-rx[1] " " tx[2]-tx[1]}' \
 <(cat /proc/net/dev; sleep 1; cat /proc/net/dev)

awk '{if(l1){print $2-l1,$10-l2} else{l1=$2; l2=$10;}}' \
  <(grep wlan0 /proc/net/dev) <(sleep 1; grep wlan0 /proc/net/dev)


