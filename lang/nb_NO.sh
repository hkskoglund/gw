#!/bin/sh
#shellcheck disable=SC2034
LIVEDATA_INTEMP_HEADER="Innendørs temperatur"
LIVEDATA_PRESSURE_ABSBARO_HEADER="Absolutt trykk"
LIVEDATA_PRESSURE_RELBARO_HEADER="Relativt trykk"
LIVEDATA_OUTTEMP_HEADER="Utendørs temperatur"
LIVEDATA_INHUMI_HEADER="Innendørs fuktighet"
LIVEDATA_OUTHUMI_HEADER="Utendørs fuktighet"
LIVEDATA_WINDCHILL_HEADER="Følt temperatur"
LIVEDATA_DEWPOINT_HEADER="Duggpunkt temperaratur"

LIVEDATA_WINDDAILYMAX_HEADER="Vind idag maks."
LIVEDATA_WINDDIRECTION_HEADER="Vind retning"
LIVEDATA_WINDDIRECTION_COMPASS_HEADER="Vind kompass retning"
LIVEDATA_WINDGUSTSPEED_HEADER="Vindkast"
LIVEDATA_WINDSPEED_HEADER="Vind hastighet"
LIVEDATA_SOLAR_LIGHT_HEADER="Solstråling"
LIVEDATA_SOLAR_UV_HEADER="Sol UV stråling"
LIVEDATA_SOLAR_UVI_HEADER="Sol UV Indeks"

LIVEDATA_RAINRATE_HEADER="Regn intensitet"
LIVEDATA_RAINEVENT_HEADER="Regn hendelse"
LIVEDATA_RAINHOUR_HEADER="Regn time"
LIVEDATA_RAINDAY_HEADER="Regn idag"
LIVEDATA_RAINWEEK_HEADER="Regn uke"
LIVEDATA_RAINMONTH_HEADER="Regn måned"
LIVEDATA_RAINYEAR_HEADER="Regn år"

LIVEDATA_TEMP_HEADER1="Temperatur 1 Soverom"
LIVEDATA_TEMP_HEADER2="Temperatur 2 Bad"
LIVEDATA_TEMP_HEADER3="Temperatur 3 Vaskerom"
LIVEDATA_TEMP_HEADER4="Temperatur 4"
LIVEDATA_TEMP_HEADER5="Temperatur 5"
LIVEDATA_TEMP_HEADER6="Temperatur 6"
LIVEDATA_TEMP_HEADER7="Temperatur 7"
LIVEDATA_TEMP_HEADER8="Temperatur 8"

LIVEDATA_TEMP_BATTERY_HEADER1=$LIVEDATA_TEMP_HEADER1
LIVEDATA_TEMP_BATTERY_HEADER2=$LIVEDATA_TEMP_HEADER2
LIVEDATA_TEMP_BATTERY_HEADER3=$LIVEDATA_TEMP_HEADER3

LIVEDATA_LEAK_BATTERY_HEADER1="Lekkasje 1/oppvaskmaskin"

LIVEDATA_WH65_BATTERY_HEADER='WH65 Værstasjon'
LIVEDATA_WH40_RAINFALL_BATTERY_HEADER='Regnfall batteri'

LIVEDATA_HUMIDITY_HEADER1="Fuktighet Soverom"
LIVEDATA_HUMIDITY_HEADER2="Fuktighet Bad"
LIVEDATA_HUMIDITY_HEADER3="Fuktighet Vaskerom"

LIVEDATA_SOILMOISTURE_HEADER1="Julestjerne 🪴"
LIVEDATA_SOILMOISTURE_BATTERY_HEADER1=$LIVEDATA_SOILMOISTURE_HEADER1

LIVEDATA_SOILTEMP_HEADER1="Jordtemperatur 1"

LIVEDATA_LEAK_HEADER1="Lekkasje vaskemaskin"
LIVEDATA_LEAK_YES="JA "
 LIVEDATA_LEAK_NO="NEI"

LIVEDATA_LIGHTNING_DISTANCE_HEADER="Lyn avstand (siste)"
LIVEDATA_LIGHTNING_POWER_HEADER="Lyn antall idag"
LIVEDATA_LIGHTNING_TIME_UTC_HEADER="Lyn tidspunkt utc (siste)"

LIVEDATA_WH45CO2_TEMPF_HEADER="Temperatur (CO2 sensor)"
LIVEDATA_WH45CO2_HUMI_HEADER="Fuktighet (CO2 sensor)"
LIVEDATA_WH45CO2_PM10_HEADER="PM10"
LIVEDATA_WH45CO2_PM10_24HAVG_HEADER="PM10 24t"
LIVEDATA_WH45CO2_PM25_HEADER="PM25"
LIVEDATA_WH45CO2_PM25_24HAVG_HEADER="PM25 24t"
LIVEDATA_WH45CO2_CO2_HEADER="CO2"
LIVEDATA_WH45CO2_CO2_24HAVG_HEADER="CO2 24t"

LIVEDATA_WH45CO2_BATTERY_HEADER="CO2 batteri"

