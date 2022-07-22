function Station(name, id) {
    this.name = name
    this.id = id
    this.init()
}

Station.prototype.onJSON = function () {
}

Station.prototype.init=function()
{
}

Station.prototype.initWindrosedata=function()
{
    this.windrosedata = []
    for (var beufort = 0; beufort < 12; beufort++)
        this.windrosedata.push([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
}

function StationMETnoFrost(name,id)
{
    Station.call(this,name,id)
    this.getJSON = new GetJSONFrost(window.location.origin+'/api/frost.met.no/latest?SN='+id,GetJSON.prototype.requestInterval.min15)
     /*
        if (this.options.frostapi.enabled) {
            this.getJSONFrostLatest15Min = new GetJSONFrost(window.location.origin+'/api/frost.met.no/latest',GetJSON.prototype.requestInterval.min15,this.options.frostapi)
            this.getJSONFrostLatest15Min.request.addEventListener("load",this.onJSONFrost.bind(this,this.getJSONFrostLatest15Min))
            this.getJSONFrostLatest15Min.request.addEventListener("load",this.redrawCharts.bind(this))
    
           // this.getJSONFrostLatest1H = new GetJSONFrost(window.location.origin+'/api/frost.met.no/latest-1H',GetJSON.prototype.requestInterval.hour1,this.options.frostapi)
           // this.getJSONFrostLatest1H.request.addEventListener("load",this.onJSONFrost.bind(this,this.getJSONFrostLatest1H))
           // this.getJSONFrostLatest1H.request.addEventListener("load",this.onJSONloadredrawCharts.bind(this))
    
        }
   /* frostapi: {
        doc: 'https://frost.met.no/index.html',
        authorization: "Basic " + btoa("2c6cf1d9-b949-4f64-af83-0cb4d881658a:"), // http basic authorization header -> get key from https://frost.met.no/howto.html
        enabled: true && (navigatorIsNorway || this.isLGSmartTV2012()),    // use REST api from frost.met.no - The Norwegian Meterological Institute CC 4.0  
        stationName: 'Værvarslinga SN90450',
        stationId: 'SN90450',
        // stationName: 'Harstad Stadion',
        // stationId: 'SN87640',
        stations: [
            {
                stationName: 'Harstad Stadion',
                stationId: 'SN87640',
            },
            {
                stationName: 'Værvarslinga',
                stationId: 'SN90450',
            }
        ]
    }, */
}

StationMETnoFrost.prototype = Object.create(Station.prototype)

StationMETnoFrost.prototype.init=function()
{
    this.initWindrosedata()
}


function StationGW(name, id) {
    Station.call(this, name, id)
    this.getJSON = new GetJSONLivedata(window.location.origin + '/api/livedata', GetJSON.prototype.requestInterval.second16)
    this.getJSON.request.addEventListener('load', this.onJSON.bind(this))
    setTimeout(this.getJSON.sendInterval.bind(this.getJSON, GetJSON.prototype.requestInterval.min1), GetJSON.prototype.requestInterval.min5)
}

StationGW.prototype = Object.create(Station.prototype)

StationGW.prototype.init=function()
{
    this.initWindrosedata()
}

function StationWU(name, id) {
    Station.call(this, name, id)
    // API documentation  'https://docs.google.com/document/d/1eKCnKXI9xnoMGRRzOL1xPCBihNV2rOet08qpE_gArAY'
    this.apiKey = '9b606f1b6dde4afba06f1b6dde2afb1a', // get a personal api key from https://www.wunderground.com/member/api-keys
    this.getJSON = new GetJSONWUCurrentConditions('https://api.weather.com/v2/pws/observations/current?apiKey=' + this.apiKey + '&stationId=' + this.id + '&numericPrecision=decimal&format=json&units=m', GetJSON.prototype.requestInterval.min5)
    this.getJSON.request.addEventListener('load', this.onJSON.bind(this))
}

StationWU.prototype = Object.create(Station.prototype)

StationWU.prototype.init=function()
{
    this.initWindrosedata()
}

function StationYrForecastNow(name,id,location) {
    Station.call(this, name, id)
    this.getJSON = new GetJSON(window.location.origin + '/api/yr_forecastnow?location=' + location, GetJSON.prototype.requestInterval.min5)
    this.getJSON.request.addEventListener('load', this.onJSONYrForecastNow.bind(this))
}

StationYrForecastNow.prototype = Object.create(Station.prototype)

StationYrForecastNow.prototype.onJSONYrForecastNow=function()
{
    var json = this.getJSON.json,
        points= json.points

    if (json.radarIsDown) {
        console.error('Yr radar is down')
        return
    }

    var timezoneOffset = new Date().getTimezoneOffset() * 60000
    this.points = points.map(function (element) { return [new Date(element.time).getTime() - timezoneOffset, element.precipitation.intensity] })
    // Test zones var count=0
    // var points=json.points.map(function (element) { return [new Date(element.time).getTime()-timezoneOffset,count=count+0.5] })

    if (!this.yrForecastnowPoints) {
        this.yrForecastnowPointsTimestamp = this.points.map(function (element) { return element[0] })
        this.yrForecastnowPointsIntensity = this.points.map(function (element) { return element[1] })
    }
    else
    // Keep history of forcasted precipitation in rainchart to compare with actual precipitation measured by station
    {
        this.points.forEach(function (element) {
            var timestamp = element[0],
                intensity = element[1],
                i = this.yrForecastnowPointsTimestamp.indexOf(timestamp)
            if (i !== -1)
                this.yrForecastnowPointsIntensity[i] = intensity // update with new intensity
            else {
                this.yrForecastnowPointsTimestamp.push(timestamp) // add new point
                this.yrForecastnowPointsIntensity.push(intensity)
            }

        }.bind(this))
    }

    this.yrForecastnowPoints = this.yrForecastnowPointsTimestamp.map(function (timestamp, index) {
                    var intensity = this.yrForecastnowPointsIntensity[index]
                    return [timestamp, intensity]
                }.bind(this))

     //console.log('yr forecastnow '+JSON.stringify(this.yrForecastnowPointsIntensity))
     //console.log('yr forecastnow '+JSON.stringify(this.yrForecastnowPointsTimestamp))
}

StationYrForecastNow.prototype.hasPrecipitation=function()
{
    var hasPrecipitation

    if (!this.yrForecastnowPointsIntensity)
      hasPrecipitation=false
    else
      hasPrecipitation= this.yrForecastnowPointsIntensity.some(function (intensity) { return intensity > 0 })
    
    //console.log('hasprecipitation',this.id,this.yrForecastnowPointsIntensity,hasPrecipitation)
    return hasPrecipitation
}


