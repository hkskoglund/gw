#!/usr/bin/bash
interval=2
if [ "$1" = "-n" ]; then # allow -n {interval} at start 
  interval=$2
  shift 2
fi
hostname=$(hostname)
#https://stackoverflow.com/questions/37774983/clearing-the-screen-by-printing-a-character
#\033 -> \e in printf
printf "%b" '\e[2J\e[H' #clear screen
while true && [ -n "$*" ]; do
   printf "%b\n\n" "\e[1;1HEvery $interval s:$*\e[1;75H$hostname: $(date)"
   "$@"
   sleep "$interval" 
done

