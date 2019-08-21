#!/bin/bash
hostname=`hostname`
if test $hostname = "ryuteki"; then
    echo /home/Database
else
    echo /work/Database
fi
