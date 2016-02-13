#! /usr/bin/perl -w

use strict;
use warnings;
use autodie;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;

my $length=0;
GetOptions('length' => \$length);
my $file=$ARGV[0];
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
