#!/bin/bash

DIR1=$1
DIR2=$2

if [ $# -eq 0 ]
then
    echo "Invalid option"
    echo "Please use: <program> <dir1> <dir2>"
    exit 1
fi

if [ ! -d $DIR1 ]
then
    echo "$DIR1 does not exist!"
    exit 1
fi

if [ ! -d $DIR2 ]
then
    echo "$DIR2 does not exist!"
    exit 1
fi

clear

total1=`ls $DIR1 | wc -l`
total2=`ls $DIR2 | wc -l`

echo

echo "====================="
echo -e "Files\tDirectory"
echo "====================="
echo
echo -e "$total1\t$DIR1"
echo -e "$total2\t$DIR2"
echo
echo "---------------------"
echo -e "Total files: $(( $total1 + $total2 ))"
echo "---------------------"

exit 0
