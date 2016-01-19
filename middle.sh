#!/bin/bash
head -n $3 $1 | tail -n $(($3 - $2 + 1))
