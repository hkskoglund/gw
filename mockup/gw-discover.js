// Taken from https://gist.github.com/sid24rane/6e6698e93360f2694e310dd347a2e2eb


var udp = require('dgram');
var ecowitt_port=59387;

// --------------------creating a udp server --------------------

// creating a udp server
var server = udp.createSocket('udp4');

// emits when any error occurs
server.on('error', (err) => {
  console.error('Error: ' + error);
  server.close();
});

// emits on new datagram msg
server.on('message', (msg,info) => {
    var d = Date.now();
    var mac=msg.toString('hex',5,11);
    var name=msg.toString('utf8',18,msg.length-1)
  console.log(d, msg,msg.toString('utf8',18,msg.length-1),'MAC: '+mac,info);
 // console.log('Received %d bytes from %s:%d\n',msg.length, info.address, info.port);

//         0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41
//
//<Buffer ff ff 12 00 27 48 3f da 55 4d a9 c0 a8 03 cc af c8 17 47 57 31 30 30 30 41 2d 57 49 46 49 34 44 41 39 20 56 31 2e 36 2e 38 09>
//                       | MAC            |           |CPORT|LL NAME 
//                                                              G  W  1  0  0  0  A  -  W  I  F  I  4  D  A  9     V  1  .  6  .  8
// CPORT = COMMAND port on gw? af c8 = 45000 dec.

//sending msg
//server.send(msg,info.port,'localhost',function(error){
//  if(error){
//    client.close();
//  }else{
//    console.log('Data sent !!!');
//  }

//});

});

//emits when socket is ready and listening for datagram msgs
server.on('listening',() => {
  var address = server.address();
  var port = address.port;
  var family = address.family;
  var ipaddr = address.address;
  console.log('Server is listening at port ' + port);
  console.log('Server ip :' + ipaddr);
  console.log('Server is IP4/IP6 : ' + family);
});

//emits after the socket is closed using socket.close();
//server.on('close',function(){
//  console.log('Socket is closed !');
//});

server.bind(ecowitt_port);

//setTimeout(function(){
//server.close();
//},3000);