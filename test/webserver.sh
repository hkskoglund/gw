#!/bin/sh
#https://www.my-tiny.net/L19-netcat.htm

HTTP_RESPONSE_200_OK="HTTP/1.1 200" # https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/200
HTTP_RESPONSE_404_NOTFOUND="HTTP/1.1 404"
HTTP_RESPONSE_501_NOTIMPLEMENTED="HTTP/1.1 501"

. ../lib/http.sh
. ../lib/util.sh

sendHttpResponse()
{
    printf "%b" "$APPEND_HTTP_RESPONSE" >"$GWFIFO"
}

appendHttpHeader()
{
    APPEND_HTTP_RESPONSE="${APPEND_HTTP_RESPONSE}$1: $2\n"
}

appendHttpDefaultHeaders()
{
    appendHttpHeader "Date" "$(date)"
    appendHttpHeader "Server" "gw"
    appendHttpHeader "Connection" "close"
}

appendHttpnewLine()
{
    APPEND_HTTP_RESPONSE="$APPEND_HTTP_RESPONSE\r\n"
}

appendHttpResponseCode()
{
    APPEND_HTTP_RESPONSE="${APPEND_HTTP_RESPONSE}$1\n"
}

appendHttpBody()
{
    APPEND_HTTP_RESPONSE="$APPEND_HTTP_RESPONSE$1"
}

resetHttpResponse()
{
    unset APPEND_HTTP_RESPONSE
}

sendHttpResponseCode()
{
    resetHttpResponse
    appendHttpResponseCode "$1"
    appendHttpDefaultHeaders
    sendHttpResponse
}

webserver()
{
        
        # read request and headers including newline
        lno=0
        while IFS= read -r REPLY; do
           lno=$(( lno + 1 ))
           
              set -x
              eval HTTP_LINE$lno=\""$REPLY"\"
              if [ $lno -gt 1 ] && [ "$REPLY" != "$CRLF" ]; then
                eval parseHttpHeader \"\$HTTP_LINE$lno\"
              fi
              set +x
              
            case "$REPLY" in 
                "$CRLF") break
                        ;;
            esac
        done
      
        # send response to client to terminate connection
        case "$HTTP_LINE1" in 
                HEAD*)                          sendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                                ;;

                "GET / "*|"GET /livedata"*)     #sendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                                resetHttpResponse
                                                appendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                                appendHttpDefaultHeaders
                                                appendHttpHeader "Content-Type: application/json"
                                                appendHttpnewLine
                                                appendHttpBody '{"success":"true"}'
                                                sendHttpResponse

                                                ;;

                "GET /"*)                       sendHttpResponseCode "$HTTP_RESPONSE_404_NOTFOUND"
                                                ;;

                        *)                      sendHttpResponseCode "$HTTP_RESPONSE_501_NOTIMPLEMENTED"
                                                ;;
        esac
}


startwebserver()
# $1 port
{
    CRLF=$(printf "\r\n")
    if [ -z "$1" ]; then
        echo >&2 Error: No port specified for web server
        return 1
    fi
    TMPFIFODIR=$(mktemp -d) 
   # trap 'rm -rf "$TMPFIFODIR; exit"'
    GWFIFO="$TMPFIFODIR/fifo"
    GWWEBSERVER_PORT=$1
    ! [ -p "$GWFIFO" ] && mkfifo "$GWFIFO"
    while true; do 
       tail -f "$GWFIFO" | nc -v -4 -l "$GWWEBSERVER_PORT" | webserver  #nc openbsd -N closes connection
        #all processes in pipeline runs in same process group, commands to manage: ps -efj, kill -- -PGID, jobs, kill %+, kill %-
        #https://www.baeldung.com/linux/kill-members-process-group
    done
}
trap

set -x
#echo Args $0
startwebserver "$1"
#echo Background PID $!
jobs
set +x