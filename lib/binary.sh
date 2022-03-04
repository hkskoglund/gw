#!/bin/sh

GWDIR=${GWDIR:=.}
. $GWDIR/lib/binary-fields.sh

parseVersion() {
    readString OD_BUFFER "version"
    export GW_VERSION="$VALUE_STRING"
    getVersionInt "$GW_VERSION"
    export GW_VERSION_INT="${GW_VERSION_INT:=$VALUE_VERSION}"
    echo "$GW_VERSION"
}

parseMAC() 
{
    readSlice OD_BUFFER 6 "MAC"
    setMAC "$VALUE_SLICE"
    export GW_MAC="$VALUE_MAC"
    echo "$GW_MAC"
}

parseResult() {
    
    readUInt8 OD_BUFFER 'write result'
    write_result=$VALUE_UINT8
    export GW_RESULT="$write_result"

    if [ "$write_result" -eq 0 ]; then
    :
     #   echo >&2 "$COMMAND_NAME OK"
    elif [ "$write_result" -eq 1 ]; then
        echo >&2 "$COMMAND_NAME FAIL"
    else
        echo >&2 "$COMMAND_NAME errorcode: $write_result"
    fi

    unset write_result

}

printBroadcast() {
   # if [ "$SHELL_SUPPORT_BULTIN_PRINTF" -eq 1 ]; then
   #    printf "%-25s %s\n%-25s %s\n%-25s %s\n%-25s %s\n%-25s %s\n" "broadcast mac" "$GW_BROADCAST_MAC"\
   #    "broadcast ip" "$GW_BROADCAST_IP" "broadcast port" "$GW_BROADCAST_PORT" "broadcast ssid" "$GW_BROADCAST_SSID" "broadcast version" "$GW_BROADCAST_VERSION"
   # else
      echo "$GW_BROADCAST_MAC $GW_BROADCAST_IP $GW_BROADCAST_PORT $GW_BROADCAST_SSID $GW_BROADCAST_VERSION"
    #fi
}

setMAC()
{
    unset VALUE_MAC
     IFS=' '
    #shellcheck disable=SC2086
    set -- $1
    N=1
    
    while [ $N -le 6 ]; do
        eval convertUInt8ToHex "\${$N}"
        if [ $N -le 5 ]; then
            VALUE_MAC="$VALUE_MAC$VALUE_UINT8_HEX:" 
        else
            VALUE_MAC="$VALUE_MAC$VALUE_UINT8_HEX"
        fi 
        N=$(( N + 1 ))
    done
}

parseBroadcast() {

    readSlice OD_BUFFER 12 "broadcast"
    #this is the station MAC/ip on local network.
    #Observation: when device is reset its annoncing hotspot accesspoint/AP with first byte of MAC changed
    IFS=' '
    #shellcheck disable=SC2086
    set -- $VALUE_SLICE
    setMAC "$VALUE_SLICE"
    export GW_BROADCAST_MAC="$VALUE_MAC"

   #GW_BROADCAST_MAC="$B1HEX:$B2HEX:$B3HEX:$B4HEX:$B5HEX:$B6HEX"
    export GW_BROADCAST_IP="$7.$8.$9.${10}"
    export GW_BROADCAST_PORT="$(( (${11} << 8) | ${12} ))"

    readString OD_BUFFER "ssid version"
    #https://stackoverflow.com/questions/1469849/how-to-split-one-string-into-multiple-strings-separated-by-at-least-one-space-in
    #shellcheck disable=SC2086
    
    set -- $VALUE_STRING # -- assign words to positional parameters
    export GW_BROADCAST_SSID="$1"
    export GW_BROADCAST_VERSION="$2"

    printBroadcast

    unset N
}

printEcowittInterval() {

    if [ "$GW_WS_ECOWITT_INTERVAL" -eq 1 ]; then
        echo "ecowitt interval              $GW_WS_ECOWITT_INTERVAL minute"
    elif [ "$GW_WS_ECOWITT_INTERVAL" -gt 1 ]; then
        echo "ecowitt interval              $GW_WS_ECOWITT_INTERVAL minutes"
    fi
}

parseEcowittInterval() {

    readUInt8 OD_BUFFER "ecowitt interval"
    export GW_WS_ECOWITT_INTERVAL="$VALUE_UINT8"
    printEcowittInterval
}

printWunderground() {
    echo "wunderground station id       $GW_WS_WUNDERGROUND_ID
wunderground station password $GW_WS_WUNDERGROUND_PASSWORD"
}

parseWunderground() {
    readString OD_BUFFER "wunderground id"
    export GW_WS_WUNDERGROUND_ID="$VALUE_STRING"
    readString OD_BUFFER "wunderground password"
    GW_WS_WUNDERGROUND_PASSWORD=$VALUE_STRING

    printWunderground
}

printWeathercloud() {
    echo "weathercloud id               $GW_WS_WC_ID
weathercloud password         $GW_WS_WC_PASSWORD"
}

parseWeathercloud() {
    readString OD_BUFFER "weathercloud id"
    export GW_WS_WC_ID="$VALUE_STRING"

    readString OD_BUFFER "weathercloud password"
    export GW_WS_WC_PASSWORD="$VALUE_STRING"

    printWeathercloud
}

printWow() {
    echo "wow id                        $GW_WS_WOW_ID
wow password                  $GW_WS_WOW_PASSWORD"
}

parseWow() {
    readString OD_BUFFER "wow id"
    export GW_WS_WOW_ID="$VALUE_STRING"

    readString OD_BUFFER "wow password"
    export GW_WS_WOW_PASSWORD="$VALUE_STRING"

    printWow
}

printCalibration() {
    #if [ "$SHELL_SUPPORT_BULTIN_PRINTF" -eq 1 ]; then
    #   printf "%-40s %7s %-4s\n%-40s %7s %-4s\n%-40s %7s %-4s\n%-40s %7s %-4s\n%-40s %7s %-4s\n%-40s %7s %-4s\n%-40s %7s %-4s\n"\
    #    "calibration in temperature offset"           "$GW_CALIBRATION_INTEMPOFFSET"     "$LIVEDATAUNIT_TEMP"\
    #    "calibration in humidity offset"              "$GW_CALIBRATION_INHUMIDITYOFFSET"   "$LIVEDATAUNIT_HUMIDITY"\
    #    "calibration absolute pressure offset"        "$GW_CALIBRATION_ABSOFFSET"        "$LIVEDATAUNIT_PRESSURE"\
    #    "calibration relative pressure offset"        "$GW_CALIBRATION_RELOFFSET"        "$LIVEDATAUNIT_PRESSURE"\
    #    "calibration out temperature offset"          "$GW_CALIBRATION_OUTTEMPOFFSET"    "$LIVEDATAUNIT_TEMP"\
    ##    "calibration out humidity offset"             "$GW_CALIBRATION_OUTHUMIDITYOFFSET" "$LIVEDATAUNIT_HUMIDITY"\
    #    "calibration wind direction offset"           "$GW_CALIBRATION_WINDDIROFFSET" ""
    #else
        echo "calibration in temperature offset           $GW_CALIBRATION_INTEMPOFFSET $LIVEDATAUNIT_TEMP
calibration in humidity offset              $GW_CALIBRATION_INHUMIDITYOFFSET   %
calibration absolute pressure offset        $GW_CALIBRATION_ABSOFFSET $LIVEDATAUNIT_PRESSURE
calibration relative pressure offset        $GW_CALIBRATION_RELOFFSET $LIVEDATAUNIT_PRESSURE
calibration out temperature offset          $GW_CALIBRATION_OUTTEMPOFFSET $LIVEDATAUNIT_TEMP
calibration out humidity offset             $GW_CALIBRATION_OUTHUMIDITYOFFSET   %
calibration wind direction offset           $GW_CALIBRATION_WINDDIROFFSET $LIVEDATAUNIT_WIND_DEGREE_UNIT"
   # fi

}


