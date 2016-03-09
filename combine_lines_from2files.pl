#!/usr/bin/env perl

=head1 DESCRIPTION

    describe DESCRIPTION

=head1 SYNOPSIS

    % combine_lines_from2files.pl <file1> <file2> <line1> <line2>

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;
pod2usage(2) if($#ARGV !=3);
my $file1=$ARGV[0];
my $file2=$ARGV[1];
my $line1=$ARGV[2];
my $line2=$ARGV[3];

my %Hash = ();
my $file = file($file1);
my $fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\s/, $_);
    $Hash{$clm[$line1]} = $_;
}
$fh->close;

$file = file($file2);
$fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\s/, $_);
    my $name = $clm[$line2];
    print "$Hash{$name}\t$_\n" if(exists($Hash{$name}));
}
$fh->close;
