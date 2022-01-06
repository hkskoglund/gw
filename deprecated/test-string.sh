#!/usr/bin/bash
n=0
while [ "$n" -lt $(( 1000 )) ]; do
   str=$str'A'
   n=$(( n + 1 ))
done

echo "${#str}"

echo "End test"
read -r A

#watch -n 1 -d 'pmap -p $(pgrep "test-string")
#strace -f bash -c './test-string.sh'

#brk(0x55f7842ce000)                     = 0x55f7842ce000
#brk(0x55f7843ea000)                     =
#brk(0x55f78440b000)                     = 0x55f78440b000
#brk(0x55f78442c000)                     = 0x55f78442c000
#brk(0x55f78444d000)                     = 0x55f78444d000

https://stackoverflow.com/questions/6988487/what-does-the-brk-system-call-do