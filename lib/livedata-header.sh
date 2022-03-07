#!/bin/sh

GWDIR=${GWDIR:='.'}

if [ -z "$SENSORTYPE_WH31TEMP_MAXCH" ]; then
    . "$GWDIR/lib/sensortype.sh"
fi

#default livedata headers, may be overridden by -A language file or environment variables on cmd line
export LIVEDATAHEADER_INTEMP="${LIVEDATAHEADER_INTEMP:="Indoor temperature"}"
export LIVEDATAHEADER_OUTTEMP="${LIVEDATAHEADER_OUTTEMP:="Outdoor temperature"}"
export LIVEDATAHEADER_INHUMI="${LIVEDATAHEADER_INHUMI:="Indoor humidity"}"
export LIVEDATAHEADER_OUTHUMI="${LIVEDATAHEADER_OUTHUMI:="Outdoor humidity"}"

export LIVEDATAHEADER_PRESSURE_ABSBARO="${LIVEDATAHEADER_PRESSURE_ABSBARO:="Absolute pressure"}"
export LIVEDATAHEADER_PRESSURE_RELBARO="${LIVEDATAHEADER_PRESSURE_RELBARO:="Relative pressure"}"

export LIVEDATAHEADER_WINDCHILL="${LIVEDATAHEADER_WINDCHILL:="Windchill"}"
export LIVEDATAHEADER_DEWPOINT="${LIVEDATAHEADER_DEWPOINT:="Dewpoint"}"

export LIVEDATAHEADER_WINDDAILYMAX="${LIVEDATAHEADER_WINDDAILYMAX:="Wind max."}"
export LIVEDATAHEADER_WINDDIRECTION="${LIVEDATAHEADER_WINDDIRECTION:="Wind direction"}"
export LIVEDATAHEADER_WINDDIRECTION_COMPASS="${LIVEDATAHEADER_WINDDIRECTION_COMPASS:="Wind compass direction"}"
export LIVEDATAHEADER_WINDGUSTSPEED="${LIVEDATAHEADER_WINDGUSTSPEED:="Wind gust"}"
export LIVEDATAHEADER_WINDSPEED="${LIVEDATAHEADER_WINDSPEED:="Wind"}"

export LIVEDATAHEADER_SOLAR_LIGHT="${LIVEDATAHEADER_SOLAR_LIGHT:="Solar radiation"}"
export LIVEDATAHEADER_SOLAR_UV="${LIVEDATAHEADER_SOLAR_UV:="Solar UV radiation"}" # available in binary data
export LIVEDATAHEADER_SOLAR_UVI="${LIVEDATAHEADER_SOLAR_UVI:="Solar UV index"}"

export LIVEDATAHEADER_RAINRATE="${LIVEDATAHEADER_RAINRATE:="Rain rate"}"
export LIVEDATAHEADER_RAINEVENT="${LIVEDATAHEADER_RAINEVENT:="Rain event"}"
export LIVEDATAHEADER_RAINHOUR="${LIVEDATAHEADER_RAINHOUR:="Rain hour"}"
export LIVEDATAHEADER_RAINDAY="${LIVEDATAHEADER_RAINDAY:="Rain day"}"
export LIVEDATAHEADER_RAINWEEK="${LIVEDATAHEADER_RAINWEEK:="Rain week"}"
export LIVEDATAHEADER_RAINMONTH="${LIVEDATAHEADER_RAINMONTH:="Rain month"}"
export LIVEDATAHEADER_RAINYEAR="${LIVEDATAHEADER_RAINYEAR:="Rain year"}"
export LIVEDATAHEADER_RAINTOTAL="${LIVEDATAHEADER_RAINTOTAL:="Rain total"}"

export LIVEDATAHEADER_LEAK_YES="${LIVEDATAHEADER_LEAK_YES:="YES"}"
export  LIVEDATAHEADER_LEAK_NO="${LIVEDATAHEADER_LEAK_NO:="NO "}"

