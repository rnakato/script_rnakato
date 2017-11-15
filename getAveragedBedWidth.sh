cat $1 | grep -v \# | grep -v chromosome | awk '{ a+= $3-$2;} END {printf "%.1f", a/NR; printf "\n"}'
