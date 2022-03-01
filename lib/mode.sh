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

setLightMode()
# $1 mode
# export 
{
    UNIT_LIGHT_MODE=$1

    if [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_LUX" ]; then
        if [ "$SHELL_SUPPORT_UNICODE" ]; then
            LIVEDATA_SOLAR_LIGHT_UNIT=$UNIT_UNICODE_LIGHT_LUX
        else
            LIVEDATA_SOLAR_LIGHT_UNIT="lux"
        fi
    elif [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_WATTM2" ]; then
        if [ "$SHELL_SUPPORT_UNICODE" ]; then
            LIVEDATA_SOLAR_LIGHT_UNIT="W/"$UNIT_UNICODE_M2
        else
            LIVEDATA_SOLAR_LIGHT_UNIT="W/m2"
        fi
    fi

    export LIVEDATA_SOLAR_LIGHT_UNIT

    if [ "$SHELL_SUPPORT_UNICODE" ]; then
        LIVEDATA_SOLAR_LIGHT_UV_UNIT="µW/$UNIT_UNICODE_M2"
    else
        LIVEDATA_SOLAR_LIGHT_UV_UNIT="µW/m2"
    fi

    export LIVEDATA_SOLAR_LIGHT_UV_UNIT

    [ "$DEBUG" -eq 1 ] && >&2 echo Unit solar radiation: $LIVEDATA_SOLAR_LIGHT_UNIT uv: $LIVEDATA_SOLAR_LIGHT_UV_UNIT


}

setWindMode()
# $1 mode
# export LIVEDATA_WIND_UNIT
{
    UNIT_WIND_MODE=$1

    if [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_MPH" ]; then 
          LIVEDATA_WIND_UNIT="mph"
       
    elif [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_MPS" ]; then
         LIVEDATA_WIND_UNIT=$UNIT_UNICODE_WIND_MPS
    elif [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_KMH" ]; then
         LIVEDATA_WIND_UNIT="km/$UNIT_HOUR"
    fi

    export LIVEDATA_WIND_UNIT
    
    [ "$DEBUG" -eq 1 ] && >&2 echo Unit wind : "$LIVEDATA_WIND_UNIT"

}

setTemperatureMode()
#$1 - mode
# export LIVEDATA_TEMP_UNIT
{
    UNIT_TEMPERATURE_MODE=$1

    if [ "$UNIT_TEMPERATURE_MODE" -eq "$UNIT_TEMPERATURE_CELCIUS" ]; then 
        if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
            LIVEDATA_TEMP_UNIT=$UNIT_UNICODE_CELCIUS
        else
            LIVEDATA_TEMP_UNIT="C"
        fi
       
    elif [ "$UNIT_TEMPERATURE_MODE" -eq "$UNIT_TEMPERATURE_FARENHEIT" ]; then
        if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
            LIVEDATA_TEMP_UNIT=$UNIT_UNICODE_FARENHEIT
        else
            LIVEDATA_TEMP_UNIT="F"
        fi
    fi

    export LIVEDATA_TEMP_UNIT
    
    [ "$DEBUG" -eq 1 ] && >&2 echo Unit temperature : $LIVEDATA_TEMP_UNIT

}

setPressureMode()
# $1 pressure mode
# export LIVEDATA_PRESSURE_UNIT
{
    UNIT_PRESSURE_MODE=$1

    if  [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_HPA" ]; then
        LIVEDATA_PRESSURE_UNIT=$UNIT_UNICODE_PRESSURE_HPA
    elif [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_INHG" ]; then
        LIVEDATA_PRESSURE_UNIT="inHg"
    fi

    export LIVEDATA_PRESSURE_UNIT

    [ "$DEBUG" -eq 1 ] && >&2 echo Unit pressure : $LIVEDATA_PRESSURE_UNIT

}

setRainMode()
# $1 rain mode
# export LIVEDATA_RAIN_UNIT LIVEDATA_RAINRATE_UNIT
{
    UNIT_RAIN_MODE=$1

    if  [ "$UNIT_RAIN_MODE" -eq "$UNIT_RAIN_MM" ]; then
        LIVEDATA_RAIN_UNIT=$UNIT_UNICODE_RAIN_MM
    elif [ "$UNIT_RAIN_MODE" -eq "$UNIT_RAIN_IN" ]; then
        LIVEDATA_RAIN_UNIT="in"
    fi

    export LIVEDATA_RAIN_UNIT
    UNIT_HOUR=${UNIT_HOUR:="h"}
    export LIVEDATA_RAINRATE_UNIT=$LIVEDATA_RAIN_UNIT"/$UNIT_HOUR"


    [ "$DEBUG" -eq 1 ] && >&2 echo Unit rain rainrate : $LIVEDATA_RAIN_UNIT "$LIVEDATA_RAINRATE_UNIT"
    
}

initUnit()
# export LIVEDATA_PM25_UNIT LIVEDATA_WH45CO2_UNIT="ppm" LIVEDATA_HUMIDITY_UNIT="%" LIVEDATA_WIND_DEGREE_UNIT
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

    if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
        LIVEDATA_PM25_UNIT="µg/㎥"
    else
        LIVEDATA_PM25_UNIT="µg/m3"
    fi

    export LIVEDATA_PM25_UNIT LIVEDATA_WH45CO2_UNIT="ppm" LIVEDATA_HUMIDITY_UNIT="%" LIVEDATA_WIND_DEGREE_UNIT

    if [ "$SHELL_SUPPORT_UNICODE" -eq 1 ]; then
        LIVEDATA_WIND_DEGREE_UNIT=$UNIT_UNICODE_WINDDIRECTION
    else
        LIVEDATA_WIND_DEGREE_UNIT="deg"
    fi

}