#!/bin/sh
#shellcheck disable=SC2034
LIVEDATAHEADER_INTEMP="Innendørs temperatur"
LIVEDATAHEADER_PRESSURE_ABSBARO="Absolutt trykk"
LIVEDATAHEADER_PRESSURE_RELBARO="Relativt trykk"
LIVEDATAHEADER_OUTTEMP="Utendørs temperatur"
LIVEDATAHEADER_INHUMI="Innendørs fuktighet"
LIVEDATAHEADER_OUTHUMI="Utendørs fuktighet"
LIVEDATAHEADER_WINDCHILL="Følt temperatur"
LIVEDATAHEADER_DEWPOINT="Duggpunkt temperaratur"

LIVEDATAHEADER_WINDDAILYMAX="Vind idag maks."
LIVEDATAHEADER_WINDDIRECTION="Vind retning"
LIVEDATAHEADER_WINDDIRECTION_COMPASS="Vind kompass retning"
LIVEDATAHEADER_WINDGUSTSPEED="Vindkast"
LIVEDATAHEADER_WINDSPEED="Vind hastighet"
LIVEDATAHEADER_SOLAR_LIGHT="Solstråling"
LIVEDATAHEADER_SOLAR_UV="Sol UV stråling"
LIVEDATAHEADER_SOLAR_UVI="Sol UV Indeks"

LIVEDATAHEADER_RAINRATE="Regn intensitet"
LIVEDATAHEADER_RAINEVENT="Regn hendelse"
LIVEDATAHEADER_RAINHOUR="Regn time"
LIVEDATAHEADER_RAINDAY="Regn idag"
LIVEDATAHEADER_RAINWEEK="Regn uke"
LIVEDATAHEADER_RAINMONTH="Regn måned"
LIVEDATAHEADER_RAINYEAR="Regn år"

LIVEDATAHEADER_TEMP1="Temperatur 1 Soverom"
LIVEDATAHEADER_TEMP2="Temperatur 2 Bad"
LIVEDATAHEADER_TEMP3="Temperatur 3 Vaskerom"
LIVEDATAHEADER_TEMP4="Temperatur 4"
LIVEDATAHEADER_TEMP5="Temperatur 5"
LIVEDATAHEADER_TEMP6="Temperatur 6"
LIVEDATAHEADER_TEMP7="Temperatur 7"
LIVEDATAHEADER_TEMP8="Temperatur 8"

LIVEDATAHEADER_TEMP_BATTERY1=$LIVEDATAHEADER_TEMP1
LIVEDATAHEADER_TEMP_BATTERY2=$LIVEDATAHEADER_TEMP2
LIVEDATAHEADER_TEMP_BATTERY3=$LIVEDATAHEADER_TEMP3

LIVEDATAHEADER_LEAK_BATTERY1="Lekkasje 1/oppvaskmaskin"

LIVEDATAHEADER__BATTERY='WH65 Værstasjon'
LIVEDATAHEADER_RAINFALL_BATTERY='Regnfall batteri'

LIVEDATAHEADER_HUMIDITY1="Fuktighet Soverom"
LIVEDATAHEADER_HUMIDITY2="Fuktighet Bad"
LIVEDATAHEADER_HUMIDITY3="Fuktighet Vaskerom"

LIVEDATAHEADER_SOILMOISTURE1="Julestjerne 🪴"
LIVEDATAHEADER_SOILMOISTURE_BATTERY1=$LIVEDATAHEADER_SOILMOISTURE1

LIVEDATAHEADER_SOILTEMP1="Jordtemperatur 1"

LIVEDATAHEADER_LEAK1="Lekkasje vaskemaskin"
LIVEDATAHEADER_LEAK_YES="JA "
 LIVEDATAHEADER_LEAK_NO="NEI"

LIVEDATAHEADER_LIGHTNING_DISTANCE="Lyn avstand (siste)"
LIVEDATAHEADER_LIGHTNING_POWER="Lyn antall idag"
LIVEDATAHEADER_LIGHTNING_TIME_UTC="Lyn tidspunkt utc (siste)"