export LIVEDATAGROUPHEADER_SOILMOISTURE="${LIVEDATAGROUPHEADER_SOILMOISTURE:="ＳＯＩＬＭＯＩＳＴＵＲＥ"}"
        export LIVEDATAGROUPHEADER_SOILTEMP="${LIVEDATAGROUPHEADER_SOILTEMP:="ＳＯＩＬＴＥＭＰＥＲＡＴＵＲＥ"}"
                export LIVEDATAGROUPHEADER_PM25="${LIVEDATAGROUPHEADER_PM25:="ＰＭ２.５ ＡＩＲ ＱＵＡＬＩＴＹ"}"
  export LIVEDATAGROUPHEADER_LEAFWETNESS="${LIVEDATAGROUPHEADER_LEAFWETNESS:="ＬＥＡＦＷＥＴＮＥＳＳ"}"
          export LIVEDATAGROUPHEADER_TEMPUSR="${LIVEDATAGROUPHEADER_TEMPUSR:="ＴＥＭＰＵＳＲ"}"
          export LIVEDATAGROUPHEADER_WH45CO2="${LIVEDATAGROUPHEADER_WH45CO2:="ＣＯ２"}"
      export LIVEDATAGROUPHEADER_LIGHTNING="${LIVEDATAGROUPHEADER_LIGHTNING:="ＬＩＧＨＴＮＩＮＧ"}"
                export LIVEDATAGROUPHEADER_LEAK="${LIVEDATAGROUPHEADER_LEAK:="ＬＥＡＫ"}"
                export LIVEDATAGROUPHEADER_RAIN="${LIVEDATAGROUPHEADER_RAIN:="ＲＡＩＮ"}"
              export LIVEDATAGROUPHEADER_SOLAR="${LIVEDATAGROUPHEADER_SOLAR:="ＳＯＬＡＲ"}"
                export LIVEDATAGROUPHEADER_WIND="${LIVEDATAGROUPHEADER_WIND:="ＷＩＮＤ"}"
        export LIVEDATAGROUPHEADER_PRESSURE="${LIVEDATAGROUPHEADER_PRESSURE:="ＰＲＥＳＳＵＲＥ"}"
                    export LIVEDATAGROUPHEADER_TEMPERATURE="${LIVEDATAGROUPHEADER_TEMPERATURE:="ＴＥＭＰＥＲＡＴＵＲＥ"}"
                    export LIVEDATAGROUPHEADER_SYSTEM="${LIVEDATAGROUPHEADER_SYSTEM:="ＳＹＳＴＥＭ"}"
                    export LIVEDATAGROUPHEADER_SENSOR="${LIVEDATAGROUPHEADER_SENSOR:="ＳＥＮＳＯＲ"}"

export LIVEDATAHEADER_LIGHTNING_DISTANCE="${LIVEDATAHEADER_LIGHTNING_DISTANCE:="Lightning distance (last)"}"
export LIVEDATAHEADER_LIGHTNING_TIME_UTC="${LIVEDATAHEADER_LIGHTNING_TIME_UTC:="Lightning time utc (last)"}"
export LIVEDATAHEADER_LIGHTNING_POWER="${LIVEDATAHEADER_LIGHTNING_POWER:="Lightning count today"}"

export LIVEDATAHEADER_WH45CO2_TEMPF="${LIVEDATAHEADER_WH45CO2_TEMPF:="Temperature"}"
export LIVEDATAHEADER_WH45CO2_HUMI="${LIVEDATAHEADER_WH45CO2_HUMI:="Humidity"}"
export LIVEDATAHEADER_WH45CO2_PM10="${LIVEDATAHEADER_WH45CO2_PM10:="PM10"}"
export LIVEDATAHEADER_WH45CO2_PM10_24HAVG="${LIVEDATAHEADER_WH45CO2_PM10_24HAVG:="PM10 24h avg."}"
export LIVEDATAHEADER_WH45CO2_PM25="${LIVEDATAHEADER_WH45CO2_PM25:="PM25"}"
export LIVEDATAHEADER_WH45CO2_PM25_24HAVG="${LIVEDATAHEADER_WH45CO2_PM25_24HAVG:="PM25 24h avg."}"
export LIVEDATAHEADER_WH45CO2_CO2="${LIVEDATAHEADER_WH45CO2_CO2:="CO2"}"
export LIVEDATAHEADER_WH45CO2_CO2_24HAVG="${LIVEDATAHEADER_WH45CO2_CO2_24HAVG:="CO2 24h avg."}"
export LIVEDATAHEADER_WH45CO2_BATTERY="${LIVEDATAHEADER_WH45CO2_BATTERY:="CO2 battery"}"

