#!/usr/bin/perl -w

$file = $ARGV[0];
$gt = $ARGV[1];
$win=$ARGV[2];
$GC=$ARGV[3];
$mpbl=$ARGV[4];
$uniq=$ARGV[5];

open(File,$gt) ||die "error: can't open $gt.\n";
while(<File>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    $length{$clm[0]} = $clm[1];
} 
close (File);

foreach $chr (keys(%length)){
    open(File, $mpbl) ||die "error: can't open $mpbl.\n";
    while(<File>){
	next if($_ eq "\n");
	chomp;
	my @clm = split(/\t/, $_);
	$mpbl{$clm[0]} = $clm[1];
    }
    close (File);
    open(ListFile, "${file}_$chr.$win.wig") ||die "error: can't open ${file}_$chr.$win.wig\n";
    my $line=<ListFile>;
    $line=<ListFile>;
    while(<ListFile>){
	next if($_ eq "\n");
	chomp;
	my @clm = split(/\t/, $_);
	$wig{$clm[0]-1} = $clm[1];
    }
    my $num=0;
    foreach $key (sort{$wig{$a} <=> $wig{$b}}(keys %wig)){
	$sortwig[$num++] = $wig{$key};
    }
    my $upper = $sortwig[int($num * 0.9)];

    close (ListFile);
    open(ListFile, "$GC/$chr-bs$win") ||die "error: can't open $GC/$chr-bs$win\n";
    while(<ListFile>){
	next if($_ eq "\n");
	chomp;
	my @clm = split(/\t/, $_);
	next if(!exists($wig{$clm[0]}) || $wig{$clm[0]}==0 || $wig{$clm[0]} >= $upper);
	next if(!exists($mpbl{$clm[0]}) || $mpbl{$clm[0]} < $uniq);
	print "$clm[1]\t$wig{$clm[0]}\t$chr\n";
    }
}
