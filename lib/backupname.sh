#!/bin/sh
# shellcheck disable=SC2034
# field names in backup file
BACKUPNAME_ECOWITT_INTERVAL="ecowitt_interval"
BACKUPNAME_WUNDERGROUND_ID="wunderground_id"
BACKUPNAME_WUNDERGROUND_PASSWORD="wunderground_password"
BACKUPNAME_WEATHERCLOUD_ID="weathercloud_id"
BACKUPNAME_WEATHERCLOUD_PASSWORD="weathercloud_password"
BACKUPNAME_WOW_ID="wow_id"
BACKUPNAME_WOW_PASSWORD="wow_password"
BACKUPNAME_CUSTOMIZED_ID='customized_id'
BACKUPNAME_CUSTOMIZED_PASSWORD='customized_password'
BACKUPNAME_CUSTOMIZED_SERVER='customized_server'
BACKUPNAME_CUSTOMIZED_PORT='customized_port'
BACKUPNAME_CUSTOMIZED_INTERVAL='customized_interval'
BACKUPNAME_CUSTOMIZED_HTTP='customized_http'
BACKUPNAME_CUSTOMIZED_ENABLED='customized_enabled'
BACKUPNAME_CUSTOMIZED_PATH_ECOWITT='customized_path_ecowitt'
BACKUPNAME_CUSTOMIZED_PATH_WUNDERGROUND='customized_path_wunderground'

BACKUPNAME_SENSOR_WH65="sensor_wh65"
BACKUPNAME_SENSOR_WH68="sensor_wh68"
BACKUPNAME_SENSOR_WH80="sensor_wh80"
BACKUPNAME_SENSOR_WH90="sensor_wh90"
BACKUPNAME_SENSOR_RAINFALL="sensor_rainfall"
BACKUPNAME_SENSOR_OUTTEMP="sensor_outtemp"
BACKUPNAME_SENSOR_TEMP="sensor_temp"
BACKUPNAME_SENSOR_SOILMOISTURE="sensor_soilmoisture"
BACKUPNAME_SENSOR_PM25="sensor_pm25"
BACKUPNAME_SENSOR_LIGHTNING="sensor_lightning"
BACKUPNAME_SENSOR_LEAK="sensor_leak"
BACKUPNAME_SENSOR_SOILTEMP="sensor_soiltemp"
BACKUPNAME_SENSOR_CO2="sensor_co2"
BACKUPNAME_SENSOR_LEAFWETNESS="sensor_leafwetness"

N=1
while [ "$N" -le 8 ]; do 
    if [ "$N" -le 4 ]; then
        eval "BACKUPNAME_SENSOR_PM25$N=sensor_pm25$N"
        eval "BACKUPNAME_SENSOR_LEAK$N=sensor_leak$N"
    fi
    eval "BACKUPNAME_SENSOR_TEMP$N=sensor_temp$N"
    eval "BACKUPNAME_SENSOR_SOILMOISTURE$N=sensor_soilmoisture$N"
    eval "BACKUPNAME_SENSOR_SOILTEMP$N=sensor_soiltemp$N"
    eval "BACKUPNAME_SENSOR_LEAFWETNESS$N=sensor_leafwetness$N"
    N=$(( N + 1 ))
done
unset N

BACKUPNAME_RAINDAY="rain_day"
BACKUPNAME_RAINWEEK="rain_week"
BACKUPNAME_RAINMONTH="rain_month"
BACKUPNAME_RAINYEAR="rain_year" 

getBackupname()
# get backupname for sensortype
{
    unset VALUE_BACKUPNAME

    if [ "$1" -eq 0 ]; then
        VALUE_BACKUPNAME=$BACKUPNAME_SENSOR_WH65;
    elif [ "$1" -eq 1 ]; then
        VALUE_BACKUPNAME=$BACKUPNAME_SENSOR_WH68;
    elif [ "$1" -eq 2 ]; then
        VALUE_BACKUPNAME=$BACKUPNAME_SENSOR_WH80;
    elif [ "$1" -eq 3 ]; then
        VALUE_BACKUPNAME=$BACKUPNAME_SENSOR_RAINFALL
    elif [ "$1" -eq 5 ]; then
        VALUE_BACKUPNAME=$BACKUPNAME_SENSOR_OUTTEMP
    elif [ "$1" -ge 6 ] && [ "$1" -le 13 ]; then
        VALUE_BACKUPNAME="$BACKUPNAME_SENSOR_TEMP$(($1 - 5))"
    elif [ "$1" -ge 14 ] && [ "$1" -le 21 ]; then
        VALUE_BACKUPNAME="$BACKUPNAME_SENSOR_SOILMOISTURE$(($1 - 13))"
    elif [ "$1" -ge 22 ] && [ "$1" -le 25 ]; then
        VALUE_BACKUPNAME="$BACKUPNAME_SENSOR_SOILMOISTURE$(($1 - 21))"
    elif [ "$1" -eq 26 ]; then
        VALUE_BACKUPNAME=$BACKUPNAME_SENSOR_LIGHTNING
    elif [ "$1" -ge 27 ] && [ "$1" -le 30 ]; then
        VALUE_BACKUPNAME="$BACKUPNAME_SENSOR_LEAK$(($1 - 26))"
    elif [ "$1" -ge 31 ] && [ "$1" -le 38 ]; then
        VALUE_BACKUPNAME="$BACKUPNAME_SENSOR_SOILTEMP$(($1 - 30))"
    elif [ "$1" -eq 39 ]; then
        VALUE_BACKUPNAME=$BACKUPNAME_SENSOR_CO2
    elif [ "$1" -ge 40 ] && [ "$1" -le 47 ]; then
        VALUE_BACKUPNAME="$BACKUPNAME_SENSOR_LEAFWETNESS$(($1 - 39))"
    fi
    
}

#set | grep BACKUPNAME_
