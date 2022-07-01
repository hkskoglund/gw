(function _WeatherStation() {


    https://stackoverflow.com/questions/15455009/javascript-call-apply-vs-bind
    if (!Function.prototype.bind)
    {
        console.log('javascript bind not found, creating new Function.prototype.bind,'+window.navigator.userAgent)
        Function.prototype.bind = function(ctx) {
            var fn = this,
                args=Array.prototype.slice.call(arguments,1) // Shallow copy - points to same memory - arguments when creating function with .bind(this,...)
            return function() {
                //https://gist.github.com/MiguelCastillo/38005792d33373f4d08c
                fn.apply(ctx, args.concat(Array.prototype.slice.call(arguments))); // conact to append arguments when calling
            };
        };
    }

    /*function alert()
        {
            return
        } */

    Number.isInteger = Number.isInteger || function(value) {
        return typeof value === 'number' && isFinite(value) && Math.floor(value) === value;
    };

    window.addEventListener('load', function _initui() {
        // console.log('onload event, init ui')
        // console.log('window location',window.location)
        try {
            var ui = new UI()
        } catch (err)
        {
            console.error(JSON.stringify(err))
        }
    })

 function Station(name,id)
 {
    this.name=name
    this.id=id
    this.timestampHHMMSS=''
    this.latestReferencetime=0
 }

 function StationHarstadStation(name,id)
 {
    Station.call(this,name,id)
  
 }

StationHarstadStation.prototype= Object.create(Station.prototype)

function StationVervarslinga(name,id)
{
    Station.call(this,name,id)
}

StationVervarslinga.prototype=Object.create(Station.prototype)
 

function StationGW(name,id)
{
    Station.call(this,name,id)
    this.getJSON=new GetJSONLivedata(window.location.origin+'/api/livedata',GetJSON.prototype.requestInterval.second16)
    this.getJSON.request.addEventListener('load',this.updateStationTimestampLatestChart.bind(this))
    setTimeout(this.getJSON.sendInterval.bind(this.getJSON, GetJSON.prototype.requestInterval.min1), GetJSON.prototype.requestInterval.min5)
}

StationGW.prototype=Object.create(Station.prototype)

StationGW.prototype.updateStationTimestampLatestChart=function()
{
    var timestamp=this.getJSON.timestamp()
    this.timestamp=timestamp
    this.timestampHHMMSS=DateUtil.prototype.getHHMMSS(new Date(timestamp+new Date().getTimezoneOffset()*60000)) // assumes same timezone on GW as local computer
}

function StationWU(name,id)
{
    Station.call(this,name,id)
}

StationWU.prototype=Object.create(Station.prototype)


 function GetJSON(url,interval,options) {
   
    this.url=url
    this.interval=interval
    this.options=options || {}

    this.request=new XMLHttpRequest()
    this.request.addEventListener("load", this.transferComplete.bind(this))
    this.request.addEventListener("error", this.transferError.bind(this))
    this.request.addEventListener("abort",this.transferAbort.bind(this))

    this.sendInterval(interval)

    console.log('GetJSON',this)
 }

GetJSON.prototype.requestInterval={
    hour1:   3600000,
    min15:    900000,
    min10:    600000,
    min5:     300000,
    min1:      60000,
    second16:  16000,
    second5: 5000,
    second1: 1000,
}


 GetJSON.prototype.transferComplete=function(evt)
{
    //console.log('transfer complete',evt)
    if (this.request.responseText.length > 0) {
        //console.log('json:'+this.request.responseText)
        try {
            this.json = JSON.parse(this.request.responseText)
            //console.dir(this.json, { depth: null })

            this.parse()
        } catch (err)
        {
            console.error('Failed parsing JSON')
            console.error(JSON.stringify(err))
        }
       
    } else
    {
        console.error("No JSON received " + this.request.status+' '+this.request.statusText)
        delete this.json
    }
}

GetJSON.prototype.transferError=function(evt)
// Chrome: about 2 seconds timeout
{
    console.error('Failed to receive json for '+this.url,evt);
}

GetJSON.prototype.transferAbort = function(ev)
{
    console.warn('request aborted '+JSON.stringify(ev))
}

 GetJSON.prototype.send=function()
{
    this.request.open('GET',this.url)
    this.request.setRequestHeader("Accept","application/json")
    if (this.options.authorization)
        this.request.setRequestHeader("Authorization", this.options.authorization);
    this.request.send()
}

GetJSON.prototype.sendInterval= function(interval)
{
    if (!interval)
      {
          console.error('sendInterval: Refusing to set undefined interval: '+interval)
          return
      }

    // don't send new request if already in progress 
    if (this.request.readyState === XMLHttpRequest.UNSENT || this.request.readyState === XMLHttpRequest.DONE) // unsent or done https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/readyState
       this.send()

    if (this.requestIntervalID != null && this.requestIntervalID != undefined) {
       // console.log('clearing interval id:'+this.requestIntervalID)
        clearInterval(this.requestIntervalID)
    }
    
    this.requestIntervalID=setInterval(this.send.bind(this),interval)
    console.log('Setting new send interval '+this.url+' interval:'+interval+' previous interval: '+this.interval+' id:'+this.requestIntervalID)
    this.interval=interval
}


function GetJSONLivedata(url,interval,options) {
// https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest
// https://stackoverflow.com/questions/1973140/parsing-json-from-xmlhttprequest-responsejson
// https://developer.mozilla.org/en-US/docs/Web/API/setInterval

     GetJSON.call(this,url,interval,options)

}

GetJSONLivedata.prototype= Object.create(GetJSON.prototype)


GetJSONLivedata.prototype.WindnewCompassDirection = {
    WIND_N:      1,
    WIND_NNE:    2,
    WIND_NE:     3,
    WIND_ENE:    4,
    WIND_E:      5,
    WIND_ESE:    6,
    WIND_SE:     7,
    WIND_SSE:    8,
    WIND_S:      9,
    WIND_SSW:   10,
    WIND_SW:    11,
    WIND_WSW:   12,
    WIND_W:     13,
    WIND_WNW:   14,
    WIND_NW:    15,
    WIND_NNW:   16
}

GetJSONLivedata.prototype.Mode = {
    temperature_celcius : 0,
    temperature_farenheit : 1,
    pressure_hpa : 0,
    pressure_inhg : 1,
    rain_mm : 0,
    rain_in : 1,
    wind_mps : 0,
    wind_mph : 1,
    wind_kmh : 2,
    light_lux : 0,
    light_wattm2 : 1
}

GetJSONLivedata.prototype.timestamp=function()
{
    // When gw system setting for time is AUTO=1, this will be in the local timezone
    return this.data.timestamp
}

GetJSONLivedata.prototype.outtempToString=function()
{
    return this.outtemp().toFixed(1)+' '+this.unitTemp()
}

GetJSONLivedata.prototype.outtemp=function()
{
    return this.data.outtemp
}

GetJSONLivedata.prototype.intempToString=function()
{
    return this.intemp().toFixed(1)+' '+this.unitTemp()
}

GetJSONLivedata.prototype.intemp=function()
{
    return this.data.intemp
}

GetJSONLivedata.prototype.inhumidityToString=function()
{
    return this.inhumidity()+' %'
}

GetJSONLivedata.prototype.inhumidity=function()
{
    return this.data.inhumidity
}

GetJSONLivedata.prototype.outhumidityToString=function()
{
    return this.outhumidity()+' %'
}

GetJSONLivedata.prototype.outhumidity=function()
{
    return this.data.outhumidity
}

GetJSONLivedata.prototype.windspeedToString=function()
{
    return this.windspeed().toFixed(1)+' '+this.unitWind()
}
GetJSONLivedata.prototype.windspeed=function()
{
    //https://javascript.info/number
    return this.data.windspeed
}

GetJSONLivedata.prototype.winddailymax=function()
{
    return this.data.winddailymax
}

GetJSONLivedata.prototype.winddailymaxToString=function()
{
    return this.winddailymax().toFixed(1)+' '+this.unitWind()
}

GetJSONLivedata.prototype.windspeed_mps=function()
// highcharts windbarb requires m/s
{
    if (this.mode.wind === this.Mode.wind_mps)
        return this.windspeed()
    else
        console.error('Converter to m/s neccessary for wind mode : '+this.mode.wind)
}

GetJSONLivedata.prototype.windgustspeedToString=function()
{
    return this.windgustspeed().toFixed(1)+' '+this.unitWind()
}

GetJSONLivedata.prototype.windgustspeed=function()
{
    return this.data.windgustspeed
}

GetJSONLivedata.prototype.windgustspeed_mps=function()
// highcharts windbarb requires m/s
{
    if (this.mode.wind === this.Mode.wind_mps)
        return this.windgustspeed()
    else
      console.error('Converter to m/s neccessary for wind mode : '+this.mode.wind)
    
}

GetJSONLivedata.prototype.winddirection=function()
{
    return this.data.winddirection
}

GetJSONLivedata.prototype.windgustspeed_beufort=function()
{
    return this.data.windgustspeed_beufort
}

GetJSONLivedata.prototype.winddirection_compass_value=function()
{
    return this.data.winddirection_compass_value
}

GetJSONLivedata.prototype.winddirection_compass=function()
{
    return  this.data.winddirection_compass + ' ('+this.data.winddirection+this.unit.winddirection+')'
}

GetJSONLivedata.prototype.windgustbeufort_description=function()
{
    return this.data.windgustspeed_beufort_description+' ('+this.data.windgustspeed_beufort+')'
}

GetJSONLivedata.prototype.relbaro= function()
{
    return this.data.relbaro
}

GetJSONLivedata.prototype.absbaro=function()
{
    return this.data.absbaro
}

GetJSONLivedata.prototype.pressureCalibrationToString=function(pressure)
{
    return pressure.toFixed(1)
}

GetJSONLivedata.prototype.pressureToString= function(pressure)
{
    var numdecimals=1

    if (this.mode.pressure === this.Mode.pressure_inhg)
        numdecimals=2

    return pressure.toFixed(numdecimals)+' '+ this.unitPressure()
}

GetJSONLivedata.prototype.solar_lightToString=function()
{
    return this.solar_light().toFixed(1)+' '+this.unitSolarlight()
}

GetJSONLivedata.prototype.solar_light = function()
{
    return this.data.solar_light
}

GetJSONLivedata.prototype.solar_uvToString = function()
{
    return this.solar_uv().toFixed(1)+' '+this.unitSolarUV()
}

GetJSONLivedata.prototype.solar_uv = function()
{
    return this.data.solar_uv
}

GetJSONLivedata.prototype.solar_uvi=function()
{
    return this.data.solar_uvi
}

GetJSONLivedata.prototype.rainrate_description=function()
{
    return this.data.rainrate_description
}

GetJSONLivedata.prototype.rainrateToString=function()
{
    var numdecimals

    if (this.mode.rain === this.Mode.rain_mm)
        numdecimals=1
    else
        numdecimals=2
    
    return this.rainrate().toFixed(numdecimals)+' '+this.unitRainrate()
}

GetJSONLivedata.prototype.rainrate=function()
{
    return this.data.rainrate
}

GetJSONLivedata.prototype.rainevent=function()
{
    return this.data.rainevent
}

GetJSONLivedata.prototype.rainhour=function()
{
    return this.data.rainhour
}

GetJSONLivedata.prototype.rainday=function()
{
    return this.data.rainday
}

GetJSONLivedata.prototype.rainweek=function()
{
    return this.data.rainweek
}

GetJSONLivedata.prototype.rainmonth=function()
{
    return this.data.rainmonth
}

GetJSONLivedata.prototype.rainyear=function()
{
    return this.data.rainyear
}

GetJSONLivedata.prototype.unitRainrate=function()
{
    return this.unit.rainrate
}

GetJSONLivedata.prototype.unitRain=function()
{
    return this.unit.rain
}

GetJSONLivedata.prototype.unitTemp=function()
{
    return this.unit.temperature
}

GetJSONLivedata.prototype.unitWind=function()
{
    return this.unit.wind
}

GetJSONLivedata.prototype.unitSolarlight=function()
{
    return this.unit.solar_light
}

GetJSONLivedata.prototype.solar_uvi_description=function()
{
    return this.data.solar_uvi_description
}

GetJSONLivedata.prototype.unitSolarUV=function()
{
    return this.unit.solar_uv
}

GetJSONLivedata.prototype.unitPressure=function()
{
    return this.unit.pressure
}

GetJSONLivedata.prototype.parse=function()
{
    this.data = this.json.data
    this.unit = this.json.unit
    this.mode = this.json.mode
}

function GetJSONFrostPrecipitation(url,interval,options)
{
    GetJSON.call(this,url,interval,options)
}

GetJSONFrostPrecipitation.prototype= Object.create(GetJSON.prototype)

function WindConverter()
{

}

WindConverter.prototype.fromDegToCompassDirection=function(deg)
{
    // https://www.campbellsci.com/blog/convert-wind-directions
    var direction=["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW","N"]

    return direction[Math.round((deg % 360)/22.5)]
}

WindConverter.prototype.fromKmhToMps=function(kmh)
{
    return kmh*5/18
}

function DateUtil()
{
}

DateUtil.prototype.getHHMMSS=function(date)
{
    
   return ('0'+date.getHours()).slice(-2)+':'+('0'+date.getMinutes()).slice(-2)+':'+('0'+date.getSeconds()).slice(-2) // https://stackoverflow.com/questions/1267283/how-can-i-pad-a-value-with-leading-zeros  
}

function GetJSONWUCurrentConditions(url,interval,options)
{
    GetJSON.call(this,url,interval,options)
}

GetJSONWUCurrentConditions.prototype= Object.create(GetJSON.prototype)

GetJSONWUCurrentConditions.prototype.parse=function()
{
    if (this.json.observations && this.json.observations[0]) {
        this.data=this.json.observations[0]
       // console.log('wu data '+JSON.stringify(this.data))
       console.log('WU',this.data)
    } else
        console.error('Not a WU observation '+JSON.stringify(this.json))
}

GetJSONWUCurrentConditions.prototype.timestamp=function()
{
    // epoch Time in UNIX seconds
    return this.data.epoch*1000
}

GetJSONWUCurrentConditions.prototype.outtemp=function()
{
    return this.data.metric.temp
}

GetJSONWUCurrentConditions.prototype.windchill=function()
{
    return this.data.metric.windChill
}

GetJSONWUCurrentConditions.prototype.outhumidity=function()
{
    return this.data.humidity
}

GetJSONWUCurrentConditions.prototype.wind_speed=function()
{
    return WindConverter.prototype.fromKmhToMps(this.data.metric.windSpeed)
}

GetJSONWUCurrentConditions.prototype.windgust_speed=function()
{
    return WindConverter.prototype.fromKmhToMps(this.data.metric.windGust)
}

GetJSONWUCurrentConditions.prototype.winddirection=function()
{
    return this.data.winddir
}

GetJSONWUCurrentConditions.prototype.relbaro=function()
{
    return this.data.metric.pressure
}

GetJSONWUCurrentConditions.prototype.solar_light=function()
{
    return this.data.solarRadiation
}

GetJSONWUCurrentConditions.prototype.solar_uvi=function()
{
    return this.data.uv
}

GetJSONWUCurrentConditions.prototype.rainrate=function()
{
    return this.data.metric.precipRate
}

function GetJSONHolfuyLive(url,interval,options)
{
    GetJSON.call(this,url,interval,options)
}

GetJSONHolfuyLive.prototype= Object.create(GetJSON.prototype)

function GetJSONFrost(url,interval,options)
{
    GetJSON.call(this,url,interval,options)
}

GetJSONFrost.prototype= Object.create(GetJSON.prototype)

GetJSONFrost.prototype.dateutil=function()
{
 // sources='+sourceId+'&referenceTime='+d1hourago.toISOString()
 /*var  date   = new Date(),
    dateISO = date.toISOString().split('.')[0]+'Z', // 2022-05-19T09:28:59Z https://stackoverflow.com/questions/34053715/how-to-output-date-in-javascript-in-iso-8601-without-milliseconds-and-with-z
    year   = date.getUTCFullYear(),
    month  = date.getUTCMonth(), // zero-based 0=january
    day    = date.getUTCDate(), // day
    hours  = date.getUTCHours(),
    minutes= date.getUTCMinutes(),
    dateISOYYMMDD = year + '-' + (month + 1) + '-' + day,
    dateISOMidnight= new Date(dateISOYYMMDD + ' 00:00'),
    d1hourago=new Date(Date.now()-3600000),
    d1hourafter=new Date(Date.now()+3600000),
    sourceId='SN90450',
    frostapi_url='https://frost.met.no/observations/v0.jsonld', // Webserver does not send Access-Control-Allow-Origin: * -> cannot use in Chrome -> use proxy server?
    //frostapi_url='https://rim.k8s.met.no/api/v1/observations' // Allow CORS -> can use in browser
    latestHourURL='https://frost.met.no/observations/v0.jsonld?elements=air_temperature,surface_snow_thickness,air_pressure_at_sea_level,relative_humidity,max(wind_speed%20PT1H),max(wind_speed_of_gust%20PT1H),wind_from_direction,mean(surface_downwelling_shortwave_flux_in_air%20PT1H)&referencetime=latest&sources=SN90450&timeresolutions=PT1H&timeresolutions=PT0H',
    precipitation_calibration_month_url=frostapi_url+'?sources='+sourceId+'referenceTime=2021-05-01T00:00:00Z/2022-05-31T23:59:59Z&elements=sum(precipitation_amount%20P1M)&timeResolution=months',
    precipitationHourURL=frostapi_url+'?sources='+sourceId+'&referencetime='+dateISOMidnight.toISOString().split('.')[0]+'Z'+'/'+dateISO+'&elements=sum(precipitation_amount%20PT1H)&timeResolution=hours' */
}

GetJSONFrost.prototype.parse=function()
{
    var json=this.json 
   // https://frost.met.no/api.html#!/observations/observations
   if (json['@type'] != 'ObservationResponse' )
   {
       console.error('Not a ObservationResponse type, aborting parsing'+JSON.stringify(json))
       return
   }

   //console.log('JSON'+JSON.stringify(json))

   var item,
        obsNr,
        referenceTime,
        timestamp,
        hhmmss,
        observation,
        elementId,
        unit,
        lastObservation,
        currentStation=0

    this.data= {}

    for (item=0;item<json.totalItemCount;item++) // number of data items
    {
            referenceTime=new Date(json.data[item].referenceTime)
           // console.log('referenceTime '+referenceTime)
           // console.log(JSON.stringify(json.data[item]))
            timestamp=referenceTime.getTime()-referenceTime.getTimezoneOffset()*60000  // local timezone time
            hhmmss=DateUtil.prototype.getHHMMSS(referenceTime)
            if (referenceTime>this.options.stations[currentStation].latestReferencetime) {
                this.options.stations[currentStation].timestampHHMMSS=hhmmss
                this.options.stations[currentStation].latestReferencetime=referenceTime
            }
        
           // console.log('observations '+json.data[item].observations.length)
            for (obsNr=0;obsNr<json.data[item].observations.length;obsNr++)
            {
                observation=json.data[item].observations[obsNr]
                elementId=observation.elementId
             //   console.log(elementId+' '+JSON.stringify(observation))

                unit=observation.unit

                if (unit==='degC')
                    unit='℃'
                else if (unit==='percent')
                    unit='%'
                else if (unit==='degrees')
                    unit='°'
                else if (unit==='W/m2')
                    unit='W/㎡'

                // Query result should have time offset PT0H
                if (observation.timeOffset!=='PT0H')
                    // must add offset to referencetime
                    console.error('Skipping observation for time offset '+observation.timeOffset+' '+JSON.stringify(observation))
                else
                {

                    if (!this.data[elementId])
                        this.data[elementId] = []

                    lastObservation=this.data[elementId].slice(-1)[0]
                    if (!lastObservation || (lastObservation && lastObservation.timestamp !== timestamp)) // dont attempt to add multiple observations with same timestamp, for example PT1H and PT10M at 10:00
                        this.data[elementId].push({
                            timestamp : timestamp,
                            hhmmss : hhmmss,
                            value : observation.value,
                            unit : unit
                        })
                }
            
            }
    }

   console.log('METno',this.data)

}

GetJSONFrost.prototype.getLatestObservation=function(element)
{
    if (!this.data)
    {
        console.warn('JSON frost: No data')
        return
    }
    
    var data=this.data[element]
    if (data)
        return data[data.length-1].value
}

function UI()
{

    var port

    this.measurementCount=0

    this.outtempElement=document.getElementById('outtemp')
    this.intempElement=document.getElementById('intemp')
    this.unitTempElement=document.getElementById('unit_temperature')

    this.absbaroElement=document.getElementById('absbaro')
    this.relbaroElement=document.getElementById('relbaro')
    this.unitpressureElement=document.getElementById('unit_pressure')

    this.windspeedElement=document.getElementById('windspeed')
    this.windgustspeedElement=document.getElementById('windgustspeed')
    this.winddirection_compassElement=document.getElementById('winddirection_compass')
    this.windgustspeed_beufort_descriptionElement=document.getElementById('windgustspeed_beufort_description')
    this.unitWindElement=document.getElementById('unit_wind')

    this.meter_windgustspeedElement=document.getElementById('meter_windgustspeed')

    this.solar_lightElement=document.getElementById('solar_light')
    this.unit_solar_lightElement=document.getElementById('unit_solar_light')
    this.solar_uvElement=document.getElementById('solar_uv')
    this.unit_solar_uvElement=document.getElementById('unitsolar_uv')
    this.solar_uviElement=document.getElementById('solar_uvi')
    
    this.weatherElement=document.getElementById('divWeather')

    var forceLowMemoryDevice=true
    var isLowMemoryDevice=this.isLowMemoryDevice() || forceLowMemoryDevice
    var navigatorIsNorway= navigator.language.toLowerCase().indexOf('nb') !== -1 || this.isLGSmartTV2012()

   
    this.timeoutID={}

    this.restoreHiddenSeries={}  

    this.options={
       // tooltip: !isLowMemoryDevice,              // turn off for ipad1 - slow animation/disappearing
       tooltip: true,
        animation: !isLowMemoryDevice,               // turn off animation for all charts
        rangeSelector: !isLowMemoryDevice,        // keeps memory for series
       // mousetracking: !isLowMemoryDevice,        // allocates memory for duplicate path for tracking
       mousetracking: true,
        forceLowMemoryDevice : forceLowMemoryDevice,        // for testing
        // navigator.languauge is "en-us" for LG Smart TV 2012
        isLGSmartTV2012 : this.isLGSmartTV2012(),
        latestChart : {
            stations: []
        },
      
        frostapi : {
            doc: 'https://frost.met.no/index.html',
            authorization: "Basic " + btoa("2c6cf1d9-b949-4f64-af83-0cb4d881658a:"), // http basic authorization header -> get key from https://frost.met.no/howto.html
            enabled : true && ( navigatorIsNorway || this.isLGSmartTV2012()),    // use REST api from frost.met.no - The Norwegian Meterological Institute CC 4.0  
            stationName: 'Værvarslinga SN90450',
            stationId: 'SN90450',
           // stationName: 'Harstad Stadion',
           // stationId: 'SN87640',
            timestampHHMMSS: '',
            latestReferencetime : 0,
            stations : [
                {
                    stationName: 'Harstad Stadion',
                    stationId: 'SN87640',
                    timestampHHMMSS: '',
                    latestReferencetime : 0, 
                },
                {
                    stationName: 'Værvarslinga',
                    stationId: 'SN90450',
                    timestampHHMMSS: '',
                    latestReferencetime: 0
                }
            ]
        },
        wundergroundapi: {
            doc: 'https://docs.google.com/document/d/1eKCnKXI9xnoMGRRzOL1xPCBihNV2rOet08qpE_gArAY',
            apiKey: '9b606f1b6dde4afba06f1b6dde2afb1a', // get a personal api key from https://www.wunderground.com/member/api-keys
            stationId: 'IENGEN26',
            stationName: 'Engenes',
            //stationId: 'ITOMAS1',
            //stationName: 'Tomasjord',
            interval: GetJSON.prototype.requestInterval.min5,
            enabled : true,
            timestampHHMMSS : '',
        },
        holfuyapi: {
            doc: 'http://api.holfuy.com/live/', // does not support CORS in Chrome/Edge (use curl on backend?), but works in Firefox 100.0.1
            stationId: '101', // Test
            stationName: 'test',
            interval: GetJSON.prototype.requestInterval.hour1,
            enabled: false,
            timestampHHMMSS : ''
        },
        publicwmsmetno: {
            radar_nowcast : {
                enabled : true,
                interval : GetJSON.prototype.requestInterval.min15,
                url: window.location.origin+'/api/radar_nowcast'
            }
        },
        weatherapi: {
            radar: {
                enabled: true && navigatorIsNorway, // should be disabled on metered connection
                interval: GetJSON.prototype.requestInterval.min15,
                doc: 'https://api.met.no/weatherapi/radar/2.0/documentation',
                url_troms_5level_reflectivity:'https://api.met.no/weatherapi/radar/2.0/?area=troms&type=5level_reflectivity&content=image', // ca 173 kB
                url_troms_5level_reflectivity_animation : 'https://api.met.no/weatherapi/radar/2.0/?area=troms&type=5level_reflectivity&content=animation',
               // url_test: 'https://www.yr.no/nb/innhold/1-2296106/meteogram.svg' // ca 14.4 kB
               // url_test_webcam_1 : 'https://www.yr.no/webcams/1/2000/tromso/1.jpg'
            },
            geosatellite: {
                enabled: true,  // should be disabled on metered connection
                interval: GetJSON.prototype.requestInterval.min15,
                doc: 'https://api.met.no/weatherapi/geosatellite/1.4/documentation',
                // test  curl -s -v 'https://api.met.no/weatherapi/geosatellite/1.4/?area=europe' -J -O
                // https://stackoverflow.com/questions/2698552/how-do-i-save-a-file-using-the-response-header-filename-with-curl
                url_europe: 'https://api.met.no/weatherapi/geosatellite/1.4/?area=europe', // ca 835 kB
                url_europe_small: 'https://api.met.no/weatherapi/geosatellite/1.4/?area=europe&size=small'
            },
            polarsatellite: {
                enabled: true,  // should be disabled on metered connection
                interval: GetJSON.prototype.requestInterval.min15,
                doc: 'https://api.met.no/weatherapi/polarsatellite/1.1/documentation',
                url_latest_noaa_rgb_north_europe: 'https://api.met.no/weatherapi/polarsatellite/1.1/?satellite=noaa&channel=rgb&area=ne'
            },
        },
        uvnettapi: {
            enabled: false,
            url : 'https://uvnett.dsa.no/dagsverdigraf_detaljert.aspx?Stasjon=And%u00f8ya&Dato=28/06/2022&Bredde=1024&Hoyde=768&Engelsk=True'
        }
    }

    //this.options.maxPoints=Math.round(this.options.shifttime*60*1000/this.options.interval) // max number of points for requested shifttime

    this.initCharts()

    if (window.location.hostname === '127.0.0.1') // assume web server runs on port 80
        // Visual studio code live preview uses 127.0.0.1:3000
      port=80
    else
      port=window.location.port

    this.initStations(port)
   // this.testMemory()
   
   this.eventHandler={
    scroll : this.onScrollUpdateplotBGImage.bind(this)
}

   // if (this.options.weatherapi.radar.enabled && this.latestChart) 
   //    this.reloadPlotBackgroundImage(this.latestChart,this.options.weatherapi.radar.url_troms_5level_reflectivity,this.options.weatherapi.radar.interval,true)

     if (this.options.publicwmsmetno.radar_nowcast.enabled && this.latestChart)
         this.reloadPlotBackgroundImage(this.latestChart,this.options.publicwmsmetno.radar_nowcast.url,this.options.publicwmsmetno.radar_nowcast.interval,true)

    if (this.options.weatherapi.geosatellite.enabled && this.temperatureChart) 
        this.reloadPlotBackgroundImage(this.temperatureChart,this.options.weatherapi.geosatellite.url_europe,this.options.weatherapi.geosatellite.interval,true)

    if (this.options.weatherapi.polarsatellite.enabled && this.pressureChart) 
        this.reloadPlotBackgroundImage(this.pressureChart,this.options.weatherapi.polarsatellite.url_latest_noaa_rgb_north_europe,this.options.weatherapi.polarsatellite.interval,true)

    document.addEventListener('scroll',this.eventHandler.scroll, { passive: true})
}

window.WeatherStation=UI

UI.prototype.onScrollUpdateplotBGImage=function(event)
{
    this.eventHandler.scrollTimestamp=Date.now()

    for (id in this.options.missedReloadURL)
        this.updatePlotbackgroundImage(this.options.missedReloadURL[id].chart,this.options.missedReloadURL[id].url)

      //  if (this.temperatureChart.plotBGImage && this.latestChart.plotBGImage)
      //    document.removeEventListener('scroll',this.eventHandler.scroll, {passive: true})
}

UI.prototype.updatePlotbackgroundImage=function(chart,url)
{
   var visible=this.isInViewport(chart.plotBackground.element),
       id=chart.renderTo.id

    if (visible)
    {
      console.log('Updating plotbackground '+id+' url '+url)
      chart.update({ chart : { plotBackgroundImage : url }})
      if (this.options.missedReloadURL)
        delete this.options.missedReloadURL[id]
    }
    else
    {
      if (!this.options.missedReloadURL)
        this.options.missedReloadURL={}

      if (!this.options.missedReloadURL[id])
        this.options.missedReloadURL[id]={ chart: chart, url : url, time: Date.now() }
      else
      {
        this.options.missedReloadURL[id].chart=chart
        this.options.missedReloadURL[id].url=url
        this.options.missedReloadURL[id].time=Date.now()
      }

      // console.warn('Reload when visible '+id+' url '+url)
    }

    return visible
}

UI.prototype.reloadPlotBackgroundImage=function(chart,url,interval,bypassBrowserCache)
{
    var id=chart.renderTo.id

    this.updatePlotbackgroundImage(chart,url)

      console.log('setting reload of ' +id+' plotbackgroundimage '+url+' to '+interval)

    this.timeoutID['plotbackgroundimage-'+id]=setInterval(function _reloadPlotBackgroundImage() {  
        // Problem: image not reloaded due to caching; Chrome devtools "disable cache" enabled -> reloads image
        // 15 minute interval: 4*24 = 96 &, 5 minute interval: 3*15min interval = 288 &
        // < server: nginx/1.18.0 (Ubuntu), default buffer size 1KB, should not allocate buffers for empty key=value pairs  http://nginx.org/en/docs/http/ngx_http_core_module.html#client_header_buffer_size
        if (bypassBrowserCache)
          url=url+'&' // add empty key=value, to bypass cache in browser, not optimal but works,use slow interval=1 hour to limit url string length, in theory a "414 URI Too Long" may be generated https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/414
        
          this.updatePlotbackgroundImage(chart,url)
    }.bind(this),interval)
   
}

UI.prototype.isInViewport=function(element) {
// https://www.javascripttutorial.net/dom/css/check-if-an-element-is-visible-in-the-viewport/
    var rect = element.getBoundingClientRect(),
        visible
   // console.log('boundingclientrect '+JSON.stringify(rect))
   // console.log('innerHeight '+window.innerHeight+' innerwidth '+window.innerWidth+' clientHeight '+document.documentElement.clientHeight+' clientWidth '+document.documentElement.clientWidth)
    visible=(
        rect.top >= 0 &&
        rect.left >= 0 &&
        rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
        rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
    
      return visible
}


UI.prototype.testMemory=function()
// Allocates 1MB until memory is exausted and generates LowMemory log on ipad1
// Test LG Smart TV 2012: 262MB before "not enough memory" popup
{
    console.log('typeof Uint8Array: ' + typeof Uint8Array)

    if (typeof Uint8Array !== 'function' && typeof Uint8Array !== 'object')
    {
        console.error('Uint8Array not available')
        return
    } 

    var heap=[]
    var bytes=0
    var Mebibyte=1024*1024 // https://en.wikipedia.org/wiki/Megabyte

    while (true) {
        heap.push(new Uint8Array(Mebibyte))
        bytes+=Mebibyte
        //console.log('Allocated MB'+bytes/Mebibyte)
        alert(bytes/Mebibyte +' MB allocated')
        // Ipad1 : LowMemory-{date}.plist
        //               Count resident pages
        // MobileSafari  37995
        // https://developer.apple.com/library/archive/documentation/Performance/Conceptual/ManagingMemory/Articles/AboutMemory.html
        // "In OS X and in earlier versions of iOS, the size of a page is 4 kilobytes. "
        // Total Memory usage: 4096 bytes/page*37995 page=155463680 bytes
        // Test: able to allocate 113 MB
        // https://en.wikipedia.org/wiki/IPad_(1st_generation)
        // Memory : 256 GB
    }
}

UI.prototype.addStation=function(station)
{
    if (station instanceof StationGW) {
        station.getJSON.request.addEventListener("load",this.onJSONLivedata.bind(this,station))
        station.getJSON.request.addEventListener("load",this.onJSONLatestChart.bind(this,station))
        station.getJSON.request.addEventListener("load",this.onJSONTemperatureChart.bind(this,station))
        station.getJSON.request.addEventListener("load",this.onJSONWindbarbChart.bind(this,station))
        station.getJSON.request.addEventListener("load",this.onJSONWindroseChart.bind(this,station))
        station.getJSON.request.addEventListener("load",this.onJSONSolarChart.bind(this,station))
        station.getJSON.request.addEventListener("load",this.onJSONRainchart.bind(this,station))
        station.getJSON.request.addEventListener("load",this.onJSONRainstatChart.bind(this,station))
        station.getJSON.request.addEventListener("load",this.onJSONPressureChart.bind(this,station))
    }

    station.getJSON.request.addEventListener("load",this.redrawCharts.bind(this))
    this.options.latestChart.stations.push(station)
}

UI.prototype.initStations=function(port)
{

    this.addStation(new StationGW('Tomasjord','ITOMAS1'))

    /*
    if (this.options.frostapi.enabled) {
        this.getJSONFrostLatest15Min = new GetJSONFrost(window.location.origin+'/api/frost.met.no/latest',GetJSON.prototype.requestInterval.min15,this.options.frostapi)
        this.getJSONFrostLatest15Min.request.addEventListener("load",this.onJSONFrost.bind(this,this.getJSONFrostLatest15Min))
        this.getJSONFrostLatest15Min.request.addEventListener("load",this.redrawCharts.bind(this))

       // this.getJSONFrostLatest1H = new GetJSONFrost(window.location.origin+'/api/frost.met.no/latest-1H',GetJSON.prototype.requestInterval.hour1,this.options.frostapi)
       // this.getJSONFrostLatest1H.request.addEventListener("load",this.onJSONFrost.bind(this,this.getJSONFrostLatest1H))
       // this.getJSONFrostLatest1H.request.addEventListener("load",this.onJSONloadredrawCharts.bind(this))

    }

    if (this.options.wundergroundapi.enabled) {
        var wu=this.options.wundergroundapi
        this.getJSONWUCurrentConditions = new GetJSONWUCurrentConditions('https://api.weather.com/v2/pws/observations/current?apiKey='+wu.apiKey+'&stationId='+wu.id+'&numericPrecision=decimal&format=json&units=m',this.options.wundergroundapi.interval,this.options.wundergroundapi)
        this.getJSONWUCurrentConditions.request.addEventListener("load",this.onJSONWUCurrentConditions.bind(this,this.getJSONWUCurrentConditions))
        this.getJSONWUCurrentConditions.request.addEventListener("load",this.redrawCharts.bind(this))

    }

    if (this.options.holfuyapi.enabled)
    {
        var holfuyapi=this.options.holfuyapi
        // https://holfuy.com/puget/mjso.php?k=299 - has wind_chill temperature
        //this.getJSONHolfuyLive = new GetJSONHolfuyLive('http://api.holfuy.com/live/?s='+holfuyapi.id+'&m=JSON&tu=C&su=m/s',holfuyapi.interval,this.options)
        this.getJSONHolfuyLive.request.addEventListener("load",this.onJSONHolfuyLive.bind(this))

    } 
    */
    
}

UI.prototype.onJSONHolfuyLive=function(evt)
{
    console.log('holfuy',evt)
}

UI.prototype.addObservationsMETno=function(data)
{
    var series,
        observation,
        obsNr,
        elementId,
        lastSeriesData

    for (elementId in data) 
    {
        switch (elementId)
        {
            case 'air_pressure_at_sea_level' :

                if (this.pressureChart)
                    series = this.pressureChart.get('series-metno-air_pressure_at_sea_level')
                break
            
            case 'air_temperature' :

                if (this.temperatureChart) {
                    series=this.temperatureChart.get('series-metno-temperature10min')
                }

                break
            
            case 'relative_humidity' :
                
                if (this.temperatureChart)
                    series=this.temperatureChart.get('series-metno-humidity1h')
                break

            case 'wind_speed' :

                if (this.windbarbchart)
                    series=this.windbarbchart.get('series-metno-windmean10min')
                break

         /*   case 'max(wind_speed PT1H)':

                if (this.windbarbchart)
                    series=this.windbarbchart.series[3]
                break */
                
            // Multi-criteria case https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/switch
            case 'max(wind_speed_of_gust PT1H)':
            case 'max(wind_speed_of_gust PT10M)':

                if (this.windbarbchart)
                    series=this.windbarbchart.get('series-metno-windgustmax10min')
                break

            case 'mean(surface_downwelling_shortwave_flux_in_air PT1H)' :
            case 'mean(surface_downwelling_shortwave_flux_in_air PT1M)' :
                
                if (this.solarchart)
                    series=this.solarchart.get('series-metno-irradiance-mean1m')
                break

            default : 
                
                console.warn('METno elementId '+elementId+' no series found in chart')
                continue
                
        }

        if (!series) {
            console.warn('Unable to get series for '+elementId)
            continue
        }
            
        lastSeriesData=series.options.data[series.options.data.length-1]
        data[elementId].forEach(function _addObservation(observation) {
            if (!lastSeriesData || (lastSeriesData[0]!==observation.timestamp)) {
                    console.log('addpoint',series.name,[observation.timestamp,observation.value])
                    series.addPoint([observation.timestamp,observation.value],false,this.options.shift,this.options.animation,false)
            }
                else
                console.warn(elementId+' Skippping observation already is series; timestamp '+observation.timestamp+' value '+observation.value,series) // same value of relative_humidity and air_pressure_at_at_sea_level each 1h is included each 10m in JSON

            }.bind(this))

        series=undefined
    }
}

UI.prototype.updateFrostLatestChart=function(METnoRequest)
{
    var redraw=false,
        animation=this.options.animation,
        currentStation=0

    if (this.latestChart)
    {
        var stationCategoryIndex=this.options.frostapi.stations[currentStation].stationCategoryIndex // METno

        this.updateStationTimestampLatestChart()

        var outtemp=METnoRequest.getLatestObservation('air_temperature')
        if (outtemp)
        {
            this.latestChart.get('series-temperature').options.data[stationCategoryIndex]=outtemp
        }

        var humidity=METnoRequest.getLatestObservation('relative_humidity')

        if (humidity)
            this.latestChart.get('series-humidity').options.data[stationCategoryIndex]=humidity
        
        var windspeed=METnoRequest.getLatestObservation('wind_speed')

        if (windspeed)
            this.latestChart.get('series-windspeed').options.data[stationCategoryIndex]=windspeed
    
        var windgust=METnoRequest.getLatestObservation('max(wind_speed_of_gust PT10M)')
        
        if (windgust)
            this.latestChart.get('series-windgust').options.data[stationCategoryIndex]=windgust

        var winddirection=METnoRequest.getLatestObservation('wind_from_direction')
        
        if (winddirection)
            this.latestChart.get('series-winddirection').options.data[stationCategoryIndex]=winddirection

        var relbaro=METnoRequest.getLatestObservation('air_pressure_at_sea_level')

        if (relbaro)
            this.latestChart.get('series-relbaro').options.data[stationCategoryIndex]=relbaro
        
         var irradiance=METnoRequest.getLatestObservation("mean(surface_downwelling_shortwave_flux_in_air PT1M)")

        if (irradiance)
            this.latestChart.get('series-irradiance').options.data[stationCategoryIndex]=irradiance
        
        this.latestChart.series.forEach(function (series) {
            series.setData(series.options.data,redraw,animation)
        })

    } 
}

UI.prototype.onJSONFrost=function(jsonReq,evt)
{
   this.addObservationsMETno(jsonReq.data)
   this.updateFrostLatestChart(jsonReq)
}

UI.prototype.onJSONFrostPrecipitationHour=function(evt)
{
    var json=this.getJSON.jsonFrostPrecipitationHour
    //console.log('ui got',json)
    var precipitationDay=0
    json.data.forEach(function (data) { precipitationDay=precipitationDay+data.observations[0].value})
    var precipitationHour=json.data[json.data.length-1].observations[0].value
    //console.log('precipitation today: '+ precipitationDay+' precip. hour: '+precipitationHour)
    this.rainstatchart.series[2].setData([['hour',precipitationHour],['day',precipitationDay],null,null,null],false,this.options.animation)
}

UI.prototype.onJSONWUCurrentConditions=function(jsonReq,evt)
// candidate for refactoring into one function with updateCharts/onJSONLivedata
{
    var redraw=false,
        animation=this.options.animation
        stationCategoryIndex=this.options.wundergroundapi.stationCategoryIndex // Wunderground

    this.options.wundergroundapi.timestampHHMMSS=DateUtil.prototype.getHHMMSS(new Date(jsonReq.timestamp()))

    //console.log('wu cc',evt,this)
    if (this.latestChart)
    {
        this.latestChart.get('series-temperature').options.data[stationCategoryIndex]=jsonReq.outtemp()
        this.latestChart.get('series-windchill').options.data[stationCategoryIndex]=jsonReq.windchill()
        this.latestChart.get('series-humidity').options.data[stationCategoryIndex]=jsonReq.outhumidity()
        this.latestChart.get('series-windspeed').options.data[stationCategoryIndex]=jsonReq.wind_speed()
        this.latestChart.get('series-windgust').options.data[stationCategoryIndex]=jsonReq.windgust_speed()
        this.latestChart.get('series-winddirection').options.data[stationCategoryIndex]=jsonReq.winddirection()
        this.latestChart.get('series-relbaro').options.data[stationCategoryIndex]=jsonReq.relbaro()
        this.latestChart.get('series-irradiance').options.data[stationCategoryIndex]=jsonReq.solar_light()
        this.latestChart.get('series-UVI').options.data[stationCategoryIndex]=jsonReq.solar_uvi()
        this.latestChart.get('series-rainrate').options.data[stationCategoryIndex]=jsonReq.rainrate()        

        this.latestChart.series.forEach(function (series) {
            series.setData(series.options.data,redraw,animation)
        })
    }
}

UI.prototype.isLowMemoryDevice=function()
{
    return this.isIpad1() || this.isLGSmartTV2012()
}

UI.prototype.isIpad1=function()
{
   // "Mozilla/5.0 (iPad; CPU OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B206 Safari/7534.48.3"
   return navigator.userAgent.indexOf("iPad; CPU OS 5_1_1 like Mac OS X")!==-1
}

UI.prototype.isLGSmartTV2012=function()
{
    // https://www.lg.com/se/support/manuals?csSalesCode=42LM669T.AEN
   // Mozilla/5.0 (X11; Linux; ko-KR) AppleWebKit/534.26+ (KHTML, like Gecko) Version/5.0 Safari/534.26
   return navigator.userAgent.indexOf("Mozilla/5.0 (X11; Linux; ko-KR) AppleWebKit/534.26+ (KHTML, like Gecko) Version/5.0 Safari/534.26") !== -1
}

UI.prototype.initWindroseChart=function()

{
    var beufort

    this.windrosedata=[]
    for (beufort=0;beufort<12;beufort++)
        this.windrosedata.push([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])

    this.windrosechart=Highcharts.chart('windrosechart', {
        chart: {
            animation: this.options.animation,
            polar: true,
            type: 'column',
        },

        tooltip : {
            enabled: this.options.tooltip
        },

        credits: {
            enabled: false
        },

        title: {
            text: 'Wind rose',
            //align: 'centre'
        },
    
        subtitle: {
            text: 'Based on windgust data',
            //align: 'left'
        },
    
        legend: {
            align: 'right',
            verticalAlign: 'top',
            y: 100,
            layout: 'vertical'
        },
    
        xAxis: {
            tickmarkPlacement: 'on',
            categories: ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        },
    
        yAxis: {
            min: 0,
            endOnTick: false,
            showLastLabel: true,
            title: {
                text: ''
            },
            //labels: {
            //    formatter: function () {
            //        return this.value + '%';
            //    }
            //},
            reversedStacks: false
        },
    
        //tooltip: {
        //    valueSuffix: ''
        //},
    
        plotOptions: {
            series: {
                stacking: 'normal',
                shadow: false,
                groupPadding: 0,
                pointPlacement: 'on',
                tooltip: {
                    valueDecimals : 1,
                    valueSuffix : ' %'
                }
            }
        },

        // Colors from https://en.wikipedia.org/wiki/Beaufort_scale
        
        series: [
            // Beufort scale 0 Calm
            { name: '0 Calm < 0.5 m/s',
            data: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
            color: '#7cb5ec' // from Highcharts
            }, 
            // Beufort scale 1 
            { name : '1 Light air 0.5 - 1.5 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
             color : '#AEF1F9'
            },
             // Beufort scale 1 
             { name : '2 Light breeze 1.6 - 3.3 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
              color : '#96F7DC'
            },
             // Beufort scale 3
            { name : '3 Gentle breeze 3.4 - 5.5 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
             color: '#96F7B4'
            },
             // Beufort scale 4
             { name : '4 Moderat breeze 5.6 - 7.9 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
              color: '#6FF46F'
            },
             // Beufort scale 5
             { name : '5 Fresh breeze 8 - 10.7 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
              color: '#73ED12'
            },
             // Beufort scale 6
             { name : '6 Strong breeze 10.8 - 13.8 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
              color: '#A4ED12'
            },
             // Beufort scale 7
             { name : '7 Near gale 13.9 - 17.1 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
              color: '#DAED12'
            },
             // Beufort scale 8
             { name : '8 Gale  17.2 - 20.7 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
              color: '#EDC212'
            },
             // Beufort scale 9
             { name : '9 Strong gale 20.8 - 24.4 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
              color: '#ED8F12'
            },
             // Beufort scale 10
             { name : '10 Storm 24.5 - 28.4 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
              color: '#ED6312'
            },
             // Beufort scale 11 
             { name : '11 Violent storm  28.5 - 32.6 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
              color: '#ED2912'
            },
             // Beufort scale 12 
             { name : '12 Hurricane force > 32.6 m/s',
             data:  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
              color: '#D5102D'
            }
                ]
    });

}

UI.prototype.initTemperatureChart=function()
{

  /*  if (this.options.frostapi.enabled)
           tempSeries.push(  {
            name: 'METno Temperature 10min',
            id:'series-metno-temperature10min',
            type: 'spline',
            yAxis: 0,
            data: [],
            visible: false,
            zIndex : 2
        }, {
            name: 'METno Humidity 1h',
            id: 'series-metno-humidity1h',
            type: 'spline',
            yAxis: 1,
            data: [],
            visible: false,
            zIndex : 1
        })*/
    
    this.temperatureChart= new Highcharts.stockChart({ 
        chart : {
            animation: this.options.animation,
            renderTo: 'temperaturechart',
            //plotBackgroundImage: this.options.weatherapi.geosatellite.enabled ? this.options.weatherapi.geosatellite.url_europe : '',
            height: this.options.weatherapi.geosatellite.enabled ? (720) : undefined,
            events: {
                click : this.onClickToggleChartSeries.bind(this)
            }
        },

        rangeSelector: {
            enabled: this.options.rangeSelector,
            inputEnabled: false,
            buttons: [{
                type: 'hour',
                count: 1,
                text: '1h'
            },
                {
                type: 'minute',
                count: 15,
                text: '15m'
            },{
                type: 'minute',
                count: 1,
                text: '1m'
            },
            {
                type: 'all',
                text: 'All'
            }],
            selected: 4,
            verticalAlign: 'bottom'
        },

        scrollbar: {
            enabled: false
        },

        navigator: {
            enabled: this.options.rangeSelector,
            series: {
                type: 'spline',
                dataGrouping: {
                    groupPixelWidth: 30
                }
            }
        },

        legend: {
            enabled: true
        },
    
        tooltip : {
            enabled: this.options.tooltip
        },
        credits: {
            enabled: false
        },
        title: {
            text: 'Temperature'
        },
        yAxis: [{
            //https://api.highcharts.com/highcharts/yAxis.max
            title: false,
            tickInterval: 1,
            opposite: false,
            gridLineWidth: this.options.weatherapi.geosatellite.enabled ? 0 : 1
            //max : null
            //max : 1.0
        //  max : 40
        },
        // humidity
        {
            title:false,
            //opposite: true,
            min: 0,
            max: 100,
            gridLineWidth: this.options.weatherapi.geosatellite.enabled ? 0 : 1
        },
        ],
        xAxis: [{

            id: 'datetime-axis',

            type: 'datetime',

            offset : 10,

            tickpixelinterval: 150,

        }],

        // don't use memory for duplicate path
        plotOptions: {
            series: {
                enableMouseTracking: this.options.mousetracking,
                // https://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/plotoptions/series-events-legenditemclick/
                // https://api.highcharts.com/highcharts/series.line.events.legendItemClick?_ga=2.179134500.1422516645.1651056622-470753587.1650372441
                // https://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/plotoptions/series-events-show/
                dataGrouping: { 
                    groupPixelWidth: 30
                }
            }
        },

        series: []
        
   })

}

UI.prototype.initPressureChart=function()
{
    var pressureSeries=[
        {
                name: 'Relative',
                id: 'series-relbaro',
                type: 'spline',
                data: []
            },
            {
                name: 'Absolute',
                id:'series-absbaro',
                type: 'spline',
                data: [],
                visible: false
            }]
    
        if (this.options.frostapi.enabled) {
           pressureSeries.push(
            {
                name: 'METno Sea-level pressure (QFF) 1h',
                id: 'series-metno-air_pressure_at_sea_level',
                type: 'spline',
                data: [],
                visible: false
            })
        }
            
    
        this.pressureChart= new Highcharts.stockChart({ chart : {
            animation: this.options.animation,
            renderTo: 'pressurechart',
            height: 600,
            events: {
                click: this.onClickToggleChartSeries.bind(this)
            }
        },
        tooltip: {
            enabled: this.options.tooltip
        },
        rangeSelector: {
            enabled: this.options.rangeSelector,
            inputEnabled: false,
            buttons: [{
                type: 'hour',
                count: 1,
                text: '1h'
            },
                {
                type: 'minute',
                count: 15,
                text: '15m'
            },{
                type: 'minute',
                count: 1,
                text: '1m'
            },
             {
                type: 'all',
                text: 'All'
            }],
            selected: 4,
            verticalAlign: 'bottom'
        },
    
        scrollbar: {
            enabled: false
        },
    
        navigator: {
            enabled: this.options.rangeSelector,
            series: {
                type: 'spline',
                dataGrouping: {
                    groupPixelWidth: 30
                }
            }
        },
    
        legend: {
            enabled: true
        },
        
        tooltip : {
            enabled: this.options.tooltip,
        },
        credits: {
            enabled: false
        },
        title: {
            text: 'Pressure'
        },
        yAxis: [{
            //https://api.highcharts.com/highcharts/yAxis.max
            title: false,
            tickInterval: 5,
            //min: 950
            //max : null
            
        }
    
    ],
        xAxis: [{
            type: 'datetime',
        }],
    
        plotOptions: {
            series: {
                enableMouseTracking: this.options.mousetracking,
                dataGrouping: { 
                    groupPixelWidth: 30
                },
                lineWidth: 4
            }
        },
    
        series: pressureSeries,

        })
}

UI.prototype.onClickToggleChartSeries=function(event)
// Toggle display of series to reveal underlying image
{
    var id=event.xAxis[0].axis.chart.renderTo.id,
        restoreHiddenSeries=this.restoreHiddenSeries[id]

    // console.log('click',event)

    if (!restoreHiddenSeries)
      restoreHiddenSeries=this.restoreHiddenSeries[id]=[]
    
     if (restoreHiddenSeries && restoreHiddenSeries.length) {   
        restoreHiddenSeries.forEach(function (series) { series.show() })
        this.restoreHiddenSeries[id]=[]
    } else
     {

         event.xAxis[0].axis.series.forEach(function (series) {
         
             if (series.visible)    
             {
                 restoreHiddenSeries.push(series)
                 series.hide()
             }
         
         })
     }
}

UI.prototype.initLatestChart=function()
{
    
    this.latestChart=new Highcharts.chart('latestChart',
                            { chart : { 
                                 //animation: this.options.animation
                                // plotBackgroundImage: this.options.weatherapi.radar.enabled ? this.options.weatherapi.radar.url_troms_5level_reflectivity : '',
                                 height: this.options.weatherapi.radar.enabled ? (640) : undefined,
                                 events: {
                                    // Allow viewing of underlying image
                                    click : this.onClickToggleChartSeries.bind(this)
                                 }
                                },
                                title: {
                                    text: 'Latest observations'
                                },
                                credits: {
                                    enabled: true,
                                    text: 'MET Norway data - CC 4.0'
                                },
                                yAxis: [
                                    // Temperature
                                    {
                                    title: { text : 'Temperature' },
                                    gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                                    //max: 60
                                },
                                // Humidity
                                {
                                    min: 0,
                                    max: 100,
                                    title: { text : 'Humidity' },
                                    opposite: true,
                                    visible: false,
                                    gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                                },
                                    // Wind
                                    {
                                        min: 0,
                                        title: { text : 'Wind speed' },
                                        opposite: true,
                                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                                    },
                                    // Wind direction
                                    {
                                        min: 0,
                                        title: { text : 'Wind dir.' },
                                        opposite: true,
                                        visible: false,
                                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                                    },
                                    // Pressure
                                    {
                                        min: 0,
                                        title: false,
                                        opposite: true,
                                        visible: false,
                                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                                    },
                                    // Irradiance
                                    {
                                        min: 0,
                                        title: false,
                                        visible: false,
                                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                                    },
                                    // UVI
                                    {
                                        min: 0,
                                        title: false,
                                        visible: false,
                                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                                    },
                                    // Rain rate
                                    {
                                        min: 0,
                                        title: { text : 'Rain rate'},
                                        visible: false,
                                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                                    }
                            ],
                                xAxis: [{
                                 type: 'column',
                                 categories: []
                                }],
                               
                                tooltip: {
                                    enabled: true
                                },

                                series: [
                                    {
                                        name: 'Temperature',
                                        id: 'series-temperature',
                                        type: 'column',
                                        // datalabels crashes on LG TV 2012 "not enough memory"
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012,
                                            color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                                            style: {
                                                fontSize: 14,
                                                fontWeight: 'bold'
                                            }
                                        }
                                    },
                                    {
                                        name: 'Windchill',
                                        id: 'series-windchill',
                                        type: 'column',
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012,
                                            color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                                            style: {
                                                fontSize: 14,
                                                fontWeight: 'bold'
                                            }
                                        },
                                        visible: false
                                    },
                                    {
                                        name: 'Humidity',
                                        id: 'series-humidity',
                                        type: 'column',
                                        yAxis: 1,
                                        dataLabels: {
                                            enabled: true && !this.isLGSmartTV2012,
                                            color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                                            style: {
                                                fontSize: 14,
                                                fontWeight: 'bold'
                                            }
                                        },
                                        visible: false
                                    },
                                    {
                                        name: 'Wind speed',
                                        id: 'series-windspeed',
                                        type: 'column',
                                        yAxis: 2,
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012,
                                            // https://www.highcharts.com/docs/chart-concepts/labels-and-string-formatting?_ga=2.200835883.424482256.1654686807-470753587.1650372441#format-strings
                                            format : '{point.y:.1f}',
                                            color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                                            style: {
                                                fontSize: 14,
                                                fontWeight: 'bold'
                                            }
                                        }
                                    },
                                    {
                                        name: 'Wind gust',
                                        id: 'series-windgust',
                                        type: 'column',
                                        yAxis: 2,
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012,
                                            format : '{point.y:.1f}',
                                            color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                                            style: {
                                                fontSize: 14,
                                                fontWeight: 'bold'
                                            }
                                        }
                                    },
                                    {
                                        name: 'Wind dir.',
                                        id :'series-winddirection',
                                        type: 'column',
                                        yAxis: 3,
                                        tooltip: {
                                            pointFormatter : function () {
                                                return this.series.name+' '+WindConverter.prototype.fromDegToCompassDirection(this.y)+' ('+this.y+')'
                                            }
                                        },
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012,
                                            color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                                            style: {
                                                fontSize: 14,
                                                fontWeight: 'bold'
                                            },
                                            formatter : function () {
                                                return WindConverter.prototype.fromDegToCompassDirection(this.y)
                                            }
                                        }
                                    },
                                    {
                                        name: 'Rainrate',
                                        id: 'series-rainrate',
                                        type: 'column',
                                        yAxis: 7,
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012,
                                            format : '{point.y:.1f}',
                                            color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                                            style: {
                                                fontSize: 14,
                                                fontWeight: 'bold'
                                            }
                                        },
                                        visible: true,
                                        //zones:  this.zones.rainrate
                                    },
                                    {
                                        name: 'Pressure',
                                        id: 'series-relbaro',
                                        type: 'column',
                                        yAxis: 4,
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012,
                                            format : '{point.y:.1f}',
                                            color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                                            style: {
                                                fontSize: 14,
                                                fontWeight: 'bold'
                                            }
                                        },
                                        visible: false
                                    },
                                    {
                                        name: 'Sunlight',
                                        id: 'series-irradiance',
                                        type: 'column',
                                        yAxis: 5,
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012,
                                            color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                                            style: {
                                                fontSize: 14,
                                                fontWeight: 'bold'
                                            }
                                        },
                                        visible: true
                                    },
                                    {
                                        name: 'UVI',
                                        id: 'series-UVI',
                                        type: 'column',
                                        yAxis: 6,
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012,
                                            color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                                            style: {
                                                fontSize: 14,
                                                fontWeight: 'bold'
                                            }
                                        },
                                        visible: false,
                                       // zones : this.zones.uvi
                                    },
                            ]
                            })

    this.latestChart.series.forEach(function (series) {
        
        series.options.data=[]; 
                
        series.xAxis.categories.forEach(function (category) { 
                series.options.data.push(null) 
            }) 
    }) 

}


