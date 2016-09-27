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
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

my $filename=shift;
pod2usage(2) unless $filename;

my $file = file($filename);
my $fh = $file->open('r') or die $!;
my $nline=0;
my $ncol=0;
my $nsample=0;
my @array;
while(<$fh>){
    next if($_ eq "");
    chomp;
    my @clm = split(/\t/, $_);
    if(!$nline) {
	$ncol = $#clm +1;
	$nsample = $ncol - 3;
#	print "$ncol $nsample\n";
	for(my $i=0; $i<$ncol+$nsample; $i++) {
	    my @a;
	    push @array, [@a];
	}
    }

    for(my $i=0; $i<=$#clm; $i++) {
	push(@{$array[$i]}, $clm[$i]);
    }
    $nline++;
}
$fh->close;

for(my $i=0; $i<$nsample; $i++) {
    @{$array[$i+$ncol]} = sort { $b <=> $a } @{$array[$i+3]};
}

for(my $j=0; $j<$nline; $j++) {
    for(my $i=0; $i<$ncol; $i++) {
	print "$array[$i][$j]\t";
    }
    for(my $i=0; $i<$nsample; $i++) {
	my $val = $array[$i+3][$j];
	for(my $l=0; $l<$nline; $l++) {
	    if($val == $array[$ncol+$i][$l]) {
		printf("%f\t",($nline-$l-1)/($nline-1));
		last;
	    }
	}
    }
    print "\n";
}
