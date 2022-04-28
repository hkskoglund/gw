
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

GetJSON.prototype.getWindspeed_mps=function()
// highcharts windbarb requires m/s
{
    if (this.mode.wind === this.Mode.wind_mps)
        return this.getWindspeed()
    else
        console.error('Converter to m/s neccessary for wind mode : '+this.mode.wind)
}

GetJSON.prototype.getWindgustspeed=function()
{
    return Number(this.data.windgustspeed.toFixed(1))
}

GetJSON.prototype.getWindgustspeed_mps=function()
// highcharts windbarb requires m/s
{
    if (this.mode.wind === this.Mode.wind_mps)
        return this.getWindgustspeed()
    else
      console.error('Converter to m/s neccessary for wind mode : '+this.mode.wind)
    
}

GetJSON.prototype.getWinddirection=function()
{
    return this.data.winddirection
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
        console.error("No JSON received " + this.req.status+' '+this.req.statusText)
        delete this.json
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


function UI()
{
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

    this.initChart()

    this.options={
        interval: 16000, // milliseconds request time for JSON
        shifttime : 15  // shift time in minutes, when points gets deleted/shifted left
    }

    this.options.maxPoints=Math.round(this.options.shifttime*60*1000/this.options.interval) // max number of points for requested shifttime
    
    this.getJSON=new GetJSON(window.location.hostname,window.location.port,'/api/livedata',this.options.interval)
    this.getJSON.req.addEventListener("load",this.onJSON.bind(this))
    
}

UI.prototype.initChart=function()
{
    
    this.solarchart= new Highcharts.Chart({ chart : {
                            renderTo: 'solarchart'
                        },
                        title: {
                            text: 'Solar'
                        },
                        yAxis: [{
                            //https://api.highcharts.com/highcharts/yAxis.max
                            title: false,
                            min : null,
                            max : null
                            //max : 1.0
                        //  max : 40
                        },
                    // uv
                    {
                        title:false,
                        opposite: true,
                        min: null,
                        max: null
                    },
                    // uvi
                    {
                        title:false,
                        min: null,
                        max: null
                    }
                ],
                        xAxis: [{

                            id: 'datetime-axis',

                            type: 'datetime',

                            offset : 10,

                            tickpixelinterval: 150,

                            labels:
                                {
                                    enabled: true,
                                    style: {
                                        //color: '#6D869F',
                                        fontWeight: 'bold',
                                        fontSize: '10px',

                                    },

                                    y: 18
                                },

                        }],

                        series: [
                            {
                                    name: 'Solar light',
                                    type: 'spline',
                                    yAxis: 0,
                                    data: [],
                                },
                                {
                                    name: 'Solar UV',
                                    type: 'spline',
                                    data: [],
                                    yAxis: 1,
                                }
                                ,
                                {
                                    name: 'Solar UVI',
                                    type: 'area',
                                    yAxis: 2,
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
                        })

    // based on https://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/demo/windbarb-series/
    this.windbarbchart= new Highcharts.Chart({ chart : {
        renderTo: 'windbarb' },

        title: {
            text: 'Wind'
        },
    
        xAxis: {
            type: 'datetime',
            offset: 40
        },

        yAxis: {
            title : false
        },
    
      //  plotOptions: {
      //      series: {
      //          pointStart: Date.UTC(2017, 0, 29),
      //          pointInterval: 36e5
      //      }
      //  },
    
        series: [{
            type: 'windbarb',
            data: [ ],
            name: 'Wind',
            color: Highcharts.getOptions().colors[1],
            showInLegend: false,
            tooltip: {
                valueSuffix: ' m/s'
            }
        }, {
            type: 'areaspline',
            keys: ['y', 'rotation'], // rotation is not used here
            data: [
            ],
            color: Highcharts.getOptions().colors[0],
           // fillColor: {
           //     linearGradient: { x1: 0, x2: 0, y1: 0, y2: 1 },
           //     stops: [
           //         [0, Highcharts.getOptions().colors[0]],
           //         [1,
           //             Highcharts.color(Highcharts.getOptions().colors[0])
           //                 .setOpacity(0.25).get()
           //         ]
           //     ]
           // },
            name: 'Wind speed',
            tooltip: {
                valueSuffix: ' m/s'
            },
           // states: {
           //     inactive: {
           //         opacity: 1
           //     }
           // }
        },{
            type: 'areaspline',
            data: [],
            name: 'Wind gust speed',
            tooltip: {
                valueSuffix: ' m/s'
            }
        }
    ]
    
    });
}

UI.prototype.onJSON=function (ev)
{
    // Show when data is available
   // if (this.weatherElement.style.display==="none")
   //   this.weatherElement.style.display="block"

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

    // https://www.highcharts.com/changelog/

    var timestamp=this.getJSON.getTimestamp()
    
    // Remove data if too old, otherwise they get skewed to the left
    if (this.windbarbchart.series[0].xData.length >= 1 &&   ( timestamp - this.windbarbchart.series[0].xData[this.windbarbchart.series[0].xData.length-1]) > this.options.interval*this.options.maxPoints)
    {
        console.log('Removing data from chart to avoid skewed presentation, max points: '+this.options.maxPoints)
        this.windbarbchart.series[0].setData([])
        this.windbarbchart.series[1].setData([])
        this.windbarbchart.series[2].setData([])
        this.solarchart.series[0].setData([])
        this.solarchart.series[1].setData([])
    }   

    this.windbarbchart.series[0].addPoint([timestamp,this.getJSON.getWindgustspeed_mps(),this.getJSON.getWinddirection()],false, this.windbarbchart.series[0].points.length>this.options.maxPoints, false)
    // https://api.highcharts.com/highcharts/series.line.data
    // only support m/s unit
    this.windbarbchart.series[1].addPoint({ x: timestamp, y: this.getJSON.getWindspeed_mps() },false, this.windbarbchart.series[1].points.length>this.options.maxPoints, false)
    this.windbarbchart.series[2].addPoint({ x: timestamp, y: this.getJSON.getWindgustspeed_mps() },false, this.windbarbchart.series[2].points.length>this.options.maxPoints, false) 

   this.solarchart.series[0].addPoint([timestamp,this.getJSON.getSolarLight()],false, this.solarchart.series[0].points.length>37, false)
    this.solarchart.series[1].addPoint([timestamp,this.getJSON.getSolarUV()],false, this.solarchart.series[1].points.length>37, false)
   this.solarchart.series[2].addPoint([timestamp, this.getJSON.getSolarUVI()],false, this.solarchart.series[2].points.length>37, false)

   // console.log('data min/max',this.windchart.series[0].yAxis.dataMin,this.windchart.series[0].yAxis.dataMax)
   
    this.windbarbchart.redraw()
    this.solarchart.redraw()


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
    var ui = new UI()
    
}
