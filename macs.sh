#!/bin/bash

if test $# -ne 4; then
    echo "macs.sh <IP bam> <Input bam> <output> <mode>"
    exit 0
fi

mdir=macs
if test ! -e $mdir; then mkdir $mdir; fi

IP=$1
Input=$2
peak=$3
mode=$4

macs="macs2 callpeak -t $IP -c $Input -g hs -f BAM"
if test -e $IP && test -s $IP ; then
    if test -e $Input && test -s $Inpput ; then
	if test $mode = "nomodel"; then
	    if test ! -e $mdir/${peak}-nomodel_summits.bed; then $macs -n $mdir/$peak-nomodel --nomodel --shift 200; fi
	elif test $mode = "broad"; then
	    if test ! -e $mdir/${peak}_summits.bed; then         $macs -n $mdir/$peak --broad; fi
	elif test $mode = "broad-nomodel"; then
	    if test ! -e $mdir/${peak}-nomodel_summits.bed; then $macs -n $mdir/$peak-nomodel --nomodel --shift 200 --broad; fi
	else 
	    if test ! -e $mdir/${peak}_summits.bed; then         $macs -n $mdir/$peak; fi
	fi
    else
	echo "$Input does not exist."
    fi
else
    echo "$IP does not exist."
fi
