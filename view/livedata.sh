#!/bin/sh
# shellcheck disable=SC2034
GWDIR=${GWDIR:="."}
DEBUG=${DEBUG:=0}
SHELL_SUPPORT_UNICODE=${SHELL_SUPPORT_UNICODE:=1}
LV_DELIMITER='-'
 
 if  ! type appendBuffer >/dev/null 2>/dev/null; then 
# shellcheck source=../lib/appendBuffer.sh
   . "$GWDIR/lib/appendBuffer.sh"
fi

if ! type initUnit >/dev/null 2>/dev/null; then
# shellcheck source=../lib/mode.sh
  . "$GWDIR/lib/mode.sh"
  initUnit
fi

if [ -z "$LIVEDATAHEADER_INTEMP" ]; then # assume lib not loaded
# shellcheck source=../lib/livedata-header.sh
  . "$GWDIR/lib/livedata-header.sh"
fi

if [ -z "$CSI" ] && [ -z "$NO_COLOR" ]; then 
# shellcheck source=../style/ansiesc.sh
    . "$GWDIR/style/ansiesc.sh"
fi

if [ -z "$LIVEDATALIMIT_RAINHOUR" ]; then
# shellcheck source=../lib/limits.sh
    . "$GWDIR/lib/limits.sh"
fi

if [ -z "$WIND_DIRECTION_N" ]; then
# shellcheck source=../lib/wind.sh
    . "$GWDIR/lib/wind.sh"
fi

#shellcheck source=../lib/beufort.sh
. "$GWDIR/lib/beufort.sh"

#shellcheck source=../lib/uvi.sh
. "$GWDIR/lib/uvi.sh"

#shellcheck source=../lib/pm25.sh
. "$GWDIR/lib/pm25.sh"

#shellcheck source=../lib/rainintensity.sh
. "$GWDIR/lib/rainintensity.sh"

printArgs()
#$1 funcname $2 args
{
    printf "%s\n" "$1"
    shift
    argn=1
    for arg; do
       printf " Arg %2d:%s\n" "$argn" "$arg"
       argn=$(( argn + 1 ))
    done
    printf "\n"
    unset argn arg
}
printLivedataLine()
#allows to intercept/disable printing during debugging
{
    #printArgs printLivedataLine "$@"

    if [ -n "$DEBUG_LIVEDATA_LINE" ]; then
        :
    else
        printLivedataLineFinal "$@"
       # :
    fi

}

printLivedataLineFinal()
# basic output:
#  $1 header 
#  $2 value 
#  $3 value format 
#  $4 unit 
#  $5 unitfmt 
# extended output
#  $6 battery low 0=ok, 1=low
#  $7 battery value 
#  $8 battery state 
#  $9 battery state fmt
# $10 signal value
# $11 signal state 
# optimized to just use one printf call builtin/external -> builds up entire format and argument strings for entire livedata view
# in: STYLE_LIVE_VALUE
{
    if [ "$DEBUG" -eq 1 ] || [ -n "$DEBUG_LIVEDATA_LINE" ]; then
        printf >&2 "%s\r\t\t\t\t%s\r\t\t\t\t\t%s\r\t\t\t\t\t\t%s\r\t\t\t\t\t\t\t%s\r\t\t\t\t\t\t\t\t%s\r\t\t\t\t\t\t\t\t\t%s\r\t\t\t\t\t\t\t\t\t\t%s\r\t\t\t\t\t\t\t\t\t\t\t%s\r\t\t\t\t\t\t\t\t\t\t\t\t%s\r\t\t\t\t\t\t\t\t\t\t\t\t\t%s length %d\n" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" $#
    fi

    l_header=$1
    l_headerfmt="%-32s" # compatible with watch
    # \r\t* horizontal/absolute positioning is compatible with unicode in string
    #l_headerfmt=" %s\r\t\t\t\t" # fails with watch
    #fi
    l_value=$2
    l_valuefmt=$3
    l_unit=$4
    l_unitfmt=$5
    # l_unitfmt="\r\t\t\t\t\t%s" 
    l_unitfmt="%s" #override !

    # extended output 

    l_batterylow=$6
    l_batteryvalue=$7
    l_batterystatus=$8
    l_batterystatusfmt=$9
    l_signalvalue=${10}
    l_signalstate=${11}

    if [ -z "$NO_COLOR" ]; then
        l_STYLE=$STYLE_LIVE_VALUE
        unset STYLE_LIVE_VALUE
        l_STYLE_OFF=$STYLE_RESET
    fi

     # only use UNICODE battery icon/skip detailed battery levels

    l_batteryline="$l_batterystatus"
   
    case $l_batteryline in

            $UNICODE_BATTERY*)      l_batteryline=$UNICODE_BATTERY
                                    ;;
    
            $UNICODE_BATTERY_LOW*) l_batteryline=$UNICODE_BATTERY_LOW 
                                    ;;
    esac

    # only use signal icon, filter levels

    l_signalline="${l_signalstate}"
   
    case $l_signalline in 

            $UNICODE_SIGNAL*)   l_signalline=$UNICODE_SIGNAL
                                ;;
    esac
    
    #merge icons for compact format, only show when battery low, or low signal (keep quite when everything is ok)

    [ -n "$l_batterylow" ] && [ "$l_batterylow" != "1" ] && unset l_batteryline
    [ -n "$l_signalvalue" ] && [ "$l_signalvalue" -gt 0 ] && unset l_signalline

    l_statusline="$l_batteryline$l_signalline" 

    l_statusfmt=${l_batterystatusfmt}
    
    if [ -z "$l_statusfmt" ]; then
        l_format="$l_headerfmt $l_STYLE$l_valuefmt $l_unitfmt$l_STYLE_OFF\n"
        l_args="'$l_header' '$l_value' '$l_unit'"
    else
        l_format="$l_headerfmt $l_STYLE$l_valuefmt $l_unitfmt$l_STYLE_OFF $l_statusfmt\n"
        l_args="'$l_header' '$l_value' '$l_unit' '$l_statusline'"
    fi

    appendFormat "$l_format"
    appendArgs "$l_args"

    unset l_headerfmt\
        l_statusfmt\
        l_unitfmt\
        l_batteryline\
        l_signalline\
        l_format\
        l_args\
        l_batterystatus\
        l_batterystatusfmt\
        l_batteryvalue l_header\
        l_signalstate\
        l_signalvalue\
        l_statusline\
        l_unit\
        l_value\
        l_valuefmt\
        l_STYLE\
        l_STYLE_OFF

    #echo >&2 "set l_*v vars : $(set | grep l_)" # any unset l_ (local vars?)
    
}

printLivedataGroupheader()
# print group header
# $1 style format 
# $2 group header
{
    if [ -z "$NO_COLOR" ]; then
        l_STYLE=$STYLE_LIVEVIEW_NORMAL_HEADER
        l_stylereset=$STYLE_RESET
    fi
    
    if [ -n "$LIVEVIEW_SHOW_GROUPHEADERS" ]; then
        
            [ -z "$1" ] && set -- "\n$l_STYLE%s$l_stylereset\n\n" "$2"  #use default when "" used as $1

        appendBuffer "$1" "'$2'"
    fi
}

printLDIntemp()
{
     if [ -n "$LIVEDATA_INTEMP" ]; then

             #printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_TEMPERATURE"
         
         setLivedataValueStyleLtGt "$LIVEDATA_INTEMP_INTS10" "$LIVEDATALIMIT_INTEMP_LOW" "$LIVEDATALIMIT_INTEMP_HIGH" "$STYLE_LIVEDATALIMIT_INTEMP_LOW" "$STYLE_LIVEDATALIMIT_INTEMP_HIGH"
         printLivedataLine "$LIVEDATAHEADER_INTEMP"  "$LIVEDATA_INTEMP" "%6.1f" "$LIVEDATAUNIT_TEMP" "%s"
     fi
}

printLDOuttemp()
{
     if [ -n "$LIVEDATA_OUTTEMP" ]; then
         setLivedataValueStyleLtGt "$LIVEDATA_OUTTEMP_INTS10" "$LIVEDATALIMIT_OUTTEMP_LOW" "$LIVEDATALIMIT_OUTTEMP_HIGH" "$STYLE_LIVEDATALIMIT_OUTTEMP" "$STYLE_LIVEDATALIMIT_OUTTEMP_HIGH"
         #shellcheck disable=SC2153
         printLivedataLine "$LIVEDATAHEADER_OUTTEMP" "$LIVEDATA_OUTTEMP" "%6.1f" "$LIVEDATAUNIT_TEMP" "%s" 
     fi
}

