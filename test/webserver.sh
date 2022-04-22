#!/bin/sh
#https://www.my-tiny.net/L19-netcat.htm

HTTP_RESPONSE_200_OK="HTTP/1.1 200" # https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/200
HTTP_RESPONSE_404_NOTFOUND="HTTP/1.1 404"
HTTP_RESPONSE_501_NOTIMPLEMENTED="HTTP/1.1 501"

if [ -n "$ZSH_VERSION" ]; then
    #https://zsh.sourceforge.io/FAQ/zshfaq03.html
       setopt shwordsplit  #zsh compability for "1 2 3" -> split in 1 2 3
    fi

. ../lib/http.sh
. ../lib/util.sh

sendHttpResponse()
{
    printf "%b" "$APPEND_HTTP_RESPONSE" 
}

appendHttpResponseHeader()
{
    APPEND_HTTP_RESPONSE="${APPEND_HTTP_RESPONSE}$1: $2\r\n"
}

appendHttpDefaultHeaders()
{
    appendHttpResponseHeader "Date" "$(date)"
    appendHttpResponseHeader "Server" "gw"
   # appendHttpResponseHeader "Connection" "close"
}

appendHttpResponseNewline()
{
    APPEND_HTTP_RESPONSE="$APPEND_HTTP_RESPONSE\r\n"
}

appendHttpResponseCode()
{
    APPEND_HTTP_RESPONSE="${APPEND_HTTP_RESPONSE}$1\r\n"
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
    echo >&2 "sending response: $1"
    appendHttpResponseCode "$1"
    appendHttpDefaultHeaders
    appendHttpResponseHeader "Content-Length" "0"
    appendHttpResponseNewline
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

webserver()
# process runs in a subshell (function call in end of pipeline), pid can be accessed by $BASHPID/$$ is invoking shell, pstree -pal gives overview
{
    # read request and headers including newline. read strips off LF=\n at the end of line -> only check for CR=\r
    
    #while true; do 

    echo >&2 "waiting: read http request"

        l_received=0

        while IFS=" " read -r l_http_request_line; do

           echo received "$l_http_request_line" >&2
            
            l_received=$(( l_received + 1 ))
        
            eval HTTP_LINE$l_received=\""$l_http_request_line"\"

            if [ "$l_http_request_line" = "$CR" ]; then # request and headers read
                echo >&2 header/body CRLF - empty line
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

            HEAD)                               sendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                                ;;

            GET)   case "$HTTP_REQUEST_ABSPATH" in

                         /livedata) 
                        # /livedata?gw=192.168.3.16
                                                l_response_JSON=$( cd .. ; ./gw -g 192.168.3.16 -v json -c l )
                                                getUnicodeStringLength "$l_response_JSON"
                                                appendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                                appendHttpDefaultHeaders
                                                appendHttpResponseHeader "Content-Type" "application/json"
                                                appendHttpResponseHeader "Content-Length" "$VALUE_UNICODE_STRING_LENGTH"
                                                #https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
                                                # for cross-origin request: 127.0.0.1:3000 Live Preview visual studio code -> webserver localhost:8000
                                                appendHttpResponseHeader "Access-Control-Allow-Origin" "*"
                                                appendHttpResponseNewline
                                                sendHttpResponse
                                                echo >&2 Sending JSON
                                                printf "%s" "$l_response_JSON"
                                                #problem WSL2: stty: 'standard input': Inappropriate ioctl for device
                                                unset l_response_JSON
                                                ;;

                    /)                      #resetHttpResponse
                                            appendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                            appendHttpDefaultHeaders

                                        # shellcheck disable=SC2154
                                        case "$HTTP_HEADER_accept" in
                                            
                                            application/json)
                                                
                                                    appendHttpResponseHeader "Content-Type" "application/json"
                                                    appendHttpResponseNewline
                                                    appendHttpResponseBody '{"intemp":"21.2"}'
                                                    sendHttpResponse
                                                    ;;
                                                
                                            *text/html*)
                                                    echo >&2 "sending text/html"
                                                    appendHttpResponseHeader "Content-Type" "text/html"
                                                    getFilesize "$HTTP_SERVER_ROOT/ipad1.html"
                                                    appendHttpResponseHeader "Content-Length" "$VALUE_FILESIZE"

                                                    appendHttpResponseNewline
                                                    sendHttpResponse
                                                    cat "$HTTP_SERVER_ROOT/ipad1.html"
                                                    ;;
                                            
                                            *)      #appendHttpResponseHeader "Content-Type" "text/plain"
                                                    ltextplain='hello from webserver'
                                                    #appendHttpResponseHeader "Content-Length: ${#ltextplain}"
                                                    #appendHttpResponseNewline
                                                    #appendHttpResponseBody "$ltextplain"
                                                    #sendHttpResponse
                                                    echo >&2 "webserver: sending plain text"
                                                    printf "HTTP/1.1 200\r\nContent-Type: text/plain\r\nContent-Length: %d\r\n\r\n%s" ${#ltextplain} "$ltextplain"

                                                    ;;
                                        esac
                                    ;;
                                        
                        *".js")
                                l_script_file=${HTTP_REQUEST_ABSPATH##*/}
                                l_script_dir=${HTTP_REQUEST_ABSPATH%"$l_script_file"}
                                l_server_file="$HTTP_SERVER_ROOT$l_script_dir$l_script_file"
                                if [ -s "$l_server_file" ]; then
                                        appendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                        appendHttpDefaultHeaders
                                        appendHttpResponseHeader "Content-Type" "application/javascript"
                                        getFilesize "$l_server_file"
                                        appendHttpResponseHeader "Content-Length" "$VALUE_FILESIZE"
                                        appendHttpResponseNewline
                                        sendHttpResponse
                                        >&2 echo "webserver: sending javascript $l_server_file"
                                        cat "$l_server_file"
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

    resetHttpHeaders
    resetHttpLines "$l_received"
    resetHttpRequest
    resetHttpResponse

    # set | grep HTTP >&2

    unset l_received l_http_request_line

  #done

}

