#!/bin/sh
if [ $# -ne 1 ]; then
    echo "Usage: CmdExecutor.sh read_filename"
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "Input file not found. $1"
    exit 1
fi

IFS=$'\n'
file=(`cat "$1"`)

ln=0
for line in "${file[@]}"; do
    if [ ! "$(echo $line | cut -c 1)" = "#" -a ! "$line" = "" ]; then
        # execute command
        echo $line
        $($line)
    fi
done
