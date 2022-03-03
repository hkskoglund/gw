#!/bin/sh
#$1 - host
#echo >&2 $0 PID $$
 # source arguments to dash shell
# . | source - run in current shell
# shellcheck disable=SC1091
if [ -z "$1" ]; then
  echo >&2 Error: no host ip
  return 1
fi

#https://github.com/koalaman/shellcheck/wiki/SC2240 The dot command does not support arguments in sh/dash. Set them as variables.
GWOPTIONS="-g $1 -c livedata" . ./gw >/dev/null
EXITCODE_GW=$?
if [ $EXITCODE_GW -ne 0 ]; then
  echo >&2 "Failed livedata $GW_VERSION $GW_HOST, exitcode $EXITCODE_GW"
  return 2
fi

GWEXPORTSHOW=${GWEXPORTSHOW:=0}
if [ $GWEXPORTSHOW -eq 1 ] ; then
  export -p | grep -E "LIVEDATA_"
fi

# oneliner
printf "in %s %u out %s %u Wind: %s %s speed %s gust %s %s %u Pressure: %s abs %s Rain: rate %s %s day %s Solar: light %s uvi %s\n" "$LIVEDATA_INTEMP" "$LIVEDATA_INHUMI" "$LIVEDATA_OUTTEMP" "$LIVEDATA_OUTHUMI"\
 "$LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE" "$LIVEDATA_WINDDIRECTION_COMPASS" "$LIVEDATA_WINDSPEED" "$LIVEDATA_WINDGUSTSPEED" "$LIVEDATA_WINDGUSTSPEED_BEUFORT_DESCRIPTION" "$LIVEDATA_WINDGUSTSPEED_BEUFORT"\
 "$LIVEDATA_PRESSURE_RELBARO" "$LIVEDATA_PRESSURE_ABSBARO"\
 "$LIVEDATA_RAINRATE" "$LIVEDATA_RAINRATE_STATE" "$LIVEDATA_RAINDAY"\
 "$LIVEDATA_SOLAR_LIGHT" "$LIVEDATA_SOLAR_UVI"