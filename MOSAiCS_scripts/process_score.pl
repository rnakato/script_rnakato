###################################################################
#	This script processes the mappability/GC score by calculating 
#	the average mappability/GC score for each bp in a sliding window
# 	of 2*expected frag length, and then summarize again the 
#	average mappability score in non overlapping bins
#	The arguments are (1) map_infilename (eg: chr12_binary.txt) (2) outfile_name
#	(3) frag length (4) bin size
###################################################################

#!/usr/bin/env perl;
use warnings;
use strict;
use FindBin;
use lib $FindBin::Bin;
$|=1;

my $infile = $ARGV[0];
my $L = $ARGV[2];
my $binsize = $ARGV[3];
my $outfile = $ARGV[1];

open IN, "$infile" or die "Cannot open $infile\n";
open OUT, ">$outfile" or die "Cannot open $outfile\n";

while (my $raw_map = <IN>) {
	chomp $raw_map;	
	$raw_map =~ s/\s//g;
	my $len = length($raw_map)-1;
	my @ave_map = ();	
	for(my $i=0; $i<=$L-1; $i++){
		my $start = 0;
		my $stop = $i+$L-1;
		my $seg_len = $stop -$start + 1;
		my $seg = substr($raw_map,$start,$seg_len);
		my $ave = ($seg =~ tr/1/1/)/($seg_len);
		push (@ave_map, $ave);
	}
	for(my $i=$L; $i<=$len-$L+1; $i++){
		my $start = $i-$L+1;
		my $stop = $i+$L-1;
		my $seg_len = $stop -$start + 1;
		my $seg = substr($raw_map,$start,$seg_len);
		my $ave = ($seg =~ tr/1/1/)/($seg_len);
		push (@ave_map, $ave);
	}	
		
	for(my $i=$len-$L+2; $i<=$len; $i++){
		my $start = $i-$L+1;
		my $stop = $len;
		my $seg_len = $stop -$start + 1;
		my $seg = substr($raw_map,$start,$seg_len);
		my $ave = ($seg =~ tr/1/1/)/($seg_len);
		push (@ave_map, $ave);
	}
	
	my $len2 = scalar(@ave_map);
	my $max = int(($len2+1)/$binsize)-1;
	
	for(my $i=0; $i<=$max; $i++){
		my $start = $i*$binsize;
		my $stop = $start +$binsize -1;
		my @sub_raw_map = @ave_map[$start..$stop];
		my $total = 0;
		foreach my $element (@sub_raw_map){
			$total+=$element;
		}
		my $ave = $total/scalar(@sub_raw_map);
		print OUT "$start\t$ave\n";
	}
}



	
	
