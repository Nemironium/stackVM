#!/bin/bash
./preprocessor $1
result=$(./analyzer "$1.temp" > "$1.zasm" 2> "err.log")
if [[  $(grep 'Error' err.log) ]]; then 
    cat err.log
    rm -f "$1.zasm"
else
    cat err.log
fi
rm -f err.log
rm -f "$1.temp" 
