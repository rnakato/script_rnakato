#!/usr/bin/env perl
use strict;
use warnings;
use autodie;
die "GeCKO.extractadapter.pl <fastq> <adapter>\n" if($#ARGV !=1);

my $fastqfile=$ARGV[0];
my $adapter=$ARGV[1];

# read数カウント
my $linenum=0;
open(File, $fastqfile) ||die "error: can't open $fastqfile.\n";
while(<File>){ $linenum++; }
close (File);
$linenum /= 4;  # 4行で1リードのため

# adapterチェック
open(File, $fastqfile) ||die "error: can't open $fastqfile.\n";
my $n=0;
my $adapternum=0;
my $short=0;
my %Hash;
while(my $line = <File>){
    if($n%4 == 1){   # 配列の行
	if($line =~ /(.*)$adapter(.+)/) {  # adapterを含んでいれば
	    if(length($2)>=20){            # 配列長が20bp以上であれば
		$Hash{substr($2, 0, 20)}++; # ハッシュに追加
		$adapternum++;
	    }else{
		$short++;
	    }
	}
    }
    $n++;
}
close (File);

open(OUT, ">$fastqfile.count");   # $fastqfile.countに結果を出力
foreach my $tag (keys(%Hash)){
    print OUT "$tag\t$Hash{$tag}\n";
}
close (OUT);

my $per = $adapternum/$linenum;
my $pshort = $short/$linenum;
print "read\twith adapter\tprop\ttoo short\tprop\n";
print "$linenum\t$adapternum\t$per\t$short\t$pshort\n";
