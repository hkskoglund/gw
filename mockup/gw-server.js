// sudo firewall-cmd --list-ports --zone=FedoraWorkstation
// 1025-65535/tcp 1025-65535/udp
// sudo firewall-cmd --get-active-zones
//sudo firewall-cmd --change-interface=wlp7s0 --zone=FedoraWorkstation

// For wireless hotspot in fedora, zone nm-shared have closed ports
// sudo firewall-cmd  --add-port 1024-65535/tcp --add-port 1024-65535/udp --zone=nm-shared
// sudo firewall-cmd --runtime-to-permanent
// Based on https://nodejs.org/en/docs/guides/anatomy-of-an-http-transaction/

const http = require('http');
const port = 8000;
const { URLSearchParams } = require('url');

http.createServer((request, response) => {
    
  const { headers, method, url } = request;
  console.log(Date.now(),headers,method,url);
  let body = [];
  request.on('error', (err) => {
    console.error(err);
  }).on('data', (chunk) => {
    body.push(chunk);
    
  }).on('end', () => {
    body = Buffer.concat(body).toString();
    // https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams#examples
    var tempParams = new URLSearchParams(body);
    tempParams.delete("PASSKEY"); // hide
    console.log(Date.now(),tempParams.toString());
    // At this point, we have the headers, method, url and body, and can now
    // do whatever we need to in order to respond to this request.
    response.writeHead(200);
    response.end();
  });
}).listen(port); // Activates this server, listening on port.



// COMMANDS TO GW
//  ffff27032a - wireshark log

// CMD_GW1000_LIVEDATA = 39 (0x27 = 39)
// ./WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/p010GW/GetRecvData_GW.java

//  sources/com/ost/newnettool/p010GW/TcpsockGw.java
// l. 238 ReadGW1000_LIVEDATA()
// l. 822 Read_data-GWfunc(i)

//public byte[] Read_data_GWfunc(int i) {
//  byte[] bArr = new byte[5];
//  bArr[0] = -1;
//  bArr[1] = -1;
//  bArr[2] = (byte) i;
//  bArr[3] = 3;
//  bArr[4] = (byte) this.f887sf.checksum(bArr, 5);
//  return tcp_send_data(bArr, 5, true);
// }

// sources/com/ost/newnettool/WH2350ALL/ShareFunc.java


// l. 369 public int checksum(byte[] bArr, int i) {
//        byte b = 0;
//        for (int i2 = 2; i2 < i; i2++) {
//            b = (byte) (b + (bArr[i2] & 255));
//        }
//        return b;
//    }





// WSVIEW SEND 'get data' command to port 45000 on GW-10000
// WSVIEW SEND 'get sensors' command to port 45000 on GW-1000

// KUN GW1000
// Data
// ffff 2700 0f01 00e5 0637 0827 ee09 27ee 94

// 55 dec = 0x37 hex

// HH = INDOOR HUMID.
//             TTTTTTTTTTHH
// ffff 2700 0f01 00e5 0637 08 27eb 09 27eb 8e / //stationtype=GW1000A_V1.6.8&dateutc=2021-07-09+11%3A10%3A22&tempinf=73.2&humidityin=55&baromrelin=30.180&baromabsin=30.180&freq=868M&model=GW1000_Pro
// ffff 2700 2301 00eb 0639 08 27e8 09 27e8 1a00ca223c1b00de23331c010d24331d0029252041

// ffff 2700 0f01 00e5 0637 08 27eb 09 27eb 8e / 1625830264591 stationtype=GW1000A_V1.6.8&dateutc=2021-07-09+11%3A31%3A03&tempinf=73.0&humidityin=55&baromrelin=30.180&baromabsin=30.180&freq=868M&model=GW1000_Pro



// 59 dec = 0x3B hex

// TEMP INDOOR = TI = 4 bytes = in celsius = 00e5 = 235 /10 = 23.5 celcius
// H1 - humidity T1
// CC - checksum?
// PPPP - rel/abs-pressure in mbar * 10 =  27eb = 10219 = 1021.9 mbar = 30,1767 inHg ???
// HEADER 27 00 = response to command 27 ?? // Data: ff ff 27 03 2a COMMAND - 5 bytes - maybe response is 5 bytes
// HEADER 3c 01 = response to command 3c 03 // Data: ffff3c033f

// HEADER LL
// LL - probably length of command+data packet+CC = 2700 .... CC
// LL - MSB + LSB - 00 14 = 0 + 0x14 = 0x14 
// CC - checksum?
// TYPE - 1 byte before each field
// 01 = INDOOR temp
// 06 = INDOOR humidity
// 08 = ABSOLUTE pressure
// 09 = RELATIVE pressure
// 1a = temp sensor 1 - ch 1 
// 1b = temp sensor 2
// 1c = temp sensor 3
// 1d = temp sensor 4
// 2c = soilmoisture 1 - ch 1 = SM
// 2e = soilmoisture 2 - ch 2


// WS-65
// 02 - OT -outdoor temp
// 07 - OH - outdoor humidity
// 0a - WD - wind direction
// 0b - WS - wind speed? unit?
// 0c - WG - wind gust? unit?
// 15 - SR - solar radiation * 10 lux
// 17 - UVI - ?


