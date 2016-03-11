#!/usr/bin/perl -w

$fasta = $ARGV[0];

open(InputFile,$fasta) ||die "error: can't open $fasta.\n";
while($line = <InputFile>){
    next if($line eq "\n");
    chomp $line;
    if($line =~ ">"){
	if($len){
	    $acgt_count = ($fasta =~ tr/acgtACGT/acgtACGT/);
	    $gc_count = ($fasta =~ tr/cgCG/cgCG/);
	    my $p= $gc_count/$acgt_count;
	    print "$acgt_count\t$gc_count\t$p\n";
	}
	$len=0;
	$fasta="";
	if($' =~ /([A-Za-z0-9_]+)\s(.+)/){ $head = $1;}
	else{ $head = $';}
	next;
    }else{
	chomp($line);
	$len += length($line);
	$fasta .= $line;
    }
} 
close (InputFile);

if($len){
    $acgt_count = ($fasta =~ tr/acgtACGT/acgtACGT/);
    $gc_count = ($fasta =~ tr/cgCG/cgCG/);
    my $p= $gc_count/$acgt_count;
    print "$acgt_count\t$gc_count\t$p\n";
}

