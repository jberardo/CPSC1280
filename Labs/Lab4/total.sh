#!/bin/bash

DIR1=$1
DIR2=$2

if [ ! -d $DIR1 ]; then
    echo "$DIR1 does not exist!"
    exit
fi

if [ ! -d $DIR2 ]; then
    echo "$DIR2 does not exist!"
    exit
fi

clear

total1=`ls $DIR1 | wc -l`
total2=`ls $DIR2 | wc -l`

echo

echo "====================="
echo -e "Directory\tFiles"
echo "====================="
echo
echo -e "$DIR1\t$total1"
echo -e "$DIR2\t$total2"
echo
echo "---------------------"
echo -e "Total\t\t$(( $total1 + $total2 ))"
echo "---------------------"
