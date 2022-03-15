#!/bin/sh
#Limits for triggering of ansi escape highlights

#export LIVEDATALIMIT_RAINRATE=${LIVEDATALIMIT_RAINRATE:=5} # 0.5 mm/h - scale x10

export LIVEDATALIMIT_RAINHOUR="${LIVEDATALIMIT_RAINHOUR:=5}"
export LIVEDATALIMIT_RAINDAY="${LIVEDATALIMIT_RAINDAY:=100}" # 10.0 mm
export LIVEDATALIMIT_RAINEVENT="${LIVEDATALIMIT_RAINEVENT:=200}"

export LIVEDATALIMIT_PRESSURE_RELBARO_LOW="${LIVEDATALIMIT_PRESSURE_RELBARO_LOW:=9900}" # 990 hpa - scale x10
export LIVEDATALIMIT_PRESSURE_ABSBARO_LOW="${LIVEDATALIMIT_PRESSURE_ABSBARO_LOW:=9900}" 

export LIVEDATALIMIT_OUTTEMP_LOW="${LIVEDATALIMIT_OUTTEMP_LOW:=-10}" # -1.0 - scale x10
export LIVEDATALIMIT_OUTTEMP_HIGH="${LIVEDATALIMIT_OUTTEMP_HIGH:=170}" # 17.0 - scale x10
export LIVEDATALIMIT_INTEMP_LOW="${LIVEDATALIMIT_INTEMP_LOW:=200}" 
export LIVEDATALIMIT_INTEMP_HIGH="${LIVEDATALIMIT_INTEMP_HIGH:=230}" 
