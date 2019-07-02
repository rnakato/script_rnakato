#!/bin/bash

if nkf --help >& /dev/null; then
    tmpfile=$(mktemp)
    nkf -Lu $1 > test
    mv test $1
else
    echo "Error: nkf not found."
fi
