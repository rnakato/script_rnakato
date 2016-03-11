#! /usr/bin/perl

$filename=$ARGV[0];
$refline=$ARGV[1];
$obsline=$ARGV[2];
$logratioTrim=0.3;    # log値（M）のtrimする割合
$sumTrim=0.05;        # 絶対値（A）のtrimする割合

open(IN, $filename) || die;
$line = <IN>;
chomp $line;
@clm= split(/\t/, $line);
for($i=0; $i<=$#clm; $i++){
    $name[$i] = $clm[$i];
}

$genenum_all=0;
@ref=(); @obs=();
while(<IN>) {
    chomp;
    my @clm= split(/\t/, $_);
    push (@ref, {tag => $clm[$refline], name => $clm[0]});
    push (@obs, {tag => $clm[$obsline], name => $clm[0]});
    $genenum_all++;
}
close IN;

($val, $logval) = &calcNormFactor(\@ref, \@obs, $genenum_all);
print "$name[$refline]-$name[$obsline]\t$val\t$logval\n";
#print "$val\t";

sub calcNormFactor{
    my ($ref_ref, $ref_obs, $genenum_all) = @_;
    my $diff=0;
    my $tags_ref=0; 
    my $tags_obs=0;
    for($i=0; $i<$genenum_all; $i++){
	$tags_ref += $$ref_ref[$i]->{tag};
	$tags_obs += $$ref_obs[$i]->{tag};
	if($$ref_ref[$i]->{tag} != $$ref_obs[$i]->{tag}){ $diff=1;}
    }
    if(!$tags_ref || !$tags_obs){ die "total read number is zero.\n";}
    
    my $genenum_finite_all=0;
    if(!$diff){      # 全遺伝子のタグ数が同じなら
	$val=1;$logval=0;
	return($val, $logval);
    } 
    for($i=0; $i<$genenum_all; $i++){
	my $tag_r = $$ref_ref[$i]->{tag};
	my $tag_o = $$ref_obs[$i]->{tag};
	if($tag_r !=0 && $tag_o !=0){
	    $M{$$ref_ref[$i]->{name}} = log2(($tag_o/$tags_obs)/($tag_r/$tags_ref));     # read数で正規化した各遺伝子の発現量（のlog）
	    $A{$$ref_ref[$i]->{name}} = log2($tag_o/$tags_obs) + log2($tag_r/$tags_ref); # absolute expression (2サンプルの発現量の相乗平均のlog)
	    $w{$$ref_ref[$i]->{name}} = ($tags_obs-$tag_o)/($tags_obs*$tag_o) + ($tags_ref-$tag_r)/($tags_ref*$tag_r); # 補正重み
	    $genenum_finite_all++;
	}
    }
#    print "genenum_all = $genenum_all, genenum_finite_all = $genenum_finite_all\n";
	
    $num_min_M = int($genenum_finite_all * $logratioTrim +1);
    $num_max_M = $genenum_finite_all + 1 - $num_min_M;
    $num_min_A = int($genenum_finite_all * $sumTrim +1);
    $num_max_A = $genenum_finite_all + 1 - $num_min_A;
#    print "$num_min_M, $num_max_M, $num_min_A, $num_max_A\n";
    &trimHash(\%M, \%M_med, $num_min_M, $num_max_M);   # Mのtrim後の集合をM_medに格納
    &trimHash(\%A, \%A_med, $num_min_A, $num_max_A);
    
    $sum_numer=0; $sum_denom=0;
    foreach $id (keys %M_med){
	if(exists($A_med{$id}) && $w{$id}){
	    $sum_numer += $M_med{$id}/$w{$id};
	    $sum_denom += 1/$w{$id};
	}
    }
    $logval = $sum_numer/$sum_denom;
    $val = 2 ** ($sum_numer/$sum_denom);
    return($val, $logval);
}

sub trimHash{
    my ($ref_Hash, $ref_Hash_trim, $num_min, $num_max) = @_;
    my $num=0;
    foreach $id (sort {$$ref_Hash{$a} <=> $$ref_Hash{$b}} keys %{$ref_Hash}){
	$num++;
	if($num<$num_min){}
	elsif($num<=$num_max+1){ $$ref_Hash_trim{$id}=$$ref_Hash{$id};}
	else{ return;}
    }
}

sub log2{
    my $x = shift;
    return log($x)/log(2);
}

