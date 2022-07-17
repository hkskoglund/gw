(function _WeatherStation() {
    
    window.addEventListener('load', function _initui() {
        // console.log('onload event, init ui')
        // console.log('window location',window.location)
        try {
            var ui = new WeatherStation()
        } catch (err) {
            console.error(JSON.stringify(err))
        }
    })

    function WeatherStation() {

        var port

        this.stations= []
        this.stationsYrForecastNow=[]

        this.outtempElement = document.getElementById('outtemp')
        this.intempElement = document.getElementById('intemp')
        this.unitTempElement = document.getElementById('unit_temperature')

        this.absbaroElement = document.getElementById('absbaro')
        this.relbaroElement = document.getElementById('relbaro')
        this.unitpressureElement = document.getElementById('unit_pressure')

        this.windspeedElement = document.getElementById('windspeed')
        this.windgustspeedElement = document.getElementById('windgustspeed')
        this.winddirection_compassElement = document.getElementById('winddirection_compass')
        this.windgustspeed_beufort_descriptionElement = document.getElementById('windgustspeed_beufort_description')
        this.unitWindElement = document.getElementById('unit_wind')

        this.meter_windgustspeedElement = document.getElementById('meter_windgustspeed')

        this.solar_lightElement = document.getElementById('solar_light')
        this.unit_solar_lightElement = document.getElementById('unit_solar_light')
        this.solar_uvElement = document.getElementById('solar_uv')
        this.unit_solar_uvElement = document.getElementById('unitsolar_uv')
        this.solar_uviElement = document.getElementById('solar_uvi')

        this.weatherElement = document.getElementById('divWeather')

        var forceLowMemoryDevice = true
        var isLowMemoryDevice = this.isLowMemoryDevice() || forceLowMemoryDevice
        var navigatorIsNorway = navigator.language.toLowerCase().indexOf('nb') !== -1 || this.isLGSmartTV2012()


        this.timeoutID = {}

        this.restoreHiddenSeries = {}

        this.options = {
            // tooltip: !isLowMemoryDevice,              // turn off for ipad1 - slow animation/disappearing
            tooltip: true,
            animation: !isLowMemoryDevice,               // turn off animation for all charts
            navigator: {
                enabled: !isLowMemoryDevice,
                series: {
                    type: 'spline',
                    dataGrouping: {
                        groupPixelWidth: 30
                    }
                }
            },
            rangeSelector:
            {
                enabled: !isLowMemoryDevice,        // keeps memory for series,
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
                }, {
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
            // mousetracking: !isLowMemoryDevice,        // allocates memory for duplicate path for tracking
            mousetracking: true,
            forceLowMemoryDevice: forceLowMemoryDevice,        // for testing
            // navigator.languauge is "en-us" for LG Smart TV 2012
            isLGSmartTV2012: this.isLGSmartTV2012(),
            frostapi: {
                doc: 'https://frost.met.no/index.html',
                authorization: "Basic " + btoa("2c6cf1d9-b949-4f64-af83-0cb4d881658a:"), // http basic authorization header -> get key from https://frost.met.no/howto.html
                enabled: true && (navigatorIsNorway || this.isLGSmartTV2012()),    // use REST api from frost.met.no - The Norwegian Meterological Institute CC 4.0  
                stationName: 'Værvarslinga SN90450',
                stationId: 'SN90450',
                // stationName: 'Harstad Stadion',
                // stationId: 'SN87640',
                timestampHHMMSS: '',
                latestReferencetime: 0,
                stations: [
                    {
                        stationName: 'Harstad Stadion',
                        stationId: 'SN87640',
                        timestampHHMMSS: '',
                        latestReferencetime: 0,
                    },
                    {
                        stationName: 'Værvarslinga',
                        stationId: 'SN90450',
                        timestampHHMMSS: '',
                        latestReferencetime: 0
                    }
                ]
            },

            holfuyapi: {
                doc: 'http://api.holfuy.com/live/', // does not support CORS in Chrome/Edge (use curl on backend?), but works in Firefox 100.0.1
                stationId: '101', // Test
                stationName: 'test',
                interval: GetJSON.prototype.requestInterval.hour1,
                enabled: false,
                timestampHHMMSS: ''
            },
            publicwmsmetno: {
                radar_nowcast: {
                    enabled: true,
                    interval: GetJSON.prototype.requestInterval.min5,
                    url: window.location.origin + '/api/radar_nowcast'
                }
            },
            weatherapi: {
                radar: {
                    enabled: true && navigatorIsNorway, // should be disabled on metered connection
                    interval: GetJSON.prototype.requestInterval.min15,
                    doc: 'https://api.met.no/weatherapi/radar/2.0/documentation',
                    url_troms_5level_reflectivity: 'https://api.met.no/weatherapi/radar/2.0/?area=troms&type=5level_reflectivity&content=image', // ca 173 kB
                    url_troms_5level_reflectivity_animation: 'https://api.met.no/weatherapi/radar/2.0/?area=troms&type=5level_reflectivity&content=animation',
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
                url: 'https://uvnett.dsa.no/dagsverdigraf_detaljert.aspx?Stasjon=And%u00f8ya&Dato=28/06/2022&Bredde=1024&Hoyde=768&Engelsk=True'
            }
        }

        //this.options.maxPoints=Math.round(this.options.shifttime*60*1000/this.options.interval) // max number of points for requested shifttime

        this.windrosechart = []
        this.initCharts()

        if (window.location.hostname === '127.0.0.1') // assume web server runs on port 80
            // Visual studio code live preview uses 127.0.0.1:3000
            port = 80
        else
            port = window.location.port

        this.initStations(port)
        // this.testMemory()

     
        this.eventHandler = {
            scroll: this.onScrollUpdateplotBGImage.bind(this)
        }

        // if (this.options.weatherapi.radar.enabled && this.latestChart) 
        //    this.reloadPlotBackgroundImage(this.latestChart,this.options.weatherapi.radar.url_troms_5level_reflectivity,this.options.weatherapi.radar.interval,true)

        if (this.options.publicwmsmetno.radar_nowcast.enabled && this.latestChart)
            this.reloadPlotBackgroundImage(this.latestChart, this.options.publicwmsmetno.radar_nowcast.url, this.options.publicwmsmetno.radar_nowcast.interval, true)

        if (this.options.weatherapi.geosatellite.enabled && this.temperatureChart)
            this.reloadPlotBackgroundImage(this.temperatureChart, this.options.weatherapi.geosatellite.url_europe, this.options.weatherapi.geosatellite.interval, true)

        if (this.options.weatherapi.polarsatellite.enabled && this.pressureChart)
            this.reloadPlotBackgroundImage(this.pressureChart, this.options.weatherapi.polarsatellite.url_latest_noaa_rgb_north_europe, this.options.weatherapi.polarsatellite.interval, true)

        document.addEventListener('scroll', this.eventHandler.scroll, { passive: true })
    }

    WeatherStation.prototype.onScrollUpdateplotBGImage = function (event) {
        this.eventHandler.scrollTimestamp = Date.now()

        for (id in this.options.missedReloadURL)
            this.updatePlotbackgroundImage(this.options.missedReloadURL[id].chart, this.options.missedReloadURL[id].url)

        //  if (this.temperatureChart.plotBGImage && this.latestChart.plotBGImage)
        //    document.removeEventListener('scroll',this.eventHandler.scroll, {passive: true})
    }

    WeatherStation.prototype.updatePlotbackgroundImage = function (chart, url) {
        var visible = this.isInViewport(chart.plotBackground.element),
            id = chart.renderTo.id

        if (visible) {
            console.log('Updating plotbackground ' + id + ' url ' + url)
            chart.update({ chart: { plotBackgroundImage: url } })
            if (this.options.missedReloadURL)
                delete this.options.missedReloadURL[id]
        }
        else {
            if (!this.options.missedReloadURL)
                this.options.missedReloadURL = {}

            if (!this.options.missedReloadURL[id])
                this.options.missedReloadURL[id] = { chart: chart, url: url, time: Date.now() }
            else {
                this.options.missedReloadURL[id].chart = chart
                this.options.missedReloadURL[id].url = url
                this.options.missedReloadURL[id].time = Date.now()
            }

            // console.warn('Reload when visible '+id+' url '+url)
        }

        return visible
    }

    WeatherStation.prototype.reloadPlotBackgroundImage = function (chart, url, interval, bypassBrowserCache) {
        var id = chart.renderTo.id

        this.updatePlotbackgroundImage(chart, url)

        console.log('setting reload of ' + id + ' plotbackgroundimage ' + url + ' to ' + interval)

        this.timeoutID['plotbackgroundimage-' + id] = setInterval(function _reloadPlotBackgroundImage() {
            // Problem: image not reloaded due to caching; Chrome devtools "disable cache" enabled -> reloads image
            // 15 minute interval: 4*24 = 96 &, 5 minute interval: 3*15min interval = 288 &
            // < server: nginx/1.18.0 (Ubuntu), default buffer size 1KB, should not allocate buffers for empty key=value pairs  http://nginx.org/en/docs/http/ngx_http_core_module.html#client_header_buffer_size
            if (bypassBrowserCache)
                url = url + '&' // add empty key=value, to bypass cache in browser, not optimal but works,use slow interval=1 hour to limit url string length, in theory a "414 URI Too Long" may be generated https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/414

            this.updatePlotbackgroundImage(chart, url)
        }.bind(this), interval)

    }

    WeatherStation.prototype.isInViewport = function (element) {
        // https://www.javascripttutorial.net/dom/css/check-if-an-element-is-visible-in-the-viewport/
        var rect = element.getBoundingClientRect(),
            visible
        // console.log('boundingclientrect '+JSON.stringify(rect))
        // console.log('innerHeight '+window.innerHeight+' innerwidth '+window.innerWidth+' clientHeight '+document.documentElement.clientHeight+' clientWidth '+document.documentElement.clientWidth)
        visible = (
            rect.top >= 0 &&
            rect.left >= 0 &&
            rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
            rect.right <= (window.innerWidth || document.documentElement.clientWidth)
        );

        return visible
    }

    WeatherStation.prototype.testMemory = function ()
    // Allocates 1MB until memory is exausted and generates LowMemory log on ipad1
    // Test LG Smart TV 2012: 262MB before "not enough memory" popup
    {
        console.log('typeof Uint8Array: ' + typeof Uint8Array)

        if (typeof Uint8Array !== 'function' && typeof Uint8Array !== 'object') {
            console.error('Uint8Array not available')
            return
        }

        var heap = []
        var bytes = 0
        var Mebibyte = 1024 * 1024 // https://en.wikipedia.org/wiki/Megabyte

        while (true) {
            heap.push(new Uint8Array(Mebibyte))
            bytes += Mebibyte
            //console.log('Allocated MB'+bytes/Mebibyte)
            alert(bytes / Mebibyte + ' MB allocated')
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

    WeatherStation.prototype.addStation = function (station) {
        if (station instanceof StationGW) {
            this.initWindroseChart(station)
            station.getJSON.request.addEventListener("load", this.onJSONLivedata.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONLatestChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONTemperatureChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONWindbarbChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONWindroseChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONSolarChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONRainchart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONRainstatChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONPressureChart.bind(this, station))
        } else if (station instanceof StationWU) {
            console.log('StationWU', station)
            this.initWindroseChart(station)
            station.getJSON.request.addEventListener("load", this.onJSONLatestChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONTemperatureChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONWindbarbChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONWindroseChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONSolarChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONRainchart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONPressureChart.bind(this, station))

        } else if (station instanceof StationYrForecastNow)
        {
            station.getJSON.request.addEventListener("load",this.onJSONYrForecastNow.bind(this,station))
            this.stationsYrForecastNow.push(station)
        }

        this.stations.push(station)
        station.getJSON.request.addEventListener("load", this.redrawCharts.bind(this))
    }

    WeatherStation.prototype.initStations = function (port) {

        this.addStation(new StationGW('Tomasjord', 'ITOMAS1'))
        this.addStation(new StationWU('Engenes', 'IENGEN26'))
        this.addStation(new StationYrForecastNow('Tomasjord','radar-forecast-ITOMAS1','1-305426'))
        this.addStation(new StationYrForecastNow('Engenes','radar-forecast-IENGEN26','1-290674'))

        /*
        if (this.options.frostapi.enabled) {
            this.getJSONFrostLatest15Min = new GetJSONFrost(window.location.origin+'/api/frost.met.no/latest',GetJSON.prototype.requestInterval.min15,this.options.frostapi)
            this.getJSONFrostLatest15Min.request.addEventListener("load",this.onJSONFrost.bind(this,this.getJSONFrostLatest15Min))
            this.getJSONFrostLatest15Min.request.addEventListener("load",this.redrawCharts.bind(this))
    
           // this.getJSONFrostLatest1H = new GetJSONFrost(window.location.origin+'/api/frost.met.no/latest-1H',GetJSON.prototype.requestInterval.hour1,this.options.frostapi)
           // this.getJSONFrostLatest1H.request.addEventListener("load",this.onJSONFrost.bind(this,this.getJSONFrostLatest1H))
           // this.getJSONFrostLatest1H.request.addEventListener("load",this.onJSONloadredrawCharts.bind(this))
    
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

    WeatherStation.prototype.onJSONHolfuyLive = function (evt) {
        console.log('holfuy', evt)
    }

    WeatherStation.prototype.addObservationsMETno = function (data) {
        var series,
            observation,
            obsNr,
            elementId,
            lastSeriesData

        for (elementId in data) {
            switch (elementId) {
                case 'air_pressure_at_sea_level':

                    if (this.pressureChart)
                        series = this.pressureChart.get('series-metno-air_pressure_at_sea_level')
                    break

                case 'air_temperature':

                    if (this.temperatureChart) {
                        series = this.temperatureChart.get('series-metno-temperature10min')
                    }

                    break

                case 'relative_humidity':

                    if (this.temperatureChart)
                        series = this.temperatureChart.get('series-metno-humidity1h')
                    break

                case 'wind_speed':

                    if (this.windbarbchart)
                        series = this.windbarbchart.get('series-metno-windmean10min')
                    break

                /*   case 'max(wind_speed PT1H)':
       
                       if (this.windbarbchart)
                           series=this.windbarbchart.series[3]
                       break */

                // Multi-criteria case https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/switch
                case 'max(wind_speed_of_gust PT1H)':
                case 'max(wind_speed_of_gust PT10M)':

                    if (this.windbarbchart)
                        series = this.windbarbchart.get('series-metno-windgustmax10min')
                    break

                case 'mean(surface_downwelling_shortwave_flux_in_air PT1H)':
                case 'mean(surface_downwelling_shortwave_flux_in_air PT1M)':

                    if (this.solarchart)
                        series = this.solarchart.get('series-metno-irradiance-mean1m')
                    break

                default:

                    console.warn('METno elementId ' + elementId + ' no series found in chart')
                    continue

            }

            if (!series) {
                console.warn('Unable to get series for ' + elementId)
                continue
            }

            lastSeriesData = series.options.data[series.options.data.length - 1]
            data[elementId].forEach(function _addObservation(observation) {
                if (!lastSeriesData || (lastSeriesData[0] !== observation.timestamp)) {
                    console.log('addpoint', series.name, [observation.timestamp, observation.value])
                    series.addPoint([observation.timestamp, observation.value], false, this.options.shift, this.options.animation, false)
                }
                else
                    console.warn(elementId + ' Skippping observation already is series; timestamp ' + observation.timestamp + ' value ' + observation.value, series) // same value of relative_humidity and air_pressure_at_at_sea_level each 1h is included each 10m in JSON

            }.bind(this))

            series = undefined
        }
    }

    WeatherStation.prototype.updateFrostLatestChart = function (METnoRequest) {
        var redraw = false,
            animation = this.options.animation,
            currentStation = 0

        if (this.latestChart) {
            var stationCategoryIndex = this.options.frostapi.stations[currentStation].stationCategoryIndex // METno

            this.updateStationCategories(station)

            var outtemp = METnoRequest.getLatestObservation('air_temperature')
            if (outtemp) {
                this.latestChart.get('series-temperature').options.data[stationCategoryIndex] = outtemp
            }

            var humidity = METnoRequest.getLatestObservation('relative_humidity')

            if (humidity)
                this.latestChart.get('series-humidity').options.data[stationCategoryIndex] = humidity

            var windspeed = METnoRequest.getLatestObservation('wind_speed')

            if (windspeed)
                this.latestChart.get('series-windspeed').options.data[stationCategoryIndex] = windspeed

            var windgust = METnoRequest.getLatestObservation('max(wind_speed_of_gust PT10M)')

            if (windgust)
                this.latestChart.get('series-windgust').options.data[stationCategoryIndex] = windgust

            var winddirection = METnoRequest.getLatestObservation('wind_from_direction')

            if (winddirection)
                this.latestChart.get('series-winddirection').options.data[stationCategoryIndex] = winddirection

            var relbaro = METnoRequest.getLatestObservation('air_pressure_at_sea_level')

            if (relbaro)
                this.latestChart.get('series-relbaro').options.data[stationCategoryIndex] = relbaro

            var irradiance = METnoRequest.getLatestObservation("mean(surface_downwelling_shortwave_flux_in_air PT1M)")

            if (irradiance)
                this.latestChart.get('series-irradiance').options.data[stationCategoryIndex] = irradiance

            this.latestChart.series.forEach(function (series) {
                series.setData(series.options.data, redraw, animation)
            })

        }
    }

    WeatherStation.prototype.onJSONFrost = function (jsonReq, evt) {
        this.addObservationsMETno(jsonReq.data)
        this.updateFrostLatestChart(jsonReq)
    }

    WeatherStation.prototype.onJSONFrostPrecipitationHour = function (evt) {
        var json = this.getJSON.jsonFrostPrecipitationHour
        //console.log('ui got',json)
        var precipitationDay = 0
        json.data.forEach(function (data) { precipitationDay = precipitationDay + data.observations[0].value })
        var precipitationHour = json.data[json.data.length - 1].observations[0].value
        //console.log('precipitation today: '+ precipitationDay+' precip. hour: '+precipitationHour)
        // this.rainstatchart.series[2].setData([['hour',precipitationHour],['day',precipitationDay],null,null,null],false,this.options.animation)
    }

    WeatherStation.prototype.isLowMemoryDevice = function () {
        return this.isIpad1() || this.isLGSmartTV2012()
    }

    WeatherStation.prototype.isIpad1 = function () {
        // "Mozilla/5.0 (iPad; CPU OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B206 Safari/7534.48.3"
        return navigator.userAgent.indexOf("iPad; CPU OS 5_1_1 like Mac OS X") !== -1
    }

    WeatherStation.prototype.isLGSmartTV2012 = function () {
        // https://www.lg.com/se/support/manuals?csSalesCode=42LM669T.AEN
        // Mozilla/5.0 (X11; Linux; ko-KR) AppleWebKit/534.26+ (KHTML, like Gecko) Version/5.0 Safari/534.26
        return navigator.userAgent.indexOf("Mozilla/5.0 (X11; Linux; ko-KR) AppleWebKit/534.26+ (KHTML, like Gecko) Version/5.0 Safari/534.26") !== -1
    }

    WeatherStation.prototype.initWindroseChart = function (station) {
        var newWindrose,
            windrosechart,
            renderTo = 'windrosechart-' + this.windrosechart.length

        newWindrose = document.createElement('div')
        newWindrose.setAttribute('id', renderTo)

        document.getElementById('windroses').appendChild(newWindrose)

        windrosechart = Highcharts.chart(renderTo, {
            chart: {
                animation: this.options.animation,
                polar: true,
                type: 'column'
            },

            tooltip: {
                enabled: this.options.tooltip
            },

            credits: {
                enabled: false
            },

            title: {
                text: 'Wind rose ' + station.name,
                //align: 'centre'
            },

            /* subtitle: {
                 text: 'Based on windgust data',
                 //align: 'left'
             }, */

            legend: {
                enabled: false,
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
                        valueDecimals: 1,
                        valueSuffix: ' %'
                    }
                }
            },

            // Colors from https://en.wikipedia.org/wiki/Beaufort_scale

            series: [
                // Beufort scale 0 Calm
                {
                    name: '0 Calm < 0.5 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#7cb5ec' // from Highcharts
                },
                // Beufort scale 1 
                {
                    name: '1 Light air 0.5 - 1.5 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#AEF1F9'
                },
                // Beufort scale 1 
                {
                    name: '2 Light breeze 1.6 - 3.3 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#96F7DC'
                },
                // Beufort scale 3
                {
                    name: '3 Gentle breeze 3.4 - 5.5 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#96F7B4'
                },
                // Beufort scale 4
                {
                    name: '4 Moderat breeze 5.6 - 7.9 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#6FF46F'
                },
                // Beufort scale 5
                {
                    name: '5 Fresh breeze 8 - 10.7 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#73ED12'
                },
                // Beufort scale 6
                {
                    name: '6 Strong breeze 10.8 - 13.8 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#A4ED12'
                },
                // Beufort scale 7
                {
                    name: '7 Near gale 13.9 - 17.1 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#DAED12'
                },
                // Beufort scale 8
                {
                    name: '8 Gale  17.2 - 20.7 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#EDC212'
                },
                // Beufort scale 9
                {
                    name: '9 Strong gale 20.8 - 24.4 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#ED8F12'
                },
                // Beufort scale 10
                {
                    name: '10 Storm 24.5 - 28.4 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#ED6312'
                },
                // Beufort scale 11 
                {
                    name: '11 Violent storm  28.5 - 32.6 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#ED2912'
                },
                // Beufort scale 12 
                {
                    name: '12 Hurricane force > 32.6 m/s',
                    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                    color: '#D5102D'
                }
            ]
        });

        this.windrosechart.push(windrosechart)

    }

    WeatherStation.prototype.initTemperatureChart = function () {

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

        this.temperatureChart = new Highcharts.stockChart({
            chart: {
                animation: this.options.animation,
                renderTo: 'temperaturechart',
                //plotBackgroundImage: this.options.weatherapi.geosatellite.enabled ? this.options.weatherapi.geosatellite.url_europe : '',
                height: this.options.weatherapi.geosatellite.enabled ? (720) : undefined,
                events: {
                    click: this.onClickToggleChartSeries.bind(this)
                }
            },

            rangeSelector: this.options.rangeSelector,

            scrollbar: {
                enabled: false
            },

            navigator: this.options.navigator,

            legend: {
                enabled: true
            },

            tooltip: {
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
                title: false,
                //opposite: true,
                min: 0,
                max: 100,
                gridLineWidth: this.options.weatherapi.geosatellite.enabled ? 0 : 1
            },
            ],
            xAxis: [{

                id: 'axis-datetime',

                type: 'datetime',

                offset: 10,

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

    WeatherStation.prototype.initPressureChart = function () {

        /*  if (this.options.frostapi.enabled) {
             pressureSeries.push(
              {
                  name: 'METno Sea-level pressure (QFF) 1h',
                  id: 'series-metno-air_pressure_at_sea_level',
                  type: 'spline',
                  data: [],
                  visible: false
              })
          } */

        this.pressureChart = new Highcharts.stockChart({
            chart: {
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
            rangeSelector: this.options.rangeSelector,

            scrollbar: {
                enabled: false
            },

            navigator: this.options.navigator,

            legend: {
                enabled: true
            },

            tooltip: {
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
                tickInterval: 5
                //min: 950
                //max : null

            }

            ],
            xAxis: [{
                type: 'datetime'
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

            series: [],

        })
    }

    WeatherStation.prototype.onClickToggleChartSeries = function (event)
    // Toggle display of series to reveal underlying image
    {
        var id = event.xAxis[0].axis.chart.renderTo.id,
            restoreHiddenSeries = this.restoreHiddenSeries[id]

        // console.log('click',event)

        if (!restoreHiddenSeries)
            restoreHiddenSeries = this.restoreHiddenSeries[id] = []

        if (restoreHiddenSeries && restoreHiddenSeries.length) {
            restoreHiddenSeries.forEach(function (series) { series.show() })
            this.restoreHiddenSeries[id] = []
        } else {

            event.xAxis[0].axis.chart.series.forEach(function (series) {

                if (series.visible) {
                    restoreHiddenSeries.push(series)
                    series.hide()
                }

            })
        }
    }

    WeatherStation.prototype.initLatestChart = function () {

        var dataLabelStyle = {
            fontSize: 16,
            fontWeight: 'bold'
        }

        this.latestChart = new Highcharts.chart('latestChart',
            {
                chart: {
                    //animation: this.options.animation
                    // plotBackgroundImage: this.options.weatherapi.radar.enabled ? this.options.weatherapi.radar.url_troms_5level_reflectivity : '',
                    height: this.options.weatherapi.radar.enabled ? (640) : undefined,
                    events: {
                        // Allow viewing of underlying image
                        click: this.onClickToggleChartSeries.bind(this)
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
                        id: 'yaxis-temperature',
                        title: { text: 'Temperature' },
                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1,
                        visible: false
                        //max: 60
                    },
                    // Humidity
                    {
                        id: 'yaxis-humidity',
                        min: 0,
                        max: 100,
                        title: { text: 'Humidity' },
                        opposite: true,
                        visible: false,
                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                    },
                    // Wind
                    {
                        id: 'yaxis-wind',
                        min: 0,
                        title: { text: 'Wind speed' },
                        opposite: true,
                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1,
                        visible: false
                    },
                    // Wind direction
                    {
                        id: 'yaxis-winddirection',
                        min: 0,
                        max: 359,
                        title: { text: 'Wind direction' },
                        opposite: true,
                        visible: false,
                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                    },
                    // Pressure
                    {
                        id: 'yaxis-pressure',
                        min: 0,
                        title: false,
                        opposite: true,
                        visible: false,
                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                    },
                    // Irradiance
                    {
                        id: 'yaxis-irradiance',
                        min: 0,
                        title: false,
                        visible: false,
                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                    },
                    // UVI
                    {
                        id: 'yaxis-uvi',
                        min: 0,
                        title: false,
                        visible: false,
                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                    },
                    // Rain rate
                    {
                        min: 0,
                        title: { text: 'Rain rate mm/h' },
                        visible: false,
                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1,
                        tickInterval: 0.5,
                        id: 'yaxis-rainrate'
                    },
                    // Rain Today
                    {
                        id: 'yaxis-rainrate',
                        min: 0,
                        title: { text: 'Rain today' },
                        visible: false,
                        gridLineWidth: this.options.weatherapi.radar.enabled ? 0 : 1
                    }

                ],
                xAxis: [{
                    type: 'column',
                    categories: []
                }, {
                    type: 'datetime',
                    id: 'xaxis-datetime'
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
                            //  color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                            style: {
                                fontSize: 16,
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
                            //  color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                            style: dataLabelStyle
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
                            //  color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                            style: dataLabelStyle
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
                            format: '{point.y:.1f}',
                            // color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                            style: dataLabelStyle
                        }
                    },
                    {
                        name: 'Wind gust',
                        id: 'series-windgust',
                        type: 'column',
                        yAxis: 2,
                        dataLabels: {
                            enabled: true && !this.options.isLGSmartTV2012,
                            format: '{point.y:.1f}',
                            // color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                            style: dataLabelStyle
                        }
                    },
                    {
                        name: 'Wind direction',
                        id: 'series-winddirection',
                        type: 'column',
                        yAxis: 3,
                        tooltip: {
                            pointFormatter: function () {
                                return this.series.name + ' ' + WindConverter.prototype.fromDegToCompassDirection(this.y) + ' (' + this.y + ')'
                            }
                        },
                        dataLabels: {
                            enabled: true && !this.options.isLGSmartTV2012,
                            //  color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                            style: dataLabelStyle,
                            formatter: function () {
                                return WindConverter.prototype.fromDegToCompassDirection(this.y)
                            }
                        }
                    },
                    {
                        name: 'Rain rate',
                        id: 'series-rainrate',
                        type: 'column',
                        yAxis: 7,
                        dataLabels: {
                            enabled: true && !this.options.isLGSmartTV2012,
                            format: '{point.y:.1f}',
                            //  color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                            style: dataLabelStyle
                        },
                        visible: true,
                        //zones:  this.zones.rainrate
                    },
                    {
                        name: 'Rain day',
                        id: 'series-raintoday',
                        type: 'column',
                        yAxis: 8,
                        dataLabels: {
                            enabled: true && !this.options.isLGSmartTV2012,
                            format: '{point.y:.1f}',
                            //  color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                            style: dataLabelStyle
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
                            format: '{point.y:.1f}',
                            //  color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                            style: dataLabelStyle
                        },
                        visible: true
                    },
                    {
                        name: 'Sunlight',
                        id: 'series-irradiance',
                        type: 'column',
                        yAxis: 5,
                        dataLabels: {
                            enabled: true && !this.options.isLGSmartTV2012,
                            //  color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                            style: dataLabelStyle
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
                            // color : this.options.weatherapi.radar.enabled ?  '#ffffff' : undefined,
                            style: dataLabelStyle
                        },
                        visible: false,
                        // zones : this.zones.uvi
                    },
                ]
            })

        this.latestChart.series.forEach(function (series) {

            series.options.data = [];

            series.xAxis.categories.forEach(function (category) {
                series.options.data.push(null)
            })
        })

    }

    WeatherStation.prototype.initRainstatChart = function () {
        this.rainstatchart = new Highcharts.chart('rainstatchart',
            {
                chart: {
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
                }, {
                    min: 0,
                    title: false,
                    opposite: true,
                }],
                xAxis: [{
                    type: 'column',
                    categories: [] // Stations
                }],
                tooltip: {
                    enabled: this.options.tooltip
                },
                plotOptions: {
                    series: {
                        dataLabels: {
                            enabled: true && !this.options.isLGSmartTV2012
                        }
                    }
                },
                series: [
                    { name: 'Rain hour', id: 'series-rainhour', type: 'column' },
                    { name: 'Rain day', id: 'series-rainday', type: 'column', yAxis: 1 },
                    { name: 'Rain event', id: 'series-rainevent', type: 'column', yAxis: 1 },
                    { name: 'Rain week', id: 'series-rainweek', type: 'column', yAxis: 1 },
                    { name: 'Rain month', id: 'series-rainmonth', type: 'column', yAxis: 1 },
                    { name: 'Rain year', id: 'series-rainyear', type: 'column', yAxis: 1 }
                ]
            })
    }

    WeatherStation.prototype.initRainChart = function () {
        this.rainchart = new Highcharts.stockChart({
            chart: {
                animation: this.options.animation,
                renderTo: 'rainchart',
            },
            rangeSelector: this.options.rangeSelector,

            scrollbar: {
                enabled: false
            },

            navigator: this.options.navigator,

            legend: {
                enabled: true
            },

            tooltip: {
                enabled: this.options.tooltip
            },
            credits: {
                enabled: false
            },
            title: {
                text: 'Rain'
            },
            yAxis: [{
                title: {
                    text: 'Rainrate mm/h'
                },
                min: 0,
                opposite: false,
                //tickInterval: 0.1,
                id: 'yaxis-rainrate'

            },
            {
                title: {
                    text: 'Rain mm'
                },
                min: 0,
                // tickInterval: 5,
                id: 'yaxis-rain'

            }],
            xAxis: [{

                type: 'datetime'

            }],
            plotOptions: {
                series: {
                    enableMouseTracking: this.options.mousetracking,
                    dataGrouping: {
                        groupPixelWidth: 30
                    }
                }
            },

        })
    }

    WeatherStation.prototype.initSolarChart = function () {
        this.solarchart = new Highcharts.stockChart({
            chart: {
                animation: this.options.animation,
                renderTo: 'solarchart',
            },
            rangeSelector: this.options.rangeSelector,

            scrollbar: {
                enabled: false
            },

            navigator: this.options.navigator,

            legend: {
                enabled: true
            },

            tooltip: {
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
                min: 0,
                tickInterval: 50,
                opposite: false,
                id: 'yaxis-irradiance'
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
                title: false,
                min: 0,
                tickInterval: 1,
                allowDecimals: false,
                id: 'yaxis-uvi'
            }
            ],
            xAxis: [{
                id: 'axis-datetime',
                type: 'datetime',
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

        })
    }

    WeatherStation.prototype.initWindBarbChart = function () {
        // based on https://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/demo/windbarb-series/
        this.windbarbchart = new Highcharts.stockChart({
            chart: {
                animation: this.options.animation,
                renderTo: 'windbarbchart'
            },

            rangeSelector: this.options.rangeSelector,

            scrollbar: {
                enabled: false
            },

            navigator: this.options.navigator,

            legend: {
                enabled: true
            },

            tooltip: {
                enabled: this.options.tooltip,
            },

            title: {
                text: 'Wind'
            },

            xAxis: [{
                type: 'datetime',
                offset: 40
            }, {
                type: 'category',
                categories: ['Wind daily max.']
            }],

            yAxis: [{
                title: false,
                tickInterval: 0.5,
                //   plotLines: [{
                //       id: 'winddailymax',
                //       color: '#ff0000',
                //       value: 1.7
                //   }]
            },
            {
                max: 359,
                min: 0,
                visible: false
            }],

            plotOptions: {
                series: {
                    enableMouseTracking: this.options.mousetracking
                }
            },

        });
    }

    WeatherStation.prototype.initCharts = function () {

        // Windrose demo https://jsfiddle.net/fq64pkhn/
        //var testChart=Highcharts.stockChart('testchart',{ title: { text: 'test chart' }}) 
        this.zones = {
            uvi: [{
                value: 2,
                color: '#2a9502'   // green
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
            ],

            rainrate_yr: [{
                value: 1.0,
                color: 'rgb(145,228,255)'
            },
            {
                value: 1.5,
                color: 'rgb(94,215,255)'
            },
            {
                value: 2.0,
                color: 'rgb(0,170,255)'
            },
            {
                value: 2.5,
                color: 'rgb(0,128,255)'
            },
            {
                value: 3.0,
                color: 'rgb(0,85,255)'
            },
            {
                color: 'rgb(122,0,135)'
            }
            ]
        }

        // this.initTestChart()
        this.initLatestChart()
        this.initTemperatureChart()
        this.initWindBarbChart()
        //this.initWindroseChart() 
        this.initPressureChart()
        this.initRainChart()
        this.initRainstatChart()
        this.initSolarChart()

    }

    WeatherStation.prototype.initTestChart = function () {
        this.testChart = new Highcharts.chart('testchart', {
            chart: {
                type: 'column'
            },

            xAxis: {
                categories: [
                    'Jan', 'Feb'
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
                data: [49.9, null]
            }]
        });
    }

    WeatherStation.prototype.onJSONYrForecastNow = function (station) {
        var redraw = false,
            animation = this.options.animation,
            updatePoints = true,
            id = station.id,
            seriesId,
            series,
            data=station.yrForecastnowPoints,
            points=station.points,
            yAxisRainrate,
            hasPrecipitation
        
       seriesId='series-rainrate-yrforecastnow-'+id
        series = this.rainchart.get(seriesId)
        if (series)
            series.setData(data, redraw, animation, updatePoints)
        else
            this.rainchart.addSeries({
                name: 'Yr '+station.name,
                id: seriesId,
                type: 'spline',
                yAxis: this.rainchart.yAxis.indexOf(this.rainchart.get('yaxis-rainrate')),
                data: data,
                tooltip: {
                    valueDecimals: 1,
                    valueSuffix: ' mm/h'
                },
                zones: this.zones.rainrate_yr
            }, redraw, animation)

       

        yAxisRainrate=this.latestChart.get('yaxis-rainrate')
        hasPrecipitation = this.stationsYrForecastNow.some(function (station) { 
              return station.hasPrecipitation() 
        })
        
        if (hasPrecipitation)
          yAxisRainrate.visible=true
        else
          yAxisRainrate.visible=false

        seriesId='series-rainrate-yrforecastnow-'+id
        series = this.latestChart.get(seriesId)

        if (series)
            series.setData(points, redraw, animation, updatePoints)
        else
            this.latestChart.addSeries({
                name: 'Yr '+station.name,
                id: seriesid,
                type: 'spline',
                xAxis: this.latestChart.xAxis.indexOf(this.latestChart.get('xaxis-datetime')),
                yAxis: this.latestChart.yAxis.indexOf(this.latestChart.get('yaxis-rainrate')),
                // opacity: 0.5,
                // zIndex: 10,
                data: points,
                zones: this.zones.rainrate_yr,
                tooltip: {
                    valueDecimals : 1,
                    valueSuffix: ' mm/h'
                },
            }, redraw, animation)
    }

    WeatherStation.prototype.onJSONLivedata = function (station, ev) {
        var jsonReq = station.getJSON
        // Show when data is available
        // if (this.weatherElement.style.display==="none")
        //   this.weatherElement.style.display="block"

        this.outtempElement.textContent = jsonReq.outtemp()
        this.intempElement.textContent = jsonReq.intemp()
        this.unitTempElement.textContent = jsonReq.unitTemp()

        this.windspeedElement.textContent = jsonReq.windspeed()
        this.windgustspeedElement.textContent = jsonReq.windgustspeed()
        this.winddirection_compassElement.textContent = jsonReq.winddirection_compass()
        this.windgustspeed_beufort_descriptionElement.textContent = jsonReq.windgustbeufort_description()
        this.unitWindElement.textContent = jsonReq.unitWind()
        this.meter_windgustspeedElement.value = jsonReq.windgustspeed()

        this.relbaroElement.textContent = jsonReq.relbaro()
        this.absbaroElement.textContent = jsonReq.absbaro()
        this.unitpressureElement.textContent = jsonReq.unitPressure()

        this.solar_lightElement.textContent = jsonReq.solar_light()
        this.unit_solar_lightElement.textContent = jsonReq.unitSolarlight()
        this.solar_uvElement.textContent = jsonReq.solar_uv()
        this.unit_solar_uvElement.textContent = jsonReq.unitSolarUV()
        this.solar_uviElement.textContent = jsonReq.solar_uvi()

    }

    WeatherStation.prototype.updateStationCategories = function (chart) {
        var redraw = false,
            stationNames

        if (!chart)
            return

        stationNames = this.stations.map(function (station) { if (!station.timestampHHMMSS) return station.name; else return station.name + ' ' + station.timestampHHMMSS })
        chart.xAxis[0].setCategories(stationNames, redraw)
    }

    WeatherStation.prototype.onJSONLatestChart = function (station) {
        var getJSON = station.getJSON,
            redraw = false,
            animation = this.options.animation,
            stationCategoryIndex = this.stations.indexOf(station),
            chart = this.latestChart

        if (!chart)
            return

        this.updateStationCategories(chart)
        chart.get('series-temperature').options.data[stationCategoryIndex] = getJSON.outtemp()
        var windchill = getJSON.windchill() // available in WU
        if (windchill !== undefined)
            chart.get('series-windchill').options.data[stationCategoryIndex] = windchill

        //chart.series[0].options.data[1]=getJSON.intemp()
        chart.get('series-humidity').options.data[stationCategoryIndex] = getJSON.outhumidity()
        //chart.series[1].options.data[1]=getJSON.inhumidity()
        chart.get('series-windspeed').options.data[stationCategoryIndex] = getJSON.windspeed_mps()
        chart.get('series-windgust').options.data[stationCategoryIndex] = getJSON.windgustspeed_mps()
        chart.get('series-winddirection').options.data[stationCategoryIndex] = getJSON.winddirection()
        chart.get('series-relbaro').options.data[stationCategoryIndex] = getJSON.relbaro()
        chart.get('series-irradiance').options.data[stationCategoryIndex] = getJSON.solar_light()
        chart.get('series-UVI').options.data[stationCategoryIndex] = getJSON.solar_uvi()
        chart.get('series-rainrate').options.data[stationCategoryIndex] = getJSON.rainrate()
        chart.get('series-raintoday').options.data[stationCategoryIndex] = getJSON.rainday()

        chart.series.forEach(function (series) {
            for (var i = 0; i < series.options.data.length; i++) // make sure we have null data for stations thats not received JSON data yet
                if (series.options.data[i] === undefined)
                    series.options.data[i] = null
            // console.log('setData',series.name,series.options.data)
            series.setData(series.options.data, redraw, animation)
        })

    }

    WeatherStation.prototype.onJSONWindroseChart = function (station) {
        var getJSON = station.getJSON,
            redraw = false,
            animation = this.options.animation,
            updatePoints = true,
            stationCategoryIndex = this.stations.indexOf(station),
            percentArr,
            beufortScale,
            measurementCount = station.measurementCount,
            windrosedata = station.windrosedata

        if (stationCategoryIndex === -1) {
            console.error('Station not found for windrose')
            return
        }

        beufortScale = getJSON.windgustspeed_beufort()
        var windDirection = getJSON.winddirection_compass_value() - 1
        windrosedata[beufortScale][windDirection] = windrosedata[beufortScale][windDirection] + 1
        console.log('windrosedata ' + station.name + ' beufortscale: ' + beufortScale, windrosedata[beufortScale])

        for (beufortScale = 0; beufortScale < 12; beufortScale++) {
            percentArr = []
            windrosedata[beufortScale].forEach(function (measurement) {
                percentArr.push(measurement / measurementCount * 100)
            })
            //console.log('percentarray',percentArr)
            this.windrosechart[stationCategoryIndex].series[beufortScale].setData(percentArr, redraw, animation, updatePoints)
        }
    }

    WeatherStation.prototype.onJSONTemperatureChart = function (station) {
        var getJSON = station.getJSON,
            timestamp = station.timestamp,
            id = station.id,
            name = station.name
        redraw = false,
            shift = false
        animation = this.options.animation

        if (!this.temperatureChart)
            return

        var series = this.temperatureChart.get('series-outdoor-' + id)
        if (series)
            series.addPoint([timestamp, getJSON.outtemp()], redraw, shift, animation)
        else
            this.temperatureChart.addSeries({
                name: 'Outdoor ' + name,
                id: 'series-outdoor-' + id,
                type: 'spline',
                yAxis: 0,
                data: [[timestamp, getJSON.outtemp()]],
                zIndex: 5
            }, redraw, animation)

        series = this.temperatureChart.get('series-outdoor-humidity-' + id)
        if (series)
            series.addPoint([timestamp, getJSON.outhumidity()], redraw, shift, animation)
        else
            this.temperatureChart.addSeries({
                name: 'Outdoor humidity ' + name,
                id: 'series-outdoor-humidity-' + id,
                type: 'spline',
                yAxis: 1,
                data: [[timestamp, getJSON.outhumidity()]],
                tooltip: {
                    valueSuffix: ' %'
                },
                zIndex: 5,
                visible: false
            }, redraw, animation)

        var intemp = getJSON.intemp()
        if (intemp !== undefined) {
            series = this.temperatureChart.get('series-indoor-' + id)
            if (series)
                series.addPoint([timestamp, intemp], redraw, shift, animation)
            else
                this.temperatureChart.addSeries({
                    name: 'Indoor ' + name,
                    id: 'series-indoor-' + id,
                    type: 'spline',
                    yAxis: 0,
                    data: [[timestamp, intemp]],
                    zIndex: 5,
                    visible: false
                }, redraw, animation)
        }

        var inhumidity = getJSON.inhumidity()

        if (inhumidity !== undefined) {
            series = this.temperatureChart.get('series-indoor-humidity-' + id)
            if (series)
                series.addPoint([timestamp, inhumidity], redraw, shift, animation)
            else
                this.temperatureChart.addSeries({
                    name: 'Indoor humidity ' + name,
                    id: 'series-indoor-humidity-' + id,
                    type: 'spline',
                    yAxis: 1,
                    data: [[timestamp, inhumidity]],
                    tooltip: {
                        valueSuffix: ' %'
                    },
                    zIndex: 5,
                    visible: false
                }, redraw, animation)
        }
    }

    WeatherStation.prototype.onJSONPressureChart = function (station) {
        var getJSON = station.getJSON,
            timestamp = station.timestamp,
            id = station.id,
            name = station.name
        redraw = false,
            shift = false
        animation = this.options.animation

        if (!this.pressureChart)
            return

        var series = this.pressureChart.get('series-relbaro-' + id)
        if (series)
            series.addPoint([timestamp, getJSON.relbaro()], redraw, shift, animation)
        else
            this.pressureChart.addSeries({
                name: 'Relative ' + name,
                id: 'series-relbaro-' + id,
                type: 'spline',
                data: [[timestamp, getJSON.relbaro()]]
            }, redraw, animation)

        var absbaro = getJSON.absbaro()
        if (absbaro !== undefined) {
            series = this.pressureChart.get('series-absbaro-' + id)
            if (series)
                series.addPoint([timestamp, getJSON.absbaro()], redraw, shift, animation)
            else
                this.pressureChart.addSeries({
                    name: 'Absolute ' + name,
                    id: 'series-absbaro-' + id,
                    type: 'spline',
                    data: [[timestamp, getJSON.absbaro()]],
                    visible: false
                }, redraw, animation)
        }

    }

    WeatherStation.prototype.onJSONWindbarbChart = function (station) {
        var getJSON = station.getJSON,
            timestamp = station.timestamp,
            redraw = false,
            shift = false,
            animation = this.options.animation,
            series,
            seriesId,
            id = station.id,
            nameStation = station.name

        if (!this.windbarbchart)
            return

        seriesId = 'series-windbarb-' + id
        series = this.windbarbchart.get(seriesId)
        if (series)
            series.addPoint([timestamp, getJSON.windgustspeed_mps(), getJSON.winddirection()], redraw, shift, animation)
        else
            this.windbarbchart.addSeries({
                name: 'Windbarb ' + nameStation,
                id: seriesId,
                type: 'windbarb',
                data: [[timestamp, getJSON.windgustspeed_mps(), getJSON.winddirection()]],
                showInLegend: true,
                visible: false
            }, redraw, animation)

        seriesId = 'series-wind-' + id
        series = this.windbarbchart.get(seriesId)
        if (series)
            series.addPoint([timestamp, getJSON.windspeed_mps()], redraw, shift, animation)
        else
            this.windbarbchart.addSeries({
                name: 'Wind speed ' + nameStation,
                id: seriesId,
                type: 'spline',
                data: [[timestamp, getJSON.windspeed_mps()]],
                tooltip: {
                    valueSuffix: ' m/s',
                    valueDecimals: 1
                }
            }, redraw, animation)

        seriesId = 'series-windgust-' + id
        series = this.windbarbchart.get(seriesId)
        if (series)
            series.addPoint([timestamp, getJSON.windgustspeed_mps()], redraw, shift, animation)
        else
            this.windbarbchart.addSeries({
                name: 'Wind gust ' + nameStation,
                id: seriesId,
                type: 'spline',
                data: [[timestamp, getJSON.windgustspeed_mps()]],
                tooltip: {
                    valueSuffix: ' m/s',
                    valueDecimals: 1
                }
            }, redraw, animation)

        seriesId = 'series-winddirection-' + id
        series = this.windbarbchart.get(seriesId)
        if (series)
            series.addPoint([timestamp, getJSON.winddirection()], redraw, shift, animation)
        else
            this.windbarbchart.addSeries({
                name: 'Wind direction ' + nameStation,
                id: seriesId,
                type: 'scatter',
                yAxis: 1,
                data: [[timestamp, getJSON.winddirection()]],
                visible: false,
                tooltip: {
                    pointFormatter: function () {
                        return WindConverter.prototype.fromDegToCompassDirection(this.y) + ' (' + this.y + '°)'
                    }
                }
            }, redraw, animation)

    }

    WeatherStation.prototype.onJSONSolarChart = function (station) {
        var getJSON = station.getJSON,
            timestamp = station.timestamp,
            redraw = false,
            shift = false,
            animation = this.options.animation,
            name = station.name,
            id = station.id,
            series,
            seriesId

        if (!this.solarchart)
            return

        seriesId = 'series-irradiance-' + id
        series = this.solarchart.get(seriesId)
        if (series)
            series.addPoint([timestamp, getJSON.solar_light()], redraw, shift, animation)
        else
            this.solarchart.addSeries({
                name: 'Sunlight ' + name,
                id: seriesId,
                type: 'spline',
                data: [[timestamp, getJSON.solar_light()]],
                tooltip: {
                    valueSuffix: ' watt/㎡'
                }
            }, redraw, animation)

        seriesId = 'series-uvi-' + id
        series = this.solarchart.get(seriesId)
        if (series)
            series.addPoint([timestamp, getJSON.solar_uvi()], redraw, shift, animation)
        else
            this.solarchart.addSeries({
                name: 'UVI ' + name,
                id: seriesId,
                type: 'areaspline',
                data: [[timestamp, getJSON.solar_uvi()]],
                zones: this.zones.uvi
            }, redraw, animation)

        /*         if (this.options.frostapi.enabled)
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
        }) */
    }

    WeatherStation.prototype.onJSONRainchart = function (station) {
        var getJSON = station.getJSON,
            timestamp = station.timestamp,
            redraw = false,
            shift = false,
            animation = this.options.animation,
            id = station.id,
            name = station.name,
            series,
            seriesId

        if (!this.rainchart)
            return

        seriesId = 'series-rainrate-' + id
        series = this.rainchart.get(seriesId)
        if (series)
            series.addPoint([timestamp, getJSON.rainrate()], redraw, shift, animation)
        else if (getJSON.rainrate() !== undefined)
            this.rainchart.addSeries({
                name: 'Rainrate ' + name,
                id: seriesId,
                type: 'spline',
                yAxis: 0,
                data: [[timestamp, getJSON.rainrate()]],
                //zones: this.zones.rainrate,
                tooltip: {
                    valueSuffix: ' mm/h'
                },
            }, redraw, animation)

        var rainevent = getJSON.rainevent()
        if (rainevent !== undefined) {
            seriesId = 'series-rainevent-' + id
            series = this.rainchart.get(seriesId)
            if (series)
                series.addPoint([timestamp, getJSON.rainevent()], redraw, shift, animation)
            else if (getJSON.rainevent() !== undefined)
                this.rainchart.addSeries({
                    name: 'Rainevent ' + name,
                    id: seriesId,
                    type: 'spline',
                    yAxis: 1,
                    visible: false,
                    data: [[timestamp, getJSON.rainevent()]],
                    tooltip: {
                        valueDecimals: 1,
                        valueSuffix: ' mm'
                    },
                }, redraw, animation)
        }

        seriesId = 'series-rainday-' + id
        series = this.rainchart.get(seriesId)
        if (series)
            series.addPoint([timestamp, getJSON.rainday()], redraw, shift, animation)
        else if (getJSON.rainday() !== undefined)
            this.rainchart.addSeries({
                name: 'Rainday ' + name,
                id: seriesId,
                type: 'spline',
                yAxis: 1,
                visible: false,
                data: [[timestamp, getJSON.rainday()]],
                tooltip: {
                    valueDecimals: 1,
                    valueSuffix: ' mm'
                },
            }, redraw, animation)
    }

    WeatherStation.prototype.onJSONRainstatChart = function (station) {
        var getJSON = station.getJSON,
            redraw = false,
            animation = this.options.animation,
            stationCategoryIndex = this.stations.indexOf(station),
            chart = this.rainstatchart

        if (!chart)
            return

        this.updateStationCategories(chart)

        var rainhour = getJSON.rainhour()
        if (rainhour !== undefined)
            chart.get('series-rainhour').options.data[stationCategoryIndex] = rainhour

        var rainevent = getJSON.rainevent()
        if (rainevent !== undefined)
            chart.get('series-rainevent').options.data[stationCategoryIndex] = rainevent

        chart.get('series-rainday').options.data[stationCategoryIndex] = getJSON.rainday()
        chart.get('series-rainweek').options.data[stationCategoryIndex] = getJSON.rainweek()
        chart.get('series-rainmonth').options.data[stationCategoryIndex] = getJSON.rainmonth()
        chart.get('series-rainyear').options.data[stationCategoryIndex] = getJSON.rainyear()

        chart.series.forEach(function (series) {
            series.setData(series.options.data, redraw, animation)
        })
    }

    WeatherStation.prototype.redrawCharts = function () {
        // https://api.highcharts.com/class-reference/Highcharts.Axis#setExtremes
        // y-axis start on 0 by default

        if (this.pressureChart && this.pressureChart.series[0]) {
            if (this.pressureChart.series[0].dataMin && this.pressureChart.series[0].dataMax)
                this.pressureChart.series[0].yAxis.setExtremes(this.pressureChart.series[0].dataMin - 2, this.pressureChart.series[0].dataMax + 2, false)
        }
        //console.log('redraw all charts')

        Highcharts.charts.forEach(function (chart) {
            chart.redraw()
        })
    }

    window.WeatherStation = WeatherStation

})() // Avoid intefering with global namespace https://developer.mozilla.org/en-US/docs/Glossary/IIFE