parseCalibration() {

    readInt16BE OD_BUFFER "intemp offset"
    export GW_CALIBRATION_INTEMPOFFSET_INTS10="$VALUE_INT16BE"
    convertScale10ToFloat "$GW_CALIBRATION_INTEMPOFFSET_INTS10"
    GW_CALIBRATION_INTEMPOFFSET="$VALUE_SCALE10_FLOAT"

    readInt8 OD_BUFFER "inhumidity offset"
    export GW_CALIBRATION_INHUMIDITYOFFSET="$VALUE_INT8"

    readInt32BE "absolute offset"
    export GW_CALIBRATION_ABSOFFSET_INTS10="$VALUE_INT32BE" 
    convertScale10ToFloat "$GW_CALIBRATION_ABSOFFSET_INTS10"
    GW_CALIBRATION_ABSOFFSET="$VALUE_SCALE10_FLOAT"

    readInt32BE "relative offset"
    export GW_CALIBRATION_RELOFFSET_INTS10="$VALUE_INT32BE" #used for int comparison [ ... ]
    convertScale10ToFloat "$GW_CALIBRATION_RELOFFSET_INTS10"
    GW_CALIBRATION_RELOFFSET="$VALUE_SCALE10_FLOAT"

    readInt16BE OD_BUFFER "outtemp offset"
    export GW_CALIBRATION_OUTTEMPOFFSET_INTS10="$VALUE_INT16BE"
    convertScale10ToFloat "$GW_CALIBRATION_OUTTEMPOFFSET_INTS10"
    GW_CALIBRATION_OUTTEMPOFFSET="$VALUE_SCALE10_FLOAT"

    readInt8 OD_BUFFER "out humidity offset"
    export GW_CALIBRATION_OUTHUMIDITYOFFSET="$VALUE_INT8"

    readInt16BE OD_BUFFER "winddirection offset"
    export GW_CALIBRATION_WINDDIROFFSET="$VALUE_INT16BE"

    printCalibration
}

printCustomized() {
    if [ "$GW_WS_CUSTOMIZED_HTTP" -eq "$HTTP_WUNDERGROUND" ]; then #wunderground
    echo "id                 $GW_WS_CUSTOMIZED_ID
password           $GW_WS_CUSTOMIZED_PASSWORD"
fi

    echo "server             $GW_WS_CUSTOMIZED_SERVER
port               $GW_WS_CUSTOMIZED_PORT
interval           $GW_WS_CUSTOMIZED_INTERVAL
http               $GW_WS_CUSTOMIZED_HTTP $GW_WS_CUSTOMIZED_HTTP_STATE 
enabled            $GW_WS_CUSTOMIZED_ENABLED $GW_WS_CUSTOMIZED_ENABLED_STATE"

if [ "$GW_WS_CUSTOMIZED_HTTP" -eq "$HTTP_ECOWITT" ]; then
    echo "path ecowitt       $GW_WS_CUSTOMIZED_PATH_ECOWITT"
else
    echo "path wunderground  $GW_WS_CUSTOMIZED_PATH_WU"
fi
}

parseCustomized() {
    readString OD_BUFFER "customized id"
    export GW_WS_CUSTOMIZED_ID="$VALUE_STRING"

    readString OD_BUFFER "customized password"
    export GW_WS_CUSTOMIZED_PASSWORD="$VALUE_STRING"

    readString OD_BUFFER "customized server"
    export GW_WS_CUSTOMIZED_SERVER="$VALUE_STRING"

    readUInt16BE OD_BUFFER "customized port"
    export GW_WS_CUSTOMIZED_PORT="$VALUE_UINT16BE"

    readUInt16BE OD_BUFFER "customized interval"
    export GW_WS_CUSTOMIZED_INTERVAL="$VALUE_UINT16BE"

    readUInt8 OD_BUFFER "customized http"
    export GW_WS_CUSTOMIZED_HTTP="$VALUE_UINT8"

    if [ "$GW_WS_CUSTOMIZED_HTTP" -eq 1 ]; then
        export GW_WS_CUSTOMIZED_HTTP_STATE="wunderground"
    elif [ "$GW_WS_CUSTOMIZED_HTTP" -eq 0 ]; then
        export GW_WS_CUSTOMIZED_HTTP_STATE="ecowitt"
    fi

    readUInt8 OD_BUFFER "customized enabled"

    export GW_WS_CUSTOMIZED_ENABLED="$VALUE_UINT8"
    if [ "$GW_WS_CUSTOMIZED_ENABLED" -eq 1 ]; then
        export GW_WS_CUSTOMIZED_ENABLED_STATE="on"
    elif [ "$GW_WS_CUSTOMIZED_ENABLED" -eq 0 ]; then
        export GW_WS_CUSTOMIZED_ENABLED_STATE="off"
    fi

    printCustomized
}

printPath() {
    echo "path ecowitt      $GW_WS_CUSTOMIZED_PATH_ECOWITT
path wunderground $GW_WS_CUSTOMIZED_PATH_WU"
}

parsePath() {
    readString OD_BUFFER "path ecowitt"
    export GW_WS_CUSTOMIZED_PATH_ECOWITT="$VALUE_STRING"
    readString OD_BUFFER "path wunderground"
    export GW_WS_CUSTOMIZED_PATH_WU="$VALUE_STRING"

    printPath
}

printRaindata() {
    echo "rain rate  $GW_RAINRATE $LIVEDATAUNIT_RAINRATE
rain day   $GW_RAINDAILY $LIVEDATAUNIT_RAIN
rain week  $GW_RAINWEEK $LIVEDATAUNIT_RAIN
rain month $GW_RAINMONTH $LIVEDATAUNIT_RAIN
rain year  $GW_RAINYEAR $LIVEDATAUNIT_RAIN"
}

parseRaindata() {

    readUInt32BE "OD_BUFFER" "rainrate"
    export GW_RAINRATE_INTS10="$VALUE_UINT32BE"

    readUInt32BE "OD_BUFFER" "raindaily"
    export GW_RAINDAILY_INTS10="$VALUE_UINT32BE"

    readUInt32BE "OD_BUFFER" "rainweek"
    export GW_RAINWEEK_INTS10="$VALUE_UINT32BE"

    readUInt32BE "OD_BUFFER" "rainmonth"
    export GW_RAINMONTH_INTS10="$VALUE_UINT32BE"

    readUInt32BE "OD_BUFFER" "rainyear"
    export GW_RAINYEAR_INTS10="$VALUE_UINT32BE"

    convertScale10ToFloat "$GW_RAINRATE_INTS10"
    export GW_RAINRATE="$VALUE_SCALE10_FLOAT"

    convertScale10ToFloat "$GW_RAINDAILY_INTS10"
    export GW_RAINDAILY="$VALUE_SCALE10_FLOAT"
    
    convertScale10ToFloat "$GW_RAINWEEK_INTS10"
    export GW_RAINWEEK="$VALUE_SCALE10_FLOAT"
    
    convertScale10ToFloat "$GW_RAINMONTH_INTS10"
    export GW_RAINMONTH="$VALUE_SCALE10_FLOAT"
    
    convertScale10ToFloat "$GW_RAINYEAR_INTS10"
    export GW_RAINYEAR="$VALUE_SCALE10_FLOAT"

    printRaindata
}