// PREABLE = ffff
// Each Temp-sensor requires 7 bytes
// |  |CMD|LL  |   TTTT   HH    APPP    RPPP   |T1   |  |H1|CC    T2    H2    T3       H3
// ffff 2700 14 01 00e4 0637 08 27eb 09 27eb 1a 00 ca 22 3b d3                                                         / 1625830774623 stationtype=GW1000A_V1.6.8&dateutc=2021-07-09+11%3A39%3A33&tempinf=73.0&humidityin=55&baromrelin=30.180&baromabsin=30.180&temp1f=68.54&humidity1=59&batt1=0&freq=868M&model=GW1000_Pro
// ffff 2700 19 01 00e3 0637 08 27eb 09 27eb 1a 00 cb 22 3b 1b 00 de 23 33 27                                          / 1625831471660 stationtype=GW1000A_V1.6.8&dateutc=2021-07-09+11%3A51%3A10&tempinf=72.9&humidityin=55&baromrelin=30.174&baromabsin=30.174&temp1f=68.54&humidity1=59&temp2f=72.14&humidity2=51&batt1=0&batt2=0&freq=868M&model=GW1000_Pro
// ffff 2700 1e 01 00e3 0637 08 27e8 09 27e8 1a 00 ca 22 3b 1b 00 df 23 33 1c 01 0d 24 34 a8                           / 1625832083692 stationtype=GW1000A_V1.6.8&dateutc=2021-07-09+12%3A01%3A22&tempinf=72.9&humidityin=55&baromrelin=30.174&baromabsin=30.174&temp1f=68.36&humidity1=59&temp2f=71.96&humidity2=52&temp3f=80.42&humidity3=52&batt1=0&batt2=0&batt3=0&freq=868M&model=GW1000_Pro
// ffff 2700 1e 01 00e6 0637 08 27e9 09 27e9 1a 00 cb 22 3c 1b 00 de 23 33 1c 01 0d 24 34 ae                           / 1625834735801 stationtype=GW1000A_V1.6.8&dateutc=2021-07-09+12%3A45%3A34&tempinf=73.4&humidityin=55&baromrelin=30.168&baromabsin=30.168&temp1f=68.54&humidity1=60&temp2f=72.14&humidity2=51&temp3f=80.42&humidity3=52&batt1=0&batt2=0&batt3=0&freq=868M&model=GW1000_Pro
// ffff 2700 23 01 00e5 0638 08 27e8 09 27e8 1a 00 cb 22 3c 1b 00 df 23 34 1c 01 0d 24 34 1d 00 2d 25 22 44            / 1625835126821 stationtype=GW1000A_V1.6.8&dateutc=2021-07-09+12%3A52%3A05&tempinf=73.2&humidityin=56&baromrelin=30.168&baromabsin=30.168&temp1f=68.54&humidity1=60&temp2f=71.96&humidity2=51&temp3f=80.42&humidity3=52&temp4f=40.10&humidity4=34&batt1=0&batt2=0&batt3=0&batt4=0&freq=868M&model=GW1000_Pro
// ffff 2700 23 01 00e8 063a 08 27e9 09 27e9 1a 00 c9 22 3b 1b 00 de 23 33 1c 01 0d 24 33 1d 00 28 25 20 3e                                        // P = 1021.5, TI = 23.3 HI = 58, PA = 1021.5 hpa, PR = 1021.5 / 1625840363035 stationtype=GW1000A_V1.6.8&dateutc=2021-07-09+14%3A19%3A22&tempinf=73.9&humidityin=58&baromrelin=30.165&baromabsin=30.165&temp1f=68.36&humidity1=59&temp2f=71.96&humidity2=51&temp3f=80.42&humidity3=51&temp4f=39.02&humidity4=32&batt1=0&batt2=0&batt3=0&batt4=0&freq=868M&model=GW1000_Pro
// ffff 2700 23 01 00ec 0639 08 27e6 09 27e6 1a 00 c9 22 3b 1b 00 df 23 33 1c 01 0d 24 33 1d 00 27 25 20 3b

//                                          |   SM| 
// ffff 2700 25 01 00de 0638 08 27e6 09 27e6 2c 58 1a 00 c7 22 3e 1b 00 da 23 34 1c 01 13 24 28 1d 00 22 25 20 a5
// ffff 2700 25 01 00e2 0637 08 27e7 09 27e7 2e 58 1a 00c7223d1b00da23341c010f24281d00212520a6


// https://stackoverflow.com/questions/57803/how-to-convert-decimal-to-hexadecimal-in-javascript

// Convert a number to a hexadecimal string with:

//hexString = yourNumber.toString(16);
//And reverse the process with:

//yourNumber = parseInt(hexString, 16);

