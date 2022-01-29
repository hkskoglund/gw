#!/bin/sh

#https://fsymbols.com/generators/tarty/

#shellcheck disable=SC2034
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
ASCII_WIND_SW_L2="  ⟋"
ASCII_WIND_SW_L3="⟋"

ASCII_WIND_NW_L1="⟍"
ASCII_WIND_NW_L2="  ⟍"
ASCII_WIND_NW_L3="    ◢"

ASCII_WIND_NE_L1="    ⟋"
ASCII_WIND_NE_L2="  ⟋"
ASCII_WIND_NE_L3="◣"

ASCII_WIND_SE_L1="◤"
ASCII_WIND_SE_L2="  ⟍"
ASCII_WIND_SE_L3="    ⟍"

#                 
#     ▲             
#     ▌             ▌

#    ▞ 
#  ▞  
#▞   
#      ▚
#▄▄▄▄▄▄▄▄▚


#12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
#TEMPERATURE       -40      -30       -20       -10       0         10        20        30        40        50 ℃
#OUTDOOR      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
#printf "\e[1;42m                                            \r%s\e[0m\n" "Utendørs"
#HUMIDITY       0        10        20        30        40        50        60        70        80        90        100 %
#PRESSURE           950       970       990       1010      1030      1050      1070
#40
#   █
#   █
#   █
#   █
#   █
#   █
#   █
#   █
#   █
#   █
#
#30
#
#
#
#
#
#
#
#
#
#20
#
#
#
#
#
#
#
#
#
#

ASCII_MAXLINE=3

#list all capabilities to terminal: infocmp/infocmp -L https://en.wikipedia.org/wiki/Terminal_capabilities
# it capability = tab size = 8 for xterm-256
# watch -c command only supports 3-bit colors in wsl2/ubuntu, other ansi escapes codes are filtered
CSI="\e["

SGI_NORMAL=0
SGI_BOLD=1
SGI_INVERSE=7
SGI_FOREGROUND_COLOR=38
SGI_BACKGROUND_COLOR=48

SGI_FOREGC="$SGI_FOREGROUND_COLOR;5;"
SGI_BACKGC="$SGI_BACKGROUND_COLOR;5;"

ANSIESC_SGI_NORMAL="$CSI${SGI_NORMAL}m"
ANSIESC_SGI_INVERT="$CSI${SGI_INVERSE}m"
ANSIESC_SGI_BOLD_INVERT="$CSI$SGI_BOLD;${SGI_INVERSE}m"
ANSIESC_SGI_BOLD="$CSI${SGI_BOLD}m"

#Colors 8-bit
SGI_COLOR_BLACK=0
SGI_COLOR_RED=1
SGI_COLOR_GREEN=2
SGI_COLOR_YELLOW=3
SGI_COLOR_BLUE=4
SGI_COLOR_MAGENTA=5
SGI_COLOR_CYAN=6
SGI_COLOR_WHITE=7
SGI_COLOR_GRAY=8
SGI_COLOR_BRIGHT_RED=9
SGI_COLOR_BRIGHT_GREEN=10
SGI_COLOR_BRIGHT_YELLOW=11
SGI_COLOR_BRIGHT_BLUE=12
SGI_COLOR_BRIGHT_MAGENTA=13
SGI_COLOR_BRIGHT_CYAN=14
SGI_COLOR_ORANGE=208

STYLE_RESET="$ANSIESC_SGI_NORMAL"

STYLE_HEADER_DEFAULT="$CSI$SGI_BOLD;${SGI_INVERSE}m"
STYLE_HEADER=${STYLE_HEADER:=$STYLE_HEADER_DEFAULT}

STYLE_HUMIDITY=${STYLE_HUMIDITY:="$CSI$SGI_FOREGC${SGI_COLOR_BLUE}m"}
STYLE_HEADER_HUMIDITY=${STYLE_HEADER_HUMIDITY:="$CSI$SGI_BOLD;$SGI_INVERSE;$SGI_FOREGC${SGI_COLOR_BLUE}m"}