export LIVEDATAHEADER_WH65_BATTERY="${LIVEDATAHEADER_WH65_BATTERY:="WH65 Weather station"}"
export LIVEDATAHEADER_WH68_BATTERY="${LIVEDATAHEADER_WH68_BATTERY:="WH68 Weather station"}"
export LIVEDATAHEADER_WH80_BATTERY="${LIVEDATAHEADER_WH80_BATTERY:="WH80 Weather station"}"

export LIVEDATAHEADER_WH32_TEMPERATURE_BATTERY="${LIVEDATAHEADER_WH32_TEMPERATURE_BATTERY:="Temperature out battery"}"
export LIVEDATAHEADER_WH40_RAINFALL_BATTERY="${LIVEDATAHEADER_WH40_RAINFALL_BATTERY:="Rainfall battery"}"
export LIVEDATAHEADER_WH57_LIGHTNING_BATTERY="${LIVEDATAHEADER_WH57_LIGHTNING_BATTERY="Lightning battery"}"

export LIVEDATAHEADER_SYSTEM_SENSOR_CONNECTED="${LIVEDATAHEADER_SYSTEM_SENSOR_CONNECTED:="System sensors connected"}"
export LIVEDATAHEADER_SYSTEM_SENSOR_DISCONNECTED="${LIVEDATAHEADER_SYSTEM_SENSOR_DISCONNECTED:="System sensors disconnected"}"
export LIVEDATAHEADER_SYSTEM_SENSOR_SEARCHING="${LIVEDATAHEADER_SYSTEM_SENSOR_SEARCHING:="System sensors searching"}"
export LIVEDATAHEADER_SYSTEM_SENSOR_DISABLED="${LIVEDATAHEADER_SYSTEM_SENSOR_DISABLED:="System sensors disabled"}"

export LIVEDATAHEADER_SYSTEM_HOST="${LIVEDATAHEADER_SYSTEM_HOST:="System host"}"
export LIVEDATAHEADER_SYSTEM_MAC="${LIVEDATAHEADER_SYSTEM_MAC:="System mac"}"
export LIVEDATAHEADER_SYSTEM_PROTOCOL="${LIVEDATAHEADER_SYSTEM_PROTOCOL:="System protocol"}"
export LIVEDATAHEADER_SYSTEM_TIMEZONE_AUTO="${LIVEDATAHEADER_SYSTEM_TIMEZONE_AUTO:="System timezone AUTO"}"
export LIVEDATAHEADER_SYSTEM_TIMEZONE_DST="${LIVEDATAHEADER_SYSTEM_TIMEZONE_DST:="System timezone DST"}"
export LIVEDATAHEADER_SYSTEM_TIMEZONE="${LIVEDATAHEADER_SYSTEM_TIMEZONE:="System timezone (manual)"}"

N=1
while [ "$N" -le "$SENSORTYPE_WH31TEMP_MAXCH" ]; do 
    eval export LIVEDATAHEADER_WH31TEMP$N=\"\$\{LIVEDATAHEADER_WH31TEMP$N:=\"Temperature $N\"\}\"
    eval export LIVEDATAHEADER_WH31TEMP${N}_BATTERY=\"\$\{LIVEDATAHEADER_WH31TEMP${N}_BATTERY:=\"Temperature $N battery\"\}\"
    eval export LIVEDATAHEADER_WH31HUMIDITY$N=\"\$\{LIVEDATAHEADER_WH31HUMIDITY$N:=\"Humidity $N\"\}\"
    N=$(( N + 1 ))
done