LIVEDATA_PM25_24HAVG_HEADER1="PM2.5 24t Sykkelbod"
LIVEDATA_PM25_HEADER1="PM2.5 Sykkelbod"
LIVEDATA_PM25_BATTERY_HEADER1=$LIVEDATA_PM25_HEADER1

LIVEDATA_SYSTEM_HOST="System vert"
LIVEDATA_SYSTEM_VERSION_HEADER="System versjon"
LIVEDATA_SYSTEM_UTC_HEADER="System utc"
LIVEDATA_SYSTEM_FREQUENCY_HEADER="System frekvens"
LIVEDATA_SYSTEM_SENSORTYPE_HEADER="System type"
LIVEDATA_SYSTEM_PROTOCOL_HEADER="System protokoll"
LIVEDATA_SYSTEM_TIMEZONE_HEADER="System tidssone (manuell)"
LIVEDATA_SYSTEM_TIMEZONE_AUTO_HEADER="System tidssone AUTO"
LIVEDATA_SYSTEM_TIMEZONE_DST_HEADER="System tidssone DST"

LIVEDATA_SYSTEM_SENSOR_CONNECTED_HEADER="System sensorer tilkoblet"
LIVEDATA_SYSTEM_SENSOR_DISCONNECTED_HEADER="System sensorer frakoblet"
LIVEDATA_SYSTEM_SENSOR_SEARCHING_HEADER="System sensorer søker"
LIVEDATA_SYSTEM_SENSOR_DISABLED_HEADER="System sensorer deaktivert"

LIVEDATA_SOILMOISTURE_HEADER="ＪＯＲＤＦＵＫＴＩＧＨＥＴ"
LIVEDATA_SOILTEMP_HEADER="ＪＯＲＤＴＥＭＰＥＲＡＴＵＲ"
LIVEDATA_PM25_HEADER="ＰＭ ２.５ ＬＵＦＴＫＶＡＬＩＴＥＴ"
LIVEDATA_LEAFWETNESS_HEADER="ＢＬＡＤＦＵＫＴＩＧＨＥＴ"
LIVEDATA_TEMPUSR_HEADER="ＴＥＭＰＵＳＲ"
LIVEDATA_WH45CO2_HEADER="ＣＯ２"
LIVEDATA_LIGHTNING_HEADER="ＬＹＮ"
LIVEDATA_LEAK_HEADER="ＬＥＫＫＡＳＥＪＥ"
LIVEDATA_RAIN_HEADER="ＲＥＧＮ"
LIVEDATA_SOLAR_UV_HEADER="ＳＯＬ"
LIVEDATA_WIND_HEADER="ＶＩＮＤ"
LIVEDATA_PRESSURE_HEADER="ＴＲＹＫＫ"
LIVEDATA_TEMP_HEADER="ＴＥＭＰＥＲＡＴＵＲ"
LIVEDATA_TEMPERATURE_HEADER="ＴＥＭＰＥＲＡＴＵＲ"
LIVEDATA_SYSTEM_HEADER="ＳＹＳＴＥＭ"

UNIT_HOUR="t"

WIND_DIRECTION_E=Ø
WIND_DIRECTION_W=V

     UV_RISK_LOW="LAV       "
UV_RISK_MODERATE="MODERAT   "
    UV_RISK_HIGH="HØY       "
UV_RISK_VERYHIGH="VELDIG HØY"
 UV_RISK_EXTREME="EKSTREM   "

              PM25_AQI_GOOD="GOD         "
          PM25_AQI_MODERATE="MODERAT     "
PM25_AQI_UNHEALTHY_SENSITIVE="USUNN S.    "
          PM25_AQI_UNHEALTHY="USUNN       "
     PM25_AQI_VERY_UNHEALTHY="VELDIG USUNN"
         PM25_AQI_HAZARDOUS="FARLIG      "

   RAININTENSITY_LIGHT="LETT"
RAININTENSITY_MODERATE="MODERAT"
   RAININTENSITY_HEAVY="MYE"
 RAININTENSITY_EXTREME="EKSTREMT"

 BEUFORT_0_DESCRIPTION="STILLE"
 BEUFORT_1_DESCRIPTION="FLAU VIND"
 BEUFORT_2_DESCRIPTION="SVAK VIND"
 BEUFORT_3_DESCRIPTION="LETT BRIS"
 BEUFORT_4_DESCRIPTION="LABER BRIS"
 BEUFORT_5_DESCRIPTION="FRISK BRIS"
 BEUFORT_6_DESCRIPTION="LITEN KULING"
 BEUFORT_7_DESCRIPTION="STIV KULING"
 BEUFORT_8_DESCRIPTION="STERK KULING"
 BEUFORT_9_DESCRIPTION="LITEN STORM"
BEUFORT_10_DESCRIPTION="FULL STORM"
BEUFORT_11_DESCRIPTION="STERK STORM"
BEUFORT_12_DESCRIPTION="ORKAN"

SENSORIDSTATE_CONNECTED="tilkoblet"
SENSORIDSTATE_DISCONNECTED="frakoblet"
SENSORIDSTATE_SEARCHING="søker"
SENSORIDSTATE_DISABLED="deaktivert"
SENSORID_HEADER="Sensor ID B S Type Navn Tilstand Batteri Signal"