STYLE_HEADER_TEMP=${STYLE_HEADER_TEMP:=$STYLE_HEADER_DEFAULT}
STYLE_TEMP=${STYLE_TEMP:="$CSI$SGI_FOREGC${SGI_COLOR_BRIGHT_MAGENTA}m"}

STYLE_HEADER_RAIN=${STYLE_HEADER_RAIN="$CSI$SGI_BOLD;$SGI_INVERSE;$SGI_FOREGC${SGI_COLOR_BRIGHT_BLUE}m"}
STYLE_RAIN=${STYLE_RAIN:="$CSI$SGI_FOREGC${SGI_COLOR_BRIGHT_BLUE}m"}

UV_RISK_LOW=${UV_RISK_LOW:="Low"}
UV_RISK_MODERATE=${UV_RISK_MODERATE:="Moderate"}
UV_RISK_HIGH=${UV_RISK_HIGH:="High"}
UV_RISK_VERYHIGH=${UV_RISK_VERYHIGH:="Very High"}
UV_RISK_EXTREME=${UV_RISK_EXTREME="Extreme"}

newBIGnumber()
#$1 number $2 name
{
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
    while [ "$n" -le $ASCII_MAXLINE ]; do
        unset line
        for digit in $digits; do
             if [ "$digit" = '-' ]; then
                digit='sign' # map to valid variable name
             elif [ "$digit" = '.' ]; then
                digit='punctum'
            fi
            #shellcheck disable=SC2154
             eval line=\""$line\$ASCII_L$n$digit "\" # add \" to preserve space between digits
        done
        eval "$2_L$n=\"$line\""
        n=$(( n + 1 ))
    done

    unset n digit digits line number

}

setUVRisk()
#$1 UVI
{
    if [ "$1" -ge 0 ] && [ "$1" -le 2 ]; then
       UV_RISK=$UV_RISK_LOW
    elif [ "$1" -ge 3 ] && [ "$1" -le 5 ]; then
        UV_RISK=$UV_RISK_MODERATE
    elif [ "$1" -ge 6 ] && [ "$1" -le 7 ]; then
        UV_RISK=$UV_RISK_HIGH
    elif [ "$1" -ge 8 ] && [ "$1" -le 10 ]; then
        UV_RISK=$UV_RISK_VERYHIGH
    elif [ "$1" -ge 11 ]; then
        UV_RISK=$UV_RISK_EXTREME
    fi
}

injectLivedata()
{
    LIVEDATA_INTEMP=21.5
    LIVEDATA_OUTTEMP=-16.2
    LIVEDATA_INHUMI=25
    LIVEDATA_OUTHUMI=93
    UNIT_TEMP="℃"

    LIVEDATA_ABSBARO=999.2
    LIVEDATA_RELBARO=999.2
    UNIT_PRESSURE="hPa"

    LIVEDATA_RAINRATE=9999.9
    LIVEDATA_RAINHOUR=9999.9
    LIVEDATA_RAINDAY=9999.9
    LIVEDATA_RAINEVENT=9999.9
    
    LIVEDATA_RAINWEEK=9999.9
    LIVEDATA_RAINMONTH=1234.5
    LIVEDATA_RAINYEAR=5432.1

    UNIT_RAIN="mm"
    UNIT_RAINRATE="mm/h"

    LIVEDATA_WINDSPEED="3.0"
    LIVEDATA_WINDGUSTSPEED="4.3"
    LIVEDATA_WINDDAILYMAX="8.1"
    LIVEDATA_WINDDIRECTION=45
    LIVEDATA_WINDDIRECTION_COMPASS="NE"

    LIVEDATA_UV=0.0
    LIVEDATA_UVI=0
    setUVRisk "$LIVEDATA_UVI"

    UNIT_WIND="m/s"
    UNIT_DEGREE="°"
    UNIT_UV="W/㎡"

}

