#!/bin/sh
#livedata field number from specification
#shellcheck disable=SC2034
{
LDF_INTEMP=$((0x01))        #Indoor Temperature (℃) 2
LDF_OUTTEMP=$((0x02))       #Outdoor Temperature (℃) 2
LDF_DEWPOINT=$((0x03))      #Dew point (℃) 2
LDF_WINDCHILL=$((0x04))     #Wind chill (℃) 2
LDF_HEATINDEX=$((0x05))     #Heat index (℃) 2
LDF_INHUMI=$((0x06))        #Indoor Humidity (%) 1
LDF_OUTHUMI=$((0x07))       #Outdoor Humidity (%) 1
LDF_PRESSURE_ABSBARO=$((0x08))       #Absolutely Barometric (hpa) 2
LDF_PRESSURE_RELBARO=$((0x09))       #Relative Barometric (hpa) 2
LDF_WINDDIRECTION=$((0x0A)) #Wind Direction (360°) 2
LDF_WINDSPEED=$((0x0B))     #Wind Speed (m/s) 2
LDF_WINDGUSTSPPED=$((0x0C)) #Gust Speed (m/s) 2
LDF_RAINEVENT=$((0x0D))     #Rain Event (mm) 2
LDF_RAINRATE=$((0x0E))      #Rain Rate (mm/h) 2
LDF_RAINHOUR=$((0x0F))      #Rain hour (mm) 2
LDF_RAINDAY=$((0x10))       #Rain Day (mm) 2
LDF_RAINWEEK=$((0x11))      #Rain Week (mm) 2
LDF_RAINMONTH=$((0x12))     #Rain Month (mm) 4
LDF_RAINYEAR=$((0x13))      #Rain Year (mm) 4
LDF_RAINTOTALS=$((0x14))    #Rain Totals (mm) 4
LDF_LIGHT=$((0x15))         #Light (lux) 4
LDF_UV=$((0x16))            #UV (uW/m2) 2
LDF_UVI=$((0x17))           #UVI (0-15 index) 1
LDF_TIME=$((0x18))          #Date and time 6
LDF_DAYLWINDMAX=$((0X19))   #Day max wind(m/s) 2

    LDF_TEMP1=$((0x1A)) #Temperature 1(℃) 2
    LDF_TEMP2=$((0x1B)) #Temperature 2(℃) 2
    LDF_TEMP3=$((0x1C)) #Temperature 3(℃) 2
    LDF_TEMP4=$((0x1D)) #Temperature 4(℃) 2
    LDF_TEMP5=$((0x1E)) #Temperature 5(℃) 2
    LDF_TEMP6=$((0x1F)) #Temperature 6(℃) 2
    LDF_TEMP7=$((0x20)) #Temperature 7(℃) 2
    LDF_TEMP8=$((0x21)) #Temperature 8(℃) 2
    LDF_HUMI1=$((0x22)) #Humidity 1, 0-100% 1
    LDF_HUMI2=$((0x23)) #Humidity 2, 0-100% 1
    LDF_HUMI3=$((0x24)) #Humidity 3, 0-100% 1
    LDF_HUMI4=$((0x25)) #Humidity 4, 0-100% 1
    LDF_HUMI5=$((0x26)) #Humidity 5, 0-100% 1
    LDF_HUMI6=$((0x27)) #Humidity 6, 0-100% 1
    LDF_HUMI7=$((0x28)) #Humidity 7, 0-100% 1
    LDF_HUMI8=$((0x29)) #Humidity 8, 0-100% 1
LDF_PM25_CH1=$((0x2A))      #PM2.5 Air Quality Sensor(μg/m3) 2
LDF_SOILTEMP1=$((0x2B))     #Soil Temperature(℃) 2
LDF_SOILMOISTURE1=$((0x2C)) #Soil Moisture(%) 1
LDF_SOILTEMP2=$((0x2D))     #Soil Temperature(℃) 2
LDF_SOILMOISTURE2=$((0x2E)) #Soil Moisture(%) 1
LDF_SOILTEMP3=$((0x2F))     #Soil Temperature(℃) 2
LDF_SOILMOISTURE3=$((0x30)) #Soil Moisture(%) 1
LDF_SOILTEMP4=$((0x31))     #Soil Temperature(℃) 2
LDF_SOILMOISTURE4=$((0x32)) #Soil Moisture(%) 1
LDF_SOILTEMP5=$((0x33))     #Soil Temperature(℃) 2
LDF_SOILMOISTURE5=$((0x34)) #Soil Moisture(%) 1
LDF_SOILTEMP6=$((0x35))     #Soil Temperature(℃) 2
LDF_SOILMOISTURE6=$((0x36)) #Soil Moisture(%) 1
LDF_SOILTEMP7=$((0x37))     #Soil Temperature(℃) 2
LDF_SOILMOISTURE7=$((0x38)) #Soil Moisture(%) 1
LDF_SOILTEMP8=$((0x39))     #Soil Temperature(℃) 2
LDF_SOILMOISTURE8=$((0x3A)) #Soil Moisture(%) 1
LDF_LOWBATT=$((0x4C))       #All sensor lowbatt 16 char 16
LDF_PM25_24HAVG1=$((0x4D))  # pm25_ch1 2
LDF_PM25_24HAVG2=$((0x4E)) # pm25_ch2 2
LDF_PM25_24HAVG3=$((0x4F)) # pm25_ch3 2
LDF_PM25_24HAVG4=$((0x50)) # pm25_ch4 2
LDF_PM25_CH2=$((0x51))     #PM2.5 Air Quality Sensor(μg/m3) 2
LDF_PM25_CH3=$((0x52)) #PM2.5 Air Quality Sensor(μg/m3) 2
LDF_PM25_CH4=$((0x53)) #PM2.5 Air Quality Sensor(μg/m3) 2
LDF_LEAK_CH1=$((0x58)) # Leak_ch1 1
LDF_LEAK_CH2=$((0x59)) # Leak_ch2 1
LDF_LEAK_CH3=$((0x5A))        # Leak_ch3 1
LDF_LEAK_CH4=$((0x5B))        # Leak_ch4 1
LDF_LIGHTNING=$((0x60))       # lightning distance （1~40KM） 1
LDF_LIGHTNING_TIME=$((0x61))  # lightning happened time(UTC) 4
LDF_LIGHTNING_POWER=$((0x62)) # lightning counter for the ay 4
    LDF_TF_USR1=$((0x63)) #Temperature(℃) 4
    LDF_TF_USR2=$((0x64)) #Temperature(℃) 4
    LDF_TF_USR3=$((0x65)) #Temperature(℃) 4
    LDF_TF_USR4=$((0x66)) #Temperature(℃) 4
    LDF_TF_USR5=$((0x67)) #Temperature(℃) 4
    LDF_TF_USR6=$((0x68)) #Temperature(℃) 4
    LDF_TF_USR7=$((0x69)) #Temperature(℃) 4
    LDF_TF_USR8=$((0x6A)) #Temperature(℃) 4
LDF_SENSOR_CO2=$((0x70)) #16
#shellcheck disable=SC2034
LDF_PM25_AQI=$((0x71))   #only for amb
# LDF_PM25_AQI length(n*2)(1byte) 1-aqi_pm25 2-aqi_pm25_24h ... ... n-aqi
#aqi_pm25 AQI derived from PM25 int
#aqi_pm25_24h AQI derived from PM25, 24 hour running average int
#aqi_pm25_in AQI derived from PM25 IN int
#aqi_pm25_in_24h AQI derived from PM25 IN, 24 hour running average int
#aqi_pm25_aqin AQI derived from PM25, AQIN sensor int
#aqi_pm25_24h_aqin AQI derived from PM25, 24 hour running average, AQIN sensor int
#.... n
    LDF_LEAF_WETNESS_CH1=$((0x72)) # 1
    LDF_LEAF_WETNESS_CH2=$((0x73)) # 1
    LDF_LEAF_WETNESS_CH3=$((0x74)) # 1
    LDF_LEAF_WETNESS_CH4=$((0x75)) # 1
    LDF_LEAF_WETNESS_CH5=$((0x76)) # 1
    LDF_LEAF_WETNESS_CH6=$((0x77)) # 1
    LDF_LEAF_WETNESS_CH7=$((0x78)) # 1
    LDF_LEAF_WETNESS_CH8=$((0x79)) # 1
}