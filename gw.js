// Make sure GW1000 broadcast port is open in the firewall for Hotspot
//sudo firewall-cmd  --permanent --add-port=59387/udp --zone=nm-shared
// Some info based on decompiling WSView with http://www.javadecompilers.com/apk (JADX decompiler)
// Protocol documentation : https://osswww.ecowitt.net/uploads/20210716/WN1900%20GW1000,1100%20WH2680,2650%20telenet%20v1.6.0%20.pdf (https://www.ecowitt.com/shop/forum/forumDetails/255)
// WSView apk downloaded from https://apkpure.com/ws-view/com.ost.wsview

//https://stackoverflow.com/questions/35728117/difference-between-import-http-requirehttp-and-import-as-http-from-htt
import * as http from 'http'
//import * as os from 'os'

import { URLSearchParams } from 'url'

import { PromiseSocket, TimeoutError } from 'promise-socket'
import Logger from './logger.js'
import Config from './config.js'
import Packet from './packet/packet.js'
import Packet_Customized from './packet/customized.js'
import Packet_Customized_Path from './packet/customized_path.js'
import Packet_MAC from './packet/mac.js'
import Packet_Version from './packet/version.js'
import { Command, CommandResult, Protocol } from './const.js'



// https://www.npmjs.com/package/promise-socket

// /WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/Fragment/ConfigrouterFragment.java
// Change router configuration ssid password - l 272 Savedata


class GW {

    #parsedPacket; // Latest received and parsed packet

    #gwSocket;
    #pgwSocket;
    #logger;
    #server;

    constructor() {
        this.#pgwSocket = new PromiseSocket(this.#gwSocket);
        this.#pgwSocket.setTimeout(60000);
        this.#logger = new Logger(Config.log_level);
        //this.#server = this.createServer();

    }

