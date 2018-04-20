###################################################################
#	This script pre-process the Eland input for a chromosome. 
#	It is a subcode of the complete preprocess_Eland_countbin.pl. 
#	It first extends the fragment length, then sum total number of 
#	fragments within each genomic window. The arguments are:
#	(1) chrID (2) Expected fragment length, (3) Bin size (4) collapse (5) list of file names
###################################################################

#!/usr/bin/env perl;
use warnings;
use strict;
use FindBin;
use lib $FindBin::Bin;
$|=1;

my ($chr, $L, $binsize, $collapse, @filename) = @ARGV;

my @cutfile=();
my $len = scalar(@filename)-1;

for(my $i=0; $i<=$len; $i++){
	my $str = join(".",$filename[$i],"tmp");
	`more $filename[$i] | grep $chr."fa" > $str`;
    push (@cutfile ,$str);
}

`cat @cutfile >combined_tmp.txt`;
`rm -rf *tmp`;

my $infile  = "combined_tmp.txt";
my $infile_uniq  = "combined_uniq.txt";
my $outfile = $chr."_".$filename[0]."_fragL".$L."_bin".$binsize.".txt";

open IN, "$infile" or die "Cannot open $infile\n";
open OUT_uniq, ">$infile_uniq" or die "Cannot open $infile_uniq\n";
open OUT, ">$outfile" or die "Cannot open $outfile\n";

my %seen =();

while(<IN>){
	chomp;	
	my ($t1, $seq, $map, $t3, $t4, $t5, $chrt, $pos, $str, @rest) = split /\s+/, $_;
	my $read_length = length $seq;
	
	my @pos_sets = split( /,/, $pos );
	if ( scalar(@pos_sets) > 1 ) {
	    	next;
    	}
	
	$pos = $pos + $read_length - $L if($str eq "R");
	$str = "F" if($str eq "R");
	my $id = join("",$chrt,$pos);
	$seen{$id}++;
	if ( $seen{$id} > $collapse ) {
	    	next;	
    	}
	print OUT_uniq "$t1\t$seq\t$map\t$t3\t$t4\t$t5\t$chrt\t$pos\t$str\t@rest\n";
}
print "finished removing duplicates\n";

close IN;
close OUT_uniq; 

`rm -rf $infile`;

open IN, "$infile_uniq" or die "Cannot open $infile_uniq\n";

my @bin_count = ();

while (<IN>) {
	chomp;
	
	my ($t1, $seq, $map, $t3, $t4, $t5, $chrt, $pos, $str, @rest) = split /\s+/, $_;
	my $read_length = length $seq;
	my $L_tmp = $L;  
	if($L < $read_length){$L_tmp = $read_length};
	if ($str eq "F") {
         	my $bin_start = int($pos/$binsize) ;
		my $bin_stop = int(($pos + $L_tmp - 1 )/$binsize) ;
		for(my $i = $bin_start; $i <= $bin_stop; $i++){$bin_count[$i]++};
	
	}
	elsif ($str eq "R") {
		my $start_tmp = $pos + $read_length - $L_tmp;
		$start_tmp = 1 if ($start_tmp < 1);
		my $bin_start = int($start_tmp/$binsize) ;
		my $bin_stop = int(($pos + $read_length - 1)/$binsize) ;
		for(my $i = $bin_start; $i <= $bin_stop; $i++){$bin_count[$i]++};

	}
	else {
		print "PROBLEM\n";
	}
}
    
close IN;
`rm -rf $infile_uniq`;

for( my $i = 0; $i< scalar(@bin_count); $i++ ){
    my $coord = $i*$binsize;
    if($bin_count[$i]){print OUT "$chr\t$coord\t$bin_count[$i]\n";}
    else {print OUT "$chr\t$coord\t0\n";}
}

close OUT;
print "Pre-processed $chr using frag length of $L and binsize of $binsize!\n";





