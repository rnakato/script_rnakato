#!/usr/bin/perl -w

$fastq=$ARGV[0];

$num=0;
$length=0;
@array=();
@arraynum=();
open(ListFile, $fastq) ||die "error: can't open file.\n";
while($line = <ListFile>){
    next if($line eq "\n");
    if($num%4==3){
	chomp($line);
	$len = length($line);
	if($length < $len){$length=$len; }
	for($i=0; $i<$len; $i++){
	    my $char = substr($line, $i, 1);
	    my $qual = ord($char) -33;
#	    print("$char\t$qual\n");
	    $array[$i] += $qual;
	    $arraynum[$i]++;
   	}
    }
    $num++;
}
close (ListFile);

for($i=0; $i<$length; $i++){
    my $ave = $array[$i]/$arraynum[$i];
    print"$i\t$ave\n";
}
