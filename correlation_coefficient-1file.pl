#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use Path::Class;
my $filename=$ARGV[0];
my $line1=$ARGV[1];
my $line2=$ARGV[2];

die "correlation_coefficient-1file.pl <file> <line1> <line2>\n" if($#ARGV !=2);

my @array_a = ();
my @array_b = ();

my $n=0;
my $file = file($filename);
my $fh = $file->open('r') or die $!;
while(<$fh>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\s/, $_);
    $array_a[$n] = $clm[$line1];
    $array_b[$n] = $clm[$line2];
    $n++;
}
$fh->close;

my $cc = &cor(@array_a, @array_b);
print "$cc\n";

sub cor{
    my $n=@_;
    my $h=$n/2;
    my @x;
    my @y;
    for(my $i=0; $i<$h; $i++){ $x[$i]=shift(@_);}
    for(my $i=0; $i<$h; $i++){ $y[$i]=shift(@_);}
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
    for(my $i=0; $i<$n; $i++){
	my $p = $_[$i] - $mean;
	$sum += $p*$p;
    }
    my $var = $sum/($n-1);
    return($var);
}

sub cov{
    my $n=@_;
    my $h=$n/2;
    my @x;
    my @y;
    for(my $i=0;$i<$h;$i++){ $x[$i]=shift(@_);}
    for(my $k=0;$k<$h;$k++){ $y[$k]=shift(@_);}
    my $x_bar=&mean(@x); 
    my $y_bar=&mean(@y); 
    my $sum=0;
    for(my $s=0; $s<$h; $s++){ $sum += ($x[$s]-$x_bar)*($y[$s]-$y_bar);}
    my $cov = $sum/($h-1);
    return($cov);
}

sub mean{
    my $sum=0;
    $n=@_;
    for(my $i=0; $i<$n; $i++){ $sum+=$_[$i];}
    my $mean=$sum/$n;
    return($mean);
}
