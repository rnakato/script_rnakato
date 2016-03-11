#!/usr/bin/perl -w

use Getopt::Long;
$samfile=0; $bowtiefile=0;
GetOptions('sam' => \$samfile, 'bowtie' => \$bowtiefile);

if(@ARGV != 4){
    print "GCcount4fragment.pl <mapfile> <genome> <fragment length> <read length> (-sam/-bowtie)\n";
    exit;
}
if(!$samfile && !$bowtiefile){
    print "please specify filetype.\n";
    exit;
}

$mapfile = $ARGV[0];
$genome = $ARGV[1];
$fraglen=$ARGV[2];
$readlen=$ARGV[3];
$fasta="";
$head="";
$len=0;

for($i=0;$i<=$fraglen;$i++){
    $array[$i]=0;
}
$num=0;

open(InputFile,$genome) ||die "error: can't open $genome.\n";
while($line = <InputFile>){
    next if($line eq "\n");
    chomp $line;
    if($line =~ ">"){
	if($len){
	    open(File,$mapfile) ||die "error: can't open $mapfile.\n";
	    while(<File>){
		next if($_ eq "\n");
		chomp;
		my @clm = split(/\t/, $_);
		if($bowtiefile){
		    next if($clm[2] ne "$head");
		    if($clm[1] eq "+"){
			$s = $clm[3];
		    }else{
			$s = $clm[3]+ $readlen - $fraglen;
		    }
		}elsif($samfile){
		    next if($clm[0] =~ "@");
		    next if($clm[2] eq "*" || $clm[2] ne "$head");
		    if($clm[1]&16){
			$s = $clm[3]+ $readlen - $fraglen;
		    }else{
			$s = $clm[3];
		    }
		}
		my $seq = substr($fasta, $s, $fraglen);
		$acgt_count = ($seq =~ tr/acgtACGT/acgtACGT/);
		next if(!$acgt_count);
		$gc_count = ($seq =~ tr/cgCG/cgCG/);
		$array[$gc_count]++;
		$num++;
	    }
	}
	$len=0;
	$fasta="";
	if($' =~ /([A-Za-z0-9_]+)\s(.+)/){ $head = $1;}
	else{ $head = $';}
	next;
    }else{
	chomp($line);
	$len += length($line);
	$fasta .= $line;
    }
} 
close (InputFile);

if($len){
    open(File,$mapfile) ||die "error: can't open $mapfile.\n";
    while(<File>){
	next if($_ eq "\n");
	chomp;
	my @clm = split(/\t/, $_);
	if($bowtiefile){
	    next if($clm[2] ne "$head");
	    if($clm[1] eq "+"){
		$s = $clm[3];
	    }else{
		$s = $clm[3]+ $readlen - $fraglen;
	    }
	}elsif($samfile){
	    next if($clm[0] =~ "@");
	    next if($clm[2] eq "*" || $clm[2] ne "$head");
	    if($clm[1]&16){
		$s = $clm[3]+ $readlen - $fraglen;
	    }else{
		$s = $clm[3];
	    }
	}
	my $seq = substr($fasta, $s, $fraglen);
	$acgt_count = ($seq =~ tr/acgtACGT/acgtACGT/);
	next if(!$acgt_count);
	$gc_count = ($seq =~ tr/cgCG/cgCG/);
	$array[$gc_count]++;
	$num++;
    }
}

for($i=0;$i<=$fraglen;$i++){
    printf("%d\t%f\n",$i,$array[$i]/$num);
}
