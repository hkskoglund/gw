
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
    }
    
    this.interval=interval
    this.setUrl(host,port,path)

    this.req=new XMLHttpRequest()
    
    this.req.addEventListener("load", this.transferComplete.bind(this))
    this.req.addEventListener("error", this.transferError.bind(this))
    this.req.addEventListener("onabort",this.transferAbort.bind(this))
    this.setInterval(this.interval)
  
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
}


GetJSON.prototype.getOuttemp=function()
{
    return null
}

GetJSON.prototype.transferComplete=function(evt)
{
    if (this.req.responseText.length > 0) {
        console.log('json:'+this.req.responseText)
        this.json = JSON.parse(this.req.responseText)
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
    //this.req=new XMLHttpRequest()
    //req.overrideMimeType('')
    //req.overrideMimeType("application/json")
    //this.req.setRequestHeader("Accept","application/json")
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
    this.server=document.getElementById('inputServer')
    this.port=document.getElementById('inputPort')
    this.path=document.getElementById('inputPath')
    this.interval=document.getElementById('inputInterval')
    this.btnChangeServer=document.getElementById('btnChangeServer')
    this.server.value=server
    this.port.value=port
    this.path.value=path
    this.interval.value=interval

    this.getJSON=new GetEcowittJSON(server,port,path,interval)
    this.getJSON.req.addEventListener("load",this.onJSON.bind(this))
    this.btnChangeServer.addEventListener('click',this.onChangeServer.bind(this))
}

UI.prototype.onChangeServer = function(ev)
{
    // Validation
    
    var port=parseInt(this.port.value)
    var interval=parseInt(this.interval.value)

    if (isNaN(port)) {
        this.port.value=this.getJSON.port
        console.error('port is not a number:'+this.port.value)
        return
    }

    if (port < 0 ) {
        this.port.value=this.getJSON.port
        console.error('port negative:'+this.port.value)
        return
    }

    if (interval < 500) {
        this.interval.value=this.getJSON.interval
        console.error('interval less than 500ms:'+this.interval.value)
        return
    }

    if (isNaN(interval))
    {
        this.interval.value=this.getJSON.interval
        console.error('interval is not a number:'+this.interval.value)
        return
    }

    this.port.value=port
    this.interval.value=interval

    console.log('changing server to '+this.server.value+':'+this.port.value+this.path.value,this)
    this.getJSON.req.abort()
    this.getJSON.setUrl(this.server.value,port,this.path.value)
    this.getJSON.setInterval(interval)
}

UI.prototype.onJSON=function (ev)
{
    document.getElementById('outtemp').innerHTML=this.getJSON.getOuttemp()
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

var ui = new UI("192.168.3.3",8000,'/livedata',16000)








