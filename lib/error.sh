#!/bin/sh

#ERROR_CONNECTION=1
#ERROR_NO_NMCLI=2
ERROR_NC_UDP_SCAN_UNAVAILABLE=3
ERROR_SYSTEM_OPTION=5
ERROR_DEPENDENCY_NC=6
ERROR_PRX_PREAMBLE=7
ERROR_OD_BUFFER_EMPTY=8
ERROR_CONVERT=9
ERROR_HTTP_MESSSAGE_EMPTY=10
ERROR_NO_HOST_SPECIFIED=11
ERROR_INVALID_SENSORID=12
ERROR_INVALID_SENSORID_COMMAND=13
ERROR_LISTEN_INVALID_PORTNUMBER=14
ERROR_LISTEN_NOPORT=15
ERROR_LISTEN_UNSUPPORTED_NC=16
ERROR_COMMAND_UNKNOWN=17
ERROR_INVALID_SUBNET=18
ERROR_SSID_EMPTY=19
ERROR_PARSEPACKET_UNSUPPORTED_COMMAND=20
ERROR_WIFICONFIG_SERVER_FAILED=21 # fail response code 1 from GW
ERROR_CUSTOMIZED_OPTION=22 #if customized settings is wrong
ERROR_NO_COMMAND_SPECIFIED=23 # no command specified for sendpacket
ERROR_INVALID_VALUE=24 
ERROR_INVALID_FILENAME=25
ERROR_READ_BUFFER=26 # failed to read from buffer
ERROR_PARSEPACKET_LENGTH=27 # actual packet length, is not the same as reported packet length inside packet - strict packet debug option
ERROR_PARSEPACKET_CRC=28 # if crc check fails on received packet -strict packet debug option
ERROR_WEATHERSERVICE_INVALID_OPTION=29 # if option to command is unknown
ERROR_MAX_STRING_LENGTH_EXCEEDED=30 # if string length is beyond max limit
ERROR_SENSORID_COMMAND_NOT_SUPPORTED=31 # if sensor id + sensor id new command not supported in old firmware
ERROR_INVALID_ECOWITT_INTERVAL=32 # not a number, or outside 0-5
ERROR_NONEXIST_FILENAME=33
ERROR_UNKNOWN_RESTORE_COMMAND=34 # restore backup command unknown
ERROR_RESTORE_DENIED=35 # restore overwrite of binary backup denied by user


logErr()
#$1 - 1=on,0=off
{
     [ "$1" -eq 1 ] && { shift; echo >&2 "$*" ; }
}
