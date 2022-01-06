#!/usr/bin/dash

test ()
{
  typeset n 2>/dev/null || local N
  n=10
  echo "$n"
}

time test