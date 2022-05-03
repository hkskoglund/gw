
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

GetJSON.prototype.setInterval= function(interval)
{
    this.requestLivedata()

    if (this.intervalID != null && this.intervalID != undefined) {
       // console.log('clearing interval id:'+this.intervalID)
        clearInterval(this.intervalID)
    }
    
    this.intervalID=setInterval(this.requestLivedata.bind(this),interval)
    //console.log('Interval:'+interval+' id:'+this.intervalID)
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
    return this.outtemp().toFixed(1)
}

GetJSON.prototype.outtemp=function()
{
    return this.data.outtemp
}

GetJSON.prototype.intempToString=function()
{
    return this.intemp().toFixed(1)
}

GetJSON.prototype.intemp=function()
{
    return this.data.intemp
}

GetJSON.prototype.inhumidity=function()
{
    return this.data.inhumidity
}

GetJSON.prototype.outhumidity=function()
{
    return this.data.outhumidity
}

GetJSON.prototype.windspeedToString=function()
{
    return this.windspeed().toFixed(1)
}
GetJSON.prototype.windspeed=function()
{
    //https://javascript.info/number
    return this.data.windspeed
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
    return this.windgustspeed().toFixed(1)
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

GetJSON.prototype.pressureToString= function(pressure)
{
    if (this.mode.pressure === this.Mode.pressure_hpa)
        return pressure.toFixed(1)
    else if (this.mode.pressure === this.Mode.pressure_inhg)
        return pressure.toFixed(2)
}

GetJSON.prototype.solar_lightToString=function()
{
    return this.solar_light().toFixed(1)
}

GetJSON.prototype.solar_light = function()
{
    return this.data.solar_light
}

GetJSON.prototype.solar_uvToString = function()
{
    return this.solar_uv().toFixed(1)
}

GetJSON.prototype.solar_uv = function()
{
    return this.data.solar_uv
}

GetJSON.prototype.solar_uvi=function()
{
    return this.data.solar_uvi
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

    this.initChart()

    this.options={
        interval: 16000, // milliseconds request time for JSON
        shifttime : 15  // shift time in minutes, when points gets deleted/shifted left
    }

    this.options.maxPoints=Math.round(this.options.shifttime*60*1000/this.options.interval) // max number of points for requested shifttime
    
    if (window.location.hostname === '127.0.0.1') // assume web server runs on port 80
        // Visual studio code live preview uses 127.0.0.1:3000
      port=80
    else
      port=window.location.port

    this.getJSON=new GetJSON(window.location.hostname,port,'/api/livedata',this.options.interval)
    this.getJSON.req.addEventListener("load",this.onJSON.bind(this))
    
}

UI.prototype.initChart=function()
{

    // https://jsfiddle.net/fq64pkhn/
   
    this.windrosechart=Highcharts.chart('windrosechart', {
        chart: {
            polar: true,
            type: 'column'
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
    
        pane: {
            size: '85%'
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
    
        tooltip: {
            valueSuffix: '%'
        },
    
        plotOptions: {
            series: {
                stacking: 'normal',
                shadow: false,
                groupPadding: 0,
                pointPlacement: 'on'
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
    
   this.temperaturechart_column=Highcharts.chart('temperaturechart-column', {
        chart: {
            type: 'column'
        },
        title: {
            text: 'Temperature'
        },
        xAxis: {
            categories: [
                'Outdoor',
                'Indoor',
            ],
            //crosshair: true
        },
        yAxis: [{
            title: false
        },
        {
            min: 0,
            max: 100,
            title: false,
            opposite: true
        },
    ],
        
        plotOptions: {
            column: {
              //  pointPadding: 0.2,
              //  borderWidth: 0
            },
            series: { dataLabels: {
                enabled: true,
               // rotation: 0,
               // color: '#FFFFFF',
               // align: 'right',
               // format: '{point.y:.1f}', // one decimal
               // y: 10, // 10 pixels down from the top
               // style: {
               //     fontSize: '13px',
               //     fontFamily: 'Verdana, sans-serif'
               // }
            }}
        },
        
        series: [{
            name: 'Temperature',
            yAxis: 0,
            data: []
    
        }, {
            name: 'Humidity',
            data: [],
            yAxis: 1,
            visible: false
    
        }]
    });

    this.temperaturechart= new Highcharts.Chart({ chart : {
        renderTo: 'temperaturechart'
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
        //max : null
        //max : 1.0
    //  max : 40
    },
    // humidity
    {
        title:false,
        opposite: true,
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

    series: [
        {
                name: 'Outdoor',
                type: 'areaspline',
                yAxis: 0,
                data: []
               
             //   zIndex: 4
            },
            {
                name: 'Indoor',
                type: 'areaspline',
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
    })

    this.pressurechart= new Highcharts.Chart({ chart : {
        renderTo: 'pressurechart'
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
        min: 950
        //max : null
        //max : 1.0
    //  max : 40
    }

],
    xAxis: [{

        id: 'datetime-axis',

        type: 'datetime',

        offset : 10,

        tickpixelinterval: 150,

    }],

    series: [
        {
                name: 'Relative',
                type: 'areaspline',
                yAxis: 0,
                data: []
               
             //   zIndex: 4
            },
            {
                name: 'Absolute',
                type: 'areaspline',
                data: [],
                yAxis: 0,
                visible: false
           //     zIndex: 3
            }
           ] 
    })
    
    this.solarchart= new Highcharts.Chart({ chart : {
                            renderTo: 'solarchart'
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
                            tickInterval: 50
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
                        allowDecimals: false
                    }
                ],
                        xAxis: [{

                            id: 'datetime-axis',

                            type: 'datetime',

                            offset : 10,

                            tickpixelinterval: 150,

                        }],

                        series: [
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
                                    type: 'area',
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
                        })

    // based on https://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/demo/windbarb-series/
    this.windbarbchart= new Highcharts.Chart({ chart : {
        renderTo: 'windbarbchart' },

        title: {
            text: 'Wind'
        },
    
        xAxis: {
            type: 'datetime',
            offset: 40
        },

        yAxis: {
            title : false,
            tickInterval: 0.5
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
            data: [],
           
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
    var json=this.getJSON
    // Show when data is available
   // if (this.weatherElement.style.display==="none")
   //   this.weatherElement.style.display="block"

    this.measurementCount=this.measurementCount+1

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

    var timestamp=json.timestamp()

  
    this.temperaturechart_column.setSubtitle({ text: 'Outdoor '+json.outtempToString()+' ' + json.unitTemp()+' '+json.outhumidity()+' % Indoor '+json.intempToString()+' '+json.unitTemp()+json.inhumidity()+' %' })
    this.temperaturechart.setSubtitle({ text: 'Outdoor '+json.outtempToString()+' ' + json.unitTemp()+' '+json.outhumidity()+' % Indoor '+json.intempToString()+' '+json.unitTemp()+json.inhumidity()+' %' })
    this.windbarbchart.setSubtitle({ text: 'Speed '+ json.windspeedToString()+' '+json.unitWind()+' Gust '+ json.windgustspeedToString()+' '+json.unitWind()+' '+json.winddirection_compass()+' '+json.windgustbeufort_description()})
    this.solarchart.setSubtitle({ text: 'Radiation '+json.solar_lightToString()+' '+json.unitSolarlight()+' UVI ' +json.solar_uvi_description() +' ('+json.solar_uvi()+')'})
    this.pressurechart.setSubtitle({ text: 'Relative '+json.pressureToString(json.relbaro())+ ' '+ json.unitPressure()+' Absolute ' + json.pressureToString(json.absbaro())})

    if (this.temperaturechart.series[0].userOptions.tooltip === undefined || this.temperaturechart.series[0].userOptions.tooltip.valueSuffix === undefined ) {
        this.temperaturechart.series[0].update({tooltip: { valueSuffix: ' '+json.unitTemp() }})
        this.temperaturechart.series[1].update({tooltip: { valueSuffix: ' '+json.unitTemp() }})
    }
    
    if (this.pressurechart.series[0].userOptions.tooltip === undefined || this.solarchart.series[0].userOptions.tooltip.valueSuffix === undefined ) {
        this.pressurechart.series[0].update({tooltip: { valueSuffix: ' '+json.unitPressure() }})
        this.pressurechart.series[1].update({tooltip: { valueSuffix: ' '+json.unitPressure() }})
    }

    if (this.solarchart.series[0].userOptions.tooltip === undefined || this.solarchart.series[0].userOptions.tooltip.valueSuffix === undefined )
        this.solarchart.series[0].update({tooltip: { valueSuffix: ' '+json.unitSolarlight() }})
    
    // Remove data if too old, otherwise they get skewed to the left
    if (this.windbarbchart.series[0].xData.length >= 1 &&   ( timestamp - this.windbarbchart.series[0].xData[this.windbarbchart.series[0].xData.length-1]) > this.options.interval*this.options.maxPoints)
    {
        //console.log('Removing data from chart to avoid skewed presentation, max points: '+this.options.maxPoints)
        this.measurementCount=0
        this.windrosechart.series.forEach(function (element) { element.setData([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]) })
        this.temperaturechart.series.forEach(function (element) { element.setData([]) })
        this.pressurechart.series.forEach(function (element) { element.setData([]) })
        this.windbarbchart.series.forEach(function (element) { element.setData([]) })
        this.solarchart.series.forEach(function (element) { element.setData([]) })
    }

    var beufortScale=json.windgustspeed_beufort()
    var compassDirection=json.winddirection_compass_value()-1 
    var rosePoint=this.windrosechart.series[beufortScale].data[compassDirection]
        rosePoint.update(rosePoint.y+1,true)

    
   this.temperaturechart_column.series[0].setData([json.outtemp(),json.intemp()])
    this.temperaturechart_column.series[1].setData([json.outhumidity(),json.inhumidity()])
    

    this.temperaturechart.series[0].addPoint([timestamp,json.outtemp()],false, this.temperaturechart.series[0].points.length>this.options.maxPoints, false)
    this.temperaturechart.series[1].addPoint([timestamp,json.intemp()],false, this.temperaturechart.series[1].points.length>this.options.maxPoints, false)
    this.temperaturechart.series[2].addPoint([timestamp,json.outhumidity()],false, this.temperaturechart.series[2].points.length>this.options.maxPoints, false)
    this.temperaturechart.series[3].addPoint([timestamp,json.inhumidity()],false, this.temperaturechart.series[3].points.length>this.options.maxPoints, false)

    this.pressurechart.series[0].addPoint([timestamp,json.relbaro()],false, this.pressurechart.series[0].points.length>this.options.maxPoints, false)
    this.pressurechart.series[1].addPoint([timestamp,json.absbaro()],false, this.pressurechart.series[1].points.length>this.options.maxPoints, false)

    this.windbarbchart.series[0].addPoint([timestamp,json.windgustspeed_mps(),json.winddirection()],false, this.windbarbchart.series[0].points.length>this.options.maxPoints, false)
    // https://api.highcharts.com/highcharts/series.line.data
    // only support m/s unit
    this.windbarbchart.series[1].addPoint({ x: timestamp, y: json.windspeed_mps() },false, this.windbarbchart.series[1].points.length>this.options.maxPoints, false)
    this.windbarbchart.series[2].addPoint({ x: timestamp, y: json.windgustspeed_mps() },false, this.windbarbchart.series[2].points.length>this.options.maxPoints, false) 

   this.solarchart.series[0].addPoint([timestamp,json.solar_light()],false, this.solarchart.series[0].points.length>37, false)
   // this.solarchart.series[1].addPoint([timestamp,json.solar_uv()],false, this.solarchart.series[1].points.length>37, false)
   this.solarchart.series[1].addPoint([timestamp, json.solar_uvi()],false, this.solarchart.series[1].points.length>37, false)

   // console.log('data min/max',this.windchart.series[0].yAxis.dataMin,this.windchart.series[0].yAxis.dataMax)
   
    this.temperaturechart.redraw()
    this.pressurechart.redraw()
    this.windbarbchart.redraw()
    this.solarchart.redraw()
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
