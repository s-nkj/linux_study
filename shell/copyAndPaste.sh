#!/bin/sh
if [ $# -ne 3 ]; then
    echo "Usage: copyAndPaste.sh target_file_path search_expression paste_start_row"
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "target file not found. $1"
    exit 1
fi

var=$(cat $1 | awk 'match($0, /${2}/) {print}')
var=$(echo $var)

cnt=$3

for i in seq 1 ${#var[*]} 
do
    $(sed -i '${cnt}i/${var[i]}/' $1)
    cnt=$((cnt + 1))
done
