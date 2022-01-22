#!/usr/bin/dash
#ANSI escape
#disable with -E option
#https://en.wikipedia.org/wiki/ANSI_escape_code
#CSI='\e[' # control sequence introducer
#dump all 8-bit colors for f in $(seq 0 255); do printf "\e[48;5;${f}m%-${COLUMNS}s\e[0m\n" "$f"; done
CSI='\033[' # \e not supported in some versions of dash
SGI_NORMAL=0
SGI_BOLD=1
SGI_UNDERLINE=4
SGI_BLINK=6
SGI_INVERSE=7
SGI_FOREGROUND_COLOR=38
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
SGI_COLOR_ECOWITT=67 #bluish background
SGI_COLOR_ORANGE=208

STYLE_WHITE_BRIGHTRED_BLINK="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;$SGI_BACKGC$SGI_COLOR_BRIGHT_RED;${SGI_BLINK}m"
STYLE_BRIGHTRED=$CSI$SGI_FOREGC$SGI_COLOR_BRIGHT_RED"m"
STYLE_BRIGHTGREEN=$CSI$SGI_FOREGC$SGI_COLOR_BRIGHT_GREEN"m"
STYLE_WHITE_BRIGHTBLUE=$CSI$SGI_FOREGC$SGI_COLOR_WHITE";"$SGI_BACKGC$SGI_COLOR_BRIGHT_BLUE"m"
STYLE_WHITE_RED=$CSI$SGI_FOREGC$SGI_COLOR_WHITE";"$SGI_BACKGC$SGI_COLOR_RED"m"

export STYLE_BOLD=$CSI$SGI_BOLD"m"
export STYLE_BOLD_INVERSE="$CSI$SGI_BOLD;${SGI_INVERSE}m"

export STYLE_DSR_DEVICE_STATUS_REPORT=$CSI"6n" # report cursor position - debugging

export STYLE_COMPASS_NORTH="$STYLE_BRIGHTRED"
export STYLE_COMPASS_WIND="$CSI${SGI_BOLD}m"

export STYLE_PROTOCOL_ECOWITT_HTTP="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;$SGI_BACKGC${SGI_COLOR_ECOWITT}m"
export STYLE_PROTOCOL_WUNDERGROUND_HTTP="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_ORANGE}m"

export STYLE_PM25_AQI_GOOD="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_BRIGHT_GREEN}m"    #00e400
export STYLE_PM25_AQI_MODERATE="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_BRIGHT_YELLOW}m"  #ffff00
export STYLE_PM25_AQI_UNHEALTHY_SENSITIVE="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_ORANGE}m"  #ff7e00
export STYLE_PM25_AQI_UNHEALTHY="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;$SGI_BACKGC${SGI_COLOR_BRIGHT_RED}m"     #ff0000
export STYLE_PM25_AQI_VERY_UNHEALTHY="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;$SGI_BACKGC${SGI_COLOR_MAGENTA}m" #99004c
export STYLE_PM25_AQI_HAZARDOUS="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;${SGI_BACKGC}88m" #approximate #88000

export STYLE_RAININTENSITY_LIGHT="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_BRIGHT_CYAN}m"    #00e400
export STYLE_RAININTENSITY_MODERATE="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_BRIGHT_YELLOW}m"  #ffff00
export STYLE_RAININTENSITY_HEAVY="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_ORANGE}m"  #ff7e00
export STYLE_RAININTENSITY_EXTREME="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;$SGI_BACKGC${SGI_COLOR_BRIGHT_RED}m"     #ff0000

#yr.no - chrome color picker/devtools
#export STYLE_RAININTENSITY_LIGHT="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;${SGI_BACKGC24}145;228;255m"
#export STYLE_RAININTENSITY_MODERATE="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;${SGI_BACKGC24}0;170;255m"
#export STYLE_RAININTENSITY_HEAVY="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;${SGI_BACKGC24}0;128;255m"
#export STYLE_RAININTENSITY_EXTREME="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;${SGI_BACKGC24}122;0;135m"


