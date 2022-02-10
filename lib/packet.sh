#!/bin/sh

newPacketBody() {
    if [ -z "$1" ]; then
        echo >&2 Error no command given to newPacketBody
        dumpstack #works in Bash
        return 1
    fi

    PACKET_TX_CMD=$(($1))
    getCommandName "$PACKET_TX_CMD"

    PACKET_TX_PREAMBLE="255 255"
    unset PACKET_TX_BODY
}

getPacketLength()
#get length of tx packet buffer
#$1 string of uint8 integers with space
{
    IFS=' '
    VALUE_LENGTH=0
    for BYTE in $1; do
      VALUE_LENGTH=$(( VALUE_LENGTH + 1 ))
    done
    unset BYTE
}

checksumPacketTX() {
    getPacketLength "$PACKET_TX_BODY"
    PACKET_TX_BODY_LENGTH=$((VALUE_LENGTH + 2)) # at least 2 byte for length + checksum bytes

    if [ "$PACKET_TX_CMD" -eq "$CMD_BROADCAST" ] || [ "$PACKET_TX_CMD" -eq $CMD_WRITE_SSID ]; then # 2 byte length 
        PACKET_TX_BODY_LENGTH=$(( PACKET_TX_BODY_LENGTH + 1 ))
        PACKET_TX_LENGTH=" $(( ((PACKET_TX_BODY_LENGTH + 1) & 0xff00) >> 8 )) $(( (PACKET_TX_BODY_LENGTH + 1) & 0xff ))"
    else
        PACKET_TX_LENGTH=$((PACKET_TX_BODY_LENGTH + 1)) # add 1 byte for cmd field
    fi

    if [ -n "$PACKET_TX_BODY" ]; then
        PACKET_TX_BODY="$PACKET_TX_CMD $PACKET_TX_LENGTH $PACKET_TX_BODY"

    else
        PACKET_TX_BODY="$PACKET_TX_CMD $PACKET_TX_LENGTH"
    fi

    checksum "$PACKET_TX_BODY"

    PACKET_TX_BODY="$PACKET_TX_BODY $VALUE_CHECKSUM"
    PACKET_TX="$PACKET_TX_PREAMBLE $PACKET_TX_BODY"

    [ $DEBUG -eq 1 ] && echo >&2 "PACKET_TX $PACKET_TX PACKET_TX_BODY $PACKET_TX_BODY"
}


createPacketTX()
{
    checksumPacketTX
    convertBufferFromDecToOctalEscape "$PACKET_TX" # \0377 \0377 \0nnn

    PACKET_TX_ESCAPE=$VALUE_OCTAL_BUFFER_ESCAPE
}

sendPacket() {
    EXITCODE_SENDPACKET=0

   if ! sendPacketnc "$@"; then # $@ each arg expands to a separate word
      EXITCODE_SENDPACKET=$EXITCODE_SENDPACKETNC
      [ "$DEBUG" -eq 1 ] && echo >&2 "Sendpacket failed with error code $EXITCODE_SENDPACKET"
   fi
    
    return "$EXITCODE_SENDPACKET"
}

