# gw - view weather data, sensor management and configuration backup for gw-1000 or compatible devices

gw reads weather data from gw-1000 and shows it in a live view. Data can be filtered for example hiding rain. It supports the binary protocol (*client*-mode) and http requests (*server*-mode). Settings on the device can be configured. For example gw can receive Ecowitt or Wunderground http requests by configuring the **customized server**.

The sensor view lists current battery, signal status and state (searching/disabled/hexid) to all sensors. Setting a new sensor state, for example from searching to disabled is supported.

Backup and restore of the entire weather service, calibration and sensor configuration is supported. 

It is designed with *portability* in mind and tested on bash, zsh, ksh93, mksh and **dash**. Ansi escape codes are used to style wind, uv index, and pm25 air quality index. 

The script uses the standard **nc** and  **od** utilities available on most systems.

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

 Solar radiation                 1255.0 ㏓
 Solar UV radiation                 9.9 W/㎡
 Solar UV index - LOW            <span style="background-color:green; color: black">   0      </span>

ＳＯＩＬＭＯＩＳＴＵＲＥ

 Soilmoisture 1                      58 %       🔋📶

ＰＭ２.５ ＡＩＲ ＱＵＡＬＩＴＹ

 PM 2.5 1 - GOOD                    <span style="background-color:green; color: black">3.0 µg/㎥</span>   🔌📶
 PM 2.5 24h avg. 1 - GOOD           <span style="background-color:green; color: black">3.0 µg/㎥</span>

ＳＹＳＴＥＭ

System host                      192.168.3.16
System version                   GW1000A_V1.6.8
System utc                       2022-01-26 12:07:53
System frequency                 868
System type                      WH65   🔋📶
System sensors connected          7
System sensors disconnected       <span style="color:magenta">0</span>
System sensors searching         <span style="color:green">29</span>
System sensors disabled          <span style="color: red">11</span>
</pre>

## Monitoring sensors

<code>watch ./gw -g 192.168.3.16 --sensor</code>
<pre>
Every 2.0s: ./gw -g 192.168.3.16 --sensor           ideapadpro: Tue Mar 29 11:30:52 2022

