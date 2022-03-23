#!/bin/sh

printEcowittInterval()
{
    if [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_NORMAL" ]; then
        if [ "$GW_WS_ECOWITT_INTERVAL" -eq 1 ]; then
        local_min="$WEATHERSERVICEHEADERUNIT_MINUTE"
        elif [ "$GW_WS_ECOWITT_INTERVAL" -gt 1 ]; then
            local_min="$WEATHERSERVICEHEADERUNIT_MINUTES"
        fi

        printf "%s\r\t\t\t\t\t%s %s\n" "$WEATHERSERVICEHEADER_ECOWITT_INTERVAL" "$GW_WS_ECOWITT_INTERVAL" "$local_min"
        
        unset local_min
    elif [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_BACKUP" ]; then
        printf "# ecowitt interval 0-5 minutes, 0=off\n%-32s %s\n" "$WEATHERSERVICENAME_ECOWITT_INTERVAL" "$GW_WS_ECOWITT_INTERVAL"
    fi
}

printWunderground() {
    if [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_NORMAL" ]; then
        printf "%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n" "$WEATHERSERVICEHEADER_WUNDERGROUND_ID" "$GW_WS_WUNDERGROUND_ID" "$WEATHERSERVICEHEADER_WUNDERGROUND_PASSWORD" "$GW_WS_WUNDERGROUND_PASSWORD"
    elif  [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_BACKUP" ]; then
        printf "%-32s %s\n%-32s %s\n" "$WEATHERSERVICENAME_WUNDERGROUND_ID" "$GW_WS_WUNDERGROUND_ID" "$WEATHERSERVICENAME_WUNDERGROUND_PASSWORD" "$GW_WS_WUNDERGROUND_PASSWORD"
    fi
}

printWeathercloud() {
    if [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_NORMAL" ]; then
        printf "%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n" "$WEATHERSERVICEHEADER_WEATHERCLOUD_ID" "$GW_WS_WC_ID" "$WEATHERSERVICEHEADER_WEATHERCLOUD_PASSWORD" "$GW_WS_WC_PASSWORD"
    elif  [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_BACKUP" ]; then
        printf "%-32s %s\n%-32s %s\n" "$WEATHERSERVICENAME_WEATHERCLOUD_ID" "$GW_WS_WC_ID" "$WEATHERSERVICENAME_WEATHERCLOUD_PASSWORD" "$GW_WS_WC_PASSWORD"
    fi

}

printWow() {
    if [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_NORMAL" ]; then
        printf "%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n" "$WEATHERSERVICEHEADER_WOW_ID" "$GW_WS_WOW_ID" "$WEATHERSERVICEHEADER_WOW_PASSWORD" "$GW_WS_WOW_PASSWORD"
    elif  [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_BACKUP" ]; then
        printf "%-32s %s\n%-32s %s\n" "$WEATHERSERVICENAME_WOW_ID" "$GW_WS_WOW_ID" "$WEATHERSERVICENAME_WOW_PASSWORD" "$GW_WS_WOW_PASSWORD"
    fi
}

printCustomized() {
    if [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_NORMAL" ]; then
        printf "%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s %s\n%s\r\t\t\t\t\t%s %s\n%s\r\t\t\t\t\t%s %s\n%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n"\
                    "$WEATHERSERVICEHEADER_CUSTOMIZED_ID" "$GW_WS_CUSTOMIZED_ID" "$WEATHERSERVICEHEADER_CUSTOMIZED_PASSWORD" "$GW_WS_CUSTOMIZED_PASSWORD"\
                    "$WEATHERSERVICEHEADER_CUSTOMIZED_SERVER" "$GW_WS_CUSTOMIZED_SERVER" "$WEATHERSERVICEHEADER_CUSTOMIZED_PORT" "$GW_WS_CUSTOMIZED_PORT"\
                    "$WEATHERSERVICEHEADER_CUSTOMIZED_INTERVAL" "$GW_WS_CUSTOMIZED_INTERVAL" "$WEATHERSERVICEHEADERUNIT_SECONDS" "$WEATHERSERVICEHEADER_CUSTOMIZED_HTTP" "$GW_WS_CUSTOMIZED_HTTP" "$GW_WS_CUSTOMIZED_HTTP_STATE"\
                    "$WEATHERSERVICEHEADER_CUSTOMIZED_ENABLED" "$GW_WS_CUSTOMIZED_ENABLED" "$GW_WS_CUSTOMIZED_ENABLED_STATE"\
                    "$WEATHERSERVICEHEADER_CUSTOMIZED_PATH_ECOWITT" "$GW_WS_CUSTOMIZED_PATH_ECOWITT" "$WEATHERSERVICEHEADER_CUSTOMIZED_PATH_WUNDERGROUND" "$GW_WS_CUSTOMIZED_PATH_WU"
    elif [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_BACKUP" ]; then
         printf "%-32s %s\n%-32s %s\n%-32s %s\n%-32s %s\n# interval in minutes from 16\n%-32s %s\n# http protocol 1=wunderground, 0=ecowitt\n%-32s %s\n# enabled 1=on,0=off\n%-32s %s\n"\
                    "$WEATHERSERVICENAME_CUSTOMIZED_ID" "$GW_WS_CUSTOMIZED_ID"\
                    "$WEATHERSERVICENAME_CUSTOMIZED_PASSWORD" "$GW_WS_CUSTOMIZED_PASSWORD"\
                    "$WEATHERSERVICENAME_CUSTOMIZED_SERVER" "$GW_WS_CUSTOMIZED_SERVER"\
                    "$WEATHERSERVICENAME_CUSTOMIZED_PORT" "$GW_WS_CUSTOMIZED_PORT"\
                    "$WEATHERSERVICENAME_CUSTOMIZED_INTERVAL" "$GW_WS_CUSTOMIZED_INTERVAL"\
                    "$WEATHERSERVICENAME_CUSTOMIZED_HTTP" "$GW_WS_CUSTOMIZED_HTTP"\
                    "$WEATHERSERVICENAME_CUSTOMIZED_ENABLED" "$GW_WS_CUSTOMIZED_ENABLED"
    fi
}

printPath() {
    if [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_NORMAL" ]; then
        echo "$WEATHERSERVICEHEADER_CUSTOMIZED_PATH_ECOWITT      $GW_WS_CUSTOMIZED_PATH_ECOWITT
$WEATHERSERVICEHEADER_CUSTOMIZED_PATH_WUNDERGROUND $GW_WS_CUSTOMIZED_PATH_WU"
    elif [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_BACKUP" ]; then
        printf "%-32s %s\n%-32s %s\n" "$WEATHERSERVICENAME_CUSTOMIZED_PATH_ECOWITT" "$GW_WS_CUSTOMIZED_PATH_ECOWITT" "$WEATHERSERVICENAME_CUSTOMIZED_PATH_WUNDERGROUND" "$GW_WS_CUSTOMIZED_PATH_WU"
    fi
}

printWeatherServices()
# $1 - host
 {
    sendPacket "$CMD_READ_ECOWITT_INTERVAL" "$1"
    printEcowittInterval

    sendPacket "$CMD_READ_WUNDERGROUND" "$1"
    printWunderground
    
    sendPacket "$CMD_READ_WOW" "$1"
    printWow
    
    sendPacket "$CMD_READ_WEATHERCLOUD" "$1"
    printWeathercloud
    
    sendPacket "$CMD_READ_CUSTOMIZED" "$1"
    printCustomized
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
    else
        style_sensor=$STYLE_SENSOR_CONNECTED
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

printSensorHeader()
{
    resetAppendBuffer

    printSensorHeaderState=0

    if [ -z "$SENSORVIEW_HIDE_HEADER" ];  then 
       printSensorHeaderState=1
    elif [ "$SENSORVIEW_HIDE_HEADER" -eq 0 ]; then
       printSensorHeaderState=1
    fi

    if [ $printSensorHeaderState -eq 1 ]; then
                      #1:Sensortype 2:sid 3:battery 4:signal 5:type 6:name 7:state 8:battery 9:signal
        appendBuffer "%6s %9s %3s %1s %-4s %-17s %-12s\t%s\t%s\n%s\n" "$SENSORID_HEADER ───────────────────────────────────────────────────────────────────────────────"
    fi
}

printSensorMatch()
{
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
}

printSensorBackup()
{
    printf "%b" "$SENSORBACKUP"
}