newBIGWinddirection()
#$1 direction, $2 name
{
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

setStyleBIG_UVI()
#$1 UVI
#https://en.wikipedia.org/wiki/Ultraviolet_index
{
    if [ "$1" -ge 0 ] && [ "$1" -le 2 ]; then
       STYLE_UVI="$CSI$SGI_FOREGC$SGI_COLOR_GRAY;$SGI_BACKGC${SGI_COLOR_GREEN}m"
    elif [ "$1" -ge 3 ] && [ "$1" -le 5 ]; then
        STYLE_UVI="$CSI$SGI_FOREGC$SGI_COLOR_GRAY;$SGI_BACKGC${SGI_COLOR_YELLOW}m"
    elif [ "$1" -ge 6 ] && [ "$1" -le 7 ]; then
        STYLE_UVI="$CSI$SGI_FOREGC$SGI_COLOR_GRAY;$SGI_BACKGC${SGI_COLOR_ORANGE}m"
    elif [ "$1" -ge 8 ] && [ "$1" -le 10 ]; then
        STYLE_UVI="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;$SGI_BACKGC${SGI_COLOR_RED}m"
    elif [ "$1" -ge 11 ]; then
        STYLE_UVI="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;$SGI_BACKGC${SGI_COLOR_MAGENTA}m"
    fi
   
}

newRuler()
{
    n=1
    unset VALUE_RULER
    while [ "$n" -le "$1" ]; do
        VALUE_RULER=$VALUE_RULER"123456789${ANSIESC_SGI_BOLD_INVERT}0${ANSIESC_SGI_NORMAL}"
        n=$(( n + 1 ))
    done
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
    setStyleBIG_UVI "$LIVEDATA_UVI"

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
    line_uv_header_fmt="$STYLE_HEADER_DEFAULT%s$STYLE_RESET\r\t\t\t\t$STYLE_HEADER_DEFAULT%s$STYLE_RESET"
    line_uv_fmt="%s\r\t\t\t\t$STYLE_UVI%s$STYLE_RESET"
    
    newRuler 8
    ruler_fmt=$VALUE_RULER
    
    #set -x 
    
    #shellcheck disable=SC2059
    printf "$ruler_fmt\n\
$line_temp_header_fmt\n\n$line_temp_fmt\n$line_temp_fmt\n$line_temp_fmt\n\n\
$STYLE_HEADER$line_baro_fmt$STYLE_RESET\n\n$line_baro_fmt\n$line_baro_fmt\n$line_baro_fmt\n\n\
$line_rain_header_fmt\n\n$line_rain_fmt\n$line_rain_fmt\n$line_rain_fmt\n\n\
$line_rain_header_fmt\n\n$line_rain_fmt\n$line_rain_fmt\n$line_rain_fmt\n\n\
$STYLE_HEADER$line_wind_fmt$STYLE_RESET\n\n$line_wind_fmt\n$line_wind_fmt\n$line_wind_fmt\n\n\
$STYLE_HEADER$line_wind_fmt$STYLE_RESET\n\n$line_wind_fmt\n$line_wind_fmt\n$line_wind_fmt\n\n\
$line_uv_header_fmt\n\n$line_uv_fmt\n$line_uv_fmt\n$line_uv_fmt\n\n"\
    "OUTDOOR $UNIT_TEMP " "HUMIDITY %" "🏠 INDOOR $UNIT_TEMP " "HUMIDITY %"\
    "$LDVBIG_OUTTEMP_L1" "$LDVBIG_OUTHUMI_L1" "$LDVBIG_INTEMP_L1" "$LDVBIG_INHUMI_L1"\
    "$LDVBIG_OUTTEMP_L2" "$LDVBIG_OUTHUMI_L2" "$LDVBIG_INTEMP_L2" "$LDVBIG_INHUMI_L2"\
    "$LDVBIG_OUTTEMP_L3" "$LDVBIG_OUTHUMI_L3" "$LDVBIG_INTEMP_L3" "$LDVBIG_INHUMI_L3"\
    "ABSOLUTE $UNIT_PRESSURE" "RELATIVE $UNIT_PRESSURE"\
    "$LDVBIG_ABSBARO_L1" "$LDVBIG_RELBARO_L1" "$LDVBIG_ABSBARO_L2" "$LDVBIG_RELBARO_L2" "$LDVBIG_ABSBARO_L3" "$LDVBIG_RELBARO_L3"\
    "RAIN RATE $UNIT_RAINRATE" "RAIN HOUR $UNIT_RAIN"\
    "$LDVBIG_RAINRATE_L1" "$LDVBIG_RAINHOUR_L1" "$LDVBIG_RAINRATE_L2" "$LDVBIG_RAINHOUR_L2" "$LDVBIG_RAINRATE_L3" "$LDVBIG_RAINHOUR_L3"\
    "RAIN TODAY $UNIT_RAIN" "RAIN EVENT  $UNIT_RAIN"\
    "$LDVBIG_RAINDAY_L1" "$LDVBIG_RAINEVENT_L1" "$LDVBIG_RAINHOUR_L2" "$LDVBIG_RAINEVENT_L2" "$LDVBIG_RAINHOUR_L3" "$LDVBIG_RAINEVENT_L3"\
    "WIND SPEED $UNIT_WIND" "WIND GUSTSPEED $UNIT_WIND"\
    "$LDVBIG_WINDSPEED_L1" "$LDVBIG_WINDGUSTSPEED_L1" "$LDVBIG_WINDSPEED_L2" "$LDVBIG_WINDGUSTSPEED_L2" "$LDVBIG_WINDSPEED_L3" "$LDVBIG_WINDGUSTSPEED_L3"\
    "WIND DIRECTION $UNIT_DEGREE $LIVEDATA_WINDDIRECTION_COMPASS" "WIND DAILY MAX $UNIT_WIND"\
    "$LDVBIG_WINDDIRECTION_L1 $LDVBIG_WINDDIRECTION_SYMBOL_L1" "$LDVBIG_WINDDAILYMAX_L1" "$LDVBIG_WINDDIRECTION_L2 $LDVBIG_WINDDIRECTION_SYMBOL_L2" "$LDVBIG_WINDDAILYMAX_L2" "$LDVBIG_WINDDIRECTION_L3 $LDVBIG_WINDDIRECTION_SYMBOL_L3" "$LDVBIG_WINDDAILYMAX_L3"\
     "☀️ UV $UNIT_UV" "UVI $UV_RISK"\
    "$LDVBIG_UV_L1" "$LDVBIG_UVI_L1" "$LDVBIG_UV_L2" "$LDVBIG_UVI_L2" "$LDVBIG_UV_L3" "$LDVBIG_UVI_L3"

  # set +x
}

if [ -n "$ZSH_VERSION" ]; then
    #https://zsh.sourceforge.io/FAQ/zshfaq03.html
       setopt shwordsplit  #zsh compability for "1 2 3" -> split in 1 2 3
fi

injectLivedata
printLivedata  "$1"
#set

#TEST unicode: https://www.compart.com/en/unicode/block/U+2580

# setANSIESC_CHA_CursorHorizontalAbsolute "$col"
#        APPEND_FORMAT="$APPEND_FORMAT$ANSIESC_CHA_CursorHorizontalAbsolute%s\n"
#        APPEND_ARGS="$APPEND_ARGS'$line' "

#setANSIESC_CHA_CursorHorizontalAbsolute 1 # move to column 1
#    APPEND_FORMAT="$APPEND_FORMAT$ANSIESC_CHA_CursorHorizontalAbsolute$ANSIESC_SGI_NORMAL"
#    eval printf \""$APPEND_FORMAT"\" "$APPEND_ARGS"
#    unset APPEND_FORMAT APPEND_ARGS