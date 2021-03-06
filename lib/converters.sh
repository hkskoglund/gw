#!/bin/sh

getHexDigit() {
    unset VALUE_HEX_DIGIT

    if [ "$1" -ge 0 ] && [ "$1" -le 9 ]; then
        VALUE_HEX_DIGIT=$1
    elif [ "$1" -eq 10 ]; then
        VALUE_HEX_DIGIT='a'
    elif [ "$1" -eq 11 ]; then
        VALUE_HEX_DIGIT='b'
    elif [ "$1" -eq 12 ]; then
        VALUE_HEX_DIGIT='c'
    elif [ "$1" -eq 13 ]; then
        VALUE_HEX_DIGIT='d'
    elif [ "$1" -eq 14 ]; then
        VALUE_HEX_DIGIT='e'
    elif [ "$1" -eq 15 ]; then
        VALUE_HEX_DIGIT='f'
    fi
}

getFloatAsIntDecmial()
#$1 - floating point number
#get int and decimal portion; int.decimals
#assumes always . present in $1
{
    FLOAT_INT=${1%%.*}
    FLOAT_DECIMALS=${1#*.}
    FLOAT_SCALE10=${#FLOAT_DECIMALS}
    if [ "$FLOAT_INT" = 0 ]; then # we have a number 0.???
      while [ ${#FLOAT_DECIMALS} -gt 1 ]; do # removes leadning zeros, otherwise number is intepreted as  octal
        case "$FLOAT_DECIMALS" in
                0*) FLOAT_DECIMALS=${FLOAT_DECIMALS#0} # removes zeros after .
                    true
                    ;;
                *) break # this while loop
                   false
                   ;;
        esac
      done
      FLOAT_AS_INT=$FLOAT_DECIMALS
    else
      FLOAT_AS_INT=$FLOAT_INT$FLOAT_DECIMALS
    fi

    if [ "$SHELL_SUPPORT_MATH_POWER" -eq 1 ]; then
      #shellcheck disable=SC3019
      CONVERT_10MULTIPLIER=$(( 10 ** FLOAT_SCALE10))
    else
        n=2
        CONVERT_10MULTIPLIER=10
        while [ "$n" -le "$FLOAT_SCALE10" ]; do # power of 10 
            CONVERT_10MULTIPLIER=$(( CONVERT_10MULTIPLIER * 10))
            n=$(( n + 1 ))
        done
    fi

    unset n
}

convert_farenheit_to_celciusScale10()
#tempinf=72.7
#$2 - number of digits after . -> using power to scale value
{
    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 0 ]; then
        # VALUE_CELCIUS_SCALE10=$(printf %.0f "$(echo "($1 - 32 )*50/9" | bc)")
        getFloatAsIntDecmial "$1"
        VALUE_CELCIUS_SCALE10=$(( (FLOAT_AS_INT - 32*CONVERT_10MULTIPLIER) * 500 / (9*CONVERT_10MULTIPLIER) ))
        round "$VALUE_CELCIUS_SCALE10"
        VALUE_CELCIUS_SCALE10=$VALUE_ROUND
    else
        #shellcheck disable=SC2079
        VALUE_CELCIUS_SCALE10=$(( ($1 - 32 )*50/9.0 ))
    fi
    [ "$DEBUG" -eq 1 ] && echo >&2 "Converted $1 farenheit to $VALUE_CELCIUS_SCALE10 celcius - scale 10"

}

convert_celcius_to_farenheitScale10()
{
    # VALUE_CELCIUS_SCALE10=$(printf %.0f "$(echo "($1 - 32 )*50/9" | bc)")
    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 0 ]; then
        getFloatAsIntDecmial "$1"
        VALUE_FARENHEIT_SCALE10=$(( (FLOAT_AS_INT*9/5) + 32*CONVERT_10MULTIPLIER ))
    else
        #shellcheck disable=SC2079
        VALUE_FARENHEIT_SCALE10=$(( ( $1 - 32.0) *50/9 ))
    fi
    [ "$DEBUG" -eq 1 ] && echo >&2 "Converted $1 celcius to $VALUE_FARENHEIT_SCALE10 farenheit - scale 10"

}

convert_celciusScale10_to_farenheitScale10()
{
    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 0 ]; then
        VALUE_FARENHEIT_SCALE10=$(( ($1*9/5) + 320 ))
    else
        #shellcheck disable=SC2079
        VALUE_FARENHEIT_SCALE10=$(( ( $1*9.0/5) + 320 ))
    fi
     [ "$DEBUG" -eq 1 ] && echo >&2 "Converted $1 celcius to $VALUE_FARENHEIT_SCALE10 farenheit - scale 10"

}

