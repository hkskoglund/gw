#!/usr/bin/dash
export unicode="🔋"
for sh in mksh ksh dash bash zsh; do 
   printf "%s\n%s\n" "-------------------" "$sh"
   $sh -c 'type printf'
   $sh -c 'lunicode=${#unicode}; printf "%2s %d\n" "$unicode" "$lunicode"'
   $sh -c 'printf "%2s" "$unicode" | od -A n -t x1'
done