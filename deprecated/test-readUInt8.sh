#!/bin/sh

ERROR_EOF_OD_BUFFER=10

readUInt8new () 
{
    
     if [ "$SHELL_SUPPORT_TYPESET" -eq 1 ]; then
        #shellcheck disable=SC3044
        {
        typeset prefixDeleteSubstring
        typeset byte
        }
    else
       local prefixDeleteSubstring
       local byte
    fi

    unset VALUE_UINT8
    unset VALUE_UINT8_HEX

    if [ ${#OD_BUFFER} -ge 2 ]; then 
       # prefixDeleteSubstring=${OD_BUFFER#??} # '?? ' - first byte pattern
       # B1=${OD_BUFFER%%$prefixDeleteSubstring}
       # OD_BUFFER=${prefixDeleteSubstring# }
       for byte in $OD_BUFFER; do
         VALUE_UINT8_HEX=$byte
         VALUE_UINT8=$(( 0x$byte ))
         OD_BUFFER=${OD_BUFFER##"$byte "}
         break;
        done
    else
      return "$ERROR_EOF_OD_BUFFER"
    fi

}

readUInt16BEnew ()
{

    unset VALUE_UINT16BE
    unset VALUE_UINT16BE_HEX

    if [ ${#OD_BUFFER} -ge 5 ]; then # 5 - length of two hex bytes + space

        #VALUE_UINT16BE_HEX=$B1$B2
        readUInt8new
        VALUE_UINT16BE_HEX=$VALUE_UINT8_HEX
        readUInt8new
        VALUE_UINT16BE_HEX=$VALUE_UINT16BE_HEX$VALUE_UINT8_HEX
        VALUE_UINT16BE=$(( 0x$VALUE_UINT16BE_HEX ))
    else
      return "$ERROR_EOF_OD_BUFFER"
    fi
}

set -x
SHELL_SUPPORT_TYPESET=0
OD_BUFFER='11 22 33 44 55'
#readUInt8new
#readUInt8new
#readUInt8new
readUInt16BEnew
#readUInt16BEnew
#readUInt16BEnew
set +x