UI.prototype.initRainstatChart=function()
{
    this.rainstatchart=new Highcharts.chart('rainstatchart',
                            { chart : { 
                                 animation: this.options.animation
                                },
                                title: {
                                    text: 'Rain statistics'
                                },
                                credits: {
                                    enabled: false
                                },
                                yAxis: [{
                                    min: 0,
                                    title: false
                                },{
                                    min : 0,
                                    title: false,
                                    opposite: true,
                                }],
                                xAxis: [{
                                 type: 'column',
                                 categories: ['hour','day','event','week','month','year']
                                }],
                               
                                tooltip: {
                                    enabled: this.options.tooltip
                                },
                                series: [
                                    {
                                        name: 'Rain',
                                        type: 'column',
                                        data: [],
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012
                                        }
                                            
                                    },
                                    {
                                        name: 'Rain',
                                        type: 'column',
                                        data: [],
                                        yAxis: 1,
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012
                                        },
                                    },
                                    {
                                        name: 'Rain MET.no',
                                        type: 'column',
                                        data: [],
                                        yAxis: 1,
                                        dataLabels: {
                                            enabled: true && !this.options.isLGSmartTV2012
                                        },
                                    }
                            ]
                            })
                        }

UI.prototype.initRainChart=function()
{
                 
    this.rainchart= new Highcharts.stockChart({ chart : {
                            animation: this.options.animation,
                            renderTo: 'rainchart',
                        },
                        rangeSelector: {
                            enabled: this.options.rangeSelector,
                            inputEnabled : false,
                            buttons: [{
                                type: 'hour',
                                count: 1,
                                text: '1h'
                            },
                                {
                                type: 'minute',
                                count: 15,
                                text: '15m'
                            },{
                                type: 'minute',
                                count: 1,
                                text: '1m'
                            },
                             {
                                type: 'all',
                                text: 'All'
                            }],
                            selected: 4,
                            verticalAlign: 'bottom'
                        },
                    
                        scrollbar: {
                            enabled: false
                        },
                    
                        navigator: {
                            enabled: this.options.rangeSelector,
                            series: {
                                type: 'spline',
                                dataGrouping: {
                                    groupPixelWidth: 30
                                }
                            }
                        },
                    
                        legend: {
                            enabled: true
                        },
                        
                        tooltip : {
                            enabled: this.options.tooltip,
                        },
                        credits: {
                            enabled: false
                        },
                        title: {
                            text: 'Rain'
                        },
                        yAxis: [{
                            title: false,
                            min : 0,
                            opposite: false,
                            tickInterval: 0.5
                           
                        },
                        {
                            title: false,
                            min : 0,
                            tickInterval: 1
                           
                        }],
                        xAxis: [{

                            id: 'rain-datetime-axis',
                            type: 'datetime',

                        }],
                        plotOptions: {
                            series: {
                                enableMouseTracking: this.options.mousetracking,
                                dataGrouping: { 
                                    groupPixelWidth: 30
                                }
                            }
                        },
                        series: [
                            {
                                    name: 'Rain rate',
                                    type: 'spline',
                                    data: [],
                                    //https://en.wikipedia.org/wiki/Rain#Intensity
                                    //zoneAxis: 'y',
                                    zones: this.zones.rainrate
                            },
                            {
                                name: 'Rain event',
                                type: 'spline',
                                data: [],
                                yAxis: 1,
                                visible: false
                            },
                            {
                                name: 'Rain day',
                                type: 'spline',
                                data: [],
                                yAxis: 1
                            }
                        
                        ] 
                        })
}

