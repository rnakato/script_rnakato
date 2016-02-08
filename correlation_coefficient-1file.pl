#! /usr/bin/perl
# correlation_coefficient-1file.pl

$file=$ARGV[0];
$line1=$ARGV[1];
$line2=$ARGV[2];

die "correlation_coefficient-1file.pl <file> <line1> <line2>\n" if($#ARGV !=2);

undef @array_a;
undef @array_b;

$n=0;
open(ListFile, $file) ||die "error: can't open $file\n";
while(<ListFile>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\s/, $_);
    $array_a[$n] = $clm[$line1];
    $array_b[$n] = $clm[$line2];
    $n++;
}
close (ListFile);

$cc = &cor(@array_a, @array_b);
print "$cc\n";

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
