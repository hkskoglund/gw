#!/usr/bin/dash

#https://fsymbols.com/generators/tarty/

ASCII_MAXLINE=3

#shellcheck disable=SC2034
{
ASCII_L10="█▀█"
ASCII_L20="█ █"
ASCII_L30="█▄█"

ASCII_L11="▄█ "
ASCII_L21=" █ "
ASCII_L31="▄█▄"

ASCII_L12="█▀█"
ASCII_L22=" ▄▀" 
ASCII_L32="█▄▄"

ASCII_L13="█▀█"
ASCII_L23=" ▀▄"
ASCII_L33="█▄█"

ASCII_L14=" █▀█"
ASCII_L24="█▄▄█"
ASCII_L34="   █"

ASCII_L15="█▀▀"
ASCII_L25="▀▀▄"
ASCII_L35="▄▄▀"

ASCII_L16="▄▀▀▄" 
ASCII_L26="█▄▄ "
ASCII_L36="▀▄▄▀"

ASCII_L17="▀▀█"
ASCII_L27=" █ "
ASCII_L37="▐▌ "

ASCII_L18="▄▀▀▄"
ASCII_L28="▄▀▀▄"
ASCII_L38="▀▄▄▀"

ASCII_L19="▄▀▀▄"
ASCII_L29="▀▄▄█"
ASCII_L39=" ▄▄▀"

ASCII_L1sign="  "
ASCII_L2sign="▀▀"
ASCII_L3sign="  "

ASCII_L1punctum=" "
ASCII_L2punctum=" "
ASCII_L3punctum="▄"

ASCII_L1comma="  "
ASCII_L2comma="  "
ASCII_L3comma="，"

ASCII_WIND_S_L1=" ▲"
ASCII_WIND_S_L2=" |"
ASCII_WIND_S_L3=" |"

ASCII_WIND_N_L1=" |"
ASCII_WIND_N_L2=" |"
ASCII_WIND_N_L3=" ▼"

ASCII_WIND_W_L1=""
ASCII_WIND_W_L2="---▶"
ASCII_WIND_W_L3=""

ASCII_WIND_E_L1=""
ASCII_WIND_E_L2="◀---"
ASCII_WIND_E_L3=""

ASCII_WIND_SW_L1="    ◥"
ASCII_WIND_SW_L2="  ⟋  "
ASCII_WIND_SW_L3="⟋    "

ASCII_WIND_NW_L1="⟍    "
ASCII_WIND_NW_L2="  ⟍  "
ASCII_WIND_NW_L3="    ◢"

ASCII_WIND_NE_L1="    ⟋"
ASCII_WIND_NE_L2="  ⟋  "
ASCII_WIND_NE_L3="◣    "

ASCII_WIND_SE_L1="◤    "
ASCII_WIND_SE_L2="  ⟍  "
ASCII_WIND_SE_L3="    ⟍"
}

eval "$GW_SETUVRISK_FUNC"
eval "$GW_SETSTYLEUVI_FUNC"

shortHeader()
#$1 long header
{
    #shellcheck disable=SC2086
    set -- $1
    if [ "${#1}" -le 16 ]; then
       VALUE_HEADER_SHORT=$1 #just pick first word
    else
      : # maybe remove part lager than 16 chars
    fi
}