convert_inhg_to_hpa()
#convert from inhg to hpa
#baromrelin=29.731 -> 3 decimals -> multiply by 1000 = 29731
#assumes always 3 decimals after .
#some info: http://justinparrtech.com/JustinParr-Tech/programming-tip-turn-floating-point-operations-in-to-integer-operations/
#https://en.wikipedia.org/wiki/Inch_of_mercury
#using: SI unit 1 inHg = 3.38639 kPa
{
       # VALUE_INHG_HPA_SCALE10=$(printf %.0f "$(echo "338.639 * $1" | bc)")

    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 0 ]; then

        getFloatAsIntDecmial "$1"

        case "$KSH_VERSION" in 
                *MIRBSD?KSH*)
                    # maybe use $((# )) for 32-bit usigned int expression
                    VALUE_INHG_HPA_SCALE10=$(( (4233 * FLOAT_AS_INT)/ 1250)) # round conversion constant/scale down 10 -> 338639 -> 338640
                    #factorize 33864=8*4233, 10000=8*1250, $(( (33864 * FLOAT_AS_INT)/ 10000)) -> $(( (4233 * FLOAT_AS_INT)/ 1250))
                    ;;
                *)
                    #does not work with 32-bit unsigned integer arithmetic as used by mksh with $((# ... ))
                    VALUE_INHG_HPA_SCALE10=$(( (338639 * FLOAT_AS_INT) / 100000)) # use interger arithmetic
                    ;;
            esac
        
        round "$VALUE_INHG_HPA_SCALE10"
        VALUE_INHG_HPA_SCALE10=$VALUE_ROUND
    else
        #shellcheck disable=SC2079
        VALUE_INHG_HPA_SCALE10=$(( $1 * 338.639 ))
    fi
    [ "$DEBUG" -eq 1 ] && echo >&2 "Converted $1 inhg to $VALUE_INHG_HPA_SCALE10 hpa - scale 10"
}

convert_hpaScale10_To_inhgScale10()
#using: SI unit 1 inHg = 3.38639 kPa
{
    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 0 ]; then
        round $(( $1 * 100000 / 338639  ))
        VALUE_INHG_SCALE10=$VALUE_ROUND
    else
            #shellcheck disable=SC2079
       VALUE_INHG_SCALE10=$(( $1 * 1/ 33.8639 ))
    fi

    [ "$DEBUG" -eq 1 ] && echo >&2 "Converted $1 hpa to $VALUE_INHG_SCALE10 - scale 10"
}

round()
{

    [ "$DEBUG" -eq 1 ] && >&2 echo "round $1"

    modulo=$(( $1 % 10 ))
    if [ $modulo -ge 5 ]; then
        VALUE_ROUND=$(( $1 + 10 - modulo )) # round up
    else
        VALUE_ROUND=$(( $1 - modulo )) #round down
    fi

   VALUE_ROUND=$(( VALUE_ROUND / 10 ))

    unset modulo
}

convert_mph_To_mps()
# https://www.convertunits.com/from/mph/to/m/s
# 1 mph is equal to 0.44704 meter/second.
# format: speedmph=5.82&windgustmph=10.29&maxdailygust=15.88 -> 2 digits after .
#using International mile: using scaling 63360/141732 
{
   #VALUE_MPS_SCALE10=$(printf %.0f "$(echo "4.4704 * $1" | bc)")

   if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 0 ]; then
        getFloatAsIntDecmial "$1"
    
        #factorize : 63360 = 18*3520, 141732 = 18* 7874 -> $(( 63360 * FLOAT_AS_INT/ 141732)) -> $(( 3520 * FLOAT_AS_INT / 7874 ))
        #https://www.calculatorsoup.com/calculators/math/factors.php?input=141732&action=solve
    
        round "$(( 3520 * FLOAT_AS_INT / 7874 ))"
        VALUE_MPS_SCALE10=$VALUE_ROUND
    else
        #shellcheck disable=SC2079
        VALUE_MPS_SCALE10=$(( $1 * 4.4704 ))
    fi
    [ "$DEBUG" -eq 1 ] && echo >&2 "Convert mph $1 to mps $VALUE_MPS_SCALE10 scale 10"

}

