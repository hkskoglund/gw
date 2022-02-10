#!/bin/sh
setWindMode()
{
    UNIT_WIND_MODE=$1

    if [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_MPH" ]; then 
          UNIT_WIND="mph"
       
    elif [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_MPS" ]; then
         UNIT_WIND=$UNIT_UNICODE_WIND_MPS
    elif [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_KMH" ]; then
         UNIT_WIND="km/$UNIT_HOUR"
    fi
    
    [ "$DEBUG" -eq 1 ] && >&2 echo Unit wind : "$UNIT_WIND"

}

setUVMode()
{
    UNIT_UV_MODE=$1

    if [ "$UNIT_UV_MODE" -eq "$UNIT_UV_MICROWM2" ]; then
        UNIT_UV="W/m2?" # documentation for livedata protocol: ITEM_UV uW/m2?
    elif [ "$UNIT_UV_MODE" -eq "$UNIT_UV_WATTM2" ]; then
        if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
            UNIT_UV="W/㎡"   
        else
            UNIT_UV="W/m2"
        fi
    fi

    [ "$DEBUG" -eq 1 ] && >&2 echo Unit UV : $UNIT_UV

}

setTemperatureMode()
#$1 - mode
{
    UNIT_TEMPERATURE_MODE=$1

    if [ "$UNIT_TEMPERATURE_MODE" -eq "$UNIT_TEMPERATURE_CELCIUS" ]; then 
        if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
            UNIT_TEMP=$UNIT_UNICODE_CELCIUS
        else
            UNIT_TEMP="C"
        fi
       
    elif [ "$UNIT_TEMPERATURE_MODE" -eq "$UNIT_TEMPERATURE_FARENHEIT" ]; then
        if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
            UNIT_TEMP=$UNIT_UNICODE_FARENHEIT
        else
            UNIT_TEMP="F"
        fi
    fi
    
    [ "$DEBUG" -eq 1 ] && >&2 echo Unit temperature : $UNIT_TEMP

}

setPressureMode()
{
    UNIT_PRESSURE_MODE=$1

    if  [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_HPA" ]; then
        UNIT_PRESSURE=$UNIT_UNICODE_PRESSURE_HPA
    elif [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_INHG" ]; then
        UNIT_PRESSURE="inHg"
    fi

    [ "$DEBUG" -eq 1 ] && >&2 echo Unit pressure : $UNIT_PRESSURE

}

setRainMode()
{
    UNIT_RAIN_MODE=$1

    if  [ "$UNIT_RAIN_MODE" -eq "$UNIT_RAIN_MM" ]; then
        UNIT_RAIN=$UNIT_UNICODE_RAIN_MM
    elif [ "$UNIT_RAIN_MODE" -eq "$UNIT_RAIN_IN" ]; then
        UNIT_RAIN="in"
    fi

    UNIT_HOUR=${UNIT_HOUR:="h"}
    UNIT_RAINRATE=$UNIT_RAIN"/$UNIT_HOUR"

    [ "$DEBUG" -eq 1 ] && >&2 echo Unit rain rainrate : $UNIT_RAIN "$UNIT_RAINRATE"
    
}
