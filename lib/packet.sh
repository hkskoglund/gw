#!/bin/sh

DEBUG=${DEBUG:=0}
DEBUG_PACKET=${DEBUG_PACKET:=$DEBUG}

if ! type convertBufferFromDecToOctalEscape 1>/dev/null 2>/dev/null; then
    . ./lib/converters.sh
fi

sendPacket()
# wrapper function for sending packet to host
# previous prototype used bash tcp/udp functionality, instead of locking the script to bash only, nc command is used instead for allowing multiple shells
# $1 command, $2 host
{
    EXITCODE_SENDPACKET=0

    #validate command
    if [ -z "$1" ]; then
      echo >&2 "Error: No command specified"
      EXITCODE_SENDPACKET="$ERROR_NO_HOST_SPECIFIED"
      return "$EXITCODE_SENDPACKET"
    fi
    
    # validate host
    if [ -z "$2" ]; then
      echo >&2 "Error: No host specified"
      EXITCODE_SENDPACKET="$ERROR_NO_HOST_SPECIFIED"
      return "$EXITCODE_SENDPACKET"
    fi

     #init new packet for simple command without body
    if  [ "$1" -eq "$CMD_BROADCAST" ] ||\
        [ "$1" -eq "$CMD_LIVEDATA" ] ||\
        [ "$1" -eq "$CMD_READ_CALIBRATION" ] ||\
        [ "$1" -eq "$CMD_READ_ECOWITT_INTERVAL" ] ||\
        [ "$1" -eq "$CMD_READ_WUNDERGROUND" ] ||\
        [ "$1" -eq "$CMD_READ_WOW" ] ||\
        [ "$1" -eq "$CMD_READ_WEATHERCLOUD" ] ||\
        [ "$1" -eq "$CMD_READ_CUSTOMIZED" ] ||\
        [ "$1" -eq "$CMD_READ_PATH" ] ||\
        [ "$1" -eq "$CMD_READ_MAC" ] ||\
        [ "$1" -eq "$CMD_READ_RAINDATA" ] ||\
        [ "$1" -eq "$CMD_READ_SENSOR_ID" ] ||\
        [ "$1" -eq "$CMD_READ_SENSOR_ID_NEW" ] ||\
        [ "$1" -eq "$CMD_READ_SYSTEM" ] ||\
        [ "$1" -eq "$CMD_READ_VERSION" ] ||\
        [ "$1" -eq "$CMD_REBOOT" ] ||\
        [ "$1" -eq "$CMD_WRITE_RESET" ]  ; then
             newPacket "$1"
    fi

   if ! sendPacketnc "$@"; then # $@ each arg expands to a separate word
      EXITCODE_SENDPACKET=$EXITCODE_SENDPACKETNC
      [ "$DEBUG_PACKET" -eq 1 ] && echo >&2 "Sendpacket failed with error code $EXITCODE_SENDPACKET"
   fi
    
    return "$EXITCODE_SENDPACKET"
}

