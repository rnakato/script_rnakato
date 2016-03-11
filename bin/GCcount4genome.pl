#!/usr/bin/perl -w

$filename = $ARGV[0];
$kmer=$ARGV[1];
$fasta="";
$head="";
$len=0;
$step=$ARGV[2];
if(@ARGV != 3){
    print "GCcount4genome.pl <genome> <fragment length> <stepsize>\n";
    exit;
}

for($i=0;$i<=$kmer;$i++){
    $array[$i]=0;
}
$num=0;

open(InputFile,$filename) ||die "error: can't open $filename.\n";
while($line = <InputFile>){
    next if($line eq "\n");
    chomp $line;
    if($line =~ ">"){
	if($len){
	    my $l = $len - $kmer +1;
	    for($i=0;$i<$l-$kmer;$i+=$step){
		my $seq = substr($fasta, $i, $kmer);
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
    my $l = $len - $kmer +1;
    for($i=0;$i<$l-$kmer;$i+=$step){
	my $seq = substr($fasta, $i, $kmer);
	$acgt_count = ($seq =~ tr/acgtACGT/acgtACGT/);
	next if(!$acgt_count);
	$gc_count = ($seq =~ tr/cgCG/cgCG/);
	$array[$gc_count]++;
	$num++;
    }
}
for($i=0;$i<=$kmer;$i++){
    printf("%d\t%f\n",$i,$array[$i]/$num);
}
