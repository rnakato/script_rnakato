#!/usr/bin/env perl

=head1 DESCRIPTION

    describe DESCRIPTION

=head1 SYNOPSIS

    % jaccard.pl [options] -f <filename> -l <label> [-f <filename> -l <label> ...]

    Options:
    --number  peak number to be compared (default: 10000)

=cut

use strict;
use warnings;
use autodie;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;
use File::Temp qw/tempfile tempdir/;

my @file;
my @name;
my $number=10000;
GetOptions(
    "file|f=s@" => \@file,
    "label|l=s@" => \@name,
    "number|n=i" => \$number
) or pod2usage(1);

die "different number: -f and -l.\n" if($#file != $#name);

pod2usage(2) if(!$#file);
my ($fh, $tmpfile) = tempfile;

for(my $i=0;$i<=$#file;$i++){
    system("sort -k1,1 -k2,2n $file[$i] | cut -f1,2,3 > $tmpfile.$i");
    system("head -n $number $tmpfile.$i > $tmpfile.$i.top$number");
}

foreach (@name){ print "\t$_"; }
print "\n";

for(my $i=0;$i<=$#file;$i++){
    print "$name[$i]";
    for(my $j=0;$j<=$#file;$j++){
	my $jaccard=`bedtools jaccard -a $tmpfile.$i.top$number -b $tmpfile.$j.top$number | grep -v jaccard | cut -f3 | tr -d '\n'`;
	print "\t$jaccard";
    }
    print "\n";
}

for(my $i=0;$i<=$#file;$i++){
    system("rm $tmpfile.${i}*");
}
