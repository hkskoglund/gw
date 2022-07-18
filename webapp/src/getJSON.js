function GetJSON(url, interval, options) {

    this.url = url
    this.interval = interval
    this.options = options || {}
    this.timezoneOffset = new Date().getTimezoneOffset() * 60000
    this.statistics = {
        measurements : 0,
        content_length : 0
    }

    this.request = new XMLHttpRequest()
    this.request.addEventListener("load", this.transferComplete.bind(this))
    this.request.addEventListener("error", this.transferError.bind(this))
    this.request.addEventListener("abort", this.transferAbort.bind(this))

    this.sendInterval(interval)

    console.log('GetJSON', this)
}

GetJSON.prototype.requestInterval = {
    hour1: 3600000,
    min15: 900000,
    min10: 600000,
    min5: 300000,
    min1: 60000,
    second16: 16000,
    second5: 5000,
    second1: 1000,
}

GetJSON.prototype.transferComplete = function (progressEvent) {
    console.log('transfer complete',progressEvent)
    if (this.request.responseText.length > 0) {
        this.statistics.measurements++
        this.statistics.content_length+=progressEvent.total // https://developer.mozilla.org/en-US/docs/Web/API/ProgressEvent/total
        console.log('statistics',this.statistics)
        //console.log('json:'+this.request.responseText)
        try {
            this.json = JSON.parse(this.request.responseText)
            console.dir(this.json, { depth: null })

            this.parse()
        } catch (err) {
            console.error('Failed parsing JSON')
            console.error(JSON.stringify(err))
        }

    } else {
        console.error("No JSON received " + this.request.status + ' ' + this.request.statusText)
        delete this.json
    }
}

GetJSON.prototype.transferError = function (progressEvent)
// Chrome: about 2 seconds timeout
{
    console.error('Failed to receive json for ' + this.url, progressEvent);
}

GetJSON.prototype.transferAbort = function (ev) {
    console.warn('request aborted ' + JSON.stringify(ev))
}

GetJSON.prototype.send = function () {
    this.request.open('GET', this.url)
    this.request.setRequestHeader("Accept", "application/json")
    if (this.options.authorization)
        this.request.setRequestHeader("Authorization", this.options.authorization);
    this.request.send()
}

GetJSON.prototype.sendInterval = function (interval) {
    if (!interval) {
        console.error('sendInterval: Refusing to set undefined interval: ' + interval)
        return
    }

    // don't send new request if already in progress 
    if (this.request.readyState === XMLHttpRequest.UNSENT || this.request.readyState === XMLHttpRequest.DONE) // unsent or done https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/readyState
        this.send()

    if (this.requestIntervalID != null && this.requestIntervalID != undefined) {
        // console.log('clearing interval id:'+this.requestIntervalID)
        clearInterval(this.requestIntervalID)
    }

    this.requestIntervalID = setInterval(this.send.bind(this), interval)
    console.log('Setting new send interval ' + this.url + ' interval:' + interval + ' previous interval: ' + this.interval + ' id:' + this.requestIntervalID)
    this.interval = interval
}

GetJSON.prototype.parse = function () { }

GetJSON.prototype.windchill = function () {
    return null
}

GetJSON.prototype.intemp = function () { }

GetJSON.prototype.inhumidity = function () { }

GetJSON.prototype.absbaro = function () { }

GetJSON.prototype.rainevent = function () { }

function GetJSONLivedata(url, interval, options) {
    // https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest
    // https://stackoverflow.com/questions/1973140/parsing-json-from-xmlhttprequest-responsejson
    // https://developer.mozilla.org/en-US/docs/Web/API/setInterval

    GetJSON.call(this, url, interval, options)
}

GetJSONLivedata.prototype = Object.create(GetJSON.prototype)

GetJSONLivedata.prototype.Mode = {
    temperature_celcius: 0,
    temperature_farenheit: 1,
    pressure_hpa: 0,
    pressure_inhg: 1,
    rain_mm: 0,
    rain_in: 1,
    wind_mps: 0,
    wind_mph: 1,
    wind_kmh: 2,
    light_lux: 0,
    light_wattm2: 1
}

