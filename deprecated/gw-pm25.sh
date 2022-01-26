#!/usr/bin/dash
# https://www.airnow.gov/aqi/aqi-basics/
#added space at end when doing when refreshing screen with printf \e[H, otherwise status is merged if changed
                              PM25_AQI_GOOD=${PM25_AQI_GOOD:="GOOD         "}
                      PM25_AQI_MODERATE=${PM25_AQI_MODERATE:="MODERATE     "}
PM25_AQI_UNHEALTHY_SENSITIVE=${PM25_AQI_UNHEALTHY_SENSITIVE:="UNHEALTHY S. "}
                    PM25_AQI_UNHEALTHY=${PM25_AQI_UNHEALTHY:="UNHEALTY     "}
          PM25_AQI_VERY_UNHEALTHY=${PM25_AQI_VERY_UNHEALTHY:="VERY UNHEALTY"}
                    PM25_AQI_HAZARDOUS=${PM25_AQI_HAZARDOUS:="HAZARDOUS    "}

               PM25_AQI_GOOD_LIMIT=121
           PM25_AQI_MODERATE_LIMIT=355
PM25_AQI_UNHEALTHY_SENSITIVE_LIMIT=555
         PM25_AQI_UNHEALTHY_LIMIT=1505
    PM25_AQI_VERY_UNHEALTHY_LIMIT=2505

setAQI()
#https://blissair.com/what-is-pm-2-5.htm
{
    if [ "$1" -lt $PM25_AQI_GOOD_LIMIT ]; then
      VALUE_PM25_AQI=$PM25_AQI_GOOD
    elif [ "$1" -ge $PM25_AQI_GOOD_LIMIT ] && [ "$1" -lt $PM25_AQI_MODERATE_LIMIT ]; then
      VALUE_PM25_AQI=$PM25_AQI_MODERATE
    elif [ "$1" -ge $PM25_AQI_MODERATE_LIMIT ] && [ "$1" -lt $PM25_AQI_UNHEALTHY_SENSITIVE_LIMIT ]; then
      VALUE_PM25_AQI=$PM25_AQI_UNHEALTHY_SENSITIVE
    elif [ "$1" -ge $PM25_AQI_UNHEALTHY_SENSITIVE_LIMIT ] && [ "$1" -lt $PM25_AQI_UNHEALTHY_LIMIT ]; then
      VALUE_PM25_AQI=$PM25_AQI_UNHEALTHY
    elif [ "$1" -ge $PM25_AQI_UNHEALTHY_LIMIT ] && [ "$1" -lt $PM25_AQI_VERY_UNHEALTHY_LIMIT ]; then
      VALUE_PM25_AQI=$PM25_AQI_VERY_UNHEALTHY
    elif [ "$1" -ge $PM25_AQI_VERY_UNHEALTHY_LIMIT ]; then
      VALUE_PM25_AQI=$PM25_AQI_HAZARDOUS
    fi
}

setStyleAQI()
{
    if [ "$1" -lt 121 ]; then
       STYLE_AQI="$STYLE_PM25_AQI_GOOD"
    elif [ "$1" -ge 121 ] && [ "$1" -lt $PM25_AQI_MODERATE_LIMIT ]; then
        STYLE_AQI=$STYLE_PM25_AQI_MODERATE
    elif [ "$1" -ge $PM25_AQI_MODERATE_LIMIT ] && [ "$1" -lt $PM25_AQI_UNHEALTHY_SENSITIVE_LIMIT ]; then
        STYLE_AQI=$STYLE_PM25_AQI_UNHEALTHY_SENSITIVE
    elif [ "$1" -ge $PM25_AQI_UNHEALTHY_SENSITIVE_LIMIT ] && [ "$1" -lt $PM25_AQI_UNHEALTHY_LIMIT ]; then
        STYLE_AQI=$STYLE_PM25_AQI_UNHEALTHY
    elif [ "$1" -ge $PM25_AQI_UNHEALTHY_LIMIT ] && [ "$1" -lt $PM25_AQI_VERY_UNHEALTHY_LIMIT ]; then
        STYLE_AQI=$STYLE_PM25_AQI_VERY_UNHEALTHY
    elif [ "$1" -ge $PM25_AQI_VERY_UNHEALTHY_LIMIT ]; then
       #STYLE_AQI="$CSI$SGI_FOREGC$SGI_COLOR_WHITE;${SGI_BACKGC_24BIT}126;0;35m" #7f0023
       STYLE_AQI=$STYLE_PM25_AQI_HAZARDOUS
    fi
}