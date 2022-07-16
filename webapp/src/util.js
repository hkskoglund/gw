// https://stackoverflow.com/questions/15455009/javascript-call-apply-vs-bind
    if (!Function.prototype.bind) {
        console.log('javascript bind not found, creating new Function.prototype.bind,' + window.navigator.userAgent)
        Function.prototype.bind = function (ctx) {
            var fn = this,
                args = Array.prototype.slice.call(arguments, 1) // Shallow copy - points to same memory - arguments when creating function with .bind(this,...)
            return function () {
                //https://gist.github.com/MiguelCastillo/38005792d33373f4d08c
                return fn.apply(ctx, args.concat(Array.prototype.slice.call(arguments))); // conact to append arguments when calling
            };
        };
    }

    /*function alert()
        {
            return
        } */

    Number.isInteger = Number.isInteger || function (value) {
        return typeof value === 'number' && isFinite(value) && Math.floor(value) === value;
    };

function WindConverter() {
}

WindConverter.prototype.fromDegToCompassDirection = function (deg) {
    // https://www.campbellsci.com/blog/convert-wind-directions
    var direction = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW", "N"]

    return direction[Math.round((deg % 360) / 22.5)]
}

WindConverter.prototype.fromKmhToMps = function (kmh) {
    return kmh * 5 / 18
}

WindConverter.prototype.getBeufort = function (mps) {
    if (mps < 0.5)
        return 0
    else if (mps < 1.6)
        return 1
    else if (mps < 3.4)
        return 2
    else if (mps < 5.5)
        return 3
    else if (mps < 8.0)
        return 4
    else if (mps < 10.8)
        return 5
    else if (mps < 13.9)
        return 6
    else if (mps < 17.2)
        return 7
    else if (mps < 20.8)
        return 8
    else if (mps < 24.5)
        return 9
    else if (mps < 28.5)
        return 10
    else if (mps < 32.7)
        return 11
    else
        return 12
}

WindConverter.prototype.getCompassDirectionValue = function (deg) {
    if (deg < 11 || deg > 349)
        return WindConverter.prototype.WIND_N
    else if (deg > 11 && deg < 34)
        return WindConverter.prototype.WIND_NNE
    else if (deg > 34 && deg < 56)
        return WindConverter.prototype.WIND_NE
    else if (deg > 56 && deg < 79)
        return WindConverter.prototype.WIND_ENE
    else if (deg > 79 && deg < 101)
        return WindConverter.prototype.WIND_E
    else if (deg > 101 && deg < 124)
        return WindConverter.prototype.WIND_ESE
    else if (deg > 124 && deg < 146)
        return WindConverter.prototype.WIND_SE
    else if (deg > 146 && deg < 169)
        return WindConverter.prototype.WIND_SSE
    else if (deg > 169 && deg < 191)
        return WindConverter.prototype.WIND_S
    else if (deg > 191 && deg < 214)
        return WindConverter.prototype.WIND_SSW
    else if (deg > 214 && deg < 236)
        return WindConverter.prototype.WIND_SW
    else if (deg > 236 && deg < 259)
        return WindConverter.prototype.WIND_WSW
    else if (deg > 259 && deg < 281)
        return WindConverter.prototype.WIND_W
    else if (deg > 281 && deg < 304)
        return WindConverter.prototype.WIND_WNW
    else if (deg > 304 && deg < 326)
        return WindConverter.prototype.WIND_NW
    else if (deg > 326 && deg < 349)
        return WindConverter.prototype.WIND_NNW
}

WindConverter.prototype.WIND_N = 1
WindConverter.prototype.WIND_NNE = 2
WindConverter.prototype.WIND_NE = 3
WindConverter.prototype.WIND_ENE = 4
WindConverter.prototype.WIND_E = 5
WindConverter.prototype.WIND_ESE = 6
WindConverter.prototype.WIND_SE = 7
WindConverter.prototype.WIND_SSE = 8
WindConverter.prototype.WIND_S = 9
WindConverter.prototype.WIND_SSW = 10
WindConverter.prototype.WIND_SW = 11
WindConverter.prototype.WIND_WSW = 12
WindConverter.prototype.WIND_W = 13
WindConverter.prototype.WIND_WNW = 14
WindConverter.prototype.WIND_NW = 15
WindConverter.prototype.WIND_NNW = 16

function DateUtil() {
}

DateUtil.prototype.getHHMMSS = function (date) {

    return ('0' + date.getHours()).slice(-2) + ':' + ('0' + date.getMinutes()).slice(-2) + ':' + ('0' + date.getSeconds()).slice(-2) // https://stackoverflow.com/questions/1267283/how-can-i-pad-a-value-with-leading-zeros  
}