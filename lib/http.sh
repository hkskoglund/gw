#!/bin/sh

httpServer()
#$1 - port number 
{
    EXITCODE_HTTPSERVER=0
    DEBUG_HTTPSERVER=${DEBUG_HTTPSERVER:=$DEBUG}
    DEBUG_FUNC="httpServer"

    [ "$DEBUG_HTTPSERVER" -eq 1 ] && >&2 echo $DEBUG_FUNC: Listening on port "$1"

    if [ "$NC_VERSION" = "$NC_NMAP" ]; then 
        http_message=$("$NC_CMD" -l -i 0.1 "$1" 2>/dev/null) # - idle timeout to exit early, not waiting for client to close/FIN
        EXITCODE_HTTPSERVER=$? 
        if [ "$EXITCODE_HTTPSERVER" -eq 2 ]; then
          EXITCODE_HTTPSERVER=0 # 2 exit from nc when idle timeout expires (Ncat: Idle timeout expired (100 ms). QUITTING.)
        fi
    elif [ "$NC_VERSION" = "$NC_OPENBSD" ]; then
        http_message=$("$NC_CMD" -l -w 1 "$1" 2>/dev/null) # - -w to exit on idle for 1s
        EXITCODE_HTTPSERVER=$?
    elif [ "$NC_VERSION" = "$NC_TOYBOX" ]; then 
        http_message=$("$NC_CMD" -p "$1" -W 1 -l  2>/dev/null) # - -W to exit on idle for 1s
        EXITCODE_HTTPSERVER=$?
    else
        echo >&2 Error: Listen unsupported for nc version "$NC_VERSION"
        EXITCODE_HTTPSERVER=$ERROR_LISTEN_UNSUPPORTED_NC
    fi

    if [ -z "$http_message" ]; then
        [ "$DEBUG_HTTPSERVER" -eq 1 ] && echo >&2 $DEBUG_FUNC: Empty http message from nc
        return "$ERROR_HTTP_MESSSAGE_EMPTY"
    fi

    if [ -n "$DEBUG_OPTION_HTTP" ]; then
        if  [ "$DEBUG_OPTION_HTTP" -eq 1  ] ; then
            echo >&2 "$http_message"
        fi
    fi
    
    case "$http_message" in
        
        POST*tempinf*)  parseEcowittHttpRequest "$http_message"
                
                #https://stackoverflow.com/a/69836872/2076536
                ;;
        
        GET*tempf*)   parseWundergroundHttpReqest "$http_message"
                #cd /tmp/gw/wunderground; watch -n 16 'for f in *; do read v < "$f"; printf "%-30s %s\n" "$f" "$v"; done'
                ;;
        *) echo >&2 Error: Unable to parse "$http_message" #maybe add csv/json response on request?
           ;;
    esac

    unset http_message DEBUG_HTTPSERVER
    
    return "$EXITCODE_HTTPSERVER"
}

parseHttpHeader()
{
    [ "$DEBUG" -eq 1 ] &&  echo >&2 "parseHttpHeader $1"
    
    IFS=: read -r HTTP_KEY HTTP_VALUE <<EOH
$1
EOH
   #echo "KEY $HTTP_KEY VALUE $HTTP_VALUE"
    case $HTTP_KEY in
        *-*) 
                IFS=-
                #shellcheck disable=SC2086
                set -- $HTTP_KEY
                #echo KEY PART1 "$1" KEY PART2 "$2"
                toLowercase "$1"
                HTTP_KEY_PART1=$VALUE_LOWERCASE
                toLowercase "$2"
                HTTP_KEY_PART2=$VALUE_LOWERCASE
                eval "HTTP_HEADER_${HTTP_KEY_PART1}_$HTTP_KEY_PART2=${HTTP_VALUE# }"
                ;;
        *)         
                toLowercase "$HTTP_KEY"
                HTTP_KEY=$VALUE_LOWERCASE
                eval "HTTP_HEADER_$HTTP_KEY=${HTTP_VALUE# }" # trim 1 leading space
               ;;
    esac

    unset HTTP_KEY HTTP_VALUE
   #IFS=- set -- $HTTP_KEY
}

