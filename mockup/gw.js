// Based on https://gist.github.com/tedmiston/5935757


const { timeStamp } = require('console');
const udp = require('dgram');
const net = require('net');
const { PromiseSocket, TimeoutError } = require("promise-socket");

var gwudp_discover = udp.createSocket('udp4');
var gw_discover = {};

// https://www.npmjs.com/package/promise-socket



var gwsocket;
var pgwSocket;

// Based on /WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/WH2350ALL/Alldefine.java
const command = {
    BROADCAST: 0x12,        // 18
    LIVEDATA: 0x27,          // 39
    READ_MAC: 0x26,           // 38
    READ_VER: 0x50,           // 80
    READ_USR_PATH: 0x51,      // 81
    WRITE_USR_PATH: 0x52,   // 82
    READ_CUSTOMIZED: 0x2A,   // 42
    WRITE_CUSTOMIZED: 0x2B // 43
    //  READ_WUNDERGROUND: 32
}

// /WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/Fragment/ConfigrouterFragment.java
// Change router configuration ssid password - l 272 Savedata


class Logger {
    static level = {
        OFF: 0,
        NORMAL : 1,
        VERBOSE: 2
     }

     #level = Logger.level.OFF;

     constructor (lvl)
     {
         this.#level = lvl;
     }

    log(fd)
     {

       if (this.#level === Logger.level.OFF)
        return;

// https://stackoverflow.com/questions/19903841/removing-an-argument-from-arguments-in-javascript
        Array.prototype.shift.apply(arguments);

        console[fd].apply(this,[Date.now()].concat(Array.from(arguments)));
     }

     verbose(fd)
    {
        if (this.#level != Logger.level.VERBOSE)
          return;
        
        this.log(fd);
    
    }
}

class Config {
    
        static log = true;
        static log_level = Logger.level.VERBOSE;
        static port = {
            COMMAND: 45000, // Issue commands - hex port afc8 
            BROADCAST: 59387  // Broadcast to 255.255.255.255:59387 - listen
        };
        static discover_delay = 3000;
    }


class Scanner extends Config {

    #udpSocket;
    gw;
    #logger;
    
    constructor() {
        super();
        this.gw = {};
        this.#logger = new Logger(Config.log_level);
    }

    start()
    {
        this.#udpSocket = udp.createSocket('udp4');

        this.#udpSocket.on('listening',() => {
            this.#logger.log('log',Scanner.name + ' listening')

        })

        this.#udpSocket.on('close',() => {
            this.#logger.log('log',Scanner.name + ' closed after ' + Config.discover_delay + ' ms');

        })

        this.#udpSocket.on('message',this.message.bind(this));
        
        this.#udpSocket.bind(Config.port.BROADCAST);

       if (Config.discover_delay)
         setTimeout(this.stop.bind(this),Config.discover_delay);
        
    }

    stop ()
    {
        this.#udpSocket.close();
        if (Object.entries(this.gw).length)
               this.#logger.log('log',this.gw);
    }

    message(msg,rinfo) {
        var d = Date.now();

        if (!this.gw[rinfo.address]) {
            var mac = msg.toString('hex', 5, 11);
           var name = msg.toString('utf8', 18, msg.length - 1);
           var ip = msg[11].toString()+'.'+msg[12].toString()+'.'+msg[13].toString()+'.'+msg[14].toString();
           this.gw[rinfo.address] = { name: name, mac: mac, ip: ip, rinfo: rinfo, broadcast: msg, lastbroadcast: d };
        }
        else
          this.gw[rinfo.address].lastbroadcast = d;

        this.#logger.log('log',msg, msg.toString('utf8', 18, msg.length - 1), 'MAC: ' + mac  + 'IP '+ip, rinfo);

        //         0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41
        //                                         
        //<Buffer ff ff 12 00 27 48 3f da 55 4d a9 c0 a8 03 cc af c8 17 47 57 31 30 30 30 41 2d 57 49 46 49 34 44 41 39 20 56 31 2e 36 2e 38 09>
        //                       | MAC            |    IP      |CPORT|LL NAME 
        //                                        192.168.3.204|45000|   G  W  1  0  0  0  A  -  W  I  F  I  4  D  A  9     V  1  .  6  .  8
        // CPORT = COMMAND port on gw? af c8 = 45000 dec.
        // WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/Fragment/SystemFragment.java
        // l. 860 void com.ost.newnettool.Fragment.SystemFragment.writeCMD()
    }
    
}

class GW extends Config {
    // Based on /WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/WH2350ALL/Alldefine.java

    #logger;

    static command = {
        BROADCAST: 0x12,        // 18
        LIVEDATA: 0x27,          // 39
        READ_MAC: 0x26,           // 38
        READ_VER: 0x50,           // 80
        READ_USR_PATH: 0x51,      // 81
        WRITE_USR_PATH: 0x52,   // 82
        READ_CUSTOMIZED: 0x2A,   // 42
        WRITE_CUSTOMIZED: 0x2B // 43
        //  READ_WUNDERGROUND: 32
    }
    
    version = null;
    mac = null;
    host=  null;
    customized = {
        server: null,
        port: null,
        enabled: null,
        protocol: null,
        upload_interval: null,
        ecowitt: {
            path: null
        },
        wunderground: {
            path: null,
            stationid: null,
            key: null
        }
    }

    // Declare private fields
    #gwSocket;
    #pgwSocket;
 
    constructor()
    {

        this.#gwSocket = new net.Socket();
        this.#pgwSocket = new PromiseSocket(this.#gwSocket);
        this.#logger = new Logger(Config.log_level);

    } 

