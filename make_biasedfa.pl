#!/usr/bin/env perl

die "make_biasedfa.pl <chromosome dir> <chromosome name> <GCdist csv> <fragment length dist csv> <prop>\n" if($#ARGV !=4);

my $tablepath=$ARGV[0];
my $chr=$ARGV[1];
my $csv=$ARGV[2];
my $flenfile=$ARGV[3];
my $p=$ARGV[4];

my $flen4gc=140;
my $readlen=50;
for($i=0;$i<=$flen4gc;$i++) {
    $GCarray[$i]=0;
}

my $max=0;
if($csv eq "uniform") {
    for($i=0;$i<=$flen4gc;$i++) {
	$GCarray[$i]=1;
    }
}else {
    open(IN, $csv) || die "error: cannot open $csv.\n";
    while(<IN>) {
	next if($_ eq "\n" || $_ =~ />/);
	chomp;
	@clm= split(/\t/, $_);
	$GCarray[$clm[0]]=$clm[1];
	$max = $clm[1] if($max < $clm[1]);
    }
    close IN;
}

open(IN, $flenfile) || die "error: cannot open $csv.\n";
my $cump=0;
my $ndist=0;
while(<IN>) {
    next if($_ eq "\n" || $_ =~ />/);
    chomp;
    @clm= split(/\t/, $_);
    $cump += $clm[1];
    $flendist[$ndist][0]=$clm[0];
    $flendist[$ndist][1]=$cump;
    $ndist++;
}
close IN;

$num=0;
$fasta="";
open(IN, "$tablepath/chr$chr.fa") || die "error: cannot open $tablepath/chr$chr.fa.\n";
while(<IN>) {
    next if($_ eq "\n" || $_ =~ />/);
    chomp;
    $fasta .= $_;
}
close IN;

$len = length($fasta);
for($i=0; $i<$len-5-300; $i++){
    my $flen=0;
    my $pflen = rand(1);
    for ($j=0;$j<$ndist;$j++) {
	if($pflen < $flendist[$j][1]){
	    $flen=$flendist[$j][0];
	    last;
	}
    }

    my $flag = substr($fasta, $i, $flen);
    next if($flag =~ /N/);
    my $gc = substr($flag, 5, $flen4gc);
    $gc = $gc =~ s/[GC]//ig;
    $gc = 0 if($gc eq "");
    if(rand($max) < $GCarray[$gc]*$p){
	if(rand(1) < 0.5) {
	    my $read = substr($fasta, $i, $readlen);
	    print ">chr${chr}_$i:+\n$read\n";
	}else {
	    my $read = substr($fasta, $i+$flen-$readlen, $readlen);
	    my $rev = reverse $read =~ tr/AaTtGgCc/TtAaCcGg/r;
	    print ">chr${chr}_$i:-\n$rev\n";
	}
	$num++;
    }
}
