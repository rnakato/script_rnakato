#!/usr/bin/env perl

=head1 DESCRIPTION

    describe DESCRIPTION

=head1 SYNOPSIS

    split bed sites into subsites with the fixed length
    % getBedWidth.pl <bed> <windowsize>

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use POSIX qw(ceil);
use Statistics::Lite qw(:all);
use Pod::Usage qw/pod2usage/;
pod2usage(2) if($#ARGV !=1);
my $file1=$ARGV[0];
my $windowsize = int($ARGV[1]);

my $file = file($file1);
my $fh = $file->open('r') or die $!;
my @array=();

while(<$fh>){
    next if($_ eq "\n" || $_ =~ /start/ || $_ =~ /\#/);
    chomp;
    my @clm = split(/\s/, $_);
    my $chr = $clm[0];
    my $s = $clm[1];
    my $e = $clm[2];
    my $len = $e - $s;
    my $nsplit = ceil($len / $windowsize);
#    print "$chr\t$s\t$e\t$len\t$nsplit\n";
    for(my $i=0; $i<$nsplit; $i++) {
	printf("%s\t%s\t%s\n", $chr, $s + $i*$windowsize, $s + ($i+1)*$windowsize -1);
    }
}
$fh->close;

