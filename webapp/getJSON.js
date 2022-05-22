// by default functions are added to window object

function GetJSON(host,port,path,interval,options) {
// https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest
// https://stackoverflow.com/questions/1973140/parsing-json-from-xmlhttprequest-responsejson
// https://developer.mozilla.org/en-US/docs/Web/API/setInterval
    var defaultInterval=16000

    this.host=host
    this.port=port
    this.path=path
    this.options=options

    if (interval === undefined) {
        console.log('using default interval: '+defaultInterval)
        this.interval=defaultInterval
    } else
    {
        this.interval=interval
    }
    
    this.setUrl(host,port,path)

    this.req=new XMLHttpRequest()
    
    this.req.addEventListener("load", this.transferComplete.bind(this))
    this.req.addEventListener("error", this.transferError.bind(this))
    this.req.addEventListener("onabort",this.transferAbort.bind(this))

    this.setJSONRequestInterval(this.interval)

    // add pressure calibration value from met.no
    if (options.frostapi) 
    {
        
        this.reqFrost=new XMLHttpRequest()
        this.reqFrost.addEventListener('load',this.transferFrostComplete.bind(this))
        this.reqFrost.addEventListener('error',this.transferFrostError.bind(this))

        this.reqFrostPrecipitationHour= new XMLHttpRequest()
        this.reqFrostPrecipitationHour.addEventListener('load',this.reqFrostPrecipitationHourComplete.bind(this))
        this.reqFrostPrecipitationHour.addEventListener('error',this.reqFrostPrecipitationHourError.bind(this))

        this.setJSONFrostRequestInterval(options.frostapi_interval) 

        
    }
  
  }

GetJSON.prototype.WindCompassDirection = {
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

GetJSON.prototype.setJSONRequestInterval= function(interval)
{
    this.requestLivedata()

    if (this.requestIntervalID != null && this.requestIntervalID != undefined) {
       // console.log('clearing interval id:'+this.requestIntervalID)
        clearInterval(this.requestIntervalID)
    }
    
    this.requestIntervalID=setInterval(this.requestLivedata.bind(this),interval)
    //console.log('Interval:'+interval+' id:'+this.requestIntervalID)
}

GetJSON.prototype.requestLivedata=function()
{
    //req.overrideMimeType('')
    //req.overrideMimeType("application/json")
    this.req.open('GET',this.url)
    this.req.setRequestHeader("Accept","application/json")
    this.req.send()
}

GetJSON.prototype.requestFrost=function()
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
             authentication="Basic " + btoa("2c6cf1d9-b949-4f64-af83-0cb4d881658a:"),
             frostapi_url='https://frost.met.no/observations/v0.jsonld', // Webserver does not send Access-Control-Allow-Origin: * -> cannot use in Chrome -> use proxy server?
             //frostapi_url='https://rim.k8s.met.no/api/v1/observations' // Allow CORS -> can use in browser
             latestHourURL='https://frost.met.no/observations/v0.jsonld?elements=air_temperature,surface_snow_thickness,air_pressure_at_sea_level,relative_humidity,max(wind_speed%20PT1H),max(wind_speed_of_gust%20PT1H),wind_from_direction,mean(surface_downwelling_shortwave_flux_in_air%20PT1H)&referencetime=latest&sources=SN90450&timeresolutions=PT1H&timeresolutions=PT0H',
             precipitation_calibration_month_url=frostapi_url+'?sources='+sourceId+'referenceTime=2021-05-01T00:00:00Z/2022-05-31T23:59:59Z&elements=sum(precipitation_amount%20P1M)&timeResolution=months',
             precipitationHourURL=frostapi_url+'?sources='+sourceId+'&referencetime='+dateISOMidnight.toISOString().split('.')[0]+'Z'+'/'+dateISO+'&elements=sum(precipitation_amount%20PT1H)&timeResolution=hours'

        latestHourURL='/api/frost.met.no/latest-hour' // use curl on local network web server to bypass CORS
        this.reqFrost.open("GET",latestHourURL)
        this.reqFrost.setRequestHeader("Accept","application/json")
        this.reqFrost.setRequestHeader("Authorization", authentication);
        console.log('Sending GET '+latestHourURL)
        this.reqFrost.send()

       // this.reqFrostPrecipitationHour.open("GET",precipitationHourURL)
       // this.reqFrostPrecipitationHour.setRequestHeader("Accept","application/json")
       // this.reqFrostPrecipitationHour.setRequestHeader("Authorization", authentication);
       // console.log('Sending GET '+precipitationHourURL)
       // this.reqFrostPrecipitationHour.send()
        
    }

