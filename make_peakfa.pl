#!/usr/bin/env perl

use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;

my $tablepath="";
my $chr="";
my $csv="";
my $flenfile="";
my $p="";
my $bed="";

GetOptions('tablepath|t=s' => \$tablepath, 'chr|c=s' => \$chr, 'csv|v=s' => \$csv, 'flenfile|f=s' => \$flenfile, 'p|p=s' => \$p, 'bed|b=s' => \$bed);

print "$tablepath\n";
print "$chr\n";
print "$csv\n";
print "$flenfile\n";
print "$p\n";

if($tablepath eq "" || $chr eq ""|| $csv eq ""|| $flenfile eq ""|| $p eq ""|| $bed eq ""){
    print "    make_biasedfa.pl: make random reads for fasta format.\n\n";
    print "    Usage: make_biasedfa.pl -t <chromosome dir> -c <chromosome name> -v <GCdist csv> -f <fragment length dist csv> -p <prop> -b <bed>\n\n";
    exit;
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

$num=0;
$fasta="";
open(IN, "$tablepath/chr$chr.fa") || die "error: cannot open $tablepath/chr$chr.fa.\n";
while(<IN>) {
    next if($_ eq "\n" || $_ =~ />/);
    chomp;
    $fasta .= $_;
}
close IN;

if($bed ne "") {
    open(IN, $bed) || die "error: cannot open $csv.\n";
    while(<IN>) {
	next if($_ eq "\n" || $_ =~ /#/);
	chomp;
	@clm= split(/\t/, $_);
	my $s = $clm[1]-500;
	my $e = $clm[2]+500;
	
	for(my $i=$s; $i<$e; $i++) {
	    my $flen=0;
	    my $pflen = rand(1);
	    for ($j=0;$j<$ndist;$j++) {
		if($pflen < $flendist[$j][1]){
		    $flen=$flendist[$j][0];
		    last;
		}
	    }
	    next if($i+$flen < $s && $i-$flen > $e);
	    
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

    }
    close IN;
}
