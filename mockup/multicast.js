// From https://stackoverflow.com/questions/14130560/nodejs-udp-multicast-how-to

//Multicast Server sending messages
var news = [
    "Borussia Dortmund wins German championship",
    "Tornado warning for the Bay Area",
    "More rain for the weekend",
    "Android tablets take over the world",
    "iPad2 sold out",
    "Nation's rappers down to last two samples"
 ];
 
 var PORT = 43848;
 var MCAST_ADDR = "224.0.0.251"; //not your IP and should be a Class D address, see http://www.iana.org/assignments/multicast-addresses/multicast-addresses.xhtml
 import dgram from 'dgram'; 
 var server = dgram.createSocket("udp4"); 
 server.bind(PORT, function(){
     server.setBroadcast(true);
     server.setMulticastTTL(128);
     //server.addMembership(MCAST_ADDR);
 });
 
 setInterval(broadcastNew, 3000);
 
 function broadcastNew() {
     var message = Buffer.from(news[Math.floor(Math.random()*news.length)]);
     server.send(message, 0, message.length, PORT,MCAST_ADDR);
     console.log("Sent " + message + " to the wire...");
 }


 //Multicast Client receiving sent messages

var HOST = '10.42.0.1'; //this is your own IP
var client = dgram.createSocket('udp4');
var CPORT = 41848

client.on('listening', function () {
    var address = client.address();
    console.log('UDP Client listening on ' + address.address + ":" + address.port);
    client.setBroadcast(true)
    client.setMulticastTTL(128); 
    //client.addMembership(MCAST_ADDR);
});

client.on('message', function (message, remote) {   
    console.log('MCast Msg: From: ' + remote.address + ':' + remote.port +' - ' + message);
});

client.bind(CPORT, HOST);