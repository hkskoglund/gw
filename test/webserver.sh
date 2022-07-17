#!/bin/sh
#https://www.my-tiny.net/L19-netcat.htm

HTTP_RESPONSE_200_OK="200" # https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/200
HTTP_RESPONSE_404_NOTFOUND="404"
HTTP_RESPONSE_501_NOTIMPLEMENTED="501"

# https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
MIME_TYPE_TEXT="text" 
MIME_PARAM_CHARSET_UTF8="charset=utf-8" # charset can be set optionally only for text, https://www.w3.org/International/articles/http-charset/index
MIME_TYPE_APPLICATION="application"
MIME_TYPE_IMAGE="image"
MIME_SUBTYPE_PLAIN="plain"
MIME_SUBTYPE_HTML="html"
MIME_SUBTYPE_JAVASCRIPT="javascript"
MIME_SUBTYPE_JSON="json"
MIME_SUBTYPE_CSS="css"
MIME_SUBTYPE_PNG="png"

if [ -n "$ZSH_VERSION" ]; then
    #https://zsh.sourceforge.io/FAQ/zshfaq03.html
       setopt shwordsplit  #zsh compability for "1 2 3" -> split in 1 2 3
    fi

. ../lib/appendBuffer.sh
. ../lib/http.sh
. ../lib/util.sh

sendHttpError404NotFound()
{
    appendHttpResponseCodeMessage $HTTP_RESPONSE_404_NOTFOUND "$1"
    appendHttpDefaultHeaders
    logErr "$HTTP_RESPONSE_HEADER_DATE_VALUE Error: $1"
}

sendHttpTextPlain()
{
    ltextplain="$1"
     getUnicodeStringLength "$ltextplain"
    appendHttpResponseHeader "Content-Type" "$MIME_TYPE_TEXT/$MIME_SUBTYPE_PLAIN;$MIME_PARAM_CHARSET_UTF8"
    ltextplain_length=$(( VALUE_UNICODE_STRING_LENGTH + 2)) # 2=CRLF
    appendHttpResponseHeader "Content-Length" "$ltextplain_length" 
    appendHttpResponseCRLF
    
    if [ "$HTTP_REQUEST_METHOD" = "GET" ]; then 
        appendHttpResponseBody "$ltextplain"
        appendHttpResponseCRLF
        logErr "Sending text plain length: $ltextplain_length"
    fi
    
    sendHttpResponse

    unset ltextplain ltextplain_length
}

sendHttpResponse()
{
    #shellcheck disable=SC2119
    printAppendBuffer
}

appendHttpResponseHeader()
{
    appendBuffer "%s: %s\r\n" "'$1' '$2'"
}

appendHttpDefaultHeaders()
{
    HTTP_RESPONSE_HEADER_DATE_VALUE=$(date -R)
    appendHttpResponseHeader "Date" "$HTTP_RESPONSE_HEADER_DATE_VALUE"
    #https://httpwg.org/specs/rfc7231.html#http.date
    appendHttpResponseHeader "Server" "gw"
}

appendHttpResponseCRLF()
{
    appendFormat "\r\n"
}

appendHttpResponseCodeMessage()
# $1 code
# $2 message
{
    if [ -z "$2" ]; then
        appendBuffer "HTTP/1.1 %s\r\n" "'$1'"
    else
        appendBuffer "HTTP/1.1 %s %s\r\n" "'$1' '$2'"
    fi
}

appendHttpResponseBody()
{
    appendBuffer "%s" "'$1'"
}

resetHttpResponse()
{
    resetAppendBuffer
}

sendHttpResponseCode()
{
    logErr "sending response: $1"
    appendHttpResponseCodeMessage "$1"
    appendHttpDefaultHeaders
    appendHttpResponseHeader "Content-Length" "0"
    appendHttpResponseCRLF
    sendHttpResponse
}

getFilesize()
# $1 filename
{
    VALUE_FILESIZE=$(stat -c %s "$1")
}

