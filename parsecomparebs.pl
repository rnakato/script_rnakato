#! /usr/bin/perl -w

use Getopt::Long;

$length=0;
GetOptions('length' => \$length);
$file=$ARGV[0];

open(IN, $file) || die "error: cannot open $file.";
while(<IN>) {
    next if($_ eq "\n");
    chomp;
    if(!$length && $_ =~ /#num1: (.+)\tnum2: (.+)\tnum1_overlap: (.+) (\(.+\))\tnum1_notoverlap: (.+) (\(.+\))\tnum2_overlap: (.+) (\(.+\))\tnum2_notoverlap: (.+) (\(.+\))/){
	print "$1\t$2\t$3\t$4\t$5\t$6\t$7\t$8\t$9\t$10\n";
    }
    if($length && $_ =~ /#peakwidth total1: (.+) bp(.+)peakwidth total2: (.+) bp(.+)overlappeaks total: (.+) bp \((.+)% \/ (.+)%\)/){
	print "$1\t$3\t$5\t$6\t$7\n";
    }
}
close IN;

#file1 peaknum: 3499	file2 peaknum: 22412	 file1 common: 463 (13.2%)	file1 unique: 3036 (86.8%)	file2 common: 480 (2.1%)	file2 unique: 21932 (97.9%)
