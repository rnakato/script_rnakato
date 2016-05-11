#!/usr/bin/env perl

open(File, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
while(<File>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ /\s+Number of input reads \|\t(.+)/){
	$total=$1;
    }elsif($_ =~ /\s+Uniquely mapped reads number \|\t(.+)/){
	$uniq=$1;
    }elsif($_ =~ /\s+Uniquely mapped reads % \|\t(.+)%/){
	$runiq=$1;
    }elsif($_ =~ /\s+Number of reads mapped to multiple loci \|\t(.+)/){
	$multi=$1;
    }elsif($_ =~ /\s+% of reads mapped to multiple loci \|\t(.+)%/){
	$rmulti=$1;
    }elsif($_ =~ /\s+Number of reads mapped to too many loci \|\t(.+)/){
	$multi2=$1;
    }elsif($_ =~ /\s+% of reads mapped to too many loci \|\t(.+)%/){
	$rmulti2=$1;
    }elsif($_ =~ /\s+% of reads unmapped: too many mismatches \|\t(.+)/){
	$runmap=$1;
    }elsif($_ =~ /\s+% of reads unmapped: too short \|\t(.+)/){
	$runmap2=$1;
    }elsif($_ =~ /\s+% of reads unmapped: other \|\t(.+)/){
	$runmap3=$1;
    }elsif($_ =~ /\s+Number of splices: Total \|\t(.+)/){
	$nspl=$1;
    }elsif($_ =~ /\s+Number of splices: Annotated \(sjdb\) \|\t(.+)/){
	$nsplanno=$1;
    }elsif($_ =~ /\s+Number of splices: Non-canonical \|\t(.+)/){
	$nsplun=$1;
    }elsif($_ =~ /\s+Mismatch rate per base, % \|\t(.+)%/){
	$rms=$1;
    }elsif($_ =~ /\s+Deletion rate per base \|\t(.+)%/){
	$rdel=$1;
    }elsif($_ =~ /\s+Insertion rate per base \|\t(.+)%/){
	$rins=$1;
    }elsif($_ =~ /\s+Number of chimeric reads \|\t(.+)/){
	$chim=$1;
    }elsif($_ =~ /\s+% of chimeric reads \|\t(.+)%/){
	$rchim=$1;
    }

}

print STDERR "Sequenced\tUniquely mapped\t(%)\tMapped to multiple loci\t(%)\tMapped to too many loci\t(%)\tUnmapped (too many mismatches)\tUnmapped (too short)\tUnmapped (other)\tchimeric reads\t(%)\t";
print STDERR "Splices total\tAnnotated\t(%)\tNon-canonical\t(%)\tMismatch rate per base (%)\tDeletion rate per base (%)\tInsertion rate per base (%)\n";

print "$total\t$uniq\t$runiq\t$multi\t$rmulti\t$multi2\t$rmulti2\t$runmap\t$runmap2\t$runmap3\t$chim\t$rchim\t";
printf("%d\t%d\t%.2f\t%d\t%.2f\t%.2f\t%.2f\t%.2f\n", $nspl, $nsplanno, $nsplanno*100/$nspl, $nsplun, $nsplun*100/$nspl, $rms, $rdel, $rins);