sendPacketnc()
# send packet to host with nc, append response to backup file if specified
# $1 command, $2 host ip , $3 backup filename (optional)
# DEBUG_OPTION_OD_BUFFER=1      print od buffer
# DEBUG_OPTION_TRACEPACKET=1    create tx/rx files in .hex binary format
# DEBUG_SENDPACKETNC=1          debug only this function
{ 
    EXITCODE_SENDPACKETNC=0
    DEBUG_SENDPACKETNC=${DEBUG_SENDPACKETNC:=$DEBUG_PACKET}
    DEBUG_FUNC='sendPacketnc'

    [ "$DEBUG_SENDPACKETNC" -eq 1 ] && echo >&2 "$DEBUG_FUNC args: $* length: $# 0: $0 command: $1 host: $2 PACKET_TX_BODY: $PACKET_TX_BODY"
    
    timeout_nc=0.05
    timeout_udp_broadcast=0.236 # timeout selected based on udp port scanning 254 hosts in 60s (60s/254=0.236s)
    useTimeout=0

    createPacketTX "$1"

    { [ "$DEBUG_SENDPACKETNC" -eq 1 ] || [ "$DEBUG_OPTION_OD_BUFFER" ] ; } &&
    {
        printf >&2 "> %-20s" "$COMMAND_NAME"
        printBuffer >&2 "$PACKET_TX"
    }

    unset rxpipecmd txpipecmd

    if [ "$DEBUG_OPTION_TRACEPACKET" -eq 1 ]; then
       #visual studio code: problems with HH:MM:SS display for date -> using space
       tracedate=$(date +'%H %M %S %N') #https://superuser.com/questions/674464/print-current-time-with-milliseconds
       rxpipecmd=" | tee \"rx-$COMMAND_NAME-$tracedate.hex\""
       txpipecmd=" | tee \"tx-$COMMAND_NAME-$tracedate.hex\""
    fi

    if [ -n "$3" ]; then # append to backup file
      rxpipecmd="$rxpipecmd | tee -a \"$3\""
    fi

    port=$GW_PORT_TCP

    if [ "$PACKET_TX_CMD" -eq "$CMD_BROADCAST" ]; then
        ncUDPOpt='-u' # udp mode
        port=$GW_PORT_UDP
        timeout_nc=$timeout_udp_broadcast
        useTimeout=1
    elif [ "$PACKET_TX_CMD" -eq "$CMD_WRITE_RESET" ] || [ "$PACKET_TX_CMD" -eq "$CMD_WRITE_SSID" ]; then
        :
    elif [ "$PACKET_TX_CMD" -eq "$CMD_REBOOT" ]; then
       useTimeout=1
       timeout_nc=1
       #sometimes result packet from gw is not received, and nc hangs
    fi

    # change between openbsd/nmap ncat in WSL2/ubuntu - sudo update-alternatives --config nc

    odcmdstr="od -A n -t u1 -w$MAX_16BIT_UINT"

    if [ "$NC_VERSION" = "$NC_OPENBSD" ]; then

        # -N shutdown(2) the network socket after EOF on the input / from man nc - otherwise nc hangs
        nccmdstr="\"$NC_CMD\" -4 -N -w 1 $ncUDPOpt $2 $port" 
       
        #if [ "$useTimeout" -eq 1 ]; then
        #   nccmdstr="timeout $timeout_nc $nccmdstr"
        #fi
        
        cmdstr="printf %b \"$PACKET_TX_ESCAPE\" $txpipecmd | $nccmdstr $rxpipecmd | $odcmdstr"

    elif [ "$NC_VERSION" = "$NC_NMAP" ]; then

        #sleep to disable immediate EOF and shutdown of ncat -> which leads to data not received from udp socket
       
        nccmdstr="\"$NC_CMD\" -4 -w 1  $ncUDPOpt $2 $port"
        cmdstr="{ printf %b \"$PACKET_TX_ESCAPE\" $txpipecmd ; sleep $timeout_nc; } |  $nccmdstr $rxpipecmd | $odcmdstr"

    elif [ "$NC_VERSION" = "$NC_TOYBOX" ]; then

        nccmdstr="$NC_CMD -4 $ncUDPOpt $2 $port"
        
        if [ "$useTimeout" -eq 1 ]; then
           nccmdstr="timeout $timeout_nc $nccmdstr"
        fi

        cmdstr="printf %b \"$PACKET_TX_ESCAPE\" $txpipecmd | $nccmdstr $rxpipecmd | $odcmdstr"

    elif [ "$NC_VERSION" = "$NC_BUSYBOX" ]; then

        nccmdstr="$NC_CMD $2 $port"

        if [ -z "$ncUDPOpt" ]; then
            cmdstr="printf %b \"$PACKET_TX_ESCAPE\" $txpipecmd |  $nccmdstr $rxpipecmd | $odcmdstr"
        else
            echo >&2 Busybox nc does not support UDP
        fi
    else
        echo >&2 "Error: nc version $NC_VERSION not supported sendPacketnc $ERROR_DEPENDENCY_NC"
        return "$ERROR_DEPENDENCY_NC"
    fi

    if [ -n "$cmdstr" ]; then

       if [ -n "$DEBUG_OPTION_COMMAND" ] && [ "$DEBUG_OPTION_COMMAND" -eq 1 ]; then
            printf >&2 "%s: %s\n" "$COMMAND_NAME" "$cmdstr"
       fi
       
       if [ "$DEBUG_SENDPACKETNC" -eq 1 ]; then
            echo >&2 "Sending packet $COMMAND_NAME to $2:$port"
       fi 

       od_buffer=$(eval "$cmdstr" )
       #maybe use: https://stackoverflow.com/questions/1550933/catching-error-codes-in-a-shell-pipe
       if [ -z "$3" ]; then
            parsePacket "$od_buffer"
      # else
      #      echo >> "$3" #append newline | 0xa
        fi

       EXITCODE_SENDPACKETNC=$?
    fi

    unset ncUDPOpt ncIdleOpt port host timeout_udp_broadcast useTimeout timeout_nc od_buffer cmdstr nccmdstr odcmdstr  rxpipecmd txpipecmd

    return $EXITCODE_SENDPACKETNC
}

