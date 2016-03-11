#!/usr/bin/gawk -f

BEGIN { FS = "\t";}

{
    if($11<1.5){
	print $1, $11;
    }
}

