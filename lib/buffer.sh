#!/bin/sh

DEBUG=${DEBUG:=0}
DEBUG_BUFFER=${DEBUG_BUFFER:=$DEBUG}
SHELL_SUPPORT_BUILTIN_PRINTF_VOPT=${SHELL_SUPPORT_BUILTIN_PRINTF_VOPT:=0}
ERROR_READ_BUFFER=${ERROR_READ_BUFFER:=1}

# debug bash: set -o posix; set | grep GWBUFFER; set +o posix
# https://unix.stackexchange.com/questions/3510/how-to-print-only-defined-variables-shell-and-or-environment-variables-in-bash

newBuffer() 
# initialize new buffer with a space delimited decimal uint8 string
# $1 buffername, $2 value
# set $1_HEAD index of current read position (zero index)
# set $1_LENGTH number of bytes
# append $1 to GWBUFFER_NAMES to keep track of buffers
{
    EXITCODE_BUFFER=0

    newbuffer_name=$1
    newbuffer_value=$2

    unset buffer_index

    case $GWBUFFER_NAMES in
        *$newbuffer_name*) [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "newBuffer: overwrite $newbuffer_name"
                             destroyBuffer "$newbuffer_name" #overwrite
                            ;;
    esac

    eval "$newbuffer_name=\"$newbuffer_value\" ${newbuffer_name}_HEAD=0"

    GWBUFFER_NAMES="$GWBUFFER_NAMES$newbuffer_name " #keep track of buffernames

    IFS=' '
    eval set -- "$newbuffer_value"
    eval "${newbuffer_name}_LENGTH=$#"
    buffer_index=0
    while [ $buffer_index -lt $# ]; do
        eval "${newbuffer_name}_$buffer_index=\${$(( buffer_index + 1 ))}"
        buffer_index=$(( buffer_index + 1 ))
    done

    [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "new buffer; buffername: $newbuffer_name, value: $newbuffer_value, length: $#"
   
    unset newbuffer_name newbuffer_value buffer_index

    return "$EXITCODE_BUFFER"
}

destroyBuffer()
# unset buffer
# $1 buffername
{
    EXITCODE_BUFFER=0

    read_buffername=$1
    [ $DEBUG_BUFFER -eq 1 ] && eval echo >&2 "Destroying buffer $read_buffername , LENGTH \$${read_buffername}_LENGTH"

    case $GWBUFFER_NAMES in
      *$1*)
            GWBUFFER_NAMES=${GWBUFFER_NAMES#*"$read_buffername"*}
            eval buflen=\$"${read_buffername}_LENGTH"
            N=0
            #shellcheck disable=SC2154
            while [ $N -lt "$buflen" ]; do
                unset "${read_buffername}_$N"
                N=$(( N + 1 ))
            done 
            unset "${read_buffername}" "${read_buffername}_LENGTH" "${read_buffername}_HEAD" 


            ;;
       *)   echo >&2 "Error: Unknown buffername $1, known buffers $GWBUFFER_NAMES"
                 EXITCODE_BUFFER=$ERROR_READ_BUFFER
            ;;
    esac

    unset N buflen read_buffername

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

moveHEAD()
# moves HEAD pointer to index
#$1 buffername, $2 0-index
{
    [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "Moving HEAD buffername:$1, position:$2"
    eval "$1_HEAD=$2"
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
   DEBUG_BUFFER_STRING=${DEBUG_BUFFER_STRING:=$DEBUG_BUFFER}

  # PACKET_TX_BODY="${#1} $(printf "%s" "$1" | od -A n -t u1)"

    str=$2
    len=${#str}

    [ "$DEBUG_BUFFER_STRING" -eq 1 ] && >&2 echo  "writeString buffername:$1 string:$2 strlen: $len info: $3"

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

    if [ "$SHELL_SUPPORT_BUILTIN_PRINTF_VOPT" -eq  1 ] && [ -n "$APPEND_FORMAT_WRITE_STRING" ]; then
        [ "$DEBUG_BUFFER_STRING" -eq 1 ] && { echo >&2 "writeString: converting string"; set -x; }
        eval printf -v decstr \""$APPEND_FORMAT_WRITE_STRING"\" "$APPEND_STRING"
        #shellcheck disable=SC2154
        eval "$1=\"\$$1 $decstr\""
        [ "$DEBUG_BUFFER_STRING" -eq 1 ] && set +x

    elif [ -n "$APPEND_FORMAT_WRITE_STRING" ]; then
        [ "$DEBUG_BUFFER_STRING" -eq 1 ] && { echo >&2 "writeString: converting string"; set -x; }
         eval "$1=\"\$$1 $(eval printf \""$APPEND_FORMAT_WRITE_STRING"\" "$APPEND_STRING")\""
         [ "$DEBUG_BUFFER_STRING" -eq 1 ] && set +x
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
# $1 buffername, $2 number of bytes to read, $3 debug info, $4 start position (optional)
# set VALUE_SLICE - new buffer of $2 bytes
 { 
     unset VALUE_SLICE

     EXITCODE_BUFFER=0

     readslice_buffername=$1
     readslice_byte_count=$2
     readslice_info=$3
     readslice_startpos=$4

     if [ -n "$readslice_startpos" ]; then
        [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "readSlice: Moving HEAD buffername: $readslice_buffername, position: $readslice_startpos"
        moveHEAD "$readslice_buffername" "$readslice_startpos"
     fi

    readslice_N=1
    eval readslice_head_index="\$${readslice_buffername}_HEAD" readslice_buffer_length="\$${readslice_buffername}_LENGTH"
    #shellcheck disable=SC2154
    if ! [ $((readslice_head_index + readslice_byte_count )) -le "$readslice_buffer_length" ]; then
        echo >&2 "Error: readSlice: Attempt to read beyond buffer limit; buffername: $readslice_buffername, bufferlength: $readslice_buffer_length"
        EXITCODE_BUFFER=$ERROR_READ_BUFFER
    else
        while [ $readslice_N -le "$readslice_byte_count" ]; do
            eval VALUE_SLICE="\"$VALUE_SLICE \$${readslice_buffername}_$readslice_head_index\""
            readslice_head_index=$(( readslice_head_index + 1))
            readslice_N=$(( readslice_N + 1 ))
        done

        eval "${readslice_buffername}_HEAD=$readslice_head_index"
    fi
    
    [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "readSlice buffername: $readslice_buffername, bytes: $readslice_byte_count, info: $readslice_info"

    unset readslice_N readslice_head_index readslice_byte_count readslice_buffername readslice_info readslice_buffer_length readslice_startpos

    return "$EXITCODE_BUFFER"
}

readUInt8()
# read unsigned 8-bit int from space delimited buffer of decimal number
# $1 buffername, $2 debug info, $3 start position 0-indexed (optional)
# set VALUE_UINT8
 {

    unset VALUE_UINT8

    EXITCODE_BUFFER=0
    read_buffername=$1
    read_info=$2
    read_startpos=$3

    if readSlice "$1" 1 "$2" "$3"; then
      IFS=' '
        #shellcheck disable=SC2086
      set -- $VALUE_SLICE
      VALUE_UINT8=$1
    else
      EXITCODE_BUFFER=$?
    fi

    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 readUInt8 buffername: "$read_buffername" uint8: "$VALUE_UINT8" info: "$read_info" startpos: "$read_startpos"

    unset read_buffername read_info read_startpos

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

    unset read_buffername read_info 

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

    unset read_buffername read_info 

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

    unset read_buffername read_info 

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
  
    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 readUInt32BE buffername: "$read_buffername"  uint32: "$VALUE_UINT32BE" info: "$read_info" 

    unset read_buffername read_info 

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

    unset read_buffername read_info 

    return "$EXITCODE_BUFFER"
}

readString()
# read string from buffer, set VALUE_STRING
# \x formatted printf format not supported in dash -> must use \nnn-octal format,
# https://bugs.launchpad.net/ubuntu/+source/dash/+bug/1499473
# $1 buffername, $2 debug info
# only support for dec 0-127: !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
 { 
     DEBUG_BUFFER_STRING=${DEBUG_BUFFER_STRING:=$DEBUG_BUFFER}
   
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

        if [ "$SHELL_SUPPORT_BUILTIN_PRINTF_VOPT" -eq 1 ]; then
                    [ $DEBUG_BUFFER_STRING -eq 1 ] && { echo >&2 "readString: Converting escaped octal string to string"; set -x; }
            #shellcheck disable=SC3045
            printf -v VALUE_STRING "%b" "$VALUE_STRING_ESCAPE"
                         [ $DEBUG_BUFFER_STRING -eq 1 ] && set +x

        else
            [ $DEBUG_BUFFER_STRING -eq 1 ] && {  echo >&2 "readString: Converting escaped octal string to string"; set -x; }
             VALUE_STRING=$(printf "%b" "$VALUE_STRING_ESCAPE") # convert to string
             [ $DEBUG_BUFFER_STRING -eq 1 ] && set +x

        fi
     fi

    [ $DEBUG_BUFFER_STRING -eq 1 ] && echo >&2 "readString: $VALUE_STRING length: ${#VALUE_STRING}"

    unset len_uint8 n read_info read_buffername

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
    localn=0
    for BYTE in $1; do
        convertUInt8ToHex "$BYTE"
        APPEND_STRING=$APPEND_STRING" $VALUE_UINT8_HEX"
        localn=$(( localn + 1))
    done
    
    echo "$APPEND_STRING ($localn bytes)"

    unset BYTE APPEND_STRING localn

}