newPacket()
# creates new packet
# $1 command 
# set: PACKET_TX_CMD
# set: PACKET_TX_PREAMLE="255 255"
{
    if [ -z "$1" ]; then
        echo >&2 Error: no command given to newPacket
        dumpstack #works in Bash
        return 1
    fi

    PACKET_TX_CMD=$(($1))
    getCommandName "$PACKET_TX_CMD"

    PACKET_TX_PREAMBLE="255 255"
    unset PACKET_TX PACKET_TX_LENGTH PACKET_TX_ESCAPE PACKET_TX_BODY PACKET_TX_BODY_LENGTH

    [ $DEBUG_PACKET -eq 1 ] && echo >&2 newPacket command "$1" "$COMMAND_NAME"
   #set | grep PACKET
}

getPacketLength()
# get length of tx packet buffer, set VALUE_LENGTH
# $1 string of uint8 integers with space
{
    IFS=' '
    VALUE_LENGTH=0
    for BYTE in $1; do
      VALUE_LENGTH=$(( VALUE_LENGTH + 1 ))
    done
    unset BYTE
}

checksum()
# calculates checksum, start at command byte, set VALUE_CHECKSUM
# $1 buffer
 {
    sum=0

   # [ "$DEBUG_PACKET" -eq 1 ] && >&2 echo  "checksum: $1"
    
    IFS=" "
    for BYTE in $1; do
       # [ "$DEBUG_PACKET" -eq 1 ] && >&2 echo  "checksum byte $BYTE, sum $sum"
        sum=$(( (sum + BYTE) & 255 ))
    done

    [ "$DEBUG_PACKET" -eq 1 ] &&  >&2  echo "checksum dec:$sum hex: $(printf "%2x" $sum)"

    VALUE_CHECKSUM=$sum

     unset sum BYTE
}

checksumPacketTX()
# calculates packet chekcum and set final packet tx
# $1 command
# set PACKET_TX
 {

    [ "$DEBUG_PACKET" -eq 1 ] && echo >&2 "checksumPacketTX: START command: $1 PACKET_TX $PACKET_TX PACKET_TX_BODY $PACKET_TX_BODY"

    getPacketLength "$PACKET_TX_BODY"
    PACKET_TX_BODY_LENGTH=$((VALUE_LENGTH + 2)) # at least 2 byte for (length + checksum bytes)
    
    if [ "$PACKET_TX_CMD" -eq "$CMD_BROADCAST" ] || [ "$PACKET_TX_CMD" -eq "$CMD_WRITE_SSID" ]; then # 2 byte length 
        PACKET_TX_BODY_LENGTH=$(( PACKET_TX_BODY_LENGTH + 1 ))
        PACKET_TX_LENGTH=" $(( ((PACKET_TX_BODY_LENGTH + 1) & 0xff00) >> 8 )) $(( (PACKET_TX_BODY_LENGTH + 1) & 0xff ))"
    else
        PACKET_TX_LENGTH=$((PACKET_TX_BODY_LENGTH + 1)) # add 1 byte for command
    fi

    if [ -n "$PACKET_TX_BODY" ]; then
        PACKET_TX_BODY="$PACKET_TX_CMD $PACKET_TX_LENGTH $PACKET_TX_BODY"

    else
        PACKET_TX_BODY="$PACKET_TX_CMD $PACKET_TX_LENGTH"
    fi

    checksum "$PACKET_TX_BODY"

    PACKET_TX_BODY="$PACKET_TX_BODY $VALUE_CHECKSUM"
    PACKET_TX="$PACKET_TX_PREAMBLE $PACKET_TX_BODY" #ff ff ...

    [ "$DEBUG_PACKET" -eq 1 ] && echo >&2 "checksumPacketTX: END PACKET_TX $PACKET_TX PACKET_TX_BODY $PACKET_TX_BODY"
}

