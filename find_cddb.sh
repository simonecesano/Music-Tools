#!/bin/bash
find $1 -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d $'\0' line; do
    if [ -f "$line.cddb" ]
    then
	: #echo "$line ok"
    else
	echo "$line misses cddb"
    fi
done