newBIGnumber()
#$1 number $2 name
{
    if [ "$SHELL_SUPPORT_TYPESET" -eq 1 ]; then
      #shellcheck disable=SC3044
        typeset n digit digits line number
    else
        local n digit digits line number
    fi

    number=$1
    
    #find digits in number
    n=1
    while [ "${#number}" -ge 1  ]; do
        digits=$digits"${number%%"${number#?}"} " #add front digit -> build up digit string with space "1 2 3 "
        number=${number#?} # remove front digit
        n=$(( n + 1 ))
    done

    #construct each line from digits
    n=1
    while [ "$n" -le "$ASCII_MAXLINE" ]; do
        unset line
        for digit in $digits; do
             if [ "$digit" = '-' ]; then
                digit='sign' # map to valid variable name
             elif [ "$digit" = '.' ]; then
                digit='punctum'
            elif [ "$digit" = "," ]; then
               digit='comma'
            fi
            #shellcheck disable=SC2154
             eval line=\""$line\$ASCII_L$n$digit "\" # add \" to preserve space between digits
        done
        if [ "$DEBUG" -eq  1 ]; then
           echo >&2 "$2 $line"
        fi
        eval "$2_L$n=\"$line\""
        n=$(( n + 1 ))
    done

   if [ -n "$KSH_VERSION" ]; then
     unset n digit digits line number
   fi

}

newBIGWinddirection()
#$1 direction, $2 name
{
     if [ "$SHELL_SUPPORT_TYPESET" -eq 1 ]; then
      #shellcheck disable=SC3044
        typeset direction
    else
        local direction
    fi
    if [ "$1" -le 11 ] || [ "$1" -gt 349 ]; then
        direction=ASCII_WIND_N
    elif [ "$1" -gt 11 ] && [ "$1" -lt 34 ]; then
        direction=ASCII_WIND_NE
    elif [ "$1" -ge 34 ] && [ "$1" -le 56 ]; then
        direction=ASCII_WIND_NE
    elif [ "$1" -gt 56 ] && [ "$1" -le 79 ]; then
        direction=ASCII_WIND_NE
    elif [ "$1" -gt 79 ] && [ "$1" -le 101 ]; then
        direction=ASCII_WIND_E
    elif [ "$1" -gt 101 ] && [ "$1" -le 124 ]; then
         direction=ASCII_WIND_SE
    elif [ "$1" -gt 124 ] && [ "$1" -le 146 ]; then
        direction=ASCII_WIND_SE
    elif [ "$1" -gt 146 ] && [ "$1" -le 169 ]; then
        direction=ASCII_WIND_SE
    elif [ "$1" -gt 169 ] && [ "$1" -le 191 ]; then
        direction=ASCII_WIND_S
    elif [ "$1" -gt 191 ] && [ "$1" -le 214 ]; then
        direction=ASCII_WIND_SW
    elif [ "$1" -gt 214 ] && [ "$1" -le 236 ]; then
        direction=ASCII_WIND_SW
    elif [ "$1" -gt 236 ] && [ "$1" -le 259 ]; then
        direction=ASCII_WIND_SW
    elif [ "$1" -gt 259 ] && [ "$1" -le 281 ]; then
        direction=ASCI_WIND_W
    elif [ "$1" -gt 281 ] && [ "$1" -le 304 ]; then
        direction=ASCII_WIND_NW
    elif [ "$1" -gt 304 ] && [ "$1" -le 326 ]; then
        direction=ASCII_WIND_NW
    elif [ "$1" -gt 326 ] && [ "$1" -le 349 ]; then
        direction=ASCII_WIND_NW
    fi

   eval "${2}_L1=\$${direction}_L1"
   eval "${2}_L2=\$${direction}_L2"
   eval "${2}_L3=\$${direction}_L3"
   
}

printLivedataBIG()
{
    newBIGnumber "$LIVEDATA_OUTTEMP" LDVBIG_OUTTEMP
    newBIGnumber "$LIVEDATA_INTEMP" LDVBIG_INTEMP
    newBIGnumber "$LIVEDATA_OUTHUMI" LDVBIG_OUTHUMI
    newBIGnumber "$LIVEDATA_INHUMI" LDVBIG_INHUMI
    
    newBIGnumber "$LIVEDATA_ABSBARO" LDVBIG_ABSBARO
    newBIGnumber "$LIVEDATA_RELBARO" LDVBIG_RELBARO

    newBIGnumber "$LIVEDATA_RAINRATE" LDVBIG_RAINRATE
    newBIGnumber "$LIVEDATA_RAINHOUR" LDVBIG_RAINHOUR
    newBIGnumber "$LIVEDATA_RAINDAY" LDVBIG_RAINDAY
    newBIGnumber "$LIVEDATA_RAINEVENT" LDVBIG_RAINEVENT
    newBIGnumber "$LIVEDATA_RAINWEEK" LDVBIG_RAINWEEK
    newBIGnumber "$LIVEDATA_RAINMONTH" LDVBIG_RAINMONTH
    newBIGnumber "$LIVEDATA_RAINYEAR" LDVBIG_RAINYEAR
    
    newBIGnumber "$LIVEDATA_WINDSPEED" LDVBIG_WINDSPEED
    newBIGnumber "$LIVEDATA_WINDGUSTSPEED" LDVBIG_WINDGUSTSPEED
    newBIGnumber "$LIVEDATA_WINDDAILYMAX" LDVBIG_WINDDAILYMAX

    newBIGnumber "$LIVEDATA_WINDDIRECTION" LDVBIG_WINDDIRECTION
    newBIGWinddirection "$LIVEDATA_WINDDIRECTION" LDVBIG_WINDDIRECTION_SYMBOL

    newBIGnumber "$LIVEDATA_UV" LDVBIG_UV
    newBIGnumber "$LIVEDATA_UVI" LDVBIG_UVI
    setStyleUVI "$LIVEDATA_UVI"

    shortHeader "$LIVEDATA_OUTHUMI_HEADER"
    LIVEDATA_OUTHUMI_HEADER_SHORT=$VALUE_HEADER_SHORT
    shortHeader "$LIVEDATA_INHUMI_HEADER"
    LIVEDATA_INHUMI_HEADER_SHORT=$VALUE_HEADER_SHORT

    humidity_fmt="$STYLE_HUMIDITY%s$STYLE_RESET"
    humidity_header_fmt="$STYLE_HEADER_HUMIDITY%s$STYLE_RESET"

    temp_header_fmt="$STYLE_HEADER_TEMP%s$STYLE_RESET"
    temp_fmt="$STYLE_TEMP%s$STYLE_RESET"
    line_temp_header_fmt="$temp_header_fmt\r\t\t\t$humidity_header_fmt\r\t\t\t\t\t$temp_header_fmt\r\t\t\t\t\t\t\t\t$humidity_header_fmt"
    line_temp_fmt="$temp_fmt\r\t\t\t$humidity_fmt\r\t\t\t\t\t$temp_fmt\r\t\t\t\t\t\t\t\t$humidity_fmt"
    
    line_baro_fmt="%s\r\t\t\t\t%s"

    rain_header_fmt="$STYLE_HEADER_RAIN%s$STYLE_RESET"
    line_rain_header_fmt="$rain_header_fmt\r\t\t\t\t$rain_header_fmt"
    rain_fmt="$STYLE_RAIN%s$STYLE_RESET"
    line_rain_fmt="$rain_fmt\r\t\t\t\t$rain_fmt"
    
     line_wind_fmt="%s\r\t\t\t\t%s"
    line_winddir_fmt="%s\r\t\t%s\r\t\t\t\t%s"
    line_uv_header_fmt="$STYLE_HEADER_DEFAULT%s$STYLE_RESET\r\t\t\t\t$STYLE_HEADER_DEFAULT%s$STYLE_RESET"
    line_uv_fmt="%s\r\t\t\t\t$STYLE_UVI%s$STYLE_RESET"
    
    if [ "$DEBUG" -eq 1 ]; then
        newRuler 8
        ruler_fmt="$VALUE_RULER\n"
    fi

    setUVRisk "$LIVEDATA_UVI"
    #set -x 
    
    #shellcheck disable=SC2059
    printf "$ruler_fmt\
$line_temp_header_fmt\n\n$line_temp_fmt\n$line_temp_fmt\n$line_temp_fmt\n\n\
$STYLE_HEADER$line_baro_fmt$STYLE_RESET\n\n$line_baro_fmt\n$line_baro_fmt\n$line_baro_fmt\n\n\
$line_rain_header_fmt\n\n$line_rain_fmt\n$line_rain_fmt\n$line_rain_fmt\n\n\
$line_rain_header_fmt\n\n$line_rain_fmt\n$line_rain_fmt\n$line_rain_fmt\n\n\
$STYLE_HEADER$line_wind_fmt$STYLE_RESET\n\n$line_wind_fmt\n$line_wind_fmt\n$line_wind_fmt\n\n\
$STYLE_HEADER$line_wind_fmt$STYLE_RESET\n\n$line_winddir_fmt\n$line_winddir_fmt\n$line_winddir_fmt\n\n\
$line_uv_header_fmt\n\n$line_uv_fmt\n$line_uv_fmt\n$line_uv_fmt\n\n"\
    "$LIVEDATA_OUTTEMP_HEADER $UNIT_TEMP " "$LIVEDATA_OUTHUMI_HEADER_SHORT %" "$LIVEDATA_INTEMP_HEADER $UNIT_TEMP " "$LIVEDATA_INHUMI_HEADER_SHORT %"\
    "$LDVBIG_OUTTEMP_L1" "$LDVBIG_OUTHUMI_L1" "$LDVBIG_INTEMP_L1" "$LDVBIG_INHUMI_L1"\
    "$LDVBIG_OUTTEMP_L2" "$LDVBIG_OUTHUMI_L2" "$LDVBIG_INTEMP_L2" "$LDVBIG_INHUMI_L2"\
    "$LDVBIG_OUTTEMP_L3" "$LDVBIG_OUTHUMI_L3" "$LDVBIG_INTEMP_L3" "$LDVBIG_INHUMI_L3"\
    "$LIVEDATA_ABSBARO_HEADER $UNIT_PRESSURE" "$LIVEDATA_RELBARO_HEADER $UNIT_PRESSURE"\
    "$LDVBIG_ABSBARO_L1" "$LDVBIG_RELBARO_L1" "$LDVBIG_ABSBARO_L2" "$LDVBIG_RELBARO_L2" "$LDVBIG_ABSBARO_L3" "$LDVBIG_RELBARO_L3"\
    "$LIVEDATA_RAINRATE_HEADER $UNIT_RAINRATE" "$LIVEDATA_RAINHOUR_HEADER $UNIT_RAIN"\
    "$LDVBIG_RAINRATE_L1" "$LDVBIG_RAINHOUR_L1" "$LDVBIG_RAINRATE_L2" "$LDVBIG_RAINHOUR_L2" "$LDVBIG_RAINRATE_L3" "$LDVBIG_RAINHOUR_L3"\
    "$LIVEDATA_RAINDAY_HEADER $UNIT_RAIN" "$LIVEDATA_RAINEVENT_HEADER $UNIT_RAIN"\
    "$LDVBIG_RAINDAY_L1" "$LDVBIG_RAINEVENT_L1" "$LDVBIG_RAINDAY_L2" "$LDVBIG_RAINEVENT_L2" "$LDVBIG_RAINDAY_L3" "$LDVBIG_RAINEVENT_L3"\
    "$LIVEDATA_WINDSPEED_HEADER $UNIT_WIND" "$LIVEDATA_WINDGUSTSPEED_HEADER $UNIT_WIND"\
    "$LDVBIG_WINDSPEED_L1" "$LDVBIG_WINDGUSTSPEED_L1" "$LDVBIG_WINDSPEED_L2" "$LDVBIG_WINDGUSTSPEED_L2" "$LDVBIG_WINDSPEED_L3" "$LDVBIG_WINDGUSTSPEED_L3"\
    "$LIVEDATA_WINDDIRECTION_HEADER $UNIT_DEGREE $LIVEDATA_WINDDIRECTION_COMPASS" "$LIVEDATA_WINDDAILYMAX_HEADER $UNIT_WIND"\
    "$LDVBIG_WINDDIRECTION_L1" "$LDVBIG_WINDDIRECTION_SYMBOL_L1" "$LDVBIG_WINDDAILYMAX_L1" "$LDVBIG_WINDDIRECTION_L2" "$LDVBIG_WINDDIRECTION_SYMBOL_L2" "$LDVBIG_WINDDAILYMAX_L2" "$LDVBIG_WINDDIRECTION_L3" "$LDVBIG_WINDDIRECTION_SYMBOL_L3" "$LDVBIG_WINDDAILYMAX_L3"\
     "☀️ $LIVEDATA_UV_HEADER $UNIT_UV" "$LIVEDATA_UVI_HEADER $VALUE_UV_RISK"\
    "$LDVBIG_UV_L1" "$LDVBIG_UVI_L1" "$LDVBIG_UV_L2" "$LDVBIG_UVI_L2" "$LDVBIG_UV_L3" "$LDVBIG_UVI_L3"

  # set +x
}

printLivedataBIG