getSensorNameShort()
{
    case "$1" in
        0) if [ -n "$GW_SYSTEM_SENSORTYPE" ]; then
                if [ "$GW_SYSTEM_SENSORTYPE" -eq "$SYSTEM_SENSOR_TYPE_WH24" ]; then
                SENSORNAME_WH='WH24'
                else
                SENSORNAME_WH='WH65'
                fi
            else
              SENSORNAME_WH='WH??' # no system information, cannot determine WH24/WH65
            fi
            SENSORNAME_SHORT='Weather Station'
            ;;
        1) SENSORNAME_WH='WH68'
           SENSORNAME_SHORT="Weather Station"
            ;;
        2) SENSORNAME_WH="WH80"
           SENSORNAME_SHORT='Weather Station'
            ;;
        3) SENSORNAME_WH="WH40"
           SENSORNAME_SHORT="Rainfall"
            ;;
        5) SENSORNAME_WH='WH32'
           SENSORNAME_SHORT='Temperatue out'
            ;;
        6|7|8|9|10|11|12|13)
           SENSORNAME_WH='WH31'
           SENSORNAME_SHORT="Temperature$(($1 - 5))"
           ;;
        14|15|16|17|18|19|20|21)
          SENSORNAME_WH='WH51'
          SENSORNAME_SHORT="Soilmoisture$(($1 - 13))"
          ;;
        22|23|24|25)
          SENSORNAME_WH='WH43'
          SENSORNAME_SHORT="PM2.5 AQ $(($1 - 21))"
          ;;
        26)
          SENSORNAME_SHORT="Lightning"
          SENSORNAME_WH='WH57'
          ;;
        27|28|29|30)
          SENSORNAME_WH='WH55'
          SENSORNAME_SHORT="Leak$(($1 - 26))"
          ;;
        31|32|33|34|35|36|37|38)

          SENSORNAME_WH='WH34'
          SENSORNAME_SHORT="Soiltemperature$(($1 - 30))"
          ;;
        39)
          SENSORNAME_WH='WH45'
          SENSORNAME_SHORT="CO2 PM2.5 PM10 AQ"
          ;;
        40|41|42|43|44|45|46|47)
            SENSORNAME_WH='WH35'
            SENSORNAME_SHORT="Leafwetness$(($1 - 39))"
           ;;
         *)
         echo >&2 "Warning: Unknown sensortype $1"
          SENSORNAME_WH='WH??' 
          SENSORNAME_SHORT='?'
    esac
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
    
     export LIVEDATA_SENSOR_COUNT_SEARCHING=0
     export LIVEDATA_SENSOR_COUNT_CONNECTED=0
     export LIVEDATA_SENSOR_COUNT_DISCONNECTED=0
     export LIVEDATA_SENSOR_COUNT_DISABLED=0

     parseSensorIdNew_max_length=$(( OD_BUFFER_LENGTH - 1 ))

    while [ "$OD_BUFFER_HEAD" -lt $parseSensorIdNew_max_length ]; do
       
        readUInt8  OD_BUFFER "sensor type"          #type
        stype=$VALUE_UINT8
       
        readUInt32BE OD_BUFFER "sensor id"        #id
        SID=$VALUE_UINT32BE

        readUInt8  OD_BUFFER "sensor battery"
        battery=$VALUE_UINT8
        
        readUInt8 OD_BUFFER "sensor signal"
        signal=$VALUE_UINT8

        if [ "$SID" -eq "$SENSORID_SEARCH" ]; then
            LIVEDATA_SENSOR_COUNT_SEARCHING=$(( LIVEDATA_SENSOR_COUNT_SEARCHING + 1 ))
        elif [ "$SID" -eq "$SENSORID_DISABLE" ]; then
            LIVEDATA_SENSOR_COUNT_DISABLED=$(( LIVEDATA_SENSOR_COUNT_DISABLED + 1 ))
        elif [ "$signal" -gt 0 ]; then
            LIVEDATA_SENSOR_COUNT_CONNECTED=$(( LIVEDATA_SENSOR_COUNT_CONNECTED + 1 ))
            setLivedataSignal "$stype" "$signal"
        elif [ "$signal" -eq 0 ]; then
            LIVEDATA_SENSOR_COUNT_DISCONNECTED=$(( LIVEDATA_SENSOR_COUNT_DISCONNECTED + 1 ))
        fi

        #pattern matching
        printSensorMatch=0

        if [ "$SPATTERNID" = "$SPATTERNID_CONNECTED" ] && [ "$SID" -ne "$SENSORID_SEARCH" ] && [ "$SID" -ne "$SENSORID_DISABLE" ]; then # connected sensor
            printSensorMatch=1
        elif [ "$SPATTERNID" = "$SPATTERNID_DISCONNECTED" ] && [ "$SID" -ne "$SENSORID_SEARCH" ] && [ "$SID" -ne "$SENSORID_DISABLE" ] && [ "$signal" -eq 0 ]; then
            printSensorMatch=1
        elif [ "$SPATTERNID" = "$SPATTERNID_RANGE" ] && [ -n "$SPATTERNID_RANGE_LOW" ] && [ -n "$SPATTERNID_RANGE_HIGH" ] && [ "$stype" -ge "$SPATTERNID_RANGE_LOW" ] && [ "$stype" -le "$SPATTERNID_RANGE_HIGH" ]; then 
            printSensorMatch=1
        elif [ "$SPATTERNID" = "$SPATTERNID_SEARCHING" ] && [ "$SID" -eq "$SENSORID_SEARCH"  ]; then 
            printSensorMatch=1
        elif [ "$SPATTERNID" = "$SPATTERNID_DISABLED" ] && [ "$SID" -eq "$SENSORID_DISABLE" ]; then
            printSensorMatch=1
        elif [ -z "$SPATTERNID" ]; then #all sensors
            printSensorMatch=1
        fi

        if [ $printSensorMatch -eq 1 ]; then
            printSensorLine "$stype" "$SID" "$battery" "$signal"
        fi
        
        [ "$DEBUG" -eq 1 ] && >&2 echo "type $stype id $SID battery $battery signal $signal od_buffer length ${#OD_BUFFER}"
    done

    printAppendBuffer

    unset stype signal battery printSensorHeader printSensorMatch parseSensorIdNew_max_length
}

printSystem() 
{
    printf "%-32.32s%10u\t%s\n\
%-32.32s%10u\t%s\n\
%-32.32s%10u\t%s\n\
%-32.32s%10u\t%.24s\n\
%-32.32s%10u\t%s\n\
%-32.32s%10u\t%s\n"\
            "$LIVEDATAHEADER_SYSTEM_FREQUENCY" "$GW_SYSTEM_FREQUENCY" "$GW_SYSTEM_FREQUENCY_STATE"\
            "$LIVEDATAHEADER_SYSTEM_SENSORTYPE"    "$GW_SYSTEM_SENSORTYPE" "$GW_SYSTEM_SENSORTYPE_STATE"\
            "$LIVEDATAHEADER_SYSTEM_UTC" "$GW_SYSTEM_UTC" "$GW_SYSTEM_UTC_STATE"\
            "$LIVEDATAHEADER_SYSTEM_TIMEZONE"  "$GW_SYSTEM_TIMEZONE_INDEX" "$GW_SYSTEM_TIMEZONE_INDEX_STATE"\
            "$LIVEDATAHEADER_SYSTEM_TIMEZONE_AUTO" "$GW_SYSTEM_TIMEZONE_AUTO_BIT" "$GW_SYSTEM_TIMEZONE_AUTO_STATE"\
            "$LIVEDATAHEADER_SYSTEM_TIMEZONE_DST" "$GW_SYSTEM_TIMEZONE_DST_BIT" "$GW_SYSTEM_TIMEZONE_DST_STATUS_STATE"
}


parseSystem() {
    readUInt8 OD_BUFFER "system frequency"

    export GW_SYSTEM_FREQUENCY="$VALUE_UINT8"
    export GW_SYSTEM_FREQUENCY_STATE
    if [ "$GW_SYSTEM_FREQUENCY" -eq "$SYSTEM_FREQUENCY_RFM433M" ]; then
        GW_SYSTEM_FREQUENCY_STATE="433"
    elif [ "$GW_SYSTEM_FREQUENCY" -eq "$SYSTEM_FREQUENCY_RFM868M" ]; then
        GW_SYSTEM_FREQUENCY_STATE="868"
    elif [ "$GW_SYSTEM_FREQUENCY" -eq "$SYSTEM_FREQUENCY_RFM915M" ]; then
        GW_SYSTEM_FREQUENCY_STATE="915"
    elif [ "$GW_SYSTEM_FREQUENCY" -eq "$SYSTEM_FREQUENCY_RFM920M" ]; then
        GW_SYSTEM_FREQUENCY_STATE="920"
    fi

    readUInt8 OD_BUFFER "system sensortype"

    export GW_SYSTEM_SENSORTYPE="$VALUE_UINT8"
    export GW_SYSTEM_SENSORTYPE_STATE
    if [ "$GW_SYSTEM_SENSORTYPE" -eq "$SYSTEM_SENSOR_TYPE_WH24" ]; then
        #       SENSOR_TYPE[WH24_TYPE]="WH24:Outdoor Weather Sensor:16.0:" # overwrite default WH65_TYPE=0
        GW_SYSTEM_SENSORTYPE_STATE="WH24"
    elif [ "$GW_SYSTEM_SENSORTYPE" -eq "$SYSTEM_SENSOR_TYPE_WH65" ]; then
        GW_SYSTEM_SENSORTYPE_STATE="WH65"
    fi

    readUInt32BE "OD_BUFFER" "system utc"

    export GW_SYSTEM_UTC="$VALUE_UINT32BE"
    GW_SYSTEM_UTC_STATE="$(date -u -d @"$VALUE_UINT32BE" +'%F %T')"
    export GW_SYSTEM_UTC_STATE

    readUInt8 OD_BUFFER "system timezone index"

    export GW_SYSTEM_TIMEZONE_INDEX="$VALUE_UINT8"

    eval "GW_SYSTEM_TIMEZONE_INDEX_STATE=\$SYSTEM_TIMEZONE_$GW_SYSTEM_TIMEZONE_INDEX" # set from SYSTEM_TIMEZONE "array" variable with index
    export GW_SYSTEM_TIMEZONE_INDEX_STATE

    GW_SYSTEM_TIMEZONE_OFFSET_HOURS=${GW_SYSTEM_TIMEZONE_INDEX_STATE%%\)*} # remove )... 
    GW_SYSTEM_TIMEZONE_OFFSET_HOURS=${GW_SYSTEM_TIMEZONE_OFFSET_HOURS#\(UTC} # remove (UTC
    export GW_SYSTEM_TIMEZONE_OFFSET_HOURS

    readUInt8 OD_BUFFER "system dst status"

    export GW_SYSTEM_TIMEZONE_DST_STATUS="$VALUE_UINT8"

    export GW_SYSTEM_TIMEZONE_DST_BIT=$((GW_SYSTEM_TIMEZONE_DST_STATUS & 0x01))

    GW_SYSTEM_TIMEZONE_AUTOOFF_BIT=$(((GW_SYSTEM_TIMEZONE_DST_STATUS & 0x2) >> 1)) # bit 2 1= off, 0=on ?

    if [ $GW_SYSTEM_TIMEZONE_AUTOOFF_BIT = 0 ]; then #invert
       GW_SYSTEM_TIMEZONE_AUTO_BIT=1;
    else
        GW_SYSTEM_TIMEZONE_AUTO_BIT=0
    fi
    export GW_SYSTEM_TIMEZONE_AUTO_BIT

     [ -z "$GW_NOPRINT" ] && printSystem

}

