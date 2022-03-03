#!/bin/sh

GWDIR=${GWDIR:='.'}

if [ -z "$SENSORTYPE_WH31TEMP_MAXCH" ]; then
    . $GWDIR/lib/sensortype.sh
fi

#default livedata headers, may be overridden by -A language file or environment variables on cmd line
export LIVEDATA_INTEMP_HEADER="${LIVEDATA_INTEMP_HEADER:="Indoor temperature"}"
export LIVEDATA_OUTTEMP_HEADER="${LIVEDATA_OUTTEMP_HEADER:="Outdoor temperature"}"
export LIVEDATA_INHUMI_HEADER="${LIVEDATA_INHUMI_HEADER:="Indoor humidity"}"
export LIVEDATA_OUTHUMI_HEADER="${LIVEDATA_OUTHUMI_HEADER:="Outdoor humidity"}"

export LIVEDATA_PRESSURE_ABSBARO_HEADER="${LIVEDATA_PRESSURE_ABSBARO_HEADER:="Absolute pressure"}"
export LIVEDATA_PRESSURE_RELBARO_HEADER="${LIVEDATA_PRESSURE_RELBARO_HEADER:="Relative pressure"}"

export LIVEDATA_WINDCHILL_HEADER="${LIVEDATA_WINDCHILL_HEADER:="Windchill"}"
export LIVEDATA_DEWPOINT_HEADER="${LIVEDATA_DEWPOINT_HEADER:="Dewpoint"}"

export LIVEDATA_WINDDAILYMAX_HEADER="${LIVEDATA_WINDDAILYMAX_HEADER:="Wind max."}"
export LIVEDATA_WINDDIRECTION_HEADER="${LIVEDATA_WINDDIRECTION_HEADER:="Wind direction"}"
export LIVEDATA_WINDDIRECTION_COMPASS_HEADER="${LIVEDATA_WINDDIRECTION_COMPASS_HEADER:="Wind compass direction"}"
export LIVEDATA_WINDGUSTSPEED_HEADER="${LIVEDATA_WINDGUSTSPEED_HEADER:="Wind gust"}"
export LIVEDATA_WINDSPEED_HEADER="${LIVEDATA_WINDSPEED_HEADER:="Wind"}"

export LIVEDATA_SOLAR_LIGHT_HEADER="${LIVEDATA_SOLAR_LIGHT_HEADER:="Solar radiation"}"
export LIVEDATA_SOLAR_UV_HEADER="${LIVEDATA_SOLAR_UV_HEADER:="Solar UV radiation"}" # available in binary data
export LIVEDATA_SOLAR_UVI_HEADER="${LIVEDATA_SOLAR_UVI_HEADER:="Solar UV index"}"

export LIVEDATA_RAINRATE_HEADER="${LIVEDATA_RAINRATE_HEADER:="Rain rate"}"
export LIVEDATA_RAINEVENT_HEADER="${LIVEDATA_RAINEVENT_HEADER:="Rain event"}"
export LIVEDATA_RAINHOUR_HEADER="${LIVEDATA_RAINHOUR_HEADER:="Rain hour"}"
export LIVEDATA_RAINDAY_HEADER="${LIVEDATA_RAINDAY_HEADER:="Rain day"}"
export LIVEDATA_RAINWEEK_HEADER="${LIVEDATA_RAINWEEK_HEADER:="Rain week"}"
export LIVEDATA_RAINMONTH_HEADER="${LIVEDATA_RAINMONTH_HEADER:="Rain month"}"
export LIVEDATA_RAINYEAR_HEADER="${LIVEDATA_RAINYEAR_HEADER:="Rain year"}"
export LIVEDATA_RAINTOTAL_HEADER="${LIVEDATA_RAINTOTAL_HEADER:="Rain total"}"

export LIVEDATA_LEAK_YES="${LIVEDATA_LEAK_YES:="YES"}"
export  LIVEDATA_LEAK_NO="${LIVEDATA_LEAK_NO:="NO "}"

