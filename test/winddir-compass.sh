#!/bin/sh
#$1 - host
#echo >&2 $0 PID $$
 # source arguments to dash shell
# . | source - run in current shell
# shellcheck disable=SC1091
GWOPTIONS="-g $1 -c version -c livedata" . ./gw >/dev/null
EXITCODE_GW=$?
if [ $EXITCODE_GW -ne 0 ]; then
  echo >&2 "Failed livedata $GW_VERSION $GW_HOST, exitcode $EXITCODE_GW"
  return 2
fi

GWEXPORTSHOW=${GWEXPORTSHOW:=0}
if [ $GWEXPORTSHOW -eq 1 ] ; then
  export -p | grep -E "LIVEDATA_"
fi
# compass widget
printf "$LIVEDATA_WINDDIRECTION_COMPASS_N_FMT\tSpeed:\t%6.1f $LIVEDATA_WIND_UNIT\n$LIVEDATA_WINDDIRECTION_COMPASS_WE_FMT\tGust:\t%6.1f $LIVEDATA_WIND_UNIT\n$LIVEDATA_WINDDIRECTION_COMPASS_S_FMT\tMax:\t%6.1f $LIVEDATA_WIND_UNIT\n" "$LIVEDATA_WINDSPEED" "$LIVEDATA_WINDGUSTSPEED" "$LIVEDATA_WINDDAILYMAX"
