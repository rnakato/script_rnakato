#!/bin/bash

while getopts af: OPT
do
    case $OPT in
	"a" ) FLG_A="TRUE" ;;
	"f" ) FLG_B="TRUE" ; STR="$OPTARG";
    esac
done

echo -en $STR"\t"

if [ "$FLG_A" = "TRUE" ]; then
    cat $STR | grep -v \# |gawk '(NR%2==0){read=$1;total++;count[read]++;count2[length(read)]++}END{for(read in count){if(!max||count[read]>max){max=count[read];maxRead=read};if(count[read]==1){unique++}};printf("%d\t%d\t%.2f\t%s\t%d\t%.2f\t", total,unique,unique*100/total,maxRead,count[maxRead],count[maxRead]*100/total);for(len in count2){print len}}'
else
    gawk '(NR%4==2){read=$1;total++;count[read]++;count2[length(read)]++}END{for(read in count){if(!max||count[read]>max){max=count[read];maxRead=read};if(count[read]==1){unique++}};printf("%d\t%d\t%.2f\t%s\t%d\t%.2f\t", total,unique,unique*100/total,maxRead,count[maxRead],count[maxRead]*100/total);for(len in count2){print len}}' $STR
fi

