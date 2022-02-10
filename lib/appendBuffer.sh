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
#generic append to any variable
{
    #echo  "$1=\"\$$1$2\"" 
    eval "$1=\"\$$1$2\""
}

appendBuffer()
{
    #appendFormat "$1"
    appendVar APPEND_FORMAT "$1"
    #appendArgs "$2"
    appendVar APPEND_ARGS " $2"
}

printAppendBuffer()
{
    #special characters like 'æøå' gives wrong adjustment in %s 

    if [ "$DEBUG" -eq 1 ] || [ "$DEBUG_OPTION_APPEND" -eq 1 ]; then 
        printf >&2 "%s\n" "APPEND_FORMAT/APPEND_ARGS printf '$APPEND_FORMAT' $APPEND_ARGS"
    fi

    eval printf \""$APPEND_FORMAT"\" "$APPEND_ARGS"

    resetAppendBuffer
}
