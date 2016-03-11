#!/usr/bin/perl -w

$num=0;
for($i=0; $i<=100; $i++){
    $array[$i]=0;
}

open(File, $ARGV[0]) ||die "error: can't open $ARGV[0].\n";
while(<File>){
    next if($_ eq "\n");
    chomp;
    my @clm = split(/\t/, $_);
    my $per = int($clm[2]*100);
    $array[$per]++;
    $num++;
}
close (File);

for($i=0; $i<=100; $i++){
    printf("%d\t%f\n", $i, $array[$i]/$num);
}
