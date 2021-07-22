// Make sure GW1000 broadcast port is open in the firewall for Hotspot
//sudo firewall-cmd  --permanent --add-port=59387/udp --zone=nm-shared
// Some info based on decompiling WSView with http://www.javadecompilers.com/apk (JADX decompiler)
// WSView apk downloaded from https://apkpure.com/ws-view/com.ost.wsview

import udp from 'dgram';
import net from 'net';
import { PromiseSocket, TimeoutError } from 'promise-socket'
import { Logger } from './logger.js'
import { Scanner } from './scanner.js'
import { Config } from './config.js'
import { Packet } from './packet.js'

// https://www.npmjs.com/package/promise-socket

// /WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/Fragment/ConfigrouterFragment.java
// Change router configuration ssid password - l 272 Savedata

export class GW {

    // Based on /WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/WH2350ALL/Alldefine.java

    static Command = {
        BROADCAST: 0x12,        // 18
        LIVEDATA: 0x27,        // 39
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
        },
        url: null
    }

    #gwSocket;
    #pgwSocket;
    #logger;

    constructor() {
        this.#pgwSocket = new PromiseSocket(this.#gwSocket);
        this.#pgwSocket.setTimeout(5000);
        this.#logger = new Logger(Config.log_level);

    }

    getCommandName(cmd) {
        https://stackoverflow.com/questions/56821332/how-to-to-use-find-with-object-entries/56821365
        return Object.entries(GW.Command).find(([key, value]) => value == cmd)[0]
    }

    async connect(host) {
        let recvPacket;

        https://www.npmjs.com/package/promise-socket#timeouterror

        try {

            await this.#pgwSocket.connect(Config.port.COMMAND, host);
            // https://stackoverflow.com/questions/37576685/using-async-await-with-a-foreach-loop

        } catch (e) {
            this.#logger.log('error', Logger.level.NORMAL, 'Connect failed', e)
            this.#pgwSocket.destroy();
            return;
        }

        for (let cmd of [GW.Command.READ_MAC, GW.Command.READ_VER, GW.Command.READ_CUSTOMIZED, GW.Command.READ_USR_PATH]) {
            recvPacket = await this.get(cmd);
            if (recvPacket)
                this.parse(recvPacket.toBuffer());

        }

        this.setCustomizedUrl(); // requires execution of READ_CUSTOMIZED and READ_USR_PATH         

        this.#logger.log('log', Logger.level.VERBOSE, 'Customized', this.customized);

    }

    setCustomizedUrl() {
        switch (this.customized.protocol) {
            case 'wunderground':
                //https://nodejs.org/api/url.html#url_new_url_input_base
                this.customized.url = new URL(this.customized.wunderground.path, 'http:/' + this.customized.server + ':' + this.customized.port);
                break;
            case 'ecowitt':
                this.customized.url = new URL(this.customized.ecowitt.path, 'http:/' + this.customized.server + ':' + this.customized.port);
                break;

        }

    }

    async disconnect() {
        // Cleanup
        await this.#pgwSocket.end();
        this.#pgwSocket.destroy();
    }

    async get(command) {

        let packet = (new Packet(command)).writeCRC();

        let chunk;

        let responseCommand;

        try {
            this.#logger.log('log', Logger.level.VERBOSE, '>', this.getCommandName(command).padEnd(15), packet.toBuffer())
            const bytes = await this.#pgwSocket.write(packet.toBuffer());
        } catch (e) {
            this.#logger.log('error', Logger.level.VERBOSE, 'Write failed ' + command, e);
            return;
        }

        try {
            chunk = await this.#pgwSocket.read();
            responseCommand = chunk[2];

            if (chunk)
                this.#logger.log('log', Logger.level.VERBOSE, '<', this.getCommandName(responseCommand).padEnd(15), chunk, chunk.toString());
        } catch (e) {
            this.#logger.log('error', Logger.level.VERBOSE, 'Read failed', e)
        }

        const recvPacket = (new Packet()).fromBuffer(chunk);

        this.#logger.log('log', Logger.level.VERBOSE, 'Received packet', recvPacket.getBuffer())

        if (!recvPacket.isChecksumOK())
            this.#logger.log('error', Logger.level.VERBOSE, 'Received packet has invalid checksum 0x' + recvPacket.getChecksum().toString(16), recvPacket)

        return recvPacket;

    }

    // <Buffer ff ff 2a 27 06 74 65 73 74 69 64 07 74 65 73 74 6b 65 79 0e 74 65 73 74 6c 77 6f 6e 64 65 72 2e 6e 6f 1f 40 00 10 01 01 39>
    // <Buffer ff ff 2b 26 06 74 65 73 74 69 64 07 74 65 73 74 6b 65 79 0e 74 65 73 74 6c 77 6f 6e 64 65 72 2e 6e 6f 40 00 10 01 01 01 1a>


    create_user_path_packet() {
        let p = (new Packet(GW.Command.WRITE_USR_PATH)).writeString(this.customized.ecowitt.path, this.customized.wunderground.path).writeCRC();


        this.#logger.log('log', Logger.level.VERBOSE, 'create_user_path_packet', this.customized, p.toBuffer());

        return p.toBuffer();

    }

    create_customized_packet()
    // for write customized 0x2b command
    {
        let p = new Packet(GW.Command.WRITE_CUSTOMIZED);

        p.writeString(this.customized.wunderground.stationid, this.customized.wunderground.key, this.customized.server)
        p.writeUint16BE(this.customized.port, this.customized.upload_interval)
        p.writeUint8(Number(this.customized.protocol === 'wunderground'), Number(this.customized.enabled === true)).writeCRC();

        this.#logger.log('log', Logger.level.VERBOSE, 'create_customized_packet', this.customized, p.toBuffer());

        return p.toBuffer();
    }

    parse_customized_string(data) {
        /*
          0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 39 30 31 32 33 34 35 36 37 38 39 40
        
         ff ff 2a 27 06 74 65 73 74 69 64 07 74 65 73 74 6b 65 79 0e 74 65 73 74 6c 77 75 6e 64 65 72 2e 6e 6f 01 00 02 58 01 01 2b> ��*'testidtestkeytestlwunder.no
                  PL  L  t  e  s  t  i  d  L  t  e  s  t  k  e  y  L  t  e  s t  l  w  u  n  d  e  r  .  n  o| PORT|  UI | P| E| C
         PL 0x27 =   39 (not including preamble ff ff) 
         L = length, P = protocol (0 = ecowitt, 1 = wunderground), E = (0=disabled,1=enable), UI = upload interval 16-600s,C = checksum
        */

        let length_pos = 4,
            end_position,
            eof_string_pos;

        let string = new Array();
        switch (data[2]) {
            case GW.Command.READ_CUSTOMIZED:
                end_position = data.length - 7;
                break;
            case GW.Command.READ_USR_PATH:
                end_position = data.length - 2;
                break;
            default:
                this.#logger.log('log', Logger.level.DEBUG, 'Unable to find end_position of strings');
                break;
        }

        while (length_pos < end_position) {
            eof_string_pos = length_pos + 1 + data[length_pos];
            string.push(data.toString('utf8', length_pos + 1, eof_string_pos));
            length_pos = eof_string_pos;

            this.#logger.log('log', Logger.level.DEBUG, 'customized string', string, 'length_pos', length_pos, ' end_position', end_position);
        }

        return string;
    }

    parse_livedata(data) {
        this.#logger.log('log', Logger.level.NORMAL, 'Parse livedata not implemented');
    }

    parse(data) {

        let cmd = data[2],
            server,
            path;

        switch (cmd) {

            case GW.Command.LIVEDATA:
                this.parse_livedata(data);
                break;

            case GW.Command.READ_VER:
                this.version = data.toString('utf8', 5, data.length - 1);
                this.#logger.log('log', Logger.level.NORMAL, 'Version'.padEnd(8), this.version)
                break;

            case GW.Command.READ_MAC:
                this.mac = data.toString('hex', 4, data.length - 1);
                this.#logger.log('log', Logger.level.NORMAL, 'MAC'.padEnd(8), this.mac);
                break;

            case GW.Command.READ_USR_PATH:
                path = this.parse_customized_string(data);
                this.customized.ecowitt.path = path[0];
                if (path[1] != undefined)
                    this.customized.wunderground.path = path[1];
                else
                    this.customized.wunderground.path = '';


                this.#logger.log('log', Logger.level.NORMAL, 'Ecowitt path'.padEnd(19) + this.customized.ecowitt.path + '\n' + 'Wunderground path'.padEnd(19) + this.customized.wunderground.path);

                this.create_user_path_packet();
                break;

            case GW.Command.READ_CUSTOMIZED:

                server = this.parse_customized_string(data);
                this.customized.wunderground.stationid = server[0];
                this.customized.wunderground.key = server[1];
                this.customized.server = server[2]
                // https://nodejs.org/api/buffer.html#buffer_buf_readuint16be_offset
                this.customized.port = data.readUInt16BE(data.length - 7);
                this.customized.upload_interval = data.readUInt16BE(data.length - 5);
                this.customized.enabled = data.readUInt8(data.length - 2) == 1 ? true : false;
                this.customized.protocol = data.readUInt8(data.length - 3) == 1 ? 'wunderground' : 'ecowitt';

                this.#logger.log('log', Logger.level.NORMAL, 'Customized', this.customized);


                // this.create_customized_packet();

                break;

            default:
                this.#logger.log('log', Logger.level.NORMAL, 'Unable to parse command response', cmd.toString(16));
                break;
        }


    }

}


//iface_name = 'wlp7s0';
//var ip4adr = os.networkInterfaces()[iface_name][0].address;

//if (config.log && config.log_level > log_level.NORMAL) console.log(iface_name + ' ' + ip4adr);

//https://stackoverflow.com/questions/38987784/how-to-convert-a-hexadecimal-string-to-uint8array-and-back-in-javascript
// client.write(Uint8Array.from(Buffer.from('ffff2a032d', 'hex'))); // IP, port number is two bytes after IP adr., and upload interval two bytes after port

