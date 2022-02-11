#!/bin/sh

UNIT_TEMPERATURE_CELCIUS=0
UNIT_TEMPERATURE_FARENHEIT=1

UNIT_PRESSURE_HPA=0
UNIT_PRESSURE_INHG=1

UNIT_RAIN_MM=0
UNIT_RAIN_IN=1

UNIT_WIND_MPS=0
UNIT_WIND_MPH=1
UNIT_WIND_KMH=2

UNIT_UV_MICROWM2=0 # used by Ecowitt protocol
UNIT_UV_WATTM2=1

UNIT_UNICODE_CELCIUS="℃"
UNIT_UNICODE_FARENHEIT="℉"
UNIT_UNICODE_WIND_MPS="m/s"
UNIT_UNICODE_PRESSURE_HPA="hPa"
UNIT_UNICODE_RAIN_MM="mm"

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

initUnit()
{
    if [ -z "$UNIT_TEMPERATURE_MODE" ]; then 
        setTemperatureMode "$UNIT_TEMPERATURE_CELCIUS" # default
    else
        setTemperatureMode "$UNIT_TEMPERATURE_MODE"
    fi

    if [ -z "$UNIT_PRESSURE_MODE" ]; then
        setPressureMode "$UNIT_PRESSURE_HPA" # default
    else
        setPressureMode "$UNIT_PRESSURE_MODE"
    fi

    if [ -z "$UNIT_RAIN_MODE" ]; then 
        setRainMode "$UNIT_RAIN_MM" #default
    else
        setRainMode "$UNIT_RAIN_MODE"
    fi
    
    if [ -z "$UNIT_WIND_MODE" ]; then 
        setWindMode "$UNIT_WIND_MPS" #default
    else
        setWindMode "$UNIT_WIND_MODE"
    fi

    if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
        UNIT_LIGHT="㏓"
    else
        UNIT_LIGHT="lux"
    fi 
    
    if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
        UNIT_PM25="µg/㎥"
    else
        UNIT_PM25="µg/m3"
    fi

    UNIT_CO2="ppm"
    UNIT_HUMIDITY="%"

    if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
        UNIT_DEGREE="°"
    else
        UNIT_DEGREE="deg"
    fi

}