export LIVEDATA_SOILMOISTURE_GROUPHEADER="${LIVEDATA_SOILMOISTURE_GROUPHEADER:="ＳＯＩＬＭＯＩＳＴＵＲＥ"}"
        export LIVEDATA_SOILTEMP_GROUPHEADER="${LIVEDATA_SOILTEMP_GROUPHEADER:="ＳＯＩＬＴＥＭＰＥＲＡＴＵＲＥ"}"
                export LIVEDATA_PM25_GROUPHEADER="${LIVEDATA_PM25_GROUPHEADER:="ＰＭ２.５ ＡＩＲ ＱＵＡＬＩＴＹ"}"
  export LIVEDATA_LEAFWETNESS_GROUPHEADER="${LIVEDATA_LEAFWETNESS_GROUPHEADER:="ＬＥＡＦＷＥＴＮＥＳＳ"}"
          export LIVEDATA_TEMPUSR_GROUPHEADER="${LIVEDATA_TEMPUSR_GROUPHEADER:="ＴＥＭＰＵＳＲ"}"
          export LIVEDATA_WH45CO2_GROUPHEADER="${LIVEDATA_WH45CO2_GROUPHEADER:="ＣＯ２"}"
      export LIVEDATA_LIGHTNING_GROUPHEADER="${LIVEDATA_LIGHTNING_GROUPHEADER:="ＬＩＧＨＴＮＩＮＧ"}"
                export LIVEDATA_LEAK_GROUPHEADER="${LIVEDATA_LEAK_GROUPHEADER:="ＬＥＡＫ"}"
                export LIVEDATA_RAIN_GROUPHEADER="${LIVEDATA_RAIN_GROUPHEADER:="ＲＡＩＮ"}"
              export LIVEDATA_SOLAR_GROUPHEADER="${LIVEDATA_SOLAR_GROUPHEADER:="ＳＯＬＡＲ"}"
                export LIVEDATA_WIND_GROUPHEADER="${LIVEDATA_WIND_GROUPHEADER:="ＷＩＮＤ"}"
        export LIVEDATA_PRESSURE_GROUPHEADER="${LIVEDATA_PRESSURE_GROUPHEADER:="ＰＲＥＳＳＵＲＥ"}"
                    export LIVEDATA_TEMPERATURE_GROUPHEADER="${LIVEDATA_TEMPERATURE_GROUPHEADER:="ＴＥＭＰＥＲＡＴＵＲＥ"}"
                    export LIVEDATA_SYSTEM_GROUPHEADER="${LIVEDATA_SYSTEM_GROUPHEADER:="ＳＹＳＴＥＭ"}"
                    export LIVEDATA_SENSOR_GROUPHEADER="${LIVEDATA_SENSOR_GROUPHEADER:="ＳＥＮＳＯＲ"}"

export LIVEDATA_LIGHTNING_DISTANCE_HEADER="${LIVEDATA_LIGHTNING_DISTANCE_HEADER:="Lightning distance (last)"}"
export LIVEDATA_LIGHTNING_TIME_UTC_HEADER="${LIVEDATA_LIGHTNING_TIME_UTC_HEADER:="Lightning time utc (last)"}"
export LIVEDATA_LIGHTNING_POWER_HEADER="${LIVEDATA_LIGHTNING_POWER_HEADER:="Lightning count today"}"

export LIVEDATA_WH45CO2_TEMPF_HEADER="${LIVEDATA_WH45CO2_TEMPF_HEADER:="Temperature"}"
export LIVEDATA_WH45CO2_HUMI_HEADER="${LIVEDATA_WH45CO2_HUMI_HEADER:="Humidity"}"
export LIVEDATA_WH45CO2_PM10_HEADER="${LIVEDATA_WH45CO2_PM10_HEADER:="PM10"}"
export LIVEDATA_WH45CO2_PM10_24HAVG_HEADER="${LIVEDATA_WH45CO2_PM10_24HAVG_HEADER:="PM10 24h avg."}"
export LIVEDATA_WH45CO2_PM25_HEADER="${LIVEDATA_WH45CO2_PM25_HEADER:="PM25"}"
export LIVEDATA_WH45CO2_PM25_24HAVG_HEADER="${LIVEDATA_WH45CO2_PM25_24HAVG_HEADER:="PM25 24h avg."}"
export LIVEDATA_WH45CO2_CO2_HEADER="${LIVEDATA_WH45CO2_CO2_HEADER:="CO2"}"
export LIVEDATA_WH45CO2_CO2_24HAVG_HEADER="${LIVEDATA_WH45CO2_CO2_24HAVG_HEADER:="CO2 24h avg."}"
export LIVEDATA_WH45CO2_BATTERY_HEADER="${LIVEDATA_WH45CO2_BATTERY_HEADER:="CO2 battery"}"

