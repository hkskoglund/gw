#!/bin/sh
CMD_READ_VERSION=$((0x50)) #zsh - wont compare int with hex 16#50 in [ ] expression unless converted to decimal, works in [[ ]] expression
CMD_REBOOT=$((0x40))
CMD_READ_MAC=$((0x26))
CMD_WRITE_SSID=$((0x11))
CMD_BROADCAST=$((0x12))
CMD_WRITE_RESET=$((0x41))

#weather services
CMD_READ_ECOWITT_INTERVAL=$((0x1e)) 
CMD_WRITE_ECOWITT_INTERVAL=$((0x1f))
CMD_READ_WUNDERGROUND=$((0x20))
CMD_WRITE_WUNDERGROUND=$((0x21))
CMD_READ_WOW=$((0x22))
CMD_WRITE_WOW=$((0x23))
CMD_READ_WEATHERCLOUD=$((0x24))
CMD_WRITE_WEATHERCLOUD=$((0x25))

#customized server for ecowitt/wunderground http requests
CMD_READ_CUSTOMIZED=$((0x2a))
CMD_WRITE_CUSTOMIZED=$((0x2b))
CMD_READ_PATH=$((0x51))
CMD_WRITE_PATH=$((0x52))
CMD_READ_RAINDATA=$((0x34))
CMD_WRITE_RAINDATA=$((0x35))
CMD_LIVEDATA=$((0x27))

#sensors
CMD_READ_SENSOR_ID=$((0x3a))
CMD_WRITE_SENSOR_ID=$((0x3b))
CMD_READ_SENSOR_ID_NEW=$((0x3c)) # for new sensors
CMD_READ_SYSTEM=$((0x30))
CMD_WRITE_SYSTEM=$((0x31))
CMD_READ_CALIBRATION=$((0x38))
CMD_WRITE_CALIBRATION=$((0x39))

getCommandName()
# get command name, set COMMAND_NAME
# $1 decimal command
 { 
    case "$1" in
        "$CMD_READ_VERSION")            COMMAND_NAME='read version' ;;
        "$CMD_REBOOT")                  COMMAND_NAME='reboot' ;;
        "$CMD_READ_MAC")                COMMAND_NAME='read mac' ;;
        "$CMD_WRITE_SSID")              COMMAND_NAME='write ssid' ;;
        "$CMD_BROADCAST")               COMMAND_NAME='broadcast' ;;
        "$CMD_WRITE_RESET")             COMMAND_NAME='write reset' ;;
        "$CMD_READ_ECOWITT_INTERVAL")   COMMAND_NAME='read ecowitt interval' ;;
        "$CMD_WRITE_ECOWITT_INTERVAL")  COMMAND_NAME='write ecowitt interval' ;;
        "$CMD_READ_WUNDERGROUND")       COMMAND_NAME='read wunderground' ;;
        "$CMD_WRITE_WUNDERGROUND")      COMMAND_NAME='write wunderground' ;;
        "$CMD_READ_WOW")                COMMAND_NAME='read wow' ;;
        "$CMD_WRITE_WOW")               COMMAND_NAME='write wow' ;;
        "$CMD_READ_WEATHERCLOUD")       COMMAND_NAME='read weathercloud' ;;
        "$CMD_WRITE_WEATHERCLOUD")      COMMAND_NAME='write weathercloud' ;;
        "$CMD_READ_CUSTOMIZED")         COMMAND_NAME='read customized' ;;
        "$CMD_WRITE_CUSTOMIZED")        COMMAND_NAME='write customized' ;;
        "$CMD_READ_PATH")               COMMAND_NAME='read path' ;;
        "$CMD_WRITE_PATH")              COMMAND_NAME='write path' ;;
        "$CMD_READ_RAINDATA")           COMMAND_NAME='read raindata' ;;
        "$CMD_WRITE_RAINDATA")          COMMAND_NAME='write raindata' ;;
        "$CMD_LIVEDATA")                COMMAND_NAME='livedata' ;;
        "$CMD_READ_SENSOR_ID")          COMMAND_NAME='read sensor id' ;;
        "$CMD_WRITE_SENSOR_ID")         COMMAND_NAME='write sensor id' ;;
        "$CMD_READ_SENSOR_ID_NEW")      COMMAND_NAME='read sensor id new' ;;
        "$CMD_READ_SYSTEM")             COMMAND_NAME='read system' ;;
        "$CMD_WRITE_SYSTEM")            COMMAND_NAME='write system' ;;
        "$CMD_READ_CALIBRATION")        COMMAND_NAME='read calibration' ;;
        "$CMD_WRITE_CALIBRATION")       COMMAND_NAME='write calibration' ;;
        *)                              COMMAND_NAME="unknown command dec: $1" ;;
    esac
    
    if [ -z "$COMMAND_NAME" ]; then
        COMMAND_NAME="{cmdname missing} $1"
        return 1
    fi
}
