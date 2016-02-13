#! /usr/bin/perl -w

=head1 DESCRIPTION

    calculate ave, min, max, stdv for each line

=head1 SYNOPSIS

    % calc_ave_and_stdv.pl [options] <filename>

    Options:
    --column=<int>
    --ave
    --median
    --var
    --stdv
    --min
    --max
    --sum

=cut

use strict;
use warnings;
use autodie;
use Path::Class;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;
use Statistics::Lite qw(:all);

GetOptions(\my %opt, qw/ave median max min var stdv sum column|c=i/) or pod2usage(1);

my @required_options = qw/column/;
pod2usage(2) if grep {!exists $opt{$_}} @required_options;

my $filename=shift;
pod2usage(2) unless $filename;

my @array=();
my $file = file($filename);
my $fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "");
    chomp;
    my @clm = split(/\t/, $_);
    push (@array, $clm[$opt{column}]);
}
$fh->close;

printf("mean\t%f\n", mean @array) if(exists($opt{ave}));
printf("max\t%f\n",  max @array) if(exists($opt{max}));
printf("min\t%f\n",  min @array) if(exists($opt{min}));
printf("var\t%f\n",  variance @array) if(exists($opt{var}));
printf("stdv\t%f\n", stddev @array) if(exists($opt{stdv}));
printf("sum\t%f\n",  sum @array) if(exists($opt{sum}));