export LIVEDATA_WH65_BATTERY_HEADER="${LIVEDATA_WH65_BATTERY_HEADER:="WH65 Weather station"}"
export LIVEDATA_WH68_BATTERY_HEADER="${LIVEDATA_WH68_BATTERY_HEADER:="WH68 Weather station"}"
export LIVEDATA_WH80_BATTERY_HEADER="${LIVEDATA_WH80_BATTERY_HEADER:="WH80 Weather station"}"

export LIVEDATA_WH32_TEMPERATURE_BATTERY_HEADER="${LIVEDATA_WH32_TEMPERATURE_BATTERY_HEADER:="Temperature out battery"}"
export LIVEDATA_WH40_RAINFALL_BATTERY_HEADER="${LIVEDATA_WH40_RAINFALL_BATTERY_HEADER:="Rainfall battery"}"
export LIVEDATA_WH57_LIGHTNING_BATTERY_HEADER="${LIVEDATA_WH57_LIGHTNING_BATTERY_HEADER="Lightning battery"}"

export    LIVEDATA_SYSTEM_SENSOR_CONNECTED_HEADER="${LIVEDATA_SYSTEM_SENSOR_CONNECTED_HEADER:="System sensors connected"}"
export    LIVEDATA_SYSTEM_SENSOR_DISCONNECTED_HEADER="${LIVEDATA_SYSTEM_SENSOR_DISCONNECTED_HEADER:="System sensors disconnected"}"
export    LIVEDATA_SYSTEM_SENSOR_SEARCHING_HEADER="${LIVEDATA_SYSTEM_SENSOR_SEARCHING_HEADER:="System sensors searching"}"
export    LIVEDATA_SYSTEM_SENSOR_DISABLED_HEADER="${LIVEDATA_SYSTEM_SENSOR_DISABLED_HEADER:="System sensors disabled"}"

export LIVEDATA_SYSTEM_HOST_HEADER="${LIVEDATA_SYSTEM_HOST_HEADER:="System host"}"
export LIVEDATA_SYSTEM_MAC_HEADER="${LIVEDATA_SYSTEM_MAC_HEADER:="System mac"}"
export LIVEDATA_SYSTEM_PROTOCOL_HEADER="${LIVEDATA_SYSTEM_PROTOCOL_HEADER:="System protocol"}"
export LIVEDATA_SYSTEM_TIMEZONE_AUTO_HEADER="${LIVEDATA_SYSTEM_TIMEZONE_AUTO_HEADER:="System timezone AUTO"}"
export LIVEDATA_SYSTEM_TIMEZONE_DST_HEADER="${LIVEDATA_SYSTEM_TIMEZONE_DST_HEADER:="System timezone DST"}"
export LIVEDATA_SYSTEM_TIMEZONE_HEADER="${LIVEDATA_SYSTEM_TIMEZONE_HEADER:="System timezone (manual)"}"

export LIVEDATA_STATE_ON="${LIVEDATA_STATE_ON:="on"}"
export LIVEDATA_STATE_OFF="${LIVEDATA_STATE_OFF:="off"}"

N=1
while [ "$N" -le "$SENSORTYPE_WH31TEMP_MAXCH" ]; do 
    eval export LIVEDATA_TEMP_HEADER$N=\"\$\{LIVEDATA_TEMP_HEADER$N:=\"Temperature $N\"\}\"
    eval export LIVEDATA_TEMP_BATTERY_HEADER$N=\"\$\{LIVEDATA_TEMP_BATTERY_HEADER$N:=\"Temperature $N battery\"\}\"
    eval export LIVEDATA_HUMIDITY_HEADER$N=\"\$\{LIVEDATA_HUMIDITY_HEADER$N:=\"Humidity $N\"\}\"
    N=$(( N + 1 ))
done

