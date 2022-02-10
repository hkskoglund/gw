#!/usr/bin/sh

parseVersion() {
    readString
    C_VERSION="$VALUE_STRING"
    echo "$C_VERSION"
}

parseMAC() {
    
    readSlice 6
   
    C_MAC="$B1HEX:$B2HEX:$B3HEX:$B4HEX:$B5HEX:$B6HEX"
    echo "$C_MAC"
}

parseResult() {
    
    readUInt8
    write_result=$VALUE_UINT8
    VALUE_PACKET_WRITE_RESULT=$write_result

    if [ "$write_result" -eq 0 ]; then
    :
     #   echo >&2 "$COMMAND_NAME OK"
    elif [ "$write_result" -eq 1 ]; then
        echo >&2 "$COMMAND_NAME FAIL"
    fi

    unset write_result

}

printBroadcast() {
   # if [ "$SHELL_SUPPORT_BULTIN_PRINTF" -eq 1 ]; then
   #    printf "%-25s %s\n%-25s %s\n%-25s %s\n%-25s %s\n%-25s %s\n" "broadcast mac" "$C_BROADCAST_MAC"\
   #    "broadcast ip" "$C_BROADCAST_IP" "broadcast port" "$C_BROADCAST_PORT" "broadcast ssid" "$C_BROADCAST_SSID" "broadcast version" "$C_BROADCAST_VERSION"
   # else
      echo "$C_BROADCAST_MAC $C_BROADCAST_IP $C_BROADCAST_PORT $C_BROADCAST_SSID $C_BROADCAST_VERSION"
    #fi
}

parseBroadcast() {

    readSlice 12
    #this is the station MAC/ip on local network.
    #Observation: when device is reset its annoncing hotspot accesspoint/AP with first byte of MAC changed

    C_BROADCAST_MAC="$B1HEX:$B2HEX:$B3HEX:$B4HEX:$B5HEX:$B6HEX"
    C_BROADCAST_IP="$B7.$B8.$B9.$B10"
    C_BROADCAST_PORT="$(( (B11 << 8) | B12 ))"

    readString
    #https://stackoverflow.com/questions/1469849/how-to-split-one-string-into-multiple-strings-separated-by-at-least-one-space-in
    #shellcheck disable=SC2086
    set -- $VALUE_STRING # -- assign words to positional parameters
    C_BROADCAST_SSID=$1
    C_BROADCAST_VERSION=$2

    printBroadcast
}

printEcowittInterval() {

    if [ "$C_WS_ECOWITT_INTERVAL" -eq 1 ]; then
        echo "ecowitt interval              $C_WS_ECOWITT_INTERVAL minute"
    elif [ "$C_WS_ECOWITT_INTERVAL" -gt 1 ]; then
        echo "ecowitt interval              $C_WS_ECOWITT_INTERVAL minutes"
    fi
}

parseEcowittInterval() {

    readUInt8
    C_WS_ECOWITT_INTERVAL=$VALUE_UINT8
    printEcowittInterval
}

printWunderground() {
    echo "wunderground station id       $C_WS_WUNDERGROUND_ID
wunderground station password $C_WS_WUNDERGROUND_PASSWORD"
}

parseWunderground() {
    readString
    C_WS_WUNDERGROUND_ID=$VALUE_STRING
    readString
    C_WS_WUNDERGROUND_PASSWORD=$VALUE_STRING

    printWunderground
}

printWeathercloud() {
    echo "weathercloud id               $C_WS_WC_ID
weathercloud password         $C_WS_WC_PASSWORD"
}

parseWeathercloud() {
    readString
    C_WS_WC_ID=$VALUE_STRING

    readString
    C_WS_WC_PASSWORD=$VALUE_STRING

    printWeathercloud
}

printWow() {
    echo "wow id                        $C_WS_WOW_ID
wow password                  $C_WS_WOW_PASSWORD"
}

parseWow() {
    readString
    C_WS_WOW_ID=$VALUE_STRING

    readString
    C_WS_WOW_PASSWORD=$VALUE_STRING

    printWow
}

printCalibration() {
    #if [ "$SHELL_SUPPORT_BULTIN_PRINTF" -eq 1 ]; then
    #   printf "%-40s %7s %-4s\n%-40s %7s %-4s\n%-40s %7s %-4s\n%-40s %7s %-4s\n%-40s %7s %-4s\n%-40s %7s %-4s\n%-40s %7s %-4s\n"\
    #    "calibration in temperature offset"           "$C_CALIBRATION_INTEMPOFFSET"     "$UNIT_TEMP"\
    #    "calibration in humidity offset"              "$C_CALIBRATION_INHUMIDITYOFFSET"   "$UNIT_HUMIDITY"\
    #    "calibration absolute pressure offset"        "$C_CALIBRATION_ABSOFFSET"        "$UNIT_PRESSURE"\
    #    "calibration relative pressure offset"        "$C_CALIBRATION_RELOFFSET"        "$UNIT_PRESSURE"\
    #    "calibration out temperature offset"          "$C_CALIBRATION_OUTTEMPOFFSET"    "$UNIT_TEMP"\
    ##    "calibration out humidity offset"             "$C_CALIBRATION_OUTHUMIDITYOFFSET" "$UNIT_HUMIDITY"\
    #    "calibration wind direction offset"           "$C_CALIBRATION_WINDDIROFFSET" ""
    #else
        echo "calibration in temperature offset           $C_CALIBRATION_INTEMPOFFSET $UNIT_TEMP
calibration in humidity offset              $C_CALIBRATION_INHUMIDITYOFFSET   %
calibration absolute pressure offset        $C_CALIBRATION_ABSOFFSET $UNIT_PRESSURE
calibration relative pressure offset        $C_CALIBRATION_RELOFFSET $UNIT_PRESSURE
calibration out temperature offset          $C_CALIBRATION_OUTTEMPOFFSET $UNIT_TEMP
calibration out humidity offset             $C_CALIBRATION_OUTHUMIDITYOFFSET   %
calibration wind direction offset           $C_CALIBRATION_WINDDIROFFSET" 
   # fi

}

