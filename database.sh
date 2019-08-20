#!/bin/bash
hostname=`hostname`
#echo $hostname
if test $hostname = "ryuteki"; then
    echo /home/Database
else
    echo /work/Database
fi
