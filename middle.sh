#!/bin/bash

if [ $# -ne 3 ]; then
  echo "middle.sh <file> <start> <end>" 1>&2
  exit 1
fi

#cat $1 | head -n$3 | tail -n`expr $3 - $2 + 1`
head -n$3 $1 | tail -n`expr $3 - $2 + 1`

