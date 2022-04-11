function hello()
{
    console.log('hello')
}

//hello()

//document.getElementById('intemp').innerHTML='22.4'

// https://stackoverflow.com/questions/1973140/parsing-json-from-xmlhttprequest-responsejson
var req=new XMLHttpRequest()
//req.overrideMimeType('')
req.open('GET','http://localhost:8000/livedata')
//req.overrideMimeType("application/json")
req.setRequestHeader("Accept","application/json")
req.onload = function ()
{
    var json = JSON.parse(this.responseText)
    console.log(json)
    document.getElementById('intemp').innerHTML=json.intemp
}
req.send()