parseHttpLines()
{
    #http://mywiki.wooledge.org/BashFAQ/001
    N=0
    NBODY=0 #line number to body
    while eval IFS= read -r HTTP_LINE$((N + 1)); do
        N=$(( N + 1 ))
        [ $NBODY -eq 0 ] && eval HTTP_LINE$N="\${HTTP_LINE$N%?}" # remove trailing \r (\n removed by read), do not touch body
        eval "if [ \"\${#HTTP_LINE$N}\" -eq 0 ]; then NBODY=$((N + 1 )); fi" 
      [ "$DEBUG" -eq 1 ] &&  eval echo >&2 HTTP LINE $N \"\$HTTP_LINE$N\"
    done <<EOF
$1
EOF

     if [ -n "$HTTP_LINE1" ]; then
           #shellcheck disable=SC2034
           IFS=' ' read -r HTTP_METHOD HTTP_URL HTTP_VERSION <<EOL
$HTTP_LINE1
EOL
    fi

    if [ "$NBODY" -gt 2 ]; then
        eval HTTP_BODY="\$HTTP_LINE$NBODY"
        IFS=' '
        for linenr in $(seq -s ' ' 2 $(( NBODY - 2 )) ); do
            eval parseHttpHeader \"\$HTTP_LINE"$linenr"\"
        done
        unset linenr
    fi
}

setHttpBatteryState()
# determine low battery 
# $1 value x.xx format
# set VALUE_BATTERY_STATE
{
     getFloatAsIntDecmial "$value" # 3.20 format
                
    if [ "$FLOAT_AS_INT" -le $(( BATTERY_VOLTAGE_LOW * 10 * 2 )) ]; then # [ -le 240]
        appendLowBatteryState
    else
        appendBatteryState
    fi
}

