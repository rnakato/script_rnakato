#!/usr/bin/env perl

=head1 DESCRIPTION

    describe DESCRIPTION

=head1 SYNOPSIS

    % classifyGenes.pl [options] <filename>

    Options:
    --thre=<float>

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

my $thre=50;
GetOptions(
    "thre|t=f" => \$thre,
) or pod2usage(1);

my $filename=shift;
pod2usage(2) unless $filename;

my $file = file($filename);
my $fh = $file->open('r') or die $!;
my $line = <$fh>;
print $line;
while(<$fh>){
    next if($_ eq "");
    chomp;
    my @clm = split(/\t/, $_);
    my $ncol = $#clm+1;
#    print "$ncol\n";
    my $on = 1;
    for(my $i=1; $i<$ncol; $i++){
	$on = 0 if($clm[$i]<$thre);
#	print "$clm[$i]\n";
    }
    print "$_\n" if($on);
    
}
$fh->close;
