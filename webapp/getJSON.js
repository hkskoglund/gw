
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


function UI(server,port,path,interval)
{
    this.serverElement=document.getElementById('inputServer')
    this.serverElement.addEventListener('change',this.onChangeServer.bind(this))

    this.portElement=document.getElementById('inputPort')
    this.portElement.addEventListener('change',this.onChangePort.bind(this))

    this.pathElement=document.getElementById('inputPath')
    this.portElement.addEventListener('change',this.onChangePath.bind(this))

    this.intervalElement=document.getElementById('inputInterval')
    this.intervalElement.addEventListener('change',this.onChangeInterval.bind(this))

    this.outtempElement=document.getElementById('outtemp')

    this.btnOK=document.getElementById('btnOK')

    // init ui
    this.serverElement.value=localStorage.getItem('server') || server
    this.portElement.value=localStorage.getItem('port') || port
    this.pathElement.value=localStorage.getItem('path') || path
    this.intervalElement.value=localStorage.getItem('interval') || interval

    this.getJSON=new GetEcowittJSON(this.serverElement.value,this.portElement.value,this.pathElement.value,this.intervalElement.value)
    this.getJSON.req.addEventListener("load",this.onJSON.bind(this))
    this.btnOK.addEventListener('click',this.onClickOK.bind(this))
}

UI.prototype.onInputServer = function(ev)
{
    console.log('oninput',ev)
}

UI.prototype.onChangeServer = function(ev)
{
    console.log('onchangeServer',ev)
    localStorage.setItem('server',this.serverElement.value)
}

UI.prototype.onChangePort = function(ev)
{

    var port=parseInt(this.portElement.value)

    console.log('onchangePort',ev)

    if (isNaN(port)) {
        this.port.value=this.getJSON.port
        console.error('port is not a number:'+this.portElement.value)
        return
    }

    if (port < 1024 || port > 65535) {
        this.portElement.value=this.getJSON.port
        console.error('port outside bounds 1024-65535:'+this.portElement.value)
        return
    }

    localStorage.setItem('port',this.portElement.value)
}

UI.prototype.onChangePath = function(ev)
{
    console.log('onchangePath',ev)
    localStorage.setItem('path',this.pathElement.value)
}

UI.prototype.onChangeInterval = function(ev)
{
    console.log('onchangeInterval',ev)
    
    var interval=parseInt(this.intervalElement.value)

    if (interval < 500) {
        this.intervalElement.value=this.getJSON.interval
        console.error('interval less than 500ms:'+this.intervalElement.value)
        return
    }

    if (isNaN(interval))
    {
        this.interval.value=this.getJSON.interval
        console.error('interval is not a number:'+this.intervalElement.value)
        return
    }

    localStorage.setItem('interval',this.intervalElement.value)
}


UI.prototype.onClickOK = function(ev)
{

    console.log('changing server to '+this.serverElement.value+':'+this.portElement.value+this.pathElement.value,this)
    this.getJSON.req.abort()
    this.getJSON.setUrl(this.serverElement.value,this.portElement.value,this.pathElement.value)
    this.getJSON.setInterval(this.intervalElement.value)
}

UI.prototype.onJSON=function (ev)
{
    this.outtempElement.textContent=this.getJSON.getOuttemp()
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








