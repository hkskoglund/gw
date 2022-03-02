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

export -p | grep -E "LIVEDATA_"

# oneliner
printf "Ｔ: %s %s Ｗ: %s %s %s %s Ｐ: %s %s Ｒ: %s %s %s %s Ｓ: %s %s\n" "$LIVEDATA_INTEMP" "$LIVEDATA_OUTTEMP"\
 "$LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE" "$LIVEDATA_WINDDIRECTION_COMPASS" "$LIVEDATA_WINDSPEED" "$LIVEDATA_WINDGUSTSPEED"\
 "$LIVEDATA_PRESSURE_RELBARO" "$LIVEDATA_PRESSURE_ABSBARO"\
 "$LIVEDATA_RAINRATE" "$LIVEDATA_RAINRATE_STATE" "$LIVEDATA_RAINDAY" "$LIVEDATA_RAINEVENT"\
 "$LIVEDATA_SOLAR_LIGHT" "$LIVEDATA_SOLAR_UVI"