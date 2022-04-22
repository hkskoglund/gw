
// by default functions are added to window object

function GetJSON(host,port,path,interval) {
// https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest
// https://stackoverflow.com/questions/1973140/parsing-json-from-xmlhttprequest-responsejson
// https://developer.mozilla.org/en-US/docs/Web/API/setInterval
    var defaultInterval=16000

    this.host=host
    this.port=port
    this.path=path

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

    this.requestLivedata()
    this.setInterval(this.interval)
  
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

GetJSON.prototype.setInterval= function(interval)
{
    this.requestLivedata()

    if (this.intervalID != null && this.intervalID != undefined) {
        console.log('clearing interval id:'+this.intervalID)
        clearInterval(this.intervalID)
    }
    
    this.intervalID=setInterval(this.requestLivedata.bind(this),interval)
    console.log('Interval:'+interval+' id:'+this.intervalID)
}

GetJSON.prototype.transferAbort = function(ev)
{
    console.warn('request aborted')
}

GetJSON.prototype.setUrl=function(host,port,path)
{ 

    this.url='http://'+host+':'+port+path
    console.log('request data from url:'+this.url)
}

GetJSON.prototype.getTimestamp=function()
{
    return this.data.timestamp
}

GetJSON.prototype.getOuttemp=function()
{
    return Number(this.data.outtemp.toFixed(1))
}

GetJSON.prototype.getIntemp=function()
{
    return Number(this.data.intemp.toFixed(1))
}

GetJSON.prototype.getWindspeed=function()
{
    //https://javascript.info/number
    return Number(this.data.windspeed.toFixed(1))
}

GetJSON.prototype.getWindgustspeed=function()
{
    return Number(this.data.windgustspeed.toFixed(1))
}


GetJSON.prototype.getWinddirection_compass=function()
{
    return  this.data.winddirection_compass + ' ('+this.data.winddirection+this.unit.winddirection+')'
}

GetJSON.prototype.getWindgustBeufort_description=function()
{
    return this.data.windgustspeed_beufort_description+' ('+this.data.windgustspeed_beufort+')'
}

GetJSON.prototype.getRelbaro= function()
{
    if (this.mode.pressure === this.Mode.pressure_hpa)
        return Number(this.data.relbaro.toFixed(1))
    else if (this.mode.pressure === this.Mode.pressure_inhg)
        return Number(this.data.relbaro.toFixed(2))
}

GetJSON.prototype.getAbsbaro= function()
{
    if (this.mode.pressure === this.Mode.pressure_hpa)
        return Number(this.data.absbaro.toFixed(1))
    else if (this.mode.pressure === this.Mode.pressure_inhg)
        return Number(this.data.absbaro.toFixed(2))
}

GetJSON.prototype.getSolarLight = function()
{
    return Number(this.data.solar_light.toFixed(1))
}

GetJSON.prototype.getSolarUV = function()
{
    return Number(this.data.solar_uv.toFixed(1))
}

GetJSON.prototype.getSolarUVI=function()
{
    return this.data.solar_uvi
}

GetJSON.prototype.getUnitTemp=function()
{
    return this.unit.temperature
}

GetJSON.prototype.getUnitWind=function()
{
    return this.unit.wind
}

GetJSON.prototype.getUnitSolarLight=function()
{
    return this.unit.solar_light
}

GetJSON.prototype.getUnitSolarUV=function()
{
    return this.unit.solar_uv
}

GetJSON.prototype.getUnitPressure=function()
{
    return this.unit.pressure
}

GetJSON.prototype.transferComplete=function(evt)
{
    if (this.req.responseText.length > 0) {
        console.log('json:'+this.req.responseText)
        this.json = JSON.parse(this.req.responseText)
        this.data = this.json.data
        this.unit = this.json.unit
        this.mode = this.json.mode
    } else
    {
        console.error('Empty json response')
        this.json=undefined
    }
}

GetJSON.prototype.transferError=function(evt)
// Chrome: about 2 seconds timeout
{
    console.error('Failed to receive json for '+this.url,evt);
}

GetJSON.prototype.requestLivedata=function()
{
    //req.overrideMimeType('')
    //req.overrideMimeType("application/json")
    this.req.open('GET',this.url)
    this.req.setRequestHeader("Accept","application/json")
    this.req.send()
}

function GetEcowittJSON(host,port,path,interval)
{
    GetJSON.call(this,host,port,path,interval)
}

GetEcowittJSON.prototype= Object.create(GetJSON.prototype)
GetEcowittJSON.prototype.getOuttemp=function()
{
    return this.json.outdoor.temperature.value
}


function UI(server,port,path,interval)
{
    this.serverElement=document.getElementById('inputServer')
    this.serverElement.addEventListener('change',this.onChangeServer.bind(this))

    this.portElement=document.getElementById('inputPort')
    this.portElement.addEventListener('change',this.onChangePort.bind(this))

    this.pathElement=document.getElementById('inputPath')
    this.portElement.addEventListener('change',this.onChangePath.bind(this))

    this.intervalElement=document.getElementById('inputInterval')
    this.intervalElement.addEventListener('change',this.onChangeInterval.bind(this))

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

    this.btnOK=document.getElementById('btnOK')


    this.serverElement.value= localStorage.getItem('server')
    this.portElement.value=localStorage.getItem('port') 
    this.pathElement.value=localStorage.getItem('path') 
    this.intervalElement.value=localStorage.getItem('interval')

    // use default, if not available in localstorage

    if (this.serverElement.value==="") {
        this.serverElement.value=server
        localStorage.setItem('server',server)
    }

    if (this.portElement.value==="") {
        this.portElement.value=port
        localStorage.setItem('port',port)
    }

    if (this.pathElement.value==="") {
        this.pathElement.value=path
        localStorage.setItem('path',path)
    }

    if (this.intervalElement.value==="") {
        this.intervalElement.value=interval
        localStorage.setItem('interval',interval)
    }

    this.windchart= new Highcharts.Chart({ chart : {
                                                renderTo: 'windchart'
                                            },
                                            title: {
                                                text: 'Wind'
                                            },
                                            yAxis: [{
                                                //https://api.highcharts.com/highcharts/yAxis.max
                                                
                                                min : null,
                                                max : null
                                                //max : 1.0
                                              //  max : 40
                                            }],
                                            xAxis: [{

                                                id: 'datetime-axis',
                                
                                                type: 'datetime',
                                
                                                // Turn off X-axis line
                                                //lineWidth: 0,
                                
                                                // Turn off tick-marks
                                                //tickLength: 0,
                                
                                                //tickPositions: [],
                                
                                                offset : 10,
                                
                                                labels:
                                                    {
                                                        enabled: false,
                                                        style: {
                                                            //color: '#6D869F',
                                                            fontWeight: 'bold',
                                                            fontSize: '10px',
                                
                                                        },
                                
                                                        y: 18
                                                    },
                                
                                            }],
                                
                                            series: [{
                                                        name: 'Windgustspeed',
                                                        type: 'spline',
                                                        data: [],
                                                        animation: 250
                                                    },
                                                    {
                                                        name: 'Windspeed',
                                                        type: 'spline',
                                                        data: [],
                                                        animation: 250
                                                    }] 
                                        })
    
    this.getJSON=new GetJSON(this.serverElement.value,this.portElement.value,this.pathElement.value,this.intervalElement.value)
    this.getJSON.req.addEventListener("load",this.onJSON.bind(this))
    this.btnOK.addEventListener('click',this.onClickOK.bind(this))
    
}

UI.prototype.onInputServer = function(ev)
{
    console.log('oninput',ev)
}

UI.prototype.onChangeServer = function(ev)
{
    console.log('onchangeServer',ev)
    localStorage.setItem('server',this.serverElement.value)
}

UI.prototype.onChangePort = function(ev)
{

    var port=parseInt(this.portElement.value)

    console.log('onchangePort',ev)

    if (isNaN(port)) {
        this.port.value=this.getJSON.port
        console.error('port is not a number:'+this.portElement.value)
        return
    }

    if (port < 1024 || port > 65535) {
        this.portElement.value=this.getJSON.port
        console.error('port outside bounds 1024-65535:'+this.portElement.value)
        return
    }

    localStorage.setItem('port',this.portElement.value)
}

UI.prototype.onChangePath = function(ev)
{
    console.log('onchangePath',ev)
    localStorage.setItem('path',this.pathElement.value)
}

UI.prototype.onChangeInterval = function(ev)
{
    console.log('onchangeInterval',ev)
    
    var interval=parseInt(this.intervalElement.value)

    if (interval < 500) {
        this.intervalElement.value=this.getJSON.interval
        console.error('interval less than 500ms:'+this.intervalElement.value)
        return
    }

    if (isNaN(interval))
    {
        this.interval.value=this.getJSON.interval
        console.error('interval is not a number:'+this.intervalElement.value)
        return
    }

    localStorage.setItem('interval',this.intervalElement.value)
}


UI.prototype.onClickOK = function(ev)
{

    console.log('changing server to '+this.serverElement.value+':'+this.portElement.value+this.pathElement.value,this)
    this.getJSON.req.abort()
    this.getJSON.setUrl(this.serverElement.value,this.portElement.value,this.pathElement.value)
    this.getJSON.setInterval(this.intervalElement.value)
}

UI.prototype.onJSON=function (ev)
{
    // Show when data is available
    if (this.weatherElement.style.display==="none")
      this.weatherElement.style.display="block"

    this.outtempElement.textContent=this.getJSON.getOuttemp()
    this.intempElement.textContent=this.getJSON.getIntemp()
    this.unitTempElement.textContent=this.getJSON.getUnitTemp()

    this.windspeedElement.textContent=this.getJSON.getWindspeed()
    this.windgustspeedElement.textContent=this.getJSON.getWindgustspeed()
    this.winddirection_compassElement.textContent=this.getJSON.getWinddirection_compass()
    this.windgustspeed_beufort_descriptionElement.textContent=this.getJSON.getWindgustBeufort_description()
    this.unitWindElement.textContent=this.getJSON.getUnitWind()
    this.meter_windgustspeedElement.value=this.getJSON.getWindgustspeed()

    this.relbaroElement.textContent=this.getJSON.getRelbaro()
    this.absbaroElement.textContent=this.getJSON.getAbsbaro()
    this.unitpressureElement.textContent=this.getJSON.getUnitPressure()

    this.solar_lightElement.textContent=this.getJSON.getSolarLight()
    this.unit_solar_lightElement.textContent=this.getJSON.getUnitSolarLight()
    this.solar_uvElement.textContent=this.getJSON.getSolarUV()
    this.unit_solar_uvElement.textContent=this.getJSON.getUnitSolarUV()
    this.solar_uviElement.textContent=this.getJSON.getSolarUVI()

    /** From highcharts.src.js
	 * Add a point dynamically after chart load time
	 * @param {Object} options Point options as given in series.data
	 * @param {Boolean} redraw Whether to redraw the chart or wait for an explicit call
	 * @param {Boolean} shift If shift is true, a point is shifted off the start
	 *    of the series as one is appended to the end.
	 * @param {Boolean|Object} animation Whether to apply animation, and optionally animation
	 *    configuration
	 */
     this.windchart.series[0].addPoint([this.getJSON.getTimestamp(),this.getJSON.getWindspeed()],false, false, false)
    this.windchart.series[1].addPoint([this.getJSON.getTimestamp(),this.getJSON.getWindgustspeed()],false, false, false)

    console.log('data min/max',this.windchart.series[0].yAxis.dataMin,this.windchart.series[0].yAxis.dataMax)
    
    this.windchart.redraw()

}

https://stackoverflow.com/questions/15455009/javascript-call-apply-vs-bind
if (Function.prototype.bind === undefined)
{
    console.log('javascript bind not found, creating new Function.prototype.bind,'+window.navigator.userAgent)
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
    console.log('onload event, init ui')
    console.log('window location',window.location)
    var ui = new UI(window.location.hostname,window.location.port,'/livedata',16000)
    
}
