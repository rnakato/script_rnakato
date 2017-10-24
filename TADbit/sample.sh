
pdir=/home/rnakato/git/script_rnakato/TADbit

for i in 19 #$(seq 1 22) X
do
    chr=chr$i
    Ct="Control,../../Sakata/RPE_Ct/${chr}_R_Ct_100000_iced_dense.matrix"
    CTCF="CTCFKD,../../Sakata/RPE_CTCFKD/${chr}_R_si628_100000_iced_dense.matrix"
    Rad21="Rad21KD,../../Sakata/RPE_Rad21KD/${chr}_R_si621_100000_iced_dense.matrix"
    NIPBL="NIPBLKD,../../Sakata/RPE_NIPBLKD/${chr}_R_si7_100000_iced_dense.matrix"
    #echo $Ct $CTCF $Rad21 $NIPBL
    #python $pdir/LoadMatrix.py -i $Ct $CTCF $Rad21 $NIPBL -o RPE.$chr -c $chr -p 30
    #python $pdir/CompareTAD.py -i $Ct $CTCF $Rad21 $NIPBL -o RPE.$chr -t RPE.$chr.tdb -p 30
#    python $pdir/make3Dmodel.py -i $Ct $CTCF $Rad21 $NIPBL -o RPE.$chr -t tdb/RPE.$chr.tdb --start 25 --end 250 -p 30
    python $pdir/make3Dmodel.py -i $Ct $CTCF $Rad21 $NIPBL -o RPE.$chr -t tdb/RPE.$chr.tdb --start 275 --end 590 -p 30

    for str in #Control CTCFKD Rad21KD NIPBLKD
    do
	python $pdir/makeFig.py -i TADbit/Modelfile/RPE.chr19.$str.models -o $str
	#python $pdir/calcParticleDist.py -i TADbit/Modelfile/RPE.chr19.CTCFKD.models -s 10 -e 20 -o test
    done
done


rm *~
