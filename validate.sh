#!/bin/bash

getSnSp(){
    num=$2
    ref=$3
    f1=$1.top$num.temp1.$pram
    f2=$1.top$num.temp2.$pram
    head -n${num} $1 > $f1
    compare_bs -1 $f1 -2 $ref -nobs > $f2
    sn[$i]=`parsecomparebs.pl $f2 | cut -f8 | sed -e 's/(//g' -e 's/%)//g'`
    sp[$i]=`parsecomparebs.pl $f2 | cut -f4 | sed -e 's/(//g' -e 's/%)//g'`
    spd[$i]=`echo ${sp[$i]} | awk '{printf ("%.1f",(1-$1/100.0)*100)}'`
    echo -en "\t${sn[$i]}\t${spd[$i]}"
    rm $f1 $f2
}

getROC(){
    ref=$1
    peakmin=100000000000
    for i in $(seq 2 $#); do
	eval str='$'{$i}
	arr=(`echo $str | tr -s ',' ' '`)
	file[$i]=${arr[0]}
	name[$i]=${arr[1]}
	peaknum=`wc -l ${file[$i]} | cut -f1 -d " "`
	if test $peakmin -ge $peaknum; then peakmin=$peaknum; fi
    done

    p100=`expr $peakmin \/ 100`
    pram=`echo $ref | cut -d "/" -f 2`
    
    echo -en "num"
    for i in $(seq 2 $#); do echo -en "\t${name[$i]} Sn\t${name[$i]} 1-Sp"; done
    echo ""

    for n in $(seq 1 $p100); do
	#	num=`expr $p100 - $n`00
	num=${n}00
	if test $num -ge 3000 && test `expr $num % 1000` -ne 0; then continue; fi
	echo -en "$num"
	for i in $(seq 2 $#); do getSnSp ${file[$i]} $num $ref; done
	echo ""
    done
}

for sample in CTCF_mock_treat #CTCF_treat_rep1
do
    list=""
    for str in raw raw-mpbl GC-mpbl raw-mpbl-normgcov0
    do
	f=xls/drompa2-MCF7_$sample-norm1-$str-n2-m1-hg19.xls
	sort -k7nr $f > $f.sorted.p1
	sort -k8nr $f > $f.sorted.p2
	list="$list $f.sorted.p1,CTCF-$str-p1 $f.sorted.p2,CTCF-$str-p2"
    done
    prefix=drompa2-$sample
    getROC reference/CTCF.txt $list > $prefix.JASPAR.xls
#    func reference/mast_CTCF_mock_treat_n1000.1e-6.txt $list > $prefix.MAST.xls &
done

exit 0

for sample in CTCF_mock_treat CTCF_treat_rep1
do
    list=""
    for sampletype in $sample $sample-IPonly #$sample-mpbl 
    do
	for str in raw raw-mpbl GC-mpbl #raw-GR raw-mpbl-GR GC-mpbl-GR
	do
	    f=xls/drompa3-MCF7_$sampletype-n2-m1-$str-hg19.xls
	    case $sampletype in
		"$sample-IPonly")
		sort -k6nr $f > $f.sorted.p1
		list="$list $f.sorted.p1,$sampletype-$str-p1";;
		*)
		sort -k8nr $f > $f.sorted.p2
		list="$list $f.sorted.p2,$sampletype-$str-p2";;
	    esac
	done
    done
 #   echo $list
    prefix=drompa3-$sample
    func reference/CTCF.txt $list > $prefix.JASPAR.xls &
    func reference/mast_CTCF_mock_treat_n1000.1e-6.txt $list > $prefix.MAST.xls &
done

for str in CTCF_treat_rep1 CTCF_mock_treat
do
    file1=xls/$str-n2-m1-hg19.macs2_peaks.xls
    sort -k9nr $file1 > $file1.sorted
    file2=xls/drompa2-MCF7_$str-norm1-raw-mpbl-normgcov0-n2-m1-hg19.xls
    sort -k7nr $file2 > $file2.sorted.p1
    sort -k8nr $file2 > $file2.sorted.p2
    file3=xls/drompa3-MCF7_$str-IPonly-n2-m1-raw-mpbl-hg19.xls
    sort -k6nr $file3 > $file3.sorted.p1
    file4=xls/drompa3-MCF7_$str-n2-m1-raw-mpbl-hg19.xls
    sort -k8nr $file4 > $file4.sorted.p2
    file5=xls/MCF7_$str-n2-m1-hg19.sort.narrowPeak
    
    filelist="$file1.sorted,macs $file2.sorted.p1,drompa2p1 $file2.sorted.p2,drompa2p2 $file3.sorted.p1,drompa3-IPonly $file4.sorted.p2,drompa3p2 $file5,spp.narrowPeakk"
    prefix=all-$str
    func reference/CTCF.txt $filelist > $prefix.JASPAR.xls &
    func reference/mast_CTCF_mock_treat_n1000.1e-6.txt $filelist > $prefix.MAST.xls &
done

rm *~
