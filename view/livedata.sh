#!/bin/sh

GWDIR=${GWDIR:="."}
DEBUG=${DEBUG:=0}
DEBUG_OPTION_APPEND=${DEBUG_OPTION_APPEND:=0}
SHELL_SUPPORT_UNICODE=${SHELL_SUPPORT_UNICODE:=1}
HIDE_RAIN_LIVEDATA_AUTO=${HIDE_RAIN_LIVEDATA_AUTO:=0} # auto hide_liveview when 0 today (0=off)
HIDE_LIGHT_LIVEDATA_AUTO=${HIDE_LIGHT_LIVEDATA_AUTO:=0} # auto hide_liveview when 0/dark
LV_DELIMITER='-'
 
 if  ! type appendBuffer >/dev/null 2>/dev/null; then 
   . $GWDIR/lib/appendBuffer.sh
fi

if ! type initUnit >/dev/null 2>/dev/null; then
  . $GWDIR/lib/mode.sh
  initUnit
fi

if [ -z "$LIVEDATAHEADER_INTEMP" ]; then # assume lib not loaded
  . $GWDIR/lib/livedata-header.sh
fi

if [ -z "$CSI" ]; then 
    . $GWDIR/style/ansiesc.sh
fi

if [ -z "$LIVEDATA_RAINHOUR_LIMIT" ]; then
    . $GWDIR/lib/limits.sh
fi

if [ -z "$WIND_DIRECTION_N" ]; then
    . $GWDIR/lib/wind.sh
fi

printLivedataLine()
#allows to intercept/disable printing during debugging
{
    #echo "$*"
    if [ -n "$DEBUG_LIVEDATA_LINE" ]; then
        :
    else
        printLivedataLineFinal "$@"
    fi

}

printLivedataLineFinal()
#$1 -header variable name, $2 value, $3 - value format, $4 unit, $5 unit format,$6 terse header, $7 terse format, $8 status value $9 status  $10 status fmt $11 signal value $12 signal state
# optimized to just use one printf call builtin/external -> builds up entire format and argument strings for entire livedata view
{
    if [ "$DEBUG" -eq 1 ] || [ "$DEBUG_LIVEDATA_LINE" ]; then
        echo >&2 "printLivedataLine $* length $#"
    fi

    # \r\t horizontal/absolute positioning is compatible with unicode in string
    if [ -n "$LIVEVIEW_HIDE_HEADERS" ] && [ "$LIVEVIEW_HIDE_HEADERS" -eq 1 ]; then 
        header_fmt="%s\r\t\t\t\t" 
    else
       header_fmt=" %s\r\t\t\t\t"
    fi
    # unit_fmt="\r\t\t\t\t\t%s" 
    unit_fmt="%s"
    #status_fmt="\r\t\t\t\t\t\t%s"
    status_fmt=${10}
    status_fmt=${status_fmt:="\t%s"}
    signal_fmt="\t%s"
    space=' ' #do not use space for unitless values

    #TEST UTF-8: for f in $(seq -s' ' 255); do eval printf "\\\x$(printf "%x" "$f")"; done

    status_line="$9"
    case $status_line in # only use UNICODE battery icon/skip detailed battery levels
            $UNICODE_BATTERY*) status_line=$UNICODE_BATTERY
                            ;;
            $UNICODE_BATTERY_LOW*) status_line=$UNICODE_BATTERY_LOW 
                            ;;
    esac

    signal_line="${12}"
    case $signal_line in 
            $UNICODE_SIGNAL*) signal_line=$UNICODE_SIGNAL
                            ;;
    esac

    status_line="$status_line$signal_line" #merge for compact format
    unset signal_line

    [ -n "$LIVEVIEW_HIDE_STATUSLINE" ] && unset status_line

    if [ "$DEBUG" -eq 1 ] || [ "$DEBUG_OPTION_APPEND" -eq 1 ]; then 
        appendFormat " $header_fmt %s %s %s %s\n"
    fi
    
    if [ -n "$STYLE_LIVE_VALUE" ]; then
        [ -z "$4" ] && unset space # skip space if unit empty
        appendFormat "$header_fmt $STYLE_LIVE_VALUE$3$space$unit_fmt$STYLE_RESET $status_fmt $signal_fmt\n"
    else
        appendFormat "$header_fmt $3 $unit_fmt $status_fmt $signal_fmt\n"
    fi

    unset STYLE_LIVE_VALUE

    if [ "$DEBUG" -eq 1 ] || [ "$DEBUG_OPTION_APPEND" -eq 1 ]; then 
        appendArgs "'$header_fmt' '$3' '$unit_fmt' '$status_fmt' '$signal_fmt'"
    fi

    appendArgs "'$1' '$2' '$4' '$status_line' '$signal_line'"
   
    unset header_fmt ch status_fmt unit_fmt status_line signal_fmt signal_line

}

printLivedataHeader()
{
    [ -n "$LIVEVIEW_HIDE_HEADERS" ] && return

    #unset STYLE_LIVEVIEW_NORMAL_HEADER
    [ -z "$1" ] && set -- "\n$STYLE_LIVEVIEW_NORMAL_HEADER%s$STYLE_RESET\n\n" "$2"  #use default when "" used as $1

     appendBuffer "$STYLE_LIVEVIEW_NORMAL_HEADER%64s$STYLE_RESET\r$1" "' ' '$2'"
}

