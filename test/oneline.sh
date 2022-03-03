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

GWOPTIONS="-g $1 -c livedata" . ./gw 
EXITCODE_GW=$?
if [ $EXITCODE_GW -ne 0 ]; then
  echo >&2 "Failed livedata $GW_VERSION $GW_HOST, exitcode $EXITCODE_GW"
  return 2
fi

export -p | grep -E "LIVEDATA_"

# oneliner
printf "Ｔ: %s %u %s %u Ｗ: %s %s %s %s Ｐ: %s %s Ｒ: %s %s %s %s Ｓ: %s %s\n" "$LIVEDATA_INTEMP" "$LIVEDATA_INHUMI" "$LIVEDATA_OUTTEMP" "$LIVEDATA_OUTHUMI"\
 "$LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE" "$LIVEDATA_WINDDIRECTION_COMPASS" "$LIVEDATA_WINDSPEED" "$LIVEDATA_WINDGUSTSPEED"\
 "$LIVEDATA_PRESSURE_RELBARO" "$LIVEDATA_PRESSURE_ABSBARO"\
 "$LIVEDATA_RAINRATE" "$LIVEDATA_RAINRATE_STATE" "$LIVEDATA_RAINDAY" "$LIVEDATA_RAINEVENT"\
 "$LIVEDATA_SOLAR_LIGHT" "$LIVEDATA_SOLAR_UVI"