convert_mpsScale10_To_kmhScale10()
{
    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 0 ]; then
        round "$(( $1 * 36 ))" # really scale * 100
        VALUE_KMH_SCALE10=$VALUE_ROUND
    else
        #shellcheck disable=SC2079
         VALUE_KMH_SCALE10=$(( $1 * 3.6 ))
    fi
    [ "$DEBUG" -eq 1 ] && echo >&2 "Convert mps $1 to mph $VALUE_KMH_SCALE10 scale 10"

}

convcert_mpsScale10_to_mphScale10()
{

    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 0 ]; then
        #factorize:  10000000 = 32*312500, 44704 = 32*1397 $(( 10000000/44704 )) -> $ (( 312500 / 1397))
        round "$(( $1*31250 / 1397))"
        VALUE_MPH_SCALE10=$VALUE_ROUND
    else
        #shellcheck disable=SC2079
        VALUE_MPH_SCALE10=$(( $1 * 3125/ 1397.0 ))
    fi
    [ "$DEBUG" -eq 1 ] && echo >&2 "Convert mps $1 to mph $VALUE_MPH_SCALE10 scale 10"
}

convert_mph_to_kmhScale10()
#http request: wind is in mph, -u w=kmh to convert
{
    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 0 ]; then
        getFloatAsIntDecmial "$1"     #format: speedmph=5.82 -> 582
        #1mph=1.609344 km/h -> 1609344/1000000 -> largerst factor = 64 -> 64*25146/64*15625 -> 25146/15625
        round "$(( FLOAT_AS_INT * 251467/156250 ))"
        VALUE_KMH_SCALE10=$VALUE_ROUND
    else
        #shellcheck disable=SC2079
        VALUE_KMH_SCALE10=$(( $1 * 16.09344 ))
    fi
    [ "$DEBUG" -eq 1 ] && echo >&2 "Convert mph $1 to kmh $VALUE_KMH_SCALE10 scale 10"

}

convert_in_to_mm()
#1 inch SI unit = 25.4 mm
#https://en.wikipedia.org/wiki/Inch
# web format: rainratein=0.000&eventrainin=0.669&hourlyrainin=0.000&dailyrainin=0.028&weeklyrainin=0.831&monthlyrainin=0.972&yearlyrainin=17.130&totalrainin=17.130
{
    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 0 ]; then
        getFloatAsIntDecmial "$1"

        #factorize 254=2*127, 100=2*50 -> $(( 254 * FLOAT_AS_INT / 100)) -> $(( 127 * FLOAT_AS_INT / 50 ))
        round "$(( 127 * FLOAT_AS_INT / 50))"
        VALUE_IN_MM_SCALE10=$VALUE_ROUND
    else
        VALUE_IN_MM_SCALE10=$(( $1 * 254 ))
    
    fi
    [ "$DEBUG" -eq 1 ] && echo >&2 "Convert in $1 to mm $VALUE_IN_MM_SCALE10 scale 10"

}

convertScale10ToFloat() {
    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 1 ]; then
        #shellcheck disable=SC2079
        VALUE_SCALE10_FLOAT=$(( $1 / 10.0 ))
    else
        convertScale10ToFloatInt "$1"
    fi

}

convertScale10ToFloatInt() {
    # $1 - number to convert

    unset VALUE_SCALE10_FLOAT

    if [ -z "$1" ]; then
        echo >&2 "Error convertScale10ToFloat no number to convert (scale 10 value)"
        return "$ERROR_CONVERT"
    fi

    number=$(($1))
    if [ "$number" -lt 0 ]; then
        number=$((number * -1))
        sign="-"
    fi

    if [ "$number" -lt 10 ]; then
        VALUE_SCALE10_FLOAT=$sign"0$SHELL_DECIMAL_POINT"$number
    else
        int=$((number / 10))
        frac=$((number - int * 10))
        VALUE_SCALE10_FLOAT=$sign$int$SHELL_DECIMAL_POINT$frac
    fi

    unset int frac number sign
}

