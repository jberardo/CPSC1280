#!/bin/sh

f1=0
f2=1
Num=6

echo "The Fibonacci sequence for the number $Num is : "

for (( i=0;i<Num;i++ ))
    do
        echo -n "$f1 "
           fn=$((f1+f2))
            f1=$f2
            f2=$fn
    done

echo