UI.prototype.initSolarChart=function()
{
    var solarSeries=[
        {
                name: 'Sunlight',
                type: 'spline',
                yAxis: 0,
                data: []
        },
              
           // {
           //     name: 'Solar UV',
           //     type: 'spline',
           //     data: [],
           //     yAxis: 1,
           // }
           // ,
            {
                name: 'UVI',
                type: 'areaspline',
                yAxis: 1,
                data: [],
                
                zones: this.zones.uvi
            }] 
        
        if (this.options.frostapi.enabled)
          solarSeries.push( {
            // shortwave 295-2800nm (ultraviolet,visible,infrared)
            //https://frost.met.no/elements/v0.jsonld?fields=id,oldElementCodes,category,name,description,unit,sensorLevelType,sensorLevelUnit,sensorLevelDefaultValue,sensorLevelValues,cmMethod,cmMethodDescription,cmInnerMethod,cmInnerMethodDescription,status&lang=en-US
            // https://frost.met.no/elementtable
            name: 'METno Solar mean 1m',
            id:'series-metno-irradiance-mean1m',
            type: 'spline',
            yAxis: 0,
            data: [],
            visible: false
    })

    this.solarchart= new Highcharts.stockChart({ chart : {
                        animation: this.options.animation,
                        renderTo: 'solarchart',
                        },
                        rangeSelector: {
                            enabled: this.options.rangeSelector,
                            inputEnabled: false,
                            buttons: [{
                                type: 'hour',
                                count: 1,
                                text: '1h'
                            },
                                {
                                type: 'minute',
                                count: 15,
                                text: '15m'
                            },{
                                type: 'minute',
                                count: 1,
                                text: '1m'
                            },
                             {
                                type: 'all',
                                text: 'All'
                            }],
                            selected: 4,
                            verticalAlign: 'bottom'
                        },

                        scrollbar: {
                            enabled: false
                        },

                        navigator: {
                            enabled: this.options.rangeSelector,
                            series: {
                                type: 'spline',
                                dataGrouping: {
                                    groupPixelWidth: 30
                                }
                            }
                        },

                        legend: {
                            enabled: true
                        },
                       
                        tooltip : {
                            enabled: this.options.tooltip
                        },
                        credits: {
                            enabled: false
                        },
                        title: {
                            text: 'Solar'
                        },
                        yAxis: [{
                            //https://api.highcharts.com/highcharts/yAxis.max
                            title: false,
                            min : 0,
                            tickInterval: 50,
                            opposite: false
                            //max : null
                            //max : 1.0
                        //  max : 40
                        },
                 // uv
                 //   {
                 //       title:false,
                 //       opposite: true,
                 //       min: null,
                 //       max: null
                 //   },
                    // uvi
                    {
                        title:false,
                        min: 0,
                        tickInterval:1,
                        allowDecimals: false,
                    }
                ],
                        xAxis: [{

                            id: 'datetime-axis',

                            type: 'datetime',

                            offset : 10,

                            tickpixelinterval: 150,

                        }],

                        plotOptions: {
                            series: {
                                enableMouseTracking: this.options.mousetracking,
                                dataGrouping: { 
                                    groupPixelWidth: 30
                                }

                            }
                        },

                        series: solarSeries
                        })
}

