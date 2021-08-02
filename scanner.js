
import udp from 'dgram'
import { Logger } from './logger.js'
import { Config } from './config.js'
import { GW } from './gw.js';
import os from 'os'

export class Scanner {

    #udpServer;
    #broadcastSocket;
    gw_broadcast;
    #logger;

    constructor() {
        this.gw_broadcast = {};
        this.#logger = new Logger(Config.log_level);
        this.gw = new GW();
    }

    start() {

        let method;

        // Method 1 : GW1000 sends udp4 broadcast to 255.255.255.255:59387 
        this.#udpServer = udp.createSocket('udp4');

        this.#udpServer.on('close', () => {
            this.#logger.log('log', Logger.level.NORMAL,  'UDP server closed after ' + Config.discover_delay + ' ms');

        })

        method='UDP server listening for broadcast on port '+Config.port.BROADCAST
        this.#udpServer.on('message', this.message.bind(this,method));
        this.#udpServer.bind(Config.port.BROADCAST, () => {
            this.#logger.log('log', Logger.level.NORMAL, method)
        });

        // Method 2: GW1000 listen for broadcast on port 46000

       this.#broadcastSocket = udp.createSocket('udp4');

        this.#broadcastSocket.on('error', (err) => {
            this.#logger.log('error',Logger.level.NORMAL,'Error on broadcast socket',err);
        });

        this.#broadcastSocket.on('listening', this.broadcastListener.bind(this));
        method='udp broadcast to port '+ Config.port.BROADCAST_46000;
        this.#broadcastSocket.on('message', this.broadcastMessage.bind(this,method));

        this.#broadcastSocket.bind(Config.port.BROADCAST_46000);
        
        if (Config.discover_delay)
            setTimeout(this.stop.bind(this), Config.discover_delay);

    }

    stop() {
        this.#udpServer.close();
        this.#broadcastSocket.close();
        if (Object.entries(this.gw_broadcast).length)
            this.#logger.log('log', Logger.level.NORMAL, this.gw_broadcast);
    }

    broadcastListener() {
        this.#broadcastSocket.setBroadcast(true);
        // WSView app sending ffff12000416 - wireshark-log
        // 2 bytes for packet length 0004 - normally 1 bytes
        let bpacketBuf = this.gw.create_broadcast_packet().toBuffer();
        this.#logger.log('log', Logger.level.DEBUG, 'Packet to be sent', bpacketBuf, bpacketBuf.length);

        let baddr;
        let osinterfaces = os.networkInterfaces();

        //https://stackoverflow.com/questions/3653065/get-local-ip-address-in-node-js?page=1&tab
        for (const interf of Object.keys(osinterfaces)) {

            let ip4 = osinterfaces[interf][0]

            this.#logger.log('log',Logger.level.DEBUG,'ip4', ip4, ip4.cidr);

            if (!ip4.internal && ip4.cidr.endsWith('/24'))  // Only broadcast to 255.255.255.0 netmask
            {
                baddr = ip4.address.substring(0, ip4.address.lastIndexOf('.')) + '.255';
                this.#logger.log('log',Logger.level.VERBOSE,'Sending broadcast packet to ' + baddr+':'+Config.port.BROADCAST_46000);
                this.#broadcastSocket.send(bpacketBuf, 0, bpacketBuf.length, Config.port.BROADCAST_46000, baddr, (err) => {
                    if (err != null && err != undefined)
                        this.#logger.log('error', Logger.level.NORMAL, 'Failed to send broadcast to socket', this.#broadcastSocket);
                });
            }

        }
    }

    broadcastMessage(method,msg, rinfo) {
        this.#logger.log('log',Logger.level.VERBOSE,'Broadcast',msg,rinfo);

          // Skip broadcast to own ip adr./size 6
        if (msg.length > 6) 
        {
            // Parse message
            this.message(method,msg,rinfo);
        }
    }

    message(method, msg, rinfo) {
        const d = Date.now();
        let mac, ssid, ip;

        mac = msg.toString('hex', 5, 11);
        ssid = msg.toString('utf8', 18, msg.length - 1);
        ip = msg[11].toString() + '.' + msg[12].toString() + '.' + msg[13].toString() + '.' + msg[14].toString();

        if (!this.gw_broadcast[rinfo.address]) {

            this.#logger.log('log',Logger.level.VERBOSE,'Detected ',rinfo.address);
            this.gw_broadcast[rinfo.address] = { method: method,ssid: ssid, mac: mac, ip: ip, rinfo: rinfo, broadcast: msg, lastbroadcast: d };
        }
        else
            this.gw_broadcast[rinfo.address].lastbroadcast = d;

        // this.#logger.log('log', Logger.level.NORMAL,msg, msg.toString('utf8', 18, msg.length - 1), 'MAC: ' + mac + 'IP ' + ip, rinfo);

        //         0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41
        //                                         
        //<Buffer ff ff 12 00 27 48 3f da 55 4d a9 c0 a8 03 cc af c8 17 47 57 31 30 30 30 41 2d 57 49 46 49 34 44 41 39 20 56 31 2e 36 2e 38 09>
        //                       | MAC            |    IP      |CPORT|LL ssid 
        //                                        192.168.3.204|45000|   G  W  1  0  0  0  A  -  W  I  F  I  4  D  A  9     V  1  .  6  .  8
        // CPORT = COMMAND port on gw? af c8 = 45000 dec.
        // WSView_v1.1.51_apkpure.com_source_from_JADX/sources/com/ost/newnettool/Fragment/SystemFragment.java
        // l. 860 void com.ost.newnettool.Fragment.SystemFragment.writeCMD()
    }

}
