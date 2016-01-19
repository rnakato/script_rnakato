#!/usr/bin/perl -w

$filename=$ARGV[0];
$max=$ARGV[1];

%Hash_chr=();
%Hash_s=();
%Hash_e=();
%Hash_posi=();
%Hash_flag=();

open(File, $filename) ||die "error: can't open file.\n";
$line = <File>;
$line = <File>;
while($line = <File>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    $Hash_chr{$clm[4]} = $clm[0];
    $Hash_s{$clm[4]} = $clm[1];
    $Hash_e{$clm[4]} = $clm[2];
    $Hash_posi{$clm[4]} = $clm[3];
    $Hash_flag{$clm[4]} = $clm[5];
}
close (File);

$i=0;
foreach $val (sort{$a <=> $b} keys(%Hash_chr)){
    print"$Hash_chr{$val}\t$Hash_s{$val}\t$Hash_e{$val}\t$Hash_posi{$val}\t$val\t$Hash_flag{$val}\n";
    $i++;
    if($i>=$max){ exit; }
}