UI.prototype.initWindBarbChart=function()
{
    var windSeries= [{
        type: 'windbarb',
        data: [],
        name: 'Wind',
        color: Highcharts.getOptions().colors[1],
        showInLegend: false,
        zIndex:2
    }, 
    {
        type: 'areaspline',
        data: [],
        name: 'Wind',
        id:'series-wind',
        zIndex: 3
    },
    {
        type: 'areaspline',
        data: [],
        zIndex: 2,
        name: 'Wind gust',
        id:'series-windgust'
    }]

    if (this.options.frostapi.enabled)
    {
       windSeries.push(
        {
            type: 'spline',
            data: [],
            //zIndex: 2,
            name: 'METno Wind mean 10min',
            id:'series-metno-windmean10min',
            visible: false
        })

       windSeries.push(
        {
            type: 'spline',
            data: [],
            //zIndex: 2,
            name: 'METno Wind gust max 10min',
            id: 'series-metno-windgustmax10min',
            visible: false
        })
    }


    // based on https://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/demo/windbarb-series/
    this.windbarbchart= new Highcharts.stockChart({ chart : {
        animation: this.options.animation,
        renderTo: 'windbarbchart' },

        rangeSelector: {
            enabled: this.options.rangeSelector,
            inputEnabled: false,
            buttons: [{
                type: 'hour',
                count: 1,
                text: '1h'
            },
                {
                type: 'minute',
                count: 15,
                text: '15m'
            },{
                type: 'minute',
                count: 1,
                text: '1m'
            },
             {
                type: 'all',
                text: 'All'
            }],
            selected: 4,
            verticalAlign: 'bottom'
        },

        scrollbar: {
            enabled: false
        },

        navigator: {
            enabled: this.options.rangeSelector,
            series: {
                type: 'spline',
                dataGrouping: {
                    groupPixelWidth: 30
                }
            }
        },

        legend: {
            enabled: true
        },
        
        tooltip : {
            enabled: this.options.tooltip,
        },

        title: {
            text: 'Wind'
        },
    
        xAxis: [{
            type: 'datetime',
            offset: 40
        },{
            type: 'category',
            categories : ['Wind daily max.']
        }],

        yAxis: {
            title : false,
            tickInterval: 0.5,
         //   plotLines: [{
         //       id: 'winddailymax',
         //       color: '#ff0000',
         //       value: 1.7
         //   }]
        },
    
      plotOptions: {
        series: {
            enableMouseTracking: this.options.mousetracking
        }
    },
        series: windSeries
    
    });
}

