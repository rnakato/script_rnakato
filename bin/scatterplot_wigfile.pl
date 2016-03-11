#! /usr/bin/perl

use Getopt::Long;
$log=0;
$showwig=0;
GetOptions('log' => \$log, 'showwig' => \$showwig);

die "scatterplot_wigfile.pl <wigfile1> <wigfile2> <binsize> <chromosome length> <threshold>\n" if($#ARGV !=4);

$thre=0;
$file_a=$ARGV[0];
$file_b=$ARGV[1];
$binsize=$ARGV[2];
$length=$ARGV[3];
$thre=$ARGV[4];

$nbin=int($length/$binsize)+1;

for($i=0; $i<$nbin; $i++){
    $array_a_ref[$i]=0;
    $array_b_ref[$i]=0;
}

# expression file
&readfile($file_a, \@array_a_ref);
&readfile($file_b, \@array_b_ref);

@sortarray = sort {$a <=> $b} (@array_a_ref, @array_b_ref);

$q99 = $sortarray[$nbin*2*0.99];
#print "$q99\n";

for($i=0; $i<$nbin*2; $i++){
#    print "$sortarray[$i]\n"
}
$num=0;
for($i=0; $i<$nbin; $i++){
    if($array_a_ref[$i]>$thre && $array_b_ref[$i]>$thre && $array_a_ref[$i]<$q99 && $array_b_ref[$i]<$q99){
	if($log){
	    $array_a[$num] = log($array_a_ref[$i]);
	    $array_b[$num] = log($array_b_ref[$i]);
	}else{
	    $array_a[$num] = $array_a_ref[$i];
	    $array_b[$num] = $array_b_ref[$i];
	}
	$num++;
    }
}
$cc = &cor(@array_a, @array_b);

if($showwig){
    for($i=0; $i<$num; $i++){
	print "$array_a[$i]\t$array_b[$i]\n"
    }
}else{
    print "$cc\n";
}

sub readfile{
    my ($file, $ref_array) = @_;
    open(ListFile, $file) ||die "error: can't open $file\n";
    while(<ListFile>){
	next if($_ eq "\n");
	chomp;
	my @clm = split(/\t/, $_);
	$$ref_array[int($clm[0]/$binsize)] = $clm[1];
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
