#!/bin/bash
if [ "$#" -ne 1 ]; then
    dir=`pwd`
else
    dir=$1
fi

find $dir -name *.wav -print   | xargs -I{} dirname {} | sort | uniq
