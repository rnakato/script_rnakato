#!/bin/bash
# usage
cmdname=`basename $0`
function usage()
{
  echo "Usage: ${cmdname} file str_before str_after" 1>&2
}

# check arguments
if [ $# -ne 3 ]; then
  usage
  exit 1
fi
file="$1"
arg1="$2"
arg2="$3"

# main
sed -i.bak 's/'$arg1'/'$arg2'/gI' $file
exit 0