    // For wireless hotspot in fedora, zone nm-shared have closed ports
    // sudo firewall-cmd  --add-port 1024-65535/tcp --add-port 1024-65535/udp --zone=nm-shared
    // sudo firewall-cmd --runtime-to-permanent
    createServer() {

        let httpServer = http.createServer((request, response) => {

            const { headers, method, url } = request;
            console.log(Date.now(), headers, method, url);
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
                console.log(Date.now(), tempParams.toString());

                response.writeHead(200);
                response.end();
            });
        });

        this.#server = this.createServer();

        httpServer.on('listening', () => {
            this.#logger.log('log', Logger.level.NORMAL, 'Listening for customized http requests on ' + Config.hostname + ':' + Config.hostport);
        });

        //iface_name = 'wlp7s0';
        //let gwHostname = os.networkInterfaces()[Config.interface][0].address;

        httpServer.listen(Config.hostport, Config.hostname);
        // Test: sudo netstat -plnt | grep node


    }

    getCommandName(cmd) {
        https://stackoverflow.com/questions/56821332/how-to-to-use-find-with-object-entries/56821365
        return Object.entries(Command).find(([key, value]) => value == cmd)[0]
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

        /* for (let p of [new Packet(Command.READ_MAC).writeCRC(), new Packet(Command.READ_VER).writeCRC(), new Packet(Command.READ_CUSTOMIZED).writeCRC(), new Packet(Command.READ_USR_PATH).writeCRC()]) {
             recvPacket = await this.write(p);
 
         }
 
         this.setCustomizedUrl(); // requires execution of READ_CUSTOMIZED and READ_USR_PATH   
         
         this.#logger.log('log', Logger.level.VERBOSE, 'Customized', this.customized); */

    }

    setCustomizedUrl() {
        switch (this.customized.protocol) {
            case Protocol.WUNDERGROUND:
                //https://nodejs.org/api/url.html#url_new_url_input_base
                this.customized.url = new URL(this.customized.path.wunderground, 'http:/' + this.customized.hostname + ':' + this.customized.port);
                break;
            case Protocol.ECOWITT:
                this.customized.url = new URL(this.customized.path.ecowitt, 'http:/' + this.customized.hostname + ':' + this.customized.port);
                break;

        }

    }

    async disconnect() {
        // Cleanup
        await this.#pgwSocket.end();
        this.#pgwSocket.destroy();
    }

    async get(cmd) {
        let result;

        result = await this.writePackets([new Packet(cmd).writeCRC()]);
        if (this.#parsedPacket)
            return this.#parsedPacket.get();

    }

    async write(packet) {

        let command = packet.readUint8(2);
        let chunk;
        let responseCommand;
        let recvPacket;

        // TEST return Promise.reject(new Error('write reject'));

        try {
            this.#logger.log('log', Logger.level.VERBOSE, '>', this.getCommandName(command).padEnd(15), packet.toBuffer())
            const bytes = await this.#pgwSocket.write(packet.toBuffer());
        } catch (e) {
            this.#logger.log('error', Logger.level.VERBOSE, 'Write failed ' + command, e);
            return Promise.reject(e);
        }

        try {
            chunk = await this.#pgwSocket.read();
            responseCommand = chunk[2];

            if (chunk)
                this.#logger.log('log', Logger.level.VERBOSE, '<', this.getCommandName(responseCommand).padEnd(15), chunk, chunk.toString());

            recvPacket = (new Packet()).fromBuffer(chunk);

            if (recvPacket)
                this.#parsedPacket = this.parse(recvPacket.toBuffer());

            //  this.#logger.log('log', Logger.level.VERBOSE, 'Received packet', recvPacket.getBuffer())

            if (!recvPacket.isChecksumOK())
                this.#logger.log('error', Logger.level.VERBOSE, 'Received packet has invalid checksum 0x' + recvPacket.getChecksum().toString(16), recvPacket)
        } catch (e) {
            this.#logger.log('error', Logger.level.VERBOSE, 'Read failed', e)
            return Promise.reject(e);
        }

        return recvPacket;

    }

    // <Buffer ff ff 2a 27 06 74 65 73 74 69 64 07 74 65 73 74 6b 65 79 0e 74 65 73 74 6c 77 6f 6e 64 65 72 2e 6e 6f 1f 40 00 10 01 01 39>
    // <Buffer ff ff 2b 26 06 74 65 73 74 69 64 07 74 65 73 74 6b 65 79 0e 74 65 73 74 6c 77 6f 6e 64 65 72 2e 6e 6f 40 00 10 01 01 01 1a>

    async writePackets(packets) {
        var results = [];
        //https://www.youtube.com/watch?v=_9vgd9XKlDQ
        // Promise.all, Promise.allSettled works, but does not wait for response from gw

        for (let p of packets) {
            try {
                results.push(await this.write(p));
            } catch (e) {
                this.#logger.log('log', Logger.level.VERBOSE, 'writePackets catched', e);
                //Promise.reject(e);
            }

        }

        this.#logger.log('log', Logger.level.VERBOSE, 'writePackets results', results);

        return results;
    }

    async writeCustomized(customized) {
        await this.writePackets([new Packet_Customized().create(customized), new Packet_Customized_Path().create(customized)]);
    }

    create_broadcast_packet()
    // UDP broadcast for local GW to port 46000
    {
        let p = (new Packet(Command.BROADCAST, true)).writeCRC();

        this.#logger.log('log', Logger.level.VERBOSE, 'create_broadcast_packet', p.toBuffer());

        return p;
    }

    parse_livedata(data) {
        this.#logger.log('log', Logger.level.NORMAL, 'Parse livedata not implemented');
    }

    parse(data) {

        let cmd = data[2],
            result,
            p;

        switch (cmd) {

            case Command.LIVEDATA:
                this.parse_livedata(data);
                break;

            
            case Command.READ_VER:

               p = new Packet_Version(data);
               break;


            case Command.READ_MAC:

                p = new Packet_MAC(data);

                break;

            case Command.READ_USR_PATH:

                p = new Packet_Customized_Path(data);

                break;

            case Command.READ_CUSTOMIZED:

                p = new Packet_Customized(data);

                break;

            case Command.WRITE_CUSTOMIZED:
            case Command.WRITE_USR_PATH:
                result = data[4];

                switch (result) {
                    case CommandResult.SUCCESS:

                        this.#logger.log('log', Logger.level.VERBOSE, '  ' + this.getCommandName(cmd) + ' ' + cmd.toString(16) + ' SUCCESS');
                        break;
                    case CommandResult.FAIL:
                        this.#logger.log('log', Logger.level.VERBOSE, '  ' + this.getCommandName(cmd) + ' ' + +cmd.toString(16) + ' FAIL');
                        break;
                }

                break;


            case Command.BROADCAST:

                break;


            default:
                this.#logger.log('error', Logger.level.NORMAL, 'Unable to parse command response', cmd.toString(16));
                break;
        }

        return p;
    }

}

export default GW;

//iface_name = 'wlp7s0';
//var ip4adr = os.networkInterfaces()[iface_name][0].address;

//if (config.log && config.log_level > log_level.NORMAL) console.log(iface_name + ' ' + ip4adr);

//https://stackoverflow.com/questions/38987784/how-to-convert-a-hexadecimal-string-to-uint8array-and-back-in-javascript
// client.write(Uint8Array.from(Buffer.from('ffff2a032d', 'hex'))); // IP, port number is two bytes after IP adr., and upload interval two bytes after port
