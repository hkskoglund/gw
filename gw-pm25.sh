#!/usr/bin/dash
# https://www.airnow.gov/aqi/aqi-basics/
#added space at end when doing when refreshing screen with printf \e[H, otherwise status is merged if changed
                              PM25_AQI_GOOD=${PM25_AQI_GOOD:="GOOD         "}
                      PM25_AQI_MODERATE=${PM25_AQI_MODERATE:="MODERATE     "}
PM25_AQI_UNHEALTHY_SENSITIVE=${PM25_AQI_UNHEALTHY_SENSITIVE:="UNHEALTHY S."}
                      PM25_AQI_UNHEALTHY=${PM25_AQI_UNHEALTHY:="UNHEALTY     "}
            PM25_AQI_VERY_UNHEALTHY=${PM25_AQI_VERY_UNHEALTHY:="VERY UNHEALTY"}
                    PM25_AQI_HAZARDOUS=${PM25_AQI_HAZARDOUS:="HAZARDOUS    "}

setAQI()
#https://blissair.com/what-is-pm-2-5.htm
{
    if [ "$1" -lt 121 ]; then
      VALUE_PM25_AQI=$PM25_AQI_GOOD
    elif [ "$1" -ge 121 ] && [ "$1" -lt 355 ]; then
      VALUE_PM25_AQI=$PM25_AQI_MODERATE
    elif [ "$1" -ge 355 ] && [ "$1" -lt 555 ]; then
      VALUE_PM25_AQI=$PM25_AQI_UNHEALTHY_SENSITIVE
    elif [ "$1" -ge 555 ] && [ "$1" -lt 1505 ]; then
      VALUE_PM25_AQI=$PM25_AQI_UNHEALTHY
    elif [ "$1" -ge 1505 ] && [ "$1" -lt 2505 ]; then
      VALUE_PM25_AQI=$PM25_AQI_VERY_UNHEALTHY
    elif [ "$1" -ge 2505 ]; then
      VALUE_PM25_AQI=$PM25_AQI_HAZARDOUS
    fi
}

setStyleAQI()
{
    if [ "$1" -lt 121 ]; then
       STYLE_AQI="$STYLE_PM25_AQI_GOOD"
    elif [ "$1" -ge 121 ] && [ "$1" -lt 355 ]; then
        STYLE_AQI=$STYLE_PM25_AQI_MODERATE
    elif [ "$1" -ge 355 ] && [ "$1" -lt 555 ]; then
        STYLE_AQI=$STYLE_PM25_AQI_UNHEALTHY_SENSITIVE
    elif [ "$1" -ge 555 ] && [ "$1" -lt 1505 ]; then
        STYLE_AQI=$STYLE_PM25_AQI_UNHEALTHY
    elif [ "$1" -ge 1505 ] && [ "$1" -lt 2505 ]; then
        STYLE_AQI=$STYLE_PM25_AQI_VERY_UNHEALTHY
    elif [ "$1" -ge 2505 ]; then
       #STYLE_AQI="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;${SGI_BACKGC_24BIT}126;0;35m" #7f0023
       STYLE_AQI=$STYLE_PM25_AQI_HAZARDOUS
    fi
}