    async connect(host) {
        var data;
    
        https://www.npmjs.com/package/promise-socket#timeouterror
    
        try {
    
            await this.#pgwSocket.connect(GW1000.config.port.COMMAND, host);
            // https://stackoverflow.com/questions/37576685/using-async-await-with-a-foreach-loop
    
    
        } catch (e) {
            this.#logger.log('error','Connect failed', e)
            pgwSocket.destroy();
            return;
        }
    
        for (cmd of [GW.command.LIVEDATA, GW.command.READ_MAC, GW.command.READ_VER, GW.command.READ_CUSTOMIZED, GW.command.READ_USR_PATH]) {
            data = await this.get(cmd);
            if (data !== undefined)
                this.parse(data);
    
        }
    
        if (GW.config.log) console.log(gw1000);
    
        // Cleanup
        await this.#pgwSocket.end();
        this.#pgwSocket.destroy();
    }

    async  get(command) {

        var cmd = Buffer.from([0xFF, 0xFF, command, 0x03, 0x00]);
        cmd[4] = GW.checksum(cmd);
        var chunck;
    
        try {
    
            const bytes = await this.#pgwSocket.write(cmd);
        } catch (e) {
            this.#logger.log('error','Write failed ' + command, e);
            return;
        }
    
        if (GW.config.log)
            console.log('C', cmd);
    
        try {
            chunk = await this.#pgwSocket.read();
    
            if (GW.config.log && chunck != undefined)
                console.log('R', chunk, chunk.toString());
        } catch (e) {
            this.#logger.log('error','Read failed', e)
        }
    
        return chunck;
    
    }

    parse_customized_string(data) {
        //  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 39 30 31 32 33 34 35 36 37 38 39 40
        //
        // ff ff 2a 27 06 74 65 73 74 69 64 07 74 65 73 74 6b 65 79 0e 74 65 73 74 6c 77 75 6e 64 65 72 2e 6e 6f 01 00 02 58 01 01 2b> ��*'testidtestkeytestlwunder.no
        //              L  t  e  s  t  i  d  L  t  e  s  t  k  e  y  L  t  e  s t                               | PORT|  UI | P| E| C
    
        // L = length, P = protocol (0 = ecowitt, 1 = wunderground), E = (0=disabled,1=enable), UI = upload interval
    
        var length_pos = 4,
            end_position,
            eof_string_pos;
    
    
        var string = new Array();
        switch (data[2]) {
            case command.READ_CUSTOMIZED:
                end_position = data.length - 7;
                break;
            case command.READ_USR_PATH:
                end_position = data.length - 2;
                break;
            default:
                this.#logger.verbose('log','Unable to find end_position of strings');
                break;
        }
    
        while (length_pos < end_position) {
            eof_string_pos = length_pos + 1 + data[length_pos];
            string.push(data.toString('utf8', length_pos + 1, eof_string_pos));
            length_pos = eof_string_pos;
            
                this.#logger.verbose('log','string', string, 'length_pos', length_pos, ' end_position', end_position);
        }
    
        return string;
    }

    parse(data) {

        var cmd = data[2],
            server,
            path;
    
        switch (cmd) {
    
            case GW.command.LIVEDATA:
                this.parse_livedata(data);
                break;
    
            case GW.command.READ_VER:
                this.version = data.toString('utf8', 5, data.length - 1);
                break;
    
            case GW.command.READ_MAC:
                this.mac = data.toString('hex', 4, data.length - 1);
                break;
    
            case GW.command.READ_USR_PATH:
                path = parse_customized_string(data);
                this.customized.ecowitt.path = path[0];
                if (path[1] != undefined)
                    this.customized.wunderground.path = path[1];
                else
                    this.customized.wunderground.path = '';
                break;
    
            case GW.command.READ_CUSTOMIZED:
    
                server = parse_customized_string(data);
                this.customized.wunderground.stationid = server[0];
                this.customized.wunderground.key = server[1];
                this.customized.server = server[2]
                // https://nodejs.org/api/buffer.html#buffer_buf_readuint16be_offset
                this.customized.port = data.readUInt16BE(data.length - 7);
                this.customized.upload_interval = data.readUInt16BE(data.length - 5);
                this.customized.enabled = data.readUInt8(data.length - 2) == 1 ? true : false;
                this.customized.protocol = data.readUInt8(data.length - 3) == 1 ? 'wunderground' : 'ecowitt';
                break;
    
            default:
                this.#logger.log('log','Unable to parse command response', cmd.toString(16));
                break;
        }
    
    
    }

    checksum(buf) {
        var cs = 0;

        for (i = 2; i < buf.length - 1; i++)
            cs += buf[i];

        this.#logger.verbose('log','Checksum', buf, '0x' + cs.toString(16));

        return cs;
    }
    
}



function init() {
    gwsocket = new net.Socket();
    pgwSocket = new PromiseSocket(gwsocket);
    pgwSocket.setTimeout(5000);
    connect();
}


//iface_name = 'wlp7s0';
//var ip4adr = os.networkInterfaces()[iface_name][0].address;

//if (config.log && config.log_level > log_level.NORMAL) console.log(iface_name + ' ' + ip4adr);

// Make sure broadcast port is open in the firewall for Hotspot
//sudo firewall-cmd --add-port=59387/udp --zone=nm-shared


   //https://stackoverflow.com/questions/38987784/how-to-convert-a-hexadecimal-string-to-uint8array-and-back-in-javascript
   // client.write(Uint8Array.from(Buffer.from('ffff2a032d', 'hex'))); // IP, port number is two bytes after IP adr., and upload interval two bytes after port
  