#! /usr/bin/perl -w
use POSIX;

$max=0;
open(IN, $ARGV[0]) || die "cannot open file. $ARGV[0]\n";
$num=0;
while(<IN>){
    next if($_ =~"chromosome" || $_ =~"#");
    chomp;
    @clm= split(/\t/, $_);
    my $p=$clm[5];
    $max = $p if($max<$p);
    $array[$num++] = $p;
}
close IN;

for($i=0;$i<100;$i++){
    $cnt[$i]=0;
}

$max=300;
$wid = ceil($max/100);
for($i=0;$i<$num;$i++){
    my $p = $array[$i];
    $cnt[int($p/$wid)]++;
}


for($i=0;$i<99;$i++){
    printf("%d ~ %d\t%d\t%.2f\n", $wid*$i, $wid*($i+1), $cnt[$i], $cnt[$i]*100/$num);
}
 printf("%d ~ \t%d\t%.2f\n", $wid*99, $cnt[$i], $cnt[$i]*100/$num);
