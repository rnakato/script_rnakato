#!/bin/bash
param=$1
paramname=$2

if expr "$param" : "[0-9]*$" >&/dev/null; then
#    echo "ncore: $ncore"
    x=1
else
    echo "Error: illegal number specified to $paramname: $param"
    exit 1
fi

exit 0
