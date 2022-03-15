#!/bin/sh

GWDIR=${GWDIR:=.}
. "$GWDIR/lib/binary-fields.sh"

parseVersion() {
    readString "$VALUE_PARSEPACKET_BUFFERNAME" "version"
    export GW_VERSION="$VALUE_STRING"
    getVersionInt "$GW_VERSION"
    export GW_VERSION_INT="$VALUE_VERSION"
    echo "$GW_VERSION"
}

parseMAC() 
{
    readSlice "$VALUE_PARSEPACKET_BUFFERNAME" 6 "MAC"
    setMAC "$VALUE_SLICE"
    export GW_MAC="$VALUE_MAC"
    echo "$GW_MAC"
}

parseResult() {
    
    readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" 'write result'
    write_result=$VALUE_UINT8
    export GW_RESULT="$write_result"

    if [ "$write_result" -eq 0 ]; then
        #:
        [ "$DEBUG_OPTION_RESULT" -eq 1 ] && echo >&2 "$VALUE_COMMAND_NAME OK"
    elif [ "$write_result" -eq 1 ]; then
        echo >&2 "$VALUE_COMMAND_NAME FAIL"
    else
        echo >&2 "$VALUE_COMMAND_NAME errorcode: $write_result"
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

    readSlice "$VALUE_PARSEPACKET_BUFFERNAME" 12 "broadcast"
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

    readString "$VALUE_PARSEPACKET_BUFFERNAME" "ssid version"
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

    readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "ecowitt interval"
    export GW_WS_ECOWITT_INTERVAL="$VALUE_UINT8"
    printEcowittInterval
}

printWunderground() {
    echo "wunderground station id       $GW_WS_WUNDERGROUND_ID
wunderground station password $GW_WS_WUNDERGROUND_PASSWORD"
}

parseWunderground() {
    readString "$VALUE_PARSEPACKET_BUFFERNAME" "wunderground id"
    export GW_WS_WUNDERGROUND_ID="$VALUE_STRING"
    readString "$VALUE_PARSEPACKET_BUFFERNAME" "wunderground password"
    GW_WS_WUNDERGROUND_PASSWORD=$VALUE_STRING

    printWunderground
}

printWeathercloud() {
    echo "weathercloud id               $GW_WS_WC_ID
weathercloud password         $GW_WS_WC_PASSWORD"
}

parseWeathercloud() {
    readString "$VALUE_PARSEPACKET_BUFFERNAME" "weathercloud id"
    export GW_WS_WC_ID="$VALUE_STRING"

    readString "$VALUE_PARSEPACKET_BUFFERNAME" "weathercloud password"
    export GW_WS_WC_PASSWORD="$VALUE_STRING"

    printWeathercloud
}

printWow() {
    echo "wow id                        $GW_WS_WOW_ID
wow password                  $GW_WS_WOW_PASSWORD"
}

parseWow() {
    readString "$VALUE_PARSEPACKET_BUFFERNAME" "wow id"
    export GW_WS_WOW_ID="$VALUE_STRING"

    readString "$VALUE_PARSEPACKET_BUFFERNAME" "wow password"
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

    readInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "intemp offset"
    export GW_CALIBRATION_INTEMPOFFSET_INTS10="$VALUE_INT16BE"
    convertScale10ToFloat "$GW_CALIBRATION_INTEMPOFFSET_INTS10"
    
    GW_CALIBRATION_INTEMPOFFSET="$VALUE_SCALE10_FLOAT"

    readInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "inhumidity offset"
    export GW_CALIBRATION_INHUMIDITYOFFSET="$VALUE_INT8"

    readInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "absolute offset"
    export GW_CALIBRATION_ABSOFFSET_INTS10="$VALUE_INT32BE" 
    convertScale10ToFloat "$GW_CALIBRATION_ABSOFFSET_INTS10"
    GW_CALIBRATION_ABSOFFSET="$VALUE_SCALE10_FLOAT"

    readInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "relative offset"
    export GW_CALIBRATION_RELOFFSET_INTS10="$VALUE_INT32BE" #used for int comparison [ ... ]
    convertScale10ToFloat "$GW_CALIBRATION_RELOFFSET_INTS10"
    GW_CALIBRATION_RELOFFSET="$VALUE_SCALE10_FLOAT"

    readInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "outtemp offset"
    export GW_CALIBRATION_OUTTEMPOFFSET_INTS10="$VALUE_INT16BE"
    convertScale10ToFloat "$GW_CALIBRATION_OUTTEMPOFFSET_INTS10"
    GW_CALIBRATION_OUTTEMPOFFSET="$VALUE_SCALE10_FLOAT"

    readInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "out humidity offset"
    export GW_CALIBRATION_OUTHUMIDITYOFFSET="$VALUE_INT8"

    readInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "winddirection offset"
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
    readString "$VALUE_PARSEPACKET_BUFFERNAME" "customized id"
    export GW_WS_CUSTOMIZED_ID="$VALUE_STRING"

    readString "$VALUE_PARSEPACKET_BUFFERNAME" "customized password"
    export GW_WS_CUSTOMIZED_PASSWORD="$VALUE_STRING"

    readString "$VALUE_PARSEPACKET_BUFFERNAME" "customized server"
    export GW_WS_CUSTOMIZED_SERVER="$VALUE_STRING"

    readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "customized port"
    export GW_WS_CUSTOMIZED_PORT="$VALUE_UINT16BE"

    readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "customized interval"
    export GW_WS_CUSTOMIZED_INTERVAL="$VALUE_UINT16BE"

    readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "customized http"
    export GW_WS_CUSTOMIZED_HTTP="$VALUE_UINT8"

    if [ "$GW_WS_CUSTOMIZED_HTTP" -eq 1 ]; then
        export GW_WS_CUSTOMIZED_HTTP_STATE="wunderground"
    elif [ "$GW_WS_CUSTOMIZED_HTTP" -eq 0 ]; then
        export GW_WS_CUSTOMIZED_HTTP_STATE="ecowitt"
    fi

    readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "customized enabled"

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
    readString "$VALUE_PARSEPACKET_BUFFERNAME" "path ecowitt"
    export GW_WS_CUSTOMIZED_PATH_ECOWITT="$VALUE_STRING"
    readString "$VALUE_PARSEPACKET_BUFFERNAME" "path wunderground"
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

    readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "rainrate"
    export GW_RAINRATE_INTS10="$VALUE_UINT32BE"

    readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "raindaily"
    export GW_RAINDAILY_INTS10="$VALUE_UINT32BE"

    readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "rainweek"
    export GW_RAINWEEK_INTS10="$VALUE_UINT32BE"

    readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "rainmonth"
    export GW_RAINMONTH_INTS10="$VALUE_UINT32BE"

    readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "rainyear"
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
# mapping from sensortype to long/short names
# $1 sensortype
# set SENSORNAME_WH
# set SENSORNAME_SHORT
# set SENSORNAME_VAR
{
    unset SENSORNAME_WH SENSORNAME_SHORT SENSORNAME_VAR
    
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
            SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}"
            ;;
        1) SENSORNAME_WH='WH68'
           SENSORNAME_SHORT="Weather Station"
            SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}"
            ;;
        2) SENSORNAME_WH="WH80"
           SENSORNAME_SHORT='Weather Station'
            SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}"
            ;;
        3) SENSORNAME_WH="WH40"
           SENSORNAME_SHORT="Rainfall"
            SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}RAINFALL"

            ;;
        5) SENSORNAME_WH='WH32'
           SENSORNAME_SHORT='Temperatue out'
            SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}TEMP"

            ;;
        6|7|8|9|10|11|12|13)
           SENSORNAME_WH='WH31'
           local_channel=$(( $1 -5 ))
           SENSORNAME_SHORT="Temperature $local_channel"
           SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}TEMP$local_channel"
           ;;
        14|15|16|17|18|19|20|21)
          SENSORNAME_WH='WH51'
          local_channel=$(( $1 - 13 ))
          SENSORNAME_SHORT="Soilmoisture $local_channel"
          SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}SOILMOISTURE$local_channel"

          ;;
        22|23|24|25)
          SENSORNAME_WH='WH43'
          local_channel=$(($1 - 21))
          SENSORNAME_SHORT="PM2.5 AQ $local_channel"
          SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}PM25$local_channel"
          ;;
        26)
          SENSORNAME_SHORT="Lightning"
          SENSORNAME_WH='WH57'
          SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}LIGHTNING$local_channel"
          ;;
        27|28|29|30)
          SENSORNAME_WH='WH55'
          local_channel=$(($1 - 26))
          SENSORNAME_SHORT="Leak $local_channel"
          SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}LEAK$local_channel"
          ;;
        31|32|33|34|35|36|37|38)

          SENSORNAME_WH='WH34'
          local_channel=$(($1 - 30))
          SENSORNAME_SHORT="Soiltemperature $local_channel"
          SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}SOILTEMP$local_channel"
          
          ;;
        39)
          SENSORNAME_WH='WH45'
          SENSORNAME_SHORT="CO2 PM2.5 PM10 AQ"
          SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}CO2"

          ;;
        40|41|42|43|44|45|46|47)
            SENSORNAME_WH='WH35'
            local_channel=$(($1 - 39))
            SENSORNAME_SHORT="Leafwetness $local_channel"
            SENSORNAME_VAR="LIVEDATASENSOR_${SENSORNAME_WH}LEAFWETNESS$local_channel"

           ;;
         *)
         echo >&2 "Warning: Unknown sensortype $1"
          SENSORNAME_WH='WH??' 
          SENSORNAME_SHORT='?'
          SENSORNAME_VAR="LIVEDATASENSOR_UNKNOWN$1"
          return 1
    esac

    unset local_channel
}

