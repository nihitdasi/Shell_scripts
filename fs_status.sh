#!/bin/bash

# Monitoring the free fs space disk.

FU=$(df -H | egrep -v "Filesystem|tmpfs" | grep "xvda1" | awk '{print $5}' | tr -d %)
TO="221910308038@gitam.in"

if [[ $FU -ge 20 ]]
then
        echo "Warning, disk space is low - $FU %" | mail -s "DISK SPACE ALERT!" $TO

else
        echo "All good"
fi