parseLivedata() { # ff ff 27 00 53 01 00 e1 06 25 08 27 b3 09 27 c2 02 00 05 07 5d 0a 01 59 0b 00 00 0c 00 00 15 00 00 93 bc 16 00 20 17 00 2c 12 1a 00 87 22 32 1b 00 b0 23 27 1c 00 dd 24 31 58 00 19 00 47 0e 00 00 10 00 08 11 00 42 12 00 00 02 9a 13 00 00 0f 8b 0d 00 42 63
    DEBUG_FUNC="parseLivedata"
    DEBUG_PARSE_LIVEDATA=${DEBUG_PARSE_LIVEDATA:=$DEBUG}
   
    export LIVEDATA_SYSTEM_PROTOCOL="$LIVEDATA_PROTOCOL_ECOWITT_BINARY"
    export LIVEDATA_SYSTEM_PROTOCOL_LONG="$LIVEDATA_PROTOCOL_ECOWITT_BINARY_LONG"

    parselivedata_max_length=$(( OD_BUFFER_LENGTH - 1 ))

    while [ "$OD_BUFFER_HEAD" -lt  $parselivedata_max_length ]; do

        [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "OD_BUFFER_HEAD $OD_BUFFER_HEAD OD_BUFFER_LENTTH $OD_BUFFER_LENGTH"

        readUInt8 OD_BUFFER "livedata field id"
        ldf=$VALUE_UINT8

        convertUInt8ToHex "$ldf"
        ldf_hex=$VALUE_UINT8_HEX
     
        if [ "$ldf" -eq "$LDF_INTEMP" ]; then

            readInt16BE OD_BUFFER "intemp"
            export LIVEDATA_INTEMP_INTS10="$VALUE_INT16BE"
            convertTemperatureLivedata "$LIVEDATA_INTEMP_INTS10"
            export LIVEDATA_INTEMP="$VALUE_SCALE10_FLOAT" 
             [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:intemp type: int16be $LIVEDATA_INTEMP_INTS10 $LIVEDATA_INTEMP $UNIT_UNICODE_CELCIUS"

        elif [ "$ldf" -eq "$LDF_INHUMI" ]; then

            readUInt8 OD_BUFFER "inhumidity"
            export LIVEDATA_INHUMI="$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:inhumi type: uint8 $LIVEDATA_INHUMI $LIVEDATAUNIT_HUMIDITY"


        elif [ "$ldf" -eq "$LDF_PRESSURE_ABSBARO" ]; then

            readUInt16BE OD_BUFFER "absolute pressure"
            #shellcheck disable=SC2034
            export LIVEDATA_PRESSURE_ABSBARO_INTS10="$VALUE_UINT16BE" #may use for ansi escape coloring beyond limits
            convertPressureLivedata "$LIVEDATA_PRESSURE_ABSBARO_INTS10"
            export LIVEDATA_PRESSURE_ABSBARO="$VALUE_SCALE10_FLOAT"
            
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:absbaro type: uint16be $LIVEDATA_PRESSURE_ABSBARO_INTS10 $LIVEDATA_PRESSURE_ABSBARO $UNIT_UNICODE_PRESSURE_HPA"


        elif [ "$ldf" -eq "$LDF_PRESSURE_RELBARO" ]; then

            readUInt16BE OD_BUFFER "relative pressure"
            export LIVEDATA_PRESSURE_RELBARO_INTS10="$VALUE_UINT16BE"
            convertPressureLivedata "$LIVEDATA_PRESSURE_RELBARO_INTS10"
            export LIVEDATA_PRESSURE_RELBARO="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:relbaro type: uint16be $LIVEDATA_PRESSURE_RELBARO_INTS10 $LIVEDATA_PRESSURE_RELBARO  $UNIT_UNICODE_PRESSURE_HPA"


        elif [ "$ldf" -eq "$LDF_OUTTEMP" ]; then

            readInt16BE OD_BUFFER "outtemp"
            export LIVEDATA_OUTTEMP_INTS10="$VALUE_INT16BE"
            convertTemperatureLivedata "$LIVEDATA_OUTTEMP_INTS10" 
            export LIVEDATA_OUTTEMP="$VALUE_SCALE10_FLOAT"
            
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:outtemp type: int16be $LIVEDATA_OUTTEMP_INTS10 $LIVEDATA_OUTTEMP $UNIT_UNICODE_CELCIUS"


        elif [ "$ldf" -eq "$LDF_OUTHUMI" ]; then

            readUInt8 OD_BUFFER "outhumidity"
            export LIVEDATA_OUTHUMI="$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:outhumi type: uint8 $LIVEDATA_OUTHUMI $LIVEDATAUNIT_HUMIDITY"


        elif [ "$ldf" -eq "$LDF_WINDDIRECTION" ]; then

            readUInt16BE OD_BUFFER "winddirection"
            export LIVEDATA_WINDDIRECTION="$VALUE_UINT16BE"
            convertWindDirectionToCompassDirection "$LIVEDATA_WINDDIRECTION"
            export LIVEDATA_WINDDIRECTION_COMPASS="$VALUE_COMPASS_DIRECTION"
            export LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE="$VALUE_COMPASS_DIRECTION_UNICODE"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:winddirection type: uint16be $LIVEDATA_WINDDIRECTION $LIVEDATAUNIT_WIND_DEGREE_UNIT"


        elif [ "$ldf" -eq "$LDF_WINDSPEED" ]; then

            readUInt16BE OD_BUFFER "windspeed"
            export LIVEDATA_WINDSPEED_INTS10="$VALUE_UINT16BE"
            convertWindLivedata "$LIVEDATA_WINDSPEED_INTS10"
            export LIVEDATA_WINDSPEED="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:windspeed type: uint16be $LIVEDATA_WINDSPEED_INTS10 $LIVEDATA_WINDSPEED $UNIT_UNICODE_WIND_MPS"  


        elif [ "$ldf" -eq "$LDF_WINDGUSTSPPED" ]; then

            readUInt16BE OD_BUFFER "wingustspeed"
            export LIVEDATA_WINDGUSTSPEED_INTS10="$VALUE_UINT16BE"
            convertWindLivedata "$VALUE_UINT16BE"
            export LIVEDATA_WINDGUSTSPEED="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:windgustspeed type: uint16be $LIVEDATA_WINDGUSTSPEED_INTS10 $LIVEDATA_WINDGUSTSPEED $UNIT_UNICODE_WIND_MPS"


        elif [ "$ldf" -eq "$LDF_DAYLWINDMAX" ]; then

            readUInt16BE OD_BUFFER "winddailymax"
            export LIVEDATA_WINDDAILYMAX_INTS10="$VALUE_UINT16BE"
            convertWindLivedata "$VALUE_UINT16BE"
            export LIVEDATA_WINDDAILYMAX="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:winddailymax type: uint16be $LIVEDATA_WINDDAILYMAX_INTS10 $LIVEDATA_WINDDAILYMAX $UNIT_UNICODE_WIND_MPS"


        elif [ "$ldf" -eq "$LDF_LIGHT" ]; then

            readUInt32BE OD_BUFFER "light"
            export LIVEDATA_SOLAR_LIGHT_INTS10="$VALUE_UINT32BE"
            convertLightLivedata "$LIVEDATA_SOLAR_LIGHT_INTS10"
            export LIVEDATA_SOLAR_LIGHT="$VALUE_SCALE10_FLOAT"

            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:light type: uint32be $LIVEDATA_SOLAR_LIGHT_INTS10 lux $LIVEDATA_SOLAR_LIGHT  $LIVEDATAUNIT_SOLAR_LIGHT"


        elif [ "$ldf" -eq "$LDF_UV" ]; then

            readUInt16BE OD_BUFFER "uv"
            export LIVEDATA_SOLAR_UV_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_SOLAR_UV_INTS10" # assume its scale 10?
            export LIVEDATA_SOLAR_UV="$VALUE_SCALE10_FLOAT"
            # uv gain can be used to calibrate value
            #is it µW/m^2? is it scale 10 ? scale 10 gives best resolution
            #scale 10: 0.1 µW/m2 = 0.1/(100*cm*100cm) = 0.1/(10000cm^2) = 1000 µW/cm^2 = 1mW/cm^2, resolution: 1mW/cm2
            #not scale 10: 1 µW/m2 = 10mW/cm2, resolution: 10mW/cm2
            #conversion info: https://www.linshangtech.com/tech/tech508.html
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:uv type: uint16be $LIVEDATA_SOLAR_UV_INTS10 $LIVEDATA_SOLAR_UV $LIVEDATAUNIT_SOLAR_LIGHT_UV = $LIVEDATA_SOLAR_UV_INTS10 mW/㎠"

        elif [ "$ldf" -eq "$LDF_UVI" ]; then

            readUInt8 OD_BUFFER "uvi"
            export LIVEDATA_SOLAR_UVI="$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:uvi type: uint8 $LIVEDATA_SOLAR_UVI"


        elif [ "$ldf" -eq "$LDF_SOILMOISTURE1" ] || [ "$ldf" -eq "$LDF_SOILMOISTURE2" ] ||
             [ "$ldf" -eq "$LDF_SOILMOISTURE3" ] || [ "$ldf" -eq "$LDF_SOILMOISTURE4" ] ||
             [ "$ldf" -eq "$LDF_SOILMOISTURE5" ] || [ "$ldf" -eq "$LDF_SOILMOISTURE6" ] ||
             [ "$ldf" -eq "$LDF_SOILMOISTURE7" ] || [ "$ldf" -eq "$LDF_SOILMOISTURE8" ]; then #is 16 channels supported?

            channel=$((((ldf - LDF_SOILMOISTURE1) / 2) + 1))
            readUInt8 OD_BUFFER "soilmoisture$channel"
            eval "export LIVEDATA_SOILMOISTURE$channel=$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:soilmoisture$channel type: uint8 $VALUE_UINT8 $LIVEDATAUNIT_HUMIDITY"

 
        elif [ "$ldf" -eq "$LDF_SOILTEMP1" ] || [ "$ldf" -eq "$LDF_SOILTEMP2" ] ||
             [ "$ldf" -eq "$LDF_SOILTEMP3" ] || [ "$ldf" -eq "$LDF_SOILTEMP4" ] ||
             [ "$ldf" -eq "$LDF_SOILTEMP5" ] || [ "$ldf" -eq "$LDF_SOILTEMP6" ] ||
             [ "$ldf" -eq "$LDF_SOILTEMP7" ] || [ "$ldf" -eq "$LDF_SOILTEMP8" ]; then

            readInt16
            convertTemperatureLivedata "$VALUE_INT16BE"
            channel=$((((ldf - LDF_SOILTEMP1) / 2) + 1))
            eval "export LIVEDATA_SOILTEMP${channel}_INTS10=$VALUE_INT16BE"
            eval "export LIVEDATA_SOILTEMP$channel=$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:soiltemperature$channel type: int16be $VALUE_INT16BE $VALUE_SCALE10_FLOAT $UNIT_UNICODE_CELCIUS"


        elif [ "$ldf" -ge "$LDF_TEMP1" ] && [ "$ldf" -le "$LDF_TEMP8" ]; then
            channel=$((ldf - LDF_TEMP1 + 1))

            readInt16BE OD_BUFFER "temp $channel"
            convertTemperatureLivedata "$VALUE_INT16BE"

            eval "export LIVEDATA_WH31TEMP${channel}_INTS10=$VALUE_INT16BE"
            eval "export LIVEDATA_WH31TEMP$channel=$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:temperature$channel type: int16be $VALUE_INT16BE $VALUE_SCALE10_FLOAT $UNIT_UNICODE_CELCIUS"


        elif [ "$ldf" -ge "$LDF_HUMI1" ] && [ "$ldf" -le "$LDF_HUMI8" ]; then

            channel=$((ldf - LDF_HUMI1 + 1))
            readUInt8 OD_BUFFER "humidity$channel"

            eval "export LIVEDATA_WH31HUMI$channel=$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:humidity$channel type: uint8 $VALUE_UINT8 $LIVEDATAUNIT_HUMIDITY"


        elif [ "$ldf" -eq "$LDF_RAINMONTH" ]; then

            readUInt32BE "OD_BUFFER" "rainmonth"
            export LIVEDATA_RAINMONTH_INTS10="$VALUE_UINT32BE"
            convertScale10ToFloat "$LIVEDATA_RAINMONTH_INTS10"
            export LIVEDATA_RAINMONTH="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:rainmonth type: uint32be $VALUE_UINT32BE rainmonth: $LIVEDATA_RAINMONTH"

        elif [ "$ldf" -eq "$LDF_RAINYEAR" ]; then

            readUInt32BE "OD_BUFFER" "rainyear"
            export LIVEDATA_RAINYEAR_INTS10="$VALUE_UINT32BE"
            convertScale10ToFloat "$LIVEDATA_RAINYEAR_INTS10"
            export LIVEDATA_RAINYEAR="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:rainyear type: uint32be $VALUE_UINT32BE rainyear: $LIVEDATA_RAINYEAR"

        elif [ "$ldf" -eq "$LDF_RAINWEEK" ]; then

            readUInt16BE OD_BUFFER "rainweek"
            export LIVEDATA_RAINWEEK_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_RAINWEEK_INTS10"
            export LIVEDATA_RAINWEEK="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:rainweek type: uint16be $VALUE_UINT16BE rainyear: $LIVEDATA_RAINWEEK"


        elif [ "$ldf" -eq "$LDF_RAINDAY" ]; then

            readUInt16BE OD_BUFFER "rainday"
            export LIVEDATA_RAINDAY_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_RAINDAY_INTS10"
            export LIVEDATA_RAINDAY="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:rainday type: uint16be $VALUE_UINT16BE rainday: $LIVEDATA_RAINDAY"


        elif [ "$ldf" -eq "$LDF_RAINEVENT" ]; then

            readUInt16BE OD_BUFFER "rainevent"
            export LIVEDATA_RAINEVENT_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_RAINEVENT_INTS10"
            export LIVEDATA_RAINEVENT="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:rainevent type: uint16be $VALUE_UINT16BE rainevent: $LIVEDATA_RAINWEEK"


        elif [ "$ldf" -eq "$LDF_RAINRATE" ]; then

            readUInt16BE OD_BUFFER "rainrate"
            export LIVEDATA_RAINRATE_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_RAINRATE_INTS10"
            export LIVEDATA_RAINRATE="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC f:$ldf_hex name:rainrate type: uint16be $VALUE_UINT16BE rainerate: $LIVEDATA_RAINRATE"


        elif [ "$ldf" -ge "$LDF_LEAK_CH1" ] && [ "$ldf" -le "$LDF_LEAK_CH4" ]; then
            channel=$((ldf - LDF_LEAK_CH1 + 1))
            readUInt8 OD_BUFFER "leak$channel"
            eval "export LIVEDATA_LEAK$channel=$VALUE_UINT8"

        elif [ "$ldf" -eq "$LDF_PM25_CH1" ]; then

            readUInt16BE OD_BUFFER "PM25 1"
            export LIVEDATA_PM251_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_PM251_INTS10"
            export LIVEDATA_PM251="$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -ge "$LDF_PM25_CH2" ] && [ "$ldf" -le "$LDF_PM25_CH4" ]; then

            channel=$((ldf - LDF_PM25_CH1 + 1))
            readUInt16BE OD_BUFFER "PM25 $channel"
            eval "export LIVEDATA_PM25${channel}_INTS10=$VALUE_UINT16BE"
            eval "convertScale10ToFloat \$LIVEDATA_PM25${channel}_INTS10"
            eval "export LIVEDATA_PM25$channel=$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -ge "$LDF_PM25_24HAVG1" ] && [ "$ldf" -le "$LDF_PM25_24HAVG4" ]; then

            channel=$((ldf - LDF_PM25_24HAVG1 + 1))
            readUInt16BE OD_BUFFER "PM25 24h avg $channel"
            eval "export LIVEDATA_PM25${channel}_24HAVG_INTS10=$VALUE_UINT16BE"
            eval "convertScale10ToFloat \$LIVEDATA_PM25${channel}_24HAVG_INTS10"
            eval "export LIVEDATA_PM25{$channel}_24HAVG=$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -eq "$LDF_SENSOR_CO2" ]; then

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

            readInt16BE OD_BUFFER "CO2 tempf"
            export LIVEDATA_WH45CO2_TEMPF_INTS10="$VALUE_INT16BE"
            convertScale10ToFloat "$LIVEDATA_WH45CO2_TEMPF_INTS10"
            export LIVEDATA_WH45CO2_TEMPF="$VALUE_SCALE10_FLOAT"

            readUInt8 OD_BUFFER "CO2 humidity"
            export LIVEDATA_WH45CO2_HUMI="$VALUE_UINT8"

            readUInt16BE OD_BUFFER "CO2 PM10"
            export LIVEDATA_WH45CO2_PM10_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_WH45CO2_PM10_INTS10"
            export LIVEDATA_WH45CO2_PM10="$VALUE_SCALE10_FLOAT"

            readUInt16BE OD_BUFFER "CO2 PM10 24h avg"
            export LIVEDATA_WH45CO2_PM10_24HAVG_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_WH45CO2_PM10_24HAVG_INTS10"
            export LIVEDATA_WH45CO2_PM10_24HAVG="$VALUE_SCALE10_FLOAT"

            readUInt16BE OD_BUFFER "CO2 PM25"
            export LIVEDATA_WH45CO2_PM25_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_WH45CO2_PM25_INTS10"
            export LIVEDATA_WH45CO2_PM25="$VALUE_SCALE10_FLOAT"

            readUInt16BE OD_BUFFER "CO2 PM25 24h avg"
            export LIVEDATA_WH45CO2_PM25_24HAVG_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_WH45CO2_PM25_24HAVG_INTS10"
            export LIVEDATA_WH45CO2_PM25_24HAVG="$VALUE_SCALE10_FLOAT"

            readUInt16BE OD_BUFFER "CO2"
            export LIVEDATA_WH45CO2_CO2="$VALUE_UINT16BE"

            readUInt16BE OD_BUFFER "CO2 24g avg"
            export LIVEDATA_WH45CO2_CO2_24HAVG="$VALUE_UINT16BE"

            readUInt8 OD_BUFFER "CO2 battery"
            export LIVEDATA_WH45CO2_BATTERY="$VALUE_UINT8"

        elif [ "$ldf" -ge "$LDF_TF_USR1" ] && [ "$ldf" -le "$LDF_TF_USR8" ]; then
            channel=$((ldf - LDF_TF_USR1 + 1))
            readInt16BE OD_BUFFER "tf_usr$channel"
            convertTemperatureLivedata "$VALUE_INT16BE"

            eval "export LIVEDATA_TF_USR${channel}_INT16=$VALUE_INT16"
            eval "export LIVEDATA_TF_USR$channel=$VALUE_SCALE10_FLOAT"

            readUInt8 OD_BUFFER "tf_usr$channel battery"
            eval "export LIVEDATA_TF_USR${channel}_BATTERY_INTS10=$VALUE_UINT8"
            eval "convertScale10ToFloat \$LIVEDATA_TF_USR${channel}_BATTERY_INTS10"
            eval "export LIVEDATA_TF_USR${channel}_BATTERY=$VALUE_SCALE10_FLOAT"
            getBatteryVoltageLevelState "$VALUE_UINT8"
            eval "export LIVEDATA_TF_USR${channel}_BATTERY_STATE=$SBATTERY_STATE"
            

        elif [ "$ldf" -ge "$LDF_LIGHTNING" ]; then

            readUInt8 OD_BUFFER "lightning distance"
            export LIVEDATA_LIGHTNING_DISTANCE="$VALUE_UINT8" # 1-40km

        elif [ "$ldf" -ge "$LDF_LIGHTNING_TIME" ]; then

            readUInt32BE "OD_BUFFER" "lightning type"
            export LIVEDATA_LIGHTNING_TIME="$VALUE_UINT32BE"
            getDateUTC "$LIVEDATA_LIGHTNING_TIME"
            export LIVEDATA_LIGHTNING_TIME_UTC="$VALUE_DATE_UTC"


        elif [ "$ldf" -ge "$LDF_LIGHTNING_POWER" ]; then

            readUInt32BE "OD_BUFFER" "lightning power"
            export LIVEDATA_LIGHTNING_POWER="$VALUE_UINT32BE"

        elif [ "$ldf" -ge "$LDF_LEAF_WETNESS_CH1" ] && [ "$ldf" -le "$LDF_LEAF_WETNESS_CH8" ]; then

            channel=$((ldf - LDF_LEAF_WETNESS_CH1 + 1))
            readUInt8 OD_BUFFER "leafwetness$channel"

            eval "export LIVEDATA_LEAFWETNESS${channel}=$VALUE_UINT8"

        else
            echo >&2 "ERROR Unable to parse livedata field $(printf "%x" "$ldf")"
        fi

    done

    if [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ]; then
        readUInt8 OD_BUFFER "checksum"
        checksum=$VALUE_UINT8
        echo >&2 checksum "$(printf "%02x dec:%02u" "$checksum" "$checksum")"
    fi

    [ "$DEBUG_OPTION_TESTSENSOR" -eq 1 ] && injectTestSensorLivedata

    #[ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] &&
    # export -p

    printOrLogLivedata

    unset ldf channel checksum DEBUG_FUNC parselivedata_max_length
    
}

readPacketPreambleCommandLength()
# verify preamble = ff ff, read command and packet length
# $1 buffername
# set PACKET_RX_LENGTH, PACKET_RX_CRC (optional if strict packet check)
# set EXITCODE_PARSEPACKET
{
    EXITCODE_PARSEPACKET=0

    readPacketPreambleCommandLength_buffername=$1
    eval realPacketLength="\$${readPacketPreambleCommandLength_buffername}_LENGTH"
    #shellcheck disable=SC2154
    packetCRCPosition=$(( realPacketLength - 1 )) # -1 due to 0-index

    readSlice "$1" 4 "packet preamble"

    IFS=" " 
    #shellcheck disable=SC2086
    set -- $VALUE_SLICE # $1= 255 $2=255, $3=command, $4 msb packet length, optional $5 lsb packet length
    PRX_PREAMBLE="$1 $2"

    if [ "$PRX_PREAMBLE" != "255 255" ]; then
        EXITCODE_PARSEPACKET="$ERROR_PRX_PREAMBLE"
        return "$EXITCODE_PARSEPACKET"
    fi

    PRX_CMD_UINT8=$(($3))
    getCommandName "$PRX_CMD_UINT8"
  
    #Packet length
    if [ "$PRX_CMD_UINT8" -eq "$CMD_BROADCAST" ] || [ "$PRX_CMD_UINT8" -eq "$CMD_LIVEDATA" ] || [ "$PRX_CMD_UINT8" -eq "$CMD_READ_SENSOR_ID_NEW" ]; then
        readUInt8 "$readPacketPreambleCommandLength_buffername" "command name: $COMMAND_NAME dec: $PRX_CMD_UINT8 16-bit packet length msb: $4 lsb"
        PACKET_RX_LENGTH_BYTES=2
        PACKET_RX_LENGTH=$(( ($4 << 8) | VALUE_UINT8))
    else
        PACKET_RX_LENGTH_BYTES=1
        PACKET_RX_LENGTH=$(($4))
    fi

    eval packetContentPosition="\$${readPacketPreambleCommandLength_buffername}_HEAD" # backup position

    if [ "$DEBUG_OPTION_STRICTPACKET" -eq 1 ]; then
        # verify packet length
        #shellcheck disable=SC2154
        if ! [ $(( realPacketLength - 2 )) -eq $PACKET_RX_LENGTH  ]; then # -2 for "255 255" packet header
            #[ "$DEBUG" -eq 1 ] && 
            printf >&2  "Warning: %s dec: %u hex: %x, reported packet length %u not the same as actual packet length %u\n" "$COMMAND_NAME" "$PRX_CMD_UINT8" "$PRX_CMD_UINT8" "$PACKET_RX_LENGTH" "$(( realPacketLength - 2 ))"
            EXITCODE_PARSEPACKET=$ERROR_PARSEPACKET_LENGTH
        else
            [ "$DEBUG" -eq 1 ] &&  echo >&2 "RX PACKET LENGTH (byte 3 in packet) $PACKET_RX_LENGTH, actual packet length $(( realPacketLength - 2 )) "
        fi

        readUInt8 "$readPacketPreambleCommandLength_buffername" "verify crc" $packetCRCPosition
        PACKET_RX_CRC=$VALUE_UINT8
        eval getPacketCRC "\"\$$readPacketPreambleCommandLength_buffername\""
        if [ "$PACKET_RX_CRC" -ne "$VALUE_CRC" ]; then
            printf >&2 "Warning: %s, dec: %u hex: %x , inpacket crc %u != %u  (calculated), packet CRC index: %u\n" "$COMMAND_NAME" "$PRX_CMD_UINT8"  "$PRX_CMD_UINT8" "$PACKET_RX_CRC" "$VALUE_CRC" "$packetCRCPosition"
            EXITCODE_PARSEPACKET=$ERROR_PARSEPACKET_CRC
        fi

        #shellcheck disable=SC2154
        moveHEAD "$readPacketPreambleCommandLength_buffername" "$packetContentPosition" #restore position
    fi

    unset realPacketLength packetCRCPosition

    return "$EXITCODE_PARSEPACKET"
}

getPacketCRC()
# calculate packet crc from space delimited decimal buffer
# $1 buffer
# set VALUE_CRC
# https://stackoverflow.com/questions/11670935/comments-in-command-line-zsh#11873793
# zsh command-line: run setopt shwordsplit, setopt interactivecomments
{
    VALUE_CRC=0
    IFS=' '
    #shellcheck disable=SC2086
    set -- $1
    shift 2 # ignore preamble 255 255

    for BYTE; do
            #in "$@"
       VALUE_CRC=$(( VALUE_CRC + BYTE ))
    done
    VALUE_CRC=$(( (VALUE_CRC - BYTE) & 255 )) # only 8-bit crc, BYTE is last byte/CRC
}

parsePacket()
# main parser, distributes parsing to other functions for each packet 
# $1 od buffer
{
     EXITCODE_PARSEPACKET=0

     if [ -z "$1" ]; then
         [ "$DEBUG" -eq 1 ] && echo >&2 Warning: parsePacket: Empty buffer/response received
        EXITCODE_PARSEPACKET="$ERROR_OD_BUFFER_EMPTY"
        return "$EXITCODE_PARSEPACKET"
    fi

    newBuffer "OD_BUFFER" "$1"
    OD_BUFFER_BACKUP="$1"

   if ! readPacketPreambleCommandLength "OD_BUFFER"; then
      echo >&2 "Warning: Packet preamble failure, errorcode: $EXITCODE_PARSEPACKET"

      #return "$EXITCODE_PARSEPACKET"
   fi

     { [ "$DEBUG" -eq 1 ] || [ "$DEBUG_OPTION_OD_BUFFER" ] ; } && {
       printf >&2 "< %-20s" "$COMMAND_NAME"
       printBuffer >&2 "$OD_BUFFER_BACKUP" 
    }

    if isWriteCommand "$PRX_CMD_UINT8"; then
        parseResult
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_VERSION" ]; then
        parseVersion
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_MAC" ]; then
        parseMAC
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_ECOWITT_INTERVAL" ]; then
        parseEcowittInterval
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_WUNDERGROUND" ]; then
        parseWunderground
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_WEATHERCLOUD" ]; then
        parseWeathercloud
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_WOW" ]; then
        parseWow
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_SYSTEM" ]; then
        parseSystem
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_LIVEDATA" ]; then
        parseLivedata
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_BROADCAST" ]; then
        parseBroadcast
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_RAINDATA" ]; then
        parseRaindata
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_CALIBRATION" ]; then
        parseCalibration
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_PATH" ]; then
        parsePath
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_CUSTOMIZED" ]; then
        parseCustomized
    elif [ "$PRX_CMD_UINT8" -eq "$CMD_READ_SENSOR_ID_NEW" ] ||[ "$PRX_CMD_UINT8" -eq "$CMD_READ_SENSOR_ID" ]; then
        parseSensorIdNew
    else
        echo >&2 ERROR Parsing of command "$COMMAND_NAME" not supported
        EXITCODE_PARSEPACKET=$ERROR_PARSEPACKET_UNSUPPORTED_COMMAND
    fi

    [ "$DEBUG" -eq 1 ] && echo >&2 "Received command $PRX_CMD integer cmd $PRX_CMD_UINT8"

    return "$EXITCODE_PARSEPACKET"
}

restoreBackup()
# restore configuration from backup file
# $1 filename
# $2 host
{
    RESTORE_BUFFER="$(od -A n -t u1 -w"$MAX_16BIT_UINT" "$1")"

    while [ ${#RESTORE_BUFFER} -gt 0 ]; do 

        if ! readPacketPreambleCommandLength  "RESTORE_BUFFER"; then
            return "$EXITCODE_PARSEPACKET"
        fi

        echo >&2 "Restore $COMMAND_NAME dec: $PRX_CMD_UINT8 packet length:$PACKET_RX_LENGTH, packet length bytes: $PACKET_RX_LENGTH_BYTES"

        newPacket "$(( PRX_CMD_UINT8 + 1))" # write command (read + 1 )
        RESTORE_N=1
        while [ $RESTORE_N -le $(( PACKET_RX_LENGTH - PACKET_RX_LENGTH_BYTES - 2 )) ]; do # -2 = command + checksum
            readUInt8 "RESTORE_BUFFER"
          # writeUInt8 "PACKET_TX" "$VALUE_UINT8"
            echo >&2 "Read RESTORE_N:$RESTORE_N uint8:$VALUE_UINT8 uint8hex:$(printf "%x" "$VALUE_UINT8") restorebuflen: ${#RESTORE_BUFFER}"
            RESTORE_N=$(( RESTORE_N + 1))
            done

            DEBUG_SENDPACKETNC=1 sendPacket "$(( PRX_CMD_UINT8 + 1))" "$2"

            readUInt8 "RESTORE_BUFFER" #checksum
    done

}

isWriteCommand() {
    [ "$1" -eq "$CMD_WRITE_ECOWITT_INTERVAL" ] ||
        [ "$1" -eq "$CMD_WRITE_RESET" ] ||
        [ "$1" -eq "$CMD_WRITE_CUSTOMIZED" ] ||
        [ "$1" -eq "$CMD_WRITE_PATH" ] ||
        [ "$1" -eq "$CMD_REBOOT" ] ||
        [ "$1" -eq "$CMD_WRITE_SSID" ] ||
        [ "$1" -eq "$CMD_WRITE_RAINDATA" ] ||
        [ "$1" -eq "$CMD_WRITE_WUNDERGROUND" ] ||
        [ "$1" -eq "$CMD_WRITE_WOW" ] ||
        [ "$1" -eq "$CMD_WRITE_WEATHERCLOUD" ] ||
        [ "$1" -eq "$CMD_WRITE_SENSOR_ID" ] ||
        [ "$1" -eq "$CMD_WRITE_CALIBRATION" ] ||
        [ "$1" -eq "$CMD_WRITE_SYSTEM" ]
}

printWeatherServices ()
# $1 - host
 {
    sendPacket "$CMD_READ_ECOWITT_INTERVAL" "$1"
    sendPacket "$CMD_READ_WUNDERGROUND" "$1"
    sendPacket "$CMD_READ_WOW" "$1"
    sendPacket "$CMD_READ_WEATHERCLOUD" "$1"
    sendPacket "$CMD_READ_CUSTOMIZED" "$1"
}

getSignalUnicode()
{
    eval VALUE_SIGNAL_UNICODE="\$UNICODE_SIGNAL_LEVEL$1"
}

setSignal()
#$1 sensorname WH?? $2 value
{
    export LIVEDATA_"$1"_SIGNAL="$2"
    getSignalUnicode "$2"
    export LIVEDATA_"$1"_SIGNAL_STATE="$VALUE_SIGNAL_UNICODE" 
}

setLivedataSignal()
# $1 sensortype $2 signal
#maps sensor type to livedata
{
    
    if [ "$1" -ge "$SENSORTYPE_WH31TEMP" ] && [ "$1" -lt $(( SENSORTYPE_WH31TEMP + SENSORTYPE_WH31TEMP_MAXCH )) ]; then
        setSignal "WH31TEMP$(( $1 - SENSORTYPE_WH31TEMP + 1))" "$2"
    elif [ "$1" -eq "$SYSTEM_SENSOR_TYPE_WH24" ]; then
        setSignal "WH65" "$2"
    elif [ "$1" -eq "$SENSORTYPE_WH68" ]; then
        setSignal "WH68" "$2"
    elif [ "$1" -eq "$SENSORTYPE_WH80" ]; then
        setSignal "WH80" "$2"
    elif [ "$1" -eq "$SENSORTYPE_WH32" ]; then
        setSignal "WH32" "$2"
    elif [ "$1" -eq "$SENSORTYPE_WH40" ]; then
       setSignal "WH40_RAINFALL" "$2"
    elif [ "$1" -eq "$SENSORTYPE_WH57LIGHTNING" ]; then
       setSignal "LIGHTNING" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH51SOILMOISTURE" ] && [ "$1" -lt $(( SENSORTYPE_WH51SOILMOISTURE + SENSORTYPE_WH51SOILMOISTURE_MAXCH )) ]; then
       setSignal "SOILMOISTURE$(( $1 - SENSORTYPE_WH51SOILMOISTURE + 1))" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH55LEAK" ] && [ "$1" -lt $(( SENSORTYPE_WH55LEAK + SENSORTYPE_WH55LEAK_MAXCH )) ]; then
       setSignal "LEAK$(( $1 - SENSORTYPE_WH55LEAK + 1))" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH34SOILTEMP" ] && [ "$1" -lt $(( SENSORTYPE_WH34SOILTEMP + SENSORTYPE_WH34SOILTEMP_MAXCH )) ]; then
       setSignal "SOILTEMP$(( $1 - SENSORTYPE_WH34SOILTEMP + 1))" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH43PM25" ] && [ "$1" -lt $(( SENSORTYPE_WH43PM25 + SENSORTYPE_WH43PM25_MAXCH )) ]; then
       setSignal "PM25$(( $1 - SENSORTYPE_WH43PM25 + 1))" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH35LEAFWETNESS" ] && [ "$1" -lt $(( SENSORTYPE_WH35LEAFWETNESS + SENSORTYPE_WH35LEAFWETNESS_MAXCH )) ]; then
       setSignal "LEAFWETNESS$(( $1 - SENSORTYPE_WH35LEAFWETNESS + 1))" "$2"
    fi
      
}

getSensorBatteryState()
{
   
    #specification FOS_ENG-022-A, page 28
    unset SBATTERY_STATE

     case "$1" in
        0) setBatteryLowNormal "WH65" "$2" # WH65
            ;;
        1) setBatteryVoltageLevel "WH68" "$2"
            ;;
        2) setBatteryVoltageLevel "WH80" "$2"
            ;;
        3) setBatteryLowNormal "WH40_RAINFALL" "$2"
            ;;
        5) setBatteryLowNormal "WH32_TEMPERATURE" "$2"
            ;;
        6|7|8|9|10|11|12|13)
           channel=$(($1 - 5))
           setBatteryLowNormal "WH31TEMP$channel" "$2"
           ;;
        14|15|16|17|18|19|20|21)
           channel=$(( $1 - 13))
           setBatteryVoltageLevel "SOILMOISTURE$channel" "$2"
          ;;
        22|23|24|25)
          channel=$(( $1 - 21 ))
          setBatteryLevel "PM25$channel" "$2"
          ;;
        26)
          setBatteryLevel "WH57_LIGHTNING" "$2"
          ;;
        27|28|29|30)
          channel=$(( $1 - 26 ))
          setBatteryLevel "LEAK$channel" "$2"
          ;;
        31|32|33|34|35|36|37|38)
           channel=$(( $1 - 30))
           setBatteryVoltageLevel "SOILTEMP$channel" "$2"
           ;;
        39)
           setBatteryLevel "WH45CO2" "$2"
           #battery info also available from sensor read livedata
          ;;
        40|41|42|43|44|45|46|47)
           channel=$(( $1 - 39))
           setBatteryVoltageLevel "LEAFWETNESS$channel" "$2"
           ;;
    esac

    unset channel
}

