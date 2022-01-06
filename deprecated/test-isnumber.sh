#!/bin/bash

function isNumber
{
  #if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ] || [ "${KSH_VERSION:0:7}" = "Version" ]; then
  #     if [[ $1 =~ ^[0-9]+$ ]] ; then
  #       return 0
  #     else
  #       return 1
  #     fi
  #else
        #https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash?page=1&tab=votes#tab-top
        case $1 in
          ''|*[!0-9]*) return 1 ;;
                    *) return 0 ;;
        esac
  #fi
}

N=0
time while [ "$N" -lt 100000 ]; do
  isNumber $RANDOM
  N=$(( N + 1 ))
done