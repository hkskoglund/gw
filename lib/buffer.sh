#!/bin/sh

DEBUG=${DEBUG:=0}
DEBUG_BUFFER=${DEBUG_BUFFER:=$DEBUG}
SHELL_SUPPORT_BULTIN_PRINTF_VOPT=${SHELL_SUPPORT_BULTIN_PRINTF_VOPT:=0}
ERROR_READ_BUFFER=${ERROR_READ_BUFFER:=1}

# debug bash: set -o posix; set | grep GWBUFFER; set +o posix
# https://unix.stackexchange.com/questions/3510/how-to-print-only-defined-variables-shell-and-or-environment-variables-in-bash

newBuffer() 
# initialize new buffer with space delimited decimal uint8 string
# $1 buffername, $2 value
# set $1_HEAD index of current read position (zero index)
# set $1_LENGTH number of bytes
# append $1 to GWBUFFER_NAMES to keep track of buffers
{
    EXITCODE_BUFFER=0

    read_buffername=$1 # every buffer start with GWBUFFER
    read_buffervalue=$2

    unset buffer_index

    case $GWBUFFER_NAMES in
        *$read_buffername*) [ $DEBUG_BUFFER -eq 1 ] && echo >&2 echo "newBuffer: overwrite $read_buffername"
                             destroyBuffer "$read_buffername" #overwrite
                            ;;
    esac

    eval "$read_buffername=\"$read_buffervalue\" ${read_buffername}_HEAD=0"

    GWBUFFER_NAMES="$GWBUFFER_NAMES$read_buffername " #keep track of buffernames

    IFS=' '
    eval set -- "$read_buffervalue"
    eval "${read_buffername}_LENGTH=$#"
    buffer_index=0
    while [ $buffer_index -lt $# ]; do
        eval "${read_buffername}_$buffer_index=\${$(( buffer_index +1 ))}"
        buffer_index=$(( buffer_index + 1 ))
    done

    [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "new buffer; buffername: $read_buffername, value: $read_buffervalue, length: $#"
   

    unset read_buffername read_buffervalue buffer_index

    return "$EXITCODE_BUFFER"

}

destroyBuffer()
# unset buffer
# $1 buffername
{

    EXITCODE_BUFFER=0
    read_buffername=$1
    [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "Destroying buffer $read_buffername"

    case $GWBUFFER_NAMES in
      *$1*)
            GWBUFFER_NAMES=${GWBUFFER_NAMES#*"$read_buffername"*}
            eval buflen=\$"${read_buffername}_LENGTH"
            N=0
            #shellcheck disable=SC2154
            while [ $N -lt "$buflen" ]; do
                unset "${read_buffername}_$N"
                N=$(( N + 1))
            done 
            unset "${read_buffername}" "${read_buffername}_LENGTH" "${read_buffername}_HEAD" 


            ;;
       *)   echo >&2 "Error: Unknown buffername $1, known buffers $GWBUFFER_NAMES"
                 EXITCODE_BUFFER=$ERROR_READ_BUFFER
            ;;
    esac

    unset N buflen

    return $EXITCODE_BUFFER
}

destroyAllBuffers()
# unset all buffers
{
    IFS=' '
    [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "Destroying all buffers $GWBUFFER_NAMES"
    for buffername in $GWBUFFER_NAMES; do
      destroyBuffer "$buffername"
    done
    unset buffername
}

writeUInt8()
# write unsigned 8-bit int to buffer
# $1 buffername, $2 unsigned 8-bit int, $3 debug info
 {
    [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeUInt buffername:"$1" uint8:"$2" info: "$3"
    eval "$1=\"\$$1 $2 \""
}

writeInt8()
# write signed 8-bit int to buffer using 2's complement
# $1 buffername, $2 signed 8-bit int, $3 debug info
{
    convertFloat8To2sComplement "$2"
    [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeUInt8 buffername:"$1" int8:"$2" 2complement: "$VALUE_UINT_2SCOMPLEMENT" info:"$3"
    writeUInt8 "$1" "$VALUE_UINT_2SCOMPLEMENT" 2complement
}

writeUInt16BE()
# write unsigned 16-bit int to buffer
# $1 buffername, $2 unsigned 16-bit int, $3 debug info
 {
    [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeUInt16BE buffername:"$1" uint16:"$2" info:"$3"
    eval "$1=\"\$$1 $(($2 >> 8)) $(($2 & 0xff)) \""
}

writeInt16BE()
# write signed 16-bit int to buffer
# $1 buffername, $2 signed 16-bit int, $3 debug info
{
    convertFloat16To2sComplement "$2"
    [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeInt16BE buffername:"$1" int16:"$2" 2complement: "$VALUE_UINT_2SCOMPLEMENT" info: "$3"
    writeUInt16BE "$1" "$VALUE_UINT_2SCOMPLEMENT"
}

writeUInt32BE()
# write unsigned 32-bit int to buffer
# $1 buffername, $2 unsigned 32-bit int, $3 debug info
{
    [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeUInt32BE buffername:"$1" uint32:"$2" info:"$3"
    eval "$1=\"\$$1 $(($2 >> 24)) $((($2 & 0xff0000) >> 16))  $((($2 & 0xff00) >> 8))  $(($2 & 0xff)) \""
}

writeInt32BE()
# write signed 32-bit int to buffer
# $1 buffername, $2 signed 32-bit int, $3 debug info
{
    convertFloat32To2sComplement "$2"
        [ "$DEBUG_BUFFER" -eq 1 ] && >&2 echo writeInt32BE buffername:"$1" int32:"$2" 2complement: "$VALUE_UINT_2SCOMPLEMENT" info:"$3"

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
# read a slice of n bytes from buffer, start at $_HEAD position
# $1 buffername, $2 number of bytes to read, $3 debug info
# set VALUE_SLICE - new buffer of $2 bytes
 { 
     unset VALUE_SLICE

     EXITCODE_BUFFER=0
     readslice_buffername=$1
     readslice_byte_count=$2
     readslice_info=$3

    readslice_N=1
    eval readslice_head_index="\$${readslice_buffername}_HEAD" readslice_buffer_length="\$${readslice_buffername}_LENGTH"
    #shellcheck disable=SC2154
    if ! [ $((readslice_head_index + readslice_byte_count )) -le "$readslice_buffer_length" ]; then
        echo >&2 "Error: readSlice: Attempt to read beyond buffer limit; buffername: $readslice_buffername, bufferlength: $buffer_length"
        EXITCODE_BUFFER=$ERROR_READ_BUFFER
    else
        while [ $readslice_N -le "$readslice_byte_count" ]; do
            eval VALUE_SLICE="\"$VALUE_SLICE \$${readslice_buffername}_$readslice_head_index\""
            readslice_head_index=$(( readslice_head_index + 1))
            readslice_N=$(( readslice_N + 1 ))
        done

        eval "${readslice_buffername}_HEAD=$readslice_head_index"
    fi
    
    [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "readSlice buffername: $read_buffername, bytes: $readslice_byte_count, info: $readslice_info"

    unset readslice_N readslice_head_index readslice_byte_count readslice_buffername readslice_info readslice_bufferlength 

    return "$EXITCODE_BUFFER"
}

readUInt8()
# read unsigned 8-bit int from space delimited buffer of decimal number
# $1 buffername, $2 debug info
# set VALUE_UINT8
 {

    unset VALUE_UINT8

    EXITCODE_BUFFER=0
    read_buffername=$1
    read_info=$2

    if readSlice "$1" 1 "$2"; then
    #shellcheck disable=SC2086
      IFS=' '
      set -- $VALUE_SLICE
      VALUE_UINT8=$1
    else
      EXITCODE_BUFFER=$?
    fi

    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 readUInt8 buffername: "$read_buffername" uint8: "$VALUE_UINT8" info: "$read_info" 

    return $EXITCODE_BUFFER

}

readInt8() 
# read signed 8-bit int, 8-bit=sign bit,
# $1 buffername, $2 debug info
# sets VALUE_INT8
{
    unset VALUE_INT8

    EXITCODE_BUFFER=0
    read_buffername=$1
    read_info=$2

    if readUInt8 "$1" "$2"; then
        VALUE_INT8=$((-1 * (VALUE_UINT8 >> 7) * 0x80 + (VALUE_UINT8 & 0x7f)))
    else
        EXITCODE_BUFFER=$?
    fi

    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 readInt8 buffername: "$read_buffername" int8: "$VALUE_INT8" info: "$read_info" 

    return $EXITCODE_BUFFER

}

readUInt16BE() 
# read unsigned 16-bit int
# $1 buffername, $2 debug info
# set VALUE_UINT16BE
{
    unset VALUE_UINT16BE

    EXITCODE_BUFFER=0
    read_buffername=$1
    read_info=$2

    if readSlice "$1" 2 "$2"; then
        IFS=" "
        eval set -- "$VALUE_SLICE"
  
        VALUE_UINT16BE=$(( ($1 << 8 ) | $2 ))
    else
      EXITCODE_BUFFER=$?
    fi
  
    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 readUInt16BE buffername: "$read_buffername"  uint16: "$VALUE_UINT16BE" info: "$read_info" 

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
        EXITCODE_BUFFER=$?
    fi

    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 readInt16BE buffername: "$read_buffername"  int16: "$VALUE_INT16BE" info: "$read_info" 


    return "$EXITCODE_BUFFER"

}

readUInt32BE()
# read unsigned 32-bit int
# set VALUE_UINT32BE
# $1 buffername, $2 debug info
{
    unset VALUE_UINT32BE

    EXITCODE_BUFFER=0
    read_buffername=$1
    read_info=$2

    if readSlice "$1" 4 "$2"; then
        IFS=" "
        eval set -- "$VALUE_SLICE"
        
        VALUE_UINT32BE=$(( ( $1 << 24 ) | ( $2 << 16) | ( $3 << 8) | $4 ))
    else
        EXITCODE_BUFFER=$?
    fi
  
    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 echo >&2 readUInt32BE buffername: "$read_buffername"  uint32: "$VALUE_UINT32BE" info: "$read_info" 

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
        EXITCODE_BUFFER=$?
    fi

    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 echo >&2 readInt32BE buffername: "$read_buffername"  int32: "$VALUE_INT32BE" info: "$read_info" 


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