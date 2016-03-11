#!/usr/bin/perl -w

use Getopt::Long;
$full=0;
GetOptions('full' => \$full);

$BEDfile=$ARGV[0];
$RNAref=$ARGV[1];

die "parseUCSCBed.pl <BED file> <RNAlist.txt>\n" if($#ARGV !=1);

open(ListFile, $RNAref) ||die "error: can't open file.\n";
while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    my $id = $clm[0];
    $desc{$id} = $clm[1];
    $RNAlen{$id} = $clm[2];
    $type{$id} = $clm[3];
    $name{$id} = $clm[4];
}
close (ListFile);

%gene_s_all = ();
%gene_e_all = ();
%gene_chr_all = ();

open(ListFile, $BEDfile) ||die "error: can't open $BEDfile.\n";
while($line = <ListFile>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    next if(!&checkchr($clm[0]));

    my $on=0;
    my %exon_s = ();
    my %exon_e = ();
    my $id = $clm[3];

    # gene名が同じでstartとendのposiも同じものはスキップ（--fullが指定されていない場合）
    if(!$full && exists($name{$id})){
	if(!exists($gene_chr_all{$name{$id}})){
	    push(@{$gene_chr_all{$name{$id}}}, $clm[0]);
	    push(@{$gene_s_all{$name{$id}}}, $clm[1]);
	    push(@{$gene_e_all{$name{$id}}}, $clm[2]);
	}else{
	    for($i=0; $i<=$#{$gene_chr_all{$name{$id}}}; $i++){
		if($gene_chr_all{$name{$id}}[$i] eq $clm[0] 
		   && abs($gene_s_all{$name{$id}}[$i] - $clm[1]) < 2000
		   && abs($gene_e_all{$name{$id}}[$i] - $clm[2]) < 2000){
		    $on=1;
		    last;
		}
	    }
	    if(!$on){
		push(@{$gene_chr_all{$name{$id}}}, $clm[0]);
		push(@{$gene_s_all{$name{$id}}}, $clm[1]);
		push(@{$gene_e_all{$name{$id}}}, $clm[2]);	    
	    }
	}
	next if($on);
    }

    $chr{$id} = $clm[0];
    $gene_s{$id} = $clm[1];
    $gene_e{$id} = $clm[2];
    $strand{$id} = $clm[5];
#    $cdn_s{$id} = $clm[6];
#    $cdn_e{$id} = $clm[7];
    $exon_num{$id} = $clm[9];

    my @elen = split(/,/, $clm[10]);
    my @es = split(/,/, $clm[11]);
    die "$#elen, $#es, $exon_num{$id}\n" if($#elen+1 != $exon_num{$id} || $#es+1 != $exon_num{$id});
    for($i=0; $i<$exon_num{$id}; $i++){
	push(@{$exon_s{$id}}, $gene_s{$id} + $es[$i]);
	push(@{$exon_e{$id}}, $gene_s{$id} + $es[$i] + $elen[$i]);
    }

    if(!exists($desc{$id})){
	$desc{$id} = "";
	$RNAlen{$id} = "";
	$type{$id} = "";
	$name{$id} = "";
    }
    print "$name{$id}\t$type{$id}\t$strand{$id}\t$gene_s{$id}\t$gene_e{$id}\t$chr{$id}\t$desc{$id}\t", $exon_num{$id}. "\t";
    foreach $posi (@{$exon_s{$id}}){ print "$posi,"; }
    print "\t";
    foreach $posi (@{$exon_e{$id}}){ print "$posi,"; }
    print "\t$id\n";
}
close (ListFile);

sub checkchr{
    my ($chr) = @_;
    my $flag=0;
    if($chr eq "chr1"){ $flag=1;}
    if($chr eq "chr2"){ $flag=1;}
    if($chr eq "chr3"){ $flag=1;}
    if($chr eq "chr4"){ $flag=1;}
    if($chr eq "chr5"){ $flag=1;}
    if($chr eq "chr6"){ $flag=1;}
    if($chr eq "chr7"){ $flag=1;}
    if($chr eq "chr8"){ $flag=1;}
    if($chr eq "chr9"){ $flag=1;}
    if($chr eq "chr10"){ $flag=1;}
    if($chr eq "chr11"){ $flag=1;}
    if($chr eq "chr12"){ $flag=1;}
    if($chr eq "chr13"){ $flag=1;}
    if($chr eq "chr14"){ $flag=1;}
    if($chr eq "chr15"){ $flag=1;}
    if($chr eq "chr16"){ $flag=1;}
    if($chr eq "chr17"){ $flag=1;}
    if($chr eq "chr18"){ $flag=1;}
    if($chr eq "chr19"){ $flag=1;}
    if($chr eq "chr20"){ $flag=1;}
    if($chr eq "chr21"){ $flag=1;}
    if($chr eq "chr22"){ $flag=1;}
    if($chr eq "chrX"){ $flag=1;}
    if($chr eq "chrY"){ $flag=1;}
    if($chr eq "chrMT"){ $flag=1;}
    return $flag;
}
