#!/bin/sh
# $1 host
# $2 format (text)
#echo >&2 $0 PID $$
 # source arguments to dash shell
# . | source - run in current shell
# shellcheck disable=SC1091
#echo "start args $*"
if [ -z "$1" ]; then
  echo >&2 Error: no host ip
  if return 1 2>/dev/null; then
    :
  else
    exit 1
  fi
fi

ONELINE_FORMAT=$2

#https://github.com/koalaman/shellcheck/wiki/SC2240 The dot command does not support arguments in sh/dash. Set them as variables.
GWOPTIONS=" -g $1 -c livedata" . ./gw >/dev/null
EXITCODE_GW=$?
if [ $EXITCODE_GW -ne 0 ]; then
  echo >&2 "Failed livedata $GW_VERSION $GW_HOST, exitcode $EXITCODE_GW"
  return 2
fi

GWEXPORTSHOW=${GWEXPORTSHOW:=0}
if [ $GWEXPORTSHOW -eq 1 ] ; then
  export -p 
fi

# oneliner

case "$ONELINE_FORMAT" in
  text) 
     toLowercase "$LIVEDATA_WINDGUSTSPEED_BEUFORT_DESCRIPTION"
     beufort_wingustspeed_description="$VALUE_LOWERCASE"
     toLowercase "$LIVEDATA_RAINRATE_STATE_DESCRIPTION"
     rainrate_state_description="$VALUE_LOWERCASE"
     printf "%s %s %s %s %s %s %s %s %s %s %s\n" "$LIVEDATA_OUTTEMP" "$LIVEDATAUNIT_TEMP" "$LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE" "$LIVEDATA_WINDDIRECTION_COMPASS" "$LIVEDATA_WINDGUSTSPEED" "$LIVEDATAUNIT_WIND" "$beufort_wingustspeed_description"\
    "$LIVEDATA_RAINRATE" "$LIVEDATAUNIT_RAINRATE" "$LIVEDATA_RAINRATE_STATE" "$rainrate_state_description" 

  ;;
  *)
    printf "in %s %u out %s %u ${STYLE_BOLD}Wind:$STYLE_RESET %s %s speed %s gust %s %s %u ${STYLE_BOLD}Pressure:$STYLE_RESET %s abs %s ${STYLE_BOLD}Rain:$STYLE_RESET rate %s %s %s day %s ${STYLE_BOLD}Solar:$STYLE_RESET %s uvi $LIVEDATASTYLE_SOLAR_UVI%s$STYLE_RESET %s\n" "$LIVEDATA_INTEMP" "$LIVEDATA_INHUMI" "$LIVEDATA_OUTTEMP" "$LIVEDATA_OUTHUMI"\
    "$LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE" "$LIVEDATA_WINDDIRECTION_COMPASS" "$LIVEDATA_WINDSPEED" "$LIVEDATA_WINDGUSTSPEED" "$LIVEDATA_WINDGUSTSPEED_BEUFORT_DESCRIPTION" "$LIVEDATA_WINDGUSTSPEED_BEUFORT"\
    "$LIVEDATA_PRESSURE_RELBARO" "$LIVEDATA_PRESSURE_ABSBARO"\
    "$LIVEDATA_RAINRATE" "$LIVEDATA_RAINRATE_STATE"  "$LIVEDATA_RAINRATE_STATE_DESCRIPTION" "$LIVEDATA_RAINDAY"\
    "$LIVEDATA_SOLAR_LIGHT" "$LIVEDATA_SOLAR_UVI" "$LIVEDATA_SOLAR_UVI_DESCRIPTION"
    ;;
esac