sendPacketnc() { #$1 - command
    EXITCODE_SENDPACKETNC=0
    DEBUG_SENDPACKETNC=${DEBUG_SENDPACKETNC:=$DEBUG}
    DEBUG_FUNC='sendPacketnc'

    [ "$DEBUG_SENDPACKETNC" -eq 1 ] && echo >&2 "$DEBUG_FUNC args: $* length: $# 0: $0  1: $1 2: $2"
    
    #$2 - host

    timeout_nc=0.05
    timeout_udp_broadcast=0.236 # timeout selected based on udp port scanning 254 hosts in 60s (60s/254=0.236s)
    useTimeout=0


    #simple command https://stackoverflow.com/questions/6482377/check-existence-of-input-argument-in-a-bash-shell-script
    if [ -n "$1" ]; then 
        newPacketBody "$1"
    else
       echo >&2 "$DEBUG_FUNC Empty command"
       EXITCODE_SENDPACKETNC=$ERROR_EMPTY_COMMAND
       return "$EXITCODE_SENDPACKETNC"
    fi

    if [ -n "$2" ]; then
        host="$2" # for udp broadcast probing on subnet
    else
        host="$C_HOST" # -g option
    fi

    if [ -z "$host" ]; then
      echo >&2 Error: No host specified
      EXITCODE_SENDPACKETNC="$ERROR_NO_HOST_SPECIFIED"
      return $EXITCODE_SENDPACKETNC
    fi

    createPacketTX

    { [ "$DEBUG" -eq 1 ] || [ "$DEBUG_OPTION_OD_BUFFER" ] ; } &&
    {
        printf >&2 "> %-20s" "$COMMAND_NAME"
        printBuffer >&2 "$PACKET_TX"
    }

    unset rxpipecmd txpipecmd

    if [ "$DEBUG_OPTION_TRACEPACKET" -eq 1 ]; then
       #visual studio code: problems with : display for date -> using space
       tracedate=$(date +'%H %M %S %N') #https://superuser.com/questions/674464/print-current-time-with-milliseconds
       rxpipecmd=" | tee \"rx-$COMMAND_NAME-$tracedate.hex\""
       txpipecmd=" | tee \"tx-$COMMAND_NAME-$tracedate.hex\""
    fi

    port=$PORT_GW_TCP

    if [ $PACKET_TX_CMD -eq $CMD_BROADCAST ]; then
        ncUDPOpt='-u' # udp mode
        port=$PORT_GW_UDP
        timeout_nc=$timeout_udp_broadcast
        useTimeout=1
    elif [ "$PACKET_TX_CMD" -eq $CMD_WRITE_RESET ] || [ "$PACKET_TX_CMD" -eq $CMD_WRITE_SSID ]; then
        :
    elif [ "$PACKET_TX_CMD" -eq $CMD_REBOOT ]; then
       useTimeout=1
       timeout_nc=1
       #sometimes result packet from gw is not received, and nc hangs
    fi

    # change between openbsd/nmap ncat in WSL2/ubuntu - sudo update-alternatives --config nc

    odcmdstr="od -A n -t u1 -w$MAX_16BIT_UINT"

    if [ "$NC_VERSION" = $NC_OPENBSD ]; then

        # -N shutdown(2) the network socket after EOF on the input / from man nc - otherwise nc hangs
        nccmdstr="\"$NC_CMD\" -4 -N -w 1 $ncUDPOpt $host $port" 
       
       # if [ "$useTimeout" -eq 1 ]; then
       #    nccmdstr="timeout $timeout_nc $nccmdstr"
       # fi
        
        cmdstr="printf %b \"$PACKET_TX_ESCAPE\" $txpipecmd | $nccmdstr $rxpipecmd | $odcmdstr"

    elif [ "$NC_VERSION" = $NC_NMAP ]; then

        #sleep to disable immediate EOF and shutdown of ncat -> which leads to data not received from udp socket
       
        nccmdstr="\"$NC_CMD\" -4 -w 1  $ncUDPOpt $host $port"
        cmdstr="{ printf %b \"$PACKET_TX_ESCAPE\" $txpipecmd ; sleep $timeout_nc; } |  $nccmdstr $rxpipecmd | $odcmdstr"

    elif [ "$NC_VERSION" = $NC_TOYBOX ]; then

        nccmdstr="$NC_CMD -4 $ncUDPOpt $host $port"
        
        if [ "$useTimeout" -eq 1 ]; then
           nccmdstr="timeout $timeout_nc $nccmdstr"
        fi

        cmdstr="printf %b \"$PACKET_TX_ESCAPE\" $txpipecmd | $nccmdstr $rxpipecmd | $odcmdstr"

    elif [ "$NC_VERSION" = $NC_BUSYBOX ]; then

        nccmdstr="$NC_CMD $host $port"

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
       
       if [ $DEBUG -eq 1 ]; then
            echo >&2 "Sending packet to ip $host port $port"
       fi 

       od_buffer=$(eval "$cmdstr" )
       #maybe use: https://stackoverflow.com/questions/1550933/catching-error-codes-in-a-shell-pipe
       parsePacket "$od_buffer"
       EXITCODE_SENDPACKETNC=$?
    fi

    unset ncUDPOpt ncIdleOpt port host timeout_udp_broadcast useTimeout timeout_nc od_buffer cmdstr nccmdstr odcmdstr  rxpipecmd txpipecmd

    return $EXITCODE_SENDPACKETNC
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
        #[ $DEBUG -eq 1 ] && 
        printf >&2 "\r%s " "$1.$hostnumber"
        sendPacket $CMD_BROADCAST "$1.$hostnumber" 
        hostnumber=$((hostnumber + 1))
    done

    unset hostnumber

    return $EXITCODE_DISCOVERY
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

        if [ "$NC_VERSION" = $NC_NMAP ]; then
            scan_max_iterations=30
            SCAN_NC_TIMEOUT=0.1
        fi

        if scan_result=$(
            n=0
            while [ $n -lt $scan_max_iterations ]; do
                if [ "$NC_VERSION" = $NC_NMAP ]; then
                    $NC_CMD -4 -u -i $scan_nc_idle_timeout -l $PORT_CLIENT_UDP 2>/dev/null | od -A n -w64 -t x1
                else
                    timeout $SCAN_NC_TIMEOUT "$NC_CMD" -4 -u -l $PORT_CLIENT_UDP 2>/dev/null | od -A n -w64 -t x1
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
            echo >&2 Error failed to obtain scan result while listening on UDP port $PORT_CLIENT_UDP, error code $?
        fi
    else
        discovery_udp_subnet "$1"
    fi

    unset scan_max_iterations scan_nc_idle_timeout n broadcast

    return $EXITCODE_DISCOVERY
}

checksum() {
    sum=0

    [ "$DEBUG" -eq 1 ] && >&2 echo  "checksum calculation on $1"
    
    IFS=" "
    for BYTE in $1; do
        [ $DEBUG -eq 1 ] && >&2 echo  "checksum read $BYTE"
        sum=$(( (sum + BYTE) & 255 ))
    done

    [ $DEBUG -eq 1 ] &&  >&2  echo "checksum $sum $(printf "%2x" $sum)"

    VALUE_CHECKSUM=$sum

     unset sum BYTE
}

newCustomizedPacket() {
    newPacketBody $CMD_WRITE_CUSTOMIZED
    writeString "$C_WS_CUSTOMIZED_ID"
    writeString "$C_WS_CUSTOMIZED_PASSWORD"
    writeString "$C_WS_CUSTOMIZED_SERVER"
    writeUInt16BE "$C_WS_CUSTOMIZED_PORT"
    writeUInt16BE "$C_WS_CUSTOMIZED_INTERVAL"
    writeUInt8 "$C_WS_CUSTOMIZED_HTTP"
    writeUInt8 "$C_WS_CUSTOMIZED_ENABLED"
}

newPathPacket() {
    newPacketBody $CMD_WRITE_PATH
    writeString "$C_WS_CUSTOMIZED_PATH_ECOWITT"
    writeString "$C_WS_CUSTOMIZED_PATH_WU"
}

sendSystemPacket() 
#$1 systemtype, $2 tz index, $3 dst bit, $4 autooff bit
{
    dst=0

    #autooff 0->auto 1
    #autooff 1->auto 0

    if [ "$4" -eq 0 ]; then
        dst=$(($3 | 2))
    else
        dst=$(($3))
    fi

    newPacketBody $CMD_WRITE_SYSTEM

    writeUInt8      0       # frequency - only read
    writeUInt8      "$1"    # sensortype 0=WH24, 1=WH65
    writeUInt32BE   0       # UTC time - only read
    writeUInt8      "$2"    # timezone index/manual -> not updated by setting auto timezone
    writeUInt8      "$dst"  # daylight saving - dst
    
    unset dst

    [ $DEBUG -eq 1 ] && echo >&2 Send system sensortye "$1" tz "$2" dst "$3"

    sendPacket

    return "$EXITCODE_SENDPACKET"
}

sendRaindata() {
   
    newPacketBody $CMD_WRITE_RAINDATA

    writeUInt32BE "$1" # rainday
    writeUInt32BE "$2" # rainweek
    writeUInt32BE "$3" # rainmonth
    writeUInt32BE "$4" # rainyear

    [ $DEBUG -eq 1 ] && echo >&2 rainday "$2" rainweek "$3" rainmonth "$4" rainyear "$5"

    sendPacket
   
   return "$EXITCODE_SENDPACKET"
}

sendCalibration() {
    
    newPacketBody $CMD_WRITE_CALIBRATION

    writeInt16BE    "$1" #intempoffset
    writeInt8       "$2" #inhumidityoffset
    writeInt32BE    "$3" #absoffset
    writeInt32BE    "$4" #reloffset
    writeInt16BE    "$5" #outtempoffset
    writeInt8       "$6" #outhumidityoffset
    writeInt16BE    "$7" #winddiroffset

    #[ $DEBUG -eq 1 ] &&
     echo >&2 "Sending calibration intemp $1 inhumi $2 abspressure $3 relpressure $4 outtemp $5 outhumi $6 winddirection $7"
    
    sendPacket
    

    return "$EXITCODE_SENDPACKET"
}

sendEcowittIntervalnew() {
    # observation: GW1000 red-wifi led blinks slowly if not sending data to ecowitt when 0=off
    if [ "$1" -ge 0 ] && [ "$1" -le 5 ]; then
        newPacketBody $CMD_WRITE_ECOWITT_INTERVAL
        writeUInt8 "$1" #interval
        [ $DEBUG -eq 1 ] && echo >&2 Sending ecowitt interval "$1"
        sendPacket
    else
        echo >&2 Error Not a valid ecowitt interval, range 0-5 minutes
    fi
}

sendEcowittInterval() {
    # observation: GW1000 red-wifi led blinks slowly if not sending data to ecowitt when 0=off
    if [ "$1" -ge 0 ] && [ "$1" -le 5 ]; then
        newPacketBody $CMD_WRITE_ECOWITT_INTERVAL
        writeUInt8 "$1" #interval
        [ $DEBUG -eq 1 ] && echo >&2 Sending ecowitt interval "$1"
        sendPacket
    else
        echo >&2 Error Not a valid ecowitt interval, range 0-5 minutes
    fi
}

sendWeatherservice() {

    newPacketBody "$1"
    writeString "$2"
    writeString "$3"

    case "$1" in
    "$CMD_WRITE_WOW")
        writeUInt8 0 # stationnum size - unused
        writeUInt8 1
        ;;

    "$CMD_WRITE_WEATHERCLOUD")
        writeUInt8 1
        ;;
    esac
    [ $DEBUG -eq 1 ] && echo >&2 "Sending weather service $1 id $2 password $3"
    sendPacket
}

