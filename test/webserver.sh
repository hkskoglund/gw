#!/bin/sh
#https://www.my-tiny.net/L19-netcat.htm

HTTP_RESPONSE_200_OK="200" # https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/200
HTTP_RESPONSE_404_NOTFOUND="404"
HTTP_RESPONSE_501_NOTIMPLEMENTED="501"

# https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
MIME_TYPE_TEXT="text" 
MIME_PARAM_CHARSET_UTF8="charset=UTF-8" # charset can be set optionally only for text 
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

sendHttpResponse()
{
    printAppendBuffer
}

appendHttpResponseHeader()
{
    appendBuffer "%s: %s\r\n" "'$1' '$2'"
}

appendHttpDefaultHeaders()
{
    appendHttpResponseHeader "Date" "$(date -R)"
    #https://httpwg.org/specs/rfc7231.html#http.date
    appendHttpResponseHeader "Server" "gw"
}

appendHttpResponseCRLF()
{
    appendFormat "\r\n"
}

appendHttpResponseCode()
{
    appendBuffer "HTTP/1.1 %s\r\n" "'$1'"
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
    echo >&2 "sending response: $1"
    appendHttpResponseCode "$1"
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

webserver()
# process runs in a subshell (function call in end of pipeline), pid can be accessed by $BASHPID/$$ is invoking shell, pstree -pal gives overview
{
    # read request and headers including newline. read strips off LF=\n at the end of line -> only check for CR=\r
    
        l_received=0

        while IFS=" " read -r l_http_request_line; do

           echo "> $l_http_request_line" >&2
            
            l_received=$(( l_received + 1 ))
        
            eval HTTP_LINE$l_received=\""$l_http_request_line"\"

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

                        /)                   
                                        appendHttpResponseCode "$HTTP_RESPONSE_200_OK"
                                        appendHttpDefaultHeaders

                                        # shellcheck disable=SC2154
                                        case "$HTTP_HEADER_accept" in
                                            
                                            application/json)
                                                getHostFromQS "192.168.3.16"
                                               # l_response_JSON=$( cd .. ; ./gw -g "$VALUE_HOST" -v json -c l )
                                                l_response_JSON=$( cd .. ; ./gw -v json -l 8016 )
                                               
                                                getUnicodeStringLength "$l_response_JSON"
                                                #https://www.w3.org/International/articles/http-charset/index
                                                # "browsers use the reader's preferred encoding when there is no explicit charset parameter"
                                                # maybe not neccessary, unicodes seems to be transferred ok without charset
                                                appendHttpResponseHeader "Content-Type" "$MIME_TYPE_APPLICATION/$MIME_SUBTYPE_JSON" 
                                                appendHttpResponseHeader "Content-Length" "$VALUE_UNICODE_STRING_LENGTH"
                                                #https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
                                                # for cross-origin request: 127.0.0.1:3000 Live Preview visual studio code -> webserver localhost:8000
                                                appendHttpResponseHeader "Access-Control-Allow-Origin" "*"
                                                appendHttpResponseCRLF
                                                if [ "$HTTP_REQUEST_METHOD" = "GET" ]; then 
                                                     appendHttpResponseBody "$l_response_JSON"
                                                     echo >&2 "Sending JSON length: $VALUE_UNICODE_STRING_LENGTH"
                                                fi

                                                sendHttpResponse

                                                #problem WSL2: stty: 'standard input': Inappropriate ioctl for device
                                                unset l_response_JSON
                                                ;;
                                                   
                                            *text/html*)
                                                    
                                                    echo >&2 "sending text/html"
                                                    appendHttpResponseHeader "Content-Type" "$MIME_TYPE_TEXT/$MIME_SUBTYPE_HTML;$MIME_PARAM_CHARSET_UTF8" 
                                                    getFilesize "$HTTP_SERVER_ROOT/index.html"
                                                    appendHttpResponseHeader "Content-Length" "$VALUE_FILESIZE"

                                                    appendHttpResponseCRLF
                                                    sendHttpResponse
                                                    if [ "$HTTP_REQUEST_METHOD" = "GET" ]; then 
                                                            echo >&2 "Sending index.html length: $VALUE_UNICODE_STRING_LENGTH"
                                                            cat "$HTTP_SERVER_ROOT/index.html"
                                                    fi
                                                ;;
                                            
                                            *text/plain*|*)
                                                    # testcurl -v  -H "Acceept: text/plain" 192.168.3.3:8000/
                                                    getHostFromQS "192.168.3.16"
                                                    ltextplain=$( cd .. ; ./gw -g "$VALUE_HOST" -c l )
                                                    getUnicodeStringLength "$ltextplain"
                                                    appendHttpResponseHeader "Content-Type" "$MIME_TYPE_TEXT/$MIME_SUBTYPE_PLAIN;$MIME_PARAM_CHARSET_UTF8"
                                                    ltextplain_length=$(( VALUE_UNICODE_STRING_LENGTH + 2)) # 2=CRLF
                                                    appendHttpResponseHeader "Content-Length" "$ltextplain_length" 
                                                    appendHttpResponseCRLF
                                                    if [ "$HTTP_REQUEST_METHOD" = "GET" ]; then 
                                                        appendHttpResponseBody "$ltextplain"
                                                        appendHttpResponseCRLF
                                                        echo >&2 "Sending text plain length: $ltextplain_length"
                                                    fi
                                                    sendHttpResponse
                                                    unset ltextplain_length
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
                                        appendHttpResponseHeader "Content-Type" "$MIME_TYPE_TEXT/$MIME_SUBTYPE_JAVASCRIPT" 
                                        getFilesize "$l_server_file"
                                        appendHttpResponseHeader "Content-Length" "$VALUE_FILESIZE"
                                        appendHttpResponseCRLF
                                        sendHttpResponse
                                               # --head = only request headers
                                               # curl -v --head  192.168.3.3:8000/lib/highcharts-v309.src.js
                                        if [ "$HTTP_REQUEST_METHOD" = "GET" ]; then 
                                            >&2 echo "webserver: sending javascript $l_server_file"
                                            cat "$l_server_file"
                                        fi 
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
          #export allows child of nc with (cloned with -e option) to get it
           export HTTP_SERVER_ROOT="$2"
           echo >&2 "rootdir: $2"
        fi
    else
       echo >&2 "Error: no rootdir specified"
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
        { nc -4 -v -k -l "$GWWEBSERVER_PORT" -e './webserver.sh' ; echo >&2 "nc exited error code:$?"; }
    done
}

 if [ $# -ge 2  ]; then
    startwebserver "$@"
else
   #cloned process parses http request
    echo >&2 webserver pid: $$
    #lsof -p $$ >&2
    #pstree -pa >&2
    webserver
# problem: sometimes transfer is stopped
# curl -v  192.168.3.174:8000/lib/highcharts-v309.src.js
#* transfer closed with 7016 bytes remaining to read
# nc process is using sendto to write to socket, it keeps sending after webserver process exits
# strace -f -p $(pgrep nc) 2>&1
# using sleep to let nc have some time to send all data
  
  sleep 1

fi
