#!/bin/sh
#shellcheck disable=SC2034
export DEBUG="${DEBUG:=0}" # 1 will enable additional debug information, -d option to enable
[ $DEBUG -eq 1 ] && ls -l /bin/sh
DEBUG_OPTION_APPEND=0
DEBUG_OPTION_COMMAND=0
DEBUG_OPTION_HTTP=0
DEBUG_OPTION_TESTSENSOR=0
DEBUG_OPTION_TRACEPACKET=0
DEBUG_OPTION_STRICTPACKET=0
DEBUG_OPTION_EXPORT=0
DEBUG_OPTION_SET=0
DEBUG_OPTION_RESULT=0
DEBUG_OPTION_OD_BUFFER=0

HTTP_WUNDERGROUND=1
HTTP_ECOWITT=0

MAX_16BIT_UINT=$(((2 << 16) - 1))
MAX_STRING_LENGTH=64
TIMEOUT_WIFICONFIG_SERVER=${TIMEOUT_WIFICONFIG_SERVER:=10} # timeout in seconds for wifi-server configuration of GW1000

#https://unicode-table.com/en/emoji/travel-and-places/sky-and-weather/
UNICODE_RAINRATE=${UNICODE_RAINRATE:=💧}
UNICODE_RAINEVENT=${UNICODE_RAINEVENT:=⛆}
UNICODE_RAINDAY=${UNICODE_RAINDAY:=⛆}
UNICODE_RAINHOUR=${UNICODE_RAINHOUR:=☔}

UNICODE_BATTERY=${UNICODE_BATTERY:=🔋}
UNICODE_BATTERY_LOW=${UNICODE_BATTERY_LOW:=🪫}
UNICODE_PLUG=${UNICODE_PLUG:=🔌}

UNICODE_SIGNAL=${UNICODE_SIGNAL:=📶}
UNICODE_SIGNAL_LOW=${UNICODE_SIGNAL_LOW:=🛑}

UNICODE_WIND=${UNICODE_WIND:=💨} #https://emojipedia.org/dashing-away/

#https://www.compart.com/en/unicode/block/U+2580
UNICODE_SIGNAL_LEVEL0=${UNICODE_SIGNAL_LEVEL0:="$UNICODE_SIGNAL_LOW"}
UNICODE_SIGNAL_LEVEL1=${UNICODE_SIGNAL_LEVEL1:="${UNICODE_SIGNAL} 1/4"} # 1/4 packets received, seems to be a counter thats incremented/decremented after a each sensor periode
UNICODE_SIGNAL_LEVEL2=${UNICODE_SIGNAL_LEVEL2:="${UNICODE_SIGNAL} 2/4"}
UNICODE_SIGNAL_LEVEL3=${UNICODE_SIGNAL_LEVEL3:="${UNICODE_SIGNAL} 3/4"}
#UNICODE_SIGNAL_LEVEL4=${UNICODE_SIGNAL_LEVEL4:=▁▂▃▄}
UNICODE_SIGNAL_LEVEL4=${UNICODE_SIGNAL_LEVEL4:="${UNICODE_SIGNAL} 4/4"} # 4/4 packets


#HTTP_RESPONSE_200_OK="HTTP/1.1 200 OK"
#CRLF='\r\n'

LIVEDATAVIEW_NULL=0
LIVEDATAVIEW_NORMAL=1
LIVEDATAVIEW_BACKUP=2
LIVEDATAVIEW_TERSE=3
LIVEDATAVIEW=${LIVIEDATA_VIEW:=$LIVEDATAVIEW_NORMAL} #current live view


BATTERY_NORMAL=0
BATTERY_LOW=1
BATTERY_VOLTAGE_LOW=12 # scale x 10 <= 1.2V is low

NC_NMAP="nmap"
NC_OPENBSD="openbsd"
NC_TOYBOX="toybox"
NC_BUSYBOX="busybox"

PORT_TCP=45000
PORT_WIFICONFIG_SERVER_TCP=49123 # method 1: in wifi configuration part 3 in spec.
PORT_UDP=46000
PORT_CLIENT_UDP=59387

LOG_INTERVAL=${LOG_INTERVAL:=60} # default 60 seconds

LIVEDATAPROTOCOL_ECOWITT_BINARY="eb"
LIVEDATAPROTOCOL_ECOWITT_BINARY_LONG="Ecowitt binary"
LIVEDATAPROTOCOL_ECOWITT_HTTP="e"
LIVEDATAPROTOCOL_ECOWITT_HTTP_LONG="Ecowitt"
LIVEDATAPROTOCOL_WUNDERGROUND_HTTP="wu"
LIVEDATAPROTOCOL_WUNDERGROUND_HTTP_LONG="Wunderground"

CALIBRATION_INTEMPOFFSET_MAX=100
CALIBRATION_INHUMIOFFSET_MAX=10
CALIBRATION_ABSOFFSET_MAX=800
CALIBRATION_RELOFFSET_MAX=800
CALIBRATION_OUTTEMPOFFSET_MAX=100
CALIBRATION_OUTHUMIOFFSET_MAX=10
CALIBRATION_WINDDIROFFSET_MAX=180

CALIBRATION_RAIN_MAX=99999

UNIT_UNICODE_CELCIUS="℃"
UNIT_UNICODE_FARENHEIT="℉"
UNIT_UNICODE_WIND_MPS="m/s"
UNIT_UNICODE_PRESSURE_HPA="hPa"
UNIT_UNICODE_RAIN_MM="mm"
UNIT_UNICODE_WINDDIRECTION="°"

SYSTEM_FREQUENCY_RFM433M=0 # 433MHz
SYSTEM_FREQUENCY_RFM868M=1 # 868Mhz
SYSTEM_FREQUENCY_RFM915M=2 # 915MHz
SYSTEM_FREQUENCY_RFM920M=4 # 920Mhz

SYSTEM_SENSOR_TYPE_WH24=0
SYSTEM_SENSOR_TYPE_WH65=1



#is sent in http get request when data from sensors are not available, for example after reboot
WUNDERGROUND_UNDEFINED_VALUE="-9999"

#list all capabilities to terminal: infocmp/infocmp -L https://en.wikipedia.org/wiki/Terminal_capabilities
# it capability = tab size = 8 for xterm-256
# watch -c command only supports 3-bit colors in wsl2/ubuntu, other ansi escapes codes are filtered