sensor_wh65           0       f1   0 4 ✅ connected     🔋      📶 4/4
sensor_wh68           1 fffffffe 255 0 ⛔ disabled
sensor_wh80           2 fffffffe 255 0 ⛔ disabled
sensor_rainfall       3 fffffffe  31 0 ⛔ disabled
sensor_outtemp        5 fffffffe   0 0 ⛔ disabled
sensor_temp1          6       ba   0 4 ✅ connected     🔋      📶 4/4
sensor_temp2          7       db   0 4 ✅ connected     🔋      📶 4/4
sensor_temp3          8       6e   0 4 ✅ connected     🔋      📶 4/4
sensor_temp4          9 fffffffe   0 0 ⛔ disabled
sensor_temp5         10 fffffffe   0 0 ⛔ disabled
sensor_temp6         11 fffffffe   0 0 ⛔ disabled
sensor_temp7         12 fffffffe   0 0 ⛔ disabled
sensor_temp8         13 fffffffe   0 0 ⛔ disabled
sensor_soilmoisture1 14   40c6e3  13 4 ✅ connected     🔋 1.3V 📶 4/4
sensor_soilmoisture2 15 fffffffe  31 0 ⛔ disabled
sensor_soilmoisture3 16 fffffffe  31 0 ⛔ disabled
sensor_soilmoisture4 17 fffffffe  31 0 ⛔ disabled
sensor_soilmoisture5 18 fffffffe  31 0 ⛔ disabled
sensor_soilmoisture6 19 fffffffe  31 0 ⛔ disabled
sensor_soilmoisture7 20 fffffffe  31 0 ⛔ disabled
sensor_soilmoisture8 21 fffffffe  31 0 ⛔ disabled
sensor_pm251         22     c50e   6 4 ✅ connected     🔌      📶 4/4
sensor_pm252         23 fffffffe  15 0 ⛔ disabled
sensor_pm253         24 fffffffe  15 0 ⛔ disabled
sensor_pm254         25 fffffffe  15 0 ⛔ disabled
sensor_lightning     26 fffffffe   0 0 ⛔ disabled
sensor_leak1         27 fffffffe  15 0 ⛔ disabled
sensor_leak2         28 fffffffe  15 0 ⛔ disabled
sensor_leak3         29 fffffffe  15 0 ⛔ disabled
sensor_leak4         30 fffffffe  15 0 ⛔ disabled
sensor_soiltemp1     31 fffffffe 255 0 ⛔ disabled
sensor_soiltemp2     32 fffffffe 255 0 ⛔ disabled
sensor_soiltemp3     33 fffffffe 255 0 ⛔ disabled
sensor_soiltemp4     34 fffffffe 255 0 ⛔ disabled
sensor_soiltemp5     35 fffffffe 255 0 ⛔ disabled
sensor_soiltemp6     36 fffffffe 255 0 ⛔ disabled
sensor_soiltemp7     37 fffffffe 255 0 ⛔ disabled
sensor_soiltemp8     38 fffffffe 255 0 ⛔ disabled
sensor_co2           39 fffffffe   0 0 ⛔ disabled
sensor_leafwetness1  40 fffffffe 255 0 ⛔ disabled
sensor_leafwetness2  41 fffffffe 255 0 ⛔ disabled
sensor_leafwetness3  42 fffffffe 255 0 ⛔ disabled
sensor_leafwetness4  43 fffffffe 255 0 ⛔ disabled
sensor_leafwetness5  44 fffffffe 255 0 ⛔ disabled
sensor_leafwetness6  45 fffffffe 255 0 ⛔ disabled
sensor_leafwetness7  46 fffffffe 255 0 ⛔ disabled
sensor_leafwetness8  47 fffffffe 255 0 ⛔ disabled
</pre>

## Setting all leafwetness sensors to searching and disable temperature sensor 1, reset temp sensor 1 to id 'ba'.

. is glob pattern matching all channels.

<code>./gw  -g 192.168.3.16 --sensor_leafwetness.=on --sensor_temp1=off --sensor_temp1=ba --sensor | grep -E "_temp1|_leafwetness"</code>
<pre>
sensor_temp1          6       ba   0 0 🚫 disconnected
sensor_leafwetness1  40 ffffffff 255 0 🔎 searching
sensor_leafwetness2  41 ffffffff 255 0 🔎 searching
sensor_leafwetness3  42 ffffffff 255 0 🔎 searching
sensor_leafwetness4  43 ffffffff 255 0 🔎 searching
sensor_leafwetness5  44 ffffffff 255 0 🔎 searching
sensor_leafwetness6  45 ffffffff 255 0 🔎 searching
sensor_leafwetness7  46 ffffffff 255 0 🔎 searching
sensor_leafwetness8  47 ffffffff 255 0 🔎 searching
</pre>

## Weather service configuration
### Ecowitt interval 1 minute (https://www.ecowitt.net/)
<code>./gw -g 192.168.3.16 --ecowitt_interval=1</code>
### Weathercloud (https://weathercloud.net/en)
<code>./gw -g 192.168.3.16 --weathercloud_id=wcid --weathercloud_password=wcpw</code>
### Weather Observations Website  (https://wow.metoffice.gov.uk/)
<code>./gw -g 192.168.3.16 --wow_id=wowid --wow_password=wowpw</code>
### Wundergrodund (https://www.wunderground.com/)
<code>./gw -g 192.168.3.16 --wunderground_id=wuid --wunderground_password=wupw</code>
### Customized server  (http://192.168.3.4:8082/)
<code>./gw -g 192.168.3.16 --server="ecowitt://192.168.3.3:8080/path/ecowitt?interval=16&enabled=true&id=id&password=pw"  --server</code>
<pre>
customized wunderground id              id
customized wunderground password        pw
customized server                       192.168.3.3
customized port                         8082
customized interval                     16 seconds
customized http protocol                0 ecowitt
customized enabled                      1 true
customized path ecowitt                 /path/ecowitt
customized path wunderground            /path/wu
</pre>