createPacketTX()
# creates checksum for packet, converts PACKET_TX from decimal to octal
# $1 command
# set PACKET_TX_ESCAPE
{
    checksumPacketTX "$1"
    convertBufferFromDecToOctalEscape "$PACKET_TX" # \0377 \0377 \0nnn
    PACKET_TX_ESCAPE=$VALUE_OCTAL_BUFFER_ESCAPE
}

newCustomizedPacket()
# creates a new customized packet
 {
    newPacket       "$CMD_WRITE_CUSTOMIZED"
    writeString     PACKET_TX_BODY "$GW_WS_CUSTOMIZED_ID" "customized id"
    writeString     PACKET_TX_BODY "$GW_WS_CUSTOMIZED_PASSWORD" "customized password"
    writeString     PACKET_TX_BODY "$GW_WS_CUSTOMIZED_SERVER" "customized server"
    writeUInt16BE   PACKET_TX_BODY "$GW_WS_CUSTOMIZED_PORT" "customized port"
    writeUInt16BE   PACKET_TX_BODY "$GW_WS_CUSTOMIZED_INTERVAL" "customized interval"
    writeUInt8      PACKET_TX_BODY "$GW_WS_CUSTOMIZED_HTTP" "customized http"
    writeUInt8      PACKET_TX_BODY "$GW_WS_CUSTOMIZED_ENABLED" "customized enabled"
}

newPathPacket()
# creates a new path packet
{
    newPacket "$CMD_WRITE_PATH"
    writeString PACKET_TX_BODY "$GW_WS_CUSTOMIZED_PATH_ECOWITT" "customized path ecowitt"
    writeString PACKET_TX_BODY "$GW_WS_CUSTOMIZED_PATH_WU" "customized path wunderground"
}

newWIFIpacket()
# creates a new wifi packet with ssid and password
#$1 SSID, $2 password
{
    [ "$DEBUG_PACKET" -eq 1 ] && echo >&2 "newWIFIpacket SSID $1 Password $2"
    newPacket "$CMD_WRITE_SSID"
    #ssid packet has two byte length
    # TEST wsview android app, wireshark: ffff | 11 |001b| 
    #WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/Fragment/ConfigrouterFragment.java - SaveData
    writeString PACKET_TX_BODY "$1"  ssid
    writeString PACKET_TX_BODY "$2"  password
}

sendSystemPacket() 
# send system settings to host
# $1 systemtype, $2 tz index, $3 dst bit, $4 autooff bit, $5 host
{
    dst=0

    #autooff 0->auto 1
    #autooff 1->auto 0

    if [ "$4" -eq 0 ]; then
        dst=$(($3 | 2))
    else
        dst=$(($3))
    fi

    newPacket "$CMD_WRITE_SYSTEM"

    writeUInt8 PACKET_TX_BODY    0    frequency   # frequency - only read
    writeUInt8 PACKET_TX_BODY    "$1" sensortype   # sensortype 0=WH24, 1=WH65
    writeUInt32BE PACKET_TX_BODY  0   utctime    # UTC time - only read
    writeUInt8 PACKET_TX_BODY   "$2"  timezoneindex  # timezone index/manual -> not updated by setting auto timezone
    writeUInt8 PACKET_TX_BODY  "$dst" daylightsaving # daylight saving - dst
    
    unset dst

    [ "$DEBUG_PACKET" -eq 1 ] && echo >&2 Send system sensortye "$1" tz "$2" dst "$3"

    sendPacket "$CMD_WRITE_SYSTEM" "$5"

    return "$EXITCODE_SENDPACKET"
}

sendRaindata()
# send rain data to host
# $1 rainday, $2 rain week, $3 rain month, $4 rain year, $5 host ip
 {
   
    newPacket "$CMD_WRITE_RAINDATA"

    writeUInt32BE PACKET_TX_BODY "$1" rainday
    writeUInt32BE PACKET_TX_BODY "$2" rainweek
    writeUInt32BE PACKET_TX_BODY "$3" rainmonth
    writeUInt32BE PACKET_TX_BODY "$4" rainyear

    [ "$DEBUG_PACKET" -eq 1 ] && echo >&2 rainday "$2" rainweek "$3" rainmonth "$4" rainyear "$5"

    sendPacket "$CMD_WRITE_RAINDATA" "$5"
   
   return "$EXITCODE_SENDPACKET"
}