// Added WS65
//                                           OT      OH      | WD |   | WS | | WG |   SR       |
// ffff 2700 56 01 00e5 0637 08 27e9 09 27e9 02 007f 07 55 0a 00bf 0b 000a 0c 000a 15 00022bd2 16 0098 17 01 2c 57 1a 00c4 22 3d 1b 00da 23 33 1c 010a 24 29 1d 0027 25 28 19 000f 0e 0000 10 0000 11 0096 1200000096 13 000000b 90 d0000 fa
// ffff 2700 56 01 00e6 0636 08 27ea 09 27ea 02 0080 07 54 0a 00ed 0b 000a 0c 000f 15 00024540 16 00ae 17 01 2c 57 1a 00c4 22 3d 1b 00da 23 33 1c 0109 24 29 1d 0026 25 24 19 001a 0e 0000 10 0000 11 0096 1200000096 13 000000b 90 d0000 d2
// ffff 2700 56 01 00e6 0636 08 27e8 09 27e8 02 007f 07 54 0a 00eb 0b 0010 0c 0014 15 00020512 16 0079 17 01 2c 57 1a 00c4 22 3d 1b 00da 23 33 1c 0109 24 29 1d 0025 25 23 19 001a 0e 0000 10 0000 11 0096 1200000096 13 000000b 90 d0000 31
// ffff 2700 56 01 00e4 0636 08 27e7 09 27e7 02 0081 07 52 0a 0155 0b 0000 0c 0000 15 00033a72 16 0182 17 01 2c 56 1a00c2223c1b00dd23331c0107242b1d0021251f1900290e0000100000110096120000009613000000b90d00001a
// ffff 2700 56 01 00e4 0635 08 27e8 09 27e8 02 0083 07 52 0a 00e9 0b 0017 0c 001a 15 00035ec6 16 01a1 17 01 2c 56 1a00c2223c1b00dd23331c0107242b1d0020251f1900290e0000100000110096120000009613000000b90d000077
// ffff 2700 56 01 00e5 0636 08 27e9 09 27e9 02 0081 07 52 0a 0105 0b 0009 0c 000f 15 00042ad6 16 0253 17 02 2c 56 1a00c2223c1b00dd23331c0107242b1d0021251f1900290e0000100000110096120000009613000000b90d00000f
// ffff 2700 56 01 00e2 0636 08 27e6 09 27e6 02 0089 07 50 0a 015f 0b 000e 0c 0014 15 00076110 16 050c 17 03 2c 56 1a00c2223c1b00dc23331c0107242b1d002425391900330e0000100000110096120000009613000000b90d0000c7

// T1 = 1a 00 ca22 = 68.54
// T2 = 1b 00 df23 = 72.14
// T3 = 1c 01 0d24 = 80.42
// T4 = 1d 00 2d25 = 40.1  - 11557


// ffff 2700 5c01 00e3 0638 0827 ed09 27ed 0200 9907 4d0a 00d6 0b00 160c 001a15000344c216018a17015100324e002a2c101a00cb223c1b00df23341c010f24321d002c252b1900330e0000100000110096120000009613000000b90d000043


// Sensor ids?
// FF - field nr.?
// EE - enable 00, disable FF
//                                                                                      FF                       EE  T1      FF      EET2      FF      EE T3      FF      EET4
// ffff 3c01 4d00 0000 00f1 0004 01 ff ffff ffff 00 02 ffff ffff ff00 03 ff ffff ff1f 00 05 ffff ffff 0000 06 00 0000 ba00 04 07 0000 00db 0004 08 00 0000 6e00 04 09 0000 0075 0004 0aff ffff ff00 000b ffffffff0000 0c ffffffff0000 0d ffffffff0000 0e 0040c6e30e040ffffffffe1f0010ffffffff1f0011ffffffff1f0012ffffffff1f0013ffffffff1f0014ffffffff1f0015ffffffff1f0016fffffffe0f00170000c50e060418fffffffe0f0019fffffffe0f001affffffff0f001bfffffffe0f001cffffffff0f001dffffffff0f001effffffff0f001fffffffffff0020ffffffffff0021ffffffffff0022ffffffffff0023ffffffffff0024ffffffffff0025ffffffffff0026ffffffffff0027ffffffff0f0028ffffffffff0029ffffffffff002affffffffff002bffffffffff002cffffffffff002dffffffffff002effffffffff002fffffffffff000b
// ffff 3c01 4d00 ffff fffe ff00 01 ff ffff ffff 00 02 ffff ffff ff00 03 ff ffff ff1f 00 05 ffff ffff 0000 06 ff ffff fe00 00 07 ffff fffe 0000 08 ff ffff fe00 00 09 ffff fffe 00000affffffff00000bffffffff00000cffffffff00000dffffffff00000efffffffe1f000ffffffffe1f0010fffffffe1f0011fffffffe1f0012fffffffe1f0013fffffffe1f0014fffffffe1f0015fffffffe1f0016fffffffe0f0017fffffffe0f0018fffffffe0f0019fffffffe0f001affffffff0f001bfffffffe0f001cffffffff0f001dffffffff0f001effffffff0f001fffffffffff0020ffffffffff0021ffffffffff0022ffffffffff0023ffffffffff0024ffffffffff0025ffffffffff0026ffffffffff0027ffffffff0f0028ffffffffff0029ffffffffff002affffffffff002bffffffffff002cffffffffff002dffffffffff002effffffffff002fffffffffff00ba