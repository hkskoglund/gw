
// by default functions are added to window object

function GetJSON(host,port,path) {
// https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest
// https://stackoverflow.com/questions/1973140/parsing-json-from-xmlhttprequest-responsejson
// https://developer.mozilla.org/en-US/docs/Web/API/setInterval
    this.host=host
    this.port=port
    this.path=path
    this.url=this.newUrl(host,port,path)
    this.requestLivedata()
    this.intervalID=setInterval(this.requestLivedata.bind(this),16000)
  }

GetJSON.prototype.newUrl=function(host,port,path)
{ 
    return 'http://'+host+':'+port+path
}

GetJSON.prototype.updateUI=function()
{
    document.getElementById('outtemp').innerHTML=this.getOuttemp()
}

GetJSON.prototype.getOuttemp=function()
{
    return null
}

GetJSON.prototype.transferComplete=function(evt)
{
    console.log('json:'+this.req.responseText)
    this.json = JSON.parse(this.req.responseText)
    this.updateUI()
}

GetJSON.prototype.transferError=function(evt)
{
    console.error('Failed to receive json for '+this.url,evt);
}

GetJSON.prototype.requestLivedata=function()
{
    this.req=new XMLHttpRequest()
    //req.overrideMimeType('')
     this.req.open('GET',this.url)
    //req.overrideMimeType("application/json")
    this.req.setRequestHeader("Accept","application/json")

    this.req.addEventListener("load", this.transferComplete.bind(this))
    this.req.addEventListener("error", this.transferError.bind(this))

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

var getJSON=new GetEcowittJSON('192.168.3.3',8000,'/livedata')