setBatteryLowNormal()
{
     getBatteryLowOrNormal "$2" 
    eval "export LIVEDATA_${1}_BATTERY=$2"
    eval "export LIVEDATA_${1}_BATTERY_STATE='$SBATTERY_STATE'"
}

setBatteryVoltageLevel()
{
    getBatteryVoltageLevelState "$2"
    eval "export LIVEDATA_${1}_BATTERY_UINT8=$2"
    eval "export LIVEDATA_${1}_BATTERY=$VALUE_BATTERY_VOLTAGE"
    eval "export LIVEDATA_${1}_BATTERY_STATE='$SBATTERY_STATE'"
}

setBatteryLevel()
{
    getBatteryLevelState "$2"
    eval "export LIVEDATA_${1}_BATTERY=$2"
    eval "export LIVEDATA_${1}_BATTERY_STATE='$SBATTERY_STATE'"
}

appendBatteryState()
{
   if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
        SBATTERY_STATE=$SBATTERY_STATE$UNICODE_BATTERY
   else
        SBATTERY_STATE=$SBATTERY_STATE"+"
   fi 
}

appendLowBatteryState()
{
    if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
    #https://emojipedia.org/low-battery/ "Coming to major platforms in late 2021 and throughout 2022".
         SBATTERY_STATE=$SBATTERY_STATE$UNICODE_BATTERY_LOW 
    else
        SBATTERY_STATE=$SBATTERY_STATE"LOW"
    fi
}

