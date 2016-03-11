#!/usr/bin/perl -w

$file_IP=$ARGV[0];
$file_WCE=$ARGV[1];

%Hash_class=();
%Hash_len=();
%Hash_IP=();
%Hash_WCE=();
%Hash_all=();


&readfile(\%Hash_IP, $file_IP);
&readfile(\%Hash_WCE, $file_WCE);

foreach $name (keys(%Hash_all)){
    if(!exists($Hash_IP{$name})){$Hash_IP{$name}=0; }
    if(!exists($Hash_WCE{$name})){$Hash_WCE{$name}=0; }

    if($Hash_WCE{$name}!=0){ 
	$Hash_ratio{$name} = $Hash_IP{$name} / $Hash_WCE{$name};
    }else{
	$Hash_ratio{$name} =0;
    }
}

print "class\tname\tlength\tIP\tWCE\tratio\n";
foreach $name (sort{$Hash_ratio{$b} <=> $Hash_ratio{$a}} keys(%Hash_ratio)){
    printf("%s\t%s\t%d\t%.2f\t%.2f\t%.2f\n", $Hash_class{$name}, $name, $Hash_len{$name}, $Hash_IP{$name}, $Hash_WCE{$name}, $Hash_ratio{$name});
}


sub readfile{
    my ($ref_Hash, $filename) = @_;
    open(File, $filename) ||die "error: can't open file.\n";
    $line = <File>;
    $line = <File>;
    while($line = <File>){
	next if($line eq "\n");
	chomp($line);
	my @clm = split(/\t/, $line);
	$$ref_Hash{$clm[0]} = $clm[4];
	$Hash_class{$clm[0]} = $clm[1];
	$Hash_len{$clm[0]} = $clm[2];
	$Hash_all{$clm[0]} = 1;
    }
    close (File);
}    