getUnicodeStringLength()
# $1 unicode string
# ${#S} does not count number of bytes in string when sent as json
# zsh/bash affected
{
    #printf "%s" "$1" | od -A n -t x1 >&2
    VALUE_UNICODE_STRING_LENGTH=$(printf "%s" "$1" | od -A n -t x1 |  wc -w)
}

getHostFromQS()
# $1 default value
{
    if [ -n "$HTTP_QUERY_STRING_ip" ]; then
        #echo >&2 QS ip="$HTTP_QUERY_STRING_ip"
        lip="$HTTP_QUERY_STRING_ip"
    else
        lip="$1"
    fi
    VALUE_HOST=$lip
    unset lip
}

sendFile()
# $1 directory, $2 file
{
     set -x
     if [ -z "$2" ]; then 
        l_file=${HTTP_REQUEST_ABSPATH##*/}
    else
       l_file="$2"
    fi
    if [ -z "$1" ]; then
        l_dir=${HTTP_REQUEST_ABSPATH%"$l_file"}
    else
      l_dir="$1"
      fi

    l_server_file="$HTTP_SERVER_ROOT$l_dir$l_file"

    set +x

    if [ -s "$l_server_file" ]; then
            appendHttpResponseCodeMessage "$HTTP_RESPONSE_200_OK"
            appendHttpDefaultHeaders
            case "$HTTP_REQUEST_ABSPATH" in
                *".js")     appendHttpResponseHeader "Content-Type" "$MIME_TYPE_TEXT/$MIME_SUBTYPE_JAVASCRIPT;$MIME_PARAM_CHARSET_UTF8"
                            ;;
                *".css")    appendHttpResponseHeader "Content-Type" "$MIME_TYPE_TEXT/$MIME_SUBTYPE_CSS;$MIME_PARAM_CHARSET_UTF8"
                            ;;
                *".html")   appendHttpResponseHeader "Content-Type" "$MIME_TYPE_TEXT/$MIME_SUBTYPE_HTML;$MIME_PARAM_CHARSET_UTF8"
                            ;;
                *".png"|*radar_nowcast) appendHttpResponseHeader "Content-Type" "$MIME_TYPE_IMAGE/$MIME_SUBTYPE_PNG"
                            ;;  
                esac
            getFilesize "$l_server_file"
            appendHttpResponseHeader "Content-Length" "$VALUE_FILESIZE"
            appendHttpResponseCRLF
            sendHttpResponse
                    # --head = only request headers
                    # curl -v --head  192.168.3.3:8000/lib/highcharts-v309.src.js
            if [ "$HTTP_REQUEST_METHOD" = "GET" ]; then 
                logErr "webserver: sending file $l_server_file, length $VALUE_FILESIZE"
                cat "$l_server_file"
            fi 
    else
        sendHttpError404NotFound "$l_server_file"
    fi
    
    unset l_file l_dir l_server_file
}

sendJSON()
#$1 JSON string
{
    getUnicodeStringLength "$1"
                                            
    appendHttpResponseHeader "Content-Type" "$MIME_TYPE_APPLICATION/$MIME_SUBTYPE_JSON" 
    appendHttpResponseHeader "Content-Length" "$VALUE_UNICODE_STRING_LENGTH"
    #https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
    # for cross-origin request: 127.0.0.1:3000 Live Preview visual studio code -> webserver localhost:8000
    appendHttpResponseHeader "Access-Control-Allow-Origin" "*"
    appendHttpResponseCRLF
    if [ "$HTTP_REQUEST_METHOD" = "GET" ]; then 
        appendHttpResponseBody "$1"
        logErr "Sending JSON length: $VALUE_UNICODE_STRING_LENGTH"
    fi

    sendHttpResponse
}

sendMETnoRequest()
{
    sendRequest "$1" "2c6cf1d9-b949-4f64-af83-0cb4d881658a" ""
}

