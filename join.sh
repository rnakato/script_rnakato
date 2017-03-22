#!/bin/bash

join -1 1 -2 1 -a 1 <(sort $1) <(sort $2) | sed -e 's/ /\t/g'| sort -n
