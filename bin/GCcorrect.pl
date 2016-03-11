#!/usr/bin/perl -w

$fasta=$ARGV[0];
$mapfile=$ARGV[1];
$mpbl=$ARGV[2];
$len_frag=$ARGV[3];
$bin=$ARGV[4];

$head="";
open(ListFile, $fasta) ||die "cannot open $fasta";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    if($_ =~ />/){
	$head=$';  #'
	next;
    }
    $seq .= $_;
}
close (ListFile);

open(ListFile, $mapfile) ||die "cannot open $mapfile";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    @clm= split(/\t/, $_);
    next if($clm[2] ne $head);
    my $readlen=length($clm[4]);
    if($clm[1] eq "+"){
	$s = $clm[3];
    }else{
	$s = $clm[3] + $readlen - $len_frag;
    }
    if(exists($Hash{$s})){
	$Hash{$s}++;
    }else{
	$Hash{$s}=1;
    }
}
close (ListFile);

$hashnum = scalar(keys(%Hash));
$num=0;
$med=int($hashnum/2);
$q99=int($med* 1.99);
$quant99=0;
foreach my $key (sort {$Hash{$a} <=> $Hash{$b}} keys %Hash){
    $num++;
    if($num==$q99){
	$quant99=$Hash{$key};
    }
}

for($i=0;$i<249250621;$i++){
    $mp[$i]=0;
}

$mpbllen=0;
open(ListFile, $mpbl) ||die "cannot open $mpbl";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    @clm= split(/\t/, $_);
    next if($clm[0] ne $head);
    for($i=$clm[1];$i<=$clm[2];$i++){
	$mp[$i]=1;
    }
    $mpbllen += $clm[2] -$clm[1] +1;
}
close (ListFile);

for($i=0;$i<=$len_frag;$i++){
    $n[$i]=0; $f[$i]=0;
}

$p = 10000000/$mpbllen;

for($i=0;$i<249250621;$i++){
    if($mp[$i]){
	$x = rand();
	if($x < $p){
	    next if(exists($Hash{$i}) && $Hash{$i} >$quant99);
	    $subseq = substr($seq, $i, $len_frag);
	    $gc_count = ($subseq =~ tr/cgCG/cgCG/);
	    $n[$gc_count]++;
	    if(exists($Hash{$i})){$f[$gc_count] += $Hash{$i};}
	}
    }
}

$readnum=0;
for($i=0;$i<=$len_frag;$i++){
    $readnum += $f[$i];
}
for($i=0;$i<=$len_frag;$i++){
    if($n[$i]){$r=$f[$i]/$n[$i];}else{$r=0;}
#    printf("%d\t%d\t%d\t%f\t%f\n", $i, $n[$i], $f[$i], $r, $r*$readnum);
#    $rn[$i] = $r*$readnum;
    $rn[$i] = $r;
}

$len = length($seq);
$nbin = int($len/$bin) +1;

for($i=0;$i<$nbin;$i++){
    $mbpl_bin[$i]=0;
    $num_est[$i]=0;
    $num_obs[$i]=0;
    my $subseq = substr($seq, $i*$bin, $bin);
    $gc[$i] = ($subseq =~ tr/cgCG/cgCG/);
}
for($i=0;$i<249250621;$i++){
    $mbpl_bin[int($i/$bin)]++ if($mp[$i]);
}
for($i=0;$i<$nbin;$i++){
    $mbpl_bin[$i] /= $bin;
}

for($i=0;$i<249250621-$len_frag;$i++){
    if($mp[$i]){
	next if(exists($Hash{$i}) && $Hash{$i} >$quant99);
	my $subseq = substr($seq, $i, $len_frag);
	my $gc_count = ($subseq =~ tr/cgCG/cgCG/);
	$num_est[$i/$bin] += $rn[$gc_count];
	if(exists($Hash{$i})){
	    $num_obs[$i/$bin] += $Hash{$i};
	}
    }
}

@sortedarray = sort { $a <=> $b } @num_obs; 
$med = $sortedarray[int($nbin/2)];

for($i=0;$i<$nbin;$i++){
    next if($mbpl_bin[$i]<0.5);
    printf("%d\t%d\t%d\t%f\t%f\t%f\n", $i, $gc[$i], $num_obs[$i], $num_est[$i], $num_obs[$i]/$num_est[$i], $med*$num_obs[$i]/$num_est[$i]);
}