convertFloatToScale10()
{
    DEBUG_CONVERT=${DEBUG_CONVERT:=$DEBUG}
    EXITCODE_CONVERTFLOAT_SCALE10=0

    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 1 ]; then
         VALUE_FLOAT_SCALE10=$(( $1 * 10))
         roundFloat "$VALUE_FLOAT_SCALE10"
         VALUE_FLOAT_SCALE10=$VALUE_FLOAT_TO_INT
    else
    
        unset sign

        case "$1" in
            *.*)    int=${1%%.*} # . suffix remove -> integer part
                    case "$int" in
                        -*) sign=-1; int=${int#-}; ;;
                        *) sign=1 ;;
                    esac
                    dec=${1##*.} # prefix . remove -> decimal part
                    if isNumber "$int" && isNumber "$dec"; then
                        dec_suffix=${dec#?} #deletes first digit
                        dec=${dec%%"$dec_suffix"} # no rounding, just cut off
                        VALUE_FLOAT_SCALE10_ABS=$(( $int$dec ))
                        VALUE_FLOAT_SCALE10=$(( sign*$int$dec ))
                    else
                        EXITCODE_CONVERTFLOAT_SCALE10="$ERROR_CONVERT"
                    fi
                    ;;

            *)  int=$1
                case "$int" in
                    -*) sign=-1; int=${int#-} ;;
                    *) sign=1 ;;
                esac
                if isNumber "$int"; then
                        VALUE_FLOAT_SCALE10_ABS=$(( int * 10 )) 
                        VALUE_FLOAT_SCALE10=$(( sign * int * 10 ))
                else
                    EXITCODE_CONVERTFLOAT_SCALE10="$ERROR_CONVERT"
                fi
                ;;
        esac
    fi

    [ "$DEBUG_CONVERT" -eq 1 ] && echo >&2 "Converting float $1 to $VALUE_FLOAT_SCALE10 (scale 10)" 

    unset int dec dec_suffix sign DEBUG_CONVERT

    return "$EXITCODE_CONVERTFLOAT_SCALE10"

}


convertFloatToScale10()
{
    DEBUG_CONVERT=${DEBUG_CONVERT:=$DEBUG}
    EXITCODE_CONVERTFLOAT_SCALE10=0

    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 1 ]; then
         VALUE_FLOAT_SCALE10=$(( $1 * 10))
         roundFloat "$VALUE_FLOAT_SCALE10"
         VALUE_FLOAT_SCALE10=$VALUE_FLOAT_TO_INT
    else
    
        unset sign

        case "$1" in
            *.*)    int=${1%%.*} # . suffix remove -> integer part
                    case "$int" in
                        -*) sign=-1; int=${int#-}; ;;
                        *) sign=1 ;;
                    esac
                    dec=${1##*.} # prefix . remove -> decimal part
                    if isNumber "$int" && isNumber "$dec"; then
                        dec_suffix=${dec#?} #deletes first digit
                        dec=${dec%%"$dec_suffix"} # no rounding, just cut off
                        VALUE_FLOAT_SCALE10_ABS=$(( $int$dec ))
                        VALUE_FLOAT_SCALE10=$(( sign*$int$dec ))
                    else
                        EXITCODE_CONVERTFLOAT_SCALE10="$ERROR_CONVERT"
                    fi
                    ;;

            *)  int=$1
                case "$int" in
                    -*) sign=-1; int=${int#-} ;;
                    *) sign=1 ;;
                esac
                if isNumber "$int"; then
                        VALUE_FLOAT_SCALE10_ABS=$(( int * 10 )) 
                        VALUE_FLOAT_SCALE10=$(( sign * int * 10 ))
                else
                    EXITCODE_CONVERTFLOAT_SCALE10="$ERROR_CONVERT"
                fi
                ;;
        esac
    fi

    [ "$DEBUG_CONVERT" -eq 1 ] && echo >&2 "Converting float $1 to $VALUE_FLOAT_SCALE10 (scale 10)" 

    unset int dec dec_suffix sign DEBUG_CONVERT

    return "$EXITCODE_CONVERTFLOAT_SCALE10"

}

