find . -name "*.txt" | parallel mv "{} {}.bak"
seq 1 254 | parallel "ping -q -c1 -w 0.5 192.168.0.{}" | grep -B3 rtt
cat test.log | parallel --pipe -L 1000 -k grep "string"
cat data.csv | parallel -k --colsep "," echo "{1} + {2}" | bc
