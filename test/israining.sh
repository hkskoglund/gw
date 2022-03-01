#!/bin/sh
#$1 - host
#echo >&2 $0 PID $$
 # source arguments to dash shell
# . | source - run in current shell
# shellcheck disable=SC1091
GWOPTIONS="-g $1 -c version -c rain -c customized -c livedata" . ./gw >/dev/null
EXITCODE_GW=$?
if [ $EXITCODE_GW -ne 0 ]; then
  echo >&2 "Failed to get rain rate $GW_VERSION $GW_HOST, exitcode $EXITCODE_GW"
  return 2
fi

export -p | grep -E "GW_|LIVEDATA_"

if [ "$GW_RAINRATE" -eq 0 ]; then
    echo No rain
    return 1
else
    echo "Rain $GW_RAINRATE_FLOAT $LIVEDATA_RAIN_UNIT"
    return 0
fi