convertHexToOctal() { #$1 - 0xff format
    if [ "$SHELL_SUPPORT_BULTIN_PRINTF_VOPT" -eq 1 ]; then
    #shellcheck disable=SC3045
       printf -v VALUE_OCTAL "%03o" "$1"
       return
    fi

    dec=$(($1))

    lsb=$((dec & 7)) #least significant 3-bit sequence
    middle=$(((dec >> 3) & 7))
    msb=$((dec >> 6))
    VALUE_OCTAL=$msb$middle$lsb

    [ "$DEBUG" -eq 1 ] && echo >&2 Converting "$1" to octal "$VALUE_OCTAL"

    unset dec lsb msb middle
}

convertBufferFromDecToOctalEscape() {
    unset VALUE_OCTAL_BUFFER_ESCAPE

    for BYTE in $1; do
        convertHexToOctal "$BYTE"
        VALUE_OCTAL_BUFFER_ESCAPE="$VALUE_OCTAL_BUFFER_ESCAPE\\0$VALUE_OCTAL"
    done

    [ "$DEBUG" -eq 1 ] && echo >&2 "Octal buffer $VALUE_OCTAL_BUFFER_ESCAPE"

    unset BYTE
}

convert_wattm2_to_lux()
#format : 42.94 watt
{
    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 1 ]; then
       VALUE_SCALE10_FLOAT=$(( $1 * 136000/1075 ))
    else
        getFloatAsIntDecmial "$1"
        VALUE_LUX_SCALE10=$(( FLOAT_AS_INT*13600/1075 ))
        convertScale10ToFloat "$VALUE_LUX_SCALE10"
    fi

    [ "$DEBUG" -eq 1 ] && echo >&2 "Convert $1 $UNIT_LIGHT_WATTM2 to $VALUE_SCALE10_FLOAT lux, shell floating point support: $SHELL_SUPPORT_FLOATINGPOINT"
}

