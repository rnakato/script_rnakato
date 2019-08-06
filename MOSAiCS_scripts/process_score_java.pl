#!/usr/bin/env perl;

###################################################################
#	This script processes the mappability/GC score by calculating
#	the average mappability/GC score for each bp in a sliding window
# 	of 2*expected frag length, and then summarize again the
#	average mappability score in non overlapping bins
#	The arguments are (1) map_infilename (eg: chr12_binary.txt) (2) outfile_name
#	(3) tag length (4) frag length (5) bin size
###################################################################

use warnings;
use strict;
use FindBin;
use lib $FindBin::Bin;
use Cwd 'getcwd';
$|=1;

# configuration

my $start_time = time();

my $infile = $ARGV[0];
my $outfile = $ARGV[1];
my $taglength = $ARGV[2];
my $L = $ARGV[3];
my $binsize = $ARGV[4];

my $tempfile = $ARGV[1]."_fragL".$L."_bin".$binsize."_temp.txt";
my $tempfile2 = $ARGV[1]."_fragL".$L."_bin".$binsize."_temp2.txt";

print "\n";
print "input file: " . $infile . "\n";
print "output file: " . $outfile . "\n";
print "\n";

# read in nucleotide-level mappability
# & generate a file to keep one nucleotide in a line

print "reading nucleotide-level mappability...\n";
open IN, "$infile" or die "Cannot open input file $infile\n";
open TEMPOUT, ">$tempfile" or die "Cannot open temp file $tempfile\n";

foreach my $raw_map_org (<IN>) {
	chomp($raw_map_org);
	$raw_map_org =~ s/[^(0-9)(.)]/\n/g;
	print TEMPOUT $raw_map_org;
	undef $raw_map_org;
}
close( IN );
close( TEMPOUT );

# calculate mappability using window
my $pwd = `dirname $0 | tr -d "\n"`;
system( "java -classpath $pwd CalcMappability $tempfile $tempfile2 $outfile $taglength $L $binsize" )==0 or die( 'fail to run java code!\n' );

# remove temporary file

system( "rm -vf $tempfile" );
system( "rm -vf $tempfile2" );

my $end_time = time();
print "processing time: " . ($end_time - $start_time) . " sec\n";

print "done!\n";
