#!/bin/sh
#https://www.my-tiny.net/L19-netcat.htm

HTTP_RESPONSE_200_OK="HTTP/1.1 200" # https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/200
HTTP_RESPONSE_404_NOTFOUND="HTTP/1.1 404"
HTTP_RESPONSE_501_NOTIMPLEMENTED="HTTP/1.1 501"


. ../lib/http.sh
. ../lib/util.sh

sendHttpResponse()
{
    printf "%b" "$APPEND_HTTP_RESPONSE" 
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

appendHttpResponseNewline()
{
    APPEND_HTTP_RESPONSE="$APPEND_HTTP_RESPONSE\r\n"
}

appendHttpResponseCode()
{
    APPEND_HTTP_RESPONSE="${APPEND_HTTP_RESPONSE}$1\n"
}

appendHttpResponseBody()
{
    APPEND_HTTP_RESPONSE="$APPEND_HTTP_RESPONSE$1"
}

resetHttpResponse()
{
    unset APPEND_HTTP_RESPONSE
}

sendHttpResponseCode()
{
    #resetHttpResponse
    echo >&2 "response: $1"
    appendHttpResponseCode "$1"
    appendHttpDefaultHeaders
    sendHttpResponse
}

webserver()
# process runs in a subshell (function call in end of pipeline), pid can be accessed by $BASHPID/$$ is invoking shell, pstree -pal gives overview
{
    echo >&2 "waiting: read request"
    # read request and headers including newline. read strips off LF=\n at the end of line -> only check for CR=\r
    l_no=0
    
    while IFS= read -r l_http_response_line; do
    l_no=$(( l_no + 1 ))
       
          eval HTTP_LINE$l_no=\""$l_http_response_line"\"
          if [ "$l_http_response_line" = "$CR" ]; then
                echo >&2 header/body CRLF - empty line
                break # exit webserver
           elif [ $l_no -gt 1 ] ; then
                eval parseHttpHeader \"\$HTTP_LINE$l_no\"
          fi
    done
       # send response to client to terminate connection
    if [ -z "$HTTP_LINE1" ]; then
        echo >&2 "webserver: http request of length 0"
        return 1
    fi

    parseHttpRequestLine "$HTTP_LINE1"
    resetHttpResponse

    case "$HTTP_REQUEST_METHOD" in
        HEAD)                   sendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                    ;;
        GET)
            
                case "$HTTP_REQUEST_ABSPATH" in
            /livedata) 
                                            appendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                            appendHttpDefaultHeaders
                                            appendHttpResponseHeader "Content-Type" "application/json"
                                            #https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
                                            # for cross-origin request: 127.0.0.1:3000 Live Preview visual studio code -> webserver localhost:8000
                                            appendHttpResponseHeader "Access-Control-Allow-Origin" "*"
                                            appendHttpResponseNewline
                                            l_response_JSON=$(cd ..; ./gw -g 192.168.3.16 -v json -c l)
                                            #l_response_JSON=$(printf '{"indoor":{"temperature":{"time":"%s","value":"%s","unit":"%s"}}}' 1 2 3)
                                            #problem: stty: 'standard input': Inappropriate ioctl for device
                                            appendHttpResponseBody "$l_response_JSON"
                                            echo >&2 "Info: sending JSON: $l_response_JSON"
                                            sendHttpResponse
                                            unset l_response_JSON
                                            ;;
                /)
                                    #sendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                    #resetHttpResponse
                                appendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                    appendHttpDefaultHeaders
                                # shellcheck disable=SC2154
                                    echo >&2 "!!!!!!!!!! Accept-header $HTTP_HEADER_accept"
                                    case "$HTTP_HEADER_accept" in
                                    application/json)
                                        
                                            appendHttpResponseHeader "Content-Type" "application/json"
                                            appendHttpResponseNewline
                                            appendHttpResponseBody '{"intemp":"21.2"}'
                                            ;;
                                        
                                        *text/html*)
                                    
                                            appendHttpResponseHeader "Content-Type" "text/html"
                                            appendHttpResponseNewline
                                            appendHttpResponseBody "$(cat "$HTTP_SERVER_ROOT/ipad1.html")"
                                            ;;
                                    *)   appendHttpResponseHeader "Content-Type" "text/plain"
                                            appendHttpResponseBody 'Hello from webserver'
                                            ;;
                                    esac
                                sendHttpResponse
                                    ;;
                                    
                    *".js")
                            l_script_file=${HTTP_REQUEST_ABSPATH##*/}
                            l_script_dir=${HTTP_REQUEST_ABSPATH%"$l_script_file"}
                            l_server_file="$HTTP_SERVER_ROOT$l_script_dir$l_script_file"
                            if [ -s "$l_server_file" ]; then
                                >&2 echo "Info: found script $l_server_file"
                                    appendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                    appendHttpDefaultHeaders
                                    appendHttpResponseHeader "Content-Type" "application/javascript"
                                    appendHttpResponseNewline
                                    appendHttpResponseBody "$(cat "$l_server_file")"
                                    sendHttpResponse
                            else
                                >&2 echo "Error: script not found or empty: $l_server_file"
                                sendHttpResponseCode "$HTTP_RESPONSE_404_NOTFOUND"
                            fi
                        unset l_script_file l_script_dir l_server_file
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
# $2 root directory
# from man fifo: "The FIFO must be opened on both ends (reading and
# writing) before data can be passed.  Normally, opening  the  FIFO  blocks  until  the
# other end is opened also."
# https://en.wikipedia.org/wiki/Netcat#Performing_an_HTTP_request
# all processes in pipeline runs in same process group, commands to manage: ps -efj, kill -- -PGID, jobs, kill %+, kill %-
# https://www.baeldung.com/linux/kill-members-process-group
{
    echo >&2 "pid: $$"

    if [ -z "$1" ]; then
        echo >&2 Error: No port specified for web server
        return 1
    else
       echo >&2 "port: $1"
    fi

    if [ -n "$2" ]; then
        if ! [ -d "$2" ]; then
            echo >&2 "Error: $2 root is not a directory"
            return 1
        else
           HTTP_SERVER_ROOT="$2"
           echo >&2 "rootdir: $2"
        fi
    else
       echo >&2 "Error: no rootdir specified"
       return 1
    fi

    TMPFIFODIR=$(mktemp -d)
    GWFIFO="$TMPFIFODIR/httpfifo"
    # create kernel fifo, man fifo
    if mkfifo "$GWFIFO"; then
       echo >&2 "fifo: $GWFIFO"
    fi

    trap 'echo >&2 "webserver INT trap handler"; rm -rf "$TMPFIFODIR"; exit' INT # INT catches ctrl-c -> triggers exit trap handler
    #trap 'echo >&2 webserver EXIT TERM HUP trap handler; rm -rf "$TMPFIFODIR"' EXIT INT TERM HUP
    GWWEBSERVER_PORT=$1
    while true; do 
       #shellcheck disable=SC2094
      # nc -v -4 -l "$GWWEBSERVER_PORT" <"$GWFIFO" | webserver >"$GWFIFO" #openbsd
      nc -4 -l "$GWWEBSERVER_PORT" <"$GWFIFO" | webserver >"$GWFIFO"
      
    done
}

trap

#set -x
#echo Args $0
startwebserver "$@"
#echo Background PID $!
#jobs
#set +x