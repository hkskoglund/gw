
// by default functions are added to window object

function newUrl(host,port)
{ 
    return 'http://'+host+':'+port+'/livedata'
}

function transferComplete(evt)
{
    var json = JSON.parse(this.responseText)
    console.log(json)
    document.getElementById('outtemp').innerHTML=json.outdoor.temperature.value
}

function transferError(evt)
{
    console.error('Failed to receive json for '+url,evt);
}

function requestLivedata()
{
    var req=new XMLHttpRequest()
    //req.overrideMimeType('')
    req.open('GET',url)
    //req.overrideMimeType("application/json")
    req.setRequestHeader("Accept","application/json")
    req.addEventListener("load", transferComplete)
    req.addEventListener("error", transferError)
    
    req.send()
}

var url = newUrl('192.168.3.174',8000)

// https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest
// https://stackoverflow.com/questions/1973140/parsing-json-from-xmlhttprequest-responsejson
// https://developer.mozilla.org/en-US/docs/Web/API/setInterval
requestLivedata()
var intervalID=setInterval(requestLivedata,16000)