UI.prototype.initCharts=function()
{
    // Windrose demo https://jsfiddle.net/fq64pkhn/
    //var testChart=Highcharts.stockChart('testchart',{ title: { text: 'test chart' }}) 
    this.zones = {
        uvi : [{
            value: 2,
            color:  '#2a9502'   // green
        },
        {   
            value: 5,
            color: '#f7e400'    // yellow
        },
        {   
            value: 7,
            color: '#f85900'    // orange
        },
        {   
            value: 10,
            color: '#d8220e'    // redish
        },
        {   
            color: '#6b49c8'    // magenta
        }
       ],

       rainrate: [
        {   
            // max value for zone < 2.5
            value: 2.5,
            color: '#2a9502'    // green
           
        },
        {   
            value: 7.6,
            color: '#f7e400'    // yellow
           
        },
        {   
            value: 50,
            color: '#f85900'    // orange
        },
        {
            color: '#d8220e'    // redish
        },
        ]
    }
   
       // this.initTestChart()
        this.initLatestChart()
        this.initTemperatureChart()
        this.initWindBarbChart() 
        this.initWindroseChart() 
        this.initPressureChart()
        this.initRainChart()
        this.initRainstatChart()
        this.initSolarChart()

}

UI.prototype.initTestChart=function()
{
    this.testChart=new Highcharts.chart('testchart', {
        chart: {
                    type: 'column'
                },
              
                xAxis: {
                    categories: [
                        'Jan','Feb'
                    ],
                   
                },
                yAxis: {
                    min: 0,
                    title: {
                        text: 'Rainfall (mm)'
                    }
                },
            
                series: [{
                    name: 'Tokyo',
                   // data: [49.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1, 95.6, 54.4]
                   dataLabels: {
                    enabled: true && !this.options.isLGSmartTV2012
                },
                   data: [49.9,null]
                }]
            });
}