sendCalibration()
# send calibration offsets to host
# $1 intempoffset, $2 inhumidityoffset, $3 absoffset, $4 reloffset, $5 outtempoffset, $6 outhumidityoffset, $7 winddiroffset, $8
 {
    
    newPacket "$CMD_WRITE_CALIBRATION"

    writeInt16BE    PACKET_TX_BODY  "$1" intempoffset
    writeInt8       PACKET_TX_BODY "$2" inhumidityoffset 
    writeInt32BE    PACKET_TX_BODY "$3" absoffset
    writeInt32BE    PACKET_TX_BODY "$4" reloffset
    writeInt16BE    PACKET_TX_BODY "$5" outtempoffset
    writeInt8       PACKET_TX_BODY "$6" outhumidityoffset
    writeInt16BE    PACKET_TX_BODY "$7" winddiroffset

    [ "$DEBUG_PACKET" -eq 1 ] && echo >&2 "Sending calibration intemp $1 inhumi $2 abspressure $3 relpressure $4 outtemp $5 outhumi $6 winddirection $7"
    
    sendPacket "$CMD_WRITE_CALIBRATION" "$8"
    

    return "$EXITCODE_SENDPACKET"
}

sendEcowittInterval()
# send ecowitt interval to host
# $1 interval 0-5, $2 host
{
    newPacket "$CMD_WRITE_ECOWITT_INTERVAL"
    writeUInt8 PACKET_TX_BODY "$1" interval #interval
    [ "$DEBUG_PACKET" -eq 1 ] && echo >&2 Sending ecowitt interval "$1"
    sendPacket "$CMD_WRITE_ECOWITT_INTERVAL" "$2"
}

sendWeatherservice() 
# send id and password to weatherservice (wow/weathercloud/wunderground)
# $1 command, $2 id, $3 password
{
    DEBUG_SENDWEATHERSERVICE=${DEBUG_SENDWEATHERSERVICE:=$DEBUG_PACKET}

    newPacket "$1"
    writeString PACKET_TX_BODY "$2" id
    writeString PACKET_TX_BODY "$3" password

    case "$1" in
        "$CMD_WRITE_WOW")
            writeUInt8 PACKET_TX_BODY 0 unused # stationnum size - unused
            ;;
    esac

    writeUInt8 PACKET_TX_BODY 1 fixed    # fixed 1 value

    
    [ "$DEBUG_SENDWEATHERSERVICE" -eq 1 ] && echo >&2 "Sending weather service command: $1 id: $2 length: ${#2} password: $3 length: ${#3}"

    sendPacket "$1" "$GW_HOST"
}

sendCustomized()
# send customized packet to host
# $1 host

 {
     EXITCODE_SENDCUSTOMIZED=0

    newCustomizedPacket
    sendPacket "$CMD_WRITE_CUSTOMIZED" "$1"
    EXITCODE_SENDCUSTOMIZED=$?

    if isGWdevice "$GW_VERSION" &&  [ "$GW_VERSION_INT" -ge "$FW_CMD_READ_PATH" ]; then
        sendpathpacket=1
    elif ! isGWdevice "$GW_VERSION"; then
        sendpathpacket=1
    else
        sendpathpacket=0
    fi

    if [ $sendpathpacket -eq 1 ]; then
        newPathPacket
        sendPacket "$CMD_WRITE_PATH" "$1"
        EXITCODE_SENDCUSTOMIZED=$?
    fi

    unset sendpathpacket

    return $EXITCODE_SENDCUSTOMIZED
}

sendSensorId()
# send sensor id for sensortype range
# $1 low sensortype, $2 high sensortype, $3 sensorid, $4 host
{

    newPacket "$CMD_WRITE_SENSOR_ID"

    if [ -z "$2" ]; then
     [ "$DEBUG_PACKET" -eq 1 ] && printf >&2 "Writing sensor type %2d sensorid %x\n" "$1" "$3"
      writeUInt8 PACKET_TX_BODY "$1" sensortype
      writeUInt32BE PACKET_TX_BODY"$3" sensorid
    else
      n="$1"
      while [ "$n" -le "$2" ]; do
        [ "$DEBUG_PACKET" -eq 1 ] && printf >&2  "Writing sensor type %2d sensorid %x\n" "$n" "$3"
         writeUInt8 PACKET_TX_BODY "$n" sensortype
         writeUInt32BE PACKET_TX_BODY "$3" sensorid
         n=$(( n + 1 ))
      done
    fi

    unset n

    sendPacket "$CMD_WRITE_SENSOR_ID" "$4"
}

