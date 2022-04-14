
// by default functions are added to window object

function GetJSON(host,port,path) {
// https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest
// https://stackoverflow.com/questions/1973140/parsing-json-from-xmlhttprequest-responsejson
// https://developer.mozilla.org/en-US/docs/Web/API/setInterval
    this.host=host
    this.port=port
    this.path=path
    this.setUrl(host,port,path)

    this.req=new XMLHttpRequest()
    
    this.req.addEventListener("load", this.transferComplete.bind(this))
    this.req.addEventListener("error", this.transferError.bind(this))
    this.req.addEventListener("onabort",this.transferAbort.bind(this))

    this.requestLivedata()
    this.intervalID=setInterval(this.requestLivedata.bind(this),16000)
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

function GetEcowittJSON(host,port,path)
{
    GetJSON.call(this,host,port,path)
}

GetEcowittJSON.prototype= Object.create(GetJSON.prototype)
GetEcowittJSON.prototype.getOuttemp=function()
{
    return this.json.outdoor.temperature.value
}


function UI(server,port,path)
{
    this.server=document.getElementById('inputServer')
    this.port=document.getElementById('inputPort')
    this.path=document.getElementById('inputPath')
    this.btnChangeServer=document.getElementById('btnChangeServer')
    this.server.value=server
    this.port.value=port
    this.path.value=path

    this.getJSON=new GetEcowittJSON(server,port,path)
    this.getJSON.req.addEventListener("load",this.onJSON.bind(this))
    this.btnChangeServer.addEventListener('click',this.onChangeServer.bind(this))
}

UI.prototype.onChangeServer = function(ev)
{
    console.log('changing server to '+this.server.value+':'+this.port.value+this.path.value,this)
    this.getJSON.req.abort()
    this.getJSON.setUrl(this.server.value,this.port.value,this.path.value)
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

var ui = new UI("192.168.3.3",8000,'/livedata')