GetJSONLivedata.prototype.timestamp = function ()
// UTC time
{
   // When gw system setting for time is AUTO=1, this will be in the local timezone
    if (this.data.timezone_auto)
        return this.data.timestamp + this.timezoneOffset
    else
        return this.data.timestamp 
}

GetJSONLivedata.prototype.outtempToString = function () {
    return this.outtemp().toFixed(1) + ' ' + this.unitTemp()
}

GetJSONLivedata.prototype.outtemp = function () {
    return this.data.outtemp
}

GetJSONLivedata.prototype.intempToString = function () {
    return this.intemp().toFixed(1) + ' ' + this.unitTemp()
}

GetJSONLivedata.prototype.intemp = function () {
    return this.data.intemp
}

GetJSONLivedata.prototype.inhumidityToString = function () {
    return this.inhumidity() + ' %'
}

GetJSONLivedata.prototype.inhumidity = function () {
    return this.data.inhumidity
}

GetJSONLivedata.prototype.outhumidityToString = function () {
    return this.outhumidity() + ' %'
}

GetJSONLivedata.prototype.outhumidity = function () {
    return this.data.outhumidity
}

GetJSONLivedata.prototype.windspeedToString = function () {
    return this.windspeed().toFixed(1) + ' ' + this.unitWind()
}
GetJSONLivedata.prototype.windspeed = function () {
    //https://javascript.info/number
    return this.data.windspeed
}

GetJSONLivedata.prototype.winddailymax = function () {
    return this.data.winddailymax
}

GetJSONLivedata.prototype.winddailymaxToString = function () {
    return this.winddailymax().toFixed(1) + ' ' + this.unitWind()
}

GetJSONLivedata.prototype.windspeed_mps = function ()
// highcharts windbarb requires m/s
{
    if (this.mode.wind === this.Mode.wind_mps)
        return this.windspeed()
    else
        console.error('Converter to m/s neccessary for wind mode : ' + this.mode.wind)
}

GetJSONLivedata.prototype.windgustspeedToString = function () {
    return this.windgustspeed().toFixed(1) + ' ' + this.unitWind()
}

GetJSONLivedata.prototype.windgustspeed = function () {
    return this.data.windgustspeed
}

GetJSONLivedata.prototype.windgustspeed_mps = function ()
// highcharts windbarb requires m/s
{
    if (this.mode.wind === this.Mode.wind_mps)
        return this.windgustspeed()
    else
        console.error('Converter to m/s neccessary for wind mode : ' + this.mode.wind)

}

GetJSONLivedata.prototype.winddirection = function () {
    return this.data.winddirection
}

GetJSONLivedata.prototype.windgustspeed_beufort = function () {
    return this.data.windgustspeed_beufort
}

GetJSONLivedata.prototype.winddirection_compass_value = function () {
    return this.data.winddirection_compass_value
}

GetJSONLivedata.prototype.winddirection_compass = function () {
    return this.data.winddirection_compass + ' (' + this.data.winddirection + this.unit.winddirection + ')'
}

GetJSONLivedata.prototype.windgustbeufort_description = function () {
    return this.data.windgustspeed_beufort_description + ' (' + this.data.windgustspeed_beufort + ')'
}

GetJSONLivedata.prototype.relbaro = function () {
    return this.data.relbaro
}

GetJSONLivedata.prototype.absbaro = function () {
    return this.data.absbaro
}

GetJSONLivedata.prototype.pressureCalibrationToString = function (pressure) {
    return pressure.toFixed(1)
}

GetJSONLivedata.prototype.pressureToString = function (pressure) {
    var numdecimals = 1

    if (this.mode.pressure === this.Mode.pressure_inhg)
        numdecimals = 2

    return pressure.toFixed(numdecimals) + ' ' + this.unitPressure()
}

GetJSONLivedata.prototype.solar_lightToString = function () {
    return this.solar_light().toFixed(1) + ' ' + this.unitSolarlight()
}

GetJSONLivedata.prototype.solar_light = function () {
    return this.data.solar_light
}