parseEcowittHttpRequest()
#$1 - http request message (entire)
{
    DEBUG_HTTP=${DEBUG_HTTP:=$DEBUG}

    parseHttpLines "$1"

    export LIVEDATA_SYSTEM_PROTOCOL="$LIVEDATA_PROTOCOL_ECOWITT_HTTP"
    export LIVEDATA_SYSTEM_PROTOCOL_LONG="$LIVEDATA_PROTOCOL_ECOWITT_HTTP_LONG"
    export LIVEDATA_SYSTEM_PROTOCOL_VERSION="$HTTP_VERSION"
    
    [ "$DEBUG_HTTP" -eq 1 ] && printf "HTTP BODY\n%s\n" "$HTTP_BODY"
    IFS='&'
    
    for f in $HTTP_BODY; do
        
        value=${f##*=}  # remove largest prefix pattern
        key=${f%%=*}    # remove largest suffix pattern
        [ "$DEBUG_HTTP" -eq  1 ] && echo >&2 "Parsing ecowitt http key: $key value: $value" 
        
        case "$key" in

           PASSKEY) ;;

            tempinf)
                   setTemperatureHttpLivedata LIVEDATA_INTEMP "$value" 
                  
                ;;

            tempf)
                    setTemperatureHttpLivedata LIVEDATA_OUTTEMP "$value"
                ;;

            humidityin)

                export LIVEDATA_INHUMI="$value"
                ;;

            humidity)
                
                 export LIVEDATA_OUTHUMI="$value"
                ;;

            baromrelin)
                
                setPressureHttpLivedata LIVEDATA_PRESSURE_RELBARO "$value"
                ;;

            baromabsin)

                setPressureHttpLivedata LIVEDATA_PRESSURE_ABSBARO "$value"
                    ;;

            temp?f)
            
                channel=${key##temp}
                channel=${channel%f}
                setTemperatureHttpLivedata LIVEDATA_TEMP"$channel" "$value" 
                ;;

            humidity?)

                channel=${key##humidity}
                eval export LIVEDATA_HUMI"$channel"="$value"
                ;;
            
            winddir)

                    setWindDirHttpLivedata LIVEDATA_WINDDIRECTION "$value"
                ;;

            windspeedmph)

                setWindHttpLivedata LIVEDATA_WINDSPEED "$value"

                ;;

            windgustmph)

                setWindHttpLivedata LIVEDATA_WINDGUSTSPEED "$value"
                ;;

            maxdailygust)

                setWindHttpLivedata LIVEDATA_WINDDAILYMAX "$value"
                ;;
        
            rainratein)

                setRainHttpLivedata LIVEDATA_RAINRATE "$value"
                ;;

            eventrainin)

                setRainHttpLivedata LIVEDATA_RAINEVENT "$value"
                ;;

            hourlyrainin)

                setRainHttpLivedata LIVEDATA_RAINHOUR "$value"
                ;;

            dailyrainin)

                setRainHttpLivedata LIVEDATA_RAINDAY "$value"
                ;;

            weeklyrainin)

                setRainHttpLivedata LIVEDATA_RAINWEEK "$value"
                ;;

            monthlyrainin)
                
                setRainHttpLivedata LIVEDATA_RAINMONTH "$value" 
                ;;

            yearlyrainin)

                setRainHttpLivedata LIVEDATA_RAINYEAR "$value"
                ;;

            totalrainin)

               setRainHttpLivedata LIVEDATA_RAINTOTAL "$value"
               ;;

            soilmoisture?)

                channel=${key##soilmoisture}
                eval export LIVEDATA_SOILMOISTURE"$channel"="$value"
            ;;

            pm25_ch?)

                channel=${key##pm25_ch}
                eval export "LIVEDATA_PM25$channel=$value"
                eval export "LIVEDATA_PM25${channel}_INTS10=${value%%.?}${value##*.}"
                ;;

            pm25_avg_24h_ch?)

                channel=${key##pm25_avg_24h_ch}
                eval export "LIVEDATA_PM25${channel}_24HAVG=$value"
                eval export "LIVEDATA_PM25${channel}_24HAVG_INTS10=${value%%.?}${value##*.}"

                ;;

            leak_ch?)

                channel=${key##leak_ch}
                eval "export LIVEDATA_LEAK$channel=$value"
                ;;

            solarradiation)
            
                   setLightHttpLivedata LIVEDATA_SOLAR_LIGHT "$value"
                ;;

            uv)
                    export LIVEDATA_SOLAR_UVI="$value"
                ;;

            wh65batt)

                getBatteryLowOrNormal "$value"
                export LIVEDATASENSOR_WH65_BATTERY="$value"
                export LIVEDATASENSOR_WH65_BATTERY_STATE="$VALUE_BATTERY_STATE"
                ;;

            wh68batt)
                setHttpBatteryState "$value"
                export LIVEDATASENSOR_WH68_BATTERY="$value"
                export LIVEDATASENSOR_WH68_BATTERY_STATE="$VALUE_BATTERY_STATE${value}V"
                ;;

            wh80batt)
                setHttpBatteryState "$value"
                export LIVEDATASENSOR_WH80_BATTERY="$value"
                export LIVEDATASENSOR_WH80_BATTERY_STATE="$VALUE_BATTERY_STATE${value}V"
               ;;

            batt?)

                channel=${key##batt}
                getBatteryLowOrNormal "$value"
                eval "export LIVEDATASENSOR_TEMP${channel}_BATTERY=$value"
                eval "export LIVEDATASENSOR_TEMP${channel}_BATTERY_STATE=$VALUE_BATTERY_STATE"
                ;;

            pm25batt?)
            
                channel=${key##pm25batt}
                getBatteryLevelState "$value"
                eval "export LIVEDATASENSOR_PM25${channel}_BATTERY=$value"
                eval "export LIVEDATASENSOR_PM25${channel}_BATTERY_STATE=$VALUE_BATTERY_STATE"
                ;;

            soilbatt?)

                channel=${key##soilbatt}
                getFloatAsIntDecmial "$value"
                getBatteryVoltageScale10State "$FLOAT_AS_INT"
                
                eval "export LIVEDATASENSOR_SOILMOISTURE${channel}_BATTERY_INT=$FLOAT_AS_INT"  
                eval "export LIVEDATASENSOR_SOILMOISTURE${channel}_BATTERY=$value"
                eval "export LIVEDATASENSOR_SOILMOISTURE${channel}_BATTERY_STATE=\"$VALUE_BATTERY_STATE\""  
                ;;

            leakbatt?)
                
                channel=${key##leakbatt}
                getBatteryLevelState "$value"
                eval "export LIVEDATASENSOR_LEAK${channel}_BATTERY=$value"
                eval "export LIVEDATASENSOR_LEAK${channel}_BATTERY_STATE=\"$VALUE_BATTERY_STATE\""
                ;;

            stationtype)

                export LIVEDATA_SYSTEM_VERSION="$value"
                ;;

            dateutc)
            
                IFS=+
                #shellcheck disable=SC2086
                set -- $value
                
                export LIVEDATA_SYSTEM_UTC="$1 $2"
                ;;

            freq)

                IFS="M"
                #shellcheck disable=SC2086
                set -- $value
                export LIVEDATA_SYSTEM_FREQUENCY="$1"
                ;;

            model)
               export LIVEDATA_SYSTEM_MODEL="$value"
               ;; 

            *) echo >&2 "Warning: Unsupported key $key length ${#key} in ecowitt http request"
               [ "$DEBUG_HTTP" -eq 1 ] && printf >&2 "%s" "$key" | od -A n -t x1
               ;;
                
        esac
    done

    if [ -z "$LOG_CMD" ]; then
       printOrLogLivedata
    fi

    unset f key value
}

