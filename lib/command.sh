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

CMD_READ_SOILHUMIAD=$(( 0x28 ))
CMD_WRITE_SOILHUMIAD=$(( 0x29 ))

CMD_READ_MULCH_OFFSET=$(( 0x2C ))
CMD_WRITE_MULCH_OFFSET=$(( 0x2D ))
CMD_READ_PM25_OFFSET=$(( 0x2E ))
CMD_WRITE_PM25_OFFSET=$(( 0x2F ))
CMD_READ_CO2_OFFSET=$(( 0x53 ))
CMD_WRITE_CO2_OFFSET=$(( 0x54 ))

CMD_READ_GAIN=$(( 0x36 ))
CMD_WRITE_GAIN=$(( 0x37 ))

#firmware version when command has introduced
FW_CMD_READ_SENSOR_ID=146
FW_CMD_READ_PATH=150
FW_CMD_READ_SENSOR_ID_NEW=154
FW_CMD_READ_MULCH_OFFSET=148
FW_CMD_READ_PM25_OFFSET=148
FW_CMD_READ_CO2_OFFSET=159



getCommandName()
# get command name
# $1 decimal command
# set VALUE_COMMAND_NAME
 { 
    case "$1" in
        "$CMD_READ_VERSION")            VALUE_COMMAND_NAME='read version' ;;
        "$CMD_REBOOT")                  VALUE_COMMAND_NAME='reboot' ;;
        "$CMD_READ_MAC")                VALUE_COMMAND_NAME='read mac' ;;
        "$CMD_WRITE_SSID")              VALUE_COMMAND_NAME='write ssid' ;;
        "$CMD_BROADCAST")               VALUE_COMMAND_NAME='broadcast' ;;
        "$CMD_WRITE_RESET")             VALUE_COMMAND_NAME='write reset' ;;
        "$CMD_READ_ECOWITT_INTERVAL")   VALUE_COMMAND_NAME='read ecowitt interval' ;;
        "$CMD_WRITE_ECOWITT_INTERVAL")  VALUE_COMMAND_NAME='write ecowitt interval' ;;
        "$CMD_READ_WUNDERGROUND")       VALUE_COMMAND_NAME='read wunderground' ;;
        "$CMD_WRITE_WUNDERGROUND")      VALUE_COMMAND_NAME='write wunderground' ;;
        "$CMD_READ_WOW")                VALUE_COMMAND_NAME='read wow' ;;
        "$CMD_WRITE_WOW")               VALUE_COMMAND_NAME='write wow' ;;
        "$CMD_READ_WEATHERCLOUD")       VALUE_COMMAND_NAME='read weathercloud' ;;
        "$CMD_WRITE_WEATHERCLOUD")      VALUE_COMMAND_NAME='write weathercloud' ;;
        "$CMD_READ_CUSTOMIZED")         VALUE_COMMAND_NAME='read customized' ;;
        "$CMD_WRITE_CUSTOMIZED")        VALUE_COMMAND_NAME='write customized' ;;
        "$CMD_READ_PATH")               VALUE_COMMAND_NAME='read path' ;;
        "$CMD_WRITE_PATH")              VALUE_COMMAND_NAME='write path' ;;
        "$CMD_READ_RAINDATA")           VALUE_COMMAND_NAME='read raindata' ;;
        "$CMD_WRITE_RAINDATA")          VALUE_COMMAND_NAME='write raindata' ;;
        "$CMD_LIVEDATA")                VALUE_COMMAND_NAME='livedata' ;;
        "$CMD_READ_SENSOR_ID")          VALUE_COMMAND_NAME='read sensor id' ;;
        "$CMD_WRITE_SENSOR_ID")         VALUE_COMMAND_NAME='write sensor id' ;;
        "$CMD_READ_SENSOR_ID_NEW")      VALUE_COMMAND_NAME='read sensor id new' ;;
       #? "$CMD_WRITE_SENSOR_ID_NEW")     VALUE_COMMAND_NAME='write sensor id new' ;;
        "$CMD_READ_SYSTEM")             VALUE_COMMAND_NAME='read system' ;;
        "$CMD_WRITE_SYSTEM")            VALUE_COMMAND_NAME='write system' ;;
        "$CMD_READ_CALIBRATION")        VALUE_COMMAND_NAME='read calibration' ;;
        "$CMD_WRITE_CALIBRATION")       VALUE_COMMAND_NAME='write calibration' ;;
        "$CMD_READ_SOILHUMIAD")         VALUE_COMMAND_NAME='read soilmoisture calibration' ;;
        "$CMD_WRITE_SOILHUMIAD")        VALUE_COMMAND_NAME='write soilmoisture calibratation' ;;
        "$CMD_READ_MULCH_OFFSET")       VALUE_COMMAND_NAME='read WH31 temp calibration' ;;
        "$CMD_WRITE_MULCH_OFFSET")      VALUE_COMMAND_NAME='write WH31 temp calibration' ;;
        "$CMD_READ_PM25_OFFSET")        VALUE_COMMAND_NAME='read pm25 calibration' ;;
        "$CMD_WRITE_PM25_OFFSET")       VALUE_COMMAND_NAME='write pm25 calibration' ;;
        "$CMD_READ_CO2_OFFSET")         VALUE_COMMAND_NAME='read co2 calibration' ;;
        "$CMD_WRITE_CO2_OFFSET")        VALUE_COMMAND_NAME='write co2 calibration' ;;
        "$CMD_READ_GAIN")               VALUE_COMMAND_NAME='read gain calibration' ;;
        "$CMD_WRITE_GAIN")              VALUE_COMMAND_NAME='write gain calibration' ;;
        *)                              VALUE_COMMAND_NAME="command name unknown dec: $1" ;;
    esac
}
