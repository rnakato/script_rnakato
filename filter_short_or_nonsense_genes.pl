#!/usr/bin/env perl

=head1 DESCRIPTION

    describe DESCRIPTION

=head1 SYNOPSIS

    % sample.pl [options] <filename>

    Options:
    --binsize=<int>
    --pair

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config  no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

my $length=1000;
GetOptions("length|l=i" => \$length) or pod2usage(1);

my $filename=shift;
pod2usage(2) unless $filename;

my $file = file($filename);
my $fh = $file->open('r') or die $!;
my $line = <$fh>;
chomp($line);
print "$line\n";

my $ncol=0;
my $ncol_type=0;
my @clm = split(/\t/, $line);
for(my $i=0; $i<=$#clm; $i++) {
    if($clm[$i] eq "length") {
	$ncol = $i;
    }
    if($clm[$i] eq "type") {
	$ncol_type = $i;
    }
}

while(<$fh>){
    next if($_ eq "");
    chomp;
    my @clm = split(/\t/, $_);
    
    if($clm[$ncol] > $length && 
       ($clm[$ncol_type] eq "protein_coding"
	|| $clm[$ncol_type] eq "lincRNA"
	|| $clm[$ncol_type] eq "antisense")) {
	print "$_\n";
    }
}
$fh->close;
