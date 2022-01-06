#!/usr/bin/dash

test ()
{
  if [ -n "$1" ] && [ "$1" -eq 1 ]; then
  #shellcheck disable=SC3044
     typeset n 2>/dev/null
else
   local n
fi
  n=10
}

test2 ()
{
    V=1
    if [ "$V" -eq 1 ]; then
        local n
    fi
}

runtest ()
{
N=0
while [ "$N" -lt 100000 ]; do
  N=$(( N + 1 ))
  "$1" "$2"
done
}


runtest "$1" "$2"

