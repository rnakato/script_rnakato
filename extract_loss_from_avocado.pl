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

my $str="";
my $binsize=100;
my $pair=0;
GetOptions(
    "str|s=s" => \$str,
    "binsize|b=i" => \$binsize,
) or pod2usage(1);

my $filename=shift;
pod2usage(2) unless $filename;

my $file = file($filename);
my $fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "");
    chomp;
    if ($_ =~ /- loss: (.+) -/) {
	print "$1\n";
    }
}
$fh->close;
