sing="singularity exec --nv --bind /work,/work2,/work3 /work/SingularityImages/churros.1.5.0.sif"

for prefix in Control1_rep1 Control2_rep1
do
    $sing samtools index $prefix.Aligned.sortedByCoord.out.bam

    for strand in forward reverse
    do
	# --samFlagExclude 2304: supplementary alignment の除去
        $sing bamCoverage \
              -b $prefix.Aligned.sortedByCoord.out.bam \
              -o $prefix.CPM.primary.coverage_$strand.mapq10.bw \
              --binSize 1 \
              --filterRNAstrand $strand \
              --normalizeUsing CPM \
              --minMappingQuality 10 \
              --samFlagExclude 2304 \
              -p 8
    done
done