convertLightLivedata()
{
     if [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_LUX" ]; then
                VALUE_LUX_SCALE10=$1
                convertScale10ToFloat "$VALUE_LUX_SCALE10"
             
            elif [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_WATTM2" ]; then

                #lux 976 -> ecowitt protcol: 7.7 W/m2
                #https://help.ambientweather.net/help/why-is-the-lux-to-w-m-2-conversion-factor-126-7/
                VALUE_WATTM2_SCALE10=$(( LIVEDATA_SOLAR_LIGHT_INTS10*1075/136000 ))
                convertScale10ToFloat "$VALUE_WATTM2_SCALE10"
                export LIVEDATA_SOLAR_LIGHT="$VALUE_SCALE10_FLOAT"
            fi
}

convertTemperatureLivedata()
# convert temperature scale 10 to float
# $1 temp x 10
{
    if [ "$UNIT_TEMPERATURE_MODE" -eq "$UNIT_TEMPERATURE_CELCIUS" ]; then
        VALUE_CELCIUS_SCALE10=$1
        convertScale10ToFloat "$VALUE_CELCIUS_SCALE10"
    elif [ "$UNIT_TEMPERATURE_MODE" -eq "$UNIT_TEMPERATURE_FARENHEIT" ]; then
        convert_celciusScale10_to_farenheitScale10 "$1"
        convertScale10ToFloat "$VALUE_FARENHEIT_SCALE10"
    fi
}

convertPressureLivedata()
{
    if [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_HPA" ]; then
        VALUE_HPA_SCALE10=$1
        convertScale10ToFloat "$VALUE_HPA_SCALE10"
    elif [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_INHG" ]; then
        convert_hpaScale10_To_inhgScale10 "$1"
        convertScale10ToFloat "$VALUE_INHG_SCALE10"
    fi
}

convertWindLivedata()
{
    if [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_MPS" ]; then
        VALUE_MPS_SCALE10=$1
        convertScale10ToFloat "$VALUE_MPS_SCALE10"
    elif [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_MPH" ]; then
        convcert_mpsScale10_to_mphScale10 "$1"
        convertScale10ToFloat "$VALUE_MPH_SCALE10"
    elif [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_KMH" ]; then
        convert_mpsScale10_To_kmhScale10 "$1"
        convertScale10ToFloat "$VALUE_KMH_SCALE10"
    fi
}

convertWindDirectionToCompassDirection() { #$1 - direction in degrees
    #http://snowfence.umn.edu/Components/winddirectionanddegrees.htm
    unset VALUE_COMPASS_DIRECTION

    if [ "$1" -le 11 ] || [ "$1" -gt 349 ]; then
        VALUE_COMPASS=$WIND_N
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_N
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_N
    elif [ "$1" -gt 11 ] && [ "$1" -lt 34 ]; then
        VALUE_COMPASS=$WIND_NNE
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_NNE
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_NE
    elif [ "$1" -ge 34 ] && [ "$1" -le 56 ]; then
        VALUE_COMPASS=$WIND_NE
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_NE
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_NE
    elif [ "$1" -gt 56 ] && [ "$1" -le 79 ]; then
        VALUE_COMPASS=$WIND_ENE
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_ENE
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_NE
    elif [ "$1" -gt 79 ] && [ "$1" -le 101 ]; then
        VALUE_COMPASS=$WIND_E
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_E
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_E
    elif [ "$1" -gt 101 ] && [ "$1" -le 124 ]; then
        VALUE_COMPASS=$WIND_ESE
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_ESE
         VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_SE
    elif [ "$1" -gt 124 ] && [ "$1" -le 146 ]; then
       VALUE_COMPASS=$WIND_SE
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_SE
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_SE
    elif [ "$1" -gt 146 ] && [ "$1" -le 169 ]; then
        VALUE_COMPASS=$WIND_SSE
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_SSE
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_SE
    elif [ "$1" -gt 169 ] && [ "$1" -le 191 ]; then
        VALUE_COMPASS=$WIND_S
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_S
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_S
    elif [ "$1" -gt 191 ] && [ "$1" -le 214 ]; then
        VALUE_COMPASS=$WIND_SSW
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_SSW
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_SW
    elif [ "$1" -gt 214 ] && [ "$1" -le 236 ]; then
        VALUE_COMPASS=$WIND_SW
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_SW
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_SW
    elif [ "$1" -gt 236 ] && [ "$1" -le 259 ]; then
        VALUE_COMPASS=$WIND_WSW
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_WSW
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_SW
    elif [ "$1" -gt 259 ] && [ "$1" -le 281 ]; then
        VALUE_COMPASS=$WIND_W
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_W
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_W
    elif [ "$1" -gt 281 ] && [ "$1" -le 304 ]; then
        VALUE_COMPASS=$WIND_WNW
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_WNW
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_NW
    elif [ "$1" -gt 304 ] && [ "$1" -le 326 ]; then
        VALUE_COMPASS=$WIND_NW
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_NW
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_NW
    elif [ "$1" -gt 326 ] && [ "$1" -le 349 ]; then
        VALUE_COMPASS=$WIND_NNW
        VALUE_COMPASS_DIRECTION=$WIND_DIRECTION_NNW
        VALUE_COMPASS_DIRECTION_UNICODE=$UNICODE_WIND_DIRECTION_NW
    fi
}

convertUInt8ToHex() {
#$1 - decimal value to convert to hex
    if [ "$SHELL_SUPPORT_BULTIN_PRINTF_VOPT" -eq 1 ]; then
    #shellcheck disable=SC3045
        printf -v VALUE_UINT8_HEX "%02x" "$1"
        return
    fi

    lsb=$(($1 & 0xf))
    getHexDigit "$lsb"
    lsb_hexdigit=$VALUE_HEX_DIGIT

    if [ "$1" -gt 15 ]; then
        msb=$(($1 >> 4))
        getHexDigit "$msb"
        VALUE_UINT8_HEX=$VALUE_HEX_DIGIT$lsb_hexdigit
    else
        VALUE_UINT8_HEX=0$VALUE_HEX_DIGIT
    fi

    unset lsb lsb_hexdigit msb
}

setLightHttpLivedata()
{
    if [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_LUX" ]; then
        convert_wattm2_to_lux "$2"
        eval export "$1"="$VALUE_SCALE10_FLOAT"
    elif [ "$UNIT_LIGHT_MODE" -eq "$UNIT_LIGHT_WATTM2" ]; then #default in http request, no conversion
          eval export "$1"="$2"
    fi
}

setPressureHttpLivedata()
{
    convert_inhg_to_hpa "$2"
    
    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 1 ]; then
       roundFloat "$VALUE_INHG_HPA_SCALE10"
       VALUE_INHG_HPA_SCALE10=$VALUE_FLOAT_TO_INT
    fi

    eval export "$1"_INTS10="$VALUE_INHG_HPA_SCALE10"
    
    if [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_HPA" ]; then
        convertScale10ToFloat "$VALUE_INHG_HPA_SCALE10"
        eval export "$1"="$VALUE_SCALE10_FLOAT"
    elif [ "$UNIT_PRESSURE_MODE" -eq "$UNIT_PRESSURE_INHG" ]; then
        eval export "$1"="$2"
    fi
}

setWindHttpLivedata()
{
    if [ "$2" = "$WUNDERGROUND_UNDEFINED_VALUE" ]; then
      return
    fi

    convert_mph_To_mps "$2"

    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 1 ]; then
        roundFloat "$VALUE_MPS_SCALE10"
        VALUE_MPS_SCALE10=$VALUE_FLOAT_TO_INT
    fi
    
    eval export "$1_INTS10=$VALUE_MPS_SCALE10"
    
    if [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_MPS" ]; then
       convertScale10ToFloat "$VALUE_MPS_SCALE10"
       eval export "$1"="$VALUE_SCALE10_FLOAT"
    elif [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_MPH" ]; then
       eval export "$1"="$2"
    elif [ "$UNIT_WIND_MODE" -eq "$UNIT_WIND_KMH" ]; then
       convert_mph_to_kmhScale10 "$2"
       convertScale10ToFloat "$VALUE_KMH_SCALE10"
       eval export "$1"="$VALUE_SCALE10_FLOAT"
    fi
}

setWindDirHttpLivedata()
{
    if [ "$2" = "$WUNDERGROUND_UNDEFINED_VALUE" ]; then
      return
    fi
 
    eval export "$1_INTS10"="$2" 
    convertWindDirectionToCompassDirection "$2"
    eval export "$1"_COMPASS="$VALUE_COMPASS_DIRECTION"
    eval export "$1"_COMPASS_UNICODE="$VALUE_COMPASS_DIRECTION_UNICODE"

}

setRainHttpLivedata()
#$1 - field name
#$2 - value
{
    convert_in_to_mm "$2"

    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 1 ]; then
        roundFloat "$VALUE_IN_MM_SCALE10"
        VALUE_IN_MM_SCALE10=$VALUE_FLOAT_TO_INT
    fi
    
    eval export "$1_INTS10"="$VALUE_IN_MM_SCALE10"
    
    if [ "$UNIT_RAIN_MODE" -eq "$UNIT_RAIN_MM" ]; then
        convertScale10ToFloat "$VALUE_IN_MM_SCALE10"
        eval export "$1"="$VALUE_SCALE10_FLOAT"
    elif [ "$UNIT_RAIN_MODE" -eq "$UNIT_RAIN_IN" ]; then
        eval export "$1"="$2"
    fi
}

setTemperatureHttpLivedata()
{
    #skip undefined value -9999
    if [ "$2" = "$WUNDERGROUND_UNDEFINED_VALUE" ]; then
      return
    fi

    convert_farenheit_to_celciusScale10 "$2" 
    if [ "$SHELL_SUPPORT_FLOATINGPOINT" -eq 1 ]; then
       roundFloat "$VALUE_CELCIUS_SCALE10"
       VALUE_CELCIUS_SCALE10=$VALUE_FLOAT_TO_INT
    fi
    eval export "$1_INTS10=$VALUE_CELCIUS_SCALE10"
    if [ "$UNIT_TEMPERATURE_MODE" -eq "$UNIT_TEMPERATURE_CELCIUS" ]; then
        convertScale10ToFloat "$VALUE_CELCIUS_SCALE10"
        eval export "$1"="$VALUE_SCALE10_FLOAT"
    elif [ "$UNIT_TEMPERATURE_MODE" -eq "$UNIT_TEMPERATURE_FARENHEIT" ]; then
        eval export "$1"="$2"
    fi
}