GetJSONLivedata.prototype.solar_uvToString = function () {
    return this.solar_uv().toFixed(1) + ' ' + this.unitSolarUV()
}

GetJSONLivedata.prototype.solar_uv = function () {
    return this.data.solar_uv
}

GetJSONLivedata.prototype.solar_uvi = function () {
    return this.data.solar_uvi
}

GetJSONLivedata.prototype.rainrate_description = function () {
    return this.data.rainrate_description
}

GetJSONLivedata.prototype.rainrateToString = function () {
    var numdecimals

    if (this.mode.rain === this.Mode.rain_mm)
        numdecimals = 1
    else
        numdecimals = 2

    return this.rainrate().toFixed(numdecimals) + ' ' + this.unitRainrate()
}

GetJSONLivedata.prototype.rainrate = function () {
    return this.data.rainrate
}

GetJSONLivedata.prototype.rainevent = function () {
    return this.data.rainevent
}

GetJSONLivedata.prototype.rainhour = function () {
    return this.data.rainhour
}

GetJSONLivedata.prototype.rainday = function () {
    return this.data.rainday
}

GetJSONLivedata.prototype.rainweek = function () {
    return this.data.rainweek
}

GetJSONLivedata.prototype.rainmonth = function () {
    return this.data.rainmonth
}

GetJSONLivedata.prototype.rainyear = function () {
    return this.data.rainyear
}

GetJSONLivedata.prototype.unitRainrate = function () {
    return this.unit.rainrate
}

GetJSONLivedata.prototype.unitRain = function () {
    return this.unit.rain
}

GetJSONLivedata.prototype.unitTemp = function () {
    return this.unit.temperature
}

GetJSONLivedata.prototype.unitWind = function () {
    return this.unit.wind
}

GetJSONLivedata.prototype.unitSolarlight = function () {
    return this.unit.solar_light
}

GetJSONLivedata.prototype.solar_uvi_description = function () {
    return this.data.solar_uvi_description
}

GetJSONLivedata.prototype.unitSolarUV = function () {
    return this.unit.solar_uv
}

GetJSONLivedata.prototype.unitPressure = function () {
    return this.unit.pressure
}

GetJSONLivedata.prototype.parse = function () {
    this.data = this.json.data
    this.unit = this.json.unit
    this.mode = this.json.mode
}

function GetJSONFrostPrecipitation(url, interval, options) {
    GetJSON.call(this, url, interval, options)
}

GetJSONFrostPrecipitation.prototype = Object.create(GetJSON.prototype)

function GetJSONWUCurrentConditions(url, interval, options) {
    GetJSON.call(this, url, interval, options)
}

GetJSONWUCurrentConditions.prototype = Object.create(GetJSON.prototype)

GetJSONWUCurrentConditions.prototype.parse = function () {
    if (this.json.observations && this.json.observations[0]) {
        this.data = this.json.observations[0]
        // console.log('wu data '+JSON.stringify(this.data))
        console.log('WU', this.data)
    } else
        console.error('Not a WU observation ' + JSON.stringify(this.json))
}

GetJSONWUCurrentConditions.prototype.timestamp = function () {
    // epoch Time in UNIX seconds
    return this.data.epoch * 1000
}

GetJSONWUCurrentConditions.prototype.outtemp = function () {
    return this.data.metric.temp
}

GetJSONWUCurrentConditions.prototype.windchill = function () {
    return this.data.metric.windChill
}

GetJSONWUCurrentConditions.prototype.outhumidity = function () {
    return this.data.humidity
}

GetJSONWUCurrentConditions.prototype.windspeed_mps = function () {
    return WindConverter.prototype.fromKmhToMps(this.data.metric.windSpeed)
}

GetJSONWUCurrentConditions.prototype.windgustspeed_mps = function () {
    return WindConverter.prototype.fromKmhToMps(this.data.metric.windGust)
}

GetJSONWUCurrentConditions.prototype.winddirection = function () {
    return this.data.winddir
}

GetJSONWUCurrentConditions.prototype.windgustspeed_beufort = function () {
    return WindConverter.prototype.getBeufort(this.windgustspeed_mps())
}