N=1
while [ "$N" -le "$SENSORTYPE_WH55LEAK_MAXCH" ]; do 
    eval export LIVEDATA_LEAK_HEADER$N=\"\$\{LIVEDATA_LEAK_HEADER$N:="Leak $N"\}\"
    eval export LIVEDATA_LEAK_BATTERY_HEADER$N=\"\$\{LIVEDATA_LEAK_BATTERY_HEADER$N:="Leak $N battery"\}\"
    N=$(( N + 1 ))
done


N=1
while [ "$N" -le "$SENSORTYPE_WH43PM25_MAXCH" ]; do 
    eval export LIVEDATA_PM25_HEADER$N=\"\$\{LIVEDATA_PM25_HEADER$N:="PM 2.5 $N"\}\"
    eval export LIVEDATA_PM25_24HAVG_HEADER$N=\"\$\{LIVEDATA_PM25_24HAVG_HEADER$N:="PM 2.5 24h avg. $N"\}\"
    eval export LIVEDATA_PM25_BATTERY_HEADER$N=\"\$\{LIVEDATA_PM25_BATTERY_HEADER$N:="PM 2.5 $N battery"\}\"
    N=$(( N + 1 ))
done

N=1
while [ "$N" -le "$SENSORTYPE_WH51SOILMOISTURE_MAXCH" ]; do 
    eval export LIVEDATA_SOILMOISTURE_HEADER$N=\"\$\{LIVEDATA_SOILMOISTURE_HEADER$N:="Soilmoisture $N"\}\"
    eval export LIVEDATA_SOILMOISTURE_BATTERY_HEADER$N=\"\$\{LIVEDATA_SOILMOISTURE_BATTERY_HEADER$N:="Soilmoisture $N battery"\}\"
    N=$(( N + 1 ))
done

N=1
while [ "$N" -le "$SENSORTYPE_WH34SOILTEMP_MAXCH" ]; do 
    eval export LIVEDATA_SOILTEMP_HEADER$N=\"\$\{LIVEDATA_SOILTEMP_HEADER$N:="Soiltemperature $N"\}\"
    eval export LIVEDATA_SOILTEMP_BATTERY_HEADER$N=\"\$\{LIVEDATA_SOILTEMP_BATTERY_HEADER$N:="Soiltemperatur $N battery"\}\"
    N=$(( N + 1 ))
done

N=1
while [ "$N" -le "$SENSORTYPE_WH35LEAFWETNESS_MAXCH" ]; do 
    eval export LIVEDATA_LEAFWETNESS_HEADER$N=\"\$\{LIVEDATA_LEAFWETNESS_HEADER$N:="Leafwetness $N"\}\"
    eval export LIVEDATA_LEAFWETNESS_BATTERY_HEADER$N=\"\$\{LIVEDATA_LEAFWETNESS_BATTERY_HEADER$N:="Leafwetness $N battery"\}\"
    N=$(( N + 1 ))
done

N=1
while [ "$N" -le "$SENSORTYPE_TF_USR_MAXCH" ]; do 
    eval export LIVEDATA_TF_USR_HEADER$N=\"\$\{LIVEDATA_TF_USR_HEADER$N:="Temperature USR $N"\}\"
    eval export LIVEDATA_TF_USR_BATTERY_HEADER$N=\"\$\{LIVEDATA_TF_USR_BATTERY_HEADER$N:="Temperature USR $N battery"\}\"
    N=$(( N + 1 ))
done

export LIVEDATA_SYSTEM_VERSION_HEADER="${LIVEDATA_SYSTEM_VERSION_HEADER:="System version"}"
export LIVEDATA_SYSTEM_UTC_HEADER="${LIVEDATA_SYSTEM_UTC_HEADER:="System utc"}"
export LIVEDATA_SYSTEM_FREQUENCY_HEADER="${LIVEDATA_SYSTEM_FREQUENCY_HEADER:="System frequency"}"
export LIVEDATA_SYSTEM_MODEL_HEADER="${LIVEDATA_SYSTEM_MODEL_HEADER:="System model"}"
export LIVEDATA_SYSTEM_SENSORTYPE_HEADER="${LIVEDATA_SYSTEM_SENSORTYPE_HEADER:="System type"}"