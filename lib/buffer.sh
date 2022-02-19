#!/bin/sh

DEBUG=${DEBUG:=0}
DEBUG_BUFFER=${DEBUG_BUFFER:=$DEBUG}
SHELL_SUPPORT_BULTIN_PRINTF_VOPT=${SHELL_SUPPORT_BULTIN_PRINTF_VOPT:=0}

newBuffer() 
# initialize new buffer
# $1 buffername, $2 value
{
    if [ -n "$1" ]; then
        eval "$1=\"$2\""
        [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "init buffer name: $1, value: $2"
    else
        [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "Error: no buffer name"
        return 1
    fi

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
# read a slice of n bytes from buffer, set B1,...,Bn
# $1 buffername, $2 number of bytes to read
 { 

    n=1
    while [ "$n" -le "$2" ]; do
        readUInt8 "$1" "slice byte $n"
        eval "B$n=$VALUE_UINT8"
        if [ "$n" -le 6 ]; then # auto convert to hex for printing of MAC/broadcast command
        #shellcheck disable=SC2027
           eval "convertUInt8ToHex \"\$B$n\"; B"$n"HEX=\$VALUE_UINT8_HEX"
        fi
        n=$((n + 1))
    done

    unset n
}

readUInt8()
# read unsigned 8-bit int from space delimited buffer of decimal numbers, removes uint in front of buffer and sets VALUE_UINT8
# $1 buffername, $2 debug info
 {
    readuint8_buffername="$1"
    readuint8_info="$2"

    unset VALUE_UINT8

    #if [ ${#OD_BUFFER} -ge 4 ]; then # 4 = max 3 spaces and 1 digit

        set -- "OD_BUFFER"
    # for BYTE in $OD_BUFFER; do
    #        VALUE_UINT8=$((BYTE))
    #        OD_BUFFER=${OD_BUFFER#*"$BYTE"} #  # - remove shortest prefix pattern
    #        break
    #    done
    eval "for BYTE in \$$1; do VALUE_UINT8=\$((BYTE)); $1=\${$1#*\"\$BYTE\"}; break; done " # # = remove shortest prefix
    # positional parameter $2 is destroyed? only $1 available
     [ "$DEBUG_BUFFER" -eq 1 ] && [ -n "$VALUE_UINT8" ] && echo >&2 readUInt8 buffername: "$readuint8_buffername"  uint8: "$VALUE_UINT8" info: "$readuint8_info"

   # else
    #    return "$ERROR_OD_BUFFER_EMPTY"
    #fi
    unset BYTE readuint_buffername readuint8_info
}

readInt8() 
# read signed 8-bit int, 8-bit=sign bit,sets VALUE_INT8
# $1 buffername, $2 debug info
{
    readUInt8 "$1" "$2"
    VALUE_INT8=$((-1 * (VALUE_UINT8 >> 7) * 0x80 + (VALUE_UINT8 & 0x7f)))
}

readUInt16BE() 
# read unsigned 16-bit int, sets VALUE_UINT16BE
# $1 buffername, $2 debug info
{
    unset VALUE_UINT16BE

    readUInt8 "$1" "uint16 $2 msb"
    msb=$VALUE_UINT8
    readUInt8 "$1" "uint16 $2 lsb"
    VALUE_UINT16BE=$(((msb << 8) | VALUE_UINT8))
    unset msb
}

readUInt32BE()
# read unsigned 32-bit int, set VALUE_UINT32BE
{
    unset VALUE_UINT32BE

    if [ ${#OD_BUFFER} -ge 19 ]; then
        readUInt8 OD_BUFFER "uint32 $2 msb"
        msb=$VALUE_UINT8

        readUInt8 OD_BUFFER "uint32 $2 lsb"
        lsb=$VALUE_UINT8
       
        readUInt8 OD_BUFFER "uint32 $2 msb2"
        msb2=$VALUE_UINT8
       
        readUInt8 OD_BUFFER "uint32 $2 lsb2"
        lsb2=$VALUE_UINT8

        VALUE_UINT32BE=$(((msb << 24) | (lsb << 16) | (msb2 << 8) | lsb2))
    else
        return "$ERROR_OD_BUFFER_EMPTY"
    fi

    unset msb lsb msb2 lsb2
}

readInt16BE() 
# read signed 16-bit int, 2's complement big endian, msb is the sign bit, set VALUE_INT16BE
# Converting from two's complement representation https://en.wikipedia.org/wiki/Two%27s_complement
# $1 buffername, $2 debug info
{ 
    #VALUE_INT16BE_HEX=$hexstr
    
    readUInt16BE "$1" "$2"

    VALUE_INT16BE=$((-1 * (VALUE_UINT16BE >> 15) * 32768 + (VALUE_UINT16BE & 32767)))
}

readInt32BE()
# read signed 32-bit int, 2's complement big endian, msb is the sign bit, set VALUE_UINT32BE
# $1 buffername, $2 debug info
{ 
    readUInt32BE "$1" "$2"
    VALUE_INT32BE=$((-1 * (VALUE_UINT32BE >> 31) * 0x80000000 + (VALUE_UINT32BE & 0x7fffffff)))
    [ "$DEBUG_BUFFER" -eq 1 ] && echo >&2 "readInt32BE unsigned 32-bit $VALUE_UINT32BE to signed 32-bit $VALUE_INT32BE"
}

readString()
# read string from buffer, set VALUE_STRING
# \x formatted printf format not supported in dash -> must use \nnn-octal format,
# https://bugs.launchpad.net/ubuntu/+source/dash/+bug/1499473
# $1 buffername, $2 debug info
 { 
   
    readUInt8 "$1" "string length"
    len_uint8=$VALUE_UINT8

    unset VALUE_STRING_ESCAPE
    unset VALUE_STRING

    n=1
    while [ "$n" -le "$len_uint8" ]; do

        readUInt8 "$1" "string byte $n"

        convertHexToOctal "$VALUE_UINT8"
        VALUE_STRING_ESCAPE="$VALUE_STRING_ESCAPE\\0$VALUE_OCTAL"

        n=$((n + 1))

    done

    if [ "$SHELL_SUPPORT_BULTIN_PRINTF_VOPT" -eq 1 ]; then
        #shellcheck disable=SC3045
         printf -v VALUE_STRING "%b" "$VALUE_STRING_ESCAPE"
    else
       VALUE_STRING=$(printf "%b" "$VALUE_STRING_ESCAPE") # convert to string
    fi
   
    [ $DEBUG_BUFFER -eq 1 ] && echo >&2 "readString: $VALUE_STRING length: ${#VALUE_STRING}"

    unset len_uint8 n
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