#colors
export STYLE_BEUFORT_0="$CSI$SGI_BACKGC$SGI_COLOR_BLACK"m                                          #  0.5 m/s
export STYLE_BEUFORT_1="$CSI$SGI_BACKGC$SGI_COLOR_BLUE"m                                           #  1.6 m/s
export STYLE_BEUFORT_2="$CSI$SGI_BACKGC$SGI_COLOR_BRIGHT_BLUE"m                                    #  3.4 m/s
export STYLE_BEUFORT_3="$CSI$SGI_BACKGC$SGI_COLOR_CYAN"m                                           #  5.5 m/s
export STYLE_BEUFORT_4="$CSI$SGI_BACKGC$SGI_COLOR_BRIGHT_CYAN;$SGI_FOREGC${SGI_COLOR_BLACK}m"      #  8.0 m/s
export STYLE_BEUFORT_5="$CSI$SGI_BACKGC$SGI_COLOR_GREEN"m                                          # 10.8 m/s
export STYLE_BEUFORT_6="$CSI$SGI_BACKGC$SGI_COLOR_BRIGHT_GREEN;$SGI_FOREGC${SGI_COLOR_BLACK}m"     # 13.9 m/s
export STYLE_BEUFORT_7="$CSI$SGI_BACKGC$SGI_COLOR_YELLOW;$SGI_FOREGC${SGI_COLOR_BLACK}m"           # 17.2 m/s
export STYLE_BEUFORT_8="$CSI$SGI_BACKGC$SGI_COLOR_BRIGHT_YELLOW;$SGI_FOREGC${SGI_COLOR_BLACK}m"    # 20.8 m/s
export STYLE_BEUFORT_9="$CSI$SGI_BACKGC$SGI_COLOR_RED"m                                            # 24.5 m/s
export STYLE_BEUFORT_10="$CSI$SGI_BACKGC$SGI_COLOR_BRIGHT_RED"m                                    # 28.5 m/s
export STYLE_BEUFORT_11="$CSI$SGI_BACKGC$SGI_COLOR_MAGENTA"m                                       # 32.7 m/s
export STYLE_BEUFORT_12="$CSI$SGI_BACKGC$SGI_COLOR_BRIGHT_MAGENTA;$SGI_FOREGC${SGI_COLOR_BLACK}m"

#grayscale

#export STYLE_BEUFORT_0="$CSI${SGI_BACKGC}232;$SGI_FOREGC${SGI_COLOR_WHITE}m"
#export STYLE_BEUFORT_1="$CSI${SGI_BACKGC}234;$SGI_FOREGC${SGI_COLOR_WHITE}m"
#export STYLE_BEUFORT_2="$CSI${SGI_BACKGC}236;$SGI_FOREGC${SGI_COLOR_WHITE}m"
#export STYLE_BEUFORT_3="$CSI${SGI_BACKGC}238;$SGI_FOREGC${SGI_COLOR_WHITE}m"
#export STYLE_BEUFORT_4="$CSI${SGI_BACKGC}240;$SGI_FOREGC${SGI_COLOR_WHITE}m"
#export STYLE_BEUFORT_5="$CSI${SGI_BACKGC}242;$SGI_FOREGC${SGI_COLOR_WHITE}m"
#export STYLE_BEUFORT_6="$CSI${SGI_BACKGC}244;$SGI_FOREGC${SGI_COLOR_BLACK}m"
#export STYLE_BEUFORT_7="$CSI${SGI_BACKGC}246;$SGI_FOREGC${SGI_COLOR_BLACK}m"
#export STYLE_BEUFORT_8="$CSI${SGI_BACKGC}248;$SGI_FOREGC${SGI_COLOR_BLACK}m"
#export STYLE_BEUFORT_9="$CSI${SGI_BACKGC}250;$SGI_FOREGC${SGI_COLOR_BLACK}m"
#export STYLE_BEUFORT_10="$CSI${SGI_BACKGC}252;$SGI_FOREGC${SGI_COLOR_BLACK}m"
#export STYLE_BEUFORT_11="$CSI${SGI_BACKGC}254;$SGI_FOREGC${SGI_COLOR_BLACK}m"
#export STYLE_BEUFORT_12="$CSI${SGI_BACKGC}255;$SGI_FOREGC${SGI_COLOR_BLACK}m"

export STYLE_UVI_LOW=$STYLE_PM25_AQI_GOOD
export STYLE_UVI_MODERATE=$STYLE_PM25_AQI_MODERATE
export STYLE_UVI_HIGH=$STYLE_PM25_AQI_UNHEALTHY_SENSITIVE
export STYLE_UVI_VERY_HIGH=$STYLE_PM25_AQI_UNHEALTHY
export STYLE_UVI_EXTERME=$STYLE_PM25_AQI_VERY_UNHEALTHY

export STYLE_LIMIT_LIVEDATA=${STYLE_LIMIT_LIVEDATA:="$CSI$SGI_BOLD;${SGI_INVERSE}m"}
export STYLE_LIMIT_LIVEDATA_WINDDAILYMAX=${STYLE_LIMIT_LIVEDATA_WINDDAILYMAX:=$STYLE_WHITE_RED}
export STYLE_LIMIT_LIVEDATA_WINDSPEED=${STYLE_LIMIT_LIVEDATA_WINDSPEED:=$STYLE_WHITE_RED}
export STYLE_LIMIT_LIVEDATA_WINDGUSTSPEED=${STYLE_LIMIT_LIVEDATA_WINDGUSTSPEED:=$STYLE_WHITE_RED}