getBatteryVoltageLevelState()
#$1 - volatage scaled *10
# set VALUE_BATTERY_VOLTAGE
# set SBATTERY_STATE
{
     if [ "$SHELL_SUPPORT_TYPESET" -eq 1 ]; then
        #shellcheck disable=SC3044
  #      typeset -i  i
    :
    else
   #     local       i
    :
    fi

   unset SBATTERY_STATE

   if [ "$1" -le 12 ]; then
      appendLowBatteryState
   else
    # i=13
    # while [ "$i" -le "$1" ]; do
       appendBatteryState # not really linear, but approximate 
    #   i=$(( i + 1 ))
    # done
   fi
   VALUE_VOLTAGE_SCALE10=$1
   convertScale10ToFloat "$VALUE_VOLTAGE_SCALE10"
   VALUE_BATTERY_VOLTAGE="$VALUE_SCALE10_FLOAT"
   SBATTERY_STATE=$SBATTERY_STATE" ${VALUE_BATTERY_VOLTAGE}V"

   if [ -n "$KSH_VERSION" ]; then
        unset  i
    fi
}

getBatteryLevelState() { # $1 - battery level 0-6, 6 = dc, <=1 low
    
    unset SBATTERY_STATE
   
    #set -- 0     #debug  set $1 to 0
    if [ "$1" -eq 6 ]; then
      if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
       #https://emojipedia.org/electric-plug/
        SBATTERY_STATE=$UNICODE_PLUG
      else
        SBATTERY_STATE="dc" # for example PM 2.5 indoor
      fi
    else
       # l=1
       # while [ "$l" -le 5 ] ; do
       #     if [ "$l" -le "$1" ]; then
       #         appendBatteryState
       #     else
       #         appendLowBatteryState
       #     fi
       #     l=$((l + 1))
       # done
       if [ "$1" -le 1 ]; then
          appendLowBatteryState
       else
          appendBatteryState
       fi

       SBATTERY_STATE=$SBATTERY_STATE" $1"
    fi

    unset  l
}

