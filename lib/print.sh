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
        printf "# ecowitt interval 0-5 minutes, 0=off\n%-32s %s\n" "$BACKUPNAME_ECOWITT_INTERVAL" "$GW_WS_ECOWITT_INTERVAL"
    fi
}

printWundergroundId()
{
    printf "%s\r\t\t\t\t\t%s\n" "$WEATHERSERVICEHEADER_WUNDERGROUND_ID" "$GW_WS_WUNDERGROUND_ID"
}

printWundergroundPassword()
{
    printf "%s\r\t\t\t\t\t%s\n"  "$WEATHERSERVICEHEADER_WUNDERGROUND_PASSWORD" "$GW_WS_WUNDERGROUND_PASSWORD"

}

printWunderground() {
    if [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_NORMAL" ]; then
        printWundergroundId
        printWundergroundPassword
    elif  [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_BACKUP" ]; then
        printf "%-32s %s\n%-32s %s\n" "$BACKUPNAME_WUNDERGROUND_ID" "$GW_WS_WUNDERGROUND_ID" "$BACKUPNAME_WUNDERGROUND_PASSWORD" "$GW_WS_WUNDERGROUND_PASSWORD"
    fi
}

printWeathercloudId()
{
    printf "%s\r\t\t\t\t\t%s\n"  "$WEATHERSERVICEHEADER_WEATHERCLOUD_ID" "$GW_WS_WC_ID"
}

printWeathercloudPassword()
{
    printf "%s\r\t\t\t\t\t%s\n" "$WEATHERSERVICEHEADER_WEATHERCLOUD_PASSWORD" "$GW_WS_WC_PASSWORD"
}

printWeathercloud() {
    if [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_NORMAL" ]; then
       printWeathercloudId
       printWeathercloudPassword
    elif  [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_BACKUP" ]; then
        printf "%-32s %s\n%-32s %s\n" "$BACKUPNAME_WEATHERCLOUD_ID" "$GW_WS_WC_ID" "$BACKUPNAME_WEATHERCLOUD_PASSWORD" "$GW_WS_WC_PASSWORD"
    fi

}

printWowId()
{
    printf "%s\r\t\t\t\t\t%s\n" "$WEATHERSERVICEHEADER_WOW_ID" "$GW_WS_WOW_ID" 
}

printWowPassword()
{
     printf "%s\r\t\t\t\t\t%s\n" "$WEATHERSERVICEHEADER_WOW_PASSWORD" "$GW_WS_WOW_PASSWORD"
}


printWow() {
    if [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_NORMAL" ]; then
        printWowId
        printWowPassword
    elif  [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_BACKUP" ]; then
        printf "%-32s %s\n%-32s %s\n" "$BACKUPNAME_WOW_ID" "$GW_WS_WOW_ID" "$BACKUPNAME_WOW_PASSWORD" "$GW_WS_WOW_PASSWORD"
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
                    "$BACKUPNAME_CUSTOMIZED_ID" "$GW_WS_CUSTOMIZED_ID"\
                    "$BACKUPNAME_CUSTOMIZED_PASSWORD" "$GW_WS_CUSTOMIZED_PASSWORD"\
                    "$BACKUPNAME_CUSTOMIZED_SERVER" "$GW_WS_CUSTOMIZED_SERVER"\
                    "$BACKUPNAME_CUSTOMIZED_PORT" "$GW_WS_CUSTOMIZED_PORT"\
                    "$BACKUPNAME_CUSTOMIZED_INTERVAL" "$GW_WS_CUSTOMIZED_INTERVAL"\
                    "$BACKUPNAME_CUSTOMIZED_HTTP" "$GW_WS_CUSTOMIZED_HTTP"\
                    "$BACKUPNAME_CUSTOMIZED_ENABLED" "$GW_WS_CUSTOMIZED_ENABLED"
    fi
}

printPath() {
    if [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_NORMAL" ]; then
        echo "$WEATHERSERVICEHEADER_CUSTOMIZED_PATH_ECOWITT      $GW_WS_CUSTOMIZED_PATH_ECOWITT
$WEATHERSERVICEHEADER_CUSTOMIZED_PATH_WUNDERGROUND $GW_WS_CUSTOMIZED_PATH_WU"
    elif [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_BACKUP" ]; then
        printf "%-32s %s\n%-32s %s\n" "$BACKUPNAME_CUSTOMIZED_PATH_ECOWITT" "$GW_WS_CUSTOMIZED_PATH_ECOWITT" "$BACKUPNAME_CUSTOMIZED_PATH_WUNDERGROUND" "$GW_WS_CUSTOMIZED_PATH_WU"
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

printSensorLine()
#$1 backupname, $2 sensortype, $3 sensor id, $4 battery, $5 signal  $6 sensorid state, $7 battery state, $8 signal state unicode, 
#observation: leak sensor signal -> starts at level 1 after search state, then increases +1 each time a new rf message is received
{
    unset VALUE_BATTERY_STATE style_sensor style_sensor_off

   # TEST data 
    #if [ "$1" -eq 40 ]; then
    #   set -- "39" "$(( 0xfff ))" 4 4  # co2
    #  set -- "40" "$(( 0xfff ))" 14 4 # leaf wetness
    #fi

    #if [ "$3" -eq "$SENSORID_DISABLE" ]; then 
    #    style_sensor=$STYLE_SENSOR_DISABLE
    #elif [ "$3" -eq "$SENSORID_SEARCH" ]; then
    #    style_sensor=$STYLE_SENSOR_SEARCH
    #elif [ "$5" -eq 0 ]; then 
    #    style_sensor=$STYLE_SENSOR_DISCONNECTED
    #else
    #    style_sensor=$STYLE_SENSOR_CONNECTED
    #fi

    #if [ -n "$style_sensor" ]; then
    #   style_sensor_off=$STYLE_RESET # insert end escape sequence only if sgi is used
    #fi

     # 1 battery unicode is field size 4 in printf format string. TEST printf  "🔋 1.3 V" | od -A n -t x1 | wc -w -> 10
     # use \r\t\t\t workaround for unicode alignment
  
    appendBuffer "%-20s %2u %8x %3u %1u $style_sensor%s$style_sensor_off\t%s\t%s\n"\
 "'$1' '$2' '$3' '$4' '$5' '$6' '$7' '$8'"
    
    unset style_sensor_off style_sensor
}

printSensors()
# print parsed sensors in SENSOR_*
# test in terminal: watch -n 1 './gw -g 192.168.3.16 --sensor'
{
    resetAppendBuffer
    
    printSensorLine "$BACKUPNAME_SENSOR_WH65" 0 "$SENSOR_WH65_ID" "$SENSOR_WH65_BATTERY_INT" "$SENSOR_WH65_SIGNAL"  "$SENSOR_WH65_ID_STATE" "$SENSOR_WH65_BATTERY_STATE" "$SENSOR_WH65_SIGNAL_STATE"

    printSensorLine "$BACKUPNAME_SENSOR_WH68" 1 "$SENSOR_WH68_ID" "$SENSOR_WH68_BATTERY_INT" "$SENSOR_WH68_SIGNAL"  "$SENSOR_WH68_ID_STATE" "$SENSOR_WH68_BATTERY_STATE" "$SENSOR_WH68_SIGNAL_STATE"

    printSensorLine "$BACKUPNAME_SENSOR_WH80" 2 "$SENSOR_WH80_ID" "$SENSOR_WH80_BATTERY_INT" "$SENSOR_WH80_SIGNAL"  "$SENSOR_WH80_ID_STATE" "$SENSOR_WH80_BATTERY_STATE" "$SENSOR_WH80_SIGNAL_STATE" 
  
   printSensorLine "$BACKUPNAME_SENSOR_RAINFALL" 3 "$SENSOR_RAINFALL_ID" "$SENSOR_RAINFALL_BATTERY_INT" "$SENSOR_RAINFALL_SIGNAL" "$SENSOR_RAINFALL_ID_STATE" "$SENSOR_RAINFALL_BATTERY_STATE" "$SENSOR_RAINFALL_SIGNAL_STATE"
    #old sensor WH25 = 4 WH26 = 5
   printSensorLine "$BACKUPNAME_SENSOR_OUTTEMP" 5 "$SENSOR_OUTTEMP_ID" "$SENSOR_OUTTEMP_BATTERY" "$SENSOR_OUTTEMP_SIGNAL"  "$SENSOR_OUTTEMP_ID_STATE" "$SENSOR_OUTTEMP_BATTERY_STATE" "$SENSOR_OUTTEMP_SIGNAL_STATE"
   
    # use eval "'*'" to prevent word split on space -> leads to additional arguments to printSensorLine

    local_ch=1
    while [ $local_ch -le "$SENSORTYPE_WH31TEMP_MAXCH" ]; do
        eval "prefix=SENSOR_TEMP${local_ch}_"
        local_n=$(( SENSORTYPE_WH31TEMP + local_ch - 1))
        #shellcheck disable=SC2154
        eval printSensorLine "\$BACKUPNAME_SENSOR_TEMP$local_ch" $local_n "\$${prefix}ID" "\$${prefix}BATTERY_INT" "\$${prefix}SIGNAL" "'\$${prefix}ID_STATE'" "'\$${prefix}BATTERY_STATE'" "'\$${prefix}SIGNAL_STATE'"
        local_ch=$((local_ch + 1))
    done

    local_ch=1
    while [ $local_ch -le "$SENSORTYPE_WH51SOILMOISTURE_MAXCH" ]; do
        eval "prefix=SENSOR_SOILMOISTURE${local_ch}_"
        local_n=$(( SENSORTYPE_WH51SOILMOISTURE + local_ch - 1))
        eval printSensorLine "\$BACKUPNAME_SENSOR_SOILMOISTURE$local_ch" $local_n "\$${prefix}ID" "\$${prefix}BATTERY_INT" "\$${prefix}SIGNAL" "'\$${prefix}ID_STATE'" "'\$${prefix}BATTERY_STATE'" "'\$${prefix}SIGNAL_STATE'"
        local_ch=$((local_ch + 1))
    done

    local_ch=1
    while [ $local_ch -le "$SENSORTYPE_WH43PM25_MAXCH" ]; do
        eval "prefix=SENSOR_PM25${local_ch}_"
        #eval echo "prefix \$${prefix}ID $((SENSORTYPE_WH31TEMP + SENSORTYPE_WH31TEMP_MAXCH))"
        local_n=$(( SENSORTYPE_WH43PM25 + local_ch - 1))
        eval printSensorLine "\$BACKUPNAME_SENSOR_PM25$local_ch" $local_n "\$${prefix}ID" "\$${prefix}BATTERY_INT" "\$${prefix}SIGNAL" "'\$${prefix}ID_STATE'" "'\$${prefix}BATTERY_STATE'" "'\$${prefix}SIGNAL_STATE'"
        local_ch=$((local_ch + 1))
    done

    printSensorLine "$BACKUPNAME_SENSOR_LIGHTNING" 26 "$SENSOR_LIGHTNING_ID" "$SENSOR_LIGHTNING_BATTERY" "$SENSOR_LIGHTNING_SIGNAL"  "$SENSOR_LIGHTNING_ID_STATE" "$SENSOR_LIGHTNING_BATTERY_STATE" "$SENSOR_LIGHTNING_SIGNAL_STATE"

    local_ch=1
    while [ $local_ch -le "$SENSORTYPE_WH55LEAK_MAXCH" ]; do
        eval "prefix=SENSOR_LEAK${local_ch}_"
        #eval echo "prefix \$${prefix}ID $((SENSORTYPE_WH31TEMP + SENSORTYPE_WH31TEMP_MAXCH))"
        local_n=$(( SENSORTYPE_WH55LEAK + local_ch - 1))
        eval printSensorLine "\$BACKUPNAME_SENSOR_LEAK$local_ch" $local_n "\$${prefix}ID" "\$${prefix}BATTERY_INT" "\$${prefix}SIGNAL" "'\$${prefix}ID_STATE'" "'\$${prefix}BATTERY_STATE'" "'\$${prefix}SIGNAL_STATE'"
        local_ch=$((local_ch + 1))
    done

    #sensortype >30 available for CMD_READ_SENSORID_NEW

    if [ -n "$SENSOR_SOILTEMP1_ID" ]; then
        local_ch=1
        while [ $local_ch -le "$SENSORTYPE_WH34SOILTEMP_MAXCH" ]; do
            eval "prefix=SENSOR_SOILTEMP${local_ch}_"
            local_n=$(( SENSORTYPE_WH34SOILTEMP + local_ch - 1))
            eval printSensorLine "\$BACKUPNAME_SENSOR_SOILTEMP$local_ch" $local_n "\$${prefix}ID" "\$${prefix}BATTERY_INT" "\$${prefix}SIGNAL" "'\$${prefix}ID_STATE'" "'\$${prefix}BATTERY_STATE'" "'\$${prefix}SIGNAL_STATE'"
            local_ch=$((local_ch + 1))
        done
   fi

    if [ -n "$SENSOR_CO2" ]; then
       printSensorLine "$BACKUPNAME_SENSOR_CO2" 39 "$SENSOR_CO2_ID" "$SENSOR_CO2_BATTERY" "$SENSOR_CO2_SIGNAL"  "$SENSOR_CO2_ID_STATE" "$SENSOR_CO2_BATTERY_STATE" "$SENSOR_CO2_SIGNAL_STATE"
    fi

    if [ -n "$SENSOR_LEAFWETNESS1_ID" ]; then
        local_ch=1
        while [ $local_ch -le "$SENSORTYPE_WH35LEAFWETNESS_MAXCH" ]; do
            eval "prefix=SENSOR_LEAFWETNESS${local_ch}_"
            local_n=$(( SENSORTYPE_WH35LEAFWETNESS + local_ch - 1))
            eval printSensorLine "\$BACKUPNAME_SENSOR_LEAFWETNESS$local_ch" $local_n "\$${prefix}ID" "\$${prefix}BATTERY_INT" "\$${prefix}SIGNAL" "'\$${prefix}ID_STATE'" "'\$${prefix}BATTERY_STATE'" "'\$${prefix}SIGNAL_STATE'"
            local_ch=$((local_ch + 1))
        done
   fi
    
    printAppendBuffer

    unset local_ch local_n
}

printSensorBackup()
{
    printf "%b" "$SENSORBACKUP"
}

printRaindata() {
     if [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_NORMAL" ]; then
            echo "rain rate  $GW_RAINRATE $LIVEDATAUNIT_RAINRATE
rain day   $GW_RAINDAILY $LIVEDATAUNIT_RAIN
rain week  $GW_RAINWEEK $LIVEDATAUNIT_RAIN
rain month $GW_RAINMONTH $LIVEDATAUNIT_RAIN
rain year  $GW_RAINYEAR $LIVEDATAUNIT_RAIN"
    elif  [ "$LIVEDATA_VIEW" -eq "$LIVEDATA_VIEW_BACKUP" ]; then
        :
    fi

}