GetJSON.prototype.setJSONFrostRequestInterval= function(interval)
{
    this.requestFrost()

    if (this.requestPressureIntervalID != null && this.requestPressureIntervalID != undefined) {
        clearInterval(this.requestPressureIntervalID)
    }
    
    this.requestPressureIntervalID=setInterval(this.requestFrost.bind(this),interval)
}

GetJSON.prototype.transferAbort = function(ev)
{
    console.warn('request aborted')
}

GetJSON.prototype.setUrl=function(host,port,path)
{ 

    this.url='http://'+host+':'+port+path
    //console.log('request data from url:'+this.url)
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

GetJSON.prototype.transferComplete=function(evt)
{
    //console.log('transfer complete',evt)
    if (this.req.responseText.length > 0) {
        //console.log('json:'+this.req.responseText)
        this.json = JSON.parse(this.req.responseText)
        this.data = this.json.data
        this.unit = this.json.unit
        this.mode = this.json.mode
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

GetJSON.prototype.transferFrostComplete=function(evt)
{
    if (this.reqFrost.responseText.length > 0) {
        //console.log('json:'+this.req.responseText)
        this.jsonFrost = JSON.parse(this.reqFrost.responseText)
    } else
    {
        console.error("No JSON frost received " + this.reqFrost.status+' '+this.reqFrost.statusText)
        delete this.jsonFrost
    }
}

GetJSON.prototype.reqFrostPrecipitationHourComplete=function(evt)
{
    if (this.reqFrostPrecipitationHour.responseText.length > 0) {
        this.jsonFrostPrecipitationHour = JSON.parse(this.reqFrostPrecipitationHour.responseText)
    } else
    {
        console.error("No JSON frost precipitation day received " + this.reqFrostPrecipitationHour.status+' '+this.reqFrostPrecipitationHour.statusText)
        delete this.jsonFrostPrecipitationHour
    }
}

GetJSON.prototype.transferFrostError=function(evt)
{
    console.error('Failed to get calibration pressure '+ this.reqFrost.status+' '+this.reqFrost.statusText)
}

GetJSON.prototype.reqFrostPrecipitationHourError=function(evt)
{
    console.error('Failed to get precipitation day '+ this.reqFrostPrecipitationHour.status+' '+this.reqFrostPrecipitationHour.statusText)
}



function GetEcowittJSON(host,port,path,interval)
{
    GetJSON.call(this,host,port,path,interval)
}

GetEcowittJSON.prototype= Object.create(GetJSON.prototype)
GetEcowittJSON.prototype.outtemp=function()
{
    return this.json.outdoor.temperature.value
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

    var isIpad1=this.isIpad1()

    this.options={
        interval: 16000, // milliseconds request time for JSON
        redraw_interval: 60000, // milliseconds between each chart redraw
        addpoint_simulation: false, // add point every 100ms, testing performance
        addpoint_simulation_interval: 100,
        tooltip: !isIpad1, // turn off for ipad1 - slow animation/disappearing
        animation: false,               // turn off animation for all charts
        addpointIfChanged : true,   // only addpoint if value changes (keep memory footprint low),
        shift: false,               // shift series flag
        shift_measurements_ipad1: 2048, // number of measurements before shifting
        shift_measurements: 5400,
        invalid_security_certificate : isIpad1, // have outdated security certificates for https request
        mousetracking: !isIpad1,    // allocates memory for duplicate path for tracking
        frostapi : true && navigator.language.toLowerCase()==='nb-no',    // use REST api from frost.met.no - The Norwegian Meterological Institute CC 4.0  
        frostapi_interval: 3600000 // request interval 1 hour     
    }

    this.options.maxPoints=Math.round(this.options.shifttime*60*1000/this.options.interval) // max number of points for requested shifttime

    this.initChart()
  
    if (window.location.hostname === '127.0.0.1') // assume web server runs on port 80
        // Visual studio code live preview uses 127.0.0.1:3000
      port=80
    else
      port=window.location.port

    this.getJSON=new GetJSON(window.location.hostname,port,'/api/livedata',this.options.interval,this.options)
    this.getJSON.req.addEventListener("load",this.onJSON.bind(this))
    this.getJSON.reqFrost.addEventListener("load",this.onJSONFrost.bind(this))
    this.getJSON.reqFrostPrecipitationHour.addEventListener("load",this.onJSONFrostPrecipitationHour.bind(this))
    
}

UI.prototype.onJSONFrost=function(evt)
{
    var json=this.getJSON.jsonFrost // set by getJSON eventhandler, otherwise also available in evt.currentTarget.reponseText
    console.log('ui got',json)
   // https://frost.met.no/api.html#!/observations/observations
   if (json['@type'] != 'ObservationResponse' )
   {
       console.error('Not a ObservationResponse type, aborting parsing'+JSON.stringify(json))
       return
   }

   var item,
        obsNr,
        referenceTime,
        timestamp,
        hhmm,
        observation,
        elementId,
        unit

    this.metno={}

   for (item=0;item<json.totalItemCount;item++) // number of data items
   {
        referenceTime=new Date(json.data[item].referenceTime)                      // http query params has timeoffsets=PT0H -> no need to add timeoffset
        timestamp=referenceTime.getTime()-referenceTime.getTimezoneOffset()*60000  // local timezone time
        hhmm=referenceTime.getHours()+':00'

        for (obsNr=0;obsNr<json.data[item].observations.length;obsNr++)
        {
            observation=json.data[item].observations[obsNr]
            elementId=observation.elementId
            unit=observation.unit
            if (unit==='degC')
               unit='℃'
            else if (unit==='percent')
                unit='%'
            else if (unit==='degrees')
               unit='°'
            else if (unit==='W/m2')
              unit='W/㎡'

              this.metno[elementId] = {
                timestamp : timestamp,
                hhmm : hhmm,
                value : observation.value,
                unit : unit
            }

            switch (elementId)
            {
                case 'air_pressure_at_sea_level' :

                    this.pressurechart.series[2].addPoint([timestamp,this.metno.air_pressure_at_sea_level.value],false,this.options.shift,this.options.animation,false)
                    break
                
                case 'air_temperature' :

                    this.temperaturechart.series[4].addPoint([timestamp,this.metno.air_temperature.value],false,this.options.shift,this.options.animation,false)
                    break

                case 'wind_speed' :

                    this.windbarbchart.series[3].addPoint([timestamp,this.metno.wind_speed.value],false,this.options.shift,this.options.animation,false)
                    break

                case 'max(wind_speed PT1H)':
                    this.windbarbchart.series[3].addPoint([timestamp,this.metno['max(wind_speed PT1H)'].value],false,this.options.shift,this.options.animation,false)


                case 'mean(surface_downwelling_shortwave_flux_in_air PT1H)' :
                    this.solarchart.series[2].addPoint([timestamp,this.metno[elementId].value],false,this.options.shift,this.options.animation,false)
                    break
            }
        }

        console.log('metno',this.metno)
   }

  

}

UI.prototype.onJSONFrostPrecipitationHour=function(evt)
{
    var json=this.getJSON.jsonFrostPrecipitationHour
    console.log('ui got',json)
    var precipitationDay=0
    json.data.forEach(function (data) { precipitationDay=precipitationDay+data.observations[0].value})
    var precipitationHour=json.data[json.data.length-1].observations[0].value
    console.log('precipitation today: '+ precipitationDay+' precip. hour: '+precipitationHour)
    this.rainstatchart.series[2].setData([['hour',precipitationHour],['day',precipitationDay],null,null,null],false,this.options.animation)

}

UI.prototype.isIpad1=function()
{
   // "Mozilla/5.0 (iPad; CPU OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B206 Safari/7534.48.3"
   return navigator.userAgent.indexOf("iPad; CPU OS 5_1_1 like Mac OS X")!=-1
}

UI.prototype.initChart=function()
{
    // Windrose demo https://jsfiddle.net/fq64pkhn/
   
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
            text: 'Based on windgust data, values in minutes',
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
                    valueSuffix : ' min.'
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

    var tempSeries=[
        {
                name: 'Outdoor',
                type: 'spline',
                yAxis: 0,
                data: []
               
             //   zIndex: 4
            },
            {
                name: 'Indoor',
                type: 'spline',
                data: [],
              
                yAxis: 0,
                visible: false
           //     zIndex: 3
            },
            {
                name: 'Outdoor humidity',
                type: 'spline',
                data: [],
                yAxis: 1,
                visible: false,
                tooltip: {
                    valueSuffix: ' %'
                }
            //    zIndex: 2
            },
            {
                name: 'Indoor humidity',
                type: 'spline',
                data: [],
                
                yAxis: 1,
                visible: false,
                tooltip: {
                    valueSuffix: ' %'
                }
            //    zIndex: 1
            }
           ] 

    if (this.options.frostapi)
           tempSeries.push(  {
            name: 'Outdoor METno',
            type: 'spline',
            yAxis: 0,
            data: [],
            visible: false
           
        })
    
    this.temperaturechart= new Highcharts.stockChart({ 
        chart : {
            animation: this.options.animation,
            renderTo: 'temperaturechart',
        },

        rangeSelector: {
            enabled: true,
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
            enabled: true
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
                
            }
        },

        series: tempSeries
        
   })

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

    if (this.options.frostapi)
       pressureSeries.push(
        {
            name: 'Sea-level pressure (QFF) MET.no',
            type: 'spline',
            data: [],
            visible: false
        })
        

    this.pressurechart= new Highcharts.stockChart({ chart : {
        animation: this.options.animation,
        renderTo: 'pressurechart',
    },
    tooltip: {
        enabled: this.options.tooltip
    },
    rangeSelector: {
        enabled: true,
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
        enabled: true
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
            enableMouseTracking: this.options.mousetracking
        }
    },

    series: pressureSeries
    })

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
    
    this.rainchart= new Highcharts.stockChart({ chart : {
                            animation: this.options.animation,
                            renderTo: 'rainchart',
                        },
                        rangeSelector: {
                            enabled: true,
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
                            enabled: true
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
                                enableMouseTracking: this.options.mousetracking
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
    
    var solarSeries=[
        {
                name: 'Solar light',
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
                name: 'Solar UVI',
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
        
        if (this.options.frostapi)
          solarSeries.push( {
            // shortwave 295-2800nm (ultraviolet,visible,infrared)
            //https://frost.met.no/elements/v0.jsonld?fields=id,oldElementCodes,category,name,description,unit,sensorLevelType,sensorLevelUnit,sensorLevelDefaultValue,sensorLevelValues,cmMethod,cmMethodDescription,cmInnerMethod,cmInnerMethodDescription,status&lang=en-US
            // https://frost.met.no/elementtable
            name: 'Solar METno',
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
                            enabled: true,
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
                            enabled: true
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
                                enableMouseTracking: this.options.mousetracking
                            }
                        },

                        series: solarSeries
                        })

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
    },
    {
        type: 'spline',
        data: [],
        name: 'Wind max 1h METno',
        visible: false
    },

]

    // based on https://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/demo/windbarb-series/
    this.windbarbchart= new Highcharts.stockChart({ chart : {
        animation: this.options.animation,
        renderTo: 'windbarbchart' },

        rangeSelector: {
            enabled: true,
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
            enabled: true
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
            this.rainchart.series[0].tooltipOptions.valueSuffix=' '+json.unitRainrate()
            this.rainchart.series[1].tooltipOptions.valueSuffix=' '+json.unitRain()
            this.rainchart.series[2].tooltipOptions.valueSuffix=' '+json.unitRain()
            this.windbarbchart.series.forEach(function (series) { series.tooltipOptions.valueSuffix=' '+json.unitWind()})
            this.temperaturechart.series[0].tooltipOptions.valueSuffix=' '+json.unitTemp()
            this.temperaturechart.series[1].tooltipOptions.valueSuffix=' '+json.unitTemp()
            this.pressurechart.series[0].tooltipOptions.valueSuffix=' '+json.unitPressure()
            this.pressurechart.series[1].tooltipOptions.valueSuffix=' '+json.unitPressure()
            this.solarchart.series[0].tooltipOptions.valueSuffix=' '+json.unitSolarlight()
        }

        if (this.options.frostapi) {
            this.pressurechart.setCaption({ text: 'METno data from https://frost.met.no API - CC 4.0'})
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

    if (this.options.addpoint_simulation) 
        setInterval(this.update_charts.bind(this),this.options.addpoint_simulation_interval)
    else
        this.update_charts()

    this.chart_redraw()
}

UI.prototype.startRedrawInterval=function()
{
    if  (!this.chart_redraw_interval_id)
    {
      this.chart_redraw()
      this.chart_redraw_interval_id=setInterval(this.chart_redraw.bind(this),this.options.redraw_interval)
    }
}

UI.prototype.update_charts=function()
{
    var json=this.getJSON,
        timestamp=json.timestamp(),
        simulationSubtitle='',
        shiftseries=false,
        redraw=false

     if (this.options.addpoint_simulation)
     {
       timestamp=Date.now()
       simulationSubtitle='Points '+this.temperaturechart.series[0].points.length
     } 

    var tempSubtitle='<b>Outdoor</b> '+json.outtempToString()+' '+ json.outhumidityToString()+' <b>Indoor</b> '+json.intempToString()+json.inhumidityToString()
    if (this.metno.air_temperature!==undefined)
      tempSubtitle=tempSubtitle+' <b>METno</b> '+this.metno.air_temperature.value+' '+this.metno.air_temperature.unit+' '+this.metno.relative_humidity.value+' '+this.metno.relative_humidity.unit+' '+this.metno.air_temperature.hhmm

    this.temperaturechart.update({ 
        subtitle: { text: tempSubtitle}
        //caption : { text: new Date(timestamp)}
    },redraw)

    var windSubtitle='<b>Speed</b> '+ json.windspeedToString()+' <b>Gust</b> '+ json.windgustspeedToString()+' '+json.winddirection_compass()+' '+json.windgustbeufort_description()
    var winddailymax=json.winddailymax()
    if (winddailymax)
       windSubtitle=windSubtitle+' <b>Max today</b> '+json.winddailymaxToString()

    if (this.metno['max(wind_speed PT1H)'])
      windSubtitle=windSubtitle+' <b>Wind max 1h METno</b> '+this.metno['max(wind_speed PT1H)'].value+' '+this.metno['max(wind_speed PT1H)'].unit+' ('+this.metno.wind_from_direction.value+this.metno.wind_from_direction.unit+') '+this.metno['max(wind_speed PT1H)'].hhmm

    this.windbarbchart.update({ subtitle : { text: windSubtitle }},redraw)
    var solarSubtitle='<b>Radiation</b> '+json.solar_lightToString()+' <b>UVI</b> ' +json.solar_uvi_description() +' ('+json.solar_uvi()+')' 
    if (this.metno['mean(surface_downwelling_shortwave_flux_in_air PT1H)']!==undefined)
        solarSubtitle=solarSubtitle+' <b>METno</b> '+this.metno['mean(surface_downwelling_shortwave_flux_in_air PT1H)'].value+ ' '+this.metno['mean(surface_downwelling_shortwave_flux_in_air PT1H)'].unit+' '+this.metno['mean(surface_downwelling_shortwave_flux_in_air PT1H)'].hhmm

    this.solarchart.update({subtitle : { text: solarSubtitle }},redraw)
    var pressureSubtitle='<b>Relative</b> '+json.pressureToString(json.relbaro())+' <b>Absolute</b> ' + json.pressureToString(json.absbaro())
    if (this.metno.air_pressure_at_sea_level)
       pressureSubtitle=pressureSubtitle+' <b>Sea-level pressure (QFF) METno</b> ' + this.metno.air_pressure_at_sea_level.value.toFixed(1) + ' '+this.metno.air_pressure_at_sea_level.unit +' '+this.metno.air_pressure_at_sea_level.hhmm
    this.pressurechart.update({ subtitle : { text: pressureSubtitle }},redraw)
    this.rainchart.update({subtitle: { text: '<b>Rain rate</b>'+' '+json.rainrateToString()}},redraw)
    //this.pressurechart.subtitle.element.textContent='Relative ' + json.pressureToString(json.relbaro()) + ' Absolute ' + json.pressureToString(json.absbaro())

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

    var beufortScale=json.windgustspeed_beufort()
    var compassDirection=json.winddirection_compass_value()-1 
    var rosePoint=this.windrosechart.series[beufortScale].data[compassDirection]
        rosePoint.update(rosePoint.y+this.options.interval/60000,redraw)
    
    if (!this.options.shift && (this.isIpad1() && this.windbarbchart.series[2].options.data.length > this.options.shift_measurements_ipad1) || this.windbarbchart.series[0].options.data.length > this.shift_measurements)
    {
        console.log(Date()+'Starting to shift series, data length '+ this.windbarbchart.series[2].options.data.length)
        this.options.shift=true
    }

    // https://api.highcharts.com/class-reference/Highcharts.Series#addPoint
    
    this.addpointIfChanged(this.temperaturechart.series[0],[timestamp,json.outtemp()])
    this.addpointIfChanged(this.temperaturechart.series[1],[timestamp,json.intemp()])
    this.addpointIfChanged(this.temperaturechart.series[2],[timestamp,json.outhumidity()])
    this.addpointIfChanged(this.temperaturechart.series[3],[timestamp,json.inhumidity()])
    this.addpointIfChanged(this.pressurechart.series[0],[timestamp,json.relbaro()])
    this.addpointIfChanged(this.pressurechart.series[1],[timestamp,json.absbaro()])
    this.windbarbchart.series[0].addPoint([timestamp,json.windgustspeed_mps(),json.winddirection()],redraw,this.options.shift,this.options.animation,false)
    
    // https://api.highcharts.com/highcharts/series.line.data
    // only support m/s unit
    this.windbarbchart.series[1].addPoint({ x: timestamp, y: json.windspeed_mps() },redraw,this.options.shift,this.options.animation,false)
    this.windbarbchart.series[2].addPoint({ x: timestamp, y: json.windgustspeed_mps() },redraw,this.options.shift,this.options.animation,false)

    var winddailymax=json.winddailymax()
    if (winddailymax)
    {
        //this.windbarbchart.series[3].setData([['Wind daily max.',winddailymax]],false,this.options.animation,true)
    }

   //this.solarchart.series[0].addPoint([timestamp,json.solar_light()],false,this.options.shift,this.options.animation,false)
   this.addpointIfChanged(this.solarchart.series[0],[timestamp,json.solar_light()])
   // this.solarchart.series[1].addPoint([timestamp,json.solar_uv()],false, this.solarchart.series[1].points.length>37, false)
   this.addpointIfChanged(this.solarchart.series[1],[timestamp, json.solar_uvi()])
   this.addpointIfChanged(this.rainchart.series[0],[timestamp,json.rainrate()])
   this.addpointIfChanged(this.rainchart.series[1],[timestamp,json.rainevent()])
   this.addpointIfChanged(this.rainchart.series[2],[timestamp,json.rainday()])

    this.rainstatchart.series[0].setData([['hour',json.rainhour()],['day',json.rainday()],['event',json.rainevent()],['week',json.rainweek()]],redraw,this.options.animation)
    this.rainstatchart.series[1].setData([null,null,null,null,['month',json.rainmonth()],['year',json.rainyear()]],redraw,this.options.animation)

   // console.log('data min/max',this.windchart.series[0].yAxis.dataMin,this.windchart.series[0].yAxis.dataMax)
   
}

UI.prototype.addpointIfChanged=function(series,xy)
// Added to limit the number of points generated/memory footprint, for example not necessary to store alot of points when rainrate is constantly 0 
{
    var data=series.options.data.slice(-2), // get the last two measurements
        lastY,
        secondLastY,
        y=xy[1],
        x=xy[0],
        redraw=false

    if (data && data.length >= 2) {
        lastY=data[1][1],
        secondLastY=data[0][1]
    }

    if (secondLastY === lastY && lastY === y)
    {
        // don't add a new point, update the last point with new timestamp/x value
        if (series.hasData()) // visible
        {
            var point=series.data[series.data.length-1]
            if (point) {
               //console.log('updating point',point.x,point.y,xy,series.name,'time diff:'+(xy[0]-point.x),series.data)
               point.update(xy,redraw)
            }
        }
        //else wait for value to be updated on next measurement
    } else
    //             Series.prototype.addPoint = function (options, redraw, shift, animation, withEvent) {
        series.addPoint(xy,redraw,this.options.shift,this.options.animation,false)

}

UI.prototype.chart_redraw=function()
{
    // https://api.highcharts.com/class-reference/Highcharts.Axis#setExtremes
   // y-axis start on 0 by default
    if (this.pressurechart.series[0].dataMin && this.pressurechart.series[0].dataMax)
        this.pressurechart.series[0].yAxis.setExtremes(this.pressurechart.series[0].dataMin-2,this.pressurechart.series[0].dataMax+2,false)

    //console.log('redraw all charts')
    Highcharts.charts.forEach(function (chart) { chart.redraw() })

}

https://stackoverflow.com/questions/15455009/javascript-call-apply-vs-bind
if (Function.prototype.bind === undefined)
{
    //console.log('javascript bind not found, creating new Function.prototype.bind,'+window.navigator.userAgent)
    Function.prototype.bind = function(ctx) {
        var fn = this;
        return function() {
            fn.apply(ctx, arguments);
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
    var ui = new UI()
    
}

