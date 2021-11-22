#!/bin/bash

LIVEDATA_FIELD0x01="INTEMP:indoor temperature:C:2:1:1"
LIVEDATA_FIELD0x02="OUTTEMP:outdoor temperature:C:2:1:1"
LIVEDATA_FIELD0x06="INHUMI:indoor humidity:%:1:0"
LIVEDATA_FIELD0x07="OUTHUMI:outdoor humidity:%:1:0"
LIVEDATA_FIELD0x08="ABSBARO:absolute pressure:hpa:2:1"
LIVEDATA_FIELD0x09="RELBARO:relative pressure:hpa:2:1"
LIVEDATA_FIELD0x0A="WINDDIRECTION:wind direction:°:2:0"
LIVEDATA_FIELD0x0B="WINDSPEED:wind speed:m/s:2:1"
LIVEDATA_FIELD0x19="WINDGUSTDAILYMAX:wind gust daily max:m/s:2:1"
LIVEDATA_FIELD0x0C="WINDGUST:wind gust:m/s:2:1"
LIVEDATA_FIELD0x0D="RAINEVENT:rain event:mm:2:1"
LIVEDATA_FIELD0x0E="RAINRATE:rain rate:mm/h:2:1"
LIVEDATA_FIELD0x0F="RAINHOUR:rain hour:mm:2:1"
LIVEDATA_FIELD0x10="RAINDAILY:rain daily:mm:2:1"
LIVEDATA_FIELD0x11="RAINWEEK:rain week:mm:2:1"
LIVEDATA_FIELD0x12="RAINMONTH:rain month:mm:4:1"
LIVEDATA_FIELD0x13="RAINYEAR:rain year:mm:4:1"
LIVEDATA_FIELD0x15="LIGHT:light:lx:4:1" # lux=lumen/m2
LIVEDATA_FIELD0x16="UV:UV radiation:µW/m2:2:1"
LIVEDATA_FIELD0x17="UVI:UV index (0-15)::1:0"

LIVEDATA_FIELD0x60="LIGHTNING:lightning distance (1-40km):km:1:0"
LDF_LIGHTNING_TIME=$(( 0x61 ))
LIVEDATA_FIELD0x61="LIGHTNING_TIME:lightning utc time:utc:4:0"
LIVEDATA_FIELD0x62="LIGHTNING_POWER:lightning power::4:0"


#test
# V='0x01'
# eval echo '$LIVEDATA_FIELD'$V


IFS=' '
F=0x01
V='$LIVEDATA_FIELD'$F
S=$(eval echo $V)
IFS=':'
read -r NAME DESC UNIT << EOF
$S
EOF
echo "$NAME $DESC"