UI.prototype.onJSONLivedata=function (station,ev)
{
    var jsonReq=station.getJSON
    // Show when data is available
   // if (this.weatherElement.style.display==="none")
   //   this.weatherElement.style.display="block"

    this.measurementCount=this.measurementCount+1

    if (this.measurementCount===1 )
    {
        if (this.options.tooltip.enabled) {
            if (this.rainchart) {
                this.rainchart.series[0].tooltipOptions.valueSuffix=' '+jsonReq.unitRainrate()
                this.rainchart.series[1].tooltipOptions.valueSuffix=' '+jsonReq.unitRain()
                this.rainchart.series[2].tooltipOptions.valueSuffix=' '+jsonReq.unitRain()
            }
            if (this.windbarbchart)
                this.windbarbchart.series.forEach(function (series) { series.tooltipOptions.valueSuffix=' '+jsonReq.unitWind()})
            if (this.temperatureChart) {
                this.temperatureChart.series[0].tooltipOptions.valueSuffix=' '+jsonReq.unitTemp()
                this.temperatureChart.series[1].tooltipOptions.valueSuffix=' '+jsonReq.unitTemp()
            }
            if (this.pressureChart) {
                this.pressureChart.series[0].tooltipOptions.valueSuffix=' '+jsonReq.unitPressure()
                this.pressureChart.series[1].tooltipOptions.valueSuffix=' '+jsonReq.unitPressure()
            }
            if (this.solarchart)
                this.solarchart.series[0].tooltipOptions.valueSuffix=' '+jsonReq.unitSolarlight()
        }
    }

    this.outtempElement.textContent=jsonReq.outtemp()
    this.intempElement.textContent=jsonReq.intemp()
    this.unitTempElement.textContent=jsonReq.unitTemp()

    this.windspeedElement.textContent=jsonReq.windspeed()
    this.windgustspeedElement.textContent=jsonReq.windgustspeed()
    this.winddirection_compassElement.textContent=jsonReq.winddirection_compass()
    this.windgustspeed_beufort_descriptionElement.textContent=jsonReq.windgustbeufort_description()
    this.unitWindElement.textContent=jsonReq.unitWind()
    this.meter_windgustspeedElement.value=jsonReq.windgustspeed()

    this.relbaroElement.textContent=jsonReq.relbaro()
    this.absbaroElement.textContent=jsonReq.absbaro()
    this.unitpressureElement.textContent=jsonReq.unitPressure()

    this.solar_lightElement.textContent=jsonReq.solar_light()
    this.unit_solar_lightElement.textContent=jsonReq.unitSolarlight()
    this.solar_uvElement.textContent=jsonReq.solar_uv()
    this.unit_solar_uvElement.textContent=jsonReq.unitSolarUV()
    this.solar_uviElement.textContent=jsonReq.solar_uvi()

}

