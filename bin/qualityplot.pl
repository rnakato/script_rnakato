#!/usr/bin/perl -w

$num_elem=@ARGV;

@color=( "red", "blue", "tan1", "darkviolet", "black", "forestgreen", "plum", "orchid", "coral4", "lightseagreen", "mediumturquoise", "lawngreen");

for($i=0; $i<$num_elem; $i++){
    my @c = split(/\./, $ARGV[$i]);
    $name[$i] = $c[0];
}

for($i=0; $i<$num_elem; $i++){
    printf("data%d <- read.table(\"$ARGV[$i]\", header=T, row.names=1, sep=\"\\t\", quote=\"\")\n", $i+1);
    printf("D%d <- as.matrix(data%d)\n",$i+1,$i+1);
}

print "pdf(\"qualityplot.pdf\")\n";

for($i=0; $i<$num_elem; $i++){
    if($i==0){
	printf("plot(data%d[,1], type=\"l\", ylim=c(20,30), col=c(\"%s\"),main=\"average qualty of reads\", xlab=\"\", ylab=\"\")\n",$i+1, $color[$i]);
	print "par(new=T)\n";
    }elsif($i==$num_elem-1){
	printf("plot(data%d[,1], type=\"l\", ylim=c(20,30), col=c(\"%s\"), xlab=\"read position\", ylab=\"qual\")\n",$i+1, $color[$i]);
    }else{
	printf("plot(data%d[,1], type=\"l\", ylim=c(20,30), col=c(\"%s\"), xlab=\"\", ylab=\"\")\n",$i+1, $color[$i]);
	print "par(new=T)\n";
    }
}

print "legend(\"bottomleft\",c(\"";
for($i=0; $i<$num_elem; $i++){
    printf("%s\"", $name[$i]);
    if($i==$num_elem-1){
	print "),lty=c(";
    }else{
	print ", \"";
    }
}
for($i=0; $i<$num_elem; $i++){
    print "1,";
}
print "1),col=c(\"";
for($i=0; $i<$num_elem; $i++){
    printf("%s\"", $color[$i]);
    if($i==$num_elem-1){
	print "), lwd=1.5)\n";
    }else{
	print ",\"";
    }
}

print "dev.off()\n";
