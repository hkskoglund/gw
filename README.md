# gw - shell tool for viewing weather data and sensor configuration of gw-1000 or compatible devices

This tool will gather data from gw-1000 and present it in tabular form. The tabular layout with headers is the default. All sensors transmitting data are displayed unless hidden. It is possible to extend the script by creating a new view for your particular purpose. It also features a sensor configuration view which list all status of the sensors like ***searching***, ***disabled*** or which sensortype (***hex***) is connected to the gw. Detailed battery stauts is also included in the sensorview. It designed to be very **portable** and tested on bash, zsh, ksh93, mksh and **dash**. The script is dependent on the external nc and od utilities. It will try to detect which version of nc (nc bsd/nmap, toybox, busybox) is available and tailor command options accoringly in [initnc](https://github.com/hkskoglund/gw/blob/f04f02748469b1f8ac9096d7ccc48fe2048a64b3/gw#L4334). The basic overall operation of the script for sending a command to gw is ["printf %b "$octalBuffer" | nc -4 $gwip $gwport | od"](https://github.com/hkskoglund/gw/blob/f04f02748469b1f8ac9096d7ccc48fe2048a64b3/gw#L3703-L3704) then parsing is done in [parsePacket](https://github.com/hkskoglund/gw/blob/f04f02748469b1f8ac9096d7ccc48fe2048a64b3/gw#L3399). The implementation is based on the [Ecowitt binary protocol specification](https://osswww.ecowitt.net/uploads/20210716/WN1900%20GW1000,1100%20WH2680,2650%20telenet%20v1.6.0%20.pdf). 

## Examples

### Viewing livedata

```./gw -g 192.168.3.16 -c livedata```

<pre>
ＴＥＭＰＥＲＡＴＵＲＥ

 Indoor temperature                21.6 ℃
 Outdoor temperature               -4.0 ℃
 Indoor humidity                     29 %
 Outdoor humidity                    79 %

ＰＲＥＳＳＵＲＥ

 Relative pressure                995.5 hPa
 Absolute pressure                995.5 hPa

ＷＩＮＤ

 Wind                               0.7 m/s     ╭─<span style="color:red">N</span>─╮
 Wind gust - 1 LIGHT AIR            1.0 m/s     W ↖ E
 Wind direction - ESE               114 °       ╰─S─╯
 Wind max. - 4 MODERATE BREEZE      <span style="background-color:cyan; color: black">5.6 m/s</span>

ＳＯＬＡＲ

 Light                           1255.0 ㏓
 Solar UV radiation                 9.9 W/㎡
 Solar UV index - LOW                 0

ＳＯＩＬＭＯＩＳＴＵＲＥ

 Soilmoisture 1                      58 %       🔋📶

ＰＭ２.５ ＡＩＲ ＱＵＡＬＩＴＹ

 PM 2.5 1 - GOOD                    <span style="background-color:green; color: black">3.0 µg/㎥</span>   🔌📶
 PM 2.5 24h avg. 1 - GOOD           <span style="background-color:green; color: black">3.0 µg/㎥</span>

ＳＹＳＴＥＭ

System version                   GW1000A_V1.6.8
System utc                       2022-01-26 12:07:53
System frequency                 868
System type                      WH65   🔋📶
System sensors connected          7
System sensors disconnected       0
System sensors searching         29
System sensors disabled          11
</pre>

#### Status line indicators
1. 🔋 - battery ok
2. 📶 - signal ok
3. 🔌 - plug/electric power

### Continous monitoring each 1 minute -H option to hide
<code> while true; do clear;./gw -g 192.168.3.16 -H rain,system,t,leak  -c l; sleep 60; done</code>

### Listen for incoming http Ecowitt/Wunderground request on port 8080

<code>./gw -l 8080</code>

### Viewing sensor configuration

<code>./gw -g 192.168.3.16 -c sensor</code>
<pre>
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
</pre>

### Setting all leafwetness sensors to disabled and disable temperature sensor 6, next reset temp sensor 6 to id 'ba'.

The signal will increase to 100% if 4 packets are received during 4 consequtive periods.

<code>./gw -g 192.168.3.16 -c s 40-47=d,40-47,6=d,6=ba,6</code>

<pre>    
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
</pre>

### Subnet scanning for devices on LAN

<code>./gw -s 192.168.3</code>
<pre>
192.168.3.14 8c:aa:b5:c7:24:b1 192.168.3.14 45000 EasyWeather-WIFI24B1 V1.6.1
192.168.3.16 48:3f:da:54:14:ec 192.168.3.16 45000 GW1000A-WIFI14EC V1.6.8
192.168.3.26 48:3f:da:55:4d:a9 192.168.3.26 45000 GW1000A-WIFI4DA9 V1.6.8
192.168.3.32 ^C
</pre>

### Viewing customized server settings

<code>./gw -g 192.168.3.16 -c customized</code>
<pre>
id
password
server             192.168.3.3
port               8080
interval           16
protocol           0 ecowitt
enabled            1 on
path ecowitt       /weatherstation/updateweatherstation.php?
path wunderground  /data/report/
</pre>

### Changing server,port,protocol,enabled
<code>./gw -g 192.168.3.16 -c customized server=192.168.3.4,port=8082,protocol=wunderground,enabled=on -c customized</code>
<pre>
id
password
server             192.168.3.4
port               8082
interval           16
protocol           1 wunderground
enabled            1 on
path ecowitt       /weatherstation/updateweatherstation.php?
path wunderground  /data/report/
</pre>

### Configuring new wifi ssid/pw - method 1 - server
<p>Connect to GW1000-WIFI???? network in your preferred os. Verify ip address of gw. Verify firewall settings for tcp port 49123</p> 
<code>./gw -g 192.168.4.1 -c wifi-server ssid pw</code>
<br>

### Configuring new wifi ssid/pw - method 2 - client
<code>./gw -g 192.168.4.1 -c wifi-client ssid pw</code>

### Reset device
<code>./gw -g 192.168.3.15 -c reset</code>
Press capital Y to reset, settings are destroyed, be careful.
<pre>Reset 48:3f:da:54:14:ec GW1000A-WIFI14EC (Y/N)?</pre>

### Unit conversion

## Background
I initially started to program the tool in javascript/nodejs which would have been easier due to standard libraries for arrays,readUInt and http parsing, but decided to test if its possible to do it in the shell/terminal using the standard unix nc/ncat and od utilities. For arrays I am creating them dynamically by using eval. readUint-functions are included in the script, as well as http parsing for Ecowitt and Wunderground protocol requests.

## Styling

Terminal ansi escape codes is used to style solar,pm25, rain and wind data. Styling can be customized in [ansiesc.sh](./style/ansiesc.sh), [style-beufort.sh](./style/style-beufort.sh)

### Wind: Beufort
0. <span                             style="color:white;white-space:pre;width:150px">CALM&nbsp;           </span>
1. <span                   style="background-color:Blue;white-space:pre;width:150px">LIGHT AIR&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
2. <span              style="background-color:RoyalBlue;white-space:pre;width:150px">LIGHT BREEZE   </span>
3. <span         style="background-color:CornflowerBlue;white-space:pre;width:150px">GENTLE BREEZE  </span>
4. <span style="background-color:DodgerBlue;color:Black;white-space:pre;width:150px">MODERATE BREEZE</span>
5. <span               style="background-color:SeaGreen;white-space:pre;width:150px">FRESH BREEZE   </span>
6. <span  style="background-color:PaleGreen;color:Black;white-space:pre;width:150px">STRONG BREEZE  </span>
7. <span       style="background-color:Gold;color:Black;white-space:pre;width:150px">NEAR GALE      </span>
8. <span     style="background-color:Yellow;color:Black;white-space:pre;width:150px">GALE           </span>
9. <span                    style="background-color:Red;white-space:pre;width:150px">STRONG GALE    </span>
10. <span             style="background-color:DarkSalmon;white-space:pre;width:150px">STORM          </span>
11. <span               style="background-color:DeepPink;white-space:pre;width:150px">VIOLENT STORM  </span>
12. <span    style="background-color:HotPink;Color:Black;white-space:pre;width:150px">HURRICANE      </span>

### Air quality: pm 2.5

## Screenshots
### Default liveview
![Screenshot Liveview with headings - Windows Terminal v1.11.3471.0](./img/Skjermbilde%202022-01-26%20144206.png)
### Liveview without headings (-H headers option)
![Screenshot Liveview with headings - Windows Terminal v1.11.3471.0](./img/Skjermbilde%202022-01-26%20162949.jpg)


<!---
https://www.markdownguide.org/basic-syntax/
https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes
https://htmlcolorcodes.com/color-names/
-->