printSensorLine()
#$1 - sensortype, $2 sensor id, $3 battery, $4 signal , $5 sensorid state, $6 battery state, $7signal unicode
# in: SENSORNAME_WH
# in: SENSORNAME_SHORT
{
#observation: leak sensor signal -> starts at level 1 after search state, then increases +1 each time a new rf message is received

    unset VALUE_BATTERY_STATE style_sensor
    
   # TEST data 
    #if [ "$1" -eq 40 ]; then
    #   set -- "39" "$(( 0xfff ))" 4 4  # co2
    #  set -- "40" "$(( 0xfff ))" 14 4 # leaf wetness
    #fi

    if [ "$2" -eq "$SENSORID_DISABLE" ]; then 
        style_sensor=$STYLE_SENSOR_DISABLE
    elif [ "$2" -eq "$SENSORID_SEARCH" ]; then
        style_sensor=$STYLE_SENSOR_SEARCH
    elif [ "$4" -eq 0 ]; then 
        style_sensor=$STYLE_SENSOR_DISCONNECTED
    fi

    if [ -n "$style_sensor" ]; then
       style_sensor_off=$STYLE_RESET # insert end escape sequence only if sgi is used
    fi
    
     # 1 battery unicode is field size 4 in printf format string. TEST printf  "🔋 1.3 V" | od -A n -t x1 | wc -w -> 10
     # use \r\t\t\t workaround for unicode alignment
  
    appendBuffer "%6u %9x %3u %1u %4s %-17s $style_sensor%-12s$style_sensor_off\t%s\t%s\n"\
 "'$1' '$2' '$3' '$4'  '$SENSORNAME_WH' '$SENSORNAME_SHORT' '$5' '$6' '$7'"
    
    unset style_sensor_off style_sensor
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

    [ "$DEBUG" -eq  1 ] &&  >&2 echo "parseSensorIdNew SPATTERNID $SPATTERNID"
    
     export LIVEDATASENSOR_SEARCHING=0
     export LIVEDATASENSOR_CONNECTED=0
     export LIVEDATASENSOR_DISCONNECTED=0
     export LIVEDATASENSOR_DISABLED=0

     parseSensorIdNew_max_length=$(( OD_BUFFER_LENGTH - 1 ))

    while [ "$OD_BUFFER_HEAD" -lt $parseSensorIdNew_max_length ]; do
       
        readUInt8  "$VALUE_PARSEPACKET_BUFFERNAME" "sensor type"          #type
        stype=$VALUE_UINT8
       
        readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "sensor id"        #id
        SID=$VALUE_UINT32BE

        readUInt8  "$VALUE_PARSEPACKET_BUFFERNAME" "sensor battery"
        battery=$VALUE_UINT8
        
        readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "sensor signal"
        signal=$VALUE_UINT8

        if ! getSensorNameShort "$stype"; then
          contiunue
        fi
        
        unset VALUE_BATTERY_STATE VALUE_SIGNAL_UNICODE

        if [ "$SID" -eq "$SENSORID_SEARCH" ]; then
            LIVEDATASENSOR_SEARCHING=$(( LIVEDATASENSOR_SEARCHING + 1 ))
            local_sensorstate=$SENSORIDSTATE_CONNECTED
        elif [ "$SID" -eq "$SENSORID_DISABLE" ]; then
            local_sensorstate=$SENSORIDSTATE_DISABLED
            LIVEDATASENSOR_DISABLED=$(( LIVEDATASENSOR_DISABLED + 1 ))
        elif [ "$signal" -gt 0 ]; then
            LIVEDATASENSOR_CONNECTED=$(( LIVEDATASENSOR_CONNECTED + 1 ))
            local_sensorstate=$SENSORIDSTATE_CONNECTED
            exportLivedataBattery "$stype" "$battery"
            exportLivedataSignal "$stype" "$signal"
        elif [ "$signal" -eq 0 ]; then
            local_sensorstate=$SENSORIDSTATE_DISCONNECTED
            LIVEDATASENSOR_DISCONNECTED=$(( LIVEDATASENSOR_DISCONNECTED + 1 ))
        fi

        if [ -n "$SENSORNAME_VAR" ]; then
            eval export "${SENSORNAME_VAR}_ID=$SID" "${SENSORNAME_VAR}_ID_STATE=$local_sensorstate" 
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
            printSensorLine "$stype" "$SID" "$battery" "$signal" "$local_sensorstate" "$VALUE_BATTERY_STATE" "$VALUE_SIGNAL_UNICODE"
        fi
        
        [ "$DEBUG" -eq 1 ] && >&2 echo "type $stype id $SID battery $battery signal $signal"
    done

    printAppendBuffer

    unset stype signal battery printSensorHeader printSensorMatch parseSensorIdNew_max_length local_sensorstate
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
    readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "system frequency"

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

    readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "system sensortype"

    export GW_SYSTEM_SENSORTYPE="$VALUE_UINT8"
    export GW_SYSTEM_SENSORTYPE_STATE
    if [ "$GW_SYSTEM_SENSORTYPE" -eq "$SYSTEM_SENSOR_TYPE_WH24" ]; then
        #       SENSOR_TYPE[WH24_TYPE]="WH24:Outdoor Weather Sensor:16.0:" # overwrite default WH65_TYPE=0
        GW_SYSTEM_SENSORTYPE_STATE="WH24"
    elif [ "$GW_SYSTEM_SENSORTYPE" -eq "$SYSTEM_SENSOR_TYPE_WH65" ]; then
        GW_SYSTEM_SENSORTYPE_STATE="WH65"
    fi

    readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "system utc"

    export GW_SYSTEM_UTC="$VALUE_UINT32BE"
    GW_SYSTEM_UTC_STATE="$(date -u -d @"$VALUE_UINT32BE" +'%F %T')"
    export GW_SYSTEM_UTC_STATE

    readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "system timezone index"

    export GW_SYSTEM_TIMEZONE_INDEX="$VALUE_UINT8"

    eval "GW_SYSTEM_TIMEZONE_INDEX_STATE=\$SYSTEM_TIMEZONE_$GW_SYSTEM_TIMEZONE_INDEX" # set from SYSTEM_TIMEZONE "array" variable with index
    export GW_SYSTEM_TIMEZONE_INDEX_STATE

    GW_SYSTEM_TIMEZONE_OFFSET_HOURS=${GW_SYSTEM_TIMEZONE_INDEX_STATE%%\)*} # remove )... 
    GW_SYSTEM_TIMEZONE_OFFSET_HOURS=${GW_SYSTEM_TIMEZONE_OFFSET_HOURS#\(UTC} # remove (UTC
    export GW_SYSTEM_TIMEZONE_OFFSET_HOURS

    readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "system dst status"

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

parseLivedata()
# parse livedata fields
 {
    DEBUG_FUNC="parseLivedata"
    DEBUG_PARSE_LIVEDATA=${DEBUG_PARSE_LIVEDATA:=$DEBUG}
   
    export LIVEDATA_SYSTEM_PROTOCOL="$LIVEDATA_PROTOCOL_ECOWITT_BINARY"
    export LIVEDATA_SYSTEM_PROTOCOL_LONG="$LIVEDATA_PROTOCOL_ECOWITT_BINARY_LONG"

    parselivedata_max_length=$(( OD_BUFFER_LENGTH - 1 ))

    while [ "$OD_BUFFER_HEAD" -lt  $parselivedata_max_length ]; do

       # [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "OD_BUFFER_HEAD $OD_BUFFER_HEAD OD_BUFFER_LENTH $OD_BUFFER_LENGTH"

        readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "livedata field id"
        ldf=$VALUE_UINT8

        convertUInt8ToHex "$ldf"
        ldf_hex=$VALUE_UINT8_HEX
     
        if [ "$ldf" -eq "$LDF_INTEMP" ]; then

            readInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "intemp"
            export LIVEDATA_INTEMP_INTS10="$VALUE_INT16BE"
            convertTemperatureLivedata "$LIVEDATA_INTEMP_INTS10"
            export LIVEDATA_INTEMP="$VALUE_SCALE10_FLOAT" 
             [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex intemp int16be $LIVEDATA_INTEMP_INTS10 $LIVEDATA_INTEMP $UNIT_UNICODE_CELCIUS"

        elif [ "$ldf" -eq "$LDF_INHUMI" ]; then

            readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "inhumidity"
            export LIVEDATA_INHUMI="$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex inhumi uint8 $LIVEDATA_INHUMI $LIVEDATAUNIT_HUMIDITY"


        elif [ "$ldf" -eq "$LDF_PRESSURE_ABSBARO" ]; then

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "absolute pressure"
            #shellcheck disable=SC2034
            export LIVEDATA_PRESSURE_ABSBARO_INTS10="$VALUE_UINT16BE" #may use for ansi escape coloring beyond limits
            convertPressureLivedata "$LIVEDATA_PRESSURE_ABSBARO_INTS10"
            export LIVEDATA_PRESSURE_ABSBARO="$VALUE_SCALE10_FLOAT"
            
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex absbaro uint16be $LIVEDATA_PRESSURE_ABSBARO_INTS10 $LIVEDATA_PRESSURE_ABSBARO $UNIT_UNICODE_PRESSURE_HPA"


        elif [ "$ldf" -eq "$LDF_PRESSURE_RELBARO" ]; then

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "relative pressure"
            export LIVEDATA_PRESSURE_RELBARO_INTS10="$VALUE_UINT16BE"
            convertPressureLivedata "$LIVEDATA_PRESSURE_RELBARO_INTS10"
            export LIVEDATA_PRESSURE_RELBARO="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex relbaro uint16be $LIVEDATA_PRESSURE_RELBARO_INTS10 $LIVEDATA_PRESSURE_RELBARO  $UNIT_UNICODE_PRESSURE_HPA"


        elif [ "$ldf" -eq "$LDF_OUTTEMP" ]; then

            readInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "outtemp"
            export LIVEDATA_OUTTEMP_INTS10="$VALUE_INT16BE"
            convertTemperatureLivedata "$LIVEDATA_OUTTEMP_INTS10" 
            export LIVEDATA_OUTTEMP="$VALUE_SCALE10_FLOAT"
            
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex outtemp int16be $LIVEDATA_OUTTEMP_INTS10 $LIVEDATA_OUTTEMP $UNIT_UNICODE_CELCIUS"


        elif [ "$ldf" -eq "$LDF_OUTHUMI" ]; then

            readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "outhumidity"
            export LIVEDATA_OUTHUMI="$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex outhumi uint8 $LIVEDATA_OUTHUMI $LIVEDATAUNIT_HUMIDITY"


        elif [ "$ldf" -eq "$LDF_WINDDIRECTION" ]; then

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "winddirection"
            export LIVEDATA_WINDDIRECTION="$VALUE_UINT16BE"
            convertWindDirectionToCompassDirection "$LIVEDATA_WINDDIRECTION"
            export LIVEDATA_WINDDIRECTION_COMPASS="$VALUE_COMPASS_DIRECTION"
            export LIVEDATA_WINDDIRECTION_COMPASS_NEEDLE="$VALUE_COMPASS_DIRECTION_UNICODE"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex winddirection uint16be $LIVEDATA_WINDDIRECTION $LIVEDATAUNIT_WIND_DEGREE_UNIT"


        elif [ "$ldf" -eq "$LDF_WINDSPEED" ]; then

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "windspeed"
            export LIVEDATA_WINDSPEED_INTS10="$VALUE_UINT16BE"
            convertWindLivedata "$LIVEDATA_WINDSPEED_INTS10"
            export LIVEDATA_WINDSPEED="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex windspeed uint16be $LIVEDATA_WINDSPEED_INTS10 $LIVEDATA_WINDSPEED $UNIT_UNICODE_WIND_MPS"  


        elif [ "$ldf" -eq "$LDF_WINDGUSTSPPED" ]; then

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "wingustspeed"
            export LIVEDATA_WINDGUSTSPEED_INTS10="$VALUE_UINT16BE"
            convertWindLivedata "$VALUE_UINT16BE"
            export LIVEDATA_WINDGUSTSPEED="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex windgustspeed uint16be $LIVEDATA_WINDGUSTSPEED_INTS10 $LIVEDATA_WINDGUSTSPEED $UNIT_UNICODE_WIND_MPS"


        elif [ "$ldf" -eq "$LDF_DAYLWINDMAX" ]; then

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "winddailymax"
            export LIVEDATA_WINDDAILYMAX_INTS10="$VALUE_UINT16BE"
            convertWindLivedata "$VALUE_UINT16BE"
            export LIVEDATA_WINDDAILYMAX="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex winddailymax uint16be $LIVEDATA_WINDDAILYMAX_INTS10 $LIVEDATA_WINDDAILYMAX $UNIT_UNICODE_WIND_MPS"


        elif [ "$ldf" -eq "$LDF_LIGHT" ]; then

            readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "light"
            export LIVEDATA_SOLAR_LIGHT_INTS10="$VALUE_UINT32BE"
            convertLightLivedata "$LIVEDATA_SOLAR_LIGHT_INTS10"
            export LIVEDATA_SOLAR_LIGHT="$VALUE_SCALE10_FLOAT"

            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex light uint32be $LIVEDATA_SOLAR_LIGHT_INTS10 lux $LIVEDATA_SOLAR_LIGHT  $LIVEDATAUNIT_SOLAR_LIGHT"


        elif [ "$ldf" -eq "$LDF_UV" ]; then

            # value is 0.0 for WH80?
            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "uv"
            export LIVEDATA_SOLAR_UV_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_SOLAR_UV_INTS10" # assume its scale 10?
            export LIVEDATA_SOLAR_UV="$VALUE_SCALE10_FLOAT"
            # uv gain can be used to calibrate value
            #is it µW/m^2? is it scale 10 ? scale 10 gives best resolution
            #scale 10: 0.1 µW/m2 = 0.1/(100*cm*100cm) = 0.1/(10000cm^2) = 1000 µW/cm^2 = 1mW/cm^2, resolution: 1mW/cm2
            #not scale 10: 1 µW/m2 = 10mW/cm2, resolution: 10mW/cm2
            #conversion info: https://www.linshangtech.com/tech/tech508.html
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex uv uint16be $LIVEDATA_SOLAR_UV_INTS10 $LIVEDATA_SOLAR_UV $LIVEDATAUNIT_SOLAR_LIGHT_UV = $LIVEDATA_SOLAR_UV_INTS10 mW/㎠"

        elif [ "$ldf" -eq "$LDF_UVI" ]; then

            readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "uvi"
            export LIVEDATA_SOLAR_UVI="$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex uvi uint8 $LIVEDATA_SOLAR_UVI"


        elif [ "$ldf" -eq "$LDF_SOILMOISTURE1" ] || [ "$ldf" -eq "$LDF_SOILMOISTURE2" ] ||
             [ "$ldf" -eq "$LDF_SOILMOISTURE3" ] || [ "$ldf" -eq "$LDF_SOILMOISTURE4" ] ||
             [ "$ldf" -eq "$LDF_SOILMOISTURE5" ] || [ "$ldf" -eq "$LDF_SOILMOISTURE6" ] ||
             [ "$ldf" -eq "$LDF_SOILMOISTURE7" ] || [ "$ldf" -eq "$LDF_SOILMOISTURE8" ]; then #is 16 channels supported?

            channel=$((((ldf - LDF_SOILMOISTURE1) / 2) + 1))
            readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "soilmoisture$channel"
            eval "export LIVEDATA_SOILMOISTURE$channel=$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex soilmoisture$channel uint8 $VALUE_UINT8 $LIVEDATAUNIT_HUMIDITY"

 
        elif [ "$ldf" -eq "$LDF_SOILTEMP1" ] || [ "$ldf" -eq "$LDF_SOILTEMP2" ] ||
             [ "$ldf" -eq "$LDF_SOILTEMP3" ] || [ "$ldf" -eq "$LDF_SOILTEMP4" ] ||
             [ "$ldf" -eq "$LDF_SOILTEMP5" ] || [ "$ldf" -eq "$LDF_SOILTEMP6" ] ||
             [ "$ldf" -eq "$LDF_SOILTEMP7" ] || [ "$ldf" -eq "$LDF_SOILTEMP8" ]; then

            readInt16
            convertTemperatureLivedata "$VALUE_INT16BE"
            channel=$((((ldf - LDF_SOILTEMP1) / 2) + 1))
            eval "export LIVEDATA_SOILTEMP${channel}_INTS10=$VALUE_INT16BE"
            eval "export LIVEDATA_SOILTEMP$channel=$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex soiltemperature$channel int16be $VALUE_INT16BE $VALUE_SCALE10_FLOAT $UNIT_UNICODE_CELCIUS"


        elif [ "$ldf" -ge "$LDF_TEMP1" ] && [ "$ldf" -le "$LDF_TEMP8" ]; then
            channel=$((ldf - LDF_TEMP1 + 1))

            readInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "temp $channel"
            convertTemperatureLivedata "$VALUE_INT16BE"

            eval "export LIVEDATA_WH31TEMP${channel}_INTS10=$VALUE_INT16BE"
            eval "export LIVEDATA_WH31TEMP$channel=$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex temperature$channel int16be $VALUE_INT16BE $VALUE_SCALE10_FLOAT $UNIT_UNICODE_CELCIUS"


        elif [ "$ldf" -ge "$LDF_HUMI1" ] && [ "$ldf" -le "$LDF_HUMI8" ]; then

            channel=$((ldf - LDF_HUMI1 + 1))
            readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "humidity$channel"

            eval "export LIVEDATA_WH31HUMI$channel=$VALUE_UINT8"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex humidity$channel uint8 $VALUE_UINT8 $LIVEDATAUNIT_HUMIDITY"


        elif [ "$ldf" -eq "$LDF_RAINMONTH" ]; then

            readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "rainmonth"
            export LIVEDATA_RAINMONTH_INTS10="$VALUE_UINT32BE"
            convertScale10ToFloat "$LIVEDATA_RAINMONTH_INTS10"
            export LIVEDATA_RAINMONTH="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex rainmonth uint32be $VALUE_UINT32BE $LIVEDATA_RAINMONTH $LIVEDATAUNIT_RAIN" 

        elif [ "$ldf" -eq "$LDF_RAINYEAR" ]; then

            readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "rainyear"
            export LIVEDATA_RAINYEAR_INTS10="$VALUE_UINT32BE"
            convertScale10ToFloat "$LIVEDATA_RAINYEAR_INTS10"
            export LIVEDATA_RAINYEAR="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex rainyear uint32be $VALUE_UINT32BE $LIVEDATA_RAINYEAR $LIVEDATAUNIT_RAIN"

        elif [ "$ldf" -eq "$LDF_RAINWEEK" ]; then

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "rainweek"
            export LIVEDATA_RAINWEEK_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_RAINWEEK_INTS10"
            export LIVEDATA_RAINWEEK="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex rainweek uint16be $VALUE_UINT16BE $LIVEDATA_RAINWEEK $LIVEDATAUNIT_RAIN"


        elif [ "$ldf" -eq "$LDF_RAINDAY" ]; then

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "rainday"
            export LIVEDATA_RAINDAY_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_RAINDAY_INTS10"
            export LIVEDATA_RAINDAY="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex rainday uint16be $VALUE_UINT16BE $LIVEDATA_RAINDAY $LIVEDATAUNIT_RAIN"


        elif [ "$ldf" -eq "$LDF_RAINEVENT" ]; then

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "rainevent"
            export LIVEDATA_RAINEVENT_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_RAINEVENT_INTS10"
            export LIVEDATA_RAINEVENT="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex rainevent uint16be $VALUE_UINT16BE $LIVEDATA_RAINEVENT $LIVEDATAUNIT_RAIN"


        elif [ "$ldf" -eq "$LDF_RAINRATE" ]; then

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "rainrate"
            export LIVEDATA_RAINRATE_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_RAINRATE_INTS10"
            export LIVEDATA_RAINRATE="$VALUE_SCALE10_FLOAT"
            [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] && echo >&2 "$DEBUG_FUNC $ldf_hex rainrate uint16be $VALUE_UINT16BE $LIVEDATA_RAINRATE $LIVEDATAUNIT_RAINRATE"


        elif [ "$ldf" -ge "$LDF_LEAK_CH1" ] && [ "$ldf" -le "$LDF_LEAK_CH4" ]; then
            channel=$((ldf - LDF_LEAK_CH1 + 1))
            readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "leak$channel"
            eval "export LIVEDATA_LEAK$channel=$VALUE_UINT8"

        elif [ "$ldf" -eq "$LDF_PM25_CH1" ]; then

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "PM25 1"
            export LIVEDATA_PM251_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_PM251_INTS10"
            export LIVEDATA_PM251="$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -ge "$LDF_PM25_CH2" ] && [ "$ldf" -le "$LDF_PM25_CH4" ]; then

            channel=$((ldf - LDF_PM25_CH1 + 1))
            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "PM25 $channel"
            eval "export LIVEDATA_PM25${channel}_INTS10=$VALUE_UINT16BE"
            eval "convertScale10ToFloat \$LIVEDATA_PM25${channel}_INTS10"
            eval "export LIVEDATA_PM25$channel=$VALUE_SCALE10_FLOAT"

        elif [ "$ldf" -ge "$LDF_PM25_24HAVG1" ] && [ "$ldf" -le "$LDF_PM25_24HAVG4" ]; then

            channel=$((ldf - LDF_PM25_24HAVG1 + 1))
            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "PM25 24h avg $channel"
            eval "export LIVEDATA_PM25${channel}_24HAVG_INTS10=$VALUE_UINT16BE"
            eval "convertScale10ToFloat \$LIVEDATA_PM25${channel}_24HAVG_INTS10"
            eval "export LIVEDATA_PM25${channel}_24HAVG=$VALUE_SCALE10_FLOAT"

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

            readInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "CO2 tempf"
            export LIVEDATA_WH45CO2_TEMPF_INTS10="$VALUE_INT16BE"
            convertScale10ToFloat "$LIVEDATA_WH45CO2_TEMPF_INTS10"
            export LIVEDATA_WH45CO2_TEMPF="$VALUE_SCALE10_FLOAT"

            readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "CO2 humidity"
            export LIVEDATA_WH45CO2_HUMI="$VALUE_UINT8"

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "CO2 PM10"
            export LIVEDATA_WH45CO2_PM10_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_WH45CO2_PM10_INTS10"
            export LIVEDATA_WH45CO2_PM10="$VALUE_SCALE10_FLOAT"

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "CO2 PM10 24h avg"
            export LIVEDATA_WH45CO2_PM10_24HAVG_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_WH45CO2_PM10_24HAVG_INTS10"
            export LIVEDATA_WH45CO2_PM10_24HAVG="$VALUE_SCALE10_FLOAT"

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "CO2 PM25"
            export LIVEDATA_WH45CO2_PM25_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_WH45CO2_PM25_INTS10"
            export LIVEDATA_WH45CO2_PM25="$VALUE_SCALE10_FLOAT"

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "CO2 PM25 24h avg"
            export LIVEDATA_WH45CO2_PM25_24HAVG_INTS10="$VALUE_UINT16BE"
            convertScale10ToFloat "$LIVEDATA_WH45CO2_PM25_24HAVG_INTS10"
            export LIVEDATA_WH45CO2_PM25_24HAVG="$VALUE_SCALE10_FLOAT"

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "CO2"
            export LIVEDATA_WH45CO2_CO2="$VALUE_UINT16BE"

            readUInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "CO2 24g avg"
            export LIVEDATA_WH45CO2_CO2_24HAVG="$VALUE_UINT16BE"

            readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "CO2 battery"
            export LIVEDATA_WH45CO2_BATTERY="$VALUE_UINT8"

        elif [ "$ldf" -ge "$LDF_TF_USR1" ] && [ "$ldf" -le "$LDF_TF_USR8" ]; then
            channel=$((ldf - LDF_TF_USR1 + 1))
            readInt16BE "$VALUE_PARSEPACKET_BUFFERNAME" "tf_usr$channel"
            convertTemperatureLivedata "$VALUE_INT16BE"

            eval "export LIVEDATA_TF_USR${channel}_INT16=$VALUE_INT16"
            eval "export LIVEDATA_TF_USR$channel=$VALUE_SCALE10_FLOAT"

            readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "tf_usr$channel battery"
            eval "export LIVEDATA_TF_USR${channel}_BATTERY_INTS10=$VALUE_UINT8"
            eval "convertScale10ToFloat \$LIVEDATA_TF_USR${channel}_BATTERY_INTS10"
            eval "export LIVEDATA_TF_USR${channel}_BATTERY=$VALUE_SCALE10_FLOAT"
            getBatteryVoltageScale10State "$VALUE_UINT8"
            eval "export LIVEDATA_TF_USR${channel}_BATTERY_STATE=$VALUE_BATTERY_STATE"
            
        elif [ "$ldf" -ge "$LDF_LIGHTNING" ]; then

            readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "lightning distance"
            export LIVEDATA_LIGHTNING_DISTANCE="$VALUE_UINT8" # 1-40km

        elif [ "$ldf" -ge "$LDF_LIGHTNING_TIME" ]; then

            readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "lightning type"
            export LIVEDATA_LIGHTNING_TIME="$VALUE_UINT32BE"
            getDateUTC "$LIVEDATA_LIGHTNING_TIME"
            export LIVEDATA_LIGHTNING_TIME_UTC="$VALUE_DATE_UTC"


        elif [ "$ldf" -ge "$LDF_LIGHTNING_POWER" ]; then

            readUInt32BE "$VALUE_PARSEPACKET_BUFFERNAME" "lightning power"
            export LIVEDATA_LIGHTNING_POWER="$VALUE_UINT32BE"

        elif [ "$ldf" -ge "$LDF_LEAF_WETNESS_CH1" ] && [ "$ldf" -le "$LDF_LEAF_WETNESS_CH8" ]; then

            channel=$((ldf - LDF_LEAF_WETNESS_CH1 + 1))
            readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "leafwetness$channel"

            eval "export LIVEDATA_LEAFWETNESS${channel}=$VALUE_UINT8"

        else
            echo >&2 "ERROR Unable to parse livedata field $(printf "%x" "$ldf")"
        fi

    done

 #   if [ "$DEBUG_PARSE_LIVEDATA" -eq 1 ]; then
 #       readUInt8 "$VALUE_PARSEPACKET_BUFFERNAME" "checksum"
 #       checksum=$VALUE_UINT8
 #       echo >&2 checksum "$(printf "%02x dec:%02u" "$checksum" "$checksum")"
 #   fi

    [ "$DEBUG_OPTION_TESTSENSOR" -eq 1 ] && injectTestSensorLivedata

    #[ "$DEBUG_PARSE_LIVEDATA" -eq 1 ] &&
    # export -p

    printOrLogLivedata

    unset ldf ldf_hex channel checksum DEBUG_FUNC parselivedata_max_length
    
}

commandHas2BytePacketLengthResponse()
# broadcast, livedata, read_sensor_id_new has 2 byte response packet length
# return 0 = two byte packet length
{
    DEBUG_COMMANDHAS2BYTEPACKETLENGTH=${DEBUG_COMMANDHAS2BYTEPACKETLENGTH:=$DEBUG}

    if [ "$1" -eq "$CMD_BROADCAST" ] || [ "$1" -eq "$CMD_LIVEDATA" ] || [ "$1" -eq "$CMD_READ_SENSOR_ID_NEW" ]; then
          [ "$DEBUG_COMMANDHAS2BYTEPACKETLENGTH" -eq 1 ] && { getCommandName "$1"; echo >&2 "commandHas2BytePacketLengthResponse YES/0 command: $VALUE_COMMAND_NAME dec: $1" ; }
        return 0
    else
         [ "$DEBUG_COMMANDHAS2BYTEPACKETLENGTH" -eq 1 ] && { getCommandName "$1"; echo >&2 "commandHas2BytePacketLengthResponse NO/1 command: $VALUE_COMMAND_NAME dec: $1"; }
        return 1
    fi
}

commandHas2BytePacketLength()
# broadcast, write ssid has two byte packet length
{
    DEBUG_COMMANDHAS2BYTEPACKETLENGTH=${DEBUG_COMMANDHAS2BYTEPACKETLENGTH:=$DEBUG}

    if  [ "$1" -eq "$CMD_BROADCAST" ] || [ "$1" -eq "$CMD_WRITE_SSID" ] 
     then
          [ "$DEBUG_COMMANDHAS2BYTEPACKETLENGTH" -eq 1 ] && { getCommandName "$1"; echo >&2 "commandHas2BytePacketLength         YES/0 command: $VALUE_COMMAND_NAME dec: $1" ; }
        return 0
    else
         [ "$DEBUG_COMMANDHAS2BYTEPACKETLENGTH" -eq 1 ] && { getCommandName "$1"; echo >&2 "commandHas2BytePacketLength         NO/1 command: $VALUE_COMMAND_NAME dec: $1"; }
        return 1
    fi
}

readPacketPreambleCommandLength()
# verify preamble = ff ff, read command and packet length
# $1 buffername
# set PACKET_RX_LENGTH
# set PACKET_RX_CRC
# set VALUE_COMMAND_NAME (getCommandName called) 
# set EXITCODE_PARSEPACKET
{
    EXITCODE_PARSEPACKET=0

    readPacketPreambleCommandLength_buffername=$1
   
    readSlice "$readPacketPreambleCommandLength_buffername" 4 "packet preamble"

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
    if commandHas2BytePacketLengthResponse "$PRX_CMD_UINT8"; then
        readUInt8 "$readPacketPreambleCommandLength_buffername" "command name: $VALUE_COMMAND_NAME dec: $PRX_CMD_UINT8 16-bit packet length msb: $4 lsb"
        PACKET_RX_LENGTH_BYTES=2
        PACKET_RX_LENGTH=$(( ($4 << 8) | VALUE_UINT8))
    else
        PACKET_RX_LENGTH_BYTES=1
        PACKET_RX_LENGTH=$(($4))
    fi

    if [ "$DEBUG_OPTION_STRICTPACKET" -eq 1 ]; then
        eval packetContentPosition="\$${readPacketPreambleCommandLength_buffername}_HEAD" # backup position

        eval realPacketLength="\$${readPacketPreambleCommandLength_buffername}_LENGTH"

        # verify packet length
        #shellcheck disable=SC2154
        if ! [ $(( realPacketLength - 2 )) -eq $PACKET_RX_LENGTH  ]; then # -2 for "255 255" packet header
            #[ "$DEBUG" -eq 1 ] && 
            printf >&2  "Warning: %s dec: %u hex: %x, reported packet length %u not the same as actual packet length %u\n" "$VALUE_COMMAND_NAME" "$PRX_CMD_UINT8" "$PRX_CMD_UINT8" "$PACKET_RX_LENGTH" "$(( realPacketLength - 2 ))"
            EXITCODE_PARSEPACKET=$ERROR_PARSEPACKET_LENGTH
        else
            [ "$DEBUG" -eq 1 ] &&  echo >&2 "RX PACKET LENGTH (byte 3 in packet) $PACKET_RX_LENGTH, actual packet length $(( realPacketLength - 2 )) "
        fi

         #shellcheck disable=SC2154
        packetCRCPosition=$(( realPacketLength - 1 )) # -1 due to 0-index

        readUInt8 "$readPacketPreambleCommandLength_buffername" "verify crc" $packetCRCPosition
        PACKET_RX_CRC=$VALUE_UINT8
        eval getPacketCRC "\"\$$readPacketPreambleCommandLength_buffername\""
        if [ "$PACKET_RX_CRC" -ne "$VALUE_CRC" ]; then
            printf >&2 "Warning: %s, dec: %u hex: %x , inpacket crc %u != %u  (calculated), packet CRC index: %u\n" "$VALUE_COMMAND_NAME" "$PRX_CMD_UINT8"  "$PRX_CMD_UINT8" "$PACKET_RX_CRC" "$VALUE_CRC" "$packetCRCPosition"
            EXITCODE_PARSEPACKET=$ERROR_PARSEPACKET_CRC
        fi

        #shellcheck disable=SC2154
        moveHEAD "$readPacketPreambleCommandLength_buffername" "$packetContentPosition" #restore position
    fi

    unset realPacketLength packetCRCPosition readPacketPreambleCommandLength_buffername packetContentPosition

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
     DEBUG_PARSEPACKET=${DEBUG_PARSEPACKET:=$DEBUG}
     VALUE_PARSEPACKET_BUFFERNAME="OD_BUFFER"

     if [ -z "$1" ]; then
         [ "$DEBUG_PARSEPACKET" -eq 1 ] && echo >&2 Warning: parsePacket: Empty buffer/response received
        EXITCODE_PARSEPACKET="$ERROR_OD_BUFFER_EMPTY"
        return "$EXITCODE_PARSEPACKET"
    fi

    newBuffer "$VALUE_PARSEPACKET_BUFFERNAME" "$1"

   if ! readPacketPreambleCommandLength "$VALUE_PARSEPACKET_BUFFERNAME"; then
      echo >&2 "Warning: Packet preamble failure, errorcode: $EXITCODE_PARSEPACKET"

      #return "$EXITCODE_PARSEPACKET"
   fi

    [ "$DEBUG_PARSEPACKET" -eq 1 ] && echo >&2 "parsePacket: Received command $VALUE_COMMAND_NAME dec cmd $PRX_CMD_UINT8"

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
        echo >&2 "Warning: Parsing of command $VALUE_COMMAND_NAME not implemented"
        EXITCODE_PARSEPACKET=$ERROR_PARSEPACKET_UNSUPPORTED_COMMAND
    fi

    destroyBuffer "$VALUE_PARSEPACKET_BUFFERNAME"

    unset VALUE_PARSEPACKET_BUFFERNAME

    return "$EXITCODE_PARSEPACKET"
}

restoreBackup()
# restore configuration from backup file (containing bundle of read commands)
# $1 filename
# $2 host
# $3 filter
{
    EXITCODE_RESTOREBACKUP=0

    restoreFilename="$1"
    restoreHost="$2"
    restoreFilter="$3"

    if ! RESTORE_BUFFER="$(od -A n -t u1 -w"$MAX_16BIT_UINT" "$restoreFilename")"; then
          EXITCODE_RESTOREBACKUP=$?
         echo >&2 Error: unable to restore from filename "$restoreFilename"
         return "$EXITCODE_RESTOREBACKUP"
    fi

    IFS=' '
    #shellcheck disable=SC2086
    set -- $RESTORE_BUFFER

    # $1=255 $2=255 $3=command $4=msb packet length, $5 (optional 2byte packet length)

    while [ $# -gt 4 ]; do
        restoreReadCommand=$(( $3 )) 
        restoreWriteCommand=$(( restoreReadCommand + 1 )) # writecmd.=readcmd.+ 1
       
        getCommandName "$restoreReadCommand"
        echo >&2 "restoring $VALUE_COMMAND_NAME"
        #>&2 printBuffer "$*"

        if ! commandHas2BytePacketLengthResponse "$restoreReadCommand"; then
            restorePacketLength=$(( $4 ))
        else
            restorePacketLength=$(( ( $4 << 8 ) | $5 ))
        fi

        restoreCRCpos=$(( 2 + restorePacketLength ))
        eval "restoreReadCRC=\${$restoreCRCpos}"
        #shellcheck disable=SC2154 disable=SC2034
        restoreWriteCRC=$(( ( restoreReadCRC + 1) & 255 )) # just add 1 to checksum

        restorePos=4
        restoreBuffer="\$1 \$2 \$restoreWriteCommand" # build string with positional parameters containing packet
        backupBuffer="\$1 \$2 \$3"
        while [ $restorePos -le $(( restoreCRCpos - 1 )) ]; do
            restoreBuffer="$restoreBuffer \${$restorePos}"
            backupBuffer="$backupBuffer \${$restorePos}"
            restorePos=$(( restorePos + 1))
        done
        #set -x
        eval "restoreBuffer=\"$restoreBuffer \$restoreWriteCRC\"" #set the packet with new CRC
        eval "backupBuffer=\"$backupBuffer \$restoreReadCRC\""
        #set +x

        #binary backup of sensor ids
        if [ "$restoreReadCommand" -eq "$CMD_READ_SENSOR_ID" ] || [ "$restoreReadCommand" -eq "$CMD_READ_SENSOR_ID_NEW" ]; then
              IFS=' '
              local_n=1
              local_packetLength=0
              local_crc=0
              if [ "$restoreReadCommand" -eq "$CMD_READ_SENSOR_ID" ]; then
                local_startpos=5 # start at byte 5, counting from 1,2,...
              elif [ "$restoreReadCommand" -eq "$CMD_READ_SENSOR_ID_NEW" ]; then
                local_startpos=6 # start at byte 6 ( 2 byte packet length in read packet)
              fi
              unset sensorBuffer
              for byte in $backupBuffer; do
                if [ $local_n -ge $local_startpos ] && [ $(( (local_n - local_startpos) % 7)) -lt 5 ]; then # copy only sensortype (1-byte) and sensorid (4-byte) = 5 bytes, skip battery signal = 2bytes
                    sensorBuffer="$sensorBuffer $byte"
                    local_crc=$(( (local_crc + byte ) & 255 ))
                    local_packetLength=$(( local_packetLength + 1 ))
                fi
               # echo $local_n $(( (local_n - local_startpos) % 7 ))
                local_n=$(( local_n + 1 ))
              done
              local_packetLength=$(( local_packetLength + 3 )) # cmd+packetlength+crc = 3 bytes
              local_crc=$(( (local_crc + CMD_WRITE_SENSOR_ID + local_packetLength) & 255 ))
              sensorBuffer="255 255 $CMD_WRITE_SENSOR_ID $local_packetLength $sensorBuffer $local_crc"
              restoreBuffer="$sensorBuffer"
        fi

        convertBufferFromDecToOctalEscape "$restoreBuffer" # \0377 \0377 \0nnn
        set -x
        printf "%b" "$VALUE_OCTAL_BUFFER_ESCAPE" | tee restore.hex | nc -4 -N -w 1 "$restoreHost" 45000 | od -A n -t x1 -w131000
        set +x

        case "$restoreFilter" in
          cat) parsePacket "$backupBuffer" # view backup content
                ;;
        esac

        shift $restoreCRCpos # remove restored buffer at front
    done

   # echo >&2 restoreWriteCommand: $restoreWriteCommand restorePacketLength: $restorePacketLength restoreCRCpos: $restoreCRCpos restoreCRC: $restoreCRC

    unset byte local_startpos local_n local_crc local_packetLength restoreBuffer backupBuffer restoreFilename restoreHost restoreReadCommand restoreWriteCommand restorePacketLength restorePos restoreBuffer restoreCRCpos restoreFilter sensorBuffer
    
    return $EXITCODE_RESTOREBACKUP
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
    if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
        eval VALUE_SIGNAL_UNICODE="\$UNICODE_SIGNAL_LEVEL$1"
    fi
}

setLivedataSignal()
# export LIVEDATA_*_SIGNAL LIVEDATA_*_SIGNAL_STATE
#$1 sensorname WH?? $2 signal value
{
    getSignalUnicode "$2"
    export LIVEDATASENSOR_"$1"_SIGNAL="$2" LIVEDATASENSOR_"$1"_SIGNAL_STATE="$VALUE_SIGNAL_UNICODE"
}

exportLivedataSignal()
# maps integer sensortype to variable for each sensortype 
# $1 sensortype $2 signal
# set VALUE_SIGNAL_UNICODE
{
    if [ "$1" -eq "$SENSORTYPE_WH65" ]; then # 0
        setLivedataSignal "WH65" "$2"
    elif [ "$1" -eq "$SENSORTYPE_WH68" ]; then # 1
        setLivedataSignal "WH68" "$2"
    elif [ "$1" -eq "$SENSORTYPE_WH80" ]; then # 2
        setLivedataSignal "WH80" "$2"
    elif [ "$1" -eq "$SENSORTYPE_WH40" ]; then # 3
       setLivedataSignal "WH40RAINFALL" "$2"
    elif [ "$1" -eq "$SENSORTYPE_WH32" ]; then # 5
        setLivedataSignal "WH32TEMP" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH31TEMP" ] && [ "$1" -lt $(( SENSORTYPE_WH31TEMP + SENSORTYPE_WH31TEMP_MAXCH )) ]; then # 6-13
        setLivedataSignal "WH31TEMP$(( $1 - SENSORTYPE_WH31TEMP + 1))" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH51SOILMOISTURE" ] && [ "$1" -lt $(( SENSORTYPE_WH51SOILMOISTURE + SENSORTYPE_WH51SOILMOISTURE_MAXCH )) ]; then # 14-21
       setLivedataSignal "WH51SOILMOISTURE$(( $1 - SENSORTYPE_WH51SOILMOISTURE + 1))" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH43PM25" ] && [ "$1" -lt $(( SENSORTYPE_WH43PM25 + SENSORTYPE_WH43PM25_MAXCH )) ]; then # 22-25
       setLivedataSignal "WH43PM25$(( $1 - SENSORTYPE_WH43PM25 + 1))" "$2"
    elif [ "$1" -eq "$SENSORTYPE_WH57LIGHTNING" ]; then # 26
       setLivedataSignal "WH57LIGHTNING" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH55LEAK" ] && [ "$1" -lt $(( SENSORTYPE_WH55LEAK + SENSORTYPE_WH55LEAK_MAXCH )) ]; then # 26-30
       setLivedataSignal "WH55LEAK$(( $1 - SENSORTYPE_WH55LEAK + 1))" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH34SOILTEMP" ] && [ "$1" -lt $(( SENSORTYPE_WH34SOILTEMP + SENSORTYPE_WH34SOILTEMP_MAXCH )) ]; then # 31 - 38
       setLivedataSignal "WH34SOILTEMP$(( $1 - SENSORTYPE_WH34SOILTEMP + 1))" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH45CO2" ]; then # 39
       setLivedataSignal "WH45CO2" "$2"
    elif [ "$1" -ge "$SENSORTYPE_WH35LEAFWETNESS" ] && [ "$1" -lt $(( SENSORTYPE_WH35LEAFWETNESS + SENSORTYPE_WH35LEAFWETNESS_MAXCH )) ]; then # 40-47
       setLivedataSignal "WH35LEAFWETNESS$(( $1 - SENSORTYPE_WH35LEAFWETNESS + 1))" "$2"
    fi
      
}

exportLivedataBattery()
# $1 sensortype 0-48
# $2 sensor battery value
# set VALUE_BATTERY_STATE
{
   
    #specification FOS_ENG-022-A, page 28
    unset VALUE_BATTERY_STATE

     case "$1" in
        0) setBatteryLowNormal "WH65" "$2" # WH65
            ;;
        1) setBatteryVoltageLevel002 "WH68" "$2"
            ;;
        2) setBatteryVoltageLevel002 "WH80" "$2"
            ;;
        3) setBatteryLowNormal "WH40RAINFALL" "$2"
            ;;
        5) setBatteryLowNormal "WH32TEMP" "$2"
            ;;
        6|7|8|9|10|11|12|13)
           channel=$(($1 - 5))
           setBatteryLowNormal "WH31TEMP$channel" "$2"
           ;;
        14|15|16|17|18|19|20|21)
           channel=$(( $1 - 13))
           setBatteryVoltageLevel "WH51SOILMOISTURE$channel" "$2"
          ;;
        22|23|24|25)
          channel=$(( $1 - 21 ))
          setBatteryLevel "WH43PM25$channel" "$2"
          ;;
        26)
          setBatteryLevel "WH57LIGHTNING" "$2"
          ;;
        27|28|29|30)
          channel=$(( $1 - 26 ))
          setBatteryLevel "WH55LEAK$channel" "$2"
          ;;
        31|32|33|34|35|36|37|38)
           channel=$(( $1 - 30))
           setBatteryVoltageLevel "WH34SOILTEMP$channel" "$2"
           ;;
        39)
           setBatteryLevel "WH45CO2" "$2"
           #battery info also available from sensor read livedata
          ;;
        40|41|42|43|44|45|46|47)
           channel=$(( $1 - 39))
           setBatteryVoltageLevel "WH35LEAFWETNESS$channel" "$2"
           ;;
    esac

    unset channel
}