printLDWindchillDewpoint()
{
    if [ -n "$LIVEDATA_WINDCHILL" ]; then
         setLivedataValueStyleLtGt "$LIVEDATA_WINDCHILL_INT16" "$LIVEDATALIMIT_OUTTEMP_LOW" "$LIVEDATALIMIT_OUTTEMP_HIGH" "$STYLE_LIVEDATALIMIT_OUTTEMP" "$STYLE_LIVEDATALIMIT_OUTTEMP_HIGH"
         printLivedataLine "$LIVEDATAHEADER_WINDCHILL" "$LIVEDATA_WINDCHILL" "%6.1f" "$LIVEDATAUNIT_TEMP" "%2s" 
     fi
         if [ -n "$LIVEDATA_DEWPOINT" ]; then
         printLivedataLine "$LIVEDATAHEADER_DEWPOINT" "$LIVEDATA_DEWPOINT" "%6.1f" "$LIVEDATAUNIT_TEMP" "%2s"
     fi
}

printLDTempHumidity()
{
    [ -n "$LIVEDATA_TEMP1" ] && printLivedataLine "$LIVEDATAHEADER_TEMP1" "$LIVEDATA_TEMP1" '%6.1f' "$LIVEDATAUNIT_TEMP" '%2s' "$SENSOR_TEMP1_BATTERY_LOW" "$SENSOR_TEMP1_BATTERY" "$SENSOR_TEMP1_BATTERY_STATE" "\t%s"  "$SENSOR_TEMP1_SIGNAL" "$SENSOR_TEMP1_SIGNAL_STATE"
    [ -n "$LIVEDATA_TEMP2" ] && printLivedataLine "$LIVEDATAHEADER_TEMP2" "$LIVEDATA_TEMP2" '%6.1f' "$LIVEDATAUNIT_TEMP" '%2s' "$SENSOR_TEMP2_BATTERY_LOW" "$SENSOR_TEMP2_BATTERY" "$SENSOR_TEMP2_BATTERY_STATE" "\t%s"  "$SENSOR_TEMP2_SIGNAL" "$SENSOR_TEMP2_SIGNAL_STATE"
    [ -n "$LIVEDATA_TEMP3" ] && printLivedataLine "$LIVEDATAHEADER_TEMP3" "$LIVEDATA_TEMP3" '%6.1f' "$LIVEDATAUNIT_TEMP" '%2s' "$SENSOR_TEMP3_BATTERY_LOW" "$SENSOR_TEMP3_BATTERY" "$SENSOR_TEMP3_BATTERY_STATE" "\t%s"  "$SENSOR_TEMP3_SIGNAL" "$SENSOR_TEMP3_SIGNAL_STATE"
    [ -n "$LIVEDATA_TEMP4" ] && printLivedataLine "$LIVEDATAHEADER_TEMP4" "$LIVEDATA_TEMP4" '%6.1f' "$LIVEDATAUNIT_TEMP" '%2s' "$SENSOR_TEMP4_BATTERY_LOW" "$SENSOR_TEMP4_BATTERY" "$SENSOR_TEMP4_BATTERY_STATE" "\t%s"  "$SENSOR_TEMP4_SIGNAL" "$SENSOR_TEMP4_SIGNAL_STATE"
    [ -n "$LIVEDATA_TEMP5" ] && printLivedataLine "$LIVEDATAHEADER_TEMP5" "$LIVEDATA_TEMP5" '%6.1f' "$LIVEDATAUNIT_TEMP" '%2s' "$SENSOR_TEMP5_BATTERY_LOW" "$SENSOR_TEMP5_BATTERY" "$SENSOR_TEMP5_BATTERY_STATE" "\t%s"  "$SENSOR_TEMP5_SIGNAL" "$SENSOR_TEMP5_SIGNAL_STATE"
    [ -n "$LIVEDATA_TEMP6" ] && printLivedataLine "$LIVEDATAHEADER_TEMP6" "$LIVEDATA_TEMP6" '%6.1f' "$LIVEDATAUNIT_TEMP" '%2s' "$SENSOR_TEMP6_BATTERY_LOW" "$SENSOR_TEMP6_BATTERY" "$SENSOR_TEMP6_BATTERY_STATE" "\t%s"  "$SENSOR_TEMP6_SIGNAL" "$SENSOR_TEMP6_SIGNAL_STATE"
    [ -n "$LIVEDATA_TEMP7" ] && printLivedataLine "$LIVEDATAHEADER_TEMP7" "$LIVEDATA_TEMP7" '%6.1f' "$LIVEDATAUNIT_TEMP" '%2s' "$SENSOR_TEMP7_BATTERY_LOW" "$SENSOR_TEMP7_BATTERY" "$SENSOR_TEMP7_BATTERY_STATE" "\t%s"  "$SENSOR_TEMP7_SIGNAL" "$SENSOR_TEMP7_SIGNAL_STATE"
    [ -n "$LIVEDATA_TEMP8" ] && printLivedataLine "$LIVEDATAHEADER_TEMP8" "$LIVEDATA_TEMP8" '%6.1f' "$LIVEDATAUNIT_TEMP" '%2s' "$SENSOR_TEMP8_BATTERY_LOW" "$SENSOR_TEMP8_BATTERY" "$SENSOR_TEMP8_BATTERY_STATE" "\t%s"  "$SENSOR_TEMP8_SIGNAL" "$SENSOR_TEMP8_SIGNAL_STATE"

        
    [ -n "$LIVEDATA_HUMI1" ] && printLivedataLine "$LIVEDATAHEADER_HUMIDITY1" "$LIVEDATA_HUMI1" "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s"
    [ -n "$LIVEDATA_HUMI2" ] && printLivedataLine "$LIVEDATAHEADER_HUMIDITY2" "$LIVEDATA_HUMI2" "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s"
    [ -n "$LIVEDATA_HUMI3" ] && printLivedataLine "$LIVEDATAHEADER_HUMIDITY3" "$LIVEDATA_HUMI3" "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s"
    [ -n "$LIVEDATA_HUMI4" ] && printLivedataLine "$LIVEDATAHEADER_HUMIDITY4" "$LIVEDATA_HUMI4" "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s"
    [ -n "$LIVEDATA_HUMI5" ] && printLivedataLine "$LIVEDATAHEADER_HUMIDITY5" "$LIVEDATA_HUMI5" "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s"
    [ -n "$LIVEDATA_HUMI6" ] && printLivedataLine "$LIVEDATAHEADER_HUMIDITY6" "$LIVEDATA_HUMI6" "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s"
    [ -n "$LIVEDATA_HUMI7" ] && printLivedataLine "$LIVEDATAHEADER_HUMIDITY7" "$LIVEDATA_HUMI7" "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s"
    [ -n "$LIVEDATA_HUMI8" ] && printLivedataLine "$LIVEDATAHEADER_HUMIDITY8" "$LIVEDATA_HUMI8" "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s"
}

