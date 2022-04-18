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

UNIT_LIGHT_LUX=0
UNIT_LIGHT_WATTM2=1

UNIT_UNICODE_CELCIUS="℃"
UNIT_UNICODE_FARENHEIT="℉"
UNIT_UNICODE_WIND_MPS="m/s"
UNIT_UNICODE_PRESSURE_HPA="hPa"
UNIT_UNICODE_RAIN_MM="mm"
UNIT_UNICODE_LIGHT_LUX="㏓"
UNIT_UNICODE_M2="㎡"
UNIT_UNICODE_WINDDIRECTION="°"

setLightMode()
# $1 mode
# export 
{
    UNIT_LIGHT_MODE=$1

    if [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_LUX" ]; then
        if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ] ; then
            LIVEDATAUNIT_SOLAR_LIGHT=$UNIT_UNICODE_LIGHT_LUX
        else
            LIVEDATAUNIT_SOLAR_LIGHT="lux"
        fi
    elif [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_WATTM2" ]; then
        if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ] ; then
            LIVEDATAUNIT_SOLAR_LIGHT="W/"$UNIT_UNICODE_M2
        else
            LIVEDATAUNIT_SOLAR_LIGHT="W/m2"
        fi
    fi

    export LIVEDATAUNIT_SOLAR_LIGHT

    if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ] ; then
        LIVEDATAUINT_SOLAR_UV="µW/$UNIT_UNICODE_M2"
    else
        LIVEDATAUINT_SOLAR_UV="µW/m2"
    fi

    export LIVEDATAUINT_SOLAR_UV

    [ "$DEBUG" -eq 1 ] && >&2 echo Unit solar radiation: $LIVEDATAUNIT_SOLAR_LIGHT uv: $LIVEDATAUINT_SOLAR_UV


}

setWindMode()
# $1 mode
# export LIVEDATAUNIT_WIND
{
    UNIT_WIND_MODE=$1

    if [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_MPH" ]; then 
          LIVEDATAUNIT_WIND="mph"
       
    elif [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_MPS" ]; then
         LIVEDATAUNIT_WIND=$UNIT_UNICODE_WIND_MPS
    elif [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_KMH" ]; then
         LIVEDATAUNIT_WIND="km/$UNIT_HOUR"
    fi

    export LIVEDATAUNIT_WIND
    
    [ "$DEBUG" -eq 1 ] && >&2 echo Unit wind : "$LIVEDATAUNIT_WIND"

}

setTemperatureMode()
#$1 - mode
# export LIVEDATAUNIT_TEMP
{
    UNIT_TEMPERATURE_MODE=$1

    if [ "$UNIT_TEMPERATURE_MODE" -eq "$UNIT_TEMPERATURE_CELCIUS" ]; then 
        if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ] ; then
            LIVEDATAUNIT_TEMP="$UNIT_UNICODE_CELCIUS " # append 1 space -> otherwise styling is only on the first byte of unicode character; unicode : \xe2\x84\x83
        else
            LIVEDATAUNIT_TEMP="C"
        fi
       
    elif [ "$UNIT_TEMPERATURE_MODE" -eq "$UNIT_TEMPERATURE_FARENHEIT" ]; then
        if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ] ; then
            LIVEDATAUNIT_TEMP="$UNIT_UNICODE_FARENHEIT "
        else
            LIVEDATAUNIT_TEMP="F"
        fi
    fi

    export LIVEDATAUNIT_TEMP
    
    [ "$DEBUG" -eq 1 ] && >&2 echo Unit temperature : $LIVEDATAUNIT_TEMP

}

setPressureMode()
# $1 pressure mode
# export LIVEDATAUNIT_PRESSURE
{
    UNIT_PRESSURE_MODE=$1

    if  [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_HPA" ]; then

        if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
             LIVEDATAUNIT_PRESSURE=$UNIT_UNICODE_PRESSURE_HPA
        else
                 LIVEDATAUNIT_PRESSURE="hPa"
        fi
        
    elif [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_INHG" ]; then
        LIVEDATAUNIT_PRESSURE="inHg"
    fi

    export LIVEDATAUNIT_PRESSURE

    [ "$DEBUG" -eq 1 ] && >&2 echo Unit pressure : $LIVEDATAUNIT_PRESSURE

}

setRainMode()
# $1 rain mode
# export LIVEDATAUNIT_RAIN LIVEDATAUNIT_RAINRATE
{
    UNIT_RAIN_MODE=$1

    if  [ "$UNIT_RAIN_MODE" -eq "$UNIT_RAIN_MM" ]; then
        LIVEDATAUNIT_RAIN=$UNIT_UNICODE_RAIN_MM
    elif [ "$UNIT_RAIN_MODE" -eq "$UNIT_RAIN_IN" ]; then
        LIVEDATAUNIT_RAIN="in"
    fi

    export LIVEDATAUNIT_RAIN
    UNIT_HOUR=${UNIT_HOUR:="h"}
    export LIVEDATAUNIT_RAINRATE=$LIVEDATAUNIT_RAIN"/$UNIT_HOUR"

    [ "$DEBUG" -eq 1 ] && >&2 echo Unit rain rainrate : $LIVEDATAUNIT_RAIN "$LIVEDATAUNIT_RAINRATE"
    
}

initUnit()
# export LIVEDATAUNIT_PM25 LIVEDATAUNIT_CO2="ppm" LIVEDATAUNIT_HUMIDITY="%" LIVEDATAUNIT_WIND_DIRECTION
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

    if [ -z "$UNIT_LIGHT_MODE" ]; then
        setLightMode $UNIT_LIGHT_WATTM2 #default
    else
        setLightMode "$UNIT_LIGHT_MODE"
    fi

    if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ] ; then
        LIVEDATAUNIT_PM25="µg/㎥"
    else
        LIVEDATAUNIT_PM25="µg/m3"
    fi

    export LIVEDATAUNIT_PM25 LIVEDATAUNIT_CO2="ppm"
    export LIVEDATAUNIT_HUMIDITY="%" 
    export LIVEDATAUNIT_WIND_DIRECTION

    if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ] ; then
        LIVEDATAUNIT_WIND_DIRECTION=$UNIT_UNICODE_WINDDIRECTION
    else
        LIVEDATAUNIT_WIND_DIRECTION="deg"
    fi

    #set | grep LIVEDATAUNIT

}