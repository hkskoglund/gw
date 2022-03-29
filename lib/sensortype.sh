#!/bin/sh
#shellcheck disable=SC2034
#https://www.wxforum.net/index.php?topic=40730.0

SENSORID_SEARCH_HEXTEXT=ffffffff
SENSORID_DISABLE_HEXTEXT=fffffffe

case $KSH_VERSION in

    *MIRBSD?KSH*)
        #shellcheck disable=SC3044
        typeset -iU SENSORID_SEARCH  SENSORID_DISABLE VALUE_UINT32BE  VALUE_UINT16BE VALUE_UINT8 SID VALUE_UINT_2SCOMPLEMENT # unsigned 32-bit 
        SENSORID_SEARCH=$(( 0x$SENSORID_SEARCH_HEXTEXT ))
        SENSORID_DISABLE=$(( 0x$SENSORID_DISABLE_HEXTEXT ))
        # mksh - sets 0xffffffff to -1!? if typeset -i SENSORID_SEARCH=0xffffffff - its using 32-bit signed integer by default unless typeset -iU is used
        ;;

    *)
        SENSORID_SEARCH=$((0x$SENSORID_SEARCH_HEXTEXT))
        SENSORID_DISABLE=$((0x$SENSORID_DISABLE_HEXTEXT))
        #ksh typeset option -iu for usigned int https://docstore.mik.ua/orelly/unix3/korn/appb_07.htm
        ;;
esac

SENSORTYPE_WH31TEMP_MAXCH=8
SENSORTYPE_WH51SOILMOISTURE_MAXCH=8
SENSORTYPE_WH43PM25_MAXCH=4
SENSORTYPE_WH55LEAK_MAXCH=4
SENSORTYPE_WH34SOILTEMP_MAXCH=8
SENSORTYPE_WH35LEAFWETNESS_MAXCH=8
SENSORTYPE_TF_USR_MAXCH=8

#index into "sensor id new" data
SENSORTYPE_WH24=0
SENSORTYPE_WH65=0
SENSORTYPE_WH68=1
SENSORTYPE_WH80=2
SENSORTYPE_WH40=3
SENSORTYPE_WH32=5
SENSORTYPE_WH31TEMP=6 # temp. sensors start at 6
SENSORTYPE_WH51SOILMOISTURE=14
SENSORTYPE_WH43PM25=22
SENSORTYPE_WH57LIGHTNING=26
SENSORTYPE_WH55LEAK=27
SENSORTYPE_WH34SOILTEMP=31
SENSORTYPE_WH45CO2=39
SENSORTYPE_WH35LEAFWETNESS=40
SENSORTYPE_MAX=47 

SENSORIDSTATE_CONNECTED=${SENSORIDSTATE_CONNECTED:="✅ connected"}
SENSORIDSTATE_DISCONNECTED=${SENSORIDSTATE_DISCONNECTED:="🚫 disconnected"} #sensortype specified, but signal still 0/no received packets
SENSORIDSTATE_SEARCH=${SENSORIDSTATE_SEARCH:="🔎 searching"}
SENSORIDSTATE_DISABLE=${SENSORIDSTATE_DISABLE:="⛔ disabled"}
SENSORID_HEADER=${SENSORID_HEADER:="Sensor ID B S Type Name State Battery Signal"}

