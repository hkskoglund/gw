#!/bin/sh
#https://www.my-tiny.net/L19-netcat.htm
webserver()
{
    unset IFS
    CRLF=$(printf "\r\n")

    while true; do 
        #headers
        lno=0
        while read -r line; do
           lno=$(( lno + 1 ))
            echo "$line"
            case $line in 
                "$CRLF") break
                        ;;
            esac
        done
        # body
        echo Reading http headers finished
        # send response to client to terminate connection
        #case $line in 
            #    "GET / "*|"GET /livedata"*) echo GET request recevied
            #                                printf "HTTP/1.1 200 OK\nServer: gw">"$GWFIFO"
            #                                        ;;                    
            #    "GET /"*) printf "HTTP/1.1 404\nServer:gw\n">"$GWFIFO"
            #            ;; 
    done
}

startwebserver()
{
    TMPFIFODIR=$(mktemp -d) 
    trap 'rm -rf "$TMPFIFODIR; exit"' INT
    GWFIFO="$TMPFIFODIR/fifo"
    GWWEBSERVER_PORT=8000
    ! [ -p "$GWFIFO" ] && mkfifo "$GWFIFO"
    while true; do 
        tail -f "$GWFIFO" | nc -v -4 -l "$GWWEBSERVER_PORT" | webserver 
        #all processes runs in same process group
    done
}

set -x
startwebserver &
echo Background PID $!
#https://www.baeldung.com/linux/kill-members-process-group
#ps -efj
# kill -- -PGID
jobs
set +x