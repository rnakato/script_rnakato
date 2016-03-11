# 090203_l8_pFGF 以外

file="plus_FGF_summary.fq"

rm $file

for date in 090209 090213
do
    for i in 1 2 3 4 
    do
	dir=$date\_l$i\_pFGF
	cat $dir/s_$i\_*_seq.txt | awk -F '\t' '{print "@"$1$2$3$4NR"\n"$5"\n""+"$1$2$3$4NR"\n"$1 0}' > $dir/s_$i\_1.fq
	cat $dir/s_$i\_1.fq >> $file
    done
done

maq sol2sanger $file > $file-sanger

rm *~