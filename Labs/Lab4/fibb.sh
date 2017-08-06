#!/bin/sh

if [ $# -eq 0 ]
then
        echo "Invalid option."
        echo "Please use <program> <number>"
        exit 1
fi

Num=$1
f1=0
f2=1

echo "The Fibonacci sequence for the number $Num is : "

for (( i=0;i<Num;i++ ))
    do
        echo -n "$f1 "
           fn=$((f1+f2))
            f1=$f2
            f2=$fn
    done

echo

exit 0
