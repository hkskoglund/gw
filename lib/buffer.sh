#!/bin/sh

DEBUG=${DEBUG:=0}
DEBUG_BUFFER=${DEBUG_BUFFER:=$DEBUG}
SHELL_SUPPORT_BULTIN_PRINTF_VOPT=${SHELL_SUPPORT_BULTIN_PRINTF_VOPT:=0}

newBuffer() 
# initialize new buffer
# $1 buffername, $2 value
# $1_HEAD index of current read position
{
    EXITCODE_BUFFER=0

    if [ -n "$1" ]; then
        eval "$1=\"$2\" $1_HEAD=1"
        
        [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "new buffer; buffername: $1, value: $2"
    else
        [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "Error: no buffer name"
        EXITCODE_BUFFER="$ERROR_READ_BUFFER"
    fi

    return "$EXITCODE_BUFFER"

}

writeUInt8()
# write unsigned 8-bit int to buffer
# $1 buffername, $2 unsigned 8-bit int, $3 debug info
 {
    [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeUInt "$1" "$2" "$3"
    eval "$1=\"\$$1 $2 \""
}

writeInt8()
# write signed 8-bit int to buffer using 2's complement
# $1 buffername, $2 signed 8-bit int, $3 debug info
{
    convertFloat8To2sComplement "$2"
    [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeUInt "$1" "$2" 2complement: "$VALUE_UINT_2SCOMPLEMENT" "$3"
    writeUInt8 "$1" "$VALUE_UINT_2SCOMPLEMENT" 2complement
}

writeUInt16BE()
# write unsigned 16-bit int to buffer
# $1 buffername, $2 unsigned 16-bit int, $3 debug info
 {
    [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeUInt16BE "$1" "$2" "$3"
    eval "$1=\"\$$1 $(($2 >> 8)) $(($2 & 0xff)) \""
}

writeInt16BE()
# write signed 16-bit int to buffer
# $1 buffername, $2 signed 16-bit int, $3 debug info
{
    convertFloat16To2sComplement "$2"
    [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeInt16BE "$1" "$2" 2complement: "$VALUE_UINT_2SCOMPLEMENT" "$3"
    writeUInt16BE "$1" "$VALUE_UINT_2SCOMPLEMENT"
}

writeUInt32BE()
# write unsigned 32-bit int to buffer
# $1 buffername, $2 unsigned 32-bit int, $3 debug info
{
    [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeUInt32BE "$1" "$2" "$3"
    eval "$1=\"\$$1 $(($2 >> 24)) $((($2 & 0xff0000) >> 16))  $((($2 & 0xff00) >> 8))  $(($2 & 0xff)) \""
}

writeInt32BE()
# write signed 32-bit int to buffer
# $1 buffername, $2 signed 32-bit int, $3 debug info
{
    convertFloat32To2sComplement "$2"
        [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeInt32BE "$1" "$2" 2complement: "$VALUE_UINT_2SCOMPLEMENT" "$3"

    writeUInt32BE "$1" "$VALUE_UINT_2SCOMPLEMENT"
}

writeString()
# write string to buffer
# optimization: dont fork subshell with od
# $1 buffername , $2 string, $3 debug info
{
  # PACKET_TX_BODY="${#1} $(printf "%s" "$1" | od -A n -t u1)"

    str=$2
    len=${#str}

    [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo  "writeString buffername:$1 string:$2 strlen: $len info: $3"

    writeUInt8 "$1" "$len" stringlength

    unset APPEND_FORMAT_WRITE_STRING APPEND_STRING

    n=1
    while [ -n "$str" ]; do
        suffix=${str#?}
        eval C$n='${str%%"$suffix"}'
        APPEND_FORMAT_WRITE_STRING=$APPEND_FORMAT_WRITE_STRING'%d ' # wait with printf-processing until entire sting is built
        APPEND_STRING=$APPEND_STRING'\"$'"C$n " # \'$var or \"$var - char to ascii conversion in printf bulitin/command argument
        str=$suffix
        n=$(( n + 1 ))
    done

    if [ "$SHELL_SUPPORT_BULTIN_PRINTF_VOPT" -eq  1 ] && [ -n "$APPEND_FORMAT_WRITE_STRING" ]; then
        eval printf -v decstr \""$APPEND_FORMAT_WRITE_STRING"\" "$APPEND_STRING"
        #shellcheck disable=SC2154
        eval "$1=\"\$$1 $decstr\""
    elif [ -n "$APPEND_FORMAT_WRITE_STRING" ]; then
         eval "$1=\"\$$1 $(eval printf \""$APPEND_FORMAT_WRITE_STRING"\" "$APPEND_STRING")\""
    fi

    #cleanup variables
    unset APPEND_FORMAT_WRITE_STRING APPEND_STRING
    n=1
    while [ "$n" -le "$len" ]; do
        unset C$n 
        n=$(( n + 1 ))
    done

    unset len str decstr n
}

readSlice()
# read a slice of n bytes from buffer, first 6 bytes auto convert to hex for printing of MAC/broadcast command
# $1 buffername, $2 number of bytes to read
# set B1,...,Bn
# set B1HEX,...,B6HEX
 { 
     EXITCODE_BUFFER=0
     read_buffername=$1
     read_info=$2

    #[ $DEBUG_BUFFER -eq 1 ] &&
     echo >&2 "readSlice buffername: $1, bytes: $2"

    n=1
    while [ "$n" -le "$2" ]; do
        if readUInt8 "$1" "read slice byte $n"; then
            eval "B$n=$VALUE_UINT8"
            if [ "$n" -le 6 ]; then # 
                #shellcheck disable=SC2027
            eval "convertUInt8ToHex \"\$B$n\"; B"$n"HEX=\$VALUE_UINT8_HEX"
            fi
        else
           echo >&2 "Error: Unable to read slice from buffername: $read_buffername, info: $read_info"
           EXITCODE_BUFFER=$ERROR_READ_BUFFER
        fi
        n=$((n + 1))
    done

    unset n
    return "$EXITCODE_BUFFER"
}

readUInt8()
# read unsigned 8-bit int from space delimited buffer of decimal numbers, removes uint in front of buffer/destructive
# $1 buffername, $2 debug info
# set VALUE_UINT8
 {
     EXITCODE_BUFFER=0

    read_buffername="$1"
    read_info="$2"

    unset VALUE_UINT8

    IFS=" "
   
    eval set -- "\$$1"
    VALUE_UINT8=$1
    shift
    eval "$read_buffername"=\""$*"\"
    if [ -z "$VALUE_UINT8" ]; then
      echo >&2 Error: Unable to read uint8 from buffer "$read_buffername"
      EXITCODE_BUFFER=$ERROR_READ_BUFFER
    fi

    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 readUInt8 buffername: "$read_buffername" length: $#  uint8: "$VALUE_UINT8" info: "$read_info" 

    unset BYTE readuint8_buffername readuint8_info
    return "$EXITCODE_BUFFER"
}

readInt8() 
# read signed 8-bit int, 8-bit=sign bit,sets VALUE_INT8
# $1 buffername, $2 debug info
{
    EXITCODE_BUFFER=0
    read_buffername=$1
    read_info=$2

    if readUInt8 "$1" "$2"; then
        VALUE_INT8=$((-1 * (VALUE_UINT8 >> 7) * 0x80 + (VALUE_UINT8 & 0x7f)))
    else
      echo >&2 "Error: Unable to read int8 from buffername $read_buffername"
      EXITCODE_BUFFER=$ERROR_READ_BUFFER
    fi

    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 readInt8 buffername: "$read_buffername" bytelength: $#  int8: "$VALUE_INT8" info: "$read_info" 

}

readUInt16BE() 
# read unsigned 16-bit int, sets VALUE_UINT16BE
# $1 buffername, $2 debug info
{
    unset VALUE_UINT16BE
    EXITCODE_BUFFER=0
    read_buffername=$1
    read_info=$2

     IFS=" "
   
    eval set -- "\$$1"
    if [ -n "$1" ] && [ -n "$2" ]; then
        VALUE_UINT16BE=$(( ($1 << 8) | $2 ))
        shift 2
        eval "$read_buffername"=\""$*"\"
    else
       echo >&2 "Error: Unable to read uin16be from buffername $read_buffername msb: $1 lsb: $2"
       EXITCODE_BUFFER=$ERROR_READ_BUFFER
    fi

        [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 readUInt16BE buffername: "$read_buffername" bytelength: $#  uint16: "$VALUE_UINT16BE" info: "$read_info" 
    
    return "$EXITCODE_BUFFER"
}

readInt16BE() 
# read signed 16-bit int, 2's complement big endian, msb is the sign bit 
# Converting from two's complement representation https://en.wikipedia.org/wiki/Two%27s_complement
# $1 buffername, $2 debug info
# set VALUE_INT16BE
{ 
    unset VALUE_INT16BE
    
    EXITCODE_BUFFER=0

    read_buffername=$1
    read_info=$2

    if readUInt16BE "$1" "$2"; then
        VALUE_INT16BE=$((-1 * (VALUE_UINT16BE >> 15) * 32768 + (VALUE_UINT16BE & 32767)))
    else
        echo >&2 "Error: Unable to read int16be from buffername $read_buffername $read_info"
        EXITCODE_BUFFER=$ERROR_READ_BUFFER
    fi

    return "$EXITCODE_BUFFER"

}

readUInt32BE()
# read unsigned 32-bit int
# set VALUE_UINT32BE
{
    unset VALUE_UINT32BE

    EXITCODE_BUFFER=0
    read_buffername=$1
    read_info=$2

     IFS=" "
   
    eval set -- "\$$1"
    if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]; then
        VALUE_UINT32BE=$((($1 << 24) | ($2 << 16) | ($3 << 8) | $4))
        shift 4
        eval "$read_buffername"=\""$*"\"
    else
       echo >&2 "Error: Unable to read uint32be from buffername $read_buffername info: $read_info msb: $1 lsb: $2 msb2: $3 lsb2: $4"
       EXITCODE_BUFFER=$ERROR_READ_BUFFER
    fi

    return "$EXITCODE_BUFFER"

}

readInt32BE()
# read signed 32-bit int, 2's complement big endian, msb is the sign bit
# $1 buffername, $2 debug info
# set VALUE_UINT32BE
{ 
    unset VALUE_INT32BE
    EXITCODE_BUFFER=0
    read_buffername=$1
    read_info=$2

    if readUInt32BE "$1" "$2"; then
        VALUE_INT32BE=$((-1 * (VALUE_UINT32BE >> 31) * 0x80000000 + (VALUE_UINT32BE & 0x7fffffff)))
    else
        echo >&2 "Error: Unable to read int32be from buffername $read_buffername info: $read_info"
        EXITCODE_BUFFER=$ERROR_READ_BUFFER
    fi

    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 "readInt32BE unsigned 32-bit $VALUE_UINT32BE signed 32-bit $VALUE_INT32BE"

    return "$EXITCODE_BUFFER"
}

readString()
# read string from buffer, set VALUE_STRING
# \x formatted printf format not supported in dash -> must use \nnn-octal format,
# https://bugs.launchpad.net/ubuntu/+source/dash/+bug/1499473
# $1 buffername, $2 debug info
 { 
   
    EXITCODE_BUFFER=0
    read_buffername=$1
    read_info=$2

    if ! readUInt8 "$1" "string length"; then 
        echo >&2 "Error: Unable to read string length from buffername: $1 info: $2"
        return "$ERROR_READ_BUFFER"
    fi    
    
    len_uint8=$VALUE_UINT8

    unset VALUE_STRING_ESCAPE
    unset VALUE_STRING

    n=1
    while [ "$n" -le "$len_uint8" ]; do

        if readUInt8 "$1" "string byte $n"; then
            convertHexToOctal "$VALUE_UINT8"
            VALUE_STRING_ESCAPE="$VALUE_STRING_ESCAPE\\0$VALUE_OCTAL"
        else
            echo >&2 "Error: failed to read string byte $n"
            EXITCODE_BUFFER=$ERROR_READ_BUFFER
            break
        fi

        n=$((n + 1))

    done

    if [ "$EXITCODE_BUFFER" -eq 0 ]; then

        if [ "$SHELL_SUPPORT_BULTIN_PRINTF_VOPT" -eq 1 ]; then
            #shellcheck disable=SC3045
            printf -v VALUE_STRING "%b" "$VALUE_STRING_ESCAPE"
        else
        VALUE_STRING=$(printf "%b" "$VALUE_STRING_ESCAPE") # convert to string
        fi
     fi
     
    [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "readString: $VALUE_STRING length: ${#VALUE_STRING}"

    unset len_uint8 n

    return "$EXITCODE_BUFFER"
}

convertFloat8To2sComplement()
{
    convertFloatTo2sComplement "$1" 8
}

convertFloat16To2sComplement()
{
    convertFloatTo2sComplement "$1" 16
}

convertFloat32To2sComplement()
{
    convertFloatTo2sComplement "$1" 32
}

convertFloatTo2sComplement()
# convert N-bit signed float to 2's complement, big endian: most significant bits to the left, set VALUE_UINT_2SCOMPLEMENT
# $1 number, $2 N bits
{
    case "$1" in
        -*) number=${1#-} # remove sign from negative number
            VALUE_UINT_2SCOMPLEMENT=$(( (2 << $2) - number))  # 2 << 31 = 2**32, 2scomplement + number = 2^N
            ;;
        
        *)  VALUE_UINT_2SCOMPLEMENT=$1 
            ;;
    esac

   [ "$DEBUG_BUFFER" -eq 1 ] &&  echo >&2 "convertFloatTo2sComplement convert $1 to unsigned $2-bit $VALUE_UINT_2SCOMPLEMENT"

}

printBuffer()
# print decimal buffer as hex buffer
# $1 decimal buffer
 {
    unset APPEND_STRING

    IFS=" "
    for BYTE in $1; do
        convertUInt8ToHex "$BYTE"
        APPEND_STRING=$APPEND_STRING" $VALUE_UINT8_HEX"
    done
    
    echo "$APPEND_STRING"

    unset BYTE APPEND_STRING

}