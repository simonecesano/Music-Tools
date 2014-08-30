#!/bin/bash
cd $1 \
    && find . -type f -name \*wav | parallel lame \
    && find . -type f -name \*wav | parallel flac \
    && find . -type f -name \*wav | parallel oggenc \
    && find . -type f -name \*wav -exec rm -v {} \;