jsonserver()
{
    while true; do 

     echo >&2 "jsonserver: read request"

        l_received=0

        while IFS=" " read -r l_http_request_line; do

           echo received "$l_http_request_line" >&2
            
            l_received=$(( l_received + 1 ))
        
            eval HTTP_LINE$l_received=\""$l_http_request_line"\"

            if [ "$l_http_request_line" = "$CR" ]; then # request and headers read
                echo >&2 header/body CRLF - empty line
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

            GET)   case "$HTTP_REQUEST_ABSPATH" in

                         /) 
                        # /livedata?gw=192.168.3.16

                                     case "$HTTP_HEADER_accept" in
                                            
                                            text/plain)

                                               l_response_plain=$( cd ..; ./gw -g 192.168.3.16 -c l)
                                               
                                                appendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                                appendHttpDefaultHeaders
                                                appendHttpResponseHeader "Content-Type" "text/plain"
                                                getUnicodeStringLength "$l_response_plain"
                                                appendHttpResponseHeader "Content-Length" ""$(( VALUE_UNICODE_STRING_LENGTH + 1))"" # +1 for \n
                                                #https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
                                                # for cross-origin request: 127.0.0.1:3000 Live Preview visual studio code -> webserver localhost:8000
                                                appendHttpResponseHeader "Access-Control-Allow-Origin" "*"
                                                appendHttpResponseNewline
                                                sendHttpResponse
                                                echo >&2 Sending text/plain
                                                printf "%s\n" "$l_response_plain"
                                                unset l_response_plain
                                                ;;
                                               
                                            application/json|*)

                                                l_response_JSON=$( cd .. ; ./gw -g 192.168.3.16 -v json -c l )
                                                appendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                                appendHttpDefaultHeaders
                                                appendHttpResponseHeader "Content-Type" "application/json"
                                                getUnicodeStringLength "$l_response_JSON"
                                                echo >&2 JSON string length "$VALUE_UNICODE_STRING_LENGTH" '$# length' ${#l_response_JSON}
                                                appendHttpResponseHeader "Content-Length" "$VALUE_UNICODE_STRING_LENGTH"
                                                #https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
                                                # for cross-origin request: 127.0.0.1:3000 Live Preview visual studio code -> webserver localhost:8000
                                                appendHttpResponseHeader "Access-Control-Allow-Origin" "*"
                                                appendHttpResponseNewline
                                                sendHttpResponse
                                                echo >&2 Sending JSON
                                                printf "%s" "$l_response_JSON"
                                                #problem WSL2: stty: 'standard input': Inappropriate ioctl for device
                                                unset l_response_JSON
                                                ;;

                                    esac
                                    ;;

                                *)   sendHttpResponseCode "$HTTP_RESPONSE_404_NOTFOUND"
                                     ;;

                  esac
                  
        esac

    resetHttpHeaders
    resetHttpLines "$l_received"
    resetHttpRequest
    resetHttpResponse

    # set | grep HTTP >&2

    unset l_received l_http_request_line
  done
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
      # man nc openbsd: -k When a connection is completed, listen for another one.  Requires -l.
      # unless -k is used webserver will enter a read(0,"",1) = 0 loop -> because the nc process exited
      # possible: while true; do nc -4 -l; done loop -> use -k flag instead
       { nc -4 -v -k -l "$GWWEBSERVER_PORT" <"$GWFIFO" ; echo >&2 "nc exited error code:$?"; } | { jsonserver >"$GWFIFO" ; echo >&2 "jsonserver exit code: $?" ; }
      # { busybox nc  -ll -p "$GWWEBSERVER_PORT" <"$GWFIFO" ; echo >&2 "Error: nc exited error code:$?"; } | { webserver >"$GWFIFO" ; echo >&2 "Error: webserver exit code: $?" ; }
      # { toybox nc  -L -p "$GWWEBSERVER_PORT" <"$GWFIFO" ; echo >&2 "Error: nc exited error code:$?"; } | { webserver >"$GWFIFO" ; echo >&2 "Error: webserver exit code: $?" ; }

    done
}

trap

#set -x
#echo Args $0
startwebserver "$@"
#echo Background PID $!
#jobs
#set +x