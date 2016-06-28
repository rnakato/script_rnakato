#!/usr/bin/env perl

use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;

my $mpfile="";
my $width="";
my $mpthre=0.8;
my $binsize="";
my $chr="";
my $p=0.001;

GetOptions('mappability|m=s' => \$mpfile, 'chr|c=s' => \$chr, 'width|w=s' => \$width, 'size|s=s' => \$binsize);

if($mpfile eq "" || $chr eq "" || $binsize eq ""|| $width eq ""){
    print "    make_randombed.pl: make random bed.\n\n";
    print "    Usage: make_randombed.pl -m <mappability file> -c <chr> -n <number> -w <peak width> -s <binsize>\n\n";
    exit;
}

open(IN, $mpfile) || die "error: cannot open $mpfile.\n";
while(<IN>) {
    next if($_ eq "\n" || $_ =~ />/);
    chomp;
    @clm= split(/\t/, $_);
    if($clm[1]>=$mpthre && rand(1) < $p) {
	my $summit = $clm[0] + rand(binsize-1-$width) + $width/2;
	my $s = int($summit - $width/2);
	my $e = int($summit + $width/2);
	print "$chr\t$s\t$e\n";
    }
}
close IN;