export STYLE_LIMIT_LIVEDATA_RAINRATE=${STYLE_LIMIT_LIVEDATA_RAINRATE:=$STYLE_WHITE_RED}
export STYLE_LIMIT_LIVEDATA_RAINHOUR=${STYLE_LIMIT_LIVEDATA_RAINHOUR:=$STYLE_WHITE_RED}
export STYLE_LIMIT_LIVEDATA_RAINDAY=${STYLE_LIMIT_LIVEDATA_RAINDAY:=$STYLE_WHITE_RED}
export STYLE_LIMIT_LIVEDATA_RAINEVENT=${STYLE_LIMIT_LIVEDATA_RAINEVENT:=$STYLE_WHITE_RED}

export STYLE_LIMIT_LIVEDATA_OUTTEMP=${STYLE_LIMIT_LIVEDATA_OUTTEMP:=$STYLE_WHITE_BRIGHTBLUE}
export STYLE_LIMIT_LIVEDATA_OUTTEMP_HIGH=${STYLE_LIMIT_LIVEDATA_OUTTEMP_HIGH:=$STYLE_WHITE_RED}
export STYLE_LIMIT_LIVEDATA_INTEMP_LOW=${STYLE_LIMIT_LIVEDATA_INTEMP_LOW:=$STYLE_WHITE_BRIGHTBLUE}
export STYLE_LIMIT_LIVEDATA_INTEMP_HIGH=${STYLE_LIMIT_LIVEDATA_INTEMP_HIGH:=$STYLE_WHITE_RED}

export STYLE_BATTERY_LOW=${STYLE_BATTERY_LOW:=$STYLE_BRIGHTRED}
export STYLE_SIGNAL_LOW=${STYLE_SIGNAL_LOW:=$STYLE_BRIGHTRED}
export STYLE_LEAK=${STYLE_LEAK:="\a"$STYLE_WHITE_BRIGHTRED_BLINK} # add alert/bell \a if leakage detected

export STYLE_RESET="$CSI${SGI_NORMAL}m"

export STYLE_HEADER_DEFAULT="$CSI$SGI_BOLD;${SGI_INVERSE}m"
export STYLE_HEADER=${STYLE_HEADER:=$STYLE_HEADER_DEFAULT}

export STYLE_HUMIDITY=${STYLE_HUMIDITY:="$CSI$SGI_FOREGC${SGI_COLOR_BLUE}m"}
export STYLE_HEADER_HUMIDITY=${STYLE_HEADER_HUMIDITY:="$CSI$SGI_BOLD;$SGI_INVERSE;$SGI_FOREGC${SGI_COLOR_BLUE}m"}

export STYLE_HEADER_TEMP=${STYLE_HEADER_TEMP:=$STYLE_HEADER_DEFAULT}
export STYLE_TEMP=${STYLE_TEMP:="$CSI$SGI_FOREGC${SGI_COLOR_BRIGHT_MAGENTA}m"}

export STYLE_HEADER_RAIN=${STYLE_HEADER_RAIN="$CSI$SGI_BOLD;$SGI_INVERSE;$SGI_FOREGC${SGI_COLOR_BRIGHT_BLUE}m"}
export STYLE_RAIN=${STYLE_RAIN:="$CSI$SGI_FOREGC${SGI_COLOR_BRIGHT_BLUE}m"}

export STYLE_SENSOR_DISABLE=${STYLE_SENSOR_DISABLE:=$STYLE_BRIGHTRED}
export STYLE_SENSOR_SEARCH=${STYLE_SENSOR_SEARCH:=$STYLE_BRIGHTGREEN}
export STYLE_SENSOR_DISCONNECTED=${STYLE_SENSOR_DISCONNECTED:="$CSI$SGI_FOREGC${SGI_COLOR_BRIGHT_MAGENTA}m"}
#export STYLE_SENSOR_CONNECTED=${STYLE_SENSOR_CONNECTED:=""}

export STYLE_LIVEVIEW_NORMAL_HEADER=${STYLE_LIVEVIEW_NORMAL_HEADER:="$CSI${SGI_BOLD}m"}
#export STYLE_LIVEVIEW_NORMAL_HEADER=${STYLE_LIVEVIEW_NORMAL_HEADER:="$CSI$SGI_INVERSE;${SGI_BOLD}m"}