parseCalibration() {

    readInt16BE
    convertScale10ToFloat "$VALUE_INT16BE"
    C_CALIBRATION_INTEMPOFFSET_INT="$VALUE_INT16BE"
    C_CALIBRATION_INTEMPOFFSET="$VALUE_SCALE10_FLOAT"

    readInt8
    C_CALIBRATION_INHUMIDITYOFFSET="$VALUE_INT8"

    readInt32BE
    C_CALIBRATION_ABSOFFSET_INT=$VALUE_INT32BE 
    convertScale10ToFloat "$VALUE_INT32BE"
    C_CALIBRATION_ABSOFFSET="$VALUE_SCALE10_FLOAT"

    readInt32BE
    C_CALIBRATION_RELOFFSET_INT=$VALUE_INT32BE #used for int comparison [ ... ]
    convertScale10ToFloat "$VALUE_INT32BE"
    C_CALIBRATION_RELOFFSET="$VALUE_SCALE10_FLOAT"

    readInt16BE
    C_CALIBRATION_OUTTEMPOFFSET_INT="$VALUE_INT16BE"
    convertScale10ToFloat "$VALUE_INT16BE"
    C_CALIBRATION_OUTTEMPOFFSET="$VALUE_SCALE10_FLOAT"

    readInt8
    C_CALIBRATION_OUTHUMIDITYOFFSET="$VALUE_INT8"

    readInt16BE
    C_CALIBRATION_WINDDIROFFSET="$VALUE_INT16BE"

    printCalibration
}

printCustomized() {
    if [ "$C_WS_CUSTOMIZED_HTTP" -eq $HTTP_WUNDERGROUND ]; then #wunderground
    echo "id                 $C_WS_CUSTOMIZED_ID
password           $C_WS_CUSTOMIZED_PASSWORD"
fi

    echo "server             $C_WS_CUSTOMIZED_SERVER
port               $C_WS_CUSTOMIZED_PORT
interval           $C_WS_CUSTOMIZED_INTERVAL
http               $C_WS_CUSTOMIZED_HTTP $C_WS_CUSTOMIZED_HTTP_STATE 
enabled            $C_WS_CUSTOMIZED_ENABLED $C_WS_CUSTOMIZED_ENABLED_STATE"

if [ "$C_WS_CUSTOMIZED_HTTP" -eq $HTTP_ECOWITT ]; then
    echo "path ecowitt       $C_WS_CUSTOMIZED_PATH_ECOWITT"
else
    echo "path wunderground  $C_WS_CUSTOMIZED_PATH_WU"
fi
}

parseCustomized() {
    readString
    C_WS_CUSTOMIZED_ID=$VALUE_STRING

    readString
    C_WS_CUSTOMIZED_PASSWORD=$VALUE_STRING

    readString
    C_WS_CUSTOMIZED_SERVER=$VALUE_STRING

    readUInt16BE
    C_WS_CUSTOMIZED_PORT=$VALUE_UINT16BE

    readUInt16BE
    C_WS_CUSTOMIZED_INTERVAL=$VALUE_UINT16BE

    readUInt8
    C_WS_CUSTOMIZED_HTTP=$VALUE_UINT8

    if [ "$C_WS_CUSTOMIZED_HTTP" -eq 1 ]; then
        C_WS_CUSTOMIZED_HTTP_STATE="wunderground"
    elif [ "$C_WS_CUSTOMIZED_HTTP" -eq 0 ]; then
        C_WS_CUSTOMIZED_HTTP_STATE="ecowitt"
    fi

    readUInt8

    C_WS_CUSTOMIZED_ENABLED=$VALUE_UINT8
    if [ "$C_WS_CUSTOMIZED_ENABLED" -eq 1 ]; then
        C_WS_CUSTOMIZED_ENABLED_STATE="on"
    elif [ "$C_WS_CUSTOMIZED_ENABLED" -eq 0 ]; then
        C_WS_CUSTOMIZED_ENABLED_STATE="off"
    fi

    printCustomized
}

printPath() {
    echo "path ecowitt      $C_WS_CUSTOMIZED_PATH_ECOWITT
path wunderground $C_WS_CUSTOMIZED_PATH_WU"
}

parsePath() {
    readString
    C_WS_CUSTOMIZED_PATH_ECOWITT=$VALUE_STRING
    readString
    C_WS_CUSTOMIZED_PATH_WU=$VALUE_STRING

    printPath
}

printRaindata() {

    convertScale10ToFloat "$C_RAINRATE"
    rr="$VALUE_SCALE10_FLOAT"

    convertScale10ToFloat "$C_RAINDAILY"
    rd="$VALUE_SCALE10_FLOAT"
    
    convertScale10ToFloat "$C_RAINWEEK"
    rw="$VALUE_SCALE10_FLOAT"
    
    convertScale10ToFloat "$C_RAINMONTH"
    rm="$VALUE_SCALE10_FLOAT"
    
    convertScale10ToFloat "$C_RAINYEAR"
    ry="$VALUE_SCALE10_FLOAT"
    
    echo "rain rate  $rr $UNIT_RAINRATE
rain day   $rd $UNIT_RAIN
rain week  $rw $UNIT_RAIN
rain month $rm $UNIT_RAIN
rain year  $ry $UNIT_RAIN"
   
    unset rr rd rw rm ry
}

