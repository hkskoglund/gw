#!/bin/sh
# shellcheck disable=SC2034
#ANSI escape codes for styling
#disable with NO_COLOR=y environment variable
#https://en.wikipedia.org/wiki/ANSI_escape_code
#CSI='\e[' # control sequence introducer
#dump all 8-bit colors for f in $(seq 0 255); do printf "\e[48;5;${f}m%-${COLUMNS}s\e[0m\n" "$f"; done

GWDIR=${GWDIR:="."}
CSI='\033[' # \e not supported in some versions of dash
SGI_NORMAL=0
SGI_BOLD=1
SGI_UNDERLINE=4
SGI_BLINK=6
SGI_INVERSE=7
SGI_FOREGC_BLACK=30
SGI_FOREGC_RED=31
SGI_FOREGC_GREEN=32
SGI_FOREGC_YELLOW=33
SGI_FOREGC_BLUE=34
SGI_FOREGC_MAGENTA=35
SGI_FOREGC_CYAN=36
SGI_FOREGC_WHITE=37
SGI_FOREGROUND_COLOR=38
SGI_BACKGC_BLACK=40
SGI_BACKGC_RED=41
SGI_BACKGC_GREEN=42
SGI_BACKGC_YELLOW=43
SGI_BACKGC_BLUE=44
SGI_BACKGC_MAGENTA=45
SGI_BACKGC_CYAN=46
SGI_BACKGC_WHITE=47
SGI_BACKGROUND_COLOR=48

SGI_FOREGC="$SGI_FOREGROUND_COLOR;5;"
SGI_BACKGC="$SGI_BACKGROUND_COLOR;5;"
SGI_FOREGC24="$SGI_FOREGROUND_COLOR;2;"
SGI_BACKGC24="$SGI_BACKGROUND_COLOR;2;"

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
SGI_COLOR_BRIGHT_WHITE=15
SGI_COLOR_ECOWITT=67 #bluish background
SGI_COLOR_ORANGE=208

STYLE_WHITE_BRIGHTRED_BLINK="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;$SGI_BACKGC$SGI_COLOR_BRIGHT_RED;${SGI_BLINK}m"
STYLE_BRIGHTRED="$CSI$SGI_FOREGC${SGI_COLOR_BRIGHT_RED}m"
STYLE_BRIGHTGREEN=$CSI$SGI_FOREGC$SGI_COLOR_BRIGHT_GREEN"m"
STYLE_BRIGHTYELLOW=$CSI$SGI_FOREGC$SGI_COLOR_BRIGHT_YELLOW"m"
STYLE_BRIGHTWHITE_BRIGHTBLUE=$CSI$SGI_FOREGC$SGI_COLOR_BRIGHT_WHITE";"$SGI_BACKGC$SGI_COLOR_BRIGHT_BLUE"m"
STYLE_WHITE_RED=$CSI$SGI_FOREGC$SGI_COLOR_WHITE";"$SGI_BACKGC$SGI_COLOR_RED"m"

export STYLE_BOLD="$CSI${SGI_BOLD}m"
export STYLE_BOLD_INVERSE="$CSI$SGI_BOLD;${SGI_INVERSE}m"

export STYLE_DSR_DEVICE_STATUS_REPORT="${CSI}6n" # report cursor position - debugging

export STYLE_COMPASS_NORTH="$STYLE_BRIGHTRED"
export STYLE_COMPASS_WIND="$CSI${SGI_BOLD}m"

export STYLE_PROTOCOL_ECOWITT_HTTP="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;$SGI_BACKGC${SGI_COLOR_ECOWITT}m"
export STYLE_PROTOCOL_WUNDERGROUND_HTTP="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_ORANGE}m"

#shellcheck source=pm25.sh
. "$GWDIR"/style/pm25.sh
#shellcheck source=rainintensity.sh
. "$GWDIR"/style/rainintensity.sh
#shellcheck source=beufort.sh
. "$GWDIR"/style/beufort.sh
#shellcheck source=uvi.sh
. "$GWDIR"/style/uvi.sh

export STYLE_LIVEDATALIMIT="${STYLE_LIVEDATALIMIT:="$CSI$SGI_BOLD;${SGI_INVERSE}m"}"
export STYLE_LIVEDATALIMIT_WINDDAILYMAX="${STYLE_LIVEDATALIMIT_WINDDAILYMAX:=$STYLE_WHITE_RED}"
export STYLE_LIVEDATALIMIT_WINDSPEED="${STYLE_LIVEDATALIMIT_WINDSPEED:=$STYLE_WHITE_RED}"
export STYLE_LIVEDATALIMIT_WINDGUSTSPEED="${STYLE_LIVEDATALIMIT_WINDGUSTSPEED:=$STYLE_WHITE_RED}"

