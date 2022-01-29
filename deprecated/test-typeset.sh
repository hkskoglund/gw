#!/bin/sh


 initShell ()
{
        #shellcheck disable=2050
  if [[ a =~ a ]] 2>/dev/null; then
   SHELL_SUPPORT_TILDE_REGEX=1
  else
   SHELL_SUPPORT_TILDE_REGEX=0
  fi

  if typeset  1>/dev/null 2>&1; then
    SHELL_SUPPORT_TYPESET=1
  else
    SHELL_SUPPORT_TYPESET=0
  fi

}

test ()
{
    A=1

    if [ "$A" -eq 1 ]; then
       typeset N || local N
       N=10
       echo $N inside if
    fi

    echo $N outside if
}

test
echo $N in main
