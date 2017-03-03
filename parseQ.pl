#!/usr/bin/env perl

=head1 DESCRIPTION
 
    Parse stats output by bowtie1.
 
=head1 SYNOPSIS

    parsebowtielog.pl <file>

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

my $filename=shift;
pod2usage(2) unless $filename;
my $txt = "$filename.txt";

system("pdftotext $filename $txt");

my $file = file("$txt");
my $fh = $file->open('r') or die $!;
while(<$fh>){
    chomp;
    if($_ =~ /FL = ([0-9]+) \| RSC =(.*)/){
	my $flen = $1;
	my $rsc = $2;
	$rsc =~ s/^ *(.*?) *$/$1/;
	print "$flen\t$rsc\n";
    }
}
$fh->close;
unlink $txt;
