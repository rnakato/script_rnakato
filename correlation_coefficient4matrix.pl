#! /usr/bin/perl -w

&readfile($ARGV[0], \%expmatrix, \@name);

foreach $gene (keys(%Hash_geneall)){
    push (@array_a, ${expmatrix->{$name[1]}}{$gene});
    push (@array_b, ${expmatrix->{$name[2]}}{$gene});
}

$cc = &cor(@array_a, @array_b);
print "$name[1]\t$name[2]\t$cc\n";
#print "$cc\n";



sub readfile{
    my ($file, $ref_hash, $ref_name) = @_;
    open(ListFile, $file) ||die "error: can't open $file\n";
    $line = <ListFile>;
    chomp($line);
    my @clm = split(/\t/, $line);
    for($i=1;$i<=$#clm;$i++){
	$$ref_name[$i]=$clm[$i];
    }
    while($line = <ListFile>){
	next if($line eq "\n");
	chomp($line);
	my @clm = split(/\t/, $line);
	for($i=1;$i<=$#clm;$i++){
	    ${$ref_hash->{$$ref_name[$i]}}{$clm[0]} = $clm[$i];
	}
	$Hash_geneall{$clm[0]}=1;
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
