#!/bin/sh

printEcowittInterval()
{
    if [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_NORMAL" ]; then
        if [ "$GW_WS_ECOWITT_INTERVAL" -eq 1 ]; then
        local_min="$WEATHERSERVICEHEADERUNIT_MINUTE"
        elif [ "$GW_WS_ECOWITT_INTERVAL" -gt 1 ]; then
            local_min="$WEATHERSERVICEHEADERUNIT_MINUTES"
        fi

        printf "%s\r\t\t\t\t\t%s %s\n" "$WEATHERSERVICEHEADER_ECOWITT_INTERVAL" "$GW_WS_ECOWITT_INTERVAL" "$local_min"
        
        unset local_min
    elif [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_BACKUP" ]; then
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
    if [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_NORMAL" ]; then
        printWundergroundId
        printWundergroundPassword
    elif  [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_BACKUP" ]; then
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
    if [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_NORMAL" ]; then
       printWeathercloudId
       printWeathercloudPassword
    elif  [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_BACKUP" ]; then
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
    if [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_NORMAL" ]; then
        printWowId
        printWowPassword
    elif  [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_BACKUP" ]; then
        printf "%-32s %s\n%-32s %s\n" "$BACKUPNAME_WOW_ID" "$GW_WS_WOW_ID" "$BACKUPNAME_WOW_PASSWORD" "$GW_WS_WOW_PASSWORD"
    fi
}

printCustomized() {
    if [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_NORMAL" ]; then
        printf "%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s %s\n%s\r\t\t\t\t\t%s %s\n%s\r\t\t\t\t\t%s %s\n%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n"\
                    "$WEATHERSERVICEHEADER_CUSTOMIZED_ID" "$GW_WS_CUSTOMIZED_ID" "$WEATHERSERVICEHEADER_CUSTOMIZED_PASSWORD" "$GW_WS_CUSTOMIZED_PASSWORD"\
                    "$WEATHERSERVICEHEADER_CUSTOMIZED_SERVER" "$GW_WS_CUSTOMIZED_SERVER" "$WEATHERSERVICEHEADER_CUSTOMIZED_PORT" "$GW_WS_CUSTOMIZED_PORT"\
                    "$WEATHERSERVICEHEADER_CUSTOMIZED_INTERVAL" "$GW_WS_CUSTOMIZED_INTERVAL" "$WEATHERSERVICEHEADERUNIT_SECONDS" "$WEATHERSERVICEHEADER_CUSTOMIZED_HTTP" "$GW_WS_CUSTOMIZED_HTTP" "$GW_WS_CUSTOMIZED_HTTP_STATE"\
                    "$WEATHERSERVICEHEADER_CUSTOMIZED_ENABLED" "$GW_WS_CUSTOMIZED_ENABLED" "$GW_WS_CUSTOMIZED_ENABLED_STATE"\
                    "$WEATHERSERVICEHEADER_CUSTOMIZED_PATH_ECOWITT" "$GW_WS_CUSTOMIZED_PATH_ECOWITT" "$WEATHERSERVICEHEADER_CUSTOMIZED_PATH_WUNDERGROUND" "$GW_WS_CUSTOMIZED_PATH_WU"
    elif [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_BACKUP" ]; then
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
    if [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_NORMAL" ]; then
        echo "$WEATHERSERVICEHEADER_CUSTOMIZED_PATH_ECOWITT      $GW_WS_CUSTOMIZED_PATH_ECOWITT
$WEATHERSERVICEHEADER_CUSTOMIZED_PATH_WUNDERGROUND $GW_WS_CUSTOMIZED_PATH_WU"
    elif [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_BACKUP" ]; then
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
                      #1:Sensortype 2:sid 3:battery 4:signal 5:type 6:name 7:state 8:battery 9:signal
        appendBuffer "%6s %9s %3s %1s %-4s %-17s %-12s\t%s\t%s\n%s\n" "$SENSORID_HEADER ───────────────────────────────────────────────────────────────────────────────"
}

printSensorLine()
#$1 backupname, $2 sensortype, $3 sensor id, $4 battery, $5 signal  $6 sensorid state, $7 battery state, $8 signal state unicode, 
#observation: leak sensor signal -> starts at level 1 after search state, then increases +1 each time a new rf message is received
{
     # 1 battery unicode is field size 4 in printf format string. TEST printf  "🔋 1.3 V" | od -A n -t x1 | wc -w -> 10
     # use \r\t\t\t workaround for unicode alignment
  
#    appendBuffer "%-20s %2u %8x %3u %1u $style_sensor%s$style_sensor_off\t%s\t%s\n"\
# "'$1' '$2' '$3' '$4' '$5' '$6' '$7' '$8'"
   if [ -n "$3" ]; then
        appendBuffer "%-20s %8x %s\t%s\t%s\n" "'$1' '$3' '$6' '$7' '$8'"
    else
        appendBuffer "%-20s %8s %s\t%s\t%s\n" "'$1' '$3' '$6' '$7' '$8'" # http request does not have signal/id information
    fi
}

printSensorTemp()
{
 # use eval "'*'" to prevent word split on space -> leads to additional arguments to printSensorLine
    # while loop skipped, due to almost the same numbers of lines and use of eval
    [ -n "$SENSOR_TEMP1_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_TEMP}1" $((SENSORTYPE_WH31TEMP ))    "$SENSOR_TEMP1_ID" "$SENSOR_TEMP1_BATTERY_INT" "$SENSOR_TEMP1_SIGNAL" "$SENSOR_TEMP1_ID_STATE" "$SENSOR_TEMP1_BATTERY_STATE" "$SENSOR_TEMP1_SIGNAL_STATE"
    [ -n "$SENSOR_TEMP2_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_TEMP}2" $((SENSORTYPE_WH31TEMP + 1)) "$SENSOR_TEMP2_ID" "$SENSOR_TEMP2_BATTERY_INT" "$SENSOR_TEMP2_SIGNAL" "$SENSOR_TEMP2_ID_STATE" "$SENSOR_TEMP2_BATTERY_STATE" "$SENSOR_TEMP2_SIGNAL_STATE"
    [ -n "$SENSOR_TEMP3_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_TEMP}3" $((SENSORTYPE_WH31TEMP + 2)) "$SENSOR_TEMP3_ID" "$SENSOR_TEMP3_BATTERY_INT" "$SENSOR_TEMP3_SIGNAL" "$SENSOR_TEMP3_ID_STATE" "$SENSOR_TEMP3_BATTERY_STATE" "$SENSOR_TEMP3_SIGNAL_STATE"
    [ -n "$SENSOR_TEMP4_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_TEMP}4" $((SENSORTYPE_WH31TEMP + 3)) "$SENSOR_TEMP4_ID" "$SENSOR_TEMP4_BATTERY_INT" "$SENSOR_TEMP4_SIGNAL" "$SENSOR_TEMP4_ID_STATE" "$SENSOR_TEMP4_BATTERY_STATE" "$SENSOR_TEMP4_SIGNAL_STATE"
    [ -n "$SENSOR_TEMP5_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_TEMP}5" $((SENSORTYPE_WH31TEMP + 4)) "$SENSOR_TEMP5_ID" "$SENSOR_TEMP5_BATTERY_INT" "$SENSOR_TEMP5_SIGNAL" "$SENSOR_TEMP5_ID_STATE" "$SENSOR_TEMP5_BATTERY_STATE" "$SENSOR_TEMP5_SIGNAL_STATE"
    [ -n "$SENSOR_TEMP6_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_TEMP}6" $((SENSORTYPE_WH31TEMP + 5)) "$SENSOR_TEMP6_ID" "$SENSOR_TEMP6_BATTERY_INT" "$SENSOR_TEMP6_SIGNAL" "$SENSOR_TEMP6_ID_STATE" "$SENSOR_TEMP6_BATTERY_STATE" "$SENSOR_TEMP6_SIGNAL_STATE"
    [ -n "$SENSOR_TEMP7_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_TEMP}7" $((SENSORTYPE_WH31TEMP + 6)) "$SENSOR_TEMP7_ID" "$SENSOR_TEMP7_BATTERY_INT" "$SENSOR_TEMP7_SIGNAL" "$SENSOR_TEMP7_ID_STATE" "$SENSOR_TEMP7_BATTERY_STATE" "$SENSOR_TEMP7_SIGNAL_STATE"
    [ -n "$SENSOR_TEMP8_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_TEMP}8" $((SENSORTYPE_WH31TEMP + 7)) "$SENSOR_TEMP8_ID" "$SENSOR_TEMP8_BATTERY_INT" "$SENSOR_TEMP8_SIGNAL" "$SENSOR_TEMP8_ID_STATE" "$SENSOR_TEMP8_BATTERY_STATE" "$SENSOR_TEMP8_SIGNAL_STATE"
}

printSensorSoilmoisture()
{
    [ -n "$SENSOR_SOILMOISTURE1_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILMOISTURE}1" $((SENSORTYPE_WH51SOILMOISTURE ))    "$SENSOR_SOILMOISTURE1_ID" "$SENSOR_SOILMOISTURE1_BATTERY_INT" "$SENSOR_SOILMOISTURE1_SIGNAL" "$SENSOR_SOILMOISTURE1_ID_STATE" "$SENSOR_SOILMOISTURE1_BATTERY_STATE" "$SENSOR_SOILMOISTURE1_SIGNAL_STATE"
    [ -n "$SENSOR_SOILMOISTURE2_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILMOISTURE}2" $((SENSORTYPE_WH51SOILMOISTURE + 1)) "$SENSOR_SOILMOISTURE2_ID" "$SENSOR_SOILMOISTURE2_BATTERY_INT" "$SENSOR_SOILMOISTURE2_SIGNAL" "$SENSOR_SOILMOISTURE2_ID_STATE" "$SENSOR_SOILMOISTURE2_BATTERY_STATE" "$SENSOR_SOILMOISTURE2_SIGNAL_STATE"
    [ -n "$SENSOR_SOILMOISTURE3_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILMOISTURE}3" $((SENSORTYPE_WH51SOILMOISTURE + 2)) "$SENSOR_SOILMOISTURE3_ID" "$SENSOR_SOILMOISTURE3_BATTERY_INT" "$SENSOR_SOILMOISTURE3_SIGNAL" "$SENSOR_SOILMOISTURE3_ID_STATE" "$SENSOR_SOILMOISTURE3_BATTERY_STATE" "$SENSOR_SOILMOISTURE3_SIGNAL_STATE"
    [ -n "$SENSOR_SOILMOISTURE4_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILMOISTURE}4" $((SENSORTYPE_WH51SOILMOISTURE + 3)) "$SENSOR_SOILMOISTURE4_ID" "$SENSOR_SOILMOISTURE4_BATTERY_INT" "$SENSOR_SOILMOISTURE4_SIGNAL" "$SENSOR_SOILMOISTURE4_ID_STATE" "$SENSOR_SOILMOISTURE4_BATTERY_STATE" "$SENSOR_SOILMOISTURE4_SIGNAL_STATE"
    [ -n "$SENSOR_SOILMOISTURE5_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILMOISTURE}5" $((SENSORTYPE_WH51SOILMOISTURE + 4)) "$SENSOR_SOILMOISTURE5_ID" "$SENSOR_SOILMOISTURE5_BATTERY_INT" "$SENSOR_SOILMOISTURE5_SIGNAL" "$SENSOR_SOILMOISTURE5_ID_STATE" "$SENSOR_SOILMOISTURE5_BATTERY_STATE" "$SENSOR_SOILMOISTURE5_SIGNAL_STATE"
    [ -n "$SENSOR_SOILMOISTURE6_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILMOISTURE}6" $((SENSORTYPE_WH51SOILMOISTURE + 5)) "$SENSOR_SOILMOISTURE6_ID" "$SENSOR_SOILMOISTURE6_BATTERY_INT" "$SENSOR_SOILMOISTURE6_SIGNAL" "$SENSOR_SOILMOISTURE6_ID_STATE" "$SENSOR_SOILMOISTURE6_BATTERY_STATE" "$SENSOR_SOILMOISTURE6_SIGNAL_STATE"
    [ -n "$SENSOR_SOILMOISTURE7_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILMOISTURE}7" $((SENSORTYPE_WH51SOILMOISTURE + 6)) "$SENSOR_SOILMOISTURE7_ID" "$SENSOR_SOILMOISTURE7_BATTERY_INT" "$SENSOR_SOILMOISTURE7_SIGNAL" "$SENSOR_SOILMOISTURE7_ID_STATE" "$SENSOR_SOILMOISTURE7_BATTERY_STATE" "$SENSOR_SOILMOISTURE7_SIGNAL_STATE"
    [ -n "$SENSOR_SOILMOISTURE8_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILMOISTURE}8" $((SENSORTYPE_WH51SOILMOISTURE + 7)) "$SENSOR_SOILMOISTURE8_ID" "$SENSOR_SOILMOISTURE8_BATTERY_INT" "$SENSOR_SOILMOISTURE8_SIGNAL" "$SENSOR_SOILMOISTURE8_ID_STATE" "$SENSOR_SOILMOISTURE8_BATTERY_STATE" "$SENSOR_SOILMOISTURE8_SIGNAL_STATE"
}

printSensorPM25()
{
    [ -n "$SENSOR_PM251_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_PM25}1" $((SENSORTYPE_WH43PM25 ))    "$SENSOR_PM251_ID" "$SENSOR_PM251_BATTERY_INT" "$SENSOR_PM251_SIGNAL" "$SENSOR_PM251_ID_STATE" "$SENSOR_PM251_BATTERY_STATE" "$SENSOR_PM251_SIGNAL_STATE"
    [ -n "$SENSOR_PM252_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_PM25}2" $((SENSORTYPE_WH43PM25 + 1)) "$SENSOR_PM252_ID" "$SENSOR_PM252_BATTERY_INT" "$SENSOR_PM252_SIGNAL" "$SENSOR_PM252_ID_STATE" "$SENSOR_PM252_BATTERY_STATE" "$SENSOR_PM252_SIGNAL_STATE"
    [ -n "$SENSOR_PM253_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_PM25}3" $((SENSORTYPE_WH43PM25 + 2)) "$SENSOR_PM253_ID" "$SENSOR_PM253_BATTERY_INT" "$SENSOR_PM253_SIGNAL" "$SENSOR_PM253_ID_STATE" "$SENSOR_PM253_BATTERY_STATE" "$SENSOR_PM253_SIGNAL_STATE"
    [ -n "$SENSOR_PM254_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_PM25}4" $((SENSORTYPE_WH43PM25 + 3)) "$SENSOR_PM254_ID" "$SENSOR_PM254_BATTERY_INT" "$SENSOR_PM254_SIGNAL" "$SENSOR_PM254_ID_STATE" "$SENSOR_PM254_BATTERY_STATE" "$SENSOR_PM254_SIGNAL_STATE"
}

printSensorLightning()
{
    [ -n "$SENSOR_LIGHTNING_ID_STATE" ] &&printSensorLine "$BACKUPNAME_SENSOR_LIGHTNING" 26 "$SENSOR_LIGHTNING_ID" "$SENSOR_LIGHTNING_BATTERY" "$SENSOR_LIGHTNING_SIGNAL"  "$SENSOR_LIGHTNING_ID_STATE" "$SENSOR_LIGHTNING_BATTERY_STATE" "$SENSOR_LIGHTNING_SIGNAL_STATE"
}

printSensorOuttemp()
{
     #old sensor WH25 = 4 WH26 = 5
     [ -n "$SENSOR_OUTTEMP_ID_STATE" ] && printSensorLine "$BACKUPNAME_SENSOR_OUTTEMP" 5 "$SENSOR_OUTTEMP_ID" "$SENSOR_OUTTEMP_BATTERY" "$SENSOR_OUTTEMP_SIGNAL"  "$SENSOR_OUTTEMP_ID_STATE" "$SENSOR_OUTTEMP_BATTERY_STATE" "$SENSOR_OUTTEMP_SIGNAL_STATE"
}

printSensorRainfall()
{
        [ -n "$SENSOR_RAINFALL_ID_STATE" ] && printSensorLine "$BACKUPNAME_SENSOR_RAINFALL" 3 "$SENSOR_RAINFALL_ID" "$SENSOR_RAINFALL_BATTERY_INT" "$SENSOR_RAINFALL_SIGNAL" "$SENSOR_RAINFALL_ID_STATE" "$SENSOR_RAINFALL_BATTERY_STATE" "$SENSOR_RAINFALL_SIGNAL_STATE"
}

printSensorWH80()
{
        [ -n "$SENSOR_WH80_ID_STATE" ] && printSensorLine "$BACKUPNAME_SENSOR_WH80" 2 "$SENSOR_WH80_ID" "$SENSOR_WH80_BATTERY_INT" "$SENSOR_WH80_SIGNAL"  "$SENSOR_WH80_ID_STATE" "$SENSOR_WH80_BATTERY_STATE" "$SENSOR_WH80_SIGNAL_STATE" 
}

printSensorWH68()
{
        [ -n "$SENSOR_WH68_ID_STATE" ] && printSensorLine "$BACKUPNAME_SENSOR_WH68" 1 "$SENSOR_WH68_ID" "$SENSOR_WH68_BATTERY_INT" "$SENSOR_WH68_SIGNAL"  "$SENSOR_WH68_ID_STATE" "$SENSOR_WH68_BATTERY_STATE" "$SENSOR_WH68_SIGNAL_STATE"
}

printSensorWH65()
{
        [ -n "$SENSOR_WH65_ID_STATE" ] && printSensorLine "$BACKUPNAME_SENSOR_WH65" 0 "$SENSOR_WH65_ID" "$SENSOR_WH65_BATTERY_INT" "$SENSOR_WH65_SIGNAL"  "$SENSOR_WH65_ID_STATE" "$SENSOR_WH65_BATTERY_STATE" "$SENSOR_WH65_SIGNAL_STATE"
}

printSensorLeak()
{
    [ -n "$SENSOR_LEAK1_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAK}1" $((SENSORTYPE_WH55LEAK ))    "$SENSOR_LEAK1_ID" "$SENSOR_LEAK1_BATTERY_INT" "$SENSOR_LEAK1_SIGNAL" "$SENSOR_LEAK1_ID_STATE" "$SENSOR_LEAK1_BATTERY_STATE" "$SENSOR_LEAK1_SIGNAL_STATE"
    [ -n "$SENSOR_LEAK2_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAK}2" $((SENSORTYPE_WH55LEAK + 1)) "$SENSOR_LEAK2_ID" "$SENSOR_LEAK2_BATTERY_INT" "$SENSOR_LEAK2_SIGNAL" "$SENSOR_LEAK2_ID_STATE" "$SENSOR_LEAK2_BATTERY_STATE" "$SENSOR_LEAK2_SIGNAL_STATE"
    [ -n "$SENSOR_LEAK3_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAK}3" $((SENSORTYPE_WH55LEAK + 2)) "$SENSOR_LEAK3_ID" "$SENSOR_LEAK3_BATTERY_INT" "$SENSOR_LEAK3_SIGNAL" "$SENSOR_LEAK3_ID_STATE" "$SENSOR_LEAK3_BATTERY_STATE" "$SENSOR_LEAK3_SIGNAL_STATE"
    [ -n "$SENSOR_LEAK4_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAK}4" $((SENSORTYPE_WH55LEAK + 3)) "$SENSOR_LEAK4_ID" "$SENSOR_LEAK4_BATTERY_INT" "$SENSOR_LEAK4_SIGNAL" "$SENSOR_LEAK4_ID_STATE" "$SENSOR_LEAK4_BATTERY_STATE" "$SENSOR_LEAK4_SIGNAL_STATE"
}

printSensorSoiltemp()
{
    [ -n "$SENSOR_SOILTEMP1_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILTEMP}1" $((SENSORTYPE_WH34SOILTEMP ))    "$SENSOR_SOILTEMP1_ID" "$SENSOR_SOILTEMP1_BATTERY_INT" "$SENSOR_SOILTEMP1_SIGNAL" "$SENSOR_SOILTEMP1_ID_STATE" "$SENSOR_SOILTEMP1_BATTERY_STATE" "$SENSOR_SOILTEMP1_SIGNAL_STATE"
    [ -n "$SENSOR_SOILTEMP2_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILTEMP}2" $((SENSORTYPE_WH34SOILTEMP + 1)) "$SENSOR_SOILTEMP2_ID" "$SENSOR_SOILTEMP2_BATTERY_INT" "$SENSOR_SOILTEMP2_SIGNAL" "$SENSOR_SOILTEMP2_ID_STATE" "$SENSOR_SOILTEMP2_BATTERY_STATE" "$SENSOR_SOILTEMP2_SIGNAL_STATE"
    [ -n "$SENSOR_SOILTEMP3_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILTEMP}3" $((SENSORTYPE_WH34SOILTEMP + 2)) "$SENSOR_SOILTEMP3_ID" "$SENSOR_SOILTEMP3_BATTERY_INT" "$SENSOR_SOILTEMP3_SIGNAL" "$SENSOR_SOILTEMP3_ID_STATE" "$SENSOR_SOILTEMP3_BATTERY_STATE" "$SENSOR_SOILTEMP3_SIGNAL_STATE"
    [ -n "$SENSOR_SOILTEMP4_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILTEMP}4" $((SENSORTYPE_WH34SOILTEMP + 3)) "$SENSOR_SOILTEMP4_ID" "$SENSOR_SOILTEMP4_BATTERY_INT" "$SENSOR_SOILTEMP4_SIGNAL" "$SENSOR_SOILTEMP4_ID_STATE" "$SENSOR_SOILTEMP4_BATTERY_STATE" "$SENSOR_SOILTEMP4_SIGNAL_STATE"
    [ -n "$SENSOR_SOILTEMP5_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILTEMP}5" $((SENSORTYPE_WH34SOILTEMP + 4)) "$SENSOR_SOILTEMP5_ID" "$SENSOR_SOILTEMP5_BATTERY_INT" "$SENSOR_SOILTEMP5_SIGNAL" "$SENSOR_SOILTEMP5_ID_STATE" "$SENSOR_SOILTEMP5_BATTERY_STATE" "$SENSOR_SOILTEMP5_SIGNAL_STATE"
    [ -n "$SENSOR_SOILTEMP6_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILTEMP}6" $((SENSORTYPE_WH34SOILTEMP + 5)) "$SENSOR_SOILTEMP6_ID" "$SENSOR_SOILTEMP6_BATTERY_INT" "$SENSOR_SOILTEMP6_SIGNAL" "$SENSOR_SOILTEMP6_ID_STATE" "$SENSOR_SOILTEMP6_BATTERY_STATE" "$SENSOR_SOILTEMP6_SIGNAL_STATE"
    [ -n "$SENSOR_SOILTEMP7_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILTEMP}7" $((SENSORTYPE_WH34SOILTEMP + 6)) "$SENSOR_SOILTEMP7_ID" "$SENSOR_SOILTEMP7_BATTERY_INT" "$SENSOR_SOILTEMP7_SIGNAL" "$SENSOR_SOILTEMP7_ID_STATE" "$SENSOR_SOILTEMP7_BATTERY_STATE" "$SENSOR_SOILTEMP7_SIGNAL_STATE"
    [ -n "$SENSOR_SOILTEMP8_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_SOILTEMP}8" $((SENSORTYPE_WH34SOILTEMP + 7)) "$SENSOR_SOILTEMP8_ID" "$SENSOR_SOILTEMP8_BATTERY_INT" "$SENSOR_SOILTEMP8_SIGNAL" "$SENSOR_SOILTEMP8_ID_STATE" "$SENSOR_SOILTEMP8_BATTERY_STATE" "$SENSOR_SOILTEMP8_SIGNAL_STATE"
}

printSensorCO2()
{
     if [ -n "$SENSOR_CO2" ]; then
       printSensorLine "$BACKUPNAME_SENSOR_CO2" 39 "$SENSOR_CO2_ID" "$SENSOR_CO2_BATTERY" "$SENSOR_CO2_SIGNAL"  "$SENSOR_CO2_ID_STATE" "$SENSOR_CO2_BATTERY_STATE" "$SENSOR_CO2_SIGNAL_STATE"
    fi
}

printSensorLeafwetness()
{
     [ -n "$SENSOR_LEAFWETNESS1_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAFWETNESS}1" $((SENSORTYPE_ ))    "$SENSOR_LEAFWETNESS1_ID" "$SENSOR_LEAFWETNESS1_BATTERY_INT" "$SENSOR_LEAFWETNESS1_SIGNAL" "$SENSOR_LEAFWETNESS1_ID_STATE" "$SENSOR_LEAFWETNESS1_BATTERY_STATE" "$SENSOR_LEAFWETNESS1_SIGNAL_STATE"
    [ -n "$SENSOR_LEAFWETNESS2_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAFWETNESS}2" $((SENSORTYPE_WH35LEAFWETNESS + 1)) "$SENSOR_LEAFWETNESS2_ID" "$SENSOR_LEAFWETNESS2_BATTERY_INT" "$SENSOR_LEAFWETNESS2_SIGNAL" "$SENSOR_LEAFWETNESS2_ID_STATE" "$SENSOR_LEAFWETNESS2_BATTERY_STATE" "$SENSOR_LEAFWETNESS2_SIGNAL_STATE"
    [ -n "$SENSOR_LEAFWETNESS3_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAFWETNESS}3" $((SENSORTYPE_WH35LEAFWETNESS + 2)) "$SENSOR_LEAFWETNESS3_ID" "$SENSOR_LEAFWETNESS3_BATTERY_INT" "$SENSOR_LEAFWETNESS3_SIGNAL" "$SENSOR_LEAFWETNESS3_ID_STATE" "$SENSOR_LEAFWETNESS3_BATTERY_STATE" "$SENSOR_LEAFWETNESS3_SIGNAL_STATE"
    [ -n "$SENSOR_LEAFWETNESS4_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAFWETNESS}4" $((SENSORTYPE_WH35LEAFWETNESS + 3)) "$SENSOR_LEAFWETNESS4_ID" "$SENSOR_LEAFWETNESS4_BATTERY_INT" "$SENSOR_LEAFWETNESS4_SIGNAL" "$SENSOR_LEAFWETNESS4_ID_STATE" "$SENSOR_LEAFWETNESS4_BATTERY_STATE" "$SENSOR_LEAFWETNESS4_SIGNAL_STATE"
    [ -n "$SENSOR_LEAFWETNESS5_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAFWETNESS}5" $((SENSORTYPE_WH35LEAFWETNESS + 4)) "$SENSOR_LEAFWETNESS5_ID" "$SENSOR_LEAFWETNESS5_BATTERY_INT" "$SENSOR_LEAFWETNESS5_SIGNAL" "$SENSOR_LEAFWETNESS5_ID_STATE" "$SENSOR_LEAFWETNESS5_BATTERY_STATE" "$SENSOR_LEAFWETNESS5_SIGNAL_STATE"
    [ -n "$SENSOR_LEAFWETNESS6_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAFWETNESS}6" $((SENSORTYPE_WH35LEAFWETNESS + 5)) "$SENSOR_LEAFWETNESS6_ID" "$SENSOR_LEAFWETNESS6_BATTERY_INT" "$SENSOR_LEAFWETNESS6_SIGNAL" "$SENSOR_LEAFWETNESS6_ID_STATE" "$SENSOR_LEAFWETNESS6_BATTERY_STATE" "$SENSOR_LEAFWETNESS6_SIGNAL_STATE"
    [ -n "$SENSOR_LEAFWETNESS7_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAFWETNESS}7" $((SENSORTYPE_WH35LEAFWETNESS + 6)) "$SENSOR_LEAFWETNESS7_ID" "$SENSOR_LEAFWETNESS7_BATTERY_INT" "$SENSOR_LEAFWETNESS7_SIGNAL" "$SENSOR_LEAFWETNESS7_ID_STATE" "$SENSOR_LEAFWETNESS7_BATTERY_STATE" "$SENSOR_LEAFWETNESS7_SIGNAL_STATE"
    [ -n "$SENSOR_LEAFWETNESS8_ID_STATE" ] && printSensorLine  "${BACKUPNAME_SENSOR_LEAFWETNESS}8" $((SENSORTYPE_WH35LEAFWETNESS + 7)) "$SENSOR_LEAFWETNESS8_ID" "$SENSOR_LEAFWETNESS8_BATTERY_INT" "$SENSOR_LEAFWETNESS8_SIGNAL" "$SENSOR_LEAFWETNESS8_ID_STATE" "$SENSOR_LEAFWETNESS8_BATTERY_STATE" "$SENSOR_LEAFWETNESS8_SIGNAL_STATE"
}

printSensorHTML()
{
     printf "HTTP/1.1 200 OK
Server: gw
Content-Type: text/html; charset=\"UTF-8\"
Refresh: 16

<!DOCTYPE html>
<html>
<head>
<meta charset=\"UTF-8\">
<title>Sensor overview %s %s %s</title>
</head>
<body>
<pre>%s</pre>
</body>
</html>" "$LIVEDATA_SYSTEM_HOST" "$LIVEDATA_SYSTEM_VERSION" "$LIVEDATA_SYSTEM_UTC"  "$SENSOR_TEXTPLAIN"

}

printSensors()
# print parsed sensors in SENSOR_*
# test in terminal: watch -n 1 './gw -g 192.168.3.16 --sensor'
{
    resetAppendBuffer
    
    #standard sensors

    printSensorWH65
    printSensorWH68
    printSensorWH80
    printSensorRainfall
    printSensorOuttemp
    printSensorTemp
    printSensorSoilmoisture
    printSensorPM25
    printSensorLightning
    printSensorLeak
 
    # additional sensors - sensortype >30 available for CMD_READ_SENSORID_NEW

    printSensorSoiltemp
    printSensorCO2
    printSensorLeafwetness
    
    printAppendBuffer
}

printSensorBackup()
{
    printf "%b" "$SENSORBACKUP"
}

printRaindata() {
     if [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_NORMAL" ]; then
            echo "rain rate  $GW_RAINRATE $LIVEDATAUNIT_RAINRATE
rain day   $GW_RAINDAILY $LIVEDATAUNIT_RAIN
rain week  $GW_RAINWEEK $LIVEDATAUNIT_RAIN
rain month $GW_RAINMONTH $LIVEDATAUNIT_RAIN
rain year  $GW_RAINYEAR $LIVEDATAUNIT_RAIN"
    elif  [ "$LIVEDATAVIEW" -eq "$LIVEDATAVIEW_BACKUP" ]; then
        :
    fi

}