getBatteryLowOrNormal() {
    
    unset SBATTERY_STATE

    if [ "$1" -eq "$BATTERY_NORMAL" ]; then
       appendBatteryState
    elif [ "$1" -eq "$BATTERY_LOW" ]; then
        appendLowBatteryState
    fi
}

getSensorIdCommand()
# get sensor id command based on firmware version
# $1 integer - firmware version 
# set VALUE_SENSOR_COMMAND
{
    unset VALUE_SENSORID_READ_COMMAND

    if [ "$1" -ge "$FW_CMD_READ_SENSOR_ID_NEW" ]; then # Added in fw v 1.5.4 
        VALUE_SENSORID_READ_COMMAND="$CMD_READ_SENSOR_ID_NEW"  #support soiltemp, co2, leafwetness
    elif [ "$1" -ge "$FW_CMD_READ_SENSOR_ID" ]; then # Added in fw v 1.4.6
        VALUE_SENSORID_READ_COMMAND="$CMD_READ_SENSOR"
    else
        echo >&2 "Warning: Firmware $1 does not support command sensor id (dec $CMD_READ_SENSOR)/sensor id new (dec $CMD_READ_SENSOR_ID_NEW)"
        return "$ERROR_SENSORID_COMMAND_NOT_SUPPORTED"
    fi
    
    return 0
}