discovery() {
    if [ -n "$NC_VERSION" ]; then
        discovery_nc "$@"
    else
        echo >&2 Error nc not found, cannot scan for devices
    fi
}

discovery_udp_subnet() { #$1 - subnet, for example 192.168.3
    #issue: nc fails to read when sending to subnet broadcast address 192.168.3.255
    #host reply with ICMP host/port unreachable or broadcast response
    #send broadcast cmd to port 46000
    #some host responses take a long time > 175ms, but most take only 4-8ms, so -s subnet should be run multiple times to get all hosts on the subnet
    #wireshark filter: ip.addr == 192.168.3.80 || ip.addr == 192.168.3.49 || ip.addr == 192.168.3.204
    #wireshark: Time field: "Delta time displayed"
    #testing environment: vEthernet WSL adapter/ubuntu, Windows 11, Realtek RTL8852AE WiFi 6 802.11ax PCIe, Huawei AX mesh router 5Ghz channel 36,WPA2
    
    EXITCODE_DISCOVERY=0

    case $1 in
        *.*.*) 
                subnet_valid=1
                ;;
            *)
                subnet_valid=0 
                ;;
    esac

   if [ $subnet_valid -eq 0 ]; then
        echo >&2 "Error: Invalid subnet address, use ddd.ddd.ddd"
        EXITCODE_DISCOVERY=$ERROR_INVALID_SUBNET
        return "$ERROR_INVALID_SUBNET"
   fi
    
    hostnumber=1
    while [ "$hostnumber" -le 254 ]; do
        #[ $DEBUG_PACKET -eq 1 ] && 
        printf >&2 "\r%s " "$1.$hostnumber"
        sendPacket "$CMD_BROADCAST" "$1.$hostnumber" 
        hostnumber=$((hostnumber + 1))
    done

    unset hostnumber

    return "$EXITCODE_DISCOVERY"
}

discovery_nc() { #$1 - subnet for udp scan

    scan_max_iterations=10
    scan_nc_idle_timeout=0.005 # 5ms

    case "$KSH_VERSION" in
        *Android*)
            echo >&2 "Error: UDP scanning for devices not supported ( -u -l options ), nc version $NC_VERSION"
            # udp -u -l option gives 1 error code and 'nc: listen' output
            return "$ERROR_NC_UDP_SCAN_UNAVAILABLE"
            ;;
    esac

    if [ -z "$1" ]; then # set up server on 59387 port

        if [ "$NC_VERSION" = "$NC_NMAP" ]; then
            scan_max_iterations=30
            SCAN_NC_TIMEOUT=0.1
        fi

        if scan_result=$(
            n=0
            while [ $n -lt $scan_max_iterations ]; do
                if [ "$NC_VERSION" = "$NC_NMAP" ]; then
                    $NC_CMD -4 -u -i $scan_nc_idle_timeout -l "$PORT_CLIENT_UDP" 2>/dev/null | od -A n -w64 -t x1
                else
                    timeout $SCAN_NC_TIMEOUT "$NC_CMD" -4 -u -l "$PORT_CLIENT_UDP" 2>/dev/null | od -A n -w64 -t x1
                fi
                n=$((n + 1))
            done | sort -u
        ); then #"A Brief POSIX Advocacy: Shell Script Portability" https://www.usenix.org/system/files/login/articles/login_spring16_09_tomei.pdf

            if [ -n "$scan_result" ]; then
                IFS=$(printf "\n\b") # #https://stackoverflow.com/questions/16831429/when-setting-ifs-to-split-on-newlines-why-is-it-necessary-to-include-a-backspac
                for broadcast in $scan_result; do
                    parse_od_hex_packet "$broadcast"
                done
            fi
        else
            echo >&2 Error failed to obtain scan result while listening on UDP port "$PORT_CLIENT_UDP", error code $?
        fi
    else
        discovery_udp_subnet "$1"
    fi

    unset scan_max_iterations scan_nc_idle_timeout n broadcast

    return "$EXITCODE_DISCOVERY"
}