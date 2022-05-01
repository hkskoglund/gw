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
MIME_SUBTYPE_PLAIN="plain"
MIME_SUBTYPE_HTML="html"
MIME_SUBTYPE_JAVASCRIPT="javascript"
MIME_SUBTYPE_JSON="json"
MIME_SUBTYPE_CSS="css"

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
{
     set -x
    l_file=${HTTP_REQUEST_ABSPATH##*/}
    l_dir=${HTTP_REQUEST_ABSPATH%"$l_file"}
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
    "livedata_url": "http://'"$HTTP_HEADER_host"'/api/livedata"
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

                                                #l_response_JSON=$( cd .. ; timeout 20 ./gw -v json -l 8016 )
                                                set -x
                                               l_response_JSON=$( cd .. ; ./gw -g "$VALUE_HOST" -v json -c l );
                                               set +x
                                               l_exitcode_livedata=$?
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

                                        
                        *".js"|*".css"|*".html") sendFile 
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
       nc -4 -v --ssl -k -l "$GWWEBSERVER_PORT" -e './webserver.sh' 
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
