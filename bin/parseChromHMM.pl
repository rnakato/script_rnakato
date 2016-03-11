#!/usr/bin/perl -w

open(FILE, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
while(<FILE>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    my $emission = $clm[3];
    if(!exists($Hash{$emission})){
	if(-e "$ARGV[0].$emission.bed") {
	    print "ERROR: $ARGV[0].$emission.bed exists.\n";
	    exit;
	}
	$Hash{$emission} = 1;
    }
    open(OUT, ">>$ARGV[0].$emission.bed") ||die "error: can't open $ARGV[0].emission.bed.\n";
    print OUT "$_\n";
    close(OUT);
}
close(FILE);
