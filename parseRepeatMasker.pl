#! /usr/bin/perl -w
# parse RepeatMasker.txt downloaded from UCSC genome browser

my $file=$ARGV[0];
my $output=$ARGV[1];
    
open(IN, $file) || die;
my $line = <IN>;
while(<IN>) {
    chomp;
    @clm= split(/\t/, $_);
    open(OUT, ">>${output}_$clm[11].txt") || die;
    print OUT "$_\n";
    close(OUT);
}
close IN;

