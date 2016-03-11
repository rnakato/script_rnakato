#!/usr/bin/perl -w

$fastq1=$ARGV[0];
$fastq2=$ARGV[1];

$num_fastq1=0; $num_fastq2=0; $num_both=0;
open(ListFile, $fastq1) ||die "error: can't open $fastq1.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    $num_fastq1++;
    my @clm = split(/\t/, $_);
    $strand{$clm[0]} = $clm[1];
    $chr{$clm[0]} = $clm[2];
    $posi{$clm[0]} = $clm[3];
}
close (ListFile);

$num_samestrand=0;
$intrachromosomal=0; $interchromosomal=0;
$selfligate=0; $interligate=0;
open(ListFile, $fastq2) ||die "error: can't open $fastq2.\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    $num_fastq2++;
    my @clm = split(/\t/, $_);
    next if(!exists($strand{$clm[0]}));
    $num_both++;
    if($clm[1] eq $strand{$clm[0]}){
	$num_samestrand++;
	next;
    }
    if($chr{$clm[0]} eq $clm[2]){
	$intrachromosomal++;
	if(abs($posi{$clm[0]} - $clm[3]) <= 4000){
	    $selfligate++;
	}else{
	    $interligate++;
	    print "$chr{$clm[0]}\t$posi{$clm[0]}\t$posi{$clm[0]}\t$clm[2]\t$clm[3]\t$clm[3]\n";
	}
    }else{
	$interchromosomal++;
    }
}
close (ListFile);

#print "num fastq1\tnum fastq2\tnum both\tsame strand\tintrachromosomal\tself-ligate\tinter-ligate\tinterchromosomal\n";
#print "$num_fastq1\t$num_fastq2\t$num_both\t$num_samestrand\t$intrachromosomal\t$selfligate\t$interligate\t$interchromosomal\n";
