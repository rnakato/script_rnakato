#!/usr/bin/perl -w

use Getopt::Long;

$IPfile=$ARGV[0];
$WCEfile=$ARGV[1];

open(File, $IPfile) ||die "error: can't open file.\n";
$line = <File>;
chomp($line);
if($line =~ /#num: (.+) uniq: (.+)/){ $IPtagall=$2;}
while($line = <File>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    $Hash_tag_IP{$clm[0]} = $clm[1];
}
close (File);

open(File, $WCEfile) ||die "error: can't open file.\n";
$line = <File>;
chomp($line);
if($line =~ /#num: (.+) uniq: (.+)/){ $WCEtagall=$2;}
while($line = <File>){
    next if($line eq "\n");
    chomp($line);
    my @clm = split(/\t/, $line);
    $Hash_tag_WCE{$clm[0]} = $clm[1];
}
close (File);

$ratio=$IPtagall/$WCEtagall;
print "IPtags: $IPtagall\tWCEtags: $WCEtagall\tIP/WCE=$ratio\n";
print "name\tIP tags\tWCE tags\tEnrichment\n";
foreach $name (sort{$a cmp $b} keys(%Hash_tag_IP)){
    $Hash_tag_IP{$name}=0 if(!exists($Hash_tag_IP{$name}));
    $Hash_tag_WCE{$name}=0 if(!exists($Hash_tag_WCE{$name}));
    if($Hash_tag_WCE{$name}){$enrich = $Hash_tag_IP{$name}/($Hash_tag_WCE{$name}*$ratio);}else{$enrich =0;}
    printf("%s\t%.1f\t%.1f\t%.2f\n", $name, $Hash_tag_IP{$name}, $Hash_tag_WCE{$name}, $enrich);
}
