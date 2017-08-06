#!/bin/bash

# This script will look at each numbered directory in the /proc directory
# and for each process print the running program's name name, its process id, and its current state.
# You can find the name and state of a process in /proc/<pid>/status.

# You may notice that there are some errors involving processes that disappear too fast to look at their status files.
# That is fine, just pipe the errors to /dev/null.
# Use functions to break up the different parts of the script.
# You will likely need to use file processing tools you learned in earlier labs to extract the needed information.

process_ids=""
info=""

function getProcessIds
{
    process_ids=`ls -d /proc/* | grep "/proc/[0-9].*" | cut -d'/' -f3 | sort -n`
}

function getProcessInfo
{
    pid=$1

    if [ -f "/proc/$pid/status" ];
    then
        name=`cat /proc/$pid/status | grep "Name" | cut -d':' -f2`
        state=`cat /proc/$pid/status | grep "State" | cut -d':' -f2`
        info="[$pid] $name: $state"
    fi
}

function main
{
    getProcessIds
    
    echo "Current Active Processes (pid, name and state):"
    
    for id in $process_ids
    do
        getProcessInfo $id 2> /dev/null
        echo -e $info
    done
}

# start
main

exit 0
