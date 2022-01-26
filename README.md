gw is a shell tool for viewing realtime data and sensor configuration of the gw-1000 or compatible devices. It designed to be as portable as possible and have been tested on bash,zsh,ksh93,mksh and dash. It also supports subnet scanning for devices ip/mac/ssid.

It operates in two modes: 

    1. client -nc/od utilities generate a string buffer which is parsed
    2. server

Examples:

Viewing livedata:

./gw -g 192.168.3.16 -c livedata

ＴＥＭＰＥＲＡＴＵＲＥ

 Indoor temperature                21.6 ℃
 Outdoor temperature               -4.0 ℃
 Indoor humidity                     29 %
 Outdoor humidity                    79 %

ＰＲＥＳＳＵＲＥ

 Relative pressure                995.5 hPa
 Absolute pressure                995.5 hPa

ＷＩＮＤ

 Wind                               0.7 m/s     ╭─N─╮
 Wind gust - 1 LIGHT AIR            1.0 m/s     W ↖ E
 Wind direction - ESE               114 °       ╰─S─╯
 Wind max. - 4 MODERATE BREEZE      5.6 m/s

ＳＯＬＡＲ

 Light                           1255.0 ㏓
 Solar UV radiation                 9.9 W/㎡
 Solar UV index - LOW                 0

ＳＯＩＬＭＯＩＳＴＵＲＥ

 Soilmoisture 1                      58 %       🔋📶

ＰＭ２.５ ＡＩＲ ＱＵＡＬＩＴＹ

 PM 2.5 1 - GOOD                    3.0 µg/㎥   🔌📶
 PM 2.5 24h avg. 1 - GOOD           3.0 µg/㎥

ＳＹＳＴＥＭ

System version                   GW1000A_V1.6.8
System utc                       2022-01-26 12:07:53
System frequency                 868
System type                      WH65   🔋📶
System sensors connected          7
System sensors disconnected       0
System sensors searching         29
System sensors disabled          11

Hide headers, rain and temperature sensors

./gw -g 192.168.3.16 -H headers,rain,temp -c livedata

Listen for incoming http Ecowitt/Wunderground request on port 8080

./gw -l 8080

Viewing sensor configuration

./gw -g 192.168.3.16 -c sensor

Sensor        ID   B S Type Name              State             Battery Signal
───────────────────────────────────────────────────────────────────────────────
     0        f1   0 4 WH65 Weather Station   connected         🔋      📶 100%
     1  ffffffff 255 0 WH68 Weather Station   searching
     2  ffffffff 255 0 WH80 Weather Station   searching
     3  ffffffff  31 0 WH40 Rainfall          searching
     5  ffffffff   0 0 WH32 Temperatue out    searching
     6        ba   0 4 WH31 Temperature1      connected         🔋      📶 100%
     7        db   0 4 WH31 Temperature2      connected         🔋      📶 100%
     8        6e   0 4 WH31 Temperature3      connected         🔋      📶 100%
     9  ffffffff   0 0 WH31 Temperature4      searching
    10  ffffffff   0 0 WH31 Temperature5      searching
    11  ffffffff   0 0 WH31 Temperature6      searching
    12  ffffffff   0 0 WH31 Temperature7      searching
    13  ffffffff   0 0 WH31 Temperature8      searching
    14    40c6e3  13 4 WH51 Soilmoisture1     connected         🔋 1.3V 📶 100%
    15  ffffffff  31 0 WH51 Soilmoisture2     searching
    16  ffffffff  31 0 WH51 Soilmoisture3     searching
    17  ffffffff  31 0 WH51 Soilmoisture4     searching
    18  ffffffff  31 0 WH51 Soilmoisture5     searching
    19  ffffffff  31 0 WH51 Soilmoisture6     searching
    20  ffffffff  31 0 WH51 Soilmoisture7     searching
    21  ffffffff  31 0 WH51 Soilmoisture8     searching
    22      c51f   6 4 WH43 PM2.5 AQ 1        connected         🔌      📶 100%
    23  fffffffe  15 0 WH43 PM2.5 AQ 2        disabled
    24  fffffffe  15 0 WH43 PM2.5 AQ 3        disabled
    25  fffffffe  15 0 WH43 PM2.5 AQ 4        disabled
    26  ffffffff  15 0 WH57 Lightning         searching
    27      e41a   4 4 WH55 Leak1             connected         🔋 4    📶 100%
    28  ffffffff  15 0 WH55 Leak2             searching
    29  ffffffff  15 0 WH55 Leak3             searching
    30  ffffffff  15 0 WH55 Leak4             searching
    31  ffffffff 255 0 WH34 Soiltemperature1  searching
    32  ffffffff 255 0 WH34 Soiltemperature2  searching
    33  ffffffff 255 0 WH34 Soiltemperature3  searching
    34  ffffffff 255 0 WH34 Soiltemperature4  searching
    35  ffffffff 255 0 WH34 Soiltemperature5  searching
    36  ffffffff 255 0 WH34 Soiltemperature6  searching
    37  ffffffff 255 0 WH34 Soiltemperature7  searching
    38  ffffffff 255 0 WH34 Soiltemperature8  searching
    39  ffffffff  15 0 WH45 CO2 PM2.5 PM10 AQ searching
    40  ffffffff 255 0 WH35 Leafwetness1      searching
    41  ffffffff 255 0 WH35 Leafwetness2      searching
    42  ffffffff 255 0 WH35 Leafwetness3      searching
    43  ffffffff 255 0 WH35 Leafwetness4      searching
    44  ffffffff 255 0 WH35 Leafwetness5      searching
    45  ffffffff 255 0 WH35 Leafwetness6      searching
    46  ffffffff 255 0 WH35 Leafwetness7      searching
    47  ffffffff 255 0 WH35 Leafwetness8      searching

    # Setting all leafwetness sensors to disabled and disable temperature sensor 6, next reset temp sensor 6 to id 'ba'.
    The signal will increase to 100% if 4 packets are received during 4 periods.

    ```
    ./gw -g 192.168.3.16 -c s 40-47=d,40-47,6=d,6=ba,6
    ```

    
Sensor        ID   B S Type Name              State             Battery Signal
───────────────────────────────────────────────────────────────────────────────
    40  fffffffe 255 0 WH35 Leafwetness1      disabled
    41  fffffffe 255 0 WH35 Leafwetness2      disabled
    42  fffffffe 255 0 WH35 Leafwetness3      disabled
    43  fffffffe 255 0 WH35 Leafwetness4      disabled
    44  fffffffe 255 0 WH35 Leafwetness5      disabled
    45  fffffffe 255 0 WH35 Leafwetness6      disabled
    46  fffffffe 255 0 WH35 Leafwetness7      disabled
    47  fffffffe 255 0 WH35 Leafwetness8      disabled
     6        ba   0 0 WH31 Temperature1      disconnected      🔋      🛑