printLDPressure()
{
       if [ -n "$LIVEDATA_PRESSURE_RELBARO" ]; then
            
           # printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_PRESSURE"

             setLivedataValueStyleLt "$LIVEDATA_PRESSURE_RELBARO_INTS10" "$LIVEDATALIMIT_PRESSURE_RELBARO_LOW"
         
         if [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_HPA" ]; then
             printLivedataLine "$LIVEDATAHEADER_PRESSURE_RELBARO" "$LIVEDATA_PRESSURE_RELBARO" "%6.1f" "$LIVEDATAUNIT_PRESSURE" "%4s" 
             [ -n "$LIVEDATA_PRESSURE_ABSBARO" ] && {
                 setLivedataValueStyleLt "$LIVEDATA_PRESSURE_ABSBARO_INTS10" "$LIVEDATALIMIT_PRESSURE_ABSBARO_LOW"
                 printLivedataLine "$LIVEDATAHEADER_PRESSURE_ABSBARO" "$LIVEDATA_PRESSURE_ABSBARO" "%6.1f" "$LIVEDATAUNIT_PRESSURE" "%4s" ; }
         elif [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_INHG" ]; then
             printLivedataLine "$LIVEDATAHEADER_PRESSURE_RELBARO" "$LIVEDATA_PRESSURE_RELBARO" "%6.2f" "$LIVEDATAUNIT_PRESSURE" "%4s" 
             [ -n "$LIVEDATA_PRESSURE_ABSBARO" ] && printLivedataLine "$LIVEDATAHEADER_PRESSURE_ABSBARO" "$LIVEDATA_PRESSURE_ABSBARO" "%6.2f" "$LIVEDATAUNIT_PRESSURE" "%4s" 
         fi
     fi
}

printLDWind()
{
       if [ -n "$LIVEDATA_WINDSPEED" ]; then
          printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_WIND"
        fi


        if [ -n "$LIVEDATA_WINDSPEED" ]; then
               if type setStyleBeufort >/dev/null 2>/dev/null; then
                    setStyleBeufort "$LIVEDATA_WINDSPEED_INTS10"
                    #STYLE_LIVE_VALUE=$STYLE_BEUFORT
                    export LIVEDATASTYLE_WINDSPEED="$STYLE_BEUFORT"
                fi
            printLivedataLine "$LIVEDATAHEADER_WINDSPEED" "$LIVEDATA_WINDSPEED" "%6.1f" "$LIVEDATAUNIT_WIND"  "%4s" 
        fi

        if [ -n "$LIVEDATA_WINDGUSTSPEED" ]; then
            if type setStyleBeufort >/dev/null 2>/dev/null; then
                setStyleBeufort "$LIVEDATA_WINDGUSTSPEED_INTS10"
                #STYLE_LIVE_VALUE=$STYLE_BEUFORT
                export LIVEDATASTYLE_WINDGUSTSPEED="$STYLE_BEUFORT"
            fi
           

            printLivedataLine  "$LIVEDATAHEADER_WINDGUSTSPEED" "$LIVEDATA_WINDGUSTSPEED" "%6.1f" "$LIVEDATAUNIT_WIND" "%s" 
            printLivedataLine  "$LIVEDATAHEADER_WINDGUSTSPEED_BEUFORT" "$LIVEDATA_WINDGUSTSPEED_BEUFORT_DESCRIPTION ($LIVEDATA_WINDGUSTSPEED_BEUFORT)" "%s" "" "%s" 

        fi

        if [ -n "$LIVEDATA_WINDDIRECTION_COMPASS" ]; then
            printLivedataLine "$LIVEDATAHEADER_WINDDIRECTION_COMPASS" "$LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE $LIVEDATA_WINDDIRECTION_COMPASS ($LIVEDATA_WINDDIRECTION $LIVEDATAUNIT_WIND_DIRECTION)"  "%s" "$LIVEDATAUNIT_WINDDIRECTION_COMPASS" "%5s" "$LIVEDATA_WINDDIRECTION_COMPASS" "" ""
        fi
    
        if [ -n "$LIVEDATA_WINDDAILYMAX" ]; then
              if type setStyleBeufort >/dev/null 2>/dev/null; then
                setBeufort "$LIVEDATA_WINDDAILYMAX_INTS10"
                setStyleBeufort "$LIVEDATA_WINDDAILYMAX_INTS10"
               # STYLE_LIVE_VALUE=$STYLE_BEUFORT
                export LIVEDATASTYLE_WINDDAILYMAX="$STYLE_BEUFORT"
              fi
            export LIVEDATA_WINDDAILYMAX_BEUFORT="$VALUE_BEUFORT"
            export LIVEDATA_WINDDAILYMAX_BEUFORT_DESCRIPTION="$VALUE_BEUFORT_DESCRIPTION"

            printLivedataLine  "$LIVEDATAHEADER_WINDDAILYMAX"   "$LIVEDATA_WINDDAILYMAX"  "%6.1f" "$LIVEDATAUNIT_WIND" "%4s"
         fi 
}

printLDSolar()
{
    if [ -n "$LIVEDATA_SOLAR_LIGHT" ]; then
       printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_SOLAR"
    fi

    if [ -n "$LIVEDATA_SOLAR_LIGHT" ]; then
        if [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_WATTM2" ]; then
                printLivedataLine "$LIVEDATAHEADER_SOLAR_LIGHT" "$LIVEDATA_SOLAR_LIGHT"  "%6.2f" "$LIVEDATAUNIT_SOLAR_LIGHT" "%4s" 
        elif [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_LUX" ]; then 
            printLivedataLine "$LIVEDATAHEADER_SOLAR_LIGHT" "$LIVEDATA_SOLAR_LIGHT"  "%6.0f" "$LIVEDATAUNIT_SOLAR_LIGHT" "%4s" 
        fi
    fi
        
    [ -n "$LIVEDATA_SOLAR_UV" ] && printLivedataLine "$LIVEDATAHEADER_SOLAR_UV" "$LIVEDATA_SOLAR_UV" "%6.1f" "$LIVEDATAUINT_SOLAR_UV" "%5s" 
    
    if [ -n "$LIVEDATA_SOLAR_UVI" ]; then
            if type setStyleUVI >/dev/null 2>/dev/null; then
                setStyleUVI "$LIVEDATA_SOLAR_UVI"
                #shellcheck disable=SC2153
                STYLE_LIVE_VALUE=$STYLE_UVI
                export LIVEDATASTYLE_SOLAR_UVI="$STYLE_UVI"
            fi
        
         #   unset LV_DELIMITER
        
        #padSpaceRight "$VALUE_UV_RISK" 10
        printLivedataLine "$LIVEDATAHEADER_SOLAR_UVI" "$LIVEDATA_SOLAR_UVI_DESCRIPTION ($LIVEDATA_SOLAR_UVI)" "%s" "" "%4s" "" "" 
    fi
}

printLDInOutHumidity()
{
     [ -n "$LIVEDATA_INHUMI" ]   && printLivedataLine "$LIVEDATAHEADER_INHUMI" "$LIVEDATA_INHUMI"  "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s" 
     [ -n "$LIVEDATA_OUTHUMI" ]  && printLivedataLine "$LIVEDATAHEADER_OUTHUMI" "$LIVEDATA_OUTHUMI" "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s" 
}

printLDRain()
{
    setRainValueFormat # 2 decimals for inch or 1 decimals for mm
       
    if [ -n "$LIVEDATA_RAINRATE" ]; then
     
            printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_RAIN"

            setRainIntensity "$LIVEDATA_RAINRATE_INTS10"
            export LIVEDATA_RAINRATE_STATE_DESCRIPTION="$VALUE_RAININTENSITY"
            if type setStyleRainIntensity >/dev/null 2>/dev/null; then
                setStyleRainIntensity "$LIVEDATA_RAINRATE_INTS10"
                STYLE_LIVE_VALUE=$STYLE_RAININTENSITY
            fi
            setRainIntensityStatus "$LIVEDATA_RAINRATE_INTS10"
            export LIVEDATA_RAINRATE_STATE="$VALUE_RAININTENSITY_STATUS"
        
            printLivedataLine "$LIVEDATAHEADER_RAINRATE" "$LIVEDATA_RAINRATE" "$VALUE_RAIN_FMT"  "$LIVEDATAUNIT_RAINRATE" "%4s"  '' "$VALUE_RAININTENSITY_STATUS" 
    fi
    # rainhour available in Ecowitt http request
    [ -n "$LIVEDATA_RAINHOUR" ]     && printLivedataRainLine "$LIVEDATA_RAINHOUR_INTS10"  "$LIVEDATALIMIT_RAINHOUR"  "$LIVEDATAHEADER_RAINHOUR"  "$LIVEDATA_RAINHOUR" "$LIVEDATAUNIT_RAIN" "$STYLE_LIVEDATALIMIT_RAINHOUR"
    [ -n "$LIVEDATA_RAINDAY" ]      && printLivedataRainLine "$LIVEDATA_RAINDAY_INTS10"   "$LIVEDATALIMIT_RAINDAY"   "$LIVEDATAHEADER_RAINDAY"   "$LIVEDATA_RAINDAY"  "$LIVEDATAUNIT_RAIN" "$STYLE_LIVEDATALIMIT_RAINDAY"
    [ -n "$LIVEDATA_RAINEVENT" ]    && printLivedataRainLine "$LIVEDATA_RAINEVENT_INTS10" "$LIVEDATALIMIT_RAINEVENT" "$LIVEDATAHEADER_RAINEVENT" "$LIVEDATA_RAINEVENT" "$LIVEDATAUNIT_RAIN" "$STYLE_LIVEDATALIMIT_RAINEVENT"

    [ -n "$LIVEDATA_RAINWEEK" ]     && printLivedataLine "$LIVEDATAHEADER_RAINWEEK" "$LIVEDATA_RAINWEEK"    "$VALUE_RAIN_FMT" "$LIVEDATAUNIT_RAIN" "%3s"  "$SENSOR_RAINFALL_BATTERY_LOW" "$SENSOR_RAINFALL_BATTERY" "$SENSOR_RAINFALL_BATTERY_STATE" "" "$SENSOR_RAINFALL_SIGNAL" "$SENSOR_RAINFALL_SIGNAL_STATE"
    [ -n "$LIVEDATA_RAINMONTH" ]    && printLivedataLine "$LIVEDATAHEADER_RAINMONTH" "$LIVEDATA_RAINMONTH"  "$VALUE_RAIN_FMT" "$LIVEDATAUNIT_RAIN" "%3s"  "$VALUE_RAIN_FMT"
    [ -n "$LIVEDATA_RAINYEAR" ]     && printLivedataLine "$LIVEDATAHEADER_RAINYEAR" "$LIVEDATA_RAINYEAR"    "$VALUE_RAIN_FMT" "$LIVEDATAUNIT_RAIN" "%3s" 
    [ -n "$LIVEDATA_RAINTOTAL" ]    && printLivedataLine "$LIVEDATAHEADER_RAINTOTAL" "$LIVEDATA_RAINTOTAL"  "$VALUE_RAIN_FMT" "$LIVEDATAUNIT_RAIN" "%3s" "$VALUE_RAIN_FMT"

    unset l_delimiter
}

printLDSoilmoisture()
{
       [ -n "$LIVEDATA_SOILMOISTURE1$LIVEDATA_SOILMOISTURE2$LIVEDATA_SOILMOISTURE3$LIVEDATA_SOILMOISTURE4$LIVEDATA_SOILMOISTURE5$LIVEDATA_SOILMOISTURE6$LIVEDATA_SOILMOISTURE7$LIVEDATA_SOILMOISTURE8" ] && printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_SOILMOISTURE"
            
        n=1
        while [ "$n" -le "$SENSORTYPE_WH51SOILMOISTURE_MAXCH" ]; do
            eval "if [ -n ''"\$LIVEDATA_SOILMOISTURE$n" ]; then
                    printLivedataLine  \"\$LIVEDATAHEADER_SOILMOISTURE$n\" \"\$LIVEDATA_SOILMOISTURE$n\" \"%6u\" \"%\" \"%4s\"  \"\$SENSOR_SOILMOISTURE${n}_BATTERY_LOW\" \"\$SENSOR_SOILMOISTURE${n}_BATTERY\" \"\$SENSOR_SOILMOISTURE${n}_BATTERY_STATE\" '' \"\$SENSOR_SOILMOISTURE${n}_SIGNAL\" \"\$SENSOR_SOILMOISTURE${n}_SIGNAL_STATE\"
                  fi "
            n=$((n + 1))
        done
}

printLDSoiltemperature()
{
        [ -n "$LIVEDATA_SOILTEMP1$LIVEDATA_SOILTEMP2$LIVEDATA_SOILTEMP3$LIVEDATA_SOILTEMP4$LIVEDATA_SOILTEMP5$LIVEDATA_SOILTEMP6$LIVEDATA_SOILTEMP7$LIVEDATA_SOILTEMP8" ] && printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_SOILTEMP"
        
        n=1
        while [ "$n" -le "$SENSORTYPE_WH34SOILTEMP_MAXCH" ]; do
            eval "if [ -n ''"\$LIVEDATA_SOILTEMP$n" ]; then
                    printLivedataLine \"\$LIVEDATAHEADER_SOILTEMP$n\" \"\$LIVEDATA_SOILTEMP$n\" \"%6.1f\" \"$LIVEDATAUNIT_TEMP\" \"%2s\"  \"\$SENSOR_SOILTEMP${n}_BATTERY_LOW\" \"\$SENSOR_SOILTEMP${n}_BATTERY\" \"\$SENSOR_SOILTEMP${n}_BATTERY_STATE\" '' \"\$SENSOR_SOILTEMP${n}_SIGNAL\" \"\$SENSOR_SOILTEMP${n}_SIGNAL_STATE\"
                  fi"
            n=$((n + 1))
        done
}

printLDLeak()
{
        [ -n "$LIVEDATA_LEAK1$LIVEDATA_LEAK2$LIVEDATA_LEAK3$LIVEDATA_LEAK4" ] && printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_LEAK"
        
        n=1
        while [ "$n" -le "$SENSORTYPE_WH55LEAK_MAXCH" ]; do
            #TEST eval LIVEDATA_LEAK$n=1
            #shellcheck disable=SC2034
            VALUE_LEAK=$LIVEDATAHEADER_LEAK_NO
            eval "if [ -n ''"\$LIVEDATA_LEAK$n" ]; then
                        [ \"\$LIVEDATA_LEAK$n\" -ne 0 ] && STYLE_LIVE_VALUE=\"$STYLE_LEAK\" && VALUE_LEAK=$LIVEDATAHEADER_LEAK_YES
                        printLivedataLine \"\$LIVEDATAHEADER_LEAK$n\" \"\$VALUE_LEAK (\$LIVEDATA_LEAK$n)\" \"%6s\" \"\" \"%4s\" \"\$SENSOR_LEAK${n}_BATTERY_LOW\" \"\$SENSOR_LEAK${n}_BATTERY\" \"\$SENSOR_LEAK${n}_BATTERY_STATE\" '' \"\$SENSOR_LEAK${n}_SIGNAL\" \"\$SENSOR_LEAK${n}_SIGNAL_STATE\"
                fi"
            n=$((n + 1))
        done
}

printLDPM25()
{
       [ -n "$LIVEDATA_PM251$LIVEDATA_PM252$LIVEDATA_PM253$LIVEDATA_PM254" ] && printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_PM25"

        n=1
        while [ "$n" -le "$SENSORTYPE_WH43PM25_MAXCH" ]; do
            #shellcheck disable=SC2153
            eval "if [ -n ''"\$LIVEDATA_PM25$n" ]; then
                            #setSGIBatteryLowNormal \"\$SENSOR_PM25${n}_BATTERY\"
                                setAQI \"\$LIVEDATA_PM25${n}_INTS10\"
                                if type setStyleAQI >/dev/null 2>/dev/null; then
                                    setStyleAQI \"\$LIVEDATA_PM25${n}_INTS10\"
                                    STYLE_LIVE_VALUE=\$STYLE_AQI
                                fi
                              #unset LV_DELIMITER
                            export LIVEDATA_PM25${n}_AQI=\"\$VALUE_PM25_AQI\"
                            #padSpaceRight \"\$VALUE_PM25_AQI\" 13
                            printLivedataLine \"\$LIVEDATAHEADER_PM25$n\" \"\$LIVEDATA_PM25$n\" \"%6.1f\" \"\$LIVEDATAUNIT_PM25\" \"%6s\" \"\$SENSOR_PM25${n}_BATTERY_LOW\" \"\$SENSOR_PM25${n}_BATTERY\" \"\$SENSOR_PM25${n}_BATTERY_STATE\" '' \"\$SENSOR_PM25${n}_SIGNAL\" \"\$SENSOR_PM25${n}_SIGNAL_STATE\"
                 fi"
            n=$((n + 1))
        done

        n=1
        while [ "$n" -le "$SENSORTYPE_WH43PM25_MAXCH" ]; do
            eval "if [ -n ''"\$LIVEDATA_PM25${n}_24HAVG" ]; then
                            setAQI \"\$LIVEDATA_PM25${n}_24HAVG_INTS10\"
                            if type setStyleAQI >/dev/null 2>/dev/null; then
                                setStyleAQI \"\$LIVEDATA_PM25${n}_24HAVG_INTS10\"
                                STYLE_LIVE_VALUE=\$STYLE_AQI
                            fi
                            #unset LV_DELIMITER
                        export LIVEDATA_PM25${n}_AQI_24HAVG=\"\$VALUE_PM25_AQI\"
                       # padSpaceRight \"\$VALUE_PM25_AQI\" 13
                        printLivedataLine \"\$LIVEDATAHEADER_PM25${n}_24HAVG\" \"\$LIVEDATA_PM25${n}_24HAVG\" \"%6.1f\" \"\$LIVEDATAUNIT_PM25\" \"%6s\"  \"\$VALUE_PADSPACERIGHT\"
             fi"
            n=$((n + 1))
        done
}

printLDCO2()
{

        #WH45
        if [ -n "$LIVEDATA_CO2_TEMPF" ]; then
             #setSGIBatteryLowNormal "$LIVEDATA_CO2_BATTERY"
             printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_CO2"
             
             printLivedataLine "$LIVEDATAHEADER_CO2_TEMPF" "$LIVEDATA_CO2_TEMPF"  "%6.1f" "$LIVEDATAUNIT_TEMP" "%2s" "$LIVEDATA_CO2_BATTERY_LOW" "$LIVEDATA_CO2_BATTERY" "$LIVEDATA_CO2_BATTERY_STATE" "" "$LIVEDATA_CO2_SIGNAL" "$LIVEDATA_CO2_SIGNAL_STATE"
        fi

        [ -n "$LIVEDATA_CO2_HUMI" ]         && printLivedataLine "$LIVEDATAHEADER_CO2_HUMI" "$LIVEDATA_CO2_HUMI"                "%6u" "$LIVEDATAUNIT_HUMIDITY" "%4s" 
        [ -n "$LIVEDATA_CO2_PM10" ]         && printLivedataLine "$LIVEDATAHEADER_CO2_PM10" "$LIVEDATA_CO2_PM10"                "%6.1f" "$LIVEDATAUNIT_PM25" "%7s" 
        [ -n "$LIVEDATA_CO2_PM10_24HAVG" ]  && printLivedataLine "$LIVEDATAHEADER_CO2_PM10_24HAVG" "$LIVEDATA_CO2_PM10_24HAVG"  "%6.1f" "$LIVEDATAUNIT_PM25" "%7s" 
        if [ -n "$LIVEDATA_CO2_PM25" ]; then
            setAQI "$LIVEDATA_CO2_PM25_INTS10"
            setStyleAQI "$LIVEDATA_CO2_PM25_INTS10"
            STYLE_LIVE_VALUE=$STYLE_AQI
            printLivedataLine "$LIVEDATAHEADER_CO2_PM25 $LV_DELIMITER $VALUE_PM25_AQI" "$LIVEDATA_CO2_PM25"                "%6.1f" "$LIVEDATAUNIT_PM25" "%7s" 
        fi
        if [ -n "$LIVEDATA_CO2_PM25_24HAVG" ]; then
            setAQI "$LIVEDATA_CO2_PM25_24HAVG_INTS10"
            setStyleAQI "$LIVEDATA_CO2_PM25_24HAVG_INTS10"
            STYLE_LIVE_VALUE=$STYLE_AQI
            printLivedataLine "$LIVEDATAHEADER_CO2_PM25_24HAVG $LV_DELIMITER $VALUE_PM25_AQI" "$LIVEDATA_CO2_PM25_24HAVG"  "%6.1f" "$LIVEDATAUNIT_PM25" "%7s" 
        fi
        [ -n "$LIVEDATA_CO2_CO2" ]          && printLivedataLine "$LIVEDATAHEADER_CO2_CO2" "$LIVEDATA_CO2_CO2"                  "%6u" "$LIVEDATAUNIT_CO2" "%6s" 
        [ -n "$LIVEDATA_CO2_CO2_24HAVG" ]   && printLivedataLine "$LIVEDATAHEADER_CO2_CO2_24HAVG" "$LIVEDATA_CO2_CO2_24HAVG"           "%6u" "$LIVEDATAUNIT_CO2" "%6s" 

}

printLDLightning()
{
        if [ -n "$LIVEDATA_LIGHTNING_DISTANCE" ]; then
            printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_LIGHTNING"
            
            printLivedataLine "$LIVEDATAHEADER_LIGHTNING_DISTANCE" "$LIVEDATA_LIGHTNING_DISTANCE"    "%6u" "km" "%5s" "$SENSOR_LIGHTNING_BATTERY_LOW" "$SENSOR_LIGHTNING_BATTERY" "$SENSOR_LIGHTNING_BATTERY_STATE" '' "$SENSOR_LIGHTNING_SIGNAL" "$SENSOR_LIGHTNING_SIGNAL_STATE" 
        fi
        [ -n "$LIVEDATA_LIGHTNING_TIME" ]       && printLivedataLine "$LIVEDATAHEADER_LIGHTNING_TIME_UTC" "$LIVEDATA_LIGHTNING_TIME_UTC"    "%19s" "" "%5s" 
        [ -n "$LIVEDATA_LIGHTNING_POWER" ]      && printLivedataLine "$LIVEDATAHEADER_LIGHTNING_POWER" "$LIVEDATA_LIGHTNING_POWER"          "%6u" "" "%5s" 
    
}

printLDLeafwetness()
{
        if [ -n "$LIVEDATA_LEAFWETNESS1$LIVEDATA_LEAFWETNESS2$LIVEDATA_LEAFWETNESS3$LIVEDATA_LEAFWETNESS4$LIVEDATA_LEAFWETNESS5$LIVEDATA_LEAFWETNESS6$LIVEDATA_LEAFWETNESS7$LIVEDATA_LEAFWETNESS8" ]; then
            printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_LEAFWETNESS"
        fi
        n=1
        while [ "$n" -le "$SENSORTYPE_WH35LEAFWETNESS_MAXCH" ]; do
            eval "if [ -n ''"\$LIVEDATA_LEAFWETNESS$n" ]; then
                    printLivedataLine \"\$LIVEDATAHEADER_LEAFWETNESS$n\" \"\$LIVEDATA_LEAFWETNESS$n\" \"%6u\" \"%\" \"%4s\" \"\$SENSOR_LEAFWETNESS${n}_BATTERY_LOW\"  \"\$SENSOR_LEAFWETNESS${n}_BATTERY\" \"\$SENSOR_LEAFWETNESS${n}_BATTERY_STATE\" '' \"\$SENSOR_LEAFWETNESS${n}_SIGNAL\" \"\$SENSOR_LEAFWETNESS${n}_SIGNAL_STATE\"
            fi"
            n=$((n + 1))
        done
}

printLDSystem()
{
        
       if [ -n "$LIVEDATA_SYSTEM_VERSION" ]; then
            printLivedataGroupheader "" "$LIVEDATAGROUPHEADER_SYSTEM"
        fi

        [ -n "$LIVEDATA_SYSTEM_HOST" ] && printLivedataLine "$LIVEDATAHEADER_SYSTEM_HOST"   "$LIVEDATA_SYSTEM_HOST"   "%-14s" "" "%5s"
        [ -n "$LIVEDATA_SYSTEM_MAC" ] && printLivedataLine "$LIVEDATAHEADER_SYSTEM_MAC"   "$LIVEDATA_SYSTEM_MAC"   "%-14s" "" "%5s" 
        
        [ -n "$LIVEDATA_SYSTEM_VERSION" ]   && printLivedataLine "$LIVEDATAHEADER_SYSTEM_VERSION"   "$LIVEDATA_SYSTEM_VERSION"   "%-14s" "" "%5s" 
        [ -n "$LIVEDATA_SYSTEM_MODEL" ]     && printLivedataLine "$LIVEDATAHEADER_SYSTEM_MODEL"     "$LIVEDATA_SYSTEM_MODEL"     "%-7s"  "" "%5s" 
        if [ -n "$LIVEDATA_SYSTEM_UTC" ]; then
       
            if [ -n "$LIVEDATA_SYSTEM_TIMEZONE_AUTO_BIT" ] && [  "$LIVEDATA_SYSTEM_TIMEZONE_AUTO_BIT" -eq 0 ]; then
               if [ "$LIVEDATA_SYSTEM_TIMEZONE_DST_BIT" -eq 1 ]; then
                    printLivedataLine "$LIVEDATAHEADER_SYSTEM_UTC" "$LIVEDATA_SYSTEM_UTC $LIVEDATA_SYSTEM_TIMEZONE_OFFSET_HOURS DST" "%-20s" "" "%5s" 'utc'
               else
                    printLivedataLine "$LIVEDATAHEADER_SYSTEM_UTC" "$LIVEDATA_SYSTEM_UTC $LIVEDATA_SYSTEM_TIMEZONE_OFFSET_HOURS" "%-20s" "" "%5s" 'utc'
                fi     
            else
                printLivedataLine "$LIVEDATAHEADER_SYSTEM_UTC"       "$LIVEDATA_SYSTEM_UTC"       "%-20s" "" "%5s" 'utc'
            fi

        #    [ -n "$LIVEDATA_SYSTEM_TIMEZONE_AUTO" ] && printLivedataLine "$LIVEDATAHEADER_SYSTEM_TIMEZONE_AUTO" "$LIVEDATA_SYSTEM_TIMEZONE_AUTO" "%s"
        #    [ -n "$LIVEDATA_SYSTEM_TIMEZONE_DST" ] && printLivedataLine "$LIVEDATAHEADER_SYSTEM_TIMEZONE_DST" "$LIVEDATA_SYSTEM_TIMEZONE_DST" "%s"
        #    [ -n "$LIVEDATA_SYSTEM_TIMEZONE" ] && printLivedataLine "$LIVEDATAHEADER_SYSTEM_TIMEZONE" "$LIVEDATA_SYSTEM_TIMEZONE" "%-32.32s"
        fi
        
        [ -n "$LIVEDATA_SYSTEM_FREQUENCY" ] && printLivedataLine "$LIVEDATAHEADER_SYSTEM_FREQUENCY" "$LIVEDATA_SYSTEM_FREQUENCY" "%-7s"  "" "%5s"  
        [ -n "$LIVEDATA_SYSTEM_SENSORTYPE" ] && printLivedataLine "$LIVEDATAHEADER_SYSTEM_SENSORTYPE" "$LIVEDATA_SYSTEM_SENSORTYPE" "%4s" "" "%4s" "$LIVEDATA_WH65_BATTERY_LOW"  "$LIVEDATA_WH65_BATTERY" "$LIVEDATA_WH65_BATTERY_STATE" "" "$LIVEDATA_WH65_SIGNAL" "$LIVEDATA_WH65_SIGNAL_STATE"
   
       # setLivedataProtocolStyle "$LIVEDATA_SYSTEM_PROTOCOL"
       # space=' '
       # [ -z "$LIVEDATA_SYSTEM_PROTOCOL_VERSION" ] && unset space
       #    STYLE_LIVE_VALUE=$VALUE_STYLE_PROTOCOL   printLivedataLine "$LIVEDATAHEADER_SYSTEM_PROTOCOL" "$LIVEDATA_SYSTEM_PROTOCOL_LONG$space$LIVEDATA_SYSTEM_PROTOCOL_VERSION" "%s" 
       
        [ -n "$SENSORSTAT_CONNECTED" ] && STYLE_LIVE_VALUE=$STYLE_SENSOR_CONNECTED printLivedataLineFinal "$LIVEDATAHEADER_SYSTEM_SENSOR_CONNECTED" "$SENSORSTAT_CONNECTED" "%2u"
        [ -n "$SENSORSTAT_DISCONNECTED" ] && STYLE_LIVE_VALUE=$STYLE_SENSOR_DISCONNECTED printLivedataLineFinal "$LIVEDATAHEADER_SYSTEM_SENSOR_DISCONNECTED" "$SENSORSTAT_DISCONNECTED" "%2u"
        [ -n "$SENSORSTAT_SEARCHING" ] && STYLE_LIVE_VALUE=$STYLE_SENSOR_SEARCH    printLivedataLine "$LIVEDATAHEADER_SYSTEM_SENSOR_SEARCHING" "$SENSORSTAT_SEARCHING" "%2u"
        [ -n "$SENSORSTAT_DISABLED" ] && STYLE_LIVE_VALUE=$STYLE_SENSOR_DISABLE   printLivedataLine "$LIVEDATAHEADER_SYSTEM_SENSOR_DISABLED" "$SENSORSTAT_DISABLED" "%2u"

}

printLivedataHTMLOuttemp()
#https://www.w3schools.com/cssref/pr_margin.asp
#for old ipad 1/safari -landscape mode
{
    l_sysinfo="$LIVEDATA_SYSTEM_HOST $LIVEDATA_SYSTEM_VERSION $LIVEDATA_SYSTEM_UTC"
    l_htmlfmt=$(printf "HTTP/1.1 200 OK
Server: gw
Content-Type: text/html; charset=UTF-8
Refresh: 60

%s" "$(cat ./html/ipad1.html)")
   eval printf \"\$l_htmlfmt\" \""$l_sysinfo"\" \""$LIVEDATA_INTEMP"\" \""$LIVEDATA_OUTTEMP"\" \""$LIVEDATAUNIT_TEMP"\" \""$LIVEDATA_WINDSPEED"\" \""$LIVEDATA_WINDGUSTSPEED"\" \""$LIVEDATAUNIT_WIND"\" \""$LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE $LIVEDATA_WINDDIRECTION_COMPASS"\"
    unset l_sysinfo
    
}


printLivedataHTMLAll()
# https://developer.mozilla.org/en-US/docs/Web/HTML/Quirks_Mode_and_Standards_Mode
# https://en.wikipedia.org/wiki/Meta_refresh <meta http-equiv=\"refresh\" content=\"5\">
# https://stackoverflow.com/questions/32913226/auto-refresh-page-every-30-seconds
# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta
# UTF-8 is necessary to show unicode
{
    l_sysinfo="$LIVEDATA_SYSTEM_HOST $LIVEDATA_SYSTEM_VERSION $LIVEDATA_SYSTEM_UTC"
    l_htmlfmt=$(printf 'HTTP/1.1 200 OK
Server: gw
Content-Type: text/html; charset=UTF-8
Refresh: 16

%s' "$(cat ./html/livedata.html)")

    eval printf \"\$l_htmlfmt\" \""$l_sysinfo"\" \""$LIVEDATA_TEXT_UTF8"\"
    unset l_sysinfo
}

printLivedataHTML()
{
    printLivedataHTMLOuttemp
    #printLivedataHTMLAll
}

printJSONinit()
{
    JSON_level=0
}

printJSONLeftBrace()
{
    JSON_level=$(( JSON_level + 1 ))
    eval JSON_firstMember$JSON_level=1 # flag = 1 if this is the first property (used to print , on subsequent properties for same object literal)
    appendFormat " { "
}

printJSONRightBrace()
{
    JSON_level=$(( JSON_level - 1 ))
    appendFormat " } "
}

printJSONmember()
# $1 member
# $2 value format
# $3 value
# https://www.json.org/json-en.html
{
    lIFS="$IFS"
    lmember=$1
    lvaluefmt=$2

    # convert %s to "%s"
    case "$2" in
      %s)  set -- "$1" \"%s\" "\"$3\""
           #\" used to disable word splitting on space
            ;;
      %*f) # json requires . in floating point numbers
            case "$3" in
                *,*) IFS=,
                    #shellcheck disable=SC2086
                     set -- $3
                     set -x
                     lfloat="$1.$2"
                     set +x
                     IFS=$lIFS
                     set -- "$lmember" "%s" "$lfloat"
                     #locale -k decimal_point
                        ;;
            esac
            ;;
    esac

    if [ -n "$3" ]; then
        eval "if [ \$JSON_firstMember$JSON_level -eq 1 ]; then
            appendBuffer '\"$1\" : $2' '$3 '
            JSON_firstMember$JSON_level=0
        else
            appendBuffer ', \"$1\" : $2' '$3 '
        fi"
    elif [ -z "$2" ] && [ -z "$3" ]; then
         eval "if [ \$JSON_firstMember$JSON_level -eq 1 ]; then
             appendBuffer '\"$1\" : '
             JSON_firstMember$JSON_level=0
          else
            appendBuffer ', \"$1\" : '
         fi"  
    fi

    unset lmember lvaluefmt lfloat lIFS
}

printLDIntempJSON()
{
    if [ -n "$LIVEDATA_INTEMP" ]; then
        printJSONmember "intemp" "%.1f" "$LIVEDATA_INTEMP"
        printJSONmember "inhumidity" "%d" "$LIVEDATA_INHUMI"
    fi
}

printLDOuttempJSON()
{
    #https://doc.ecowitt.net/web/#/apiv3en?page_id=17
    # time and value is a string value/using "*"
   #printf '{"outdoor":{"temperature":{"time":"%s","value":"%s","unit":"%s"}}}'  "$LIVEDATA_SYSTEM_TIMESTAMP" "$LIVEDATA_OUTTEMP" "$LIVEDATAUNIT_TEMP"

    if [ -n "$LIVEDATA_OUTTEMP" ]; then
        printJSONmember "outtemp" "%.1f" "$LIVEDATA_OUTTEMP" 
        printJSONmember "outhumidity" "%d" "$LIVEDATA_OUTHUMI"
    fi

}

printLDPressureJSON()
{
    if [ -n "$LIVEDATA_PRESSURE_RELBARO" ]; then
        if [ "$UNIT_PRESSURE_MODE" -eq $UNIT_PRESSURE_HPA ]; then
            printJSONmember "relbaro" "%.1f" "$LIVEDATA_PRESSURE_RELBARO"
        elif [ "$UNIT_PRESSURE_MODE" -eq $UNIT_PRESSURE_INHG ]; then
            printJSONmember "relbaro" "%.2f" "$LIVEDATA_PRESSURE_RELBARO"
        fi
    fi

    if [ -n "$LIVEDATA_PRESSURE_ABSBARO" ]; then
        if [ "$UNIT_PRESSURE_MODE" -eq $UNIT_PRESSURE_HPA ]; then
            printJSONmember "absbaro" "%.1f" "$LIVEDATA_PRESSURE_ABSBARO"
        elif [ "$UNIT_PRESSURE_MODE" -eq $UNIT_PRESSURE_INHG ]; then
            printJSONmember "absbaro" "%.2f" "$LIVEDATA_PRESSURE_ABSBARO"
        fi
    fi
}

printLDWindJSON()
{
    if [ -n "$LIVEDATA_WINDSPEED" ]; then
        printJSONmember "windspeed" '%.1f' "$LIVEDATA_WINDSPEED"
    fi

    if [ -n "$LIVEDATA_WINDGUSTSPEED" ]; then
        printJSONmember "windgustspeed" '%.1f' "$LIVEDATA_WINDSPEED"
        printJSONmember "wingustspeed_beufort" "%d" "$LIVEDATA_WINDGUSTSPEED_BEUFORT"
        printJSONmember "wingustspeed_beufort_description" "%s" "$LIVEDATA_WINDGUSTSPEED_BEUFORT_DESCRIPTION"
    
    fi

    if [ -n "$LIVEDATA_WINDDAILYMAX" ]; then
        printJSONmember "winddailymax" '%.1f' "$LIVEDATA_WINDDAILYMAX"
    fi

    if [ -n "$LIVEDATA_WINDDIRECTION" ]; then
        printJSONmember "winddirection" '%d' "$LIVEDATA_WINDDIRECTION"
    fi

    if [ -n "$LIVEDATA_WINDDIRECTION_COMPASS" ]; then
        printJSONmember "winddirection_compass" '%s' "$LIVEDATA_WINDDIRECTION_COMPASS"
    fi

    if [ -n "$LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE" ]; then
        printJSONmember "winddirection_compass_needle" '%s' "$LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE"
    fi

}

printLDSolarJSON()
{
     if [ -n "$LIVEDATA_SOLAR_LIGHT" ]; then
        if [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_WATTM2" ]; then
                printJSONmember "solar_light" "%6.2f" "$LIVEDATA_SOLAR_LIGHT"  
        elif [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_LUX" ]; then 
            printLivedataLine "$LIVEDATAHEADER_SOLAR_LIGHT" "$LIVEDATA_SOLAR_LIGHT"  "%6.0f" "$LIVEDATAUNIT_SOLAR_LIGHT" "%4s" 
        fi
    fi

    if [ -n "$LIVEDATA_SOLAR_UV" ]; then
        printJSONmember "solar_uv" "%.1f" "$LIVEDATA_SOLAR_UV"
    fi

    if [ -n "$LIVEDATA_SOLAR_UVI" ]; then
        printJSONmember "solar_uvi" "%.1f" "$LIVEDATA_SOLAR_UVI"
        printJSONmember "solar_uvi_description" "%s" "$LIVEDATA_SOLAR_UVI_DESCRIPTION"
    fi
}

printLDUnitJSON()
{
    printJSONmember 'unit'
            
    printJSONLeftBrace
    
        printJSONmember "temperature" '%s' "$LIVEDATAUNIT_TEMP"
        printJSONmember "humidity" '%s' "$LIVEDATAUNIT_HUMIDITY"
        printJSONmember "humidity" '%s' "$LIVEDATAUNIT_HUMIDITY"
        printJSONmember "wind" '%s' "$LIVEDATAUNIT_WIND"
        printJSONmember "pressure" '%s' "$LIVEDATAUNIT_PRESSURE"
        printJSONmember "winddirection" '%s' "$LIVEDATAUNIT_WIND_DIRECTION"
        printJSONmember "rain" '%s' "$LIVEDATAUNIT_RAIN"
        printJSONmember "rain_rate" '%s' "$LIVEDATAUNIT_RAINRATE"
        printJSONmember "solar_light" '%s' $LIVEDATAUNIT_SOLAR_LIGHT
        printJSONmember "solar_uv" '%s' $LIVEDATAUINT_SOLAR_UV
        #printJSONmember "solar_uvi" '%s' '""'

        printJSONmember "pm25" '%s' "$LIVEDATAUNIT_PM25"
        
        
    printJSONRightBrace
}

printLivedataJSON()
# test: echo "console.log(JSON.parse('"$(./gw -g 192.168.3.16 -v json -c l)"'))" | node
{
    resetAppendBuffer

    printJSONinit

    printJSONLeftBrace

        printJSONmember 'data'

            printJSONLeftBrace
            
                printLDIntempJSON
                printLDOuttempJSON
                printLDPressureJSON
                printLDWindJSON
                printLDSolarJSON
            
            printJSONRightBrace

            printLDUnitJSON
        

    printJSONRightBrace

    printAppendBuffer

}

printLivedata()
# print all LIVEDATA grouped in a table
# debugging: call printLivedataFinal directly for problematic line and set DEBUG_LIVEDATA_LINE=1, also can use: printAppendbuffer; return 
{
    #DEBUG_LIVEDATA_LINE=1

    resetAppendBuffer

    printLDIntemp
    printLDOuttemp
    printLDWindchillDewpoint
    printLDInOutHumidity
    printLDTempHumidity
    printLDPressure
    printLDWind
    printLDSolar
    printLDRain
    printLDSoilmoisture
    printLDSoiltemperature
    printLDLeak
    printLDPM25
    printLDCO2
    printLDLightning
    printLDLeafwetness
    #printLDSystem
  
    printAppendBuffer

    #unset local variables for ksh -> made global by using () function syntax without function keyword
    #https://www.unix.com/shell-programming-and-scripting/137435-ksh-different-syntax-function.html
    #man ksh93: ksh93 uses static scoping (one global scope, one local scope per function) and allows local variables only on Korn style functions
}

newLivedataCompass()
# $1 unicode direction 
# $2 wind direction 
{
    #set -- "$1" "$WIND_ESE"

    l_style_needle=$STYLE_COMPASS_WIND$1$STYLE_RESET
    
    if [ -z "$KSH_VERSION" ]; then
       LIVEDATA_WINDDIRECTION_COMPASS_N_FMT="╭─$STYLE_COMPASS_NORTH$WIND_DIRECTION_N$STYLE_RESET─╮" #styling must be in the format of printf
    else
        LIVEDATA_WINDDIRECTION_COMPASS_N_FMT="╭─$STYLE_COMPASS_NORTH$WIND_DIRECTION_N$STYLE_RESET\u2500╮" #ksh Version AJM 93u+ 2012-08-01 insert \x80 instead of unicode 2500 ?! bug?
    fi
       
    LIVEDATA_WINDDIRECTION_COMPASS_WE_FMT="$WIND_DIRECTION_W $l_style_needle $WIND_DIRECTION_E"

    if [ -z "$KSH_VERSION" ]; then
        LIVEDATA_WINDDIRECTION_COMPASS_S_FMT="╰─$WIND_DIRECTION_S─╯"
    else
        LIVEDATA_WINDDIRECTION_COMPASS_S_FMT="╰─$WIND_DIRECTION_S\u2500╯"
    fi

    export LIVEDATA_WINDDIRECTION_COMPASS_N_FMT LIVEDATA_WINDDIRECTION_COMPASS_WE_FMT LIVEDATA_WINDDIRECTION_COMPASS_S_FMT

    unset l_style_needle
}

printLivedataRainLine()
# purpose: compare raw value with limit and set style
# $1 value 
# $2 limit
# $3 header
# $4 value
# $5 unit
# $6 style if limit reached
{
    # easier to read code with names on variables...
   l_value=$1
   l_limit=$2
   l_header=$3
   l_float=$4
   l_unit=$5
   if [ -z "$NO_COLOR" ]; then
        l_STYLE=$6
   fi

    #printArgs "printLivedataRainLine" "$@"

    [ "$DEBUG" -eq 1 ] && echo >&2 printLivedataRainLine raw value : "$l_value" limit: "$l_limit"

    setLivedataValueStyleGt "$l_value" "$l_limit" "$l_STYLE"
    printLivedataLine "$l_header" "$l_float" "$VALUE_RAIN_FMT" "$l_unit" "%5s" 

    unset l_value l_limit l_header l_float l_unit l_STYLE
}

setLivedataValueStyleLtGt()
#$1 - raw value, $2 low limit, 3$ high limit, $4 sgi low, $5 sgi high
{
    if [ -n "$1" ] &&  [ -n "$2" ] && [ "$1" -lt "$2" ]; then
        STYLE_LIVE_VALUE=$4
    elif [ -n "$1" ] &&  [ -n "$3" ] && [ "$1" -gt "$3" ]; then
        STYLE_LIVE_VALUE=$5
    fi
}

setLivedataValueStyleGt()
#$1 - raw v. $2 limit $3 style
{
    if [ "$1" -gt "$2" ]; then
        if [ -z "$3" ]; then
            STYLE_LIVE_VALUE=$STYLE_LIVEDATALIMIT
        else
            STYLE_LIVE_VALUE=$3
        fi
    fi
}

setLivedataValueStyleLt()
#$1 - raw v. $2 limit $3 style
{
    if [ "$1" -lt "$2" ]; then
        if [ -z "$3" ]; then
            STYLE_LIVE_VALUE=$STYLE_LIVEDATALIMIT
        else
            STYLE_LIVE_VALUE=$3
        fi
    fi
}

printLivedataSystem()
{
    setLivedataProtocolStyle "$LIVEDATA_SYSTEM_PROTOCOL"

    appendBuffer "%s %s $VALUE_STYLE_PROTOCOL%s$STYLE_RESET" "'$LIVEDATA_SYSTEM_VERSION' '$LIVEDATA_SYSTEM_FREQUENCY' '$LIVEDATA_SYSTEM_PROTOCOL'"
    
    if [ -n "$SENSORSTAT_CONNECTED" ]; then
       appendBuffer " %s/$STYLE_SENSOR_SEARCH%s$STYLE_RESET/$STYLE_SENSOR_DISABLE%s$STYLE_RESET" "'$SENSORSTAT_CONNECTED' '$SENSORSTAT_SEARCHING' '$SENSORSTAT_DISABLED' "
    fi
   
    printWHBatterySignal "WH65" "$LIVEDATA_WH65_BATTERY_STATE" "$LIVEDATA_WH65_SIGNAL_STATE"
    #set in setBattery
    #shellcheck disable=SC2153
    printWHBatterySignal "WH68" "$LIVEDATA_WH68_BATTERY_STATE" "$LIVEDATA_WH68_SIGNAL_STATE" #maybe multiple weather stations allowed?
    #shellcheck disable=SC2153
    printWHBatterySignal "WH80" "$LIVEDATA_WH80_BATTERY_STATE" "$LIVEDATA_WH80_SIGNAL_STATE"

    appendBuffer " %s" "'$LIVEDATA_SYSTEM_UTC'"

    $LIVEDATA_SYSTEM_TIMEZONE


    if [ "$LIVEDATA_SYSTEM_TIMEZONE_AUTO" = "$LIVEDATA_SYSTEM_TIMEZONE_AUTO_OFF" ]; then
      appendBuffer " %s" "'$LIVEDATA_SYSTEM_TIMEZONE_OFFSET_HOURS'"
      
      if [ "$LIVEDATA_SYSTEM_TIMEZONE_DST_BIT" -eq 1 ]; then
        appendFormat " DST"
      fi
    fi

    #appendFormat "\n\n"
}


printLivedataBatteryLowNormal()
#$1 - battery 0/1, $2 - battery state, $3 header, $4 terse header
{
    if [ -n "$1" ]; then

     setSGIBatteryLowNormal "$1"
     printLivedataLine "$3" "$2" "%-7s" "" "%5s" "$4"
    fi
}

printLivedataBatteryVoltage()
#$1 - batteryvoltage raw scaled 10, $2 - battery state, $3 header, $4 terse header
{
    if [ -n "$1" ]; then
        setSGIBatteryVoltage "$1"
        printLivedataLine "$3" "$2" "%-7s" "" "%5s" "$4" 
    fi
}

setSGIBatteryLowNormal()
{
    if [ "$1" -eq "$BATTERY_LOW" ]; then
        STYLE_LIVE_VALUE=$STYLE_BATTERY_LOW
    fi
}

setSGIBatteryVoltage()
{
    if [ "$1" -le "$BATTERY_VOLTAGE_LOW" ]; then
        STYLE_LIVE_VALUE=$STYLE_BATTERY_LOW
    fi
}

setRainValueFormat()
{
     if [ "$UNIT_RAIN_MODE" -eq "$UNIT_RAIN_MM" ]; then
      VALUE_RAIN_FMT="%6.1f"
    elif [ "$UNIT_RAIN_MODE" -eq "$UNIT_RAIN_IN" ]; then
      VALUE_RAIN_FMT="%6.2f"
    fi
}

printWHBatterySignal()
#$1 - WH?? $2 battery $3 signal
{
    if [ -n "$2" ]; then
        if [ "$1" = "WH65" ] && [ "$GW_SYSTEM_SENSORTYPE_STATE" = "WH24" ]; then
            appendFormat " WH24 %s"
        else
            appendFormat " $1 %s"
        fi

        appendArgs "'$2' "
    fi
        
    if [ -n "$3" ]; then
        appendBuffer "%s" "'$3'"
    fi
}

setLivedataProtocolStyle()
{
    case "$1" in

      "$LIVEDATAPROTOCOL_ECOWITT_HTTP"|"$LIVEDATAPROTOCOL_ECOWITT_BINARY")
            VALUE_STYLE_PROTOCOL=$STYLE_PROTOCOL_ECOWITT_HTTP
            ;;
      "$LIVEDATAPROTOCOL_WUNDERGROUND_HTTP")
            VALUE_STYLE_PROTOCOL=$STYLE_PROTOCOL_WUNDERGROUND_HTTP
            ;;
    esac
}

setRainIntensityStatus()
# sets rainintensity unicode status
{
    if [ "$1" -eq 0 ]; then
        unset VALUE_RAININTENSITY_STATUS
    elif [ "$1" -gt 0 ] &&  [ "$1" -lt "$RAININTENSITY_LIGHT_LIMIT" ]; then
        VALUE_RAININTENSITY_STATUS=$UNICODE_RAINRATE
    elif [ "$1" -ge "$RAININTENSITY_LIGHT_LIMIT" ] && [ "$1" -lt "$RAININTENSITY_MODERATE_LIMIT" ]; then
         VALUE_RAININTENSITY_STATUS=$UNICODE_RAINRATE$UNICODE_RAINRATE
    elif [ "$1" -ge  "$RAININTENSITY_MODERATE_LIMIT" ] && [ "$1" -lt "$RAININTENSITY_HEAVY_LIMIT" ]; then
        VALUE_RAININTENSITY_STATUS=$UNICODE_RAINRATE$UNICODE_RAINRATE$UNICODE_RAINRATE
    elif [ "$1" -gt "$RAININTENSITY_HEAVY_LIMIT" ]; then
        VALUE_RAININTENSITY_STATUS=$UNICODE_RAINRATE$UNICODE_RAINRATE$UNICODE_RAINRATE$UNICODE_RAINRATE
    fi
}

#use zsh -c "./gw" invokation
[ $DEBUG -eq 1 ] && echo >&2 "Entering auto startup detection with arguments 0: $0" 

    case $0 in 
        "$GWDIR"/view/livedata.sh) 
                            [ $DEBUG -eq 1 ] && echo >&2 Auto start of printlivedata
                            printLivedata ;; # auto start if called directly on command line
    esac