UI.prototype.updateStationTimestampLatestChart=function()
{
    var redraw=false,
        stationNames

    if (!this.latestChart)
        return
    
    stationNames= this.options.latestChart.stations.map(function (station) { if (!station.timestampHHMMSS) return station.name; else return station.name+' '+station.timestampHHMMSS })
    this.latestChart.xAxis[0].setCategories(stationNames,redraw)
}

UI.prototype.onJSONLatestChart=function(station)
{
    var getJSON=station.getJSON,
        redraw=false,
        animation=this.options.animation,
        stationCategoryIndex=this.options.latestChart.stations.indexOf(station)
    
    if (this.latestChart) {
        this.updateStationTimestampLatestChart()
        this.latestChart.get('series-temperature').options.data[stationCategoryIndex]=getJSON.outtemp()
        //this.latestChart.series[0].options.data[1]=getJSON.intemp()
        this.latestChart.get('series-humidity').options.data[stationCategoryIndex]=getJSON.outhumidity()
        //this.latestChart.series[1].options.data[1]=getJSON.inhumidity()
        this.latestChart.get('series-windspeed').options.data[stationCategoryIndex]=getJSON.windspeed_mps()
        this.latestChart.get('series-windgust').options.data[stationCategoryIndex]=getJSON.windgustspeed_mps()
        this.latestChart.get('series-winddirection').options.data[stationCategoryIndex]=getJSON.winddirection()
        this.latestChart.get('series-relbaro').options.data[stationCategoryIndex]=getJSON.relbaro()
        this.latestChart.get('series-irradiance').options.data[stationCategoryIndex]=getJSON.solar_light()
        this.latestChart.get('series-UVI').options.data[stationCategoryIndex]=getJSON.solar_uvi()
        this.latestChart.get('series-rainrate').options.data[stationCategoryIndex]=getJSON.rainrate()        

        this.latestChart.series.forEach(function (series) {
            series.setData(series.options.data,redraw,animation)
        })
        
    }

}