parseWundergroundHttpReqest()
#gw doesnt send request unless station id and station password are set
{
    DEBUG_HTTP=${DEBUG_HTTP:=$DEBUG}
   parseHttpLines "$1"

   LIVEDATA_SYSTEM_PROTOCOL=$LIVEDATA_PROTOCOL_WUNDERGROUND_HTTP
   #shellcheck disable=SC2034
   {
   LIVEDATA_SYSTEM_PROTOCOL_LONG=$LIVEDATA_PROTOCOL_WUNDERGROUND_HTTP_LONG
   LIVEDATA_SYSTEM_PROTOCOL_VERSION=$HTTP_VERSION
   }
      #https://www.w3.org/Protocols/HTTP/1.0/spec.html#Request

    #http_request=$(echo "$1" | head -n 1)
    #[ "$DEBUG" -eq 1 ] && printf "HTTP REQUEST\n%s\n" "$http_request"

   # http_request=${http_request##GET*ID=} # remove method GET and directory prefix, assume qs always starts with ID=
   # LIVEDATA_SYSTEM_PROTOCOL_VERSION=${http_request##*rtfreq=? } #assumes request always ends with rtfreq=
   # http_request=${http_request%% HTTP*} # remove HTTP/1.0 at end
    #http_request="ID="$http_request

    IFS='&'
    local_httpprefix=${HTTP_URL%ID=*}
    for f in ${HTTP_URL#"$local_httpprefix"}; do 

        value=${f##*=}
        key=${f%%=*}

       [ "$DEBUG_HTTP" -eq  1 ] && echo >&2 "Parsing wunderground http key: $key value: $value" 

            #password is url encoded, for example space=%20 https://stackoverflow.com/questions/6250698/how-to-decode-url-encoded-string-in-shell
        #TEST echo "$key=$value"

    #https://support.weather.com/s/article/PWS-Upload-Protocol?language=en_US
        case "$key" in

            PASSWORD | ID)
              ;;

            tempf)
                
                setTemperatureHttpLivedata LIVEDATA_OUTTEMP "$value"
                ;;

            dewptf)
               setTemperatureHttpLivedata LIVEDATA_DEWPOINT "$value"
               ;;
            
            windchillf)
              setTemperatureHttpLivedata LIVEDATA_WINDCHILL "$value"
              ;;
            
            humidity)
                if [ "$value" != "$WUNDERGROUND_UNDEFINED_VALUE" ]; then
                  export LIVEDATA_OUTHUMI="$value"
                fi
                ;;

            indoortempf)

                setTemperatureHttpLivedata LIVEDATA_INTEMP "$value"
                ;;
            
            indoorhumidity)

                export LIVEDATA_INHUMI="$value"
                ;;
            
            baromin)
                
                setPressureHttpLivedata LIVEDATA_PRESSURE_RELBARO "$value"
                ;;

            absbaromin)
               setPressureHttpLivedata LIVEDATA_PRESSURE_ABSBARO "$value"
               ;;

            rainin)
                #or pr hour?
                setRainHttpLivedata LIVEDATA_RAINRATE "$value" 
                ;;

            dailyrainin)

                setRainHttpLivedata LIVEDATA_RAINDAY "$value"
                ;;

            weeklyrainin)

                setRainHttpLivedata LIVEDATA_RAINWEEK "$value"
                ;;

            monthlyrainin)

                setRainHttpLivedata LIVEDATA_RAINMONTH "$value"
                ;;

            yearlyrainin)

                setRainHttpLivedata LIVEDATA_RAINYEAR "$value"
                ;;

            winddir)

                setWindDirHttpLivedata LIVEDATA_WINDDIRECTION "$value"

                ;;

            windspeedmph)

                setWindHttpLivedata LIVEDATA_WINDSPEED "$value"
                ;;

            windgustmph)

                setWindHttpLivedata LIVEDATA_WINDGUSTSPEED "$value"
                ;;

            solarradiation)
                
                 if [ "$value" != "$WUNDERGROUND_UNDEFINED_VALUE" ]; then
                   setLightHttpLivedata LIVEDATA_SOLAR_LIGHT "$value"
                fi
                ;;

            UV)
               
                 if [ "$value" != "$WUNDERGROUND_UNDEFINED_VALUE" ]; then
                     export LIVEDATA_SOLAR_UVI="$value"
                 fi
                ;;

            AqPM2\.5)
                #shellcheck disable=SC2034
                export LIVEDATA_PM251="$value"
                export LIVEDATA_PM251_INTS10="${value%%.?}${value##*.}"
                ;;

            soilmoisture)
                #shellcheck disable=SC2034
                export LIVEDATA_SOILMOISTURE1="$value"
                ;;

            soilmoisture?)

                channel=${key##soilmoisture}
                eval export LIVEDATA_SOILMOISTURE"$channel"="$value"
                ;;

            softwaretype)
            
               export LIVEDATA_SYSTEM_VERSION="$value"
               ;;

            lowbatt|action|realtime|rtfreq)
               : # silently discard, dateutc=now with EasyWeather fw 1.6.0
               ;;

            dateutc)
               #Easyweather fw 1.6.1
               #format 2021-12-16%2008:52:24
               case "$value" in
                    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]%20[0-9][0-9]:[0-9][0-9]:[0-9][0-9])
                        export LIVEDATA_SYSTEM_UTC="${value%\%20*} ${value#*%20}"
                        ;;
               esac
               ;;

            *) echo >&2 "Warning: Unsupported $key length ${#key} in wunderground http request"
               ;;

        esac
    done

    if [ -z "$LOG_CMD" ]; then
        printOrLogLivedata
    fi

    unset http_request f key value local_httpprefix
}
