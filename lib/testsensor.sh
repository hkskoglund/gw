#!/bin/sh
#simulate sensors
injectWH45_CO2Livedata()
{
    #spec. p 8/32 FOS-ENG-022-A
    LIVEDATA_CO2_TEMPF="20.1" #propably farenheit? -> converting necessary
    LIVEDATA_CO2_HUMI=40
    LIVEDATA_CO2_PM10=37
    LIVEDATA_CO2_PM10_24HAVG=38
    LIVEDATA_CO2_PM25_INTS10=410
    LIVEDATA_CO2_PM25=41
    LIVEDATA_CO2_PM25_24HAVG_INTS10=360
    LIVEDATA_CO2_PM25_24HAVG=36
    LIVEDATA_CO2_CO2=999
    LIVEDATA_CO2_CO2_24HAVG=1000
    setBatteryLevel "CO2" 4
    setLivedataSignal "CO2" 4

}

injectWH57_LightningLivedata()
{
    LIVEDATA_LIGHTNING_DISTANCE=30
    LIVEDATA_LIGHTNING_POWER=1004
    LIVEDATA_LIGHTNING_TIME=1638531935
    getDateUTC "$LIVEDATA_LIGHTNING_TIME"
    LIVEDATA_LIGHTNING_TIME_UTC=$VALUE_DATE_UTC
    setBatteryLevel "LIGHTNING" 1
    setLivedataSignal "LIGHTNING" 4
}


injectWH35_LeafwetnessLivedata()
{
    #shellcheck disable=SC2034
    LIVEDATA_LEAFWETNESS1=47
    setBatteryVoltageLevel "LEAFWETNESS1" 14
    setLivedataSignal "LEAFWETNESS1" 4
}

inject_TF_USR()
{
    convertTemperatureLivedata "235"
    #shellcheck disable=SC2034
    LIVEDATA_TF_USR1="$VALUE_SCALE10_FLOAT"
    setBatteryVoltageLevel "TF_USR1" 14
    setLivedataSignal "TF_USR1" 4
}

injectSoiltempLivedata()
{
    #LIVEDATA_SOILTEMP
    :
    convertTemperatureLivedata "235"
    #shellcheck disable=SC2034
    LIVEDATA_SOILTEMP1="$VALUE_SCALE10_FLOAT"
    setBatteryVoltageLevel "SOILTEMP1" 14
    setLivedataSignal "SOILTEMP1" 4
}

injectWH32TemperatureLivedata()
{
    LIVEDATA_OUTTEMP_INTS10=235
    convertTemperatureLivedata "$LIVEDATA_OUTTEMP_INTS10"
    LIVEDATA_OUTTEMP="$VALUE_SCALE10_FLOAT"
    LIVEDATA_OUTHUMI=45
    setBatteryLowNormal "OUTTEMP" "$BATTERY_NORMAL"
    setLivedataSignal "OUTTEMP" 4
}

injectWH40RainfallLivedata()
{
    setBatteryLowNormal "RAINFALL" 0
    setLivedataSignal "RAINFALL" 4
}

injectTestSensorLivedata()
{
    injectWH45_CO2Livedata
    injectWH57_LightningLivedata
    injectWH35_LeafwetnessLivedata
    inject_TF_USR # what is this, extra temp sensors?
    injectSoiltempLivedata
    injectWH32TemperatureLivedata
    injectWH40RainfallLivedata
    :
}