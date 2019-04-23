#!/bin/bash

SECONDS=0

./preprocessor $1
result=$(./analyzer "$1.temp" > "$1.zasm" 2> "err.log")
if [[  $(grep 'Error' err.log) ]]; then 
    cat err.log
else
    cat err.log
    echo $'\n'$1$' output:\n'
    ./interpretator "$1.zasm"
fi

rm -f "$1.zasm"
rm -f err.log
rm -f "$1.temp" 

duration=$SECONDS
echo $'\n'
echo $"[Finished in $(($duration % 60))s]"