sendCustomized() {
    newCustomizedPacket
    sendPacket

    newPathPacket
    sendPacket
}

writeSensorId()
#$1 - low sensortype, $2 - high sensortype, $3 - sensorid
{

    newPacketBody $CMD_WRITE_SENSOR_ID

    if [ -z "$2" ]; then
     [ "$DEBUG" -eq 1 ] && printf >&2 "Writing sensor type %2d sensorid %x\n" "$1" "$3"
      writeUInt8 "$1"
      writeUInt32BE "$3"
    else
      n="$1"
      while [ "$n" -le "$2" ]; do
        [ "$DEBUG" -eq 1 ] && printf >&2  "Writing sensor type %2d sensorid %x\n" "$n" "$3"
         writeUInt8 "$n"
         writeUInt32BE "$3"
         n=$(( n + 1 ))
      done
    fi

    unset n

    sendPacket
}

createWIFIpacket()
#$1 SSID, $2 password
{
    [ $DEBUG -eq 1 ] && echo >&2 "createWIFIpacket SSID $1 Password $2"
    newPacketBody $CMD_WRITE_SSID
    #ssid packet has two byte length
    # TEST wsview android app, wireshark: ffff | 11 |001b| 
    #WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/Fragment/ConfigrouterFragment.java - SaveData
    writeString "$1" # ssid
    writeString "$2" # password
}