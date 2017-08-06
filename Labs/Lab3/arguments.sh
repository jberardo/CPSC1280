#!/bin/sh

argWords=$#
upTimeSeconds=`cat /proc/uptime | cut -d' ' -f1 | cut -d. -f1`
upTimeMinutes=$[$upTimeSeconds/60]

echo "After being online for $upTimeMinutes minutes, $USER said \"$@\". The sentence has $argWords words in it."