N=1
while [ "$N" -le "$SENSORTYPE_WH55LEAK_MAXCH" ]; do 
    eval export LIVEDATAHEADER_LEAK$N=\"\$\{LIVEDATAHEADER_LEAK$N:="Leak $N"\}\"
    eval export LIVEDATAHEADER_LEAK${N}_BATTERY=\"\$\{LIVEDATAHEADER_LEAK${N}_BATTERY:="Leak $N battery"\}\"
    N=$(( N + 1 ))
done


N=1
while [ "$N" -le "$SENSORTYPE_WH43PM25_MAXCH" ]; do 
    eval export LIVEDATAHEADER_PM25$N=\"\$\{LIVEDATAHEADER_PM25$N:="PM 2.5 $N"\}\"
    eval export LIVEDATAHEADER_PM25${N}_24HAVG=\"\$\{LIVEDATAHEADER_PM25${N}_24HAVG:="PM 2.5 24h avg. $N"\}\"
    eval export LIVEDATAHEADER_PM25${N}_BATTERY=\"\$\{LIVEDATAHEADER_PM25${N}_BATTERY:="PM 2.5 $N battery"\}\"
    N=$(( N + 1 ))
done

N=1
while [ "$N" -le "$SENSORTYPE_WH51SOILMOISTURE_MAXCH" ]; do 
    eval export LIVEDATAHEADER_SOILMOISTURE$N=\"\$\{LIVEDATAHEADER_SOILMOISTURE$N:="Soilmoisture $N"\}\"
    eval export LIVEDATAHEADER_SOILMOISTURE${N}_BATTERY=\"\$\{LIVEDATAHEADER_SOILMOISTURE${N}_BATTERY:="Soilmoisture $N battery"\}\"
    N=$(( N + 1 ))
done

N=1
while [ "$N" -le "$SENSORTYPE_WH34SOILTEMP_MAXCH" ]; do 
    eval export LIVEDATAHEADER_SOILTEMP$N=\"\$\{LIVEDATAHEADER_SOILTEMP$N:="Soiltemperature $N"\}\"
    eval export LIVEDATAHEADER_SOILTEMP${N}_BATTERY=\"\$\{LIVEDATAHEADER_SOILTEMP${N}_BATTERY:="Soiltemperatur $N battery"\}\"
    N=$(( N + 1 ))
done

N=1
while [ "$N" -le "$SENSORTYPE_WH35LEAFWETNESS_MAXCH" ]; do 
    eval export LIVEDATAHEADER_LEAFWETNESS$N=\"\$\{LIVEDATAHEADER_LEAFWETNESS$N:="Leafwetness $N"\}\"
    eval export LIVEDATAHEADER_LEAFWETNESS${N}_BATTERY=\"\$\{LIVEDATAHEADER_LEAFWETNESS${N}_BATTERY:="Leafwetness $N battery"\}\"
    N=$(( N + 1 ))
done

N=1
while [ "$N" -le "$SENSORTYPE_TF_USR_MAXCH" ]; do 
    eval export LIVEDATAHEADER_TEMPF_USR$N=\"\$\{LIVEDATAHEADER_TEMPF_USR$N:="Temperature USR $N"\}\"
    eval export LIVEDATAHEADER_TEMPF_USR${N}_BATTERY=\"\$\{LIVEDATAHEADER_TEMPF_USR${N}_BATTERY:="Temperature USR $N battery"\}\"
    N=$(( N + 1 ))
done

export LIVEDATAHEADER_SYSTEM_VERSION="${LIVEDATAHEADER_SYSTEM_VERSION:="System version"}"
export LIVEDATAHEADER_SYSTEM_UTC="${LIVEDATAHEADER_SYSTEM_UTC:="System utc"}"
export LIVEDATAHEADER_SYSTEM_FREQUENCY="${LIVEDATAHEADER_SYSTEM_FREQUENCY:="System frequency"}"
export LIVEDATAHEADER_SYSTEM_MODEL="${LIVEDATAHEADER_SYSTEM_MODEL:="System model"}"
export LIVEDATAHEADER_SYSTEM_SENSORTYPE="${LIVEDATAHEADER_SYSTEM_SENSORTYPE:="System type"}"