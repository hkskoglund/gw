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
