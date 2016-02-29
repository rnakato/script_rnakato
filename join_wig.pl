#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use Path::Class;
use Statistics::Swoop;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;
use Pod::Usage qw/pod2usage/;

die "join_wig.pl [--binsize <int> --prop] <wigfile1> <wigfile2> [<wigfile3> ... ]\n" if($#ARGV ==-1);

my $binsize=1;
my $prop=0;
GetOptions(
    "binsize|b=i" => \$binsize,
    "prop|p" => \$prop
) or pod2usage(1);

my @wig=();
for(my $i=0;$i<=$#ARGV;$i++){
    push(@wig, $ARGV[$i]);
}

my @array;
my %Hash_all;
foreach my $sample (@wig){
#    print "$sample\n";
    my %Hash;
    &readfile($sample, \%Hash, \%Hash_all);
    push(@array, \%Hash);
}

foreach my $num (keys %Hash_all){
    foreach (@array){
	$_->{$num}=0 if(!exists($_->{$num}));
	$_->{sum} += $_->{$num};
    }
}

foreach my $num (sort {$a <=> $b} keys %Hash_all){
    printf("%d",$num * $binsize);
    foreach (@array){
	if(!$prop){
	    print "\t$_->{$num}";
	}else{
	    printf("\t%.6f",$_->{$num}/$_->{sum});
	}
    }
    print "\n";
}

sub readfile{
    my ($filename, $ref_hash, $ref_hashall) = @_;
    my $file = file($filename);
    my $fh = $file->open('r') or die $!;
    while(<$fh>){
	next if($_ eq "\n" || $_ =~ "variableStep" || $_ =~ "track");
	chomp;
	my @clm = split(/\t/, $_);
	my $n = int($clm[0] / $binsize);
	$$ref_hash{$n} = $$ref_hashall{$n} = $clm[1];
    }
}
