##################################################
# For example to get mappability
# file chromosome 6 at every bp and up to
# genomic coord 2000, type
# python cal_map_score.py 6 1 2000> outfile.txt
##################################################

#!/usr/bin/env python

import CountMap
import sys

window_size = int(sys.argv[2])
max_coord = int(sys.argv[3])

#chr = str(sys.argv[1])
#nicechr = "chr" + chr

filename = str(sys.argv[1]) #"chr" + chr + "b.out"
cm=CountMap.CountMap(filename)

count  = 0
for j in xrange(1,max_coord):

	try:
		x = cm.cnt(j)
		flag = 0
	except ValueError:
		flag = 1
	if flag == 0:
		if x == 1:
			count += 1

	if (j % window_size) == 0:
		window = int (j / window_size) - 1
		#outstring = nicechr + "\t" + str(window*window_size) + "\t" + str(count)
		outstring =  str(count)
		print outstring,
		count = 0
