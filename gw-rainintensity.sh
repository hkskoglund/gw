#!/usr/bin/dash
#https://en.wikipedia.org/wiki/Rain#Intensity
#added space at end when doing when refreshing screen with printf \e[H, otherwise status is merged with previous value if changed
      RAININTENSITY_LIGHT=${RAININTENSITY_LIGHT:="LIGHT   "}
RAININTENSITY_MODERATE=${RAININTENSITY_MODERATE:="MODERATE"}
      RAININTENSITY_HEAVY=${RAININTENSITY_HEAVY:="HEAVY   "}
  RAININTENSITY_EXTREME=${RAININTENSITY_EXTREME:="EXTREME "}

  RAININTENSITY_LIGHT_LIMIT=${RAININTENSITY_LIGHT_LIMIT:=25}
  RAININTENSITY_MODERATE_LIMIT=${RAINTENSITY_MODERATE_LIMIT:=76}
  RAININTENSITY_HEAVY_LIMIT=${RAINTENSITY_HEAVY_LIMIT:=500}

setRainIntensity()
{
    if [ "$1" -gt 0 ] &&  [ "$1" -lt $RAININTENSITY_LIGHT_LIMIT ]; then
      VALUE_RAININTENSITY=$RAININTENSITY_LIGHT
    elif [ "$1" -ge $RAININTENSITY_LIGHT_LIMIT ] && [ "$1" -lt $RAININTENSITY_MODERATE_LIMIT ]; then
      VALUE_RAININTENSITY=$RAININTENSITY_MODERATE
    elif [ "$1" -ge  $RAININTENSITY_MODERATE_LIMIT ] && [ "$1" -lt $RAININTENSITY_HEAVY_LIMIT ]; then
      VALUE_RAININTENSITY=$RAININTENSITY_HEAVY
    elif [ "$1" -gt $RAININTENSITY_HEAVY_LIMIT ]; then
      VALUE_RAININTENSITY=$RAININTENSITY_EXTREME
    fi
}

setStyleRainIntensity()
{
    if [ "$1" -gt 0 ] && [ "$1" -lt "$RAININTENSITY_LIGHT_LIMIT" ]; then
       STYLE_RAININTENSITY="$STYLE_RAININTENSITY_LIGHT"
    elif [ "$1" -ge $RAININTENSITY_LIGHT_LIMIT ] && [ "$1" -lt $RAININTENSITY_MODERATE_LIMIT ]; then
        STYLE_RAININTENSITY=$STYLE_RAININTENSITY_MODERATE
    elif [ "$1" -ge $RAININTENSITY_MODERATE_LIMIT ] && [ "$1" -lt $RAININTENSITY_HEAVY_LIMIT ]; then
        STYLE_RAININTENSITY=$STYLE_RAININTENSITY_HEAVY
    elif [ "$1" -ge $RAININTENSITY_HEAVY_LIMIT ]; then
        STYLE_RAININTENSITY=$STYLE_RAININTENSITY_EXTREME
    fi
}