parseRaindata() {

    readUInt32BE
    C_RAINRATE=$VALUE_UINT32BE

    readUInt32BE
    C_RAINDAILY=$VALUE_UINT32BE

    readUInt32BE
    C_RAINWEEK=$VALUE_UINT32BE

    readUInt32BE
    C_RAINMONTH=$VALUE_UINT32BE

    readUInt32BE
    C_RAINYEAR=$VALUE_UINT32BE

    printRaindata
}

printSensorLine()
#$1 - sensortype, $2 sensor id, $3 battery, $4 signal
{
#observation: leak sensor signal -> starts at level 1 after search state, then increases +1 each time a new rf message is received

    unset SBATTERY_STATE

    getSensorNameShort "$1"
    
   # TEST data 
    #if [ "$1" -eq 40 ]; then
    #   set -- "39" "$(( 0xfff ))" 4 4  # co2
    #  set -- "40" "$(( 0xfff ))" 14 4 # leaf wetness
    #fi

    if [ "$2" -eq "$SENSORID_DISABLE" ]; then 
      style_sensor=$STYLE_SENSOR_DISABLE
      sensorIdState=$SENSORIDSTATE_DISABLED
    elif [ "$2" -eq "$SENSORID_SEARCH" ]; then
      style_sensor=$STYLE_SENSOR_SEARCH
      sensorIdState=$SENSORIDSTATE_SEARCHING
    else
        unset style_sensor
       getSensorBatteryState "$1" "$3"
       if [ "$4" -gt 0 ]; then 
            sensorIdState=$SENSORIDSTATE_CONNECTED
        else
            style_sensor=$STYLE_SENSOR_DISCONNECTED
            sensorIdState=$SENSORIDSTATE_DISCONNECTED
        fi

       if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
            getSignalUnicode "$4"
            sensorsignal_unicode=$VALUE_SIGNAL_UNICODE
           # unicode e2 96 81 e2 96 82 e2 96 83 e2 96 84 -> each symbol 3 bytes, minimum field size = 4*3 = 12
        fi
    fi

    if [ -n "$style_sensor" ]; then
       style_sensor_off=$STYLE_RESET # insert end escape sequence only if sgi is used
    fi
    
     # 1 battery unicode is field size 4 in printf format string. TEST printf  "🔋 1.3 V" | od -A n -t x1 | wc -w -> 10
     # use \r\t\t\t workaround for unicode alignment
  
    appendBuffer "%6u %9x %3u %1u %4s %-17s $style_sensor%-12s$style_sensor_off\t%s\t%s\n"\
 "'$1' '$2' '$3' '$4'  '$SENSORNAME_WH' '$SENSORNAME_SHORT' '$sensorIdState' '$SBATTERY_STATE' '$sensorsignal_unicode'"
    
    unset sensorIdState sensorsignal_unicode style_sensor_off style_sensor
}

