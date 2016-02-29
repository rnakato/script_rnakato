#!/usr/bin/env perl

=head1 DESCRIPTION

    split multifasta into single fastas in <dir>

=head1 SYNOPSIS

    % splitmulitfasta.pl <input.fa> <directory>

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Pod::Usage qw/pod2usage/;

my $filename = $ARGV[0];
pod2usage(2) unless $filename;
my $dir = $ARGV[1];
pod2usage(2) unless $dir;
my $head ="";
my $seq = "";
my $file = file($filename);
my $fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ />(.+)/){
	if($seq ne ""){
	    my $out = file($dir . "/" . $head . ".fa");
	    my $writer = $out->open('w') or die "Can't read $out: $!";
	    $writer->print(">$head\n");
	    $writer->print("$seq\n");
	    $writer->close;
	    $seq = "";
	}
	$head =$1;
	$head =~ s/\s+/_/g;
	print "$head\n"
    }else{
	$seq .= $_;
    }
} 
$fh->close;

if($seq ne ""){
    my $out = file($dir . "/" . $head . ".fa");
    my $writer = $out->open('w') or die "Can't read $out: $!";
    $writer->print(">$head\n");
    $writer->print("$seq\n");
    $writer->close;
}
