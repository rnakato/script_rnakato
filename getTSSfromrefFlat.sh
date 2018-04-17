#!/bin/bash

cat $1 | awk '{if($4=="+") print $5; else print $6}'
