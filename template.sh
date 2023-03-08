#!/bin/bash
# usage
cmdname=`basename $0`
function usage()
{
  echo "Usage: ${cmdname} [-t] [-f file] arg1 arg2" 1>&2
}

# check options
topt=FALSE
while getopts tf: option
do
  case ${option} in
    t) topt=TRUE;;
    f) file=${OPTARG};;
    *)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

# check arguments
if [ $# -ne 2 ]; then
  usage
  exit 1
fi
arg1="$1"
arg2="$2"

# main
echo "arg1=[${arg1}], arg2=[${arg2}], topt=[${topt}], file=[${file}]"
exit 0