parseSensorIdNew()
{
    resetAppendBuffer

    printSensorHeader=0
    if [ -z "$SENSORVIEW_HIDE_HEADER" ];  then 
       printSensorHeader=1
    elif [ "$SENSORVIEW_HIDE_HEADER" -eq 0 ]; then
       printSensorHeader=1
    fi

    if [ $printSensorHeader -eq 1 ]; then
                      #1:Sensortype 2:sid 3:battery 4:signal 5:type 6:name 7:state 8:battery 9:signal
        appendBuffer "%6s %9s %3s %1s %-4s %-17s %-12s\t%s\t%s\n%s\n" "$SENSORID_HEADER ───────────────────────────────────────────────────────────────────────────────"
    fi

    [ "$DEBUG" -eq  1 ] && >&2 echo "parseSensorIdNew SPATTERNID $SPATTERNID length od buffer ${#OD_BUFFER}"
    
     LIVEDATA_SENSOR_COUNT_SEARCHING=0
     LIVEDATA_SENSOR_COUNT_CONNECTED=0
     LIVEDATA_SENSOR_COUNT_DISCONNECTED=0
     LIVEDATA_SENSOR_COUNT_DISABLED=0

    while [ ${#OD_BUFFER} -ge 7 ]; do
       
        readUInt8            #type
        stype=$VALUE_UINT8
       
        readUInt32BE         #id
        SID=$VALUE_UINT32BE

        readUInt8   
        battery=$VALUE_UINT8
        
        readUInt8
        signal=$VALUE_UINT8

        if [ $SID -eq $SENSORID_SEARCH ]; then
            LIVEDATA_SENSOR_COUNT_SEARCHING=$(( LIVEDATA_SENSOR_COUNT_SEARCHING + 1 ))
        elif [ $SID -eq $SENSORID_DISABLE ]; then
            LIVEDATA_SENSOR_COUNT_DISABLED=$(( LIVEDATA_SENSOR_COUNT_DISABLED + 1 ))
        elif [ $signal -gt 0 ]; then
            LIVEDATA_SENSOR_COUNT_CONNECTED=$(( LIVEDATA_SENSOR_COUNT_CONNECTED + 1 ))
            setLivedataSignal "$stype" "$signal"
        elif [ $signal -eq 0 ]; then
            LIVEDATA_SENSOR_COUNT_DISCONNECTED=$(( LIVEDATA_SENSOR_COUNT_DISCONNECTED + 1 ))
        fi

        #pattern matching
        printSensorMatch=0

        if [ "$SPATTERNID" = "$SPATTERNID_CONNECTED" ] && [ $SID -ne $SENSORID_SEARCH ] && [ $SID -ne $SENSORID_DISABLE ]; then # connected sensor
            printSensorMatch=1
        elif [ "$SPATTERNID" = "$SPATTERNID_DISCONNECTED" ] && [ $SID -ne $SENSORID_SEARCH ] && [ $SID -ne $SENSORID_DISABLE ] && [ $signal -eq 0 ]; then
            printSensorMatch=1
        elif [ "$SPATTERNID" = "$SPATTERNID_RANGE" ] && [ -n "$SPATTERNID_RANGE_LOW" ] && [ -n "$SPATTERNID_RANGE_HIGH" ] && [ $stype -ge "$SPATTERNID_RANGE_LOW" ] && [ $stype -le "$SPATTERNID_RANGE_HIGH" ]; then 
            printSensorMatch=1
        elif [ "$SPATTERNID" = "$SPATTERNID_SEARCHING" ] && [ $SID -eq "$SENSORID_SEARCH"  ]; then 
            printSensorMatch=1
        elif [ "$SPATTERNID" = "$SPATTERNID_DISABLED" ] && [ "$SID" -eq "$SENSORID_DISABLE" ]; then
            printSensorMatch=1
        elif [ -z "$SPATTERNID" ]; then #all sensors
            printSensorMatch=1
        fi

        if [ $printSensorMatch -eq 1 ]; then
            printSensorLine $stype $SID $battery $signal
        fi
        
        [ "$DEBUG" -eq 1 ] && >&2 echo "type $stype id $SID battery $battery signal $signal od_buffer length ${#OD_BUFFER}"
    done

    printAppendBuffer

    unset stype signal battery printSensorHeader printSensorMatch
}

printSystem() 
{
    printf "%-32.32s%10u\t%s\n\
%-32.32s%10u\t%s\n\
%-32.32s%10u\t%s\n\
%-32.32s%10u\t%.24s\n\
%-32.32s%10u\t%s\n\
%-32.32s%10u\t%s\n"\
            "$LIVEDATA_SYSTEM_FREQUENCY_HEADER" "$C_SYSTEM_FREQUENCY" "$C_SYSTEM_FREQUENCY_STATE"\
            "$LIVEDATA_SYSTEM_SENSORTYPE_HEADER"    "$C_SYSTEM_SENSORTYPE" "$C_SYSTEM_SENSORTYPE_STATE"\
            "$LIVEDATA_SYSTEM_UTC_HEADER" "$C_SYSTEM_UTC" "$C_SYSTEM_UTC_STATE"\
            "$LIVEDATA_SYSTEM_TIMEZONE_HEADER"  "$C_SYSTEM_TIMEZONE_INDEX" "$C_SYSTEM_TIMEZONE_INDEX_STATE"\
            "$LIVEDATA_SYSTEM_TIMEZONE_AUTO_HEADER" "$C_SYSTEM_TIMEZONE_AUTO_BIT" "$C_SYSTEM_TIMEZONE_AUTO_STATE"\
            "$LIVEDATA_SYSTEM_TIMEZONE_DST_HEADER" "$C_SYSTEM_TIMEZONE_DST_BIT" "$C_SYSTEM_TIMEZONE_DST_STATUS_STATE"
}

parseSystem() {
    readUInt8

    C_SYSTEM_FREQUENCY=$VALUE_UINT8
    if [ "$C_SYSTEM_FREQUENCY" -eq $SYSTEM_FREQUENCY_RFM433M ]; then
        C_SYSTEM_FREQUENCY_STATE="433"
    elif [ "$C_SYSTEM_FREQUENCY" -eq $SYSTEM_FREQUENCY_RFM868M ]; then
        C_SYSTEM_FREQUENCY_STATE="868"
    elif [ "$C_SYSTEM_FREQUENCY" -eq $SYSTEM_FREQUENCY_RFM915M ]; then
        C_SYSTEM_FREQUENCY_STATE="915"
    elif [ "$C_SYSTEM_FREQUENCY" -eq $SYSTEM_FREQUENCY_RFM920M ]; then
        C_SYSTEM_FREQUENCY_STATE="920"
    fi

    readUInt8

    C_SYSTEM_SENSORTYPE=$VALUE_UINT8
    if [ "$C_SYSTEM_SENSORTYPE" -eq $SYSTEM_SENSOR_TYPE_WH24 ]; then
        #       SENSOR_TYPE[WH24_TYPE]="WH24:Outdoor Weather Sensor:16.0:" # overwrite default WH65_TYPE=0
        C_SYSTEM_SENSORTYPE_STATE="WH24"
    elif [ "$C_SYSTEM_SENSORTYPE" -eq $SYSTEM_SENSOR_TYPE_WH65 ]; then
        C_SYSTEM_SENSORTYPE_STATE="WH65"
    fi

    readUInt32BE

    C_SYSTEM_UTC=$VALUE_UINT32BE
    C_SYSTEM_UTC_STATE="$(date -u -d @"$VALUE_UINT32BE" +'%F %T')"

    readUInt8

    C_SYSTEM_TIMEZONE_INDEX=$VALUE_UINT8

    eval "C_SYSTEM_TIMEZONE_INDEX_STATE=\$SYSTEM_TIMEZONE_$C_SYSTEM_TIMEZONE_INDEX" # set from SYSTEM_TIMEZONE "array" variable with index

    C_SYSTEM_TIMEZONE_OFFSET_HOURS=${C_SYSTEM_TIMEZONE_INDEX_STATE%%\)*} # remove )... 
    C_SYSTEM_TIMEZONE_OFFSET_HOURS=${C_SYSTEM_TIMEZONE_OFFSET_HOURS#\(UTC} # remove (UTC

    readUInt8

    C_SYSTEM_TIMEZONE_DST_STATUS=$VALUE_UINT8

    C_SYSTEM_TIMEZONE_DST_BIT=$((C_SYSTEM_TIMEZONE_DST_STATUS & 0x01))

    C_SYSTEM_TIMEZONE_AUTOOFF_BIT=$(((C_SYSTEM_TIMEZONE_DST_STATUS & 0x2) >> 1)) # bit 2 1= off, 0=on ?

    if [ $C_SYSTEM_TIMEZONE_AUTOOFF_BIT = 0 ]; then #invert
       C_SYSTEM_TIMEZONE_AUTO_BIT=1;
    else
        C_SYSTEM_TIMEZONE_AUTO_BIT=0
    fi

     [ -z "$C_NOPRINT" ] && printSystem

}

parseLivedata() { # ff ff 27 00 53 01 00 e1 06 25 08 27 b3 09 27 c2 02 00 05 07 5d 0a 01 59 0b 00 00 0c 00 00 15 00 00 93 bc 16 00 20 17 00 2c 12 1a 00 87 22 32 1b 00 b0 23 27 1c 00 dd 24 31 58 00 19 00 47 0e 00 00 10 00 08 11 00 42 12 00 00 02 9a 13 00 00 0f 8b 0d 00 42 63
    DEBUG_FUNC="parseLivedata"
    DEBUG_PARSE_LIVEDATA=${DEBUG_PARSE_LIVEDATA:=$DEBUG}
   
    LIVEDATA_SYSTEM_PROTOCOL=$LIVEDATA_PROTOCOL_ECOWITT_BINARY
    LIVEDATA_SYSTEM_PROTOCOL_LONG=$LIVEDATA_PROTOCOL_ECOWITT_BINARY_LONG

    while [ "${#OD_BUFFER}" -gt 4 ]; do

       # [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 Unparsed "$OD_BUFFER" length "${#OD_BUFFER}"

        readUInt8
        ldf=$VALUE_UINT8

        convertUInt8ToHex "$ldf"
        ldf_hex=$VALUE_UINT8_HEX
     
        if [ "$ldf" -eq $LDF_INTEMP ]; then

            readInt16BE
            export LIVEDATA_INTEMP_RAW=$VALUE_INT16BE
            convertTemperatureLivedata "$VALUE_INT16BE"
            export LIVEDATA_INTEMP="$VALUE_SCALE10_FLOAT" 
             [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex intemp int16be $LIVEDATA_INTEMP_RAW intemp $LIVEDATA_INTEMP $UNIT_UNICODE_CELCIUS"

        elif [ "$ldf" -eq $LDF_INHUMI ]; then

            readUInt8
            export LIVEDATA_INHUMI=$VALUE_UINT8
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex inhumi uint8 $LIVEDATA_INHUMI $UNIT_HUMIDITY"


        elif [ "$ldf" -eq $LDF_ABSBARO ]; then

            readUInt16BE
            #shellcheck disable=SC2034
            export LIVEDATA_ABSBARO_RAW=$VALUE_UINT16BE #may use for ansi escape coloring beyond limits
            convertPressureLivedata "$VALUE_UINT16BE"
            export LIVEDATA_ABSBARO="$VALUE_SCALE10_FLOAT"
            
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex absbaro int16be $LIVEDATA_ABSBARO_RAW absbaro $LIVEDATA_ABSBARO $UNIT_UNICODE_PRESSURE_HPA"


        elif [ "$ldf" -eq $LDF_RELBARO ]; then

            readUInt16BE
            export LIVEDATA_RELBARO_RAW=$VALUE_UINT16BE
            convertPressureLivedata "$VALUE_UINT16BE"
            export LIVEDATA_RELBARO="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex relbaro int16be $LIVEDATA_RELBARO_RAW relbaro $LIVEDATA_RELBARO  $UNIT_UNICODE_PRESSURE_HPA"


        elif [ "$ldf" -eq $LDF_OUTTEMP ]; then

            readInt16BE
            export LIVEDATA_OUTTEMP_RAW=$VALUE_INT16BE
            convertTemperatureLivedata "$VALUE_INT16BE" 
            export LIVEDATA_OUTTEMP="$VALUE_SCALE10_FLOAT"
            
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex outtemp int16be $LIVEDATA_OUTTEMP_RAW outtemp $LIVEDATA_OUTTEMP $UNIT_UNICODE_CELCIUS"


        elif [ "$ldf" -eq $LDF_OUTHUMI ]; then

            readUInt8
            export LIVEDATA_OUTHUMI=$VALUE_UINT8
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex outhumi uint8 $LIVEDATA_OUTHUMI $UNIT_HUMIDITY"


        elif [ "$ldf" -eq $LDF_WINDDIRECTION ]; then

            readUInt16BE
            export LIVEDATA_WINDDIRECTION=$VALUE_UINT16BE
            convertWindDirectionToCompassDirection "$LIVEDATA_WINDDIRECTION"
            export LIVEDATA_WINDDIRECTION_COMPASS="$VALUE_COMPASS_DIRECTION"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex winddirection uint16BE $LIVEDATA_WINDDIRECTION $UNIT_DEGREE"


        elif [ "$ldf" -eq $LDF_WINDSPEED ]; then

            readUInt16BE
            export LIVEDATA_WINDSPEED_RAW=$VALUE_UINT16BE
            convertWindLivedata "$VALUE_UINT16BE"
            export LIVEDATA_WINDSPEED="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex windspeed uint16BE $LIVEDATA_WINDSPEED_RAW windspeed $LIVEDATA_WINDSPEED $UNIT_UNICODE_WIND_MPS"  


        elif [ "$ldf" -eq $LDF_WINDGUSTSPPED ]; then

            readUInt16BE
            export LIVEDATA_WINDGUSTSPEED_RAW=$VALUE_UINT16BE
            convertWindLivedata "$VALUE_UINT16BE"
            export LIVEDATA_WINDGUSTSPEED="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex windgustspeed uint16BE $LIVEDATA_WINDGUSTSPEED_RAW windspeed $LIVEDATA_WINDGUSTSPEED $UNIT_UNICODE_WIND_MPS"


        elif [ "$ldf" -eq $LDF_DAYLWINDMAX ]; then

            readUInt16BE
            export LIVEDATA_WINDDAILYMAX_RAW=$VALUE_UINT16BE
            convertWindLivedata "$VALUE_UINT16BE"
            export LIVEDATA_WINDDAILYMAX="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex winddailymax uint16BE $LIVEDATA_WINDDAILYMAX_RAW winddailymax $LIVEDATA_WINDDAILYMAX $UNIT_UNICODE_WIND_MPS"


        elif [ "$ldf" -eq $LDF_LIGHT ]; then

            readUInt32BE
            export LIVEDATA_LIGHT_RAW=$VALUE_UINT32BE
            convertScale10ToFloat "$VALUE_UINT32BE"
            export LIVEDATA_LIGHT="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex light uint32BE $LIVEDATA_LIGHT_RAW light $LIVEDATA_LIGHT lux"


        elif [ "$ldf" -eq $LDF_UV ]; then

            readUInt16BE
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex RAW UV value $VALUE_UINT16BE, converting lux $LIVEDATA_LIGHT to W/m2 instead "
            #setUVMode $UNIT_UV_MICROWM2
            #is it µW? is it scale 10 ?
            #lux 976 -> solar radiation raw value 11 -> ecowitt protcol: 7.7 W/m2
            #https://help.ambientweather.net/help/why-is-the-lux-to-w-m-2-conversion-factor-126-7/
            setUVMode $UNIT_UV_WATTM2
            VALUE_UINT16BE=$(( LIVEDATA_LIGHT_RAW*1075/136000 ))
            convertScale10ToFloat "$VALUE_UINT16BE"
            export LIVEDATA_UV="$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -eq $LDF_UVI ]; then

            readUInt8
            export LIVEDATA_UVI=$VALUE_UINT8
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex uvi uint8 $LIVEDATA_UVI"


        elif [ "$ldf" -eq $LDF_SOILMOISTURE1 ] || [ "$ldf" -eq $LDF_SOILMOISTURE2 ] ||
             [ "$ldf" -eq $LDF_SOILMOISTURE3 ] || [ "$ldf" -eq $LDF_SOILMOISTURE4 ] ||
             [ "$ldf" -eq $LDF_SOILMOISTURE5 ] || [ "$ldf" -eq $LDF_SOILMOISTURE6 ] ||
             [ "$ldf" -eq $LDF_SOILMOISTURE7 ] || [ "$ldf" -eq $LDF_SOILMOISTURE8 ]; then #is 16 channels supported?

            readUInt8
            channel=$((((ldf - LDF_SOILMOISTURE1) / 2) + 1))
            eval "export LIVEDATA_SOILMOISTURE$channel=$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex soilmoisture$channel uint8 $VALUE_UINT8 $UNIT_HUMIDITY"

 
        elif [ "$ldf" -eq $LDF_SOILTEMP1 ] || [ "$ldf" -eq $LDF_SOILTEMP2 ] ||
             [ "$ldf" -eq $LDF_SOILTEMP3 ] || [ "$ldf" -eq $LDF_SOILTEMP4 ] ||
             [ "$ldf" -eq $LDF_SOILTEMP5 ] || [ "$ldf" -eq $LDF_SOILTEMP6 ] ||
             [ "$ldf" -eq $LDF_SOILTEMP7 ] || [ "$ldf" -eq $LDF_SOILTEMP8 ]; then

            readInt16
            convertTemperatureLivedata "$VALUE_INT16BE"
            channel=$((((ldf - LDF_SOILTEMP1) / 2) + 1))
            eval "export LIVEDATA_SOILTEMP$channel=$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex soiltemperature$channel int16BE $VALUE_INT16BE $VALUE_SCALE10_FLOAT $UNIT_UNICODE_CELCIUS"


        elif [ "$ldf" -ge $LDF_TEMP1 ] && [ "$ldf" -le $LDF_TEMP8 ]; then

            readInt16BE
            convertTemperatureLivedata "$VALUE_INT16BE"

            channel=$((ldf - LDF_TEMP1 + 1))
            eval "export LIVEDATA_TEMP$channel=$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex temperature$channel int16BE $VALUE_INT16BE $VALUE_SCALE10_FLOAT $UNIT_UNICODE_CELCIUS"


        elif [ "$ldf" -ge $LDF_HUMI1 ] && [ "$ldf" -le $LDF_HUMI8 ]; then

            readUInt8

            channel=$((ldf - LDF_HUMI1 + 1))
            eval "export LIVEDATA_HUMI$channel=$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex humidity$channel uint8 $VALUE_UINT8 $UNIT_HUMIDITY"


        elif [ "$ldf" -eq $LDF_RAINMONTH ]; then

            readUInt32BE
            convertScale10ToFloat "$VALUE_UINT32BE"
            export LIVEDATA_RAINMONTH="$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -eq $LDF_RAINYEAR ]; then

            readUInt32BE
            convertScale10ToFloat "$VALUE_UINT32BE"
            export LIVEDATA_RAINYEAR="$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -eq $LDF_RAINWEEK ]; then

            readUInt16BE
            convertScale10ToFloat "$VALUE_UINT16BE"
            export LIVEDATA_RAINWEEK="$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -eq $LDF_RAINDAY ]; then

            readUInt16BE
            export LIVEDATA_RAINDAY_RAW=$VALUE_UINT16BE
            convertScale10ToFloat "$VALUE_UINT16BE"
            export LIVEDATA_RAINDAY="$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -eq $LDF_RAINEVENT ]; then

            readUInt16BE
            export LIVEDATA_RAINEVENT_RAW=$VALUE_UINT16BE
            convertScale10ToFloat "$VALUE_UINT16BE"
            export LIVEDATA_RAINEVENT="$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -eq $LDF_RAINRATE ]; then

            readUInt16BE
            export LIVEDATA_RAINRATE_RAW=$VALUE_UINT16BE
            convertScale10ToFloat "$VALUE_UINT16BE"
            export LIVEDATA_RAINRATE="$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -ge $LDF_LEAK_CH1 ] && [ "$ldf" -le $LDF_LEAK_CH4 ]; then

            readUInt8

            channel=$((ldf - LDF_LEAK_CH1 + 1))
            eval "export LIVEDATA_LEAK$channel=$VALUE_UINT8"

        elif [ "$ldf" -eq $LDF_PM25_CH1 ]; then

            readUInt16BE
            convertScale10ToFloat "$VALUE_UINT16BE"
            export LIVEDATA_PM251_RAW="$VALUE_UINT16BE"
            export LIVEDATA_PM251="$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -ge $LDF_PM25_CH2 ] && [ "$ldf" -le $LDF_PM25_CH4 ]; then

            readUInt16BE
            convertScale10ToFloat "$VALUE_UINT16BE"

            channel=$((ldf - LDF_PM25_CH1 + 1))
            eval "export LIVEDATA_PM25${channel}_RAW=$VALUE_UINT16BE"
            eval "export LIVEDATA_PM25$channel=$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -ge $LDF_PM25_24HAVG1 ] && [ "$ldf" -le $LDF_PM25_24HAVG4 ]; then

            readUInt16BE
            convertScale10ToFloat "$VALUE_UINT16BE"

            channel=$((ldf - LDF_PM25_24HAVG1 + 1))
            eval "export LIVEDATA_PM25_24HAVG${channel}_RAW=$VALUE_UINT16BE"
            eval "export LIVEDATA_PM25_24HAVG$channel=$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -eq $LDF_SENSOR_CO2 ]; then

            #/* ------------------Ecowitt-----------------
            # 1 tf_co2        short C x10
            # 2 humi_co2      unsigned char %
            # 3 pm10_co2      unsigned short ug/m3 x10
            # 4 pm10_24h_co2  unsigned short ug/m3 x10
            # 5 pm25_co2      unsigned short ug/m3 x10
            # 6 pm25_24h_co2  unsigned short ug/m3 x10
            # 7 co2           unsigned short ppm
            # 8 co2_24h       unsigned short ppm
            # 9 co2_batt      u8 (0~5)

            readInt16BE
            convertScale10ToFloat "$VALUE_INT16BE"
            export LIVEDATA_WH45CO2_TEMPF="$VALUE_SCALE10_FLOAT"

            readUInt8
            export LIVEDATA_WH45CO2_HUMI=$VALUE_UINT8

            readUInt16BE
            convertScale10ToFloat "$VALUE_UINT16BE"
            export LIVEDATA_WH45CO2_PM10="$VALUE_SCALE10_FLOAT"

            readUInt16BE
            convertScale10ToFloat "$VALUE_UINT16BE"
            export LIVEDATA_WH45CO2_PM10_24HAVG="$VALUE_SCALE10_FLOAT"

            readUInt16BE
            convertScale10ToFloat "$VALUE_UINT16BE"
            export LIVEDATA_WH45CO2_PM25_RAW=$VALUE_UINT16BE
            export LIVEDATA_WH45CO2_PM25="$VALUE_SCALE10_FLOAT"

            readUInt16BE
            convertScale10ToFloat "$VALUE_UINT16BE"
            export LIVEDATA_WH45CO2_PM25_24HAVG_RAW=$VALUE_UINT16BE
            export LIVEDATA_WH45CO2_PM25_24HAVG="$VALUE_SCALE10_FLOAT"

            readUInt16BE
            export LIVEDATA_WH45CO2_CO2=$VALUE_UINT16BE

            readUInt16BE
            export LIVEDATA_WH45CO2_CO2_24HAVG=$VALUE_UINT16BE

            readUInt8
            export LIVEDATA_WH45CO2_BATTERY=$VALUE_UINT8

        elif [ "$ldf" -ge $LDF_TF_USR1 ] && [ "$ldf" -le $LDF_TF_USR8 ]; then

            readInt16BE
            convertTemperatureLivedata "$VALUE_INT16BE"

            channel=$((ldf - LDF_TF_USR1 + 1))
            eval "export LIVEDATA_TF_USR$channel=$VALUE_SCALE10_FLOAT"

            readUInt8
            convertScale10ToFloat "$VALUE_UINT8"
            eval "export LIVEDATA_TF_USR${channel}_BATTERY_RAW=$VALUE_UINT8"
            eval "export LIVEDATA_TF_USR${channel}_BATTERY=$VALUE_SCALE10_FLOAT"
            getBatteryVoltageLevelState "$VALUE_UINT8"
            eval "export LIVEDATA_TF_USR${channel}_BATTERY_STATE=$SBATTERY_STATE"
            

        elif [ "$ldf" -ge $LDF_LIGHTNING ]; then

            readUInt8
            export LIVEDATA_LIGHTNING_DISTANCE=$VALUE_UINT8 # 1-40km

        elif [ "$ldf" -ge $LDF_LIGHTNING_TIME ]; then

            readUInt32BE
            export LIVEDATA_LIGHTNING_TIME=$VALUE_UINT32BE
            getDateUTC "$LIVEDATA_LIGHTNING_TIME"
            export LIVEDATA_LIGHTNING_TIME_UTC="$VALUE_DATE_UTC"


        elif [ "$ldf" -ge $LDF_LIGHTNING_POWER ]; then

            readUInt32BE
            export LIVEDATA_LIGHTNING_POWER=$VALUE_UINT32BE

        elif [ "$ldf" -ge $LDF_LEAF_WETNESS_CH1 ] && [ "$ldf" -le $LDF_LEAF_WETNESS_CH8 ]; then

            readUInt8
            channel=$((ldf - LDF_LEAF_WETNESS_CH1 + 1))

            eval "export LIVEDATA_LEAFWETNESS${channel}=$VALUE_UINT8"

        else
            echo >&2 "ERROR Unable to parse livedata field $(printf "%x" $ldf)"
        fi

    done

    if [ ${#OD_BUFFER} -eq 2 ] && [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ]; then
        readUInt8
        checksum=$VALUE_UINT8
        echo >&2 checksum "$(printf "%02x" $checksum)"
    fi

    [ "$DEBUG_OPTION_TESTSENSOR" -eq 1 ] && injectTestSensorLivedata

    #[ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] &&
    # export -p

    printOrLogLivedata

    unset ldf channel checksum DEBUG_FUNC
    
}

parsePacket() {
   
    EXITCODE_PARSEPACKET=0
   
    if [ -z "$1" ]; then
        [ "$DEBUG" -eq 1 ] && echo >&2 Empty od buffer
        EXITCODE_PARSEPACKET="$ERROR_OD_BUFFER_EMPTY"
        return "$EXITCODE_PARSEPACKET"
    fi

    newBuffer "OD_BUFFER" "$1"
    OD_BUFFER_BACKUP="$1"

    readSlice 4

    PRX_PREAMBLE="$B1 $B2"
    if [ "$PRX_PREAMBLE" != "255 255" ]; then
        EXITCODE_PARSEPACKET="$ERROR_PRX_PREAMBLE"
        return $EXITCODE_PARSEPACKET
    fi

    PRX_CMD_UINT8=$((B3))
    getCommandName "$PRX_CMD_UINT8"
    { [ "$DEBUG" -eq 1 ] || [ "$DEBUG_OPTION_OD_BUFFER" ] ; } && {
       printf >&2 "< %-20s" "$COMMAND_NAME"
       printBuffer >&2 "$1" 
    }

    #Packet length
    if [ "$PRX_CMD_UINT8" -eq $CMD_BROADCAST ] || [ "$PRX_CMD_UINT8" -eq $CMD_LIVEDATA ] || [ "$PRX_CMD_UINT8" -eq $CMD_READ_SENSOR_ID_NEW ]; then
        readUInt8
        PACKET_RX_LENGTH=$(((B4 << 8) & VALUE_UINT8))
    else
        PACKET_RX_LENGTH=$((B4))
    fi

    [ $DEBUG -eq 1 ] && echo >&2 "RX PACKET LENGTH $PACKET_RX_LENGTH"

    if isWriteCommand "$PRX_CMD_UINT8"; then
        parseResult
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_VERSION ]; then
        parseVersion
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_MAC ]; then
        parseMAC
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_ECOWITT_INTERVAL ]; then
        parseEcowittInterval
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_WUNDERGROUND ]; then
        parseWunderground
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_WEATHERCLOUD ]; then
        parseWeathercloud
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_WOW ]; then
        parseWow
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_SYSTEM ]; then
        parseSystem
    elif [ "$PRX_CMD_UINT8" -eq $CMD_LIVEDATA ]; then
        parseLivedata
    elif [ "$PRX_CMD_UINT8" -eq $CMD_BROADCAST ]; then
        parseBroadcast
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_RAINDATA ]; then
        parseRaindata
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_CALIBRATION ]; then
        parseCalibration
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_PATH ]; then
        parsePath
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_CUSTOMIZED ]; then
        parseCustomized
    elif [ "$PRX_CMD_UINT8" -eq $CMD_READ_SENSOR_ID_NEW ] ||[ "$PRX_CMD_UINT8" -eq $CMD_READ_SENSOR_ID ]; then
        parseSensorIdNew
    else
        echo >&2 ERROR Parsing of command "$COMMAND_NAME" not supported
        EXITCODE_PARSEPACKET=$ERROR_PARSEPACKET_UNSUPPORTED_COMMAND
    fi

    [ $DEBUG -eq 1 ] && echo >&2 "Received command $PRX_CMD integer cmd $PRX_CMD_UINT8"

    return "$EXITCODE_PARSEPACKET"
}

