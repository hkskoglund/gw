(function _WeatherStation() {
    
    function WeatherStation() {
        this.windrosechart=[]
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
          

            holfuyapi: {
                doc: 'http://api.holfuy.com/live/', // does not support CORS in Chrome/Edge (use curl on backend?), but works in Firefox 100.0.1
                stationId: '101', // Test
                stationName: 'test',
                interval: GetJSON.prototype.requestInterval.hour1,
                enabled: false,
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

        this.initStations()
        window.addEventListener('load',function _onload() { this.init() }.bind(this))
    }

    WeatherStation.prototype.init=function()
    {
        var port

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

        
        //this.options.maxPoints=Math.round(this.options.shifttime*60*1000/this.options.interval) // max number of points for requested shifttime
       
        this.initCharts()

        if (window.location.hostname === '127.0.0.1') // assume web server runs on port 80
            // Visual studio code live preview uses 127.0.0.1:3000
            port = 80
        else
            port = window.location.port

        
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
            //console.log('Updating plotbackground ' + id + ' url ' + url)
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

        //console.log('setting reload of ' + id + ' plotbackgroundimage ' + url + ' to ' + interval)

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
        //console.log('typeof Uint8Array: ' + typeof Uint8Array)

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
            window.addEventListener('DOMContentLoaded', function (event)  {
                 this.initWindroseChart(station)
            }.bind(this));
            station.getJSON.request.addEventListener("load", this.onJSONLivedata.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONLatestChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONTemperatureChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONWindbarbChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONWindroseChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONSolarChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONRainchart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONRainstatChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONPressureChart.bind(this, station)) 
            this.stations.push(station)

        } else if (station instanceof StationWU) {
            //console.log('StationWU', station)
           
            window.addEventListener('DOMContentLoaded', function (event)  {
                    this.initWindroseChart(station)
                                        }.bind(this));
            station.getJSON.request.addEventListener("load", this.onJSONLatestChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONTemperatureChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONWindbarbChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONWindroseChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONSolarChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONRainchart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONPressureChart.bind(this, station))
            this.stations.push(station)


        }  else if (station instanceof StationMETnoFrost) {
            //console.log('StationMETnoFrost', station)
       
            window.addEventListener('DOMContentLoaded', function (event)  {
                    this.initWindroseChart(station)
                                        }.bind(this));
            station.getJSON.request.addEventListener("load", this.onJSONLatestChart.bind(this, station)) 
            station.getJSON.request.addEventListener("load", this.onJSONTemperatureChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONWindbarbChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONWindroseChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONSolarChart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONRainchart.bind(this, station))
            station.getJSON.request.addEventListener("load", this.onJSONPressureChart.bind(this, station))
            this.stations.push(station)

        }
        
        else if (station instanceof StationYrForecastNow)
        {
            station.getJSON.request.addEventListener("load",this.onJSONYrForecastNow.bind(this,station))
            this.stationsYrForecastNow.push(station)
        }

    }

    WeatherStation.prototype.initStations = function (port) {

        this.stations= []
        this.stationsYrForecastNow=[]

         this.addStation(new StationGW('Tomasjord', 'ITOMAS1'))
         this.addStation(new StationMETnoFrost('MET Værvarslinga','SN90450'))
        this.addStation(new StationWU('Engenes', 'IENGEN26'))
        this.addStation(new StationMETnoFrost('MET Harstad Stadion','SN87640')) 
        this.addStation(new StationYrForecastNow('Tomasjord','radar-forecast-ITOMAS1','1-305426')) 
        this.addStation(new StationYrForecastNow('Engenes','radar-forecast-IENGEN26','1-290674'))
    
       /* if (this.options.holfuyapi.enabled)
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
                text: 'Temperature and Humidity'
            },
            yAxis: [{
                //https://api.highcharts.com/highcharts/yAxis.max
                title: {
                    text : 'Temperature ℃'
                },
                tickInterval: 1,
                opposite: false,
                gridLineWidth: this.options.weatherapi.geosatellite.enabled ? 0 : 1
                //max : null
                //max : 1.0
                //  max : 40
            },
            // humidity
            {
                title: {
                    text :'Humidity %'
                },
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
                text: 'Relative and Absolute Pressure'
            },
            yAxis: [{
                //https://api.highcharts.com/highcharts/yAxis.max
                title : {
                    text : 'Pressure hPa'
                },
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

    WeatherStation.prototype.onClickToggleChartSeries = function (pointerEvent)
    // Toggle display of series to reveal underlying image
    {
        var axis = pointerEvent.xAxis[0].axis,
            chart = axis.chart,
            id = chart.renderTo.id,
            restoreHiddenSeries = this.restoreHiddenSeries[id],
            hideDelay=0

        // console.log('click',event)

        if (!restoreHiddenSeries)
            restoreHiddenSeries = this.restoreHiddenSeries[id] = []

        if (restoreHiddenSeries && restoreHiddenSeries.length) {
            restoreHiddenSeries.forEach(function (series) { series.show() })
            this.restoreHiddenSeries[id] = []
        } else {

           chart.series.forEach(function (series) {

                if (series.visible) {
                    restoreHiddenSeries.push(series)
                    series.hide()
                }

            })

           chart.tooltip.hide(hideDelay) // tooltip for line series is not hidden when series is hidden
           if (axis.cross)
             axis.cross.hide() // not hidden when tooltip is hidden

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
                    id: 'xaxis-station',
                    type: 'column',
                    categories: []
                }, {
                    type: 'datetime',
                    id: 'xaxis-datetime'
                }],

                tooltip: {
                    enabled: true
                },

                plotOptions : {
                    series : {
                        tooltip: {
                            valueDecimals: 1
                        }
                    }
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
                        yAxis : 0,
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
                            enabled: true && !this.options.isLGSmartTV2012,
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
                        name: 'Irradiance',
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
                    }
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
                   id : 'yaxis-rainrate',
                    min: 0,
                    title: false,
                    opposite: false
                }, {
                    title : {
                        text : 'Rain mm'
                    },
                    id: 'yaxis-rain',
                    min: 0,
                    opposite: true,
                }],
                xAxis: [{
                    id: 'xaxis-station',
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
                text: 'Irradiance and UVI'
            },
            yAxis: [{
                //https://api.highcharts.com/highcharts/yAxis.max
                title: {
                    text : 'Irradiance W/㎡'
                },
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
                title: {
                    text: 'Ultra Violet Index - UVI'
                },
                min: 0,
                tickInterval: 1,
                allowDecimals: false,
               opposite: true,
                id: 'yaxis-uvi',
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
                title: {
                    text : 'Speed m/s'
                },
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
                    enableMouseTracking: this.options.mousetracking,
                    dataGrouping: {
                        groupPixelWidth: 30
                    },
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
        var redraw = true,
            animation = this.options.animation,
            updatePoints = true,
            id = station.id,
            seriesId,
            series,
            data=station.yrForecastnowPoints,
            points=station.points,
            yAxisRainrate,
            hasPrecipitation,
            tooltipRainrateOptions={
                valueDecimals: 1,
                valueSuffix: ' mm/h'
            }

        if (this.rainchart) {
        
            seriesId='series-rainrate-yrforecastnow-'+id
            series = this.rainchart.get(seriesId)
            if (series)
                series.setData(data, redraw, animation, updatePoints)
            else
                this.rainchart.addSeries({
                    name: 'Yr radar '+station.name,
                    id: seriesId,
                    type: 'spline',
                    yAxis: this.rainchart.yAxis.indexOf(this.rainchart.get('yaxis-rainrate')),
                    data: data,
                    tooltip: tooltipRainrateOptions,
                // zones: this.zones.rainrate_yr
                }, redraw, animation)
        }

        if (!this.latestChart)
          return

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
                name: 'Yr radar '+station.name,
                id: seriesId,
                type: 'spline',
                xAxis: this.latestChart.xAxis.indexOf(this.latestChart.get('xaxis-datetime')),
                yAxis: this.latestChart.yAxis.indexOf(this.latestChart.get('yaxis-rainrate')),
                // opacity: 0.5,
                // zIndex: 10,
                data: points,
                //zones: this.zones.rainrate_yr,
                tooltip: tooltipRainrateOptions
            }, redraw, animation)
    }

    WeatherStation.prototype.onJSONLivedata = function (station, ev) {
        var jsonReq = station.getJSON
        // Show when data is available
        // if (this.weatherElement.style.display==="none")
        //   this.weatherElement.style.display="block"

        this.outtempElement.textContent = jsonReq.outtemp().value
        this.intempElement.textContent = jsonReq.intemp().value
        this.unitTempElement.textContent = jsonReq.unitTemp()

        this.windspeedElement.textContent = jsonReq.windspeed().value
        this.windgustspeedElement.textContent = jsonReq.windgustspeed().value
        this.winddirection_compassElement.textContent = jsonReq.winddirection_compass().value
        this.windgustspeed_beufort_descriptionElement.textContent = jsonReq.windgustbeufort_description().value
        this.unitWindElement.textContent = jsonReq.unitWind()
        this.meter_windgustspeedElement.value = jsonReq.windgustspeed().value

        this.relbaroElement.textContent = jsonReq.relbaro().value
        this.absbaroElement.textContent = jsonReq.absbaro().value
        this.unitpressureElement.textContent = jsonReq.unitPressure()

        this.solar_lightElement.textContent = jsonReq.solar_light().value
        this.unit_solar_lightElement.textContent = jsonReq.unitSolarlight()
        this.solar_uvElement.textContent = jsonReq.solar_uv().value
        this.unit_solar_uvElement.textContent = jsonReq.unitSolarUV()
        this.solar_uviElement.textContent = jsonReq.solar_uvi().value

    }

    WeatherStation.prototype.updateStationCategories = function (chart) {
        var redraw = false,
            stationNames,
            stationAxis=chart.get('xaxis-station')
           
        if (!chart)
            return

        stationNames = this.stations.map(function (station) {
                                            if (station.getJSON.request.readyState !== XMLHttpRequest.DONE)
                                                return station.name
                                            else 
                                                return station.name + ' ' + DateUtil.prototype.getHHMMSS(new Date(station.getJSON.timestamp_utc))
                                            })

        stationAxis.setCategories(stationNames, redraw)
    }

    WeatherStation.prototype.onJSONLatestChart = function (station) {
        var getJSON = station.getJSON,
            redraw = false,
            animation = this.options.animation,
            stationCategoryIndex = this.stations.indexOf(station),
            chart = this.latestChart,
            temperatureSeries

        if (!chart)
            return

        this.updateStationCategories(chart)

        temperatureSeries=chart.get('series-temperature')
        temperatureSeries.options.data[stationCategoryIndex] = getJSON.outtemp().value
       
        var windchill = getJSON.windchill().value // available in WU
        if (windchill !== undefined)
            chart.get('series-windchill').options.data[stationCategoryIndex] = windchill

        //chart.series[0].options.data[1]=getJSON.intemp()
        chart.get('series-humidity').options.data[stationCategoryIndex] = getJSON.outhumidity().value
        //chart.series[1].options.data[1]=getJSON.inhumidity()
        chart.get('series-windspeed').options.data[stationCategoryIndex] = getJSON.windspeed_mps().value
        chart.get('series-windgust').options.data[stationCategoryIndex] = getJSON.windgustspeed_mps().value
        chart.get('series-winddirection').options.data[stationCategoryIndex] = getJSON.winddirection().value
        chart.get('series-relbaro').options.data[stationCategoryIndex] = getJSON.relbaro().value
        chart.get('series-irradiance').options.data[stationCategoryIndex] = getJSON.solar_light().value
        chart.get('series-UVI').options.data[stationCategoryIndex] = getJSON.solar_uvi().value
        chart.get('series-rainrate').options.data[stationCategoryIndex] = getJSON.rainrate().value
        chart.get('series-raintoday').options.data[stationCategoryIndex] = getJSON.rainday().value

        chart.series.forEach(function (series) {
            for (var i = 0; i < series.options.data.length; i++) // make sure we have null data for stations thats not received JSON data yet
                if (series.options.data[i] === undefined)
                    series.options.data[i] = null
            // console.log('setData',series.name,series.options.data)
            series.setData(series.options.data, redraw, animation)
        })

        chart.redraw()

       // temperatureSeries.data[0].onMouseOver()

    }

    WeatherStation.prototype.onJSONWindroseChart = function (station) {
        var getJSON = station.getJSON,
            redraw = false,
            animation = this.options.animation,
            updatePoints = true,
            stationCategoryIndex = this.stations.indexOf(station),
            percentArr,
            beufortScale,
            totalMeasurements = station.getJSON.statistics.measurements,
            windrosedata = station.windrosedata,
            chart=this.windrosechart[stationCategoryIndex]

        if (stationCategoryIndex === -1) {
            console.error('Station not found for windrose')
            return
        }

        beufortScale = getJSON.windgustspeed_beufort().value
        var windDirection = getJSON.winddirection_compass_value().value - 1
        windrosedata[beufortScale][windDirection] = windrosedata[beufortScale][windDirection] + 1
       // console.log('windrosedata ' + station.name + ' beufortscale: ' + beufortScale, windrosedata[beufortScale])

        for (beufortScale = 0; beufortScale < 12; beufortScale++) {
            percentArr = []
            windrosedata[beufortScale].forEach(function (measurement) {
                percentArr.push(measurement / totalMeasurements * 100)
            })
            //console.log('percentarray',percentArr)
            chart.series[beufortScale].setData(percentArr, redraw, animation, updatePoints)
        }

        chart.redraw()
    }

    WeatherStation.prototype.onJSONTemperatureChart = function (station) {
        var getJSON = station.getJSON,
            id = station.id,
            name = station.name,
            point,
            chart=this.temperatureChart,
            seriesId

        if (!chart)
            return

        seriesId = 'series-outdoor-temperature-' + id
        point=getJSON.outtemp()

        this.addPoint(chart,seriesId,[point.timestamp,point.value], {
                name: 'Outdoor ' + name,
                type: 'spline',
                yAxis: 0,
                zIndex: 5,
                visible : !(station instanceof StationMETnoFrost)
            })

        seriesId = 'series-outdoor-humidity-' + id
        point=getJSON.outhumidity()

        this.addPoint(chart,seriesId,[point.timestamp, point.value],{
                name: 'Outdoor humidity ' + name,
                type: 'spline',
                yAxis: 1,
                tooltip: {
                    valueSuffix: ' %'
                },
                zIndex: 5,
                visible: false
            })

        point=getJSON.intemp()
        seriesId = 'series-indoor-temperature-' + id

        this.addPoint(chart,seriesId,[point.timestamp, point.value], {
                name: 'Indoor ' + name,
                type: 'spline',
                yAxis: 0,
                zIndex: 5,
                visible: false
            })

        point = getJSON.inhumidity()
        seriesId = 'series-indoor-humidity-' + id

        this.addPoint(chart,seriesId,[point.timestamp, point.value],{
                name: 'Indoor humidity ' + name,
                type: 'spline',
                yAxis: 1,
                tooltip: {
                    valueSuffix: ' %'
                },
                zIndex: 5,
                visible: false
            })

        chart.redraw()
    }

    WeatherStation.prototype.onJSONPressureChart = function (station) {
        var getJSON = station.getJSON,
            id = station.id,
            name = station.name,
            chart=this.pressureChart,
            point

        if (!chart)
            return

       seriesId='series-relbaro-' + id
       point=getJSON.relbaro()
       this.addPoint(chart,seriesId,[point.timestamp, point.value], {
                name: 'Relative ' + name,
                type: 'spline',
                visible : !(station instanceof StationMETnoFrost)
            })

        // optional
        point = getJSON.absbaro()
        if (point.value !== undefined) {
            seriesId = 'series-absbaro-' + id
            this.addPoint(chart,seriesId,[point.timestamp, point.value], {
                    name: 'Absolute ' + name,
                    type: 'spline',
                    visible: false
                })
        }

      /*  if (chart.series[0]) {
            if (this.pressureChart.series[0].dataMin && this.pressureChart.series[0].dataMax)
                this.pressureChart.series[0].yAxis.setExtremes(this.pressureChart.series[0].dataMin - 2, this.pressureChart.series[0].dataMax + 2, false)
        } */

        chart.redraw()

    }

    WeatherStation.prototype.addPoint=function(chart,seriesId,point,seriesOptions)
    {
        var series,
            redraw=false,
            shift=false,
            animation=this.options.animation,
            value=point[1],
            timestamp=point[0]

        // validate

        if (timestamp=== undefined || timestamp === null || value===undefined)
        {
            //console.warn('Skipping addPoint for '+seriesId+ ' invalid value or timestamp')
            return
        }

        series = chart.get(seriesId)
        if (series)
          series.addPoint(point,redraw,shift,animation)
        else
         {
           seriesOptions.id=seriesId
           seriesOptions.data=[point]
           chart.addSeries(seriesOptions,redraw,animation)
         }
    }

    WeatherStation.prototype.onJSONWindbarbChart = function (station) {
        var getJSON = station.getJSON,
            seriesId,
            id = station.id,
            name = station.name,
            point,
            chart=this.windbarbchart,
            tooltipWindoptions={
                valueSuffix: ' m/s',
                valueDecimals: 1
            },
            seriesName

        if (!this.windbarbchart)
            return

        point=[getJSON.windgustspeed_mps(),getJSON.winddirection()]
        seriesId='series-windbarb-'+id

        this.addPoint(chart,seriesId,[point[0].timestamp, point[0].value, point[1].value],{
            name: 'Windbarb ' + name,
            type: 'windbarb',
            showInLegend: true,
            visible: false
        })

        point=getJSON.windspeed_mps()
        seriesId='series-wind-' + id
       
        this.addPoint(chart,seriesId,[point.timestamp, point.value],{
            name: 'Wind speed ' + name,
            type: 'spline',
            tooltip: tooltipWindoptions,
            visible : !(station instanceof StationMETnoFrost)
        })
        
        point=getJSON.windgustspeed_mps()
        seriesId='series-windgust-' + id
        if (point.id)
          seriesName=point.id+' '+name
        else
          seriesName='Wind gust '+name
        
        this.addPoint(chart,seriesId,[point.timestamp, point.value],{
            name: seriesName,
            type: 'spline',
            tooltip: tooltipWindoptions,
            visible : !(station instanceof StationMETnoFrost)
        })
        
        point=getJSON.winddirection()
        seriesId = 'series-winddirection-' + id

        this.addPoint(chart,seriesId,[point.timestamp, point.value],{
            name: 'Wind direction ' + name,
            type: 'scatter',
            yAxis: 1,
            visible: false,
            tooltip: {
                pointFormatter: function () {
                    return WindConverter.prototype.fromDegToCompassDirection(this.y) + ' (' + this.y + '°)'
                }
            } 
        })

        chart.redraw()

    }

    WeatherStation.prototype.onJSONSolarChart = function (station) {
        var getJSON = station.getJSON,
            redraw = false,
            animation = this.options.animation,
            name = station.name,
            id = station.id,
            seriesId,
            point,
            chart=this.solarchart,
            seriesName

        if (!chart)
            return

        seriesId = 'series-irradiance-' + id
        point=getJSON.solar_light()
        if (point.id)
          seriesName=point.id+' '+name
        else
          seriesName='Irradiance ' + name

        this.addPoint(chart,seriesId,[point.timestamp,point.value],{
                name: seriesName,
                type: 'spline',
                tooltip: {
                    valueSuffix: ' watt/㎡'
                },
                visible : !(station instanceof StationMETnoFrost)
            }, redraw, animation)

        seriesId = 'series-uvi-' + id
        point=getJSON.solar_uvi()

       this.addPoint(chart,seriesId,[point.timestamp,point.value],{
                name: 'UVI ' + name,
                yAxis : chart.yAxis.indexOf(chart.get('yaxis-uvi')),
                type: 'areaspline',
                opacity: 0.5,
                zones: this.zones.uvi,
                visible : !(station instanceof StationMETnoFrost)
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

        chart.redraw()
    }

    WeatherStation.prototype.onJSONRainchart = function (station) {
        var getJSON = station.getJSON,
            id = station.id,
            name = station.name,
            seriesId,
            point,
            chart=this.rainchart

        if (!chart)
            return

        point=getJSON.rainrate()
        seriesId = 'series-rainrate-' + id
           this.addPoint(chart,seriesId,[point.timestamp, point.value],{
                name: 'Rainrate ' + name,
                type: 'spline',
                yAxis: 0,
                //zones: this.zones.rainrate,
                tooltip: {
                    valueSuffix: ' mm/h'
                },
                visible : !(station instanceof StationMETnoFrost)
            })

        point = getJSON.rainevent()
            seriesId = 'series-rainevent-' + id
            this.addPoint(chart,seriesId,[point.timestamp, point.value],{
                    name: 'Rainevent ' + name,
                    type: 'spline',
                    yAxis: 1,
                    visible: false,
                    tooltip: {
                        valueDecimals: 1,
                        valueSuffix: ' mm'
                    },
                })
        
        point=getJSON.rainday()
        seriesId = 'series-rainday-' + id
        this.addPoint(chart,seriesId,[point.timestamp, point.value], {
                name: 'Rainday ' + name,
                type: 'spline',
                yAxis: 1,
                visible: false,
                tooltip: {
                    valueDecimals: 1,
                    valueSuffix: ' mm'
                },
            })

        chart.redraw()
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

        var rainhour = getJSON.rainhour().value
        if (rainhour !== undefined)
            chart.get('series-rainhour').options.data[stationCategoryIndex] = rainhour

        var rainevent = getJSON.rainevent().value
        if (rainevent !== undefined)
            chart.get('series-rainevent').options.data[stationCategoryIndex] = rainevent

        chart.get('series-rainday').options.data[stationCategoryIndex] = getJSON.rainday().value
        chart.get('series-rainweek').options.data[stationCategoryIndex] = getJSON.rainweek().value
        chart.get('series-rainmonth').options.data[stationCategoryIndex] = getJSON.rainmonth().value
        chart.get('series-rainyear').options.data[stationCategoryIndex] = getJSON.rainyear().value

        chart.series.forEach(function (series) {
            series.setData(series.options.data, redraw, animation)
        })

        chart.redraw()
    }

    window.WeatherStation = new WeatherStation()

})() // Avoid intefering with global namespace https://developer.mozilla.org/en-US/docs/Glossary/IIFE