UI.prototype.onJSONWindroseChart=function(station)
{
    var getJSON=station.getJSON,
        redraw=false,
        animation=this.options.animation

      //console.log(this.windrosedata)
      if (this.windrosechart) {
        var newBeufortScale=getJSON.windgustspeed_beufort()
       var newCompassDirection=getJSON.winddirection_compass_value()-1 
         var beufort
       var percentArr
       this.windrosedata[newBeufortScale][newCompassDirection]=this.windrosedata[newBeufortScale][newCompassDirection]+1
     
       for (beufort=0;beufort<12;beufort++) {
           percentArr=[]
           this.windrosedata[beufort].forEach(function (measurement) { 
               percentArr.push(measurement/this.measurementCount*100)
           }.bind(this))
           //console.log('percentarray',percentArr)
           this.windrosechart.series[beufort].setData(percentArr,redraw,animation,true) // updatePoints=true 
       }
   }
}

UI.prototype.onJSONTemperatureChart=function(station)
{
    var getJSON=station.getJSON,
        timestamp=station.timestamp,
        id=station.id,
        redraw=false,
        shift=false
        animation=this.options.animation

        if (this.temperatureChart) {

            var series= this.temperatureChart.get('series-outdoor-'+station.id)
            if (series)
                series.addPoint([timestamp,getJSON.outtemp()],redraw,shift,animation)
            else 
                this.temperatureChart.addSeries( {
                    name: 'Outdoor '+station.name,
                    id:'series-outdoor-'+station.id,
                    type: 'spline',
                    yAxis: 0,
                    data: [[timestamp,getJSON.outtemp()]],
                    zIndex: 5
                },redraw,animation)

          series=this.temperatureChart.get('series-outdoor-humidity-'+station.id)
          if (series)
            series.addPoint([timestamp,getJSON.outhumidity()],redraw,shift,animation)
          else
            this.temperatureChart.addSeries( {
                name: 'Outdoor humidity '+station.name,
                id:'series-outdoor-humidity-'+station.id,
                type: 'spline',
                yAxis: 1,
                data: [[timestamp,getJSON.outhumidity()]],
                tooltip: {
                    valueSuffix: ' %'
                },
                zIndex: 5,
                visible: false
            },redraw,animation)

         series= this.temperatureChart.get('series-indoor-'+station.id)
        if (series)
            series.addPoint([timestamp,getJSON.intemp()],redraw,shift,animation)
        else 
            this.temperatureChart.addSeries( {
                name: 'Indoor '+station.name,
                id:'series-indoor-'+station.id,
                type: 'spline',
                yAxis: 0,
                data: [[timestamp,getJSON.intemp()]],
                zIndex: 5,
                visible: false
            },redraw,animation)

        series=this.temperatureChart.get('series-indoor-humidity-'+station.id)
        if (series)
            series.addPoint([timestamp,getJSON.inhumidity()],redraw,shift,animation)
        else
            this.temperatureChart.addSeries( {
                name: 'Indoor humidity '+station.name,
                id:'series-indoor-humidity-'+station.id,
                type: 'spline',
                yAxis: 1,
                data: [[timestamp,getJSON.inhumidity()]],
                tooltip: {
                    valueSuffix: ' %'
                },
                zIndex: 5,
                visible: false
            },redraw,animation)
        
        }
    
}

UI.prototype.onJSONPressureChart=function(station)
{
    var getJSON=station.getJSON,
        timestamp=station.timestamp
        redraw=false,
        shift=false
        animation=this.options.animation

    if (this.pressureChart) {
        this.pressureChart.series[0].addPoint([timestamp,getJSON.relbaro()],redraw,shift,animation)
        this.pressureChart.series[1].addPoint([timestamp,getJSON.absbaro()],redraw,shift,animation)
   }
}

UI.prototype.onJSONWindbarbChart=function(station)
{
    var getJSON=station.getJSON,
        timestamp=station.timestamp
        redraw=false,
        shift=false
        animation=this.options.animation

    if (this.windbarbchart) {
        this.windbarbchart.series[0].addPoint([timestamp,getJSON.windgustspeed_mps(),getJSON.winddirection()],redraw,shift,animation)
        
        // https://api.highcharts.com/highcharts/series.line.data
        // only support m/s unit
        this.windbarbchart.series[1].addPoint([timestamp,getJSON.windspeed_mps()],redraw,shift,animation)
        this.windbarbchart.series[2].addPoint([timestamp,getJSON.windgustspeed_mps()],redraw,shift,animation)
       /* var winddailymax=getJSON.winddailymax()
        if (winddailymax)
       {
            //this.windbarbchart.series[3].setData([['Wind daily max.',winddailymax]],false,this.options.animation,true)
        } */
    }
}

UI.prototype.onJSONSolarChart=function(station)
{
    var getJSON=station.getJSON,
        timestamp=getJSON.timestamp(),
        redraw=false,
        shift=false
        animation=this.options.animation
    
    if (this.solarchart) {
        this.solarchart.series[0].addPoint([timestamp,getJSON.solar_light()],redraw,shift,animation)
        this.solarchart.series[1].addPoint([timestamp, getJSON.solar_uvi()],redraw,shift,animation)
    }
}

UI.prototype.onJSONRainchart=function(station)
{
    var getJSON=station.getJSON,
        timestamp=getJSON.timestamp(),
        redraw=false,
        shift=false
        animation=this.options.animation
    
    if (this.rainchart) {
        this.rainchart.series[0].addPoint([timestamp,getJSON.rainrate()],redraw,shift,animation)
        this.rainchart.series[1].addPoint([timestamp,getJSON.rainevent()],redraw,shift,animation)
        this.rainchart.series[2].addPoint([timestamp,getJSON.rainday()],redraw,shift,animation)
    }
}

UI.prototype.onJSONRainstatChart=function(station)
{
    var getJSON=station.getJSON,
        redraw=false,
        animation=this.options.animation

    if (this.rainstatchart) {
        this.rainstatchart.series[0].setData([['hour',getJSON.rainhour()],['day',getJSON.rainday()],['event',getJSON.rainevent()],['week',getJSON.rainweek()]],redraw,animation)
        this.rainstatchart.series[1].setData([null,null,null,null,['month',getJSON.rainmonth()],['year',getJSON.rainyear()]],redraw,animation)
    }
}

UI.prototype.redrawCharts=function()
{
    // https://api.highcharts.com/class-reference/Highcharts.Axis#setExtremes
   // y-axis start on 0 by default
    
   if (this.pressureChart) {
        if (this.pressureChart.series[0].dataMin && this.pressureChart.series[0].dataMax)
                this.pressureChart.series[0].yAxis.setExtremes(this.pressureChart.series[0].dataMin-2,this.pressureChart.series[0].dataMax+2,false)
    }
    //console.log('redraw all charts')
    
    Highcharts.charts.forEach(function (chart) { 
        chart.redraw() 
    })
}

})() // Avoid intefering with global namespace https://developer.mozilla.org/en-US/docs/Glossary/IIFE 

