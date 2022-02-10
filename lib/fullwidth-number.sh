#!/bin/sh

FW_0=０
FW_1=１
FW_2=２
FW_3=３
FW_4=４
FW_5=５
FW_6=６
FW_7=７
FW_8=８
FW_9=９

convertNumberToUnicodeFullwidth()
{
    DEBUG_FUNC=convertNumberToUnicodeFullwidth
    EXITCODE_convertNumberToUnicodeFullwidth=0
    numberToConvert=$1
 

    unset fw

    while [ ${#numberToConvert} -gt 0 ]; do
        suffix=${numberToConvert#?}
        fwnum=${numberToConvert%%"$suffix"} # get first character of string by deleting suffix
        case "$fwnum" in
           [0-9,.]) #shellcheck disable=SC2154
                    eval fw="$fw\$FW_$fwnum"
                    ;;
              *)    echo >&2 $DEBUG_FUNC Unsupported fullwidth conversion of "$fwnum"
                    EXITCODE_convertNumberToUnicodeFullwidth=1
                    ;;
        esac
        numberToConvert=$suffix
    done

    VALUE_FULLWIDTH=$fw
    unset DEBUG_FUNC fw suffix fwnum numberToConvert

    return $EXITCODE_convertNumberToUnicodeFullwidth
}