sendRequest()
# $1 http request url, $2 username optional, $3 password
{
        appendHttpResponseCodeMessage "$HTTP_RESPONSE_200_OK"
        appendHttpDefaultHeaders
        #using basic authentication with -u/new user must be registered at frost.met.no, -s turns off progress metering
        set -x
        l_user="$2"
        l_password="$3"
        if [ -n "$l_user" ]; then 
            l_response_JSON=$( curl -v -s -u "$l_user:$l_password" "$1" );
            l_exitcode=$?
        else
             l_response_JSON=$( curl -v -s "$1" );
             l_exitcode=$?
        fi

        set +x
        if [ $l_exitcode -gt 0 ]; then
            l_response_JSON='{ "exitcode": '$l_exitcode' }'
        fi
        
        sendJSON "$l_response_JSON"

        #problem WSL2: stty: 'standard input': Inappropriate ioctl for device
        unset l_response_JSON l_exitcode l_user l_password
}

getDateNearest5Minute()
# $1 UTC date 2022-06-27T14:00:00Z
# set VALUE_DATE_NEAREST5MIN
# round minutes to nearest 5 minute interval
{
     l_date_next5min=$( date -d "$1 + 5 minutes" --utc +%FT%H ) # in case day, hour wrap
    IFS=:
    #shellcheck disable=SC2086
    set -- $1
    l_minute=${2#0} # remove 0 prefix, otherwise octal base
    l_modulo=$(( l_minute % 5 ))
    if [ $l_modulo -le 2 ] && [ "$l_minute" -ge 5 ]; then
        l_nearest5min=$(( l_minute -  l_modulo % 5 ))
    elif [ $l_modulo -gt 2 ] && [ "$l_minute" -ge 5 ]; then
        l_nearest5min=$(( l_minute + 5 - (l_minute+5) % 5  ))
    elif [ $l_modulo -le 2 ] && [ "$l_minute" -le 2 ]; then
        l_nearest5min=$(( l_minute -  l_modulo % 5 ))
    elif [ $l_modulo -gt 2 ] && [ "$l_minute" -gt 2 ]; then
        l_nearest5min=$(( l_minute + 5 - (l_minute+5) % 5  ))
    fi

    if [ $l_nearest5min -eq 60 ]; then
       VALUE_DATE_NEAREST5MIN="$l_date_next5min:00:00Z"
    else
      if [ $l_nearest5min -le 9 ]; then
        l_nearest5min="0$l_nearest5min" #reinsert prefix
      fi

      VALUE_DATE_NEAREST5MIN="$1:$l_nearest5min:00Z"
    fi

    unset l_minute l_modulo l_date_next5min l_nearest5min
}

webserver()
# process runs in a subshell (function call in end of pipeline), pid can be accessed by $BASHPID/$$ is invoking shell, pstree -pal gives overview
{
    # read request and headers including newline. read strips off LF=\n at the end of line -> only check for CR=\r
    
        l_received=0

        while IFS=" " read -r l_http_request_line; do

           logErr "> $l_http_request_line" 
            
            l_received=$(( l_received + 1 ))
        
            eval HTTP_LINE$l_received=\'"$l_http_request_line"\'

            if [ "$l_http_request_line" = "$CR" ]; then # request and headers read
               # echo >&2 "> CRLF/empty line"
                break 
            fi
            
        done

       # set | grep HTTP >&2

        parseHttpRequestLine "$HTTP_LINE1"

        ln=2
        while [ $ln -le $(( l_received - 1 )) ]; do
            eval parseHttpHeader \"\$HTTP_LINE$ln\"
            ln=$(( ln + 1 ))
        done

 
        case "$HTTP_REQUEST_METHOD" in

            GET|HEAD)   case "$HTTP_REQUEST_ABSPATH" in

                            /)        HTTP_REQUEST_ABSPATH="/index.html"
                                    sendFile
                                                    ;;

                            /api)              #using same JSON format as github api to describe api 
                                            # echo "console.log(JSON.parse('$(curl -s https://api.github.com)'))" | node 
                                            appendHttpResponseCodeMessage "$HTTP_RESPONSE_200_OK"
                                            appendHttpDefaultHeaders
                                            #adding newline \n inside string by breaking line
                                            #shellcheck disable=SC2154
                                            l_response_JSON='{
    "livedata_url": "http://'"$HTTP_HEADER_host"'/api/livedata",
    "frostmetno_latest_url": "http://'"$HTTP_HEADER_host"'/api/frost.met.no/latest-hour",
    "frostmetno_latest_10min_url": "http://'"$HTTP_HEADER_host"'/api/frost.met.no/latest-10min",
    "frostmetno_url": "http://'"$HTTP_HEADER_host"'/api/frost.met.no{/path}",
    "radar_nowcast_url": "http://'"$HTTP_HEADER_host"'/api/radar_nowcast"
    

}
'
                                        sendJSON "$l_response_JSON"
                                        unset l_response_JSON
                                        ;;
                                

                            /api/livedata|/api/livedata\?*)      

                                        appendHttpResponseCodeMessage "$HTTP_RESPONSE_200_OK"
                                        appendHttpDefaultHeaders

                                        # shellcheck disable=SC2154
                                        case "$HTTP_HEADER_accept" in
                                            
                                            *application/json*)

                                                getHostFromQS "192.168.3.16"
                                                //getHostFromQS "192.168.5.7"


                                                #l_response_JSON=$( cd .. ; timeout 20 ./gw -v json -l 8016 )
                                                set -x
                                               l_response_JSON=$( cd .. ; ./gw -g "$VALUE_HOST" -v json -c l );
                                                l_exitcode_livedata=$?
                                               set +x
                                               if [ $l_exitcode_livedata -gt 0 ]; then
                                                    l_response_JSON='{ "exitcode": '$l_exitcode_livedata' }'
                                               fi
                                               
                                              sendJSON "$l_response_JSON"

                                                #problem WSL2: stty: 'standard input': Inappropriate ioctl for device
                                                unset l_response_JSON l_exitcode_livedata
                                                
                                                ;;
                                            
                                            *text/plain*|*)

                                             getHostFromQS "192.168.3.16"
                                                ltextplain=$( cd .. ; ./gw -g "$VALUE_HOST" -c l )
                                                l_exitcode_livedata=$?
                                                
                                                if [ $l_exitcode_livedata -gt 0 ]; then
                                                    ltextplain="No response from $VALUE_HOST, exitcode : $l_exitcode_livedata"
                                                fi
                                                
                                                sendHttpTextPlain "$ltextplain"

                                                unset ltextplain l_exitcode_livedata
                                                ;;
                                        esac
                                    ;;

                                        
                        *".js"|*".css"|*".html"|*".png") sendFile 
                                        ;;

                        /api/frost.met.no/latest-1H)

                                # ipad1 does not have updated security certificates to access frost.met.no directly with XmlHttpRequest, using this endpoint allows curl to get the data
                                # query can be built using https://seklima.met.no/ -> developer tools "Network" pane

                                l_sources=SN90450
                                #l_sources=SN87640
                                l_elements="air_pressure_at_sea_level,relative_humidity,surface_snow_thickness"
                                l_timeresolution="PT1H"
                                l_referencetime=latest

                                sendMETnoRequest "https://frost.met.no/observations/v0.jsonld?elements=$l_elements&referencetime=$l_referencetime&sources=$l_sources&timeresolutions=$l_timeresolution&timeoffsets=PT0H"

                                unset l_sources l_elements l_timeresolution
                               
                                ;;

                        /api/frost.met.no/latest)

                               # https://web.postman.co/workspace/Test-av-frost%2Frim-MET~2bc0415b-9a14-431a-84ff-ad0748f8adae/request/21055109-f182896f-5ca9-484f-874f-91b2c594e624
                               
                               l_sources=SN90450
                               #l_sources=SN87640
                               l_timeresolution="PT1M,PT10M,PT1H"
                               #l_elements='mean(surface_downwelling_shortwave_flux_in_air%20PT1M),air_temperature,wind_speed,max(wind_speed_of_gust%20PT10M),wind_from_direction'
                                l_elements='air_temperature,wind_speed,max(wind_speed_of_gust%20PT10M),wind_from_direction,air_pressure_at_sea_level,relative_humidity,mean(surface_downwelling_shortwave_flux_in_air%20PT1M),surface_snow_thickness'
                               # latest mean(surface_downwelling_shortwave_flux_in_air%20PT1M) seems to be updated in intervals of about 15 minutes
                               l_referencetime="latest"
                               #l_referencetime_start=$(date -d "15 minutes ago" --utc +%FT%TZ)
                               #l_referencetime_end=$(date --utc +%FT%TZ)
                               #l_referencetime="$l_referencetime_start/$l_referencetime_end"
                               l_request="https://frost.met.no/observations/v0.jsonld?elements=$l_elements&referencetime=$l_referencetime&sources=$l_sources&timeresolutions=$l_timeresolution"
                                echo >&2 Sending request "$l_request"

                               sendMETnoRequest "$l_request"

                               unset l_sources l_timeresolution l_elements l_referencetime l_referencetime_start l_referencetime_end l_request
                               ;;

                        /api/frost.met.no/*)

                                # runs request as specified
                                appendHttpResponseCodeMessage "$HTTP_RESPONSE_200_OK"
                                appendHttpDefaultHeaders
                                l_query=${HTTP_REQUEST_ABSPATH#/api/frost.met.no/}
                                sendMETnoRequest "https://frost.met.no/$l_query"
                              
                                unset l_query

                                ;;

                        /api/radar_nowcast*)
                              # precipitation radar PNG image by quering WMS (primarily reserved by yr.no service, but uses public in url and Access-Control-Allow-Origin: * header)
                              # analyzed web requests in the yr.no service and used QGIS to generate query (F12 to get request console in QGIS)
                              # Test curl '192.168.3.3/api/radar_nowcast' --output test.png
                               l_dir="/img/radar/"
                               l_serverdir="$HTTP_SERVER_ROOT$l_dir"
                               if ! [ -e "$l_serverdir" ]; then
                                   mkdir -p "$l_serverdir"
                               fi 
                               l_file="radar_nowcast.png"
                               l_fname="$l_serverdir$l_file"
                               getDateNearest5Minute "$(date --utc +%FT%TZ)"
                               l_url="https://public-wms.met.no/verportal/radar_nowcast.map?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&BBOX=1348785.417150997091,10513254.4631713666,2876190.928262108471,11374438.4631713666&CRS=EPSG:3857&WIDTH=1278&HEIGHT=720&LAYERS=background,radar_nowcast&TIME=$VALUE_DATE_NEAREST5MIN&FORMAT=image/png&TRANSPARENT=TRUE"
                               #l_url="https://public-wms.met.no/verportal/radar_nowcast.map?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&BBOX=1218784.258785837796,10455088.7090703249,2517080.593458713498,11209671.769827649&CRS=EPSG:3857&WIDTH=1257&HEIGHT=730&LAYERS=background,radar_nowcast&TIME=$VALUE_DATE_NEAREST5MIN&FORMAT=image/png&TRANSPARENT=TRUE"     
                                set -x
                                curl -s -v  --compressed --output "$l_fname" "$l_url" 
                                set +x
                                sendFile "$l_dir" "$l_file"
                               unset l_dir l_file l_fname l_url l_serverdir
                        ;;

                        /api/yr_forecastnow*)

                            # allow QS parameter location; /api/yr_forecastnow?location=
                            if [ -z  "$HTTP_QUERY_STRING_location" ]; then
                              l_location="1-305426" # default location/Tomasjord
                            else
                              l_location="$HTTP_QUERY_STRING_location"
                            fi
                            sendRequest "https://www.yr.no/api/v0/locations/$l_location/forecast/now"
                            unset l_location
                            ;;
                        
                        *)      sendHttpResponseCode "$HTTP_RESPONSE_404_NOTFOUND"
                                ;;
                    esac
                    ;;

                *)                      sendHttpResponseCode "$HTTP_RESPONSE_501_NOTIMPLEMENTED"
                                        ;;
            esac

    resetHttpHeaders
    resetHttpLines "$l_received"
    resetHttpRequest
    resetHttpResponse

    # set | grep HTTP >&2

    unset l_received l_http_request_line

}

logErr()
{
    echo >&2 "$*"
}

startwebserver()
# $1 port
# $2 root directory
# from man fifo: "The FIFO must be opened on both ends (reading and
# writing) before data can be passed.  Normally, opening  the  FIFO  blocks  until  the
# other end is opened also."
# https://en.wikipedia.org/wiki/Netcat#Performing_an_HTTP_request
# all processes in pipeline runs in same process group, commands to manage: ps -efj, kill -- -PGID, jobs, kill %+, kill %-
# https://www.baeldung.com/linux/kill-members-process-group
{
    logErr "pid: $$"

    if [ -z "$1" ]; then
        logErr "Error: No port specified for web server"
        return 1
    else
       logErr "port: $1"
    fi

    if [ -n "$2" ]; then
        if ! [ -d "$2" ]; then
            logErr "Error: $2 root is not a directory"
            return 1
        else
          #export allows child of nc with (cloned with -e option) to get it
           export HTTP_SERVER_ROOT="$2"
           logErr "rootdir: $2"
        fi
    else
       logErr "Error: no rootdir specified"
       return 1
    fi

    # nc openbsd test kernel fifo
        #   TMPFIFODIR=$(mktemp -d)
        #   GWFIFO="$TMPFIFODIR/httpfifo"
            # create kernel fifo, man fifo
        #   if mkfifo "$GWFIFO"; then
        #   echo >&2 "fifo: $GWFIFO"
        #   fi

    trap 'echo >&2 "webserver INT trap handler"; rm -rf "$TMPFIFODIR"; exit' INT # INT catches ctrl-c -> triggers exit trap handler
    #trap 'echo >&2 webserver EXIT TERM HUP trap handler; rm -rf "$TMPFIFODIR"' EXIT INT TERM HUP
    GWWEBSERVER_PORT=$1
    while true; do 
       # nc openbsd: does not work, single fifo shared with multiple sockets? {  webserver <"$GWFIFO"; }  | { nc -4 -v -l "$GWWEBSERVER_PORT" >"$GWFIFO" ; echo >&2 "nc exited error code:$?"; } 
      
      # Ncat: version 7.8 allows -e to clone new process for handling request
       nc -4 -v -k -l "$GWWEBSERVER_PORT" -e './webserver.sh' 
       EXITCODE_WEBSERVER_NC=$?
       echo >&2 "nc exited error code:$EXITCODE_WEBSERVER_NC"
    done

    # https://fedoramagazine.org/how-to-manage-network-services-with-firewall-cmd/
    # fedora: webserver port 80, must be allowed in the firewall
    #   sudo firewall-cmd --zone=FedoraWorkstation --permanent --add-port=80/tcp
    #   sudo firewall-cmd --list-all
    # Process must run with root/sudo for nc to bind to port 0.0.0.0:80

    # wsl2: open tcp port 80 in firewall (inbound rules) in Private profile
    #   setup portproxy: iex "netsh interface portproxy add v4tov4 listenaddress=(Get-NetIPAddress -InterfaceAlias Wi-Fi -AddressFamily IPv4).IPAddress connectaddress=$(wsl -e hostname -I) connectport=80 listenport=80"
}

 if [ $# -ge 2  ]; then
    startwebserver "$@"
else
   #cloned process parses http request
    logErr "webserver pid: $$"
    #lsof -p $$ >&2
    #pstree -pa >&2
    webserver
# problem: sometimes transfer is stopped
# curl -v  192.168.3.174:8000/lib/highcharts-v309.src.js
#* transfer closed with 7016 bytes remaining to read
# nc process is using sendto to write to socket, it keeps sending after webserver.sh process exits
# strace -f -p $(pgrep -f "nc-.*webserver") 2>&1
# using sleep to let nc have some time to send all data
# nc send data in chunks of 8192 bytes, only seem to miss less than 1 block of data at the end, unless sleep 1 is used
  
  sleep 1

fi
