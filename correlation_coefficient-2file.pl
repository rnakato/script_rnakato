#! /usr/bin/perl -w

use strict;
use warnings;
use autodie;

$file_a=$ARGV[0];
$file_b=$ARGV[1];
$genefile=$ARGV[2];
$outfile=$ARGV[3];
$thre=$ARGV[4];

undef @array_a;
undef @array_b;
undef %Hash_gene_a;
undef %Hash_gene_b;
undef %Hash_genetype;

#genefile
open(ListFile, $genefile) ||die "error: can't open $genefile\n";
while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    $Hash_gene_a{$clm[0]} = 0;
    $Hash_gene_b{$clm[0]} = 0;
    $Hash_genetype{$clm[0]} = $clm[2];
}
close (ListFile);


# expression file
&readfile($file_a, \%Hash_gene_a);
&readfile($file_b, \%Hash_gene_b);

foreach $name (keys(%Hash_gene_a)){
    if($Hash_genetype{$name} ne "mRNA"){ next;}
    if(!exist($Hash_gene_b{$name})){ next;}
    push (@array_a, $Hash_gene_a{$name});
    push (@array_b, $Hash_gene_b{$name});
}

$cc = &cor(@array_a, @array_b);
if($file_a =~ /(.+)\.(.+)/){ $name_a=$1; }
if($file_b =~ /(.+)\.(.+)/){ $name_b=$1; }
print "$name_a\t$name_b\t$cc\n";


&output_gnuplot($outfile, \@array_a, \@array_b);
#&output_excel($outfile, \%Hash_gene_a, \%Hash_gene_b);


sub output_excel{
    my ($excel, $ref_a, $ref_b) = @_;
    open(OUT, ">$excel") ||die "error: can't open $excel\n";

    foreach $name (keys(%$ref_a)){
	print OUT "$name\t$$ref_a{$name}\t$$ref_b{$name}\n";
    }
    close (OUT);
}

sub output_gnuplot{
    my ($gnu, $ref_a, $ref_b) = @_;
    open(OUT, ">$gnu") ||die "error: can't open $gnu\n";
    for($i=0; $i<@$ref_a; $i++){
	print OUT "$$ref_a[$i]\t$$ref_b[$i]\n";
    }
    close (OUT);
}


sub readfile{
    my ($file, $ref_hash) = @_;
    open(ListFile, $file) ||die "error: can't open $file\n";
    while($line = <ListFile>){
	next if($line eq "\n");
	chomp($line);
	my @clm = split(/\s/, $line);
#	$$ref_hash{$clm[1]} = $clm[0];   ## tags
	if($clm[4] > $thre){ $$ref_hash{$clm[0]} = $clm[4];}
    }
    close (ListFile);
}

sub cor{
    my $n=@_;
    my $h=$n/2;
    for($i=0; $i<$h; $i++){ $x[$i]=shift(@_);}
    for($i=0; $i<$h; $i++){ $y[$i]=shift(@_);}
    my $x_sd = sqrt(&var(@x));
    my $y_sd = sqrt(&var(@y));
    my $xy_cov = &cov(@x, @y);
    
    my $cor=$xy_cov/($x_sd*$y_sd);
    return($cor);
}

sub var{
    my $mean=&mean(@_);
    my $n=@_;
    my $sum=0;
    for($i=0; $i<$n; $i++){
	$p = $_[$i] - $mean;
	$sum += $p*$p;
    }
    $var = $sum/($n-1);
    return($var);
}

sub cov{
    my $n=@_;
    my $h=$n/2;
    for($i=0;$i<$h;$i++){ $x[$i]=shift(@_);}
    for($k=0;$k<$h;$k++){ $y[$k]=shift(@_);}
    my $x_bar=&mean(@x); 
    my $y_bar=&mean(@y); 
    my $sum=0;
    for($s=0; $s<$h; $s++){ $sum += ($x[$s]-$x_bar)*($y[$s]-$y_bar);}
    $cov = $sum/($h-1);
    return($cov);
}

sub mean{
    my $sum=0;
    $n=@_;
    for($i=0; $i<$n; $i++){ $sum+=$_[$i];}
    $mean=$sum/$n;
    return($mean);
}