LIVEDATAHEADER_CO2_TEMPF="Temperatur (CO2 sensor)"
LIVEDATAHEADER_CO2_HUMI="Fuktighet (CO2 sensor)"
LIVEDATAHEADER_CO2_PM10="PM10"
LIVEDATAHEADER_CO2_PM10_24HAVG="PM10 24t"
LIVEDATAHEADER_CO2_PM25="PM25"
LIVEDATAHEADER_CO2_PM25_24HAVG="PM25 24t"
LIVEDATAHEADER_CO2_CO2="CO2"
LIVEDATAHEADER_CO2_CO2_24HAVG="CO2 24t"

LIVEDATAHEADER_CO2_BATTERY="CO2 batteri"

LIVEDATAHEADER_PM251_24HAVG="PM2.5 24t Sykkelbod"
LIVEDATAHEADER_PM251="PM2.5 Sykkelbod"

LIVEDATA_SYSTEM_HOST="System vert"
LIVEDATAHEADER_SYSTEM_VERSION="System versjon"
LIVEDATAHEADER_SYSTEM_UTC="System utc"
LIVEDATAHEADER_SYSTEM_FREQUENCY="System frekvens"
LIVEDATAHEADER_SYSTEM_SENSORTYPE="System type"
LIVEDATAHEADER_SYSTEM_PROTOCOL="System protokoll"
LIVEDATAHEADER_SYSTEM_TIMEZONE="System tidssone (manuell)"
LIVEDATAHEADER_SYSTEM_TIMEZONE_AUTO="System tidssone AUTO"
LIVEDATAHEADER_SYSTEM_TIMEZONE_DST="System tidssone DST"

LIVEDATAHEADER_SYSTEM_SENSOR_CONNECTED="System sensorer tilkoblet"
LIVEDATAHEADER_SYSTEM_SENSOR_DISCONNECTED="System sensorer frakoblet"
LIVEDATAHEADER_SYSTEM_SENSOR_SEARCHING="System sensorer søker"
LIVEDATAHEADER_SYSTEM_SENSOR_DISABLED="System sensorer deaktivert"

LIVEDATAGROUPHEADER_SOILMOISTURE="ＪＯＲＤＦＵＫＴＩＧＨＥＴ"
LIVEDATAGROUPHEADER_SOILTEMP="ＪＯＲＤＴＥＭＰＥＲＡＴＵＲ"
LIVEDATAGROUPHEADER_PM25="ＰＭ ２.５ ＬＵＦＴＫＶＡＬＩＴＥＴ"
LIVEDATAGROUPHEADER_LEAFWETNESS="ＢＬＡＤＦＵＫＴＩＧＨＥＴ"
LIVEDATAGROUPHEADER_TEMPUSR="ＴＥＭＰＵＳＲ"
LIVEDATAGROUPHEADER_CO2="ＣＯ２"
LIVEDATAGROUPHEADER_LIGHTNING="ＬＹＮ"
LIVEDATAGROUPHEADER_LEAK="ＬＥＫＫＡＳＪＥ"
LIVEDATAGROUPHEADER_RAIN="ＲＥＧＮ"
LIVEDATAGROUPHEADER_SOLAR="ＳＯＬ"
LIVEDATAGROUPHEADER_WIND="ＶＩＮＤ"
LIVEDATAGROUPHEADER_PRESSURE="ＴＲＹＫＫ"
LIVEDATAGROUPHEADER_TEMPERATURE="ＴＥＭＰＥＲＡＴＵＲ"
LIVEDATAGROUPHEADER_SYSTEM="ＳＹＳＴＥＭ"

UNIT_HOUR="t"

WIND_DIRECTION_E=Ø
WIND_DIRECTION_W=V

     UV_RISK_LOW="LAV"
UV_RISK_MODERATE="MODERAT"
    UV_RISK_HIGH="HØY"
UV_RISK_VERYHIGH="VELDIG HØY"
 UV_RISK_EXTREME="EKSTREM"

              PM25_AQI_GOOD="GOD"
          PM25_AQI_MODERATE="MODERAT"
PM25_AQI_UNHEALTHY_SENSITIVE="USUNN S."
          PM25_AQI_UNHEALTHY="USUNN"
     PM25_AQI_VERY_UNHEALTHY="VELDIG USUNN"
         PM25_AQI_HAZARDOUS="FARLIG"

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
