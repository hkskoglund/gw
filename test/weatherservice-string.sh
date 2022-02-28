#!/bin/sh

if [ -z "$1" ]; then
  echo >&2 no host ip specified, exiting
  exit 2
fi


TESTSTRING_40='1234567890123456789012345678901234567890'
TESTSTRING_64=$TESTSTRING_40'123456789012345678901234'
TESTSTRING=${TESTSTRING=$TESTSTRING_40}

printf "All weather services including customized will be overwritten with '%s', proceed (Y):" $TESTSTRING
read -r REPLY
[ "$REPLY" != "Y" ] &&  exit 1

#https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
echo >&2 "Test: string length host: $1, teststring: $TESTSTRING length: ${#TESTSTRING}"
if ./gw -g "$1" -c version; then
    for ws in wc wow wunderground customized; do
        if [ $ws != 'customized' ]; then
                DEBUG_WS_OPTIONS=1 DEBUG_SENDWEATHERSERVICE=1 ./gw -g "$1" -d buffer,strict -c $ws id="$TESTSTRING",pw="$TESTSTRING" -c $ws; 
        else
            DEBUG_CUSTOMIZED=1 ./gw -g "$1" -d buffer,strict -c $ws id="$TESTSTRING",pw="$TESTSTRING",server="$TESTSTRING_64",path_wunderground="$TESTSTRING_64",path_ecowitt="$TESTSTRING_64" -c $ws;
        fi
    done

fi
