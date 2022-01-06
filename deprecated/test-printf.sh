#!/usr/bin/dash

n=0
f="99.34"
while [ "$n" -lt 1000 ]; do
    printf "%-40s %7.1f %s\n" "testing" "$f" "%" 1>/dev/null
   #echo "testing $f %"
   n=$(( n + 1))
done
