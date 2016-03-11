#! /usr/bin/perl -w

use Getopt::Long;

$chrsort=0;
GetOptions('sort' => \$chrsort);

$linenum=$ARGV[1];
$num=0;

open(IN, $ARGV[0]) || die "cannot open $ARGV[0].";
while($line = <IN>){
    #print $line;
    chomp($line);
    my @clm = split(/\t/, $line);
    $Hash{$num} = $line;
    $chr{$num} = $clm[0];
    $num++;
    last if($num>=$linenum);
}

foreach $num (sort {$chr{$a} cmp $chr{$b}} keys %chr){
    print "$Hash{$num}\n";
}
