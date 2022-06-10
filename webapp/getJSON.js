// by default functions are added to window object

function GetJSON(url,interval,options) {
// https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest
// https://stackoverflow.com/questions/1973140/parsing-json-from-xmlhttprequest-responsejson
// https://developer.mozilla.org/en-US/docs/Web/API/setInterval

    this.options=options
    
    this.url=url

    this.req=new XMLHttpRequest()
    
    this.req.addEventListener("load", this.transferComplete.bind(this))
    this.req.addEventListener("error", this.transferError.bind(this))
    this.req.addEventListener("onabort",this.transferAbort.bind(this))

    this.sendRequestInterval(interval)

    console.log('GetJSON',this)
  
  }

GetJSON.prototype.WindnewCompassDirection = {
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

GetJSON.prototype.Mode = {
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

GetJSON.prototype.sendRequestInterval= function(interval)
{
    if (!interval)
      {
          console.error('sendRequestInterval: Refusing to set undefined interval: '+interval)
          return
      }

    // don't send new request if already in progress 
    if (this.req.readyState === XMLHttpRequest.UNSENT || this.req.readyState === XMLHttpRequest.DONE) // unsent or done https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/readyState
       this.sendRequest()

    if (this.requestIntervalID != null && this.requestIntervalID != undefined) {
       // console.log('clearing interval id:'+this.requestIntervalID)
        clearInterval(this.requestIntervalID)
    }
    
    this.requestIntervalID=setInterval(this.sendRequest.bind(this),interval)
    console.log('Setting new interval '+this.url+' interval:'+interval+' previous interval: '+this.interval+' id:'+this.requestIntervalID)
    this.interval=interval
}

GetJSON.prototype.sendRequest=function()
{
    //req.overrideMimeType('')
    //req.overrideMimeType("application/json")
    this.req.open('GET',this.url)
    this.req.setRequestHeader("Accept","application/json")
    this.req.send()
}


GetJSON.prototype.transferAbort = function(ev)
{
    console.warn('request aborted '+JSON.stringify(ev))
}


GetJSON.prototype.timestamp=function()
{
    return this.data.timestamp
}

GetJSON.prototype.outtempToString=function()
{
    return this.outtemp().toFixed(1)+' '+this.unitTemp()
}

GetJSON.prototype.outtemp=function()
{
    return this.data.outtemp
}

GetJSON.prototype.intempToString=function()
{
    return this.intemp().toFixed(1)+' '+this.unitTemp()
}

GetJSON.prototype.intemp=function()
{
    return this.data.intemp
}

GetJSON.prototype.inhumidityToString=function()
{
    return this.inhumidity()+' %'
}

GetJSON.prototype.inhumidity=function()
{
    return this.data.inhumidity
}

GetJSON.prototype.outhumidityToString=function()
{
    return this.outhumidity()+' %'
}

GetJSON.prototype.outhumidity=function()
{
    return this.data.outhumidity
}

GetJSON.prototype.windspeedToString=function()
{
    return this.windspeed().toFixed(1)+' '+this.unitWind()
}
GetJSON.prototype.windspeed=function()
{
    //https://javascript.info/number
    return this.data.windspeed
}

GetJSON.prototype.winddailymax=function()
{
    return this.data.winddailymax
}

GetJSON.prototype.winddailymaxToString=function()
{
    return this.winddailymax().toFixed(1)+' '+this.unitWind()
}

GetJSON.prototype.windspeed_mps=function()
// highcharts windbarb requires m/s
{
    if (this.mode.wind === this.Mode.wind_mps)
        return this.windspeed()
    else
        console.error('Converter to m/s neccessary for wind mode : '+this.mode.wind)
}

GetJSON.prototype.windgustspeedToString=function()
{
    return this.windgustspeed().toFixed(1)+' '+this.unitWind()
}

GetJSON.prototype.windgustspeed=function()
{
    return this.data.windgustspeed
}

GetJSON.prototype.windgustspeed_mps=function()
// highcharts windbarb requires m/s
{
    if (this.mode.wind === this.Mode.wind_mps)
        return this.windgustspeed()
    else
      console.error('Converter to m/s neccessary for wind mode : '+this.mode.wind)
    
}

GetJSON.prototype.winddirection=function()
{
    return this.data.winddirection
}

GetJSON.prototype.windgustspeed_beufort=function()
{
    return this.data.windgustspeed_beufort
}

GetJSON.prototype.winddirection_compass_value=function()
{
    return this.data.winddirection_compass_value
}

GetJSON.prototype.winddirection_compass=function()
{
    return  this.data.winddirection_compass + ' ('+this.data.winddirection+this.unit.winddirection+')'
}

GetJSON.prototype.windgustbeufort_description=function()
{
    return this.data.windgustspeed_beufort_description+' ('+this.data.windgustspeed_beufort+')'
}


GetJSON.prototype.relbaro= function()
{
    return this.data.relbaro
   
}

GetJSON.prototype.absbaro=function()
{
    return this.data.absbaro
}

GetJSON.prototype.pressureCalibrationToString=function(pressure)
{
    return pressure.toFixed(1)
}

GetJSON.prototype.pressureToString= function(pressure)
{
    var numdecimals=1

    if (this.mode.pressure === this.Mode.pressure_inhg)
        numdecimals=2

    return pressure.toFixed(numdecimals)+' '+ this.unitPressure()
}

GetJSON.prototype.solar_lightToString=function()
{
    return this.solar_light().toFixed(1)+' '+this.unitSolarlight()
}

GetJSON.prototype.solar_light = function()
{
    return this.data.solar_light
}

GetJSON.prototype.solar_uvToString = function()
{
    return this.solar_uv().toFixed(1)+' '+this.unitSolarUV()
}

GetJSON.prototype.solar_uv = function()
{
    return this.data.solar_uv
}

GetJSON.prototype.solar_uvi=function()
{
    return this.data.solar_uvi
}

GetJSON.prototype.rainrate_description=function()
{
    return this.data.rainrate_description
}

GetJSON.prototype.rainrateToString=function()
{
    var numdecimals

    if (this.mode.rain === this.Mode.rain_mm)
        numdecimals=1
    else
        numdecimals=2
    
    return this.rainrate().toFixed(numdecimals)+' '+this.unitRainrate()
}

GetJSON.prototype.rainrate=function()
{
    return this.data.rainrate
}

GetJSON.prototype.rainevent=function()
{
    return this.data.rainevent
}

GetJSON.prototype.rainhour=function()
{
    return this.data.rainhour
}

GetJSON.prototype.rainday=function()
{
    return this.data.rainday
}

GetJSON.prototype.rainweek=function()
{
    return this.data.rainweek
}

GetJSON.prototype.rainmonth=function()
{
    return this.data.rainmonth
}

GetJSON.prototype.rainyear=function()
{
    return this.data.rainyear
}

GetJSON.prototype.unitRainrate=function()
{
    return this.unit.rainrate
}

GetJSON.prototype.unitRain=function()
{
    return this.unit.rain
}

GetJSON.prototype.unitTemp=function()
{
    return this.unit.temperature
}

GetJSON.prototype.unitWind=function()
{
    return this.unit.wind
}

GetJSON.prototype.unitSolarlight=function()
{
    return this.unit.solar_light
}

GetJSON.prototype.solar_uvi_description=function()
{
    return this.data.solar_uvi_description
}

GetJSON.prototype.unitSolarUV=function()
{
    return this.unit.solar_uv
}

GetJSON.prototype.unitPressure=function()
{
    return this.unit.pressure
}

GetJSON.prototype.parse=function()
{
    this.data = this.json.data
    this.unit = this.json.unit
    this.mode = this.json.mode
}

GetJSON.prototype.transferComplete=function(evt)
{
    //console.log('transfer complete',evt)
    if (this.req.responseText.length > 0) {
        //console.log('json:'+this.req.responseText)
        try {
            this.json = JSON.parse(this.req.responseText)
            //console.dir(this.json, { depth: null })

            this.parse()
        } catch (err)
        {
            console.error('Failed parsing JSON')
            console.error(JSON.stringify(err))
        }
       
    } else
    {
        console.error("No JSON received " + this.req.status+' '+this.req.statusText)
        delete this.json
    }
}

GetJSON.prototype.transferError=function(evt)
// Chrome: about 2 seconds timeout
{
    console.error('Failed to receive json for '+this.url,evt);
}

function GetJSONFrostPrecipitation(url,interval,options)
{
    GetJSON.call(this,url,interval,options)
}

GetJSONFrostPrecipitation.prototype= Object.create(GetJSON.prototype)

function WindConverter()
{

}

WindConverter.prototype.fromKmhToMps=function(kmh)
{
    return kmh*5/18
}

function GetJSONWUCurrentConditions(url,interval,options)
{
    GetJSON.call(this,url,interval,options)
    this.options=options.wundergroundapi
    this.windConverter=new WindConverter()
}

GetJSONWUCurrentConditions.prototype= Object.create(GetJSON.prototype)

/*  {
        "stationID": "IENGEN26",
        "obsTimeUtc": "2022-06-09T13:32:48Z",
        "obsTimeLocal": "2022-06-09 15:32:48",
        "neighborhood": "Engenes",
        "softwareType": "GW1000A_V1.7.3",
        "country": "NO",
        "solarRadiation": 132.1,
        "lon": 17.155897,
        "realtimeFrequency": null,
        "epoch": 1654781568,
        "lat": 68.920051,
        "uv": 0,
        "winddir": 302,
        "humidity": 77,
        "qcStatus": -1,
        "metric": {
          "temp": 6.7,
          "heatIndex": 6.7,
          "dewpt": 3,
          "windChill": 4.5,
          "windSpeed": 11.2,
          "windGust": 14.4,
          "pressure": 1010.3,
          "precipRate": 0,
          "precipTotal": 0,
          "elev": 14.6
        }
      } */

GetJSONWUCurrentConditions.prototype.parse=function()
{
    if (this.json.observations && this.json.observations[0]) {
        this.data=this.json.observations[0]
        console.log('wu data '+JSON.stringify(this.data))
    } else
        console.error('Not a WU observation '+JSON.stringify(this.json))
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
    return this.windConverter.fromKmhToMps(this.data.metric.windSpeed)
}

GetJSONWUCurrentConditions.prototype.windgust_speed=function()
{
    return this.windConverter.fromKmhToMps(this.data.metric.windGust)
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

function GetJSONHolfuyLive(url,interval,options)
{
    GetJSON.call(this,url,interval,options)
    this.options=options.holfuyapi
}

GetJSONHolfuyLive.prototype= Object.create(GetJSON.prototype)

function GetJSONFrost(url,interval,options)
{
    GetJSON.call(this,url,interval,options)
    this.options=options.frostapi
}

GetJSONFrost.prototype= Object.create(GetJSON.prototype)

GetJSONFrost.prototype.sendRequest=function()
{
    // sources='+sourceId+'&referenceTime='+d1hourago.toISOString()
    var  date   = new Date(),
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
            precipitationHourURL=frostapi_url+'?sources='+sourceId+'&referencetime='+dateISOMidnight.toISOString().split('.')[0]+'Z'+'/'+dateISO+'&elements=sum(precipitation_amount%20PT1H)&timeResolution=hours'

    latestHourURL='/api/frost.met.no/latest-hour' // use curl on local network web server to bypass CORS
    this.req.open("GET",latestHourURL)
    this.req.setRequestHeader("Accept","application/json")
    this.req.setRequestHeader("Authorization", this.options.authorization);
    this.req.send()
    
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
        hhmm,
        observation,
        elementId,
        unit,
        timeOffset,
        lastObservation

    this.METno={}

    for (item=0;item<json.totalItemCount;item++) // number of data items
    {
            referenceTime=new Date(json.data[item].referenceTime) 
           // console.log('referenceTime '+referenceTime)
           // console.log(JSON.stringify(json.data[item]))
            //console.log('referencetime',referenceTime)                    
            timestamp=referenceTime.getTime()-referenceTime.getTimezoneOffset()*60000  // local timezone time
            hhmm=('0'+referenceTime.getHours()).slice(-2)+':'+('0'+referenceTime.getMinutes()).slice(-2) // https://stackoverflow.com/questions/1267283/how-can-i-pad-a-value-with-leading-zeros
        
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

                    if (!this.METno[elementId])
                        this.METno[elementId] = []

                    lastObservation=this.METno[elementId].slice(-1)[0]
                    if (!lastObservation || (lastObservation && lastObservation.timestamp !== timestamp)) // dont attempt to add multiple observations with same timestamp, for example PT1H and PT10M at 10:00
                        this.METno[elementId].push({
                            timestamp : timestamp,
                            hhmm : hhmm,
                            value : observation.value,
                            unit : unit
                        })
                }
            
            }
    }

   console.log('METno '+JSON.stringify(this.METno),this.METno)

}

function getJSONFrostLatest15Min(url,interval,options)
{
    GetJSONFrost.call(this,url,interval,options)
}

getJSONFrostLatest15Min.prototype= Object.create(GetJSONFrost.prototype)

getJSONFrostLatest15Min.prototype.sendRequest=function()
{
    this.req.open("GET",this.url)
    this.req.setRequestHeader("Accept","application/json")
    this.req.setRequestHeader("Authorization", this.options.authorization);
    this.req.send()
}

function GetJSONFrostLatest1H(url,interval,options)
{
    GetJSONFrost.call(this,url,interval,options)
}

GetJSONFrostLatest1H.prototype= Object.create(GetJSONFrost.prototype)

GetJSONFrostLatest1H.prototype.sendRequest=function()
{
    this.req.open("GET",this.url)
    this.req.setRequestHeader("Accept","application/json")
    this.req.setRequestHeader("Authorization", this.options.authorization);
    this.req.send()
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

    this.requestInterval={
        hour1:   3600000,
        min15:    900000,
        min10:    600000,
        min5:     300000,
        min1:      60000,
        second16:  16000
    }

    this.options={
        stationName: 'GW Tomasjord',
        interval: this.requestInterval.second16,  //  milliseconds (ms) request time for livedata JSON
        slow_interval: this.requestInterval.min1,           // ms slow request for livedata JSON
        fastRequestTimeout : this.requestInterval.min5,   // ms before starting slow request interval for livedata JSON
        fastRedrawTimeout : this.requestInterval.min5,    // ms before, reverting to fixed redraw interval, during fast redraw charts are redrawn as fast as the JSON request interval
        redraw_interval: this.requestInterval.min1,         // ms between each chart redraw
        tooltip: !isLowMemoryDevice,              // turn off for ipad1 - slow animation/disappearing
        animation: false,               // turn off animation for all charts
        addpointIfChanged : true,       // only addpoint if value changes (keep memory footprint low),
        shift: false,                   // shift series flag
        shift_measurements_ipad1: 2250, // number of measurements before shifting (3600/16=225 samples/hours*10 hours)
        shift_measurements: 5400,       // 1 day= 225 samples*24 hours =5400
        invalid_security_certificate : isLowMemoryDevice, // have outdated security certificates for https request
        rangeSelector: !isLowMemoryDevice,        // keeps memory for series
        mousetracking: !isLowMemoryDevice,        // allocates memory for duplicate path for tracking
        forceLowMemoryDevice : forceLowMemoryDevice,        // for testing
        // navigator.languauge is "en-us" for LG Smart TV 2012
        frostapi : {
            doc: 'https://frost.met.no/index.html',
            authorization: "Basic " + btoa("2c6cf1d9-b949-4f64-af83-0cb4d881658a:"), // http basic authorization header 
            enabled : true && ( (navigator.language.toLowerCase().indexOf('nb') !== -1) || this.isLGSmartTV2012()),    // use REST api from frost.met.no - The Norwegian Meterological Institute CC 4.0  
            stationName: 'METno SN90450 Tromsø',
            stationId: 'SN90450'
        },
        wundergroundapi: {
            doc: 'https://docs.google.com/document/d/1eKCnKXI9xnoMGRRzOL1xPCBihNV2rOet08qpE_gArAY',
            apiKey: '9b606f1b6dde4afba06f1b6dde2afb1a', // get a personal api key from https://www.wunderground.com/member/api-keys
            stationId: 'IENGEN26',
            stationName: 'WU IENGEN26 Engenes',
            interval: this.requestInterval.min15,
            enabled : true
        },
        holfuyapi: {
            doc: 'http://api.holfuy.com/live/', // does not support CORS in Chrome/Edge (use curl on backend?), but works in Firefox 100.0.1
            stationId: '101', // Test
            stationName: 'test',
            interval: this.requestInterval.hour1,
            enabled: false
        }
    }

    //this.options.maxPoints=Math.round(this.options.shifttime*60*1000/this.options.interval) // max number of points for requested shifttime

    this.initCharts()
  
    if (window.location.hostname === '127.0.0.1') // assume web server runs on port 80
        // Visual studio code live preview uses 127.0.0.1:3000
      port=80
    else
      port=window.location.port

    this.METnoLatestObservation={}

    this.initJSONRequests(port)
    //this.testMemory()
    
}

UI.prototype.testMemory=function()
// Allocates 1MB until memory is exausted and generates LowMemory log on ipad1
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

UI.prototype.initJSONRequests=function(port)
{

    this.getJSON=new GetJSON(window.location.origin+'/api/livedata',this.options.interval,this.options)
    this.getJSON.req.addEventListener("load",this.onJSON.bind(this))
    setTimeout(this.getJSON.sendRequestInterval.bind(this.getJSON,this.options.slow_interval),this.options.fastRequestTimeout)

    //this.getJSONFrost = new GetJSONFrost(window.location.hostname,port,'/api/frost.met.no/latest-hourly',this.options.frostapi_interval,this.options)
    //this.getJSONFrost.req.addEventListener("load",this.onJSONFrost.bind(this))

    if (this.options.frostapi.enabled) {
        this.getJSONFrostLatest15Min = new getJSONFrostLatest15Min(window.location.origin+'/api/frost.met.no/latest-15min',this.requestInterval.min15,this.options)
        this.getJSONFrostLatest15Min.req.addEventListener("load",this.onJSONFrostLatest15Min.bind(this))

        this.getJSONFrostLatest1H = new GetJSONFrostLatest1H(window.location.origin+'/api/frost.met.no/latest-1H',this.requestInterval.hour1,this.options)
        this.getJSONFrostLatest1H.req.addEventListener("load",this.onJSONFrostLatest1H.bind(this))
    }

    if (this.options.wundergroundapi.enabled) {
        var wu=this.options.wundergroundapi
        this.getJSONWUCurrentConditions = new GetJSONWUCurrentConditions('https://api.weather.com/v2/pws/observations/current?apiKey='+wu.apiKey+'&stationId='+wu.stationId+'&numericPrecision=decimal&format=json&units=m',this.options.wundergroundapi.interval,this.options)
        this.getJSONWUCurrentConditions.req.addEventListener("load",this.onJSONWUCurrentConditions.bind(this))
    }

    if (this.options.holfuyapi.enabled)
    {
        var holfuyapi=this.options.holfuyapi
        // https://holfuy.com/puget/mjso.php?k=299 - has wind_chill temperature
        //this.getJSONHolfuyLive = new GetJSONHolfuyLive('http://api.holfuy.com/live/?s='+holfuyapi.stationId+'&m=JSON&tu=C&su=m/s',holfuyapi.interval,this.options)
        this.getJSONHolfuyLive.req.addEventListener("load",this.onJSONHolfuyLive.bind(this))

    } 
}

UI.prototype.onJSONHolfuyLive=function(evt)
{
    console.log('holfuy',evt)
}

UI.prototype.addObservationsMETno=function()
{
    var series,
        observation,
        obsNr,
        elementId,
        lastOptionsData,
        subtitle

    for (elementId in this.METno) 
    {
        switch (elementId)
        {
            case 'air_pressure_at_sea_level' :

                if (this.pressurechart)
                    series = this.pressurechart.series[2]
                break
            
            case 'air_temperature' :

                if (this.temperaturechart) {
                    series=this.temperaturechart.series[4]
                }

                break

            
            case 'relative_humidity' :
                
                if (this.temperaturechart)
                    series=this.temperaturechart.series[5]
                break

            case 'wind_speed' :

                if (this.windbarbchart)
                    series=this.windbarbchart.series[3]
                break

            case 'max(wind_speed PT1H)':

                if (this.windbarbchart)
                    series=this.windbarbchart.series[3]
                break
                
            // Multi-criteria case https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/switch
            case 'max(wind_speed_of_gust PT1H)':
            case 'max(wind_speed_of_gust PT10M)':

                if (this.windbarbchart)
                    series=this.windbarbchart.series[4]
                break

            case 'mean(surface_downwelling_shortwave_flux_in_air PT1H)' :
            case 'mean(surface_downwelling_shortwave_flux_in_air PT1M)' :
                
                if (this.solarchart)
                    series=this.solarchart.series[2]
                break

            default : 
                
                console.error('Unsupported elementId '+elementId+' not added to series')
                break
        }

        if (series) {
            for (obsNr=0;obsNr<this.METno[elementId].length;obsNr++) {
                observation=this.METno[elementId][obsNr]
               lastOptionsData=series.options.data.slice(-1)
              // console.log('lastOptionsData',lastOptionsData,series.name)
               if ((lastOptionsData.length===1 && lastOptionsData[0][0]!==observation.timestamp)|| lastOptionsData.length===0) {
                //    console.log('addpoint',series.name,[observation.timestamp,observation.value])
                    series.addPoint([observation.timestamp,observation.value],false,this.options.shift,this.options.animation,false)
               }
                else
                  console.warn(elementId+' Skippping observation already is series; timestamp '+observation.timestamp+' value '+observation.value,series) // same value of relative_humidity and air_pressure_at_at_sea_level each 1h is included each 10m in JSON

            }
            series=undefined
        }

    }
}

UI.prototype.updateLatestMETno=function()
{
     var METno=this.METno,
        latest=this.METnoLatestObservation

    // Copy latest observation

    for (elementId in METno)
       latest[elementId]=METno[elementId][METno[elementId].length-1]

    console.log('METnoLatestObservation',latest)
}

UI.prototype.onJSONFrostLatest15Min=function(evt)
{

    var redraw=false,
        animation=this.options.animation

    this.METno=this.getJSONFrostLatest15Min.METno
    this.updateLatestMETno()
    this.addObservationsMETno()

    if (this.latestChart)
    {
        var stationIndex=2 // METno

        if (this.METnoLatestObservation.air_temperature)
            this.latestChart.get('series-temperature').options.data[stationIndex]=this.METnoLatestObservation.air_temperature.value

        if (this.METnoLatestObservation.relative_humidity)
            this.latestChart.get('series-humidity').options.data[stationIndex]=this.METnoLatestObservation.relative_humidity.value
        
        if (this.METnoLatestObservation.wind_speed)
            this.latestChart.get('series-windspeed').options.data[stationIndex]=this.METnoLatestObservation.wind_speed.value
        
        if (this.METnoLatestObservation['max(wind_speed_of_gust PT10M)'])
            this.latestChart.get('series-windgust').options.data[stationIndex]=this.METnoLatestObservation['max(wind_speed_of_gust PT10M)'].value

        if (this.METnoLatestObservation.wind_from_direction)
            this.latestChart.get('series-winddirection').options.data[stationIndex]=this.METnoLatestObservation.wind_from_direction.value

        
        if (this.METnoLatestObservation.air_pressure_at_sea_level)
            this.latestChart.get('series-relbaro').options.data[stationIndex]=this.METnoLatestObservation.air_pressure_at_sea_level.value
        
        if (this.METnoLatestObservation['mean(surface_downwelling_shortwave_flux_in_air PT1M)'])
            this.latestChart.get('series-irradiance').options.data[stationIndex]=this.METnoLatestObservation['mean(surface_downwelling_shortwave_flux_in_air PT1M)'].value
        
        this.latestChart.series.forEach(function (series) {
            series.setData(series.options.data,redraw,animation)
        })
        

    } 
}

UI.prototype.onJSONFrost=function(evt)
{
   this.METno=this.getJSONFrost.METno
   this.updateLatestMETno()
   this.addObservationsMETno()
}

UI.prototype.onJSONFrostLatest1H=function(evt)
{
    this.METno=this.getJSONFrostLatest1H.METno
    this.updateLatestMETno()
    this.addObservationsMETno()
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

UI.prototype.onJSONWUCurrentConditions=function(evt)
{
    var wuCurrentConditionsJSON=this.getJSONWUCurrentConditions,
        redraw=false,
        animation=this.options.animation
        stationIndex=1 // Wunderground

    //console.log('wu cc',evt,this)
    if (this.latestChart)
    {
        this.latestChart.get('series-temperature').options.data[stationIndex]=wuCurrentConditionsJSON.outtemp()
        this.latestChart.get('series-windchill').options.data[stationIndex]=wuCurrentConditionsJSON.windchill()
        this.latestChart.get('series-humidity').options.data[stationIndex]=wuCurrentConditionsJSON.outhumidity()
        this.latestChart.get('series-windspeed').options.data[stationIndex]=wuCurrentConditionsJSON.wind_speed()
        this.latestChart.get('series-windgust').options.data[stationIndex]=wuCurrentConditionsJSON.windgust_speed()
        this.latestChart.get('series-winddirection').options.data[stationIndex]=wuCurrentConditionsJSON.winddirection()
        this.latestChart.get('series-relbaro').options.data[stationIndex]=wuCurrentConditionsJSON.relbaro()
        this.latestChart.get('series-irradiance').options.data[stationIndex]=wuCurrentConditionsJSON.solar_light()
        
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
    var tempSeries=[
        {
                name: 'Outdoor',
                type: 'spline',
                yAxis: 0,
                data: [],
                zIndex: 5
            },
            {
                name: 'Indoor',
                type: 'spline',
                data: [],
                yAxis: 0,
                visible: false,
                zIndex: 5
            },
            {
                name: 'Outdoor humidity',
                type: 'spline',
                data: [],
                yAxis: 1,
                visible: false,
                tooltip: {
                    valueSuffix: ' %'
                },
                zIndex: 4
            },
            {
                name: 'Indoor humidity ',
                type: 'spline',
                data: [],
                
                yAxis: 1,
                visible: false,
                tooltip: {
                    valueSuffix: ' %'
                },
                zIndex : 4
            }
           ] 

    if (this.options.frostapi.enabled)
           tempSeries.push(  {
            name: 'METno Temperature 10min',
            type: 'spline',
            yAxis: 0,
            data: [],
            visible: false,
            zIndex : 2
        }, {
            name: 'METno Humidity 1h',
            type: 'spline',
            yAxis: 1,
            data: [],
            visible: false,
            zIndex : 1
        })
    
    this.temperaturechart= new Highcharts.stockChart({ 
        chart : {
            animation: this.options.animation,
            renderTo: 'temperaturechart',
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
            //max : null
            //max : 1.0
        //  max : 40
        },
        // humidity
        {
            title:false,
            //opposite: true,
            min: 0,
            max: 100
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

        series: tempSeries
        
   })

}

UI.prototype.initPressureChart=function()
{
    var pressureSeries=[
        {
                name: 'Relative',
                type: 'spline',
                data: []
            },
            {
                name: 'Absolute',
                type: 'spline',
                data: [],
                visible: false
            }]
    
        if (this.options.frostapi.enabled) {
           pressureSeries.push(
            {
                name: 'METno Sea-level pressure (QFF) 1h',
                type: 'spline',
                data: [],
                visible: false
            })
        }
            
    
        this.pressurechart= new Highcharts.stockChart({ chart : {
            animation: this.options.animation,
            renderTo: 'pressurechart',
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
                }
            }
        },
    
        series: pressureSeries,

        })
}

UI.prototype.initLatestChart=function()
{
    var stationNames=[]
    stationNames.push(this.options.stationName)
    stationNames.push(this.options.wundergroundapi.stationName)
    stationNames.push(this.options.frostapi.stationName)

    this.latestChart=new Highcharts.chart('latestChart',
                            { chart : { 
                                 animation: this.options.animation
                                },
                                title: {
                                    text: 'Latest observations'
                                },
                                credits: {
                                    enabled: false
                                },
                                // Temperature
                                yAxis: [{
                                    title: { text : 'Temperature' },
                                    //max: 60
                                },
                                // Humidity
                                {
                                    min: 0,
                                    max: 100,
                                    title: { text : 'Humidity' },
                                    opposite: true,
                                    visible: false
                                },
                                    // Wind
                                    {
                                        min: 0,
                                        title: { text : 'Wind speed' },
                                        opposite: true,
                                    },
                                    // Wind direction
                                    {
                                        min: 0,
                                        title: { text : 'Wind dir.' },
                                        opposite: true,
                                        visible: false
                                    },
                                    // Pressure
                                    {
                                        min: 0,
                                        title: false,
                                        opposite: true,
                                        visible: false
                                    },
                                    // Irradiance
                                    {
                                        min: 0,
                                        title: false,
                                        visible: false
                                    }
                            ],
                                xAxis: [{
                                 type: 'column',
                                 categories: stationNames
                                }],
                               
                                tooltip: {
                                    enabled: this.options.tooltip
                                },
                                caption : { 
                                    text: 'Sources: GW http:/*//api/livedata, WU data https://api.weather.com, METno data https://frost.met.no - CC 4.0'
                                },
                                series: [
                                    {
                                        name: 'Temperature',
                                        id: 'series-temperature',
                                        type: 'column',
                                        dataLabels: {
                                            enabled: true
                                        }
                                    },
                                    {
                                        name: 'Windchill',
                                        id: 'series-windchill',
                                        type: 'column',
                                        dataLabels: {
                                            enabled: true
                                        },
                                        visible: false
                                    },
                                    {
                                        name: 'Humidity',
                                        id: 'series-humidity',
                                        type: 'column',
                                        yAxis: 1,
                                        dataLabels: {
                                            enabled: true
                                        },
                                        visible: false
                                    },
                                    {
                                        name: 'Wind speed',
                                        id: 'series-windspeed',
                                        type: 'column',
                                        yAxis: 2,
                                        dataLabels: {
                                            enabled: true,
                                            // https://www.highcharts.com/docs/chart-concepts/labels-and-string-formatting?_ga=2.200835883.424482256.1654686807-470753587.1650372441#format-strings
                                            format : '{point.y:.1f}'
                                        }
                                    },
                                    {
                                        name: 'Wind gust',
                                        id: 'series-windgust',
                                        type: 'column',
                                        yAxis: 2,
                                        dataLabels: {
                                            enabled: true,
                                            format : '{point.y:.1f}'
                                        }
                                    },
                                    {
                                        name: 'Wind dir.',
                                        id :'series-winddirection',
                                        type: 'column',
                                        yAxis: 3,
                                        dataLabels: {
                                            enabled: true
                                        }
                                    },
                                    {
                                        name: 'Pressure',
                                        id: 'series-relbaro',
                                        type: 'column',
                                        yAxis: 4,
                                        dataLabels: {
                                            enabled: true,
                                            format : '{point.y:.1f}'
                                        },
                                        visible: false
                                    },
                                    {
                                        name: 'Irradiance',
                                        id: 'series-irradiance',
                                        type: 'column',
                                        yAxis: 5,
                                        dataLabels: {
                                            enabled: true
                                        },
                                        visible: false
                                    }
                                   
                            ]
                            })

    this.latestChart.series.forEach(function (series) {
        
    series.options.data=[]; 
            
       series.xAxis.categories.forEach(function (category) { 
            series.options.data.push(null ) 
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
                                            enabled: true
                                        }
                                            
                                    },
                                    {
                                        name: 'Rain',
                                        type: 'column',
                                        data: [],
                                        yAxis: 1,
                                        dataLabels: {
                                            enabled: true
                                        },
                                    },
                                    {
                                        name: 'Rain MET.no',
                                        type: 'column',
                                        data: [],
                                        yAxis: 1,
                                        dataLabels: {
                                            enabled: true
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
                            tickInterval: 0.1
                           
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
                                    zones: [
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
                name: 'Irradiance',
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
                
                zones: [{
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
               ]
            }] 
        
        if (this.options.enabled)
          solarSeries.push( {
            // shortwave 295-2800nm (ultraviolet,visible,infrared)
            //https://frost.met.no/elements/v0.jsonld?fields=id,oldElementCodes,category,name,description,unit,sensorLevelType,sensorLevelUnit,sensorLevelDefaultValue,sensorLevelValues,cmMethod,cmMethodDescription,cmInnerMethod,cmInnerMethodDescription,status&lang=en-US
            // https://frost.met.no/elementtable
            name: 'METno Solar mean 1m',
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
        zIndex: 3
    },
    {
        type: 'areaspline',
        data: [],
        zIndex: 2,
        name: 'Wind gust',
    }]

    if (this.options.frostapi.enabled)
    {
       windSeries.push(
        {
            type: 'spline',
            data: [],
            //zIndex: 2,
            name: 'METno Wind mean 10min',
            visible: false
        })

       windSeries.push(
        {
            type: 'spline',
            data: [],
            //zIndex: 2,
            name: 'METno Wind gust max 10min',
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

    if (this.isLGSmartTV2012()) {

        this.initTemperatureChart()
        this.initWindBarbChart() 
        this.initWindroseChart()
        this.initPressureChart()
        //this.initRainChart()
        //this.initRainstatChart()
        this.initSolarChart()
    } else {
        this.initLatestChart()
        this.initTemperatureChart()
        this.initWindBarbChart() 
        this.initWindroseChart()
        this.initPressureChart()
        this.initRainChart()
        this.initRainstatChart()
        this.initSolarChart() 
    }
}

UI.prototype.onJSON=function (ev)
{
    var json=this.getJSON
    // Show when data is available
   // if (this.weatherElement.style.display==="none")
   //   this.weatherElement.style.display="block"

    this.measurementCount=this.measurementCount+1

    if (this.measurementCount===1 )
    {
        if (this.options.tooltip.enabled) {
            if (this.rainchart) {
                this.rainchart.series[0].tooltipOptions.valueSuffix=' '+json.unitRainrate()
                this.rainchart.series[1].tooltipOptions.valueSuffix=' '+json.unitRain()
                this.rainchart.series[2].tooltipOptions.valueSuffix=' '+json.unitRain()
            }
            if (this.windbarbchart)
                this.windbarbchart.series.forEach(function (series) { series.tooltipOptions.valueSuffix=' '+json.unitWind()})
            if (this.temperaturechart) {
                this.temperaturechart.series[0].tooltipOptions.valueSuffix=' '+json.unitTemp()
                this.temperaturechart.series[1].tooltipOptions.valueSuffix=' '+json.unitTemp()
            }
            if (this.pressurechart) {
                this.pressurechart.series[0].tooltipOptions.valueSuffix=' '+json.unitPressure()
                this.pressurechart.series[1].tooltipOptions.valueSuffix=' '+json.unitPressure()
            }
            if (this.solarchart)
                this.solarchart.series[0].tooltipOptions.valueSuffix=' '+json.unitSolarlight()
        }

     
    }

    this.outtempElement.textContent=json.outtemp()
    this.intempElement.textContent=json.intemp()
    this.unitTempElement.textContent=json.unitTemp()

    this.windspeedElement.textContent=json.windspeed()
    this.windgustspeedElement.textContent=json.windgustspeed()
    this.winddirection_compassElement.textContent=json.winddirection_compass()
    this.windgustspeed_beufort_descriptionElement.textContent=json.windgustbeufort_description()
    this.unitWindElement.textContent=json.unitWind()
    this.meter_windgustspeedElement.value=json.windgustspeed()

    this.relbaroElement.textContent=json.relbaro()
    this.absbaroElement.textContent=json.absbaro()
    this.unitpressureElement.textContent=json.unitPressure()

    this.solar_lightElement.textContent=json.solar_light()
    this.unit_solar_lightElement.textContent=json.unitSolarlight()
    this.solar_uvElement.textContent=json.solar_uv()
    this.unit_solar_uvElement.textContent=json.unitSolarUV()
    this.solar_uviElement.textContent=json.solar_uvi()

    this.updateCharts()

    if (!this.fastRedrawTimeoutId)
    {
        console.log('Setting fast redraw timeout '+this.options.fastRedrawTimeout)
        this.fastRedrawTimeoutId=setTimeout(this.setChartRedrawInterval.bind(this),this.options.fastRedrawTimeout)
        this.redrawChart()
    } else if (!this.chartRedrawIntevalId)
        this.redrawChart()

}

UI.prototype.setChartRedrawInterval=function()
{
    if  (!this.chartRedrawIntevalId)
    {
      this.redrawChart()
      console.log('Setting chart redraw interval '+this.options.redraw_interval)
      this.chartRedrawIntevalId=setInterval(this.redrawChart.bind(this),this.options.redraw_interval)
    }
}

UI.prototype.updateCharts=function()
{
    var livedataJSON=this.getJSON,
        timestamp=livedataJSON.timestamp(),
        redraw=false,
        animation=this.options.animation

    //this.pressurechart.subtitle.element.textContent='Relative ' + livedataJSON.pressureToString(livedataJSON.relbaro()) + ' Absolute ' + livedataJSON.pressureToString(livedataJSON.absbaro())

    // Remove data if too old, otherwise they get skewed to the left
  //  if (this.windbarbchart.series[0].xData.length >= 1 &&   ( timestamp - this.windbarbchart.series[0].xData[this.windbarbchart.series[0].xData.length-1]) > this.options.interval*this.options.maxPoints)
  //  {
  //      //console.log('Removing data from chart to avoid skewed presentation, max points: '+this.options.maxPoints)
  //      this.measurementCount=0
  //      this.windrosechart.series.forEach(function (element) { element.setData([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]) })
  //      this.temperaturechart.series.forEach(function (element) { element.setData([]) })
  //      this.pressurechart.series.forEach(function (element) { element.setData([]) })
  //      this.windbarbchart.series.forEach(function (element) { element.setData([]) })
  //      this.solarchart.series.forEach(function (element) { element.setData([]) })
  //  }

     if (this.latestChart) {
         var stationIndex=0
        this.latestChart.get('series-temperature').options.data[stationIndex]=livedataJSON.outtemp()
        //this.latestChart.series[0].options.data[1]=livedataJSON.intemp()
        this.latestChart.get('series-humidity').options.data[stationIndex]=livedataJSON.outhumidity()
        //this.latestChart.series[1].options.data[1]=livedataJSON.inhumidity()
        this.latestChart.get('series-windspeed').options.data[stationIndex]=livedataJSON.windspeed_mps()
        this.latestChart.get('series-windgust').options.data[stationIndex]=livedataJSON.windgustspeed_mps()
        this.latestChart.get('series-winddirection').options.data[stationIndex]=livedataJSON.winddirection()
        this.latestChart.get('series-relbaro').options.data[stationIndex]=livedataJSON.relbaro()
        this.latestChart.get('series-irradiance').options.data[stationIndex]=livedataJSON.solar_light()

        this.latestChart.series.forEach(function (series) {
            series.setData(series.options.data,redraw,animation)
        })
        
    }
    
   
    //console.log(this.windrosedata)
    if (this.windrosechart) {
         var newBeufortScale=livedataJSON.windgustspeed_beufort()
        var newCompassDirection=livedataJSON.winddirection_compass_value()-1 
          var beufort
        var percentArr
        this.windrosedata[newBeufortScale][newCompassDirection]=this.windrosedata[newBeufortScale][newCompassDirection]+1
      
        for (beufort=0;beufort<12;beufort++) {
            percentArr=[]
            this.windrosedata[beufort].forEach(function (measurement) { 
                percentArr.push(measurement/this.measurementCount*100)
            }.bind(this))
            //console.log('percentarray',percentArr)
            this.windrosechart.series[beufort].setData(percentArr,redraw,this.options.animation,true) // updatePoints=true 
        }
    }

    if (this.temperaturechart) {
        var dataLength=this.temperaturechart.series[0].options.data.length 
        
        if (!this.options.shift && ((this.isLowMemoryDevice() && (dataLength > this.options.shift_measurements_ipad1)) ||  dataLength > this.shift_measurements))
        {
            console.log(Date()+'Starting to shift series, data length '+ dataLength)
            this.options.shift=true
        }

        this.addpointIfChanged(this.temperaturechart.series[0],[timestamp,livedataJSON.outtemp()])
        this.addpointIfChanged(this.temperaturechart.series[1],[timestamp,livedataJSON.intemp()])
        this.addpointIfChanged(this.temperaturechart.series[2],[timestamp,livedataJSON.outhumidity()])
        this.addpointIfChanged(this.temperaturechart.series[3],[timestamp,livedataJSON.inhumidity()])
    }

    // https://api.highcharts.com/class-reference/Highcharts.Series#addPoint
    
   if (this.pressurechart) {
        this.addpointIfChanged(this.pressurechart.series[0],[timestamp,livedataJSON.relbaro()])
        this.addpointIfChanged(this.pressurechart.series[1],[timestamp,livedataJSON.absbaro()])
   }

   if (this.windbarbchart) {
        this.windbarbchart.series[0].addPoint([timestamp,livedataJSON.windgustspeed_mps(),livedataJSON.winddirection()],redraw,this.options.shift,this.options.animation,false)
        
        // https://api.highcharts.com/highcharts/series.line.data
        // only support m/s unit
        //this.windbarbchart.series[1].addPoint({ x: timestamp, y: livedataJSON.windspeed_mps() },redraw,this.options.shift,this.options.animation,false)
        this.addpointIfChanged(this.windbarbchart.series[1],[timestamp,livedataJSON.windspeed_mps()])
        //this.windbarbchart.series[2].addPoint({ x: timestamp, y: livedataJSON.windgustspeed_mps() },redraw,this.options.shift,this.options.animation,false)
        this.addpointIfChanged(this.windbarbchart.series[2],[timestamp,livedataJSON.windgustspeed_mps()])
        var winddailymax=livedataJSON.winddailymax()
        if (winddailymax)
        {
            //this.windbarbchart.series[3].setData([['Wind daily max.',winddailymax]],false,this.options.animation,true)
        }
    }

    if (this.solarchart) {
        //this.solarchart.series[0].addPoint([timestamp,livedataJSON.solar_light()],false,this.options.shift,this.options.animation,false)
        this.addpointIfChanged(this.solarchart.series[0],[timestamp,livedataJSON.solar_light()])
        // this.solarchart.series[1].addPoint([timestamp,livedataJSON.solar_uv()],false, this.solarchart.series[1].points.length>37, false)
        this.addpointIfChanged(this.solarchart.series[1],[timestamp, livedataJSON.solar_uvi()])
    }

    if (this.rainchart) {
        this.addpointIfChanged(this.rainchart.series[0],[timestamp,livedataJSON.rainrate()])
        this.addpointIfChanged(this.rainchart.series[1],[timestamp,livedataJSON.rainevent()])
        this.addpointIfChanged(this.rainchart.series[2],[timestamp,livedataJSON.rainday()])
    }

    if (this.rainstatchart) {
        this.rainstatchart.series[0].setData([['hour',livedataJSON.rainhour()],['day',livedataJSON.rainday()],['event',livedataJSON.rainevent()],['week',livedataJSON.rainweek()]],redraw,this.options.animation)
        this.rainstatchart.series[1].setData([null,null,null,null,['month',livedataJSON.rainmonth()],['year',livedataJSON.rainyear()]],redraw,this.options.animation)
    }
   // console.log('data min/max',this.windchart.series[0].yAxis.dataMin,this.windchart.series[0].yAxis.dataMax)
   
}

UI.prototype.addpointIfChanged=function(series,xy)
// Added to limit the number of points generated/memory footprint, for example not necessary to store alot of points when rainrate is constantly 0 
{
    series.addPoint(xy,false,this.options.shift,this.options.animation,false)
    // optimization deprecated, series may be grouped automatically by Highstock, hard to update latest point
}

UI.prototype.redrawChart=function()
{
    // https://api.highcharts.com/class-reference/Highcharts.Axis#setExtremes
   // y-axis start on 0 by default
    
   if (this.pressurechart) {
        if (this.pressurechart.series[0].dataMin && this.pressurechart.series[0].dataMax)
                this.pressurechart.series[0].yAxis.setExtremes(this.pressurechart.series[0].dataMin-2,this.pressurechart.series[0].dataMax+2,false)
    }
    //console.log('redraw all charts')
    Highcharts.charts.forEach(function (chart) { chart.redraw() })

}

https://stackoverflow.com/questions/15455009/javascript-call-apply-vs-bind
if (!Function.prototype.bind)
{
    //console.log('javascript bind not found, creating new Function.prototype.bind,'+window.navigator.userAgent)
    Function.prototype.bind = function(ctx) {
        var fn = this,
            args=Array.prototype.slice.call(arguments,1) // Shallow copy - points to same memory - arguments when creating function with .bind(this,...)
        return function() {
            //https://gist.github.com/MiguelCastillo/38005792d33373f4d08c
            fn.apply(ctx, args.concat(Array.prototype.slice.call(arguments))); // conact to append arguments when calling
        };
    };
}

Number.isInteger = Number.isInteger || function(value) {
    return typeof value === 'number' && 
      isFinite(value) && 
      Math.floor(value) === value;
  };


window.onload = function init() {
   // console.log('onload event, init ui')
   // console.log('window location',window.location)
   try {
        var ui = new UI()
   } catch (err)
   {
       console.error(JSON.stringify(err))
   }
    
}

