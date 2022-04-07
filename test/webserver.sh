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

appendHttpResponseHeader()
{
    APPEND_HTTP_RESPONSE="${APPEND_HTTP_RESPONSE}$1: $2\n"
}

appendHttpDefaultHeaders()
{
    appendHttpResponseHeader "Date" "$(date)"
    appendHttpResponseHeader "Server" "gw"
    appendHttpResponseHeader "Connection" "close"
}

appendHttpResponsenewline()
{
    APPEND_HTTP_RESPONSE="$APPEND_HTTP_RESPONSE\r\n"
}

appendHttpResponseCode()
{
    APPEND_HTTP_RESPONSE="${APPEND_HTTP_RESPONSE}$1\n"
}

appendHttpResponseneBody()
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
# process runs in a subshell (function call in end of pipeline), pid can be accessed by $BASHPID/$$ is invoking shell, pstree -pal gives overview
{
        # read request and headers including newline. read strips off LF=\n at the end of line -> only check for CR=\r
        l_no=0
        while IFS= read -r l_http_response_line; do

           l_no=$(( l_no + 1 ))
           
              set -x
              eval HTTP_LINE$l_no=\""$l_http_response_line"\"
              if [ "$l_http_response_line" = "$CR" ]; then
                    echo >&2 http newline CR
                    break
               elif [ $l_no -gt 1 ] ; then
                eval parseHttpHeader \"\$HTTP_LINE$l_no\"
              fi
              set +x

        done
      
        # send response to client to terminate connection

        if [ -z "$HTTP_LINE1" ]; then
            echo >&2 "webserver: http request of length 0"
            return 1
        fi

        parseHttpRequestLine "$HTTP_LINE1"

        case "$HTTP_REQUEST_METHOD" in
            HEAD)                   sendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                    ;;
            GET)
                case "$HTTP_REQUEST_URL" in
                  /|/livedata)
                                    #sendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                    resetHttpResponse
                                    appendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                    appendHttpDefaultHeaders
                                    appendHeader "Content-Type: text/plain"
                                    appendHttpResponsenewline
                                    appendHttpResponseneBody 'test\t\ttest\t\ttest\n'
                                    #appendHttpResponseHeader "Content-Type: application/json"
                                    #appendHttpResponsenewline
                                    #appendHttpResponseneBody '{"success":"true"}'
                                    sendHttpResponse
                                    ;;

                            *)      sendHttpResponseCode "$HTTP_RESPONSE_404_NOTFOUND"
                                    ;;
                esac
                ;;
            *)                      sendHttpResponseCode "$HTTP_RESPONSE_501_NOTIMPLEMENTED"
                                    ;;
        esac

   # set
    unset l_no l_http_response_line
}


startwebserver()
# $1 port
{
    echo >&2 "Webserver PID $$"

    CR=$(printf "\r") 
    if [ -z "$1" ]; then
        echo >&2 Error: No port specified for web server
        return 1
    fi
    TMPFIFODIR=$(mktemp -d)
    GWFIFO="$TMPFIFODIR/fifo"
    mkfifo "$GWFIFO"
    trap 'echo >&2 "webserver INT trap handler"; rm -rf "$TMPFIFODIR"; exit' INT # INT catches ctrl-c -> triggers exit trap handler
    #trap 'echo >&2 webserver EXIT TERM HUP trap handler; rm -rf "$TMPFIFODIR"' EXIT INT TERM HUP
    GWWEBSERVER_PORT=$1
    while true; do 
       #set
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
#jobs
set +x