printLivedata() 
{

    #debugging: call printLivedataFinal directly for problematic line and set DEBUG_LIVEDATA_LINE=1
    #DEBUG_LIVEDATA_LINE=1

    #resetAppendBuffer
 
     if [ -n "$LIVEDATA_INTEMP" ]; then

         printLivedataHeader "" "$LIVEDATAGROUPHEADER_TEMPERATURE"
         
         setLivedataValueStyleLtGt "$LIVEDATA_INTEMP_INTS10" "$LIVEDATA_INTEMP_LIMIT_LOW" "$LIVEDATA_INTEMP_LIMIT_HIGH" "$STYLE_LIVEDATA_INTEMP_LIMIT_LOW" "$STYLE_LIVEDATA_INTEMP_LIMIT_HIGH"
         printLivedataLine "$LIVEDATAHEADER_INTEMP"  "$LIVEDATA_INTEMP" "%6.1f" "$LIVEDATAUNIT_TEMP" "%s" 'in' "%s" 
     fi
    
     if [ -n "$LIVEDATA_OUTTEMP" ]; then
         setLivedataValueStyleLtGt "$LIVEDATA_OUTTEMP_INTS10" "$LIVEDATA_OUTTEMP_LIMIT_LOW" "$LIVEDATA_OUTTEMP_LIMIT_HIGH" "$STYLE_LIMIT_LIVEDATA_OUTTEMP" "$STYLE_LIVEDATA_OUTTEMP_LIMIT_HIGH"
         #WH32 battery and state may be set by injectWH32 testdata or if available
         #shellcheck disable=SC2153
         printLivedataLine "$LIVEDATAHEADER_OUTTEMP" "$LIVEDATA_OUTTEMP" "%6.1f" "$LIVEDATAUNIT_TEMP" "%s" 'out' '' "$LIVEDATA_WH32_BATTERY"  "$LIVEDATA_WH32_BATTERY_STATE" "" "$LIVEDATA_WH32_SIGNAL" "$LIVEDATA_WH32_SIGNAL_STATE"
     fi
 
     if [ -n "$LIVEDATA_WINDCHILL" ]; then
         setLivedataValueStyleLtGt "$LIVEDATA_WINDCHILL_INT16" "$LIVEDATA_OUTTEMP_LIMIT_LOW" "$LIVEDATA_OUTTEMP_LIMIT_HIGH" "$STYLE_LIMIT_LIVEDATA_OUTTEMP" "$STYLE_LIVEDATA_OUTTEMP_LIMIT_HIGH"
         printLivedataLine "$LIVEDATAHEADER_WINDCHILL" "$LIVEDATA_WINDCHILL" "%6.1f" "$LIVEDATAUNIT_TEMP" "%2s" 'wchill' 
     fi
         if [ -n "$LIVEDATA_DEWPOINT" ]; then
         printLivedataLine "$LIVEDATAHEADER_DEWPOINT" "$LIVEDATA_DEWPOINT" "%6.1f" "$LIVEDATAUNIT_TEMP" "%2s"  'dewp'
     fi
     
     [ -n "$LIVEDATA_INHUMI" ]   && printLivedataLine "$LIVEDATAHEADER_INHUMI" "$LIVEDATA_INHUMI"  "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s" 'ihum'   "%4u"
     [ -n "$LIVEDATA_OUTHUMI" ]  && printLivedataLine "$LIVEDATAHEADER_OUTHUMI" "$LIVEDATA_OUTHUMI" "%6u" "$LIVEDATAUNIT_HUMIDITY" "%s" 'ohum'  "%4u"
     
     if [ -z "$LIVEVIEW_HIDE_TEMP" ]; then 
        n=1
        while [ "$n" -le "$SENSORTYPE_WH31TEMP_MAXCH" ]; do
        #shellcheck disable=SC2153
        {
            #eval echo !!!!!!!!!!!!!!!!! \"\$LIVEDATA_WH31TEMP${n}_SIGNAL_STATE\" n=$n
            #set -x
            eval " if [ -n ''"\$LIVEDATA_WH31TEMP$n" ]; then
                       # setSGIBatteryLowNormal "\$LIVEDATA_WH31TEMP${n}_BATTERY"
                        printLivedataLine \"\$LIVEDATAHEADER_WH31TEMP$n\" \"\$LIVEDATA_WH31TEMP$n\" '%6.1f'  \"\$LIVEDATAUNIT_TEMP\" '%2s' 'temp$n' '' \"\$LIVEDATA_WH31TEMP${n}_BATTERY\" \"\$LIVEDATA_WH31TEMP${n}_BATTERY_STATE\" '' \"\$LIVEDATA_WH31TEMP${n}_SIGNAL\" \"\$LIVEDATA_WH31TEMP${n}_SIGNAL_STATE\"
                   fi "
            #set +x
        }
            n=$((n + 1))
        done

        n=1
        while [ "$n" -le "$SENSORTYPE_WH31TEMP_MAXCH" ]; do
        #shellcheck disable=SC2153
        {
            eval "[ -n ''"\$LIVEDATA_WH31HUMI$n" ] && printLivedataLine \"\$LIVEDATAHEADER_WH31HUMIDITY$n\" \"\$LIVEDATA_WH31HUMI$n\" \"%6u\" \"%\" \"%4s\" \"hum$n\" \"%4u\""
        }
            n=$((n + 1))
        done

     fi
     
     if [ -n "$LIVEDATA_PRESSURE_RELBARO" ]; then
            
            printLivedataHeader "" "$LIVEDATAGROUPHEADER_PRESSURE"
             setLivedataValueStyleLt "$LIVEDATA_PRESSURE_RELBARO_INTS10" "$LIVEDATA_PRESSURE_RELBARO_LIMIT_LOW"
         
         if [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_HPA" ]; then
             printLivedataLine "$LIVEDATAHEADER_PRESSURE_RELBARO" "$LIVEDATA_PRESSURE_RELBARO" "%6.1f" "$LIVEDATAUNIT_PRESSURE" "%4s" 'rbaro'
             [ -n "$LIVEDATA_PRESSURE_ABSBARO" ] && {
                 setLivedataValueStyleLt "$LIVEDATA_PRESSURE_ABSBARO_INTS10" "$LIVEDATA_PRESSURE_ABSBARO_LIMIT_LOW"
                 printLivedataLine "$LIVEDATAHEADER_PRESSURE_ABSBARO" "$LIVEDATA_PRESSURE_ABSBARO" "%6.1f" "$LIVEDATAUNIT_PRESSURE" "%4s" 'abaro'; }
         elif [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_INHG" ]; then
             printLivedataLine "$LIVEDATAHEADER_PRESSURE_RELBARO" "$LIVEDATA_PRESSURE_RELBARO" "%6.2f" "$LIVEDATAUNIT_PRESSURE" "%4s" 'rbaro'
             [ -n "$LIVEDATA_PRESSURE_ABSBARO" ] && printLivedataLine "$LIVEDATAHEADER_PRESSURE_ABSBARO" "$LIVEDATA_PRESSURE_ABSBARO" "%6.2f" "$LIVEDATAUNIT_PRESSURE" "%4s" 'abaro'
         fi
     fi
 
    if [ -z "$LIVEVIEW_HIDE_WIND" ]; then
      
       [ -n "$LIVEDATA_WINDSPEED" ] && printLivedataHeader "" "$LIVEDATAGROUPHEADER_WIND"

       [ -z "$LIVEVIEW_HIDE_COMPASS" ] && [ -n "$LIVEDATA_WINDSPEED" ] && [ -n "$LIVEDATA_WINDGUSTSPEED" ] && [ -n "$LIVEDATA_WINDDIRECTION" ] && newLivedataCompass "$LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE" "$VALUE_COMPASS"
         
        if [ -n "$LIVEDATA_WINDSPEED" ]; then
            if [ -z "$LIVEVIEW_HIDE_BEUFORT" ]; then
                setStyleBeufort "$LIVEDATA_WINDSPEED_INTS10"
                STYLE_LIVE_VALUE=$STYLE_BEUFORT
            fi
            printLivedataLine "$LIVEDATAHEADER_WINDSPEED" "$LIVEDATA_WINDSPEED" "%6.1f" "$LIVEDATAUNIT_WIND"  "%4s" 'wspd' "%6.1f" '' '' "\t%s$LIVEDATA_WINDDIRECTION_COMPASS_N_FMT" 
           
        fi

        if [ -n "$LIVEDATA_WINDGUSTSPEED" ]; then
           if [ -z "$LIVEVIEW_HIDE_BEUFORT" ]; then
                setBeufort "$LIVEDATA_WINDGUSTSPEED_INTS10"
                setStyleBeufort "$LIVEDATA_WINDGUSTSPEED_INTS10"
                STYLE_LIVE_VALUE=$STYLE_BEUFORT
           else
             unset LV_DELIMITER
            fi
            export LIVEDATA_WINDGUSTSPEED_BEUFORT="$VALUE_BEUFORT"
            export LIVEDATA_WINDGUSTSPEED_BEUFORT_DESCRIPTION="$VALUE_BEUFORT_DESCRIPTION"

            padSpaceRight "$LIVEDATA_WINDGUSTSPEED_BEUFORT_DESCRIPTION" 15

            printLivedataLine  "$LIVEDATAHEADER_WINDGUSTSPEED $LV_DELIMITER $VALUE_BEUFORT $VALUE_PADSPACERIGHT" "$LIVEDATA_WINDGUSTSPEED" "%6.1f" "$LIVEDATAUNIT_WIND" "%4s" 'wgspd' "%6.1f" "" "" "\t%s$LIVEDATA_WINDDIRECTION_COMPASS_WE_FMT"
        fi

        [ -n "$LIVEDATA_WINDDIRECTION" ] && printLivedataLine "$LIVEDATAHEADER_WINDDIRECTION $LV_DELIMITER $LIVEDATA_WINDDIRECTION_COMPASS" "$LIVEDATA_WINDDIRECTION"   "%6u" "$LIVEDATAUNIT_WIND_DEGREE_UNIT"\
         "%5s" 'wdeg' "%4u" "$LIVEDATA_WINDDIRECTION" "" "\t%s$LIVEDATA_WINDDIRECTION_COMPASS_S_FMT"
        
        if [ -n "$LIVEDATA_WINDDAILYMAX" ]; then
            if [ -z "$LIVEVIEW_HIDE_BEUFORT" ]; then
                setBeufort "$LIVEDATA_WINDDAILYMAX_INTS10"
                setStyleBeufort "$LIVEDATA_WINDDAILYMAX_INTS10"
                STYLE_LIVE_VALUE=$STYLE_BEUFORT
            else
                unset LV_DELIMITER
            fi
            export LIVEDATA_WINDDAILYMAX_BEUFORT="$VALUE_BEUFORT"
            export LIVEDATA_WINDDAILYMAX_BEUFORT_DESCRIPTION="$VALUE_BEUFORT_DESCRIPTION"
            printLivedataLine  "$LIVEDATAHEADER_WINDDAILYMAX $LV_DELIMITER $VALUE_BEUFORT $VALUE_BEUFORT_DESCRIPTION"   "$LIVEDATA_WINDDAILYMAX"  "%6.1f" "$LIVEDATAUNIT_WIND" "%4s" 'wdmax' "%6.1f" 
         fi 
      
        #[ -n "$LIVEDATA_WINDDIRECTION_COMPASS" ]    && printLivedataLine "LIVEDATAHEADER_WINDDIRECTION_COMPASS"   "$LIVEDATA_WINDDIRECTION_COMPASS"  "%6s" "" "%5s" 'wdir' "%4s"
    fi

    if [ -n "$LIVEDATA_SOLAR_LIGHT" ] && [ -n "$LIVEDATA_SOLAR_LIGHT_INTS10" ] && [ "$LIVEDATA_SOLAR_LIGHT_INTS10" -eq 0 ] && [ "$HIDE_LIGHT_LIVEDATA_AUTO" -eq 1 ]; then
      LIVEVIEW_HIDE_LIGHT=1 # auto hide_liveview, when dark
    fi

    if [ -z "$LIVEVIEW_HIDE_LIGHT" ]; then

        [ -n "$LIVEDATA_SOLAR_LIGHT" ] && printLivedataHeader "" "$LIVEDATAGROUPHEADER_SOLAR"

        if [ -n "$LIVEDATA_SOLAR_LIGHT" ]; then
            if [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_WATTM2" ]; then
                 printLivedataLine "$LIVEDATAHEADER_SOLAR_LIGHT" "$LIVEDATA_SOLAR_LIGHT"  "%6.2f" "$LIVEDATAUNIT_SOLAR_LIGHT" "%4s" 'light'
            elif [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_LUX" ]; then 
                printLivedataLine "$LIVEDATAHEADER_SOLAR_LIGHT" "$LIVEDATA_SOLAR_LIGHT"  "%6.0f" "$LIVEDATAUNIT_SOLAR_LIGHT" "%4s" 'light'
            fi
        fi
            
        [ -n "$LIVEDATA_SOLAR_UV" ] && printLivedataLine "$LIVEDATAHEADER_SOLAR_UV" "$LIVEDATA_SOLAR_UV" "%6.1f" "$LIVEDATAUNIT_SOLAR_LIGHT_UV" "%5s" 'uv'
        
        if [ -n "$LIVEDATA_SOLAR_UVI" ]; then
           if [ -z "$LIVEVIEW_HIDE_UVI" ]; then
                setUVRisk "$LIVEDATA_SOLAR_UVI"
                setStyleUVI "$LIVEDATA_SOLAR_UVI"
                #shellcheck disable=SC2153
                STYLE_LIVE_VALUE=$STYLE_UVI
            else
              unset LV_DELIMITER
            fi
            padSpaceRight "$VALUE_UV_RISK" 10
            printLivedataLine "$LIVEDATAHEADER_SOLAR_UVI $LV_DELIMITER $VALUE_PADSPACERIGHT" "$LIVEDATA_SOLAR_UVI"      "%6u" "    " "%4s" 'uvi' "%3u"
        fi
    fi

    if [ -n "$LIVEDATA_RAINDAY_INTS10" ] && [ "$LIVEDATA_RAINDAY_INTS10" -eq 0 ] && [ "$HIDE_RAIN_LIVEDATA_AUTO" -eq 1 ]; then
       LIVEVIEW_HIDE_RAIN=1 #auto hide_liveview, if no rain today
    fi

    if [ -z "$LIVEVIEW_HIDE_RAIN" ]; then
      
        setRainValueFormat # 2 decimals for inch or 1 decimals for mm
       
        if [ -n "$LIVEDATA_RAINRATE" ]; then
              printLivedataHeader "" "$LIVEDATAGROUPHEADER_RAIN"

               setRainIntensity "$LIVEDATA_RAINRATE_INTS10"
               export LIVEDATA_RAINRATE_STATE_DESCRIPTION="$VALUE_RAININTENSITY"
               setStyleRainIntensity "$LIVEDATA_RAINRATE_INTS10"
               setRainIntensityStatus "$LIVEDATA_RAINRATE_INTS10"
               export LIVEDATA_RAINRATE_STATE="$VALUE_RAININTENSITY_STATUS"
               STYLE_LIVE_VALUE=$STYLE_RAININTENSITY
              
               if [ "$LIVEDATA_RAINRATE_INTS10" -gt 0 ]; then
                    delimiter=$LV_DELIMITER 
                else
                    delimiter=" "
                fi
            
            #added space at end when doing when refreshing screen with printf \e[H, otherwise status is merged with previous value if changed
               padSpaceRight "$VALUE_RAININTENSITY" 8 
               
               printLivedataLine "$LIVEDATAHEADER_RAINRATE $delimiter $VALUE_PADSPACERIGHT"  "$LIVEDATA_RAINRATE" "$VALUE_RAIN_FMT"  "$LIVEDATAUNIT_RAINRATE" "%4s" 'rrate'  '' '' "$VALUE_RAININTENSITY_STATUS" 
            fi
        # rainhour available in Ecowitt http request
        [ -n "$LIVEDATA_RAINHOUR" ]     && printLivedataRainLine "$LIVEDATA_RAINHOUR_UINT16"  "$LIVEDATA_RAINHOUR_LIMIT"  "$LIVEDATAHEADER_RAINHOUR"  "$LIVEDATA_RAINHOUR" "$LIVEDATAUNIT_RAIN" 'rhour' "" "$STYLE_LIMIT_LIVEDATA_RAINHOUR"
        [ -n "$LIVEDATA_RAINDAY" ]      && printLivedataRainLine "$LIVEDATA_RAINDAY_INTS10"   "$LIVEDATA_RAINDAY_LIMIT"   "$LIVEDATAHEADER_RAINDAY"   "$LIVEDATA_RAINDAY"  "$LIVEDATAUNIT_RAIN" 'rday' "" "$STYLE_LIMIT_LIVEDATA_RAINDAY"
        [ -n "$LIVEDATA_RAINEVENT" ]    && printLivedataRainLine "$LIVEDATA_RAINEVENT_INTS10" "$LIVEDATA_RAINEVENT_LIMIT" "$LIVEDATAHEADER_RAINEVENT" "$LIVEDATA_RAINEVENT" "$LIVEDATAUNIT_RAIN" 'revent' "" "$STYLE_LIMIT_LIVEDATA_RAINEVENT"

        [ -n "$LIVEDATA_RAINWEEK" ]     && printLivedataLine "$LIVEDATAHEADER_RAINWEEK" "$LIVEDATA_RAINWEEK"    "$VALUE_RAIN_FMT" "$LIVEDATAUNIT_RAIN" "%3s" 'rweek' ''  "$LIVEDATA_WH40_RAINFALL_BATTERY" "$LIVEDATA_WH40_RAINFALL_BATTERY_STATE" "" "$LIVEDATA_WH40_RAINFALL_SIGNAL" "$LIVEDATA_WH40_RAINFALL_SIGNAL_STATE"
        [ -n "$LIVEDATA_RAINMONTH" ]    && printLivedataLine "$LIVEDATAHEADER_RAINMONTH" "$LIVEDATA_RAINMONTH"  "$VALUE_RAIN_FMT" "$LIVEDATAUNIT_RAIN" "%3s" 'rmonth' "$VALUE_RAIN_FMT"
        [ -n "$LIVEDATA_RAINYEAR" ]     && printLivedataLine "$LIVEDATAHEADER_RAINYEAR" "$LIVEDATA_RAINYEAR"    "$VALUE_RAIN_FMT" "$LIVEDATAUNIT_RAIN" "%3s" 'ryear'
        [ -n "$LIVEDATA_RAINTOTAL" ]    && printLivedataLine "$LIVEDATAHEADER_RAINTOTAL" "$LIVEDATA_RAINTOTAL"  "$VALUE_RAIN_FMT" "$LIVEDATAUNIT_RAIN" "%3s" 'rtotal' "$VALUE_RAIN_FMT"
    fi

    if [ -z "$LIVEVIEW_HIDE_SOILMOISTURE" ]; then
        [ -n "$LIVEDATA_SOILMOISTURE1" ] && printLivedataHeader "" "$LIVEDATAGROUPHEADER_SOILMOISTURE"
        n=1
        while [ "$n" -le "$SENSORTYPE_WH51SOILMOISTURE_MAXCH" ]; do
            eval "if [ -n ''"\$LIVEDATA_SOILMOISTURE$n" ]; then
                    #setSGIBatteryVoltage \"\$LIVEDATA_SOILMOISTURE${n}_BATTERY_UINT8\"
                    printLivedataLine  \"\$LIVEDATAHEADER_SOILMOISTURE$n\" \"\$LIVEDATA_SOILMOISTURE$n\" \"%6u\" \"%\" \"%4s\" \"sm$n\" \"%3u\" \"\$LIVEDATA_SOILMOISTURE${n}_BATTERY\" \"\$LIVEDATA_SOILMOISTURE${n}_BATTERY_STATE\" '' \"\$LIVEDATA_SOILMOISTURE${n}_SIGNAL\" \"\$LIVEDATA_SOILMOISTURE${n}_SIGNAL_STATE\"
                  fi "
            n=$((n + 1))
        done
    fi

    if [ -z "$LIVEVIEW_HIDE_SOILTEMPERATURE" ]; then

        [ -n "$LIVEDATA_SOILTEMP1" ] && printLivedataHeader "" "$LIVEDATAGROUPHEADER_SOILTEMP"
        n=1
        while [ "$n" -le "$SENSORTYPE_WH34SOILTEMP_MAXCH" ]; do
            eval "if [ -n ''"\$LIVEDATA_SOILTEMP$n" ]; then
                    #setSGIBatteryVoltage \"\$LIVEDATA_SOILTEMP${n}_BATTERY_UINT8\"
                    printLivedataLine \"\$LIVEDATAHEADER_SOILTEMP$n\" \"\$LIVEDATA_SOILTEMP$n\" \"%6.1f\" \"$LIVEDATAUNIT_TEMP\" \"%2s\" \"st$n\" '' \"\$LIVEDATA_SOILTEMP${n}_BATTERY\" \"\$LIVEDATA_SOILTEMP${n}_BATTERY_STATE\" '' \"\$LIVEDATA_SOILMOISTURE${n}_SIGNAL\" \"\$LIVEDATA_SOILMOISTURE${n}_SIGNAL_STATE\"
                  fi"
            n=$((n + 1))
        done
    fi
   
    if [ -z "$LIVEVIEW_HIDE_TEMPUSR" ]; then
       
       [ -n "$LIVEDATA_TF_USR1" ] && printLivedataHeader "" "$LIVEDATAGROUPHEADER_TEMPUSR"
        n=1
        while [ "$n" -le "$SENSORTYPE_WH31TEMP_MAXCH" ]; do
            eval "if [ -n ''"\$LIVEDATA_TF_USR$n" ]; then
                #setSGIBatteryVoltage \"\$LIVEDATA_TF_USR${n}_BATTERY_UINT8\"
                printLivedataLine \"\$LIVEDATAHEADER_TEMPF_USR$n\" \"\$LIVEDATA_TF_USR$n\" \"%6.1f\" \"\$LIVEDATAUNIT_TEMP\" \"%2s\" \"tusr$n\" '' \"\$LIVEDATA_TF_USR${n}_BATTERY\"  \"\$LIVEDATA_TF_USR${n}_BATTERY_STATE\" '' \"\$LIVEDATA_TF_USR${n}_SIGNAL\"  \"\$LIVEDATA_TF_USR${n}_SIGNAL_STATE\"
                fi"
            n=$((n + 1))
        done
    fi

    if [ -z "$LIVEVIEW_HIDE_LEAK" ]; then

        [ -n "$LIVEDATA_LEAK1" ] && printLivedataHeader "" "$LIVEDATAGROUPHEADER_LEAK"
        n=1
        while [ "$n" -le "$SENSORTYPE_WH55LEAK_MAXCH" ]; do
            #TEST eval LIVEDATA_LEAK$n=1
            #shellcheck disable=SC2034
            VALUE_LEAK=$LIVEDATAHEADER_LEAK_NO
            eval "if [ -n ''"\$LIVEDATA_LEAK$n" ]; then
                        #setSGIBatteryLowNormal \"\$LIVEDATA_LEAK${n}_BATTERY\"
                        [ \"\$LIVEDATA_LEAK$n\" -ne 0 ] && STYLE_LIVE_VALUE=\"$STYLE_LEAK\" && VALUE_LEAK=$LIVEDATAHEADER_LEAK_YES
                        LIVEDATAHEADER_LEAK$n=\"\$LIVEDATAHEADER_LEAK$n \$LV_DELIMITER \$VALUE_LEAK\"
                        printLivedataLine \"\$LIVEDATAHEADER_LEAK$n\" \"\$LIVEDATA_LEAK$n\" \"%6u\" \"\" \"%4s\" \"leak$n\" '' \"\$LIVEDATA_LEAK${n}_BATTERY\" \"\$LIVEDATA_LEAK${n}_BATTERY_STATE\" '' \"\$LIVEDATA_LEAK${n}_SIGNAL\" \"\$LIVEDATA_LEAK${n}_SIGNAL_STATE\"
                fi"
            n=$((n + 1))
        done
    fi

    if [ -z "$LIVEVIEW_HIDE_PM25" ]; then

        [ -n "$LIVEDATA_PM251" ] && printLivedataHeader "" "$LIVEDATAGROUPHEADER_PM25"
        n=1
        while [ "$n" -le "$SENSORTYPE_WH43PM25_MAXCH" ]; do
            #shellcheck disable=SC2153
            eval "if [ -n ''"\$LIVEDATA_PM25$n" ]; then
                            #setSGIBatteryLowNormal \"\$LIVEDATA_PM25${n}_BATTERY\"
                            if [ -z \"\$LIVEVIEW_HIDE_PM25AQI\" ]; then
                                setAQI \"\$LIVEDATA_PM25${n}_INTS10\"
                                setStyleAQI \"\$LIVEDATA_PM25${n}_INTS10\"
                                STYLE_LIVE_VALUE=\$STYLE_AQI
                            else
                              unset LV_DELIMITER
                            fi
                            export LIVEDATA_PM25${n}_AQI=\"\$VALUE_PM25_AQI\"
                            padSpaceRight \"\$VALUE_PM25_AQI\" 13
                            printLivedataLine \"\$LIVEDATAHEADER_PM25$n  \$LV_DELIMITER \$VALUE_PADSPACERIGHT\" \"\$LIVEDATA_PM25$n\" \"%6.1f\" \"\$LIVEDATAUNIT_PM25\" \"%6s\" \"pm25$n\" '' \"\$LIVEDATA_PM25${n}_BATTERY\" \"\$LIVEDATA_PM25${n}_BATTERY_STATE\" '' \"\$LIVEDATA_PM25${n}_SIGNAL\" \"\$LIVEDATA_PM25${n}_SIGNAL_STATE\"
                 fi"
            n=$((n + 1))
        done

        n=1
        while [ "$n" -le "$SENSORTYPE_WH43PM25_MAXCH" ]; do
            eval "if [ -n ''"\$LIVEDATA_PM25${n}_24HAVG" ]; then
                        if [ -z \"\$LIVEVIEW_HIDE_PM25AQI\" ]; then
                            setAQI \"\$LIVEDATA_PM2${n}5_24HAVG_INTS10\"
                            setStyleAQI \"\$LIVEDATA_PM25${n}_24HAVG_INTS10\"
                            STYLE_LIVE_VALUE=\$STYLE_AQI
                        else
                            unset LV_DELIMITER
                        fi
                        export LIVEDATA_PM25${n}_AQI_24HAVG=\"\$VALUE_PM25_AQI\"
                        printLivedataLine \"\$LIVEDATAHEADER_PM25${n}_24HAVG\$LV_DELIMITER \$VALUE_PM25_AQI\" \"\$LIVEDATA_PM25${n}_24HAVG\" \"%6.1f\" \"\$LIVEDATAUNIT_PM25\" \"%6s\" \"pm25a$n\" \"%6.1f\"
             fi"
            n=$((n + 1))
        done
    fi

    if [ -z "$LIVEVIEW_HIDE_CO2" ]; then

        #WH45
        if [ -n "$LIVEDATA_WH45CO2_TEMPF" ]; then
             #setSGIBatteryLowNormal "$LIVEDATA_WH45CO2_BATTERY"
             printLivedataHeader "" "$LIVEDATAGROUPHEADER_WH45CO2"
             printLivedataLine "$LIVEDATAHEADER_WH45CO2_TEMPF" "$LIVEDATA_WH45CO2_TEMPF"  "%6.1f" "$LIVEDATAUNIT_TEMP" "%2s" 'temp' '' "$LIVEDATA_WH45CO2_BATTERY" "$LIVEDATA_WH45CO2_BATTERY_STATE" "" "$LIVEDATA_WH45CO2_SIGNAL" "$LIVEDATA_WH45CO2_SIGNAL_STATE"
        fi

        [ -n "$LIVEDATA_WH45CO2_HUMI" ]         && printLivedataLine "$LIVEDATAHEADER_WH45CO2_HUMI" "$LIVEDATA_WH45CO2_HUMI"                "%6u" "$LIVEDATAUNIT_HUMIDITY" "%4s" 'humi'
        [ -n "$LIVEDATA_WH45CO2_PM10" ]         && printLivedataLine "$LIVEDATAHEADER_WH45CO2_PM10" "$LIVEDATA_WH45CO2_PM10"                "%6.1f" "$LIVEDATAUNIT_PM25" "%7s" 'pm10'
        [ -n "$LIVEDATA_WH45CO2_PM10_24HAVG" ]  && printLivedataLine "$LIVEDATAHEADER_WH45CO2_PM10_24HAVG" "$LIVEDATA_WH45CO2_PM10_24HAVG"  "%6.1f" "$LIVEDATAUNIT_PM25" "%7s" 'pm10a'
        if [ -n "$LIVEDATA_WH45CO2_PM25" ]; then
            setAQI "$LIVEDATA_WH45CO2_PM25_INTS10"
            setStyleAQI "$LIVEDATA_WH45CO2_PM25_INTS10"
            STYLE_LIVE_VALUE=$STYLE_AQI
            LIVEDATAHEADER_WH45CO2_PM25="$LIVEDATAHEADER_WH45CO2_PM25 $LV_DELIMITER $VALUE_PM25_AQI"
            printLivedataLine "$LIVEDATAHEADER_WH45CO2_PM25" "$LIVEDATA_WH45CO2_PM25"                "%6.1f" "$LIVEDATAUNIT_PM25" "%7s" 'pm25'
        fi
        if [ -n "$LIVEDATA_WH45CO2_PM25_24HAVG" ]; then
            setAQI "$LIVEDATA_WH45CO2_PM25_24HAVG_INTS10"
            setStyleAQI "$LIVEDATA_WH45CO2_PM25_24HAVG_INTS10"
            STYLE_LIVE_VALUE=$STYLE_AQI
            LIVEDATAHEADER_WH45CO2_PM25_24HAVG="$LIVEDATAHEADER_WH45CO2_PM25_24HAVG $LV_DELIMITER $VALUE_PM25_AQI"
            printLivedataLine "$LIVEDATAHEADER_WH45CO2_PM25_24HAVG" "$LIVEDATA_WH45CO2_PM25_24HAVG"  "%6.1f" "$LIVEDATAUNIT_PM25" "%7s" 'pm25a'
        fi
        [ -n "$LIVEDATA_WH45CO2_CO2" ]          && printLivedataLine "$LIVEDATAHEADER_WH45CO2_CO2" "$LIVEDATA_WH45CO2_CO2"                  "%6u" "$LIVEDATAUNIT_WH45CO2" "%6s" 'co2'
        [ -n "$LIVEDATA_WH45CO2_CO2_24HAVG" ]   && printLivedataLine "$LIVEDATAHEADER_WH45CO2_CO2_24HAVG" "$LIVEDATA_WH45CO2_CO2_24HAVG"           "%6u" "$LIVEDATAUNIT_WH45CO2" "%6s" 'co2a'
    fi

    if [ -z "$LIVEVIEW_HIDE_LIGHTNING" ]; then

        if [ -n "$LIVEDATA_LIGHTNING_DISTANCE" ]; then
            printLivedataHeader "" "$LIVEDATAGROUPHEADER_LIGHTNING"
            printLivedataLine "$LIVEDATAHEADER_LIGHTNING_DISTANCE" "$LIVEDATA_LIGHTNING_DISTANCE"    "%6u" "km" "%5s" 'ldist' '' "$LIVEDATA_WH57_LIGHTNING_BATTERY" "$LIVEDATA_WH57_LIGHTNING_BATTERY_STATE" '' "$LIVEDATA_WH57_LIGHTNING_SIGNAL" "$LIVEDATA_WH57_LIGHTNING_SIGNAL_STATE" 
        fi
        [ -n "$LIVEDATA_LIGHTNING_TIME" ]       && printLivedataLine "$LIVEDATAHEADER_LIGHTNING_TIME_UTC" "$LIVEDATA_LIGHTNING_TIME_UTC"    "%19s" "" "%5s" "lightningutc" 
        [ -n "$LIVEDATA_LIGHTNING_POWER" ]      && printLivedataLine "$LIVEDATAHEADER_LIGHTNING_POWER" "$LIVEDATA_LIGHTNING_POWER"          "%6u" "" "%5s" 'lpower' "%6u"
    
    fi

    if [ -z "$LIVEVIEW_HIDE_LEAFWETNESS" ]; then
        [ -n "$LIVEDATA_LEAFWETNESS1" ] && printLivedataHeader "" "$LIVEDATAGROUPHEADER_LEAFWETNESS"
        n=1
        while [ "$n" -le "$SENSORTYPE_WH35LEAFWETNESS_MAXCH" ]; do
            eval "if [ -n ''"\$LIVEDATA_LEAFWETNESS$n" ]; then
                    #setSGIBatteryVoltage \"\$LIVEDATA_LEAFWETNESS${n}_BATTERY_UINT8\"
                    printLivedataLine \"\$LIVEDATAHEADER_LEAFWETNESS$n\" \"\$LIVEDATA_LEAFWETNESS$n\" \"%6u\" \"%\" \"%4s\"  \"leaf$n\" '' \"\$LIVEDATA_LEAFWETNESS${n}_BATTERY\" \"\$LIVEDATA_LEAFWETNESS${n}_BATTERY_STATE\" '' \"\$LIVEDATA_LEAFWETNESS${n}_SIGNAL\" \"\$LIVEDATA_LEAFWETNESS${n}_SIGNAL_STATE\"
            fi"
            n=$((n + 1))
        done
    fi

    #battery

    if [ -z "$HIDE_BATTERY_LIVEDATA" ]; then
      :
       # printLivedataBatteryLowNormal "$LIVEDATA_WH65_BATTERY" "$LIVEDATA_WH65_BATTERY_STATE" "LIVEDATAHEADER_WH65_BATTERY" 'bwh65'
       # printLivedataBatteryVoltage   "$LIVEDATA_WH68_BATTERY" "$LIVEDATA_WH68_BATTERY_STATE" "LIVEDATAHEADER_WH68_BATTERY" 'bwh68'
       # printLivedataBatteryVoltage   "$LIVEDATA_WH80_BATTERY" "$LIVEDATA_WH80_BATTERY_STATE" "LIVEDATAHEADER_WH68_BATTERY"  'bwh80'
       # printLivedataBatteryLowNormal "$LIVEDATA_WH32_TEMPERATURE_BATTERY" "$LIVEDATA_WH32_TEMPERATURE_BATTERY_STATE" "LIVEDATAHEADER_WH32_TEMPERATURE_BATTERY" 'btout' 
       # printLivedataBatteryLowNormal "$LIVEDATA_WH40_RAINFALL_BATTERY" "$LIVEDATA_WH40_RAINFALL_BATTERY_STATE" "LIVEDATAHEADER_WH40_RAINFALL_BATTERY" 'brain'
        #printLivedataBatteryLowNormal "$LIVEDATA_WH57_LIGHTNING_BATTERY" "$LIVEDATA_WH57_LIGHTNING_BATTERY_STATE" "LIVEDATAHEADER_WH57_LIGHTNING_BATTERY" 'bwh57'
     
    fi

    #system
    
    if [ -z "$LIVEVIEW_HIDE_SYSTEM" ]; then
        
       [ -n "$LIVEDATA_SYSTEM_HOST" ] &&  printLivedataHeader "" "$LIVEDATAGROUPHEADER_SYSTEM" # -g host option

        [ -n "$LIVEDATA_SYSTEM_HOST" ] && printLivedataLine "$LIVEDATAHEADER_SYSTEM_HOST"   "$LIVEDATA_SYSTEM_HOST"   "%-14s" "" "%5s" 'host'
        [ -n "$LIVEDATA_SYSTEM_MAC" ] && printLivedataLine "$LIVEDATAHEADER_SYSTEM_MAC"   "$LIVEDATA_SYSTEM_MAC"   "%-14s" "" "%5s" 'mac'
        
        [ -n "$LIVEDATA_SYSTEM_VERSION" ]   && printLivedataLine "$LIVEDATAHEADER_SYSTEM_VERSION"   "$LIVEDATA_SYSTEM_VERSION"   "%-14s" "" "%5s" 'version'
        [ -n "$LIVEDATA_SYSTEM_MODEL" ]     && printLivedataLine "$LIVEDATAHEADER_SYSTEM_MODEL"     "$LIVEDATA_SYSTEM_MODEL"     "%-7s"  "" "%5s" 'model'
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
        
        [ -n "$LIVEDATA_SYSTEM_FREQUENCY" ] && printLivedataLine "$LIVEDATAHEADER_SYSTEM_FREQUENCY" "$LIVEDATA_SYSTEM_FREQUENCY" "%-7s"  "" "%5s" 'freq' 
        [ -n "$LIVEDATA_SYSTEM_SENSORTYPE" ] && printLivedataLine "$LIVEDATAHEADER_SYSTEM_SENSORTYPE" "$LIVEDATA_SYSTEM_SENSORTYPE" "%4s" "" "%4s" 'type' '' "$LIVEDATA_WH65_BATTERY" "$LIVEDATA_WH65_BATTERY_STATE" "" "$LIVEDATA_WH65_SIGNAL" "$LIVEDATA_WH65_SIGNAL_STATE"
   
       # setLivedataProtocolStyle "$LIVEDATA_SYSTEM_PROTOCOL"
       # space=' '
       # [ -z "$LIVEDATA_SYSTEM_PROTOCOL_VERSION" ] && unset space
       #    STYLE_LIVE_VALUE=$VALUE_STYLE_PROTOCOL   printLivedataLine "$LIVEDATAHEADER_SYSTEM_PROTOCOL" "$LIVEDATA_SYSTEM_PROTOCOL_LONG$space$LIVEDATA_SYSTEM_PROTOCOL_VERSION" "%s" 
       
        [ -n "$LIVEDATA_SENSOR_COUNT_CONNECTED" ] && STYLE_LIVE_VALUE=$STYLE_SENSOR_CONNECTED printLivedataLineFinal "$LIVEDATAHEADER_SYSTEM_SENSOR_CONNECTED" "$LIVEDATA_SENSOR_COUNT_CONNECTED" "%2u"
        [ -n "$LIVEDATA_SENSOR_COUNT_DISCONNECTED" ] && STYLE_LIVE_VALUE=$STYLE_SENSOR_DISCONNECTED printLivedataLineFinal "$LIVEDATAHEADER_SYSTEM_SENSOR_DISCONNECTED" "$LIVEDATA_SENSOR_COUNT_DISCONNECTED" "%2u"
        [ -n "$LIVEDATA_SENSOR_COUNT_SEARCHING" ] && STYLE_LIVE_VALUE=$STYLE_SENSOR_SEARCH    printLivedataLine "$LIVEDATAHEADER_SYSTEM_SENSOR_SEARCHING" "$LIVEDATA_SENSOR_COUNT_SEARCHING" "%2u"
        [ -n "$LIVEDATA_SENSOR_COUNT_DISABLED" ] && STYLE_LIVE_VALUE=$STYLE_SENSOR_DISABLE   printLivedataLine "$LIVEDATAHEADER_SYSTEM_SENSOR_DISABLED" "$LIVEDATA_SENSOR_COUNT_DISABLED" "%2u"

    fi

    #WH68 sa,WH80 sa,WH40 rfall,WH32 tout
   # printLivedataLine '' "$LIVEDATA_WH68_BATTERY" "$LIVEDATA_WH45CO2_BATTERY_STATE" "" "$LIVEDATA_WH45CO2_SIGNAL" "$LIVEDATA_WH45CO2_SIGNAL_STATE"
  
    printAppendBuffer

    #unset local variables for ksh -> made global by using () function syntax without function keyword
    #https://www.unix.com/shell-programming-and-scripting/137435-ksh-different-syntax-function.html
    #man ksh93: ksh93 uses static scoping (one global scope, one local scope per function) and allows local variables only on Korn style functions
    
    unset n delimiter space
}

newLivedataCompass()
#$1 unicode direction, $2 - wind direction 
{
    #set -- "$1" "$WIND_ESE"

    style_needle=$STYLE_COMPASS_WIND$1$STYLE_RESET
    
    if [ -z "$KSH_VERSION" ]; then
       LIVEDATA_WINDDIRECTION_COMPASS_N_FMT="╭─$STYLE_COMPASS_NORTH$WIND_DIRECTION_N$STYLE_RESET─╮" #styling must be in the format of printf
    else
        LIVEDATA_WINDDIRECTION_COMPASS_N_FMT="╭─$STYLE_COMPASS_NORTH$WIND_DIRECTION_N$STYLE_RESET\u2500╮" #ksh Version AJM 93u+ 2012-08-01 insert \x80 instead of unicode 2500 ?! bug?
    fi
       
    LIVEDATA_WINDDIRECTION_COMPASS_WE_FMT="$WIND_DIRECTION_W $style_needle $WIND_DIRECTION_E"

    if [ -z "$KSH_VERSION" ]; then
        LIVEDATA_WINDDIRECTION_COMPASS_S_FMT="╰─$WIND_DIRECTION_S─╯"
    else
        LIVEDATA_WINDDIRECTION_COMPASS_S_FMT="╰─$WIND_DIRECTION_S\u2500╯"
    fi

    export LIVEDATA_WINDDIRECTION_COMPASS_N_FMT LIVEDATA_WINDDIRECTION_COMPASS_WE_FMT LIVEDATA_WINDDIRECTION_COMPASS_S_FMT

    unset style_needle
}

printLivedataRainLine()
{
    #echo "printLivedataRainLine $*"

    [ "$DEBUG" -eq 1 ] && echo >&2 printLivedataRainLine raw value : "$1" limit: "$2"

    if [ "$1" -gt "$2" ] && [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
        setLivedataValueStyleGt "$1" "$2" "$8"
        printLivedataLine "$3" "$4" "$VALUE_RAIN_FMT" "$5" "%5s" "$6" "%6.1f" "$1" "$7"
    else
        printLivedataLine "$3" "$4" "$VALUE_RAIN_FMT"  "$5" "%5s" "$6" "%6.1f"
    fi
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
            STYLE_LIVE_VALUE=$STYLE_LIMIT_LIVEDATA
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
            STYLE_LIVE_VALUE=$STYLE_LIMIT_LIVEDATA
        else
            STYLE_LIVE_VALUE=$3
        fi
    fi
}

printLivedataSystem()
{
    setLivedataProtocolStyle "$LIVEDATA_SYSTEM_PROTOCOL"

    appendBuffer "%s %s $VALUE_STYLE_PROTOCOL%s$STYLE_RESET" "'$LIVEDATA_SYSTEM_VERSION' '$LIVEDATA_SYSTEM_FREQUENCY' '$LIVEDATA_SYSTEM_PROTOCOL'"
    
    if [ -n "$LIVEDATA_SENSOR_COUNT_CONNECTED" ]; then
       appendBuffer " %s/$STYLE_SENSOR_SEARCH%s$STYLE_RESET/$STYLE_SENSOR_DISABLE%s$STYLE_RESET" "'$LIVEDATA_SENSOR_COUNT_CONNECTED' '$LIVEDATA_SENSOR_COUNT_SEARCHING' '$LIVEDATA_SENSOR_COUNT_DISABLED' "
    fi
   
    printWHBatterySignal "WH65" "$LIVEDATA_WH65_BATTERY_STATE" "$LIVEDATA_WH65_SIGNAL_STATE"
    #set in getSensorBatteryState
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

      "$LIVEDATA_PROTOCOL_ECOWITT_HTTP"|"$LIVEDATA_PROTOCOL_ECOWITT_BINARY")
            VALUE_STYLE_PROTOCOL=$STYLE_PROTOCOL_ECOWITT_HTTP
            ;;
      "$LIVEDATA_PROTOCOL_WUNDERGROUND_HTTP")
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