setBatteryLowNormal()
{
     getBatteryLowOrNormal "$2" 
    eval "export LIVEDATASENSOR_${1}_BATTERY=$2"
    eval "export LIVEDATASENSOR_${1}_BATTERY_STATE='$VALUE_BATTERY_STATE'"
}

setBatteryVoltageLevel()
# $1 sensorname
# $2 voltage x 10
{
    getBatteryVoltageScale10State "$2"
    eval "export LIVEDATASENSOR_${1}_BATTERY_INTS10=$2"
    eval "export LIVEDATASENSOR_${1}_BATTERY=$VALUE_BATTERY_VOLTAGE"
    eval "export LIVEDATASENSOR_${1}_BATTERY_STATE='$VALUE_BATTERY_STATE'"
}

setBatteryLevel()
{
    getBatteryLevelState "$2"
    eval "export LIVEDATASENSOR_${1}_BATTERY=$2"
    eval "export LIVEDATASENSOR_${1}_BATTERY_STATE='$VALUE_BATTERY_STATE'"
}

setBatteryVoltageLevel002()
# set battery voltagelevel, value is multiplied by 0.2 (divide by 5), to get scalex10 value, two AA batteries inside WH80 -> divide value by 2 -> divide by 10
# $1 sensor name WH80/WH68
# $2 value - this is a x100 scale value
{
    unset VALUE_BATTERY_STATE

    local_voltage_s100=$(( $2 * 2 )) # scale x 100 - for 2 AA batteries

    if [ "$2" -le $(( BATTERY_VOLTAGE_LOW * 10 )) ]; then # [ -le 120]
       appendLowBatteryState
    else
       appendBatteryState
    fi

    local_voltage=${local_voltage_s100%??}$SHELL_DECIMAL_POINT${local_voltage_s100#?} # assumes 3 digits always for local_voltage_s100
    eval "export LIVEDATASENSOR_${1}_BATTERY=$local_voltage" 
    VALUE_BATTERY_STATE=$VALUE_BATTERY_STATE"${local_voltage}V"
    eval "export LIVEDATASENSOR_${1}_BATTERY_STATE='$VALUE_BATTERY_STATE'"

    unset local_voltage local_voltage_s100
}

appendBatteryState()
# appends unicode for battery or +
# set VALUE_BATTERY_STATE
{
   if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
        VALUE_BATTERY_STATE=$VALUE_BATTERY_STATE$UNICODE_BATTERY
   else
        VALUE_BATTERY_STATE=$VALUE_BATTERY_STATE"+"
   fi 
}

appendLowBatteryState()
# appends unicode for battery low or LOW
# set VALUE_BATTERY_STATE
{
    if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
    #https://emojipedia.org/low-battery/ "Coming to major platforms in late 2021 and throughout 2022".
         VALUE_BATTERY_STATE=$VALUE_BATTERY_STATE$UNICODE_BATTERY_LOW 
    else
        VALUE_BATTERY_STATE=$VALUE_BATTERY_STATE"LOW"
    fi
}

getBatteryVoltageScale10State()
# appends voltage level for 1 AA battery to VALUE_BATTERY_STATE
# $1 voltage scaled * 10
# set VALUE_BATTERY_VOLTAGE
# set VALUE_BATTERY_STATE
{
   unset VALUE_BATTERY_STATE

   if [ "$1" -le "$BATTERY_VOLTAGE_LOW" ]; then
      appendLowBatteryState
   else
      appendBatteryState
   fi

   convertScale10ToFloat "$1"

   VALUE_BATTERY_VOLTAGE="$VALUE_SCALE10_FLOAT"
   VALUE_BATTERY_STATE=$VALUE_BATTERY_STATE" ${VALUE_BATTERY_VOLTAGE}V"
}

getBatteryLevelState() { # $1 - battery level 0-6, 6 = dc, <=1 low
    
    unset VALUE_BATTERY_STATE
   
    #set -- 0     #debug  set $1 to 0
    if [ "$1" -eq 6 ]; then
      if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
       #https://emojipedia.org/electric-plug/
        VALUE_BATTERY_STATE=$UNICODE_PLUG
      else
        VALUE_BATTERY_STATE="dc" # for example PM 2.5 indoor
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

       VALUE_BATTERY_STATE=$VALUE_BATTERY_STATE" $1"
    fi

    unset  l
}

getBatteryLowOrNormal() {
    
    unset VALUE_BATTERY_STATE

    if [ "$1" -eq "$BATTERY_NORMAL" ]; then
       appendBatteryState
    elif [ "$1" -eq "$BATTERY_LOW" ]; then
        appendLowBatteryState
    fi
}

getSensorIdCommandForFW()
# get sensor id command based on firmware version
# $1 integer - firmware version 
# set VALUE_SENSOR_COMMAND
{
    unset VALUE_SENSORID_READ_COMMAND
    EXITCODE_GETSENSORIDCOMMAND=0
    DEBUG_GETSENSORIDCOMMAND=${DEBUG_GETSENSORIDCOMMAND:=$DEBUG}

    if [ -z "$1" ]; then # if version not available, fallback to read sensor
       VALUE_SENSORID_READ_COMMAND="$CMD_READ_SENSOR_ID"
       EXITCODE_GETSENSORIDCOMMAND=0
    elif [ "$1" -ge "$FW_CMD_READ_SENSOR_ID_NEW" ]; then # Added in fw v 1.5.4 
            VALUE_SENSORID_READ_COMMAND="$CMD_READ_SENSOR_ID_NEW"  #support soiltemp, co2, leafwetness
    elif [ "$1" -ge "$FW_CMD_READ_SENSOR_ID" ]; then # Added in fw v 1.4.6
            VALUE_SENSORID_READ_COMMAND="$CMD_READ_SENSOR_ID"
    else
            echo >&2 "Warning: Firmware $1 does not support command sensor id (dec $CMD_READ_SENSOR_ID)/sensor id new (dec $CMD_READ_SENSOR_ID_NEW)"
            EXITCODE_GETSENSORIDCOMMAND="$ERROR_SENSORID_COMMAND_NOT_SUPPORTED"
        fi
    
    [ "$DEBUG_GETSENSORIDCOMMAND" -eq 1 ] && { getCommandName "$VALUE_SENSORID_READ_COMMAND"; printf >&2 "getSensorIdCommandForFW: firmware %s %d using %s dec: %d hex: %x \n" "$GW_VERSION" "$GW_VERSION_INT" "$VALUE_COMMAND_NAME" "$VALUE_SENSORID_READ_COMMAND" "$VALUE_SENSORID_READ_COMMAND"; }
    
    return "$EXITCODE_GETSENSORIDCOMMAND"
}