# gw - shell script for viewing weather data and sensors connected to gw-1000 or compatible devices

This tool reads weather data from gw-1000 and shows it in a table. It supports both the binary Ecowitt protocol and http requests. It may be used to configure some of the settings on the device for example a customized server. The sensor view lists current battery, signal status and state (searching/disabled/hexid) to all sensors. Setting a new sensor state, for example from searching to disabled is supported. It designed with *portability* in mind and tested on bash, zsh, ksh93, mksh and **dash**. Ansi escape codes are used to style wind, uv index, and pm25 air quality index. The script is dependent on the external **nc** and  **od** utilities.

# Screenshot Windows Terminal/WSL 2
![Screenshot Liveview with headings - Windows Terminal v1.11.3471.0 - WSL2](./img/Skjermbilde%202022-01-26%20144206.png)
### Status line indicators
1. 🔋 - battery ok
2. 📶 - signal ok
3. 🔌 - plug/electric power
4. ↖ - wind direction
5. 💧 - rain

# Examples

## Viewing livedata

<code>./gw -g 192.168.3.16 -c livedata</code>

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
System sensors disconnected       <span style="color:magenta">0</span>
System sensors searching         <span style="color:green">29</span>
System sensors disabled          <span style="color: red">11</span>
</pre>

## Continous monitoring each 1 minute -H option to hide
<code> while true; do clear;./gw -g 192.168.3.16 -H rain,system,t,leak  -c l; sleep 60; done</code>

## Listen for incoming http Ecowitt/Wunderground request on port 8080

<code>./gw -l 8080</code>

## Viewing sensor configuration

<code>./gw -g 192.168.3.16 -c sensor</code>
<pre>
Sensor        ID   B S Type Name              State             Battery Signal
───────────────────────────────────────────────────────────────────────────────
     0        f1   0 4 WH65 Weather Station   connected         🔋      📶 100%
     1  ffffffff 255 0 WH68 Weather Station   <span style="color: green">searching</span>
     2  ffffffff 255 0 WH80 Weather Station   <span style="color: green">searching</span>
     3  ffffffff  31 0 WH40 Rainfall          <span style="color: green">searching</span>
     5  ffffffff   0 0 WH32 Temperatue out    <span style="color: green">searching</span>
     6        ba   0 4 WH31 Temperature1      connected         🔋      📶 100%
     7        db   0 4 WH31 Temperature2      connected         🔋      📶 100%
     8        6e   0 4 WH31 Temperature3      connected         🔋      📶 100%
     9  ffffffff   0 0 WH31 Temperature4      <span style="color: green">searching</span>
    10  ffffffff   0 0 WH31 Temperature5      <span style="color: green">searching</span>
    11  ffffffff   0 0 WH31 Temperature6      <span style="color: green">searching</span>
    12  ffffffff   0 0 WH31 Temperature7      <span style="color: green">searching</span>
    13  ffffffff   0 0 WH31 Temperature8      <span style="color: green">searching</span>
    14    40c6e3  13 4 WH51 Soilmoisture1     connected         🔋 1.3V 📶 100%
    15  ffffffff  31 0 WH51 Soilmoisture2     <span style="color: green">searching</span>
    16  ffffffff  31 0 WH51 Soilmoisture3     <span style="color: green">searching</span>
    17  ffffffff  31 0 WH51 Soilmoisture4     <span style="color: green">searching</span>
    18  ffffffff  31 0 WH51 Soilmoisture5     <span style="color: green">searching</span>
    19  ffffffff  31 0 WH51 Soilmoisture6     <span style="color: green">searching</span>
    20  ffffffff  31 0 WH51 Soilmoisture7     <span style="color: green">searching</span>
    21  ffffffff  31 0 WH51 Soilmoisture8     <span style="color: green">searching</span>
    22      c51f   6 4 WH43 PM2.5 AQ 1        connected         🔌      📶 100%
    23  fffffffe  15 0 WH43 PM2.5 AQ 2        disabled
    24  fffffffe  15 0 WH43 PM2.5 AQ 3        disabled
    25  fffffffe  15 0 WH43 PM2.5 AQ 4        disabled
    26  ffffffff  15 0 WH57 Lightning         <span style="color: green">searching</span>
    27      e41a   4 4 WH55 Leak1             connected         🔋 4    📶 100%
    28  ffffffff  15 0 WH55 Leak2             <span style="color: green">searching</span>
    29  ffffffff  15 0 WH55 Leak3             <span style="color: green">searching</span>
    30  ffffffff  15 0 WH55 Leak4             <span style="color: green">searching</span>
    31  ffffffff 255 0 WH34 Soiltemperature1  <span style="color: green">searching</span>
    32  ffffffff 255 0 WH34 Soiltemperature2  <span style="color: green">searching</span>
    33  ffffffff 255 0 WH34 Soiltemperature3  <span style="color: green">searching</span>
    34  ffffffff 255 0 WH34 Soiltemperature4  <span style="color: green">searching</span>
    35  ffffffff 255 0 WH34 Soiltemperature5  <span style="color: green">searching</span>
    36  ffffffff 255 0 WH34 Soiltemperature6  <span style="color: green">searching</span>
    37  ffffffff 255 0 WH34 Soiltemperature7  <span style="color: green">searching</span>
    38  ffffffff 255 0 WH34 Soiltemperature8  <span style="color: green">searching</span>
    39  ffffffff  15 0 WH45 CO2 PM2.5 PM10 AQ <span style="color: green">searching</span>
    40  ffffffff 255 0 WH35 Leafwetness1      <span style="color: green">searching</span>
    41  ffffffff 255 0 WH35 Leafwetness2      <span style="color: green">searching</span>
    42  ffffffff 255 0 WH35 Leafwetness3      <span style="color: green">searching</span>
    43  ffffffff 255 0 WH35 Leafwetness4      <span style="color: green">searching</span>
    44  ffffffff 255 0 WH35 Leafwetness5      <span style="color: green">searching</span>
    45  ffffffff 255 0 WH35 Leafwetness6      <span style="color: green">searching</span>
    46  ffffffff 255 0 WH35 Leafwetness7      <span style="color: green">searching</span>
    47  ffffffff 255 0 WH35 Leafwetness8      <span style="color: green">searching</span>
</pre>

## Setting all leafwetness sensors to disabled and disable temperature sensor 6, next reset temp sensor 6 to id 'ba'.

The signal will increase to 100% if 4 packets are received during 4 consequtive periods.

<code>./gw -g 192.168.3.16 -c s 40-47=d,40-47,6=d,6=ba,6</code>

<pre>    
Sensor        ID   B S Type Name              State             Battery Signal
───────────────────────────────────────────────────────────────────────────────
    40  fffffffe 255 0 WH35 Leafwetness1      <span style="color:red">disabled</span>
    41  fffffffe 255 0 WH35 Leafwetness2      <span style="color:red">disabled</span>
    42  fffffffe 255 0 WH35 Leafwetness3      <span style="color:red">disabled</span>
    43  fffffffe 255 0 WH35 Leafwetness4      <span style="color:red">disabled</span>
    44  fffffffe 255 0 WH35 Leafwetness5      <span style="color:red">disabled</span>
    45  fffffffe 255 0 WH35 Leafwetness6      <span style="color:red">disabled</span>
    46  fffffffe 255 0 WH35 Leafwetness7      <span style="color:red">disabled</span>
    47  fffffffe 255 0 WH35 Leafwetness8      <span style="color:red">disabled</span>
     6        ba   0 0 WH31 Temperature1      <span style="color:magenta">disconnected</span>      🔋      🛑
</pre>

## Subnet scanning for devices on LAN

<code>./gw -s 192.168.3</code>
<pre>
192.168.3.14 8c:aa:b5:c7:24:b1 192.168.3.14 45000 EasyWeather-WIFI24B1 V1.6.1
192.168.3.16 48:3f:da:54:14:ec 192.168.3.16 45000 GW1000A-WIFI14EC V1.6.8
192.168.3.26 48:3f:da:55:4d:a9 192.168.3.26 45000 GW1000A-WIFI4DA9 V1.6.8
192.168.3.32 ^C
</pre>

## Changing units for temperature, pressure, wind and rain

<code>./gw -u p=inhg,t=farenheit,r=in -g 192.168.3.16 -c l</code>

## Viewing customized server settings

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

## Changing server, port, protocol, enabled
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

## Setting manual timezone
<code>./gw -g 192.168.3.16  -c system auto=off,tz=43,dst=1 -c system</code>
<pre>
System frequency                         1      868
System type                              1      WH65
System utc                      1643717874      2022-02-01 12:17:54
System timezone (manual)                43      (UTC+01:00) Amsterdam, B
System timezone AUTO                     0
System timezone DST                      1
</pre>

## Configuring new wifi ssid/pw - method 1 - server
<p>Connect to GW1000-WIFI???? network in your preferred os. Verify ip address of gw. Verify firewall settings for tcp port 49123</p> 
<code>./gw -g 192.168.4.1 -c wifi-server ssid pw</code>
<br>

## Configuring new wifi ssid/pw - method 2 - client
<code>./gw -g 192.168.4.1 -c wifi-client ssid pw</code>

## Reset device
<code>./gw -g 192.168.3.15 -c reset</code>
Press capital Y to reset, settings are destroyed, be careful.
<pre>Reset 48:3f:da:54:14:ec GW1000A-WIFI14EC (Y/N)?</pre>

# Background
I started to program the tool in javascript/nodejs which would have been easier due to standard libraries for arrays, readUInt and http parsing, but decided to test if its possible to do it in the shell/terminal using the standard unix nc/ncat and od utilities. For arrays I am creating them dynamically by using eval. readUint-functions are included in the script, as well as http parsing for Ecowitt and Wunderground protocol requests.

# Implementation
It will try to detect which version of nc (nc bsd/nmap, toybox, busybox) is available and tailor command options accoringly in [initnc](https://github.com/hkskoglund/gw/blob/f04f02748469b1f8ac9096d7ccc48fe2048a64b3/gw#L4334). The basic overall operation of the script for sending a command to gw is ["printf %b "$octalBuffer" | nc -4 $gwip $gwport | od"](https://github.com/hkskoglund/gw/blob/f04f02748469b1f8ac9096d7ccc48fe2048a64b3/gw#L3703-L3704) then parsing is done in [parsePacket](https://github.com/hkskoglund/gw/blob/f04f02748469b1f8ac9096d7ccc48fe2048a64b3/gw#L3399). Finaly livedata are printed in [printLivedata](https://github.com/hkskoglund/gw/blob/a0968f97c8cb69aa1f87b3155eaef63e927c398d/gw#L2123). The implementation is based on the [Ecowitt binary protocol specification](https://osswww.ecowitt.net/uploads/20210716/WN1900%20GW1000,1100%20WH2680,2650%20telenet%20v1.6.0%20.pdf). Unit conversion is initialized in [initUnit()](https://github.com/hkskoglund/gw/blob/a0968f97c8cb69aa1f87b3155eaef63e927c398d/gw#L6112-L6113). It is possible to extend the script by creating a new script view for your particular purpose using exported LIVEDATA environment variables.

## Styling

Terminal ansi escape codes is used to style solar,pm25, rain and wind data. Styling can be customized in [ansiesc.sh](./style/ansiesc.sh), [style-beufort.sh](./style/style-beufort.sh)

# Usage
### Basic
./gw [ -g **ip** ] [ -c **command** ] [-l **port** ] 
<br>
### Filtering/unit conversion
./gw [ -H **HEADERS** ] [ u- **UNITS**] ...
<br>
### Scan subnet for gw
./gw [ -s **xxx.xxx.xxx** ]<br>

# Options

### -g, --gw IP - ip adress to device<br>
### -c, --command COMMAND OPTIONS - send command to device
### -l, --listen PORT - listen for incoming ecowitt/wunderground http requests
### -s, --scan SUBNET - scan for devices on xxx.xxx.xxx 
### -H, --hide-headers HEADERS - hide headers from output in default view
### -u, --unit UNITS - set unit conversion for pressure,rain and wind<br><br>

# Commands

## livedata | l - get livedata from gw<br><br>

## sensor | s **SENSOROPTIONS** - get/set sensor state (searching/disabled/hexid)

### **SENSOROPTIONS** -  range *lowtype*-*hightype*=searching | s | connected | c | disconnected or single sensor *type*=*hexid*. For example to disable sensors 40-47 (leafwetnetness), the command is -c sensor 40-47=disable. The command following = is optional, in this case only sensors matching the range will be printed. To list only connected sensors, use -c sensor connected or shortform -c s c.<br><br>

## customized | c **CUSTOMIZEDOPTIONS** - get/set customized server configuration 
### **CUSTOMIZEDOPTIONS** is specified in a , separated list of key=value. Allowed keys are id, password | pw, server | s, port | p , interval | i, http | h, enabled | e, path_wunderground | p_w or path_ecowitt | p_e<br><br>

## system | sys **SYSTEMOPTIONS** - get/set system manual/auto timezone,daylight saving, system type (wh24/wh65)<br>
### **SYSTEMOPTIONS** auto=on | off |1 | 0, dst= on |off | 1 | 0, tz=*tzindex*|?, type=wh24 | wh65 | 0 |1. *tzindex* is a number between 0-107. Specifying *tzindex*=? will print available timezones.<br><br>

## wifi-server | w-s **SSID** **PASSWORD** - server configuration of ssid and password 
### Listen for incoming tcp connection on port 49123 from device and send new ssid/password when connected. It may be neccessary to use a manual ip/netmask on server, for example 192.168.4.2/255.255.255.0.<br><br>

## wifi-client | w-c **SSID** **PASSWORD** -client configuration of ssid and password
### Send a wifi configuration packet with ssid and password to the gw. This command must be used with the -g **host** option.

## reboot - reboot device<br><br>

## reset - reset device to default settings<br><br>

## Headers - hide/filter output in default view
### headers | h, rain | r, wind | w, beufort | b, temperature | t, light | l, uvi, system | s, soilmoisture | sm, soiltemperature | st, leak, co2, pm25, pm25aqi, leafwetness | leafw, lightning, tempusr | tusr, compass | c, status, sensor-header | sh<br><br>

## Units
### pressure | p = inhg | hpa
### temperature | t = celcius | c | farenheit | f
### rain | r = mm | in
### wind | w = mph | kmh | mps<br><br>

## Environment variables
### NO_COLOR - set to disable ansi escape terminal color styling<br><br>

# Running script in Windows Subsystem for Linux 2 - WSL2
portproxy must be used, open up customized server port(8080), 49123 for wifi-server configuration<br>
<code>
netsh interface portproxy reset<br>
iex "netsh interface portproxy add v4tov4 listenaddress=(Get-NetIPAddress -InterfaceAlias Wi-Fi -AddressFamily IPv4).IPAddress connectaddress=$(wsl -e hostname -I) connectport=8080 listenport=8080"</code>
<!---
https://www.markdownguide.org/basic-syntax/
https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes
https://htmlcolorcodes.com/color-names/
-->
