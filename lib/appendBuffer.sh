#!/bin/sh

appendFormat()
{
    #APPEND_FORMAT="$APPEND_FORMAT$1"
    appendVar APPEND_FORMAT "$1"
}

appendArgs()
{
   # APPEND_ARGS="$APPEND_ARGS $1" #keep space between arguments
   appendVar APPEND_ARGS " $1"
}

appendVar()
# $1 variable
# $2 value
# generic append to any variable
{
    eval "$1=\$$1"'$2' 
}

appendBuffer()
{
    appendVar APPEND_FORMAT "$1"
    appendVar APPEND_ARGS " $2"
}

resetAppendBuffer()
{
   unset APPEND_FORMAT APPEND_ARGS
}

printAppendBuffer()
# $1 format (json)
{
    #special characters like 'æøå' gives wrong adjustment in %s 

    if [ "$DEBUG" -eq 1 ]; then 
        printf >&2 "%s\n" "APPEND_FORMAT/APPEND_ARGS printf '$APPEND_FORMAT' $APPEND_ARGS"
    fi

    case "$1" in
        json) eval LC_NUMERIC= printf \"'$APPEND_FORMAT'\" "$APPEND_ARGS"
                # use POSIX; LC_NUMERIC= locale -k decimal_point = decimal_point="."
                ;;
                
            
        *)
            eval printf \"'$APPEND_FORMAT'\" "$APPEND_ARGS"
            #'$APPEND_FORMAT' keeps double quoute "" in JSON
            ;;
    esac

    resetAppendBuffer
}