export STYLE_LIVEDATALIMIT_RAINRATE="${STYLE_LIVEDATALIMIT_RAINRATE:=$STYLE_WHITE_RED}"
export STYLE_LIVEDATALIMIT_RAINHOUR="${STYLE_LIVEDATALIMIT_RAINHOUR:=$STYLE_WHITE_RED}"
export STYLE_LIVEDATALIMIT_RAINDAY="${STYLE_LIVEDATALIMIT_RAINDAY:=$STYLE_WHITE_RED}"
export STYLE_LIVEDATALIMIT_RAINEVENT="${STYLE_LIVEDATALIMIT_RAINEVENT:=$STYLE_WHITE_RED}"

export STYLE_LIVEDATALIMIT_OUTTEMP="${STYLE_LIVEDATALIMIT_OUTTEMP:=$STYLE_BRIGHTWHITE_BRIGHTBLUE}"
export STYLE_LIVEDATALIMIT_OUTTEMP_HIGH="${STYLE_LIVEDATALIMIT_OUTTEMP_HIGH:=$STYLE_WHITE_RED}"
export STYLE_LIVEDATALIMIT_INTEMP_LOW="${STYLE_LIVEDATALIMIT_INTEMP_LOW:=$STYLE_WHITE_BRIGHTBLUE}"
export STYLE_LIVEDATALIMIT_INTEMP_HIGH="${STYLE_LIVEDATALIMIT_INTEMP_HIGH:=$STYLE_WHITE_RED}"

export STYLE_BATTERY_LOW="${STYLE_BATTERY_LOW:=$STYLE_BRIGHTRED}"
export STYLE_SIGNAL_LOW="${STYLE_SIGNAL_LOW:=$STYLE_BRIGHTRED}"
export STYLE_LEAK="${STYLE_LEAK:="\a"$STYLE_WHITE_BRIGHTRED_BLINK}" # add alert/bell \a if leakage detected

export STYLE_RESET="$CSI${SGI_NORMAL}m"

export STYLE_HEADER_DEFAULT="$CSI$SGI_BOLD;${SGI_INVERSE}m"
export STYLE_HEADER="${STYLE_HEADER:=$STYLE_HEADER_DEFAULT}"

export STYLE_HUMIDITY="${STYLE_HUMIDITY:="$CSI$SGI_FOREGC${SGI_COLOR_BLUE}m"}"
export STYLE_HEADER_HUMIDITY="${STYLE_HEADER_HUMIDITY:="$CSI$SGI_BOLD;$SGI_INVERSE;$SGI_FOREGC${SGI_COLOR_BLUE}m"}"

export STYLE_HEADER_TEMP="${STYLE_HEADER_TEMP:=$STYLE_HEADER_DEFAULT}"
export STYLE_TEMP="${STYLE_TEMP:="$CSI$SGI_FOREGC${SGI_COLOR_BRIGHT_MAGENTA}m"}"

export STYLE_HEADER_RAIN="${STYLE_HEADER_RAIN="$CSI$SGI_BOLD;$SGI_INVERSE;$SGI_FOREGC${SGI_COLOR_BRIGHT_BLUE}m"}"
export STYLE_RAIN="${STYLE_RAIN:="$CSI$SGI_FOREGC${SGI_COLOR_BRIGHT_BLUE}m"}"

export STYLE_SENSOR_DISABLE="${STYLE_SENSOR_DISABLE:=$STYLE_BRIGHTRED}"
export STYLE_SENSOR_SEARCH="${STYLE_SENSOR_SEARCH:=$STYLE_BRIGHTYELLOW}"
export STYLE_SENSOR_DISCONNECTED="${STYLE_SENSOR_DISCONNECTED:="$CSI$SGI_FOREGC${SGI_COLOR_BRIGHT_MAGENTA}m"}"
export STYLE_SENSOR_CONNECTED="${STYLE_SENSOR_CONNECTED:=$STYLE_BRIGHTGREEN}"

export STYLE_LIVEVIEW_NORMAL_HEADER="${STYLE_LIVEVIEW_NORMAL_HEADER:="$CSI${SGI_BOLD}m"}"
#export STYLE_LIVEVIEW_NORMAL_HEADER=${STYLE_LIVEVIEW_NORMAL_HEADER:="$CSI$SGI_INVERSE;${SGI_BOLD}m"}
