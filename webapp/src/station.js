function Station(name, id) {
    this.name = name
    this.id = id
    this.timestampHHMMSS = ''
    this.latestReferencetime = 0
    this.measurementCount = 0
    this.windrosedata = []
    for (var beufort = 0; beufort < 12; beufort++)
        this.windrosedata.push([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
}

Station.prototype.onJSON = function () {
    var timestamp = this.getJSON.timestamp()
    this.timestamp = timestamp - this.getJSON.timezoneOffset // local timezone timestamp
    this.timestampHHMMSS = DateUtil.prototype.getHHMMSS(new Date(timestamp))
    this.measurementCount++
}

function StationHarstadStation(name, id) {
    Station.call(this, name, id)
}

StationHarstadStation.prototype = Object.create(Station.prototype)

function StationVervarslinga(name, id) {
    Station.call(this, name, id)
}

StationVervarslinga.prototype = Object.create(Station.prototype)

function StationGW(name, id) {
    Station.call(this, name, id)
    this.getJSON = new GetJSONLivedata(window.location.origin + '/api/livedata', GetJSON.prototype.requestInterval.second16)
    this.getJSON.request.addEventListener('load', this.onJSON.bind(this))
    setTimeout(this.getJSON.sendInterval.bind(this.getJSON, GetJSON.prototype.requestInterval.min1), GetJSON.prototype.requestInterval.min5)
}

StationGW.prototype = Object.create(Station.prototype)

function StationWU(name, id) {
    Station.call(this, name, id)
    // API documentation  'https://docs.google.com/document/d/1eKCnKXI9xnoMGRRzOL1xPCBihNV2rOet08qpE_gArAY'
    this.apiKey = '9b606f1b6dde4afba06f1b6dde2afb1a', // get a personal api key from https://www.wunderground.com/member/api-keys
        this.getJSON = new GetJSONWUCurrentConditions('https://api.weather.com/v2/pws/observations/current?apiKey=' + this.apiKey + '&stationId=' + this.id + '&numericPrecision=decimal&format=json&units=m', GetJSON.prototype.requestInterval.min5)
    this.getJSON.request.addEventListener('load', this.onJSON.bind(this))

}

StationWU.prototype = Object.create(Station.prototype)

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

     console.log('yr forecastnow '+JSON.stringify(this.yrForecastnowPoints))

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


