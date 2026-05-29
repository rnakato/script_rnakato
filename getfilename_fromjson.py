#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json

jsonfile = sys.argv[1]
sraid = sys.argv[2]
type = sys.argv[3]

with open(jsonfile) as f:
    dict_f = json.load(f)

title = dict_f[sraid]["title"]
species =  title.split(";")[2]

name = title.split(";")[1]
name = name.split(" ")[2:]
name = "_".join(name)
i, gene, cell = name.split("_")
name = f"{cell}_{gene}_{i}"

#str = dict_f[sraid]["files"]["gcp"][0]['filename']
if type == "name":
#    print(name.replace(" ","_"))
    print(name)
elif type == "species":
    print(species)
