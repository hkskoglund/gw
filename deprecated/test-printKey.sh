#!/usr/bin/dash

DEBUG=0

printKey() {
# $1 - key, $2 - field size, negative for left justify
    local str
    local whitespaceSize
    local whitespaceStr
    local n
    local strlen
    local fsize
    local ljustify

    str="$1"
    strlen=${#str}

    if [ -n "$2" ]; then
    
       if  [ "$2" -lt 0 ]; then # left justify key
          ljustify=1
          fsize=$(( -1 * $2))
       else
        ljustify=0
         fsize=$2
        fi

       FIELD_SIZE_KEY="$fsize" #allow specifying default field size in "$2"
    else
        ljustify=1
        FIELD_SIZE_KEY=$(( strlen + 1 )) # use only 1 space after key
    fi

    #build padding string with spaces
    n=1
    whitespaceSize=$(( FIELD_SIZE_KEY - strlen ))
    while [ "$n" -le "$whitespaceSize" ]; do
     whitespaceStr="$whitespaceStr "
      n=$(( n + 1 ))
    done

    if [ "$ljustify" -eq 1  ]; then 
       str="$str$whitespaceStr"
    else
      str="$whitespaceStr$str"
    fi
    
    echo -n "$str" 
    
    [ "$DEBUG" -eq 1 ] && >&2 echo "${#str}" whitespacestr len "${#whitespaceStr}"

}

printKey "indoor temperature" -40; printKey "22.3" 7; printKey "%" 3

