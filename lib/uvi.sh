#!/bin/sh

export          UV_RISK_LOW="${UV_RISK_LOW:="LOW"}"
export UV_RISK_MODERATE="${UV_RISK_MODERATE:="MODERATE"}"
export         UV_RISK_HIGH="${UV_RISK_HIGH:="HIGH"}"
export UV_RISK_VERYHIGH="${UV_RISK_VERYHIGH:="VERY HIGH"}"
export   UV_RISK_EXTREME="${UV_RISK_EXTREME:="EXTREME"}"

setUVRisk()
#$1 UVI
{
    if [ "$1" -ge 0 ] && [ "$1" -le 2 ]; then
       VALUE_UV_RISK=$UV_RISK_LOW
    elif [ "$1" -ge 3 ] && [ "$1" -le 5 ]; then
        VALUE_UV_RISK=$UV_RISK_MODERATE
    elif [ "$1" -ge 6 ] && [ "$1" -le 7 ]; then
        VALUE_UV_RISK=$UV_RISK_HIGH
    elif [ "$1" -ge 8 ] && [ "$1" -le 10 ]; then
        VALUE_UV_RISK="$UV_RISK_VERYHIGH"
    elif [ "$1" -ge 11 ]; then
        VALUE_UV_RISK=$UV_RISK_EXTREME
    fi
}