GetJSONWUCurrentConditions.prototype.winddirection_compass_value = function () {
    return WindConverter.prototype.getCompassDirectionValue(this.data.winddir)
}

GetJSONWUCurrentConditions.prototype.relbaro = function () {
    return this.data.metric.pressure
}

GetJSONWUCurrentConditions.prototype.solar_light = function () {
    return this.data.solarRadiation
}

GetJSONWUCurrentConditions.prototype.solar_uvi = function () {
    return this.data.uv
}

GetJSONWUCurrentConditions.prototype.rainrate = function () {
    return this.data.metric.precipRate
}

GetJSONWUCurrentConditions.prototype.rainday = function () {
    //Accumulated precipitation for today from midnight to present https://docs.google.com/document/d/1KGb8bTVYRsNgljnNH67AMhckY8AQT2FVwZ9urj8SWBs/edit
    return this.data.metric.precipTotal
}

function GetJSONHolfuyLive(url, interval, options) {
    GetJSON.call(this, url, interval, options)
}

GetJSONHolfuyLive.prototype = Object.create(GetJSON.prototype)

function GetJSONFrost(url, interval, options) {
    GetJSON.call(this, url, interval, options)
}

GetJSONFrost.prototype = Object.create(GetJSON.prototype)

GetJSONFrost.prototype.dateutil = function () {
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

GetJSONFrost.prototype.parse = function () {
    var json = this.json
    // https://frost.met.no/api.html#!/observations/observations
    if (json['@type'] != 'ObservationResponse') {
        console.error('Not a ObservationResponse type, aborting parsing' + JSON.stringify(json))
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
        currentStation = 0

    this.data = {}

    for (item = 0; item < json.totalItemCount; item++) // number of data items
    {
        referenceTime = new Date(json.data[item].referenceTime)
        // console.log('referenceTime '+referenceTime)
        // console.log(JSON.stringify(json.data[item]))
        timestamp = referenceTime.getTime() - referenceTime.getTimezoneOffset() * 60000  // local timezone time
        hhmmss = DateUtil.prototype.getHHMMSS(referenceTime)
        if (referenceTime > this.stations[currentStation].latestReferencetime) {
            this.stations[currentStation].timestampHHMMSS = hhmmss
            this.stations[currentStation].latestReferencetime = referenceTime
        }

        // console.log('observations '+json.data[item].observations.length)
        for (obsNr = 0; obsNr < json.data[item].observations.length; obsNr++) {
            observation = json.data[item].observations[obsNr]
            elementId = observation.elementId
            //   console.log(elementId+' '+JSON.stringify(observation))

            unit = observation.unit

            if (unit === 'degC')
                unit = '℃'
            else if (unit === 'percent')
                unit = '%'
            else if (unit === 'degrees')
                unit = '°'
            else if (unit === 'W/m2')
                unit = 'W/㎡'

            // Query result should have time offset PT0H
            if (observation.timeOffset !== 'PT0H')
                // must add offset to referencetime
                console.error('Skipping observation for time offset ' + observation.timeOffset + ' ' + JSON.stringify(observation))
            else {

                if (!this.data[elementId])
                    this.data[elementId] = []

                lastObservation = this.data[elementId].slice(-1)[0]
                if (!lastObservation || (lastObservation && lastObservation.timestamp !== timestamp)) // dont attempt to add multiple observations with same timestamp, for example PT1H and PT10M at 10:00
                    this.data[elementId].push({
                        timestamp: timestamp,
                        hhmmss: hhmmss,
                        value: observation.value,
                        unit: unit
                    })
            }

        }
    }

    console.log('METno', this.data)

}

GetJSONYrForecastNow = function (url, interval, options) {
    GetJSON.call(this, url, interval, options)
}

GetJSONYrForecastNow.prototype = Object.create(GetJSON.prototype)

GetJSONFrost.prototype.getLatestObservation = function (element) {
    if (!this.data) {
        console.warn('JSON frost: No data')
        return
    }

    var data = this.data[element]
    if (data)
        return data[data.length - 1].value
}