## Backup and restore of weather services, calibration and sensor configuration
<code>./gw -g 192.168.3.16 -b</code>
<pre>Created backup-192.168.3.16-GW1000A_V1.6.8-11-00-04-914237195.hex</pre>
<code>./gw -g 192.168.3.16 -r backup-192.168.3.16-GW1000A_V1.6.8-11-00-04-914237195.hex</code>

## Continous monitoring each 1 minute -H option to hide groups (rain, system, temperature and leak)
<code> while true; do clear;./gw -g 192.168.3.16 -H rain,system,t,leak  -c l; sleep 60; done</code>

## Listen for Ecowitt/Wunderground http request on port 8080

<code>./gw -l 8080</code>

## Subnet scanning for devices on LAN

<code>./gw --scan 192.168.3</code>
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

## Calibration rain 
<code>./gw -g 192.168.3.16 -c rain y=85.9</code>
<pre>
rain rate  0.0 mm/h
rain day   0.0 mm
rain week  0.0 mm
rain month 0.0 mm
rain year  85.9 mm
</pre>

## Calibration barometre
<code>./gw -g 192.168.3.16 -c calibrate absolute=-1.7,relative=1.7 </code>
<pre>
./gw -g 192.168.3.16 -c calibrate a=-1.7,r=1.7 -c cal
calibration in temperature offset           0.0 ℃
calibration in humidity offset              0   %
calibration absolute pressure offset        -1.7 hPa
calibration relative pressure offset        1.7 hPa
calibration out temperature offset          0.0 ℃
calibration out humidity offset             0   %
calibration wind direction offset           0
</pre>

# Usage
### Basic
./gw [ -g **IP** ] [ -c **command** ] [-l **PORT** ] [ -s | --sensor ] [ --sensor_**TYPE**=disable|search] [ --server]
<br>
### Unit conversion
./gw [ -u **UNITS**] ...
<br>
### Scan subnet for gw
./gw [ --scan **xxx.xxx.xxx** ]<br>

# Options

## -g, --gw IP - ip adress to device<br>
## -c, --command COMMAND [OPTIONS] - send command to device
## -l, --listen PORT - listen for incoming ecowitt/wunderground http requests
## -s, --sensor - print list of sensors
## -b, --backup - backup of weather services, calibration and sensors
## -B - binary backup
## -r, --restore - restore backup
## -R - restore binary backup
## --scan SUBNET - scan for devices on xxx.xxx.xxx 
## -u, --unit UNITS - set unit conversion for pressure,rain and wind
## -G, --group-header - print group header in livedata view
## -d, --debug [OPTIONS] - print debug information<br><br>

# option -c

## livedata | l - get livedata from gw
Print all weather data received from sensors

# option -s
## --sensor | -s
Print a list of sensors. Each sensor has a unique name starting with prefix <b>sensor_</b>that can be used as an long option (--) to set desired state. Multiple sensors can be set to searching/disabled using glob pattern <b>sensor_TYPE.=</b> 
### Setting single sensor state
sensor_TYPE1=disable | off,  search 
* disable | off
* search | on
* HEXID
### Setting multiple sensor using glob . pattern
sensor_TYPE.=search

# option --server
Print customized server settings
## --server="PROTOCOL://IP:PORT/PATH?interval=N&enabled=true|false&id=ID&password=PASSWORD"
Set multiple settings using query string format. 
## --id=ID
Set customized id
## --password=PASSWORD
Set customized password
## --port=PORT
Set customized port
## --http=ecowitt | wunderground
Set customized http protocol.
## --path_ecowitt=PATH
Set customized http ecowitt request path
## --path_wunderground=PATH
Set customized http wunderground request path
## --interval=INTERVAL
Set customized interval in seconds
## --enabled=true | false
Set customized enabled state

## system | sys **[OPTIONS]** - get/set system manual/auto timezone,daylight saving, system type (wh24/wh65)<br>
### **OPTIONS** comma delimited list [ key=value, ... ]; auto=on | off |1 | 0, dst= on |off | 1 | 0, tz=*tzindex*|?, type=wh24 | wh65 | 0 |1.<br>
*tzindex* is a number between 0-107. Specifying *tzindex*=? will print available timezones.
When **auto=on** is on, the timezone is determined automatically. Otherwise the manuall timezone setting is used. Daylight saving can be set with the **dst=on**. Every sensor attached to the device must be on the same frequency as the system frequency.<br>

## wifi-server | w-s **SSID** **PASSWORD** - server configuration of ssid and password 
### Listen for incoming tcp connection on port 49123 from device and send new ssid/password when connected. It may be neccessary to use a manual ip/netmask on server, for example 192.168.4.2/255.255.255.0.<br><br>

## wifi-client | w-c | ssid **SSID** **PASSWORD** - client configuration of ssid and password
### Send a wifi configuration packet with ssid and password to the gw. This command must be used with the -g **host** option.<br><br>

## rain | r **[OPTIONS]** - get/set rain day, week, month and year
### OPTIONS comma delimited list [ key=value, ... ]; day= | week= | month= | year=< value in mm > | reset<br><br>

## calibrate | cal **[OPTIONS]** - get/set calibration
### OPTIONS - comma delimited list [ key=value, ... ]; it | intemp=[-]offset (℃) ,ih | inhumi=[-]offset (%), ot | outtemp=[-]offset (℃),oh | outhumi=[-]offset (%), a|absolute=[-]offset (hPa), r|relative=[-]offset (hPa), w | winddir=[-]offset (°), reset
reset will set all calibration offsets to 0. Calibration is updated on the device each minute (based on test: while true; do ./gw -g 192.168.3.26 -c l | egrep -i "press|utc|host" ; sleep 1;  done)

## reboot - reboot device<br>
Reboot takes about 5 seconds. Time is synchronized with cn.pool.ntp.org each hour. Timezone, utcoffset, sunrise/sunset are fetched from rtpdate.ecowitt.net. Wind daily max is reset during reboot.
## reset - reset device to default settings<br><br>

# Option: -B | --backup - backup of weather sevice, calibration and sensor configuration
Takes a binary backup of entire configuration including weather services, calibration offsets and sensor configuration.

# Option -R | --restore BACKUPFILE - restore weather service, calibration and sensor configuration
Restores binary backup from backupfile

# Option -u [k=v,...]
## pressure | p = inhg | hpa
## temperature | t = celcius | c | farenheit | f
## rain | r = mm | inch
## wind | w = mph | kmh | mps
## light | l = lux | watt<br><br>
# Option -d [k,...kn]
## command - print command sent to device
<code>./gw -g 192.168.3.16 -d command -c version</code>
<pre>read version: printf %b "\0377\0377\0120\0003\0123"  | "/usr/bin/nc" -4 -N -w 1  192.168.3.16 45000  | od -A n -t u1 -w131071
GW1000A_V1.6.8</pre>
## http | h - print http request received from device
## buffer | b - print hex buffer to/from device
<code> ./gw -g 192.168.3.16 -d buffer -c version</code>
<pre>> read version         ff ff 50 03 53
< read version         ff ff 50 12 0e 47 57 31 30 30 30 41 5f 56 31 2e 36 2e 38 c0</pre>
GW1000A_V1.6.8
## trace | t - creates .hex rx/tx files with command/response
<code> ./gw -g 192.168.3.16 -d trace -c version; ls *.hex</code>
<pre>'rx-read version-14 20 03 412733378.hex'
'tx-read version-14 20 03 412733378.hex'</pre>
Allows viewing hex file in Visual Studio Code
## append | a - print append format/args for liveview
## strict - show warning if packet length is not the same as actual packet length and crc fails
## export - show exported variables
## set - show all variables
<br><br>

# Standalone execution of livedata view
The standard livedata view can be run standalone and will intepret LIVEDATA environment variables. Used for testing.
<code>LIVEDATA_INTEMP=20 LIVEDATA_OUTTEMP=1 ./view/livedata.sh</code>

# Environment variables
## NO_COLOR - set to disable ansi escape terminal color styling
## NC_VERSION - set nc version manually if auto-detect fails
### Valid values: openbsd, nmap, busybox, toybox; example NC_VERSION=busybox | toybox
## NC_CMD - set path to nc binary if nc executable is not in the path
If NC_VERSION is set, NC_CMD will be determined automatically by *which*-command searching the path, but it can be set manually; example NC_CMD=/home/user/test/toybox NC_VERSION=toybox ./gw<br>
The purpose of NC_VERSION is to tailor options used in each executable
## DEBUG_INITNC - valid values 0 | 1 - shows debug info for initnc/auto-detect
<br>

# Background
I started to program the tool in javascript/nodejs which would have been easier due to standard libraries for arrays, readUInt and http parsing, but decided to test if its possible to do it in the shell/terminal using the standard unix nc/ncat and od utilities. For arrays I am creating them dynamically by using eval. readUint-functions are included in the script, as well as http parsing for Ecowitt and Wunderground protocol requests.

# Implementation
It will try to detect which version of nc (nc bsd/nmap, toybox, busybox) is available and tailor command options accoringly in [initnc](https://github.com/hkskoglund/gw/blob/f04f02748469b1f8ac9096d7ccc48fe2048a64b3/gw#L4334). The basic overall operation of the script for sending a command to gw is ["printf %b "$octalBuffer" | nc -4 $gwip $gwport | od"](https://github.com/hkskoglund/gw/blob/f04f02748469b1f8ac9096d7ccc48fe2048a64b3/gw#L3703-L3704) then parsing is done in [parsePacket](https://github.com/hkskoglund/gw/blob/f04f02748469b1f8ac9096d7ccc48fe2048a64b3/gw#L3399). Finaly livedata are printed in [printLivedata](https://github.com/hkskoglund/gw/blob/a0968f97c8cb69aa1f87b3155eaef63e927c398d/gw#L2123). The implementation is based on the [Ecowitt binary protocol specification](https://osswww.ecowitt.net/uploads/20210716/WN1900%20GW1000,1100%20WH2680,2650%20telenet%20v1.6.0%20.pdf). Unit conversion is initialized in [initUnit()](https://github.com/hkskoglund/gw/blob/a0968f97c8cb69aa1f87b3155eaef63e927c398d/gw#L6112-L6113). It is possible to extend the script by creating a new script view for your particular purpose using exported LIVEDATA environment variables.

## Styling

Terminal ansi escape codes is used to style solar,pm25, rain and wind data. Styling can be customized in [ansiesc.sh](./style/ansiesc.sh), [style-beufort.sh](./style/style-beufort.sh)

# Running script in Windows Subsystem for Linux 2 - WSL2
portproxy must be used, open up customized server port(8080), 49123 for wifi-server configuration<br>
<code>netsh interface portproxy reset</code><br>
<code>iex "netsh interface portproxy add v4tov4 listenaddress=(Get-NetIPAddress -InterfaceAlias Wi-Fi -AddressFamily IPv4).IPAddress connectaddress=$(wsl -e hostname -I) connectport=8080 listenport=8080"</code>
<!---
https://www.markdownguide.org/basic-syntax/
https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes
https://htmlcolorcodes.com/color-names/
-->
