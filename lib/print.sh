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
        set -x
        printf "%s\r\t\t\t\t\t%s\n%s\r\t\t\t\t\t%s\n" "$WEATHERSERVICEHEADER_WUNDERGROUND_ID" "$GW_WS_WUNDERGROUND_ID" "$WEATHERSERVICEHEADER_WUNDERGROUND_PASSWORD" "$GW_WS_WUNDERGROUND_